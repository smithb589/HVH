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
    mode.GoodGuyLives = GOODGUY_LIVES
    mode.BadGuyLives  = BADGUY_LIVES
    mode:SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, GOODGUY_LIVES)
    mode:SetTopBarTeamValue(DOTA_TEAM_BADGUYS, BADGUY_LIVES)

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
function HVHGameMode:_SetupFastTime(multiplier)
  Timers:CreateTimer(function()
    local timeOfDay = GameRules:GetTimeOfDay()
    --print ("Running immediately and then every second thereafter. Time of day is " .. timeOfDay )
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
  for level=1,STARTING_LEVELS_TO_ADD do
    hero:HeroLevelUp(false)
  end

  -- starting xp for that level
  --startingXP = sum_table_through_row(XP_PER_LEVEL_TABLE, 15)
  hero:AddExperience(STARTING_LEVELS_TO_ADD * XP_FACTOR,
    DOTA_ModifyXP_Unspecified, false, true)

  -- max out abilities
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

  -- starting gear
  local heroTeam = hero:GetTeamNumber()
  if heroTeam == DOTA_TEAM_GOODGUYS then
    hero:AddItemByName("item_boots")
  else
    hero:AddItemByName("item_phase_boots")
    hero:AddItemByName("item_ultimate_scepter")
  end

  --print("Succesful setup of new hero")
  hero.SuccessfulSetup = true
end

-- TODO: this shit. this shit right here.
function HVHGameMode:SetHeroDeathBounty(hero)
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

function HVHGameMode:SpawnDog(random_spawn)
  local spawner = nil
  if random_spawn then
    spawner = HVHGameMode:ChooseRandomSpawn("info_player_start_goodguys")
  else
    spawner = Entities:FindByClassname(nil, "info_courier_spawn_radiant")
  end
 
  local position = spawner:GetAbsOrigin()
  CreateUnitByName("npc_dota_good_guy_dog", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
end

function HVHGameMode:ChooseRandomSpawn(classname)
    local possibleSpawners = Entities:FindAllByClassname(classname)
    local r = RandomInt(1, #possibleSpawners)
    spawner = possibleSpawners[r]

    return spawner
end