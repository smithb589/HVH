require("hvh_settings")

function HVHGameMode:_InitGameMode()
  GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
  GameRules:SetPreGameTime( PRE_GAME_TIME)
  GameRules:SetPostGameTime( POST_GAME_TIME )
  GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
  GameRules:SetUseCustomHeroXPValues( USE_CUSTOM_XP_VALUES )
  GameRules:SetGoldPerTick(GOLD_PER_TICK)
  GameRules:SetGoldTickTime(GOLD_TICK_TIME)
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
  GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
  GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
  GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
  GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )
  GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME) 

  ListenToGameEvent('player_connect_full', Dynamic_Wrap(self, 'OnPlayerConnectFull'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(self, 'OnNPCSpawned'), self)
  ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('round_start', Dynamic_Wrap(self, 'OnRoundStart'), self)

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
    mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
    mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
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

    --self:OnFirstPlayerLoaded()
  end 
end

-- Increases the rate of the day/night cycle by a multiplier
function HVHGameMode:_SetupFastTime(multiplier)
  -- GetTimeOfDay() is expressed as a float from 0.0 to 1.0, where ~0.25 is sunrise and ~0.75 is sunset
  local MINS_PER_CYCLE = 8 -- set to standard dota day/night cycle
  local SECS_PER_CYCLE = MINS_PER_CYCLE * 60
  local TIME_OF_DAY_PER_SECOND = 1 / SECS_PER_CYCLE
  local extraFloatTimePerSecond = TIME_OF_DAY_PER_SECOND * (DAY_NIGHT_CYCLE_MULTIPLIER - 1)

  Timers:CreateTimer(function()
    local timeOfDay = GameRules:GetTimeOfDay()
    --print ("Running immediately and then every second thereafter. Time of day is " .. timeOfDay )
    GameRules:SetTimeOfDay(timeOfDay + extraFloatTimePerSecond)
    return 1.0
  end)
end

function HVHGameMode:SetupHero(playerID)
  local player = PlayerResource:GetPlayer(playerID)
  if player then
    local hero = player:GetAssignedHero()
    if hero then
      
      -- start at higher level
      for level=2,STARTING_LEVEL do
        hero:HeroLevelUp(false)
      end

      -- max out abilities
      local ability = nil
      for i=0,15 do
        ability = hero:GetAbilityByIndex(i)
        if ability then 
          for level=1, ability:GetMaxLevel() do --ability:SetLevel(ability:GetMaxLevel()) IGNORES OnUpgrade
            ability:UpgradeAbility(false)
          end
        end
      end
      hero:SetAbilityPoints(0)

      -- starting gear
      local playerTeam = PlayerResource:GetTeam(playerID)
      if playerTeam == DOTA_TEAM_GOODGUYS then
        hero:AddItemByName("item_boots")
      else
        hero:AddItemByName("item_phase_boots")
        hero:AddItemByName("item_ultimate_scepter")
      end

      -- if bad guy, enlarge
      if playerTeam == DOTA_TEAM_BADGUYS then
        hero:SetModelScale(1.2)
      end

    else
      print("No hero for player with ID " .. playerID)
    end
  else
    print("Could not find player with ID " .. playerID)
  end  
end