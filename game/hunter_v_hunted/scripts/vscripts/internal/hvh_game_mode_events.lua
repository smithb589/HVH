function HVHGameMode:OnPlayerConnectFull()
	self:SetupGameMode()
end

function HVHGameMode:OnGameRulesStateChange()
  state = GameRules:State_Get()
  if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
    HVHCycles:SetupCycleTimer()
  elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
    self:PostLoadPrecache()
    self:RegisterHostOptions()
    self:SetupInitialTeamSpawns()
    self:PushScoreToCustomNetTable()
    self:GlimpseFix()
  elseif state == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
    --
  elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
    --
  elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    self:DisplayHostOptions()
    self:SpawnStartingDogs()
    HVHTutorial:WakeUpHeroes()
    HVHCycles:SetupFastTime()
    HVHItemSpawnController:Setup()
    HVHPowerStages:Setup()
    HVHNeutralCreeps:Setup()
    HVHSniperSelect:Setup()
    HVHPhoenix:Setup()
  end
end

-- triggers after hero is force picked, or fake heroes are made
-- will keep repeating until successful
function HVHGameMode:OnPlayerPickHero(keys)
  local player = EntIndexToHScript(keys.player)
  local playerID = player:GetPlayerID()
  --local heroUnitName = keys.hero
  --local heroIndex = keys.heroindex

  Timers:CreateTimer(function()
    local successfulHeroSetup = self:AttemptToReplaceAndSetupHeroForPlayer(player)
    if successfulHeroSetup then
      return false -- end loop
    else
      return 0.1 -- try again in 0.1 sec
    end
  end)
end


function HVHGameMode:OnEntityKilled(killedArgs)
 	local unit = EntIndexToHScript(killedArgs.entindex_killed)
  local killer = EntIndexToHScript(killedArgs.entindex_attacker)

  if unit and unit:GetUnitName() == "npc_dota_good_guy_dog" then
    local mode = GameRules:GetGameModeEntity()
    mode.DeadHounds = mode.DeadHounds + 1 -- stat collection
    Timers:CreateTimer(HVHGameMode:GetRespawnTime(), function()
      HVHGameMode:SpawnDog(true)
    end)
  end
end

-- Overridden Valve items will not consume charges or get destroyed, even with ItemPermanent "0". This fixes that problem.
-- BUG: This will BREAK existing charged items
function HVHGameMode:OnAbilityUsed(keys)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
  local hero = player:GetAssignedHero() -- BUG: won't work for using charged items on secondary heroes/creeps

  -- don't waste our time on non-item abilities
  if not hero:HasItemInInventory(abilityName) then
      --print(abilityName .. " not found in " .. hero:GetName() .. "'s inventory.")
      return
  end

  -- BUG: Won't this always use the first item in the inventory rather than the one that was actually cast?
  -- Check all 6 item slots for items with charges that match abilityName, then expend the charge
  for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
    local item = hero:GetItemInSlot(i)
    if item ~= nil and HVHItemUtils:IsChargedItem(item) then
      local itemName = item:GetName()
      if itemName == abilityName then
        HVHItemUtils:ExpendCharge(item)
        break
      end
    end
  end
end