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
  --ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self)
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
    mode.GoodGuyTeamSpawn = nil
    mode.BadGuyTeamSpawn = nil
    mode.DeadHounds = 0
  end 
end

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
function HVHGameMode:SetupCycleTimer()
  local t = 1.0
  Timers:CreateTimer(t, function()
    CustomNetTables:SetTableValue("cycle", "IsDaytime", { value = GameRules:IsDaytime() })
    return t
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

-- at the beginning of the game, set random team spawn points
-- each info_courier_spawn_radiant entity has an attribute value "id"
-- each info_courier_spawn_dire has a matching "id" value, and it's positioned on the opposite side of map
function HVHGameMode:SetupInitialTeamSpawns()
  local ggSpawns = Entities:FindAllByClassname("info_courier_spawn_radiant")
  local bgSpawns = Entities:FindAllByClassname("info_courier_spawn_dire")

  local ggSpawn = self:GetRandomTeamSpawn()
  local bgSpawn = self:GetMatchingTeamSpawn(ggSpawn)
  
  -- save both spawn points to be accessed by SetupHero() and dog spawning
  local mode = GameRules:GetGameModeEntity()
  mode.GoodGuyTeamSpawn = ggSpawn:GetAbsOrigin()
  mode.BadGuyTeamSpawn  = bgSpawn:GetAbsOrigin()
end

-- choose a random spawn point for team good guys
function HVHGameMode:GetRandomTeamSpawn()
  local ggSpawns = Entities:FindAllByClassname("info_courier_spawn_radiant")
  local r = RandomInt(1, #ggSpawns)
  local ggSpawn = ggSpawns[r]
  return ggSpawn
end

-- find the spawn point's matching bad guy brother
function HVHGameMode:GetMatchingTeamSpawn(ggSpawn)
  local ggSpawnID = ggSpawn:Attribute_GetIntValue("id", 0)
  local bgSpawns = Entities:FindAllByClassname("info_courier_spawn_dire")
  local bgSpawnID = nil
  for _,bgSpawn in pairs(bgSpawns) do
    bgSpawnID = bgSpawn:Attribute_GetIntValue("id", 0)
    if bgSpawnID == ggSpawnID then
      return bgSpawn
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
function HVHGameMode:SetupFastTime(next_time_transition, rng_secs)
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
    self:SetupFastTime(next_time_transition, rng_secs)
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

function HVHGameMode:LevelupAbility(hero, ability_name, maxout)
  if hero:HasAbility(ability_name) then
    local ability = hero:FindAbilityByName(ability_name)
    
    if maxout then
    	for level=1, ability:GetMaxLevel() do
      		ability:UpgradeAbility(false) -- SetLevel() ignores OnUpgrade events
    	end
    else
    	ability:UpgradeAbility(false)
    end
  end
end

function HVHGameMode:SetupHero(hero)
  -- start at higher level
  local startingLevelsToAdd = STARTING_LEVEL - 1
  for level=1,startingLevelsToAdd do
    hero:HeroLevelUp(false)
  end

  -- starting xp for that level
  -- startingXP = sum_table_through_row(XP_PER_LEVEL_TABLE, 15)
  hero:AddExperience(startingLevelsToAdd * XP_FACTOR,
    DOTA_ModifyXP_Unspecified, false, true)

  -- max out all abilities
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
  -- level up specific abilities
  else
  	self:LevelupAbility(hero, "sniper_shrapnel_hvh", false)
    self:LevelupAbility(hero, "sniper_feed_dog", true)
    self:LevelupAbility(hero, "night_stalker_void", true)
    self:LevelupAbility(hero, "night_stalker_crippling_fear_hvh", false)
    self:LevelupAbility(hero, "night_stalker_hunter_in_the_night", true)
    self:LevelupAbility(hero, "night_stalker_hunter_in_the_night_hvh", true)
  end

  hero:SetAbilityPoints(0)

  -- starting gear
  local heroTeam = hero:GetTeamNumber()
  if heroTeam == DOTA_TEAM_GOODGUYS then
    hero:AddItemByName("item_boots")
    hero:AddItemByName("item_tango_single")
  else
    hero:AddItemByName("item_phase_boots")
    hero:AddItemByName("item_magic_stick")
    --hero:AddItemByName("item_ultimate_scepter")
  end

  -- force the hero to sleep until the horn blows
  -- also move hero to the pregenerated random team spawn and lock camera for 1 second
  if PREGAME_SLEEP and GameRules:GetDOTATime(false,false) == 0 then
    local playerID = hero:GetPlayerID()
    local mode = GameRules:GetGameModeEntity()

    local spawnPos = nil
    if heroTeam == DOTA_TEAM_GOODGUYS then
      spawnPos = mode.GoodGuyTeamSpawn
      enemySpawnPos = mode.BadGuyTeamSpawn
    else
      spawnPos = mode.BadGuyTeamSpawn
      enemySpawnPos = mode.GoodGuyTeamSpawn
    end

    FindClearSpaceForUnit(hero, spawnPos, true)
    local direction = (enemySpawnPos - spawnPos):Normalized()
    hero:SetForwardVector(direction) -- face the enemy spawn
    --DebugDrawLine(spawnPos, enemySpawnPos, 0, 255, 0, true, 20.0)

    hero:AddNewModifier(hero, nil, "modifier_tutorial_sleep", {}) -- disables commands
    PlayerResource:SetCameraTarget(playerID, hero)
    Timers:CreateTimer(1.0, function()
      PlayerResource:SetCameraTarget(playerID, nil)
    end)

    -- play tutorial text to the player
    HVHTutorial:Start(playerID)
  end

  -- stat collection
  hero.ClaimedItems = 0

  --print("Succesful setup of new hero")
  --hero.SuccessfulSetup = true
end

-- spawn the dog at the radiant courier spawn (game start) or a random good guy spawner
function HVHGameMode:SpawnDog(random_spawn)
  if DISABLE_DOGS then return end

  local position = nil
  if random_spawn then
    position = HVHGameMode:ChooseFarSpawn(DOTA_TEAM_GOODGUYS)
  else
    local mode = GameRules:GetGameModeEntity()
    position = mode.GoodGuyTeamSpawn
  end
 
  -- create the dog with a random dog model
  local dog = CreateUnitByName("npc_dota_good_guy_dog", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
  Timers:CreateTimer(0.06, function() 
    local r = RandomInt(1, #HOUND_MODEL_PATHS)
    dog:SetOriginalModel(HOUND_MODEL_PATHS[r])
  end)
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
  local leastWorstSpawner = nil
  local leastWorstSpawnerDistance = 0
  for n,spawner in pairs(possibleSpawners) do

    -- find enemy heroes in radius around the spawner
    local position = spawner:GetAbsOrigin()
    local units = FindUnitsInRadius(oppositeTeam,
                  position,
                  nil,
                  MINIMUM_RESPAWN_RANGE,
                  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                  DOTA_UNIT_TARGET_HERO,
                  DOTA_UNIT_TARGET_FLAG_INVULNERABLE, -- doesn't seem to work
                  FIND_CLOSEST,
                  false)

    -- TODO: if we're NS, also find dogs around the spawner and add them to previous units table
    -- table must then be sorted by closeness

    -- if no units found in radius, the spawner is Valid
    if units[1] == nil then
      table.insert(validSpawners, spawner)
      --print(n .. ": No units found in radius.")

    -- otherwise, check if this spawner is the least worst one we've come across
    else
      closestUnitDistance = (units[1]:GetAbsOrigin() - position):Length2D()
      if closestUnitDistance > leastWorstSpawnerDistance then
        leastWorstSpawnerDistance = closestUnitDistance
        leastWorstSpawner = spawner
      end
      --[[
      local nameList = ""
      for _,unit in pairs(units) do
        nameList = unit:GetName() .. ", " .. nameList
      end
      print("Spawner #" .. n .. ": " .. #units .. " units found in radius: " .. nameList)
      --]]
    end
  end

  --print("# of Valid/Possible Spawners: " .. #validSpawners .. " / " .. #possibleSpawners)
  local spawnPoint = nil
  if validSpawners[1] ~= nil then
    local r = RandomInt(1, #validSpawners)
    spawnPoint = validSpawners[r]:GetAbsOrigin()
  else -- fallback
    spawnPoint = leastWorstSpawner:GetAbsOrigin()
  end

  return spawnPoint
end

function HVHGameMode:DetermineRespawn(unit)
  local team = unit:GetTeam()
  local respawnTime = self:GetRespawnTime()
  unit:SetTimeUntilRespawn(respawnTime)

  Timers:CreateTimer(respawnTime - 1, function() 
    local pos = HVHGameMode:ChooseFarSpawn(team)
    unit:SetRespawnPosition(pos)
  end)
end

-- random time between MIN and MAX
function HVHGameMode:GetRespawnTime()
  return RandomInt(MIN_RESPAWN_TIME, MAX_RESPAWN_TIME)
end

function HVHGameMode:WakeUpHeroes()
  local heroList = HeroList:GetAllHeroes()
  for _,hero in pairs(heroList) do
    if hero:IsAlive() and hero:HasModifier("modifier_tutorial_sleep") then
      hero:RemoveModifierByName("modifier_tutorial_sleep")
    end
  end
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