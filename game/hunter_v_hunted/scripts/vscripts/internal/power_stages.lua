if HVHPowerStages == nil then
	HVHPowerStages = class({})
end

SNIPERS_COLOR = "#FCAF3D"
NS_COLOR 	  = "#99CCFF"
STR_SNIPERS_UPGRADE = "Reinforcements have arrived!"
STR_SNIPERS_TIMBERCHAIN = "TIMBER CHAINS"
STR_SNIPERS_BONUSHOUNDS = "BONUS HOUNDS"
STR_NS_UPGRADE 		 = "The Night Stalker has evolved!"
STR_NS_ECHOLOCATION  = "ECHOLOCATION"
STR_NS_SHADOWSTALKER = "SHADOWSTALKER"

function HVHPowerStages:Setup()
	ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnEntityKilled"), self)
	self.gg_stage = 0
	self.bg_stage = 0
end

function HVHPowerStages:OnEntityKilled(killedArgs)
	local unit = EntIndexToHScript(killedArgs.entindex_killed)

	if unit and unit:IsRealHero() then
		local team = unit:GetTeam()
		self:HandlePlayerDeath(unit)
		self:CheckForWinner()
		self:CheckPowerStages(team)
	end
end

function HVHPowerStages:HandlePlayerDeath(unit)
	local team = unit:GetTeam()
	local mode = GameRules:GetGameModeEntity()

	-- decrement remaining lives and set respawn timers
	if team == DOTA_TEAM_GOODGUYS then
		mode.GoodGuyLives = mode.GoodGuyLives - 1
		mode:SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, mode.GoodGuyLives)
		HVHGameMode:DetermineRespawn(unit)
	elseif team == DOTA_TEAM_BADGUYS then
		mode.BadGuyLives = mode.BadGuyLives - 1
		mode:SetTopBarTeamValue(DOTA_TEAM_BADGUYS, mode.BadGuyLives)
		HVHGameMode:DetermineRespawn(unit)
	end
end

function HVHPowerStages:CheckForWinner()
	local mode = GameRules:GetGameModeEntity()
	if mode.GoodGuyLives <= 0 then
		GameRules:SetSafeToLeave( true )
		GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
	elseif mode.BadGuyLives <= 0 then
		GameRules:SetSafeToLeave( true )
		GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
	end
end

function HVHPowerStages:CheckPowerStages(team)
	local keys = self:GetTeamVariables(team)
	local thresholds   = keys["thresholds"]
	local currentStage = keys["currentStage"]
	local currentLives = keys["currentLives"]

	--print(string.format("Team %s -- Stage %s, Lives Remaining: %s", team, currentStage, currentLives))

	if currentLives == thresholds[currentStage+1] then
		self:UpgradePowerStage(team)
	end
end

function HVHPowerStages:UpgradePowerStage(team)
	local newPowerStage = self:IncrementPowerStageNumber(team)

	-- delay the notification by a few seconds
	Timers:CreateTimer(HVHGameMode:GetRespawnTime(), function()
		if team == DOTA_TEAM_GOODGUYS then
			if     newPowerStage == 1 then self:GrantSniperTimberchain()
			elseif newPowerStage == 2 then self:GrantSniperBonusHounds()
			elseif newPowerStage == 3 then --print("sniper stage 3")
			else --print("sniper unknown stage")
			end
		else
			if     newPowerStage == 1 then self:GrantNSEcholocation()
			elseif newPowerStage == 2 then self:GrantNSShadowstalker()
			elseif newPowerStage == 3 then --print("NS stage 3")
			else --print("NS unknown stage")
			end
		end
    	return nil
    end)
end

function HVHPowerStages:MaxOutAbility(hero_name, ability_name)
    local heroList = HeroList:GetAllHeroes()
    for _,hero in pairs(heroList) do
    	if hero:GetClassname() == hero_name then
	        local ability = hero:FindAbilityByName(ability_name)
	        ability:SetLevel(ability:GetMaxLevel())
    	end
    end
end

function HVHPowerStages:GrantSniperTimberchain()
	self:MaxOutAbility("npc_dota_hero_sniper", "shredder_timber_chain")
	self:Notify(STR_SNIPERS_UPGRADE, STR_SNIPERS_TIMBERCHAIN, SNIPERS_COLOR)
end

function HVHPowerStages:GrantSniperBonusHounds()
	HVHGameMode:SpawnDog(true)
	HVHGameMode:SpawnDog(true)
	self:Notify(STR_SNIPERS_UPGRADE, STR_SNIPERS_BONUSHOUNDS, SNIPERS_COLOR)
end

function HVHPowerStages:GrantNSEcholocation()
	self:MaxOutAbility("npc_dota_hero_night_stalker", "night_stalker_echolocation_hvh")
	self:Notify(STR_NS_UPGRADE, STR_NS_ECHOLOCATION, NS_COLOR)
end

function HVHPowerStages:GrantNSShadowstalker()
	--self:MaxOutAbility("npc_dota_hero_night_stalker", "night_stalker_shadowstalker_hvh")
	self:Notify(STR_NS_UPGRADE, STR_NS_SHADOWSTALKER, NS_COLOR)
end

function HVHPowerStages:Notify(heading, subtext, teamcolor)
	Notifications:BottomToAll({text=heading, duration=5.0, style={["font-size"]="36px"}})
	Notifications:BottomToAll({text=subtext, duration=5.0, style={color=teamcolor, ["font-size"]="60px"}})
end

function HVHPowerStages:IncrementPowerStageNumber(team)
	local newStage = nil

	if team == DOTA_TEAM_GOODGUYS then
		self.gg_stage = self.gg_stage + 1
		newStage = self.gg_stage
	else
		self.bg_stage = self.bg_stage + 1
		newStage = self.bg_stage
	end

	return newStage
end

function HVHPowerStages:GetTeamVariables(team)
	local keys = {}
	local mode = GameRules:GetGameModeEntity()

	if team == DOTA_TEAM_GOODGUYS then
		keys["thresholds"]	 = GG_POWER_STAGE_THRESHOLDS
		keys["currentStage"] = self.gg_stage
		keys["currentLives"] = mode.GoodGuyLives
	else
		keys["thresholds"]	 = BG_POWER_STAGE_THRESHOLDS
		keys["currentStage"] = self.bg_stage
		keys["currentLives"] = mode.BadGuyLives
	end

	return keys
end