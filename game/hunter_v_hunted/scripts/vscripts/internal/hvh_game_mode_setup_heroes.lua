
function HVHGameMode:AttemptToReplaceAndSetupHeroForPlayer(player)
  local team = player:GetTeam()
  local hero = player:GetAssignedHero()

  -- try again if invalid entity (hasn't loaded yet)
  if not IsValidEntity(hero) then
    print("Attempting: invalid entity")
    return false
  -- end the loop if hero already setup
  elseif hero.SuccessfulSetup then
    return true
  -- switch night stalker player to correct hero if wrong hero
  elseif self:IsSniperHeroOnWrongTeam(hero, team) then
    print("Attempting: replacing sniper with NS")
    local oldHero = hero
    hero = PlayerResource:ReplaceHeroWith(player:GetPlayerID(), "npc_dota_hero_night_stalker", 0, 0)
    UTIL_Remove(oldHero)
    return false
  -- setup hero
  else
    print("Attempting: setup hero")
    self:SetupHero(hero)
    return false
  end
end

function HVHGameMode:SetupHero(hero)
  if hero.SuccessfulSetup then return end

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
    --hero:AddItemByName("item_boots")
    hero:AddItemByName("item_sun_shard_hvh")
    hero:AddItemByName("item_tango_single")
  else
    hero:AddItemByName("item_phase_boots")
    hero:AddItemByName("item_magic_stick")
    --hero:AddItemByName("item_ultimate_scepter")
  end

  -- move hero to the pregenerated random team spawn
  local mode = GameRules:GetGameModeEntity()
  local spawnPos, enemySpawnPos = nil,nil
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

  -- lock camera for 1 second then unlock, unless non-default camera settings are enabled
  local playerID = hero:GetPlayerID()
  PlayerResource:SetCameraTarget(playerID, hero)

  if not HVHGameMode.HostOptions or HVHGameMode.HostOptions["CameraSettings"] == "default" then
    Timers:CreateTimer(1.0, function()
      PlayerResource:SetCameraTarget(playerID, nil)
    end)
  end

  -- (optional) force the hero to sleep and read tutorial text until the horn blows
  local isTutorialEnabled = nil
  if HVHGameMode.HostOptions then
    isTutorialEnabled = HVHGameMode.HostOptions["EnableTutorial"]
  else
    isTutorialEnabled = PREGAME_SLEEP
  end

  if isTutorialEnabled and GameRules:GetDOTATime(false,false) == 0 then
      hero:AddNewModifier(hero, nil, "modifier_tutorial_sleep", {}) -- disables commands
      HVHTutorial:Start(playerID)
  end

  -- stat collection
  hero.ClaimedItems = 0

  -- set up sniper unique character
  if heroTeam == DOTA_TEAM_GOODGUYS then
    hero.SniperCharacter = SNIPER_NONE
  else
    hero.SniperCharacter = SNIPER_INVALID
  end

  print("Succesful setup of new hero")
  hero.SuccessfulSetup = true
end

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

function HVHGameMode:IsSniperHeroOnWrongTeam(hero, team)
  if hero:GetUnitName() == "npc_dota_hero_sniper" and team == DOTA_TEAM_BADGUYS then
    return true
  else
    return false
  end
end