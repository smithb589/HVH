function HVHGameMode:OnPlayerConnectFull()
	self:_SetupGameMode()
end

function HVHGameMode:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:_SetupFastTime()
	end
end

function HVHGameMode:OnRoundStart(gameInfo)
	print("Creating courier.")
	--local spawner = Entities:GetEntityByName("RadiantCourierSpawner")
	--CreateUnitByName("npc_dota_courier", spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)	
end

function HVHGameMode:OnNPCSpawned(spawnArgs)
	local unit = EntIndexToHScript(spawnArgs.entindex)
	if unit and unit:IsHero() then
		local playerID = unit:GetPlayerOwnerID()
		self:SetHeroDeathBounty(unit)
	end
end

function HVHGameMode:OnEntityKilled(killedArgs)
 	local unit = EntIndexToHScript(killedArgs.entindex_killed)
 	--print("Unit Killed.")
 	if unit and unit:IsHero() then
 		--print("XP bounty on killed unit: " .. unit:GetCustomDeathXP())
 	end
end

function HVHGameMode:OnPlayerPickHero(keys)
  local heroClass = keys.hero
  if heroClass == "npc_dota_hero_axe" then
    print("Hero being replaced " .. heroClass)
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

    print("Replacing hero for player with ID " .. playerID)
    heroEntity:SetModel("models/development/invisiblebox.vmdl")
	local newHeroEntity = PlayerResource:ReplaceHeroWith(playerID, newHero, 0, 0)

    --ReplaceHeroWith doesn't seem to give them the amount of XP indicated...
    Timers:CreateTimer(0.03,
    	function() 
    		self:SetupHero(playerID)
		end
	)

    print("Replaced hero.")
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

  -- Check all 6 item slots for items with charges that match abilityName, then expend the charge
  for i=0, 5 do
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