require("hvh_settings")

function HVHGameMode:_InitGameMode()
  GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
  GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
  GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
  GameRules:SetPreGameTime( PRE_GAME_TIME)
  GameRules:SetPostGameTime( POST_GAME_TIME )
  GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
  GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
  GameRules:SetGoldPerTick(GOLD_PER_TICK)
  GameRules:SetGoldTickTime(GOLD_TICK_TIME)
  GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
  GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
  GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )

  ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'OnPlayerConnectFull'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self)
  ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(self, 'OnAbilityUsed'), self)

  local count = 0
    for team,number in pairs(CUSTOM_TEAM_PLAYER_COUNT) do
      if count >= MAX_NUMBER_OF_TEAMS then
        GameRules:SetCustomGameTeamMaxPlayers(team, 0)
      else
        GameRules:SetCustomGameTeamMaxPlayers(team, number)
      end
      count = count + 1
    end
end

-- This function is called as the first player loads and sets up the GameMode parameters
function HVHGameMode:_SetupGameMode()
  if mode == nil then
    -- Set GameMode parameters
    mode = GameRules:GetGameModeEntity()
    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
    --mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
    mode:SetBuybackEnabled( BUYBACK_ENABLED )
    mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
    mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
    mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    --DeepPrintTable(XP_PER_LEVEL_TABLE)

    mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
    mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

    mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )

    mode:SetAlwaysShowPlayerInventory( SHOW_ONLY_PLAYER_INVENTORY )
    mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )
    if FORCE_PICKED_HERO ~= nil then
      mode:SetCustomGameForceHero( FORCE_PICKED_HERO )
    end
    mode:SetFixedRespawnTime( FIXED_RESPAWN_TIME ) 
    mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
    mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
    mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )
    mode:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )
    mode:SetMaximumAttackSpeed( MAXIMUM_ATTACK_SPEED )
    mode:SetMinimumAttackSpeed( MINIMUM_ATTACK_SPEED )
    mode:SetStashPurchasingDisabled ( DISABLE_STASH_PURCHASING )

    for rune, spawn in pairs(ENABLED_RUNES) do
      mode:SetRuneEnabled(rune, spawn)
    end

    -- HVH specific
    mode:SetModifyGoldFilter( Dynamic_Wrap( self, "ModifyGoldFilter" ), self )
    mode:SetModifyExperienceFilter( Dynamic_Wrap( self, "ModifyExperienceFilter" ), self )
    mode:SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, GOODGUY_LIVES)
    mode:SetTopBarTeamValue(DOTA_TEAM_BADGUYS, BADGUY_LIVES)
    mode.GoodGuyLives = GOODGUY_LIVES
    mode.BadGuyLives  = BADGUY_LIVES

  end 
end

-- Custom Games: PrecacheUnitByNameSync and PrecacheUnitByNameAsync can optionally take a PlayerID as the last
-- argument and it will use the cosmetic items from that player when precaching. The player must be connected to the
-- game otherwise it will fall back to the default cosmetic items.
function HVHGameMode:_PostLoadPrecache()
  -- precache both heroes and cosmetics from each playerID, just in case we do team-switching logic later
  for playerID = 0, DOTA_MAX_PLAYERS-1 do
    if PlayerResource:IsValidPlayer(playerID) then
      --print("PlayerID " .. playerID .. " is a valid player.")
      PrecacheUnitByNameAsync("npc_dota_hero_sniper"       , function(...) end, playerID)
      PrecacheUnitByNameAsync("npc_dota_hero_night_stalker", function(...) end, playerID)
    end
  end
end

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

-- Increases the rate of the day/night cycle by a multiplier
-- OPTIONAL: random seconds to add or subtract to next cycle's timer
-- BUG?: half a second off every 60 mins (hypothetically)
function HVHGameMode:_SetupFastTime(next_time_transition, rng_secs)
  local standardLengthOfOneCycle = (SECS_PER_CYCLE / 2) / DAY_NIGHT_CYCLE_MULTIPLIER
  if rng_secs == nil then rng_secs = 0 end
  local thisCycleLength = standardLengthOfOneCycle + rng_secs

  Timers:CreateTimer(thisCycleLength, function()
    --print("This day/night has been " .. thisCycleLength .. " seconds long.")
    GameRules:SetTimeOfDay(next_time_transition)

    -- setup next cycle
    if next_time_transition == TIME_NEXT_EVENING then
      next_time_transition = TIME_NEXT_DAWN
    else
      next_time_transition = TIME_NEXT_EVENING
    end
    rng_secs = RandomFloat(-1 * RANDOM_EXTRA_SECONDS, RANDOM_EXTRA_SECONDS)
    self:_SetupFastTime(next_time_transition, rng_secs)
  end)
end

-- Increases the rate of the day/night cycle by a multiplier
-- BUG: about half a second off every minute (measured)
--[[
evening 1:00
evening 3:01
dawn  4:02
dawn  6:03
evening 7:03
dawn  22:11
evening 67:39
]]
function HVHGameMode:_SetupFastTime_DEPRECATED()
  Timers:CreateTimer(function()
    local timeOfDay = GameRules:GetTimeOfDay()
    print ("Time: " .. Time() .. ", DOTA time: " .. GameRules:GetDOTATime(false,false) .. ", Game time: " .. timeOfDay)
    GameRules:SetTimeOfDay(timeOfDay + EXTRA_FLOAT_TIME_PER_SECOND)
    return 1.0
  end)
end

function HVHGameMode:_SetupPassiveXP()
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

function HVHGameMode:SetupHero(hero)
  -- axe, stop nosing around in here
  if hero:GetClassname() == "npc_dota_hero_axe" then
    return
  end

  -- start at higher level
  local startingLevelsToAdd = STARTING_LEVEL - 1
  for level=1,startingLevelsToAdd do
    hero:HeroLevelUp(false)
  end

  -- starting xp for that level
  --startingXP = sum_table_through_row(XP_PER_LEVEL_TABLE, 15)
  hero:AddExperience(startingLevelsToAdd * XP_FACTOR,
    DOTA_ModifyXP_Unspecified, false, true)

  -- max out abilities
  if MAX_OUT_ABILITIES then 
    local ability = nil
    for i=0,hero:GetAbilityCount()-1 do
      ability = hero:GetAbilityByIndex(i)
      if ability and not ability:IsAttributeBonus() then 
        for level=1, ability:GetMaxLevel() do
          ability:UpgradeAbility(false) -- SetLevel() ignores OnUpgrade events
        end
      end
    end
    hero:SetAbilityPoints(0)
  end

  -- starting gear
  local heroTeam = hero:GetTeamNumber()
  if heroTeam == DOTA_TEAM_GOODGUYS then
    hero:AddItemByName("item_boots")
  else
    hero:AddItemByName("item_phase_boots")
    hero:AddItemByName("item_ultimate_scepter")
  end

  -- force the hero to sleep until the horn blows
  -- also move to random respawn point and lock camera for 3 seconds
  if PREGAME_SLEEP and GameRules:GetDOTATime(false,false) == 0 then
    local playerID = hero:GetPlayerID()
    hero:SetOrigin(HVHGameMode:ChooseFarSpawn(heroTeam))
    hero:AddNewModifier(hero, nil, "modifier_tutorial_sleep", {})
    PlayerResource:SetCameraTarget(playerID, hero)
    Timers:CreateTimer(3, function()
      PlayerResource:SetCameraTarget(playerID, nil)
    end)
  end

  --print("Succesful setup of new hero")
  hero.SuccessfulSetup = true
end

-- TODO: this shit. this shit right here.
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

-- spawn the dog at the radiant courier spawn (game start) or a random good guy spawner
function HVHGameMode:SpawnDog(random_spawn)
  local position = nil
  if random_spawn then
    position = HVHGameMode:ChooseFarSpawn(DOTA_TEAM_GOODGUYS)
  else
    local spawner = Entities:FindByClassname(nil, "info_courier_spawn_radiant")
    position = spawner:GetAbsOrigin()
  end
 
  CreateUnitByName("npc_dota_good_guy_dog", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
end

function HVHGameMode:ChooseRandomSpawn_DEPRECATED(classname)
  local possibleSpawners = Entities:FindAllByClassname(classname)
  local r = RandomInt(1, #possibleSpawners)
  spawner = possibleSpawners[r]

  return spawner
end

-- return the position of a random valid spawner
-- a valid spawner has no enemy units or heroes within MINIMUM_RESPAWN_RANGE
-- if no valid spawners are found, fallback on any possible spawner
function HVHGameMode:ChooseFarSpawn(team)
  local possibleSpawners = nil
  local oppositeTeam = nil
  if team == DOTA_TEAM_GOODGUYS then
    possibleSpawners = Entities:FindAllByClassname("info_player_start_goodguys")
    oppositeTeam = DOTA_TEAM_BADGUYS
  else
    possibleSpawners = Entities:FindAllByClassname("info_player_start_badguys")
    oppositeTeam = DOTA_TEAM_GOODGUYS
  end

  local validSpawners = {}
  for _,spawner in pairs(possibleSpawners) do
    local units = FindUnitsInRadius(oppositeTeam,
                  spawner:GetAbsOrigin(),
                  nil,
                  MINIMUM_RESPAWN_RANGE,
                  team,
                  DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                  DOTA_UNIT_TARGET_FLAG_NONE,
                  FIND_ANY_ORDER,
                  false)
    if units[1] == nil then
      table.insert(validSpawners, spawner)
      --print("No units found in radius.")
    else
      --print("Units found in radius: " .. #units)
    end
  end

  local spawnPoint = nil
  if validSpawners ~= nil then
    local r = RandomInt(1, #validSpawners)
    spawnPoint = validSpawners[r]:GetAbsOrigin()
  else -- fallback
    local r = RandomInt(1, #possibleSpawners)
    spawnPoint = possibleSpawners[r]:GetAbsOrigin()
  end

  return spawnPoint
end

function HVHGameMode:DetermineRespawn(unit)
  local team = unit:GetTeam()
  local respawnTime = HVHTimeUtils:GetRespawnTime(team)
  unit:SetTimeUntilRespawn(respawnTime)

  Timers:CreateTimer(respawnTime - 1, function() 
    local pos = HVHGameMode:ChooseFarSpawn(team)
    unit:SetRespawnPosition(pos)
  end)
end

function HVHGameMode:WakeUpHeroes()
  local heroList = HeroList:GetAllHeroes()
  for _,hero in pairs(heroList) do
    if hero:IsAlive() and hero:HasModifier("modifier_tutorial_sleep") then
      hero:RemoveModifierByName("modifier_tutorial_sleep")
    end
  end
end