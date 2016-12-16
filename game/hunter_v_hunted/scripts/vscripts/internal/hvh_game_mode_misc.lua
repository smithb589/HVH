-- disruptor_glimpse does not work on the first cast (some kind of hardcoding),
-- so this forces glimpse to be cast once on dummies at the start of the game.
-- 11/12/2015: Also fixes weaver_time_lapse!
function HVHGameMode:GlimpseFix()
    local dummy = CreateUnitByName("npc_dummy", Vector(0,0,0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    local dummy2 = CreateUnitByName("npc_dummy", Vector(0,0,0), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy:AddAbility("disruptor_glimpse")
    dummy2:AddAbility("weaver_time_lapse")
    local glimpse = dummy:FindAbilityByName("disruptor_glimpse")
    local timeLapse = dummy2:FindAbilityByName("weaver_time_lapse")
    Timers:CreateTimer(3.0, function()
      dummy:CastAbilityOnTarget(dummy2, glimpse, 0)
      dummy2:CastAbilityNoTarget(timeLapse, 0)
      Timers:CreateTimer(3.0, function()
        dummy:ForceKill(false)
        dummy2:ForceKill(false)
      end)
    end)
end

-- accessible by panorama
function HVHGameMode:PushScoreToCustomNetTable()
  local mode = GameRules:GetGameModeEntity()
  CustomNetTables:SetTableValue("scores", "GoodGuyLives", { value = mode.GoodGuyLives })
  CustomNetTables:SetTableValue("scores", "BadGuyLives", { value = mode.BadGuyLives })
end

-- Custom Games: PrecacheUnitByNameSync and PrecacheUnitByNameAsync can optionally take a PlayerID as the last
-- argument and it will use the cosmetic items from that player when precaching. The player must be connected to the
-- game otherwise it will fall back to the default cosmetic items.
function HVHGameMode:PostLoadPrecache()
  -- precache both heroes and cosmetics from each playerID, just in case we do team-switching logic later
  for playerID = 0, DOTA_MAX_PLAYERS-1 do
    if PlayerResource:IsValidPlayer(playerID) then
      --print("PlayerID " .. playerID .. " is a valid player.")
      PrecacheUnitByNameAsync("npc_dota_hero_sniper"       , function(...) end, playerID)
      PrecacheUnitByNameAsync("npc_dota_hero_night_stalker", function(...) end, playerID)
    end
  end
end

-------------------------------------------------------------------
-- Gold/XP filters
-------------------------------------------------------------------
-- BUG: this does not VISUALLY work yet but perhaps one day...
-- http://dev.dota2.com/showthread.php?t=173007
-- https://moddota.com/forums/discussion/553/removing-all-gold-from-kills
function HVHGameMode:ModifyGoldFilter(table)
  --Disable gold gain from hero kills
  if table["reason_const"] == DOTA_ModifyGold_HeroKill then
    table["gold"] = GOLD_PER_KILL
    return true
  end
  --Otherwise use normal logic
  return false
end

function HVHGameMode:ModifyExperienceFilter(table)
  --Static XP gain from hero kills
  if table["reason_const"] == DOTA_ModifyXP_HeroKill then
    
    if PlayerResource:GetTeam(table["player_id_const"]) == DOTA_TEAM_GOODGUYS then
      --print("XP to the good guys!")
      table["experience"] = XP_PER_KILL * XP_MULTIPLIER_FOR_SNIPER_KILLS
    else
      --print("XP to the bad guys!")
      table["experience"] = XP_PER_KILL
    end
    
    return true
  end
  --Otherwise use normal logic
  return false
end

-------------------------------------------------------------------
-- Deprecated functions that might be useful for reference later on
-------------------------------------------------------------------
function HVHGameMode:SetupFastTime_OLD_DEPRECATED()
  Timers:CreateTimer(function()
    local timeOfDay = GameRules:GetTimeOfDay()
    print ("Time: " .. Time() .. ", DOTA time: " .. GameRules:GetDOTATime(false,false) .. ", Game time: " .. timeOfDay)
    GameRules:SetTimeOfDay(timeOfDay + EXTRA_FLOAT_TIME_PER_SECOND)
    return 1.0
  end)
end

function HVHGameMode:SetupPassiveXP_DEPRECATED()
  Timers:CreateTimer(XP_TICK_INTERVAL, function()

    local heroList = HeroList:GetAllHeroes()
    for _,hero in pairs(heroList) do
      if hero:IsAlive() then
        hero:AddExperience(XP_PER_TICK, DOTA_ModifyXP_Unspecified, false, true)
      end
    end

    return XP_TICK_INTERVAL
  end)
end

function HVHGameMode:ChooseRandomSpawn_DEPRECATED(classname)
  local possibleSpawners = Entities:FindAllByClassname(classname)
  local r = RandomInt(1, #possibleSpawners)
  spawner = possibleSpawners[r]

  return spawner
end

function HVHGameMode:SetHeroDeathBounty_DEPRECATED(hero)
  --PrintTable(XP_PER_LEVEL_TABLE)
  --local heroLevel = hero:GetLevel()
  --local deathXP = 100
  --hero:SetDeathXP(deathXP)
  --hero:SetMaximumGoldBounty(0)
  --hero:SetMinimumGoldBounty(0)
  --hero:AddExperience(13600, DOTA_ModifyXP_Unspecified, false, true)
  --print("Current XP: " .. hero:GetCurrentXP())
  --print("DeathXP: " .. deathXP)
  --print("Bounty: " .. hero:GetGoldBounty())
end