require("time_utils")

function HVHGameMode:OnPlayerConnectFull()
	self:_SetupGameMode()
end

function HVHGameMode:OnGameRulesStateChange()
  state = GameRules:State_Get()
  if state == DOTA_GAMERULES_STATE_HERO_SELECTION then
    self:_PostLoadPrecache()
  elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    self:_SetupFastTime(TIME_NEXT_EVENING, RANDOM_EXTRA_SECONDS)
    self:_SetupPassiveXP()
    self:WakeUpHeroes()
    self:SpawnDog(false)
    HVHItemSpawnController:Setup()
    HVHPowerStages:Setup()
  end
end

function HVHGameMode:OnPlayerPickHero(keys)
  local heroClass = keys.hero
  if heroClass == "npc_dota_hero_axe" then
    --print("Hero being replaced " .. heroClass)
    local heroEntity = EntIndexToHScript(keys.heroindex)

    local player = EntIndexToHScript(keys.player)
    local playerID = player:GetPlayerID()
    local playerTeam = player:GetTeamNumber()

    local newHero = nil
    if playerTeam == DOTA_TEAM_GOODGUYS then
      newHero = "npc_dota_hero_sniper"
    else
      newHero = "npc_dota_hero_night_stalker"
    end

    --print("Replacing hero for player with ID " .. playerID)
    heroEntity:SetModel("models/development/invisiblebox.vmdl")
    local newHeroEntity = PlayerResource:ReplaceHeroWith(playerID, newHero, 0, 0)

    --ReplaceHeroWith doesn't seem to give them the amount of XP indicated...
    --Timers:CreateTimer(SINGLE_FRAME_TIME,
    --  function() 
    --    self:SetupHero(playerID)
    --end
    --)

  --print("Replaced hero.")
  end
end


function HVHGameMode:OnNPCSpawned(spawnArgs)
  Timers:CreateTimer(SINGLE_FRAME_TIME, function() 

  	local unit = EntIndexToHScript(spawnArgs.entindex)
  	if unit and unit:IsRealHero() then
       if unit.SuccessfulSetup ~= true then
     
          local playerID = unit:GetPlayerOwnerID()
          self:SetupHero(unit)
      end
    --self:SetHeroDeathBounty(unit)          
    end

  end)
end

function HVHGameMode:OnEntityKilled(killedArgs)
 	local unit = EntIndexToHScript(killedArgs.entindex_killed)

  -- dog dead for a minimum of 1 cycle + randomness, then check every second
  -- to respawn when it's daytime
  if unit and unit:GetUnitName() == "npc_dota_good_guy_dog" then
    local standardLengthOfOneCycle = (SECS_PER_CYCLE / 2) / DAY_NIGHT_CYCLE_MULTIPLIER
    local maxLengthOfCycle = standardLengthOfOneCycle + RANDOM_EXTRA_SECONDS
    Timers:CreateTimer(maxLengthOfCycle, function()
      if GameRules:IsDaytime() then
        HVHGameMode:SpawnDog(true)
      else
        return 1.0
      end
    end)
    --[[-- dog respawning every morning exactly
    Timers:CreateTimer({
      endTime = HVHTimeUtils:GetSecondsUntil(TIME_NEXT_DAWN),
      callback = function()
        HVHGameMode:SpawnDog(true)
    end})
    ]]
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

  -- Won't this always use the first item in the inventory rather than the one that was actually cast?
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