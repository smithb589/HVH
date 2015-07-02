function HVHGameMode:OnConnectFull()
	self:_SetupGameMode()
end

function HVHGameMode:OnPlayerSpawn(playerSpawnArgs)
	local unit = EntIndexToHScript(playerSpawnArgs.entindex)
	if unit and unit:IsHero() then
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
    local playerTeam = player(GetTeamNumber())

    local newHero = nil
    if playerTeam == DOTA_TEAM_GOODGUYS then
      newHero = "npc_dota_hero_sniper"
    else
      newHero = "npc_dota_hero_night_stalker"
    end

    print("Replacing hero for player with ID " .. playerID)
    heroEntity:SetModel("models/development/invisiblebox.vmdl")
    local newHeroEntity = PlayerResource:ReplaceHeroWith(playerID, newHero, 0, 0)
    if playerTeam == DOTA_TEAM_BADGUYS then
      newHeroEntity:SetModelScale(1.3)

    --ReplaceHeroWith doesn't seem to give them the amount of XP indicated...
    Timers:CreateTimer(0.03,
    	function() 
    		self:_LevelUpReplacedHero(playerID)
		end
	)

    print("Replaced hero.")
  end
end