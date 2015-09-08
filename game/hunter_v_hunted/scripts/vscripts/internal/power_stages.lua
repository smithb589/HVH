if HVHPowerStages == nil then
	HVHPowerStages = class({})
end

SNIPERS_LANDSCAPE_PATH = "file://{images}/custom_game/notifications/snipers_landscape.psd"
NS_LANDSCAPE_PATH = "file://{images}/custom_game/notifications/nightstalker_landscape.psd"

NOTIFICATION_DURATION = 6.5

STR_SNIPERS_UPGRADE = "Reinforcements have arrived!"
STR_SNIPERS_EARTHBIND   = "MEEPO'S NETS"
STR_SNIPERS_TIMBERCHAIN = "TIMBER CHAINS"
STR_SNIPERS_BONUSHOUNDS = "THE PACK GROWS"
STR_NS_UPGRADE 		 = "The Night Stalker has evolved!"
STR_NS_LEAP          = "DREAD LEAP"
STR_NS_ECHOLOCATION  = "ECHOLOCATION"
STR_NS_CRIPPLE_AOE   = "CRIPPLING HYSTERIA (AOE)"

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
			if     newPowerStage == 1 then
				self:GrantSniperEarthbind()
				self:GrantSniperShrapnelCharge()
			elseif newPowerStage == 2 then
				self:GrantSniperTimberchain()
				self:GrantSniperShrapnelCharge()	
			elseif newPowerStage == 3 then self:GrantSniperBonusHounds()
			else --print("sniper unknown stage")
			end
		else
			if     newPowerStage == 1 then self:GrantNSLeap()
			elseif newPowerStage == 2 then self:GrantNSEcholocation()
			elseif newPowerStage == 3 then self:GrantNSCripplingFearAOE()
			else --print("NS unknown stage")
			end
		end
    	return nil
    end)
end

-- improves an ability to by a single level for all heroes matching hero_name
-- removes old version of ability if replaced_ability_name is used
function HVHPowerStages:LevelupAbilityForAll(hero_name, ability_name, replaced_ability_name, maxout)
    local heroList = HeroList:GetAllHeroes()
    for _,hero in pairs(heroList) do
    	if hero:GetClassname() == hero_name then
    		
    		if replaced_ability_name ~= nil then
    			hero:RemoveAbility(replaced_ability_name)
	        	hero:AddAbility(ability_name)
	        end

	        HVHGameMode:LevelupAbility(hero, ability_name, maxout)
    	end
    end
end

function HVHPowerStages:GrantSniperShrapnelCharge()
	self:LevelupAbilityForAll("npc_dota_hero_sniper", "sniper_shrapnel_hvh", nil, false)
	Notifications:BottomToAll({text="(ALSO +1 MAX SHRAPNEL CHARGES)", duration=NOTIFICATION_DURATION,
		continue=false, style={color=SNIPERS_COLOR_HEX, ["font-size"]="28px"}})
end

function HVHPowerStages:GrantSniperEarthbind()
	self:LevelupAbilityForAll("npc_dota_hero_sniper", "meepo_earthbind", nil, true)
	self:Notify(STR_SNIPERS_UPGRADE, STR_SNIPERS_EARTHBIND, "meepo_earthbind", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantSniperTimberchain()
	self:LevelupAbilityForAll("npc_dota_hero_sniper", "shredder_timber_chain", nil, true)
	self:Notify(STR_SNIPERS_UPGRADE, STR_SNIPERS_TIMBERCHAIN, "shredder_timber_chain", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantSniperBonusHounds()
	HVHGameMode:SpawnDog(true)
	HVHGameMode:SpawnDog(true)
	self:Notify(STR_SNIPERS_UPGRADE, STR_SNIPERS_BONUSHOUNDS, "lycan_summon_wolves", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantNSLeap()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "mirana_leap", nil, true)
	self:Notify(STR_NS_UPGRADE, STR_NS_LEAP, "mirana_leap", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:GrantNSEcholocation()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "night_stalker_echolocation_hvh", nil, true)
	self:Notify(STR_NS_UPGRADE, STR_NS_ECHOLOCATION, "night_stalker_echolocation_hvh", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:GrantNSCripplingFearAOE()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "night_stalker_crippling_fear_aoe_hvh", "night_stalker_crippling_fear_hvh", true)
	self:Notify(STR_NS_UPGRADE, STR_NS_CRIPPLE_AOE, "night_stalker_crippling_fear_aoe_hvh", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:Notify(heading, subtext, ability_name, team)
	local teamColor = nil
	local imagePath = nil
	if team == DOTA_TEAM_GOODGUYS then
		teamColor = SNIPERS_COLOR_HEX
		imagePath = SNIPERS_LANDSCAPE_PATH
	else
		teamColor = NS_COLOR_HEX
		imagePath = NS_LANDSCAPE_PATH
	end

	Notifications:TopToAll({text=heading, duration=NOTIFICATION_DURATION, style={color=teamColor, ["font-size"]="28px"}})
	Notifications:TopToAll({text=subtext, duration=NOTIFICATION_DURATION, style={color=teamColor, ["font-size"]="48px"}})
	Notifications:BottomToAll({image=imagePath, duration=NOTIFICATION_DURATION})
	Notifications:BottomToAll({text="&nbsp;&nbsp;&nbsp;gained&nbsp;&nbsp;&nbsp;", continue=true, style={color=teamColor, ["font-size"]="48px"}})

	-- notifications.lua doesn't seem to like custom ability images and won't compile images into vtex_c
	-- search "PrecacheHacks" under the ../content/dota_addons/hunter_v_hunted/panorama/ folder to add more 
	if ability_name == "night_stalker_echolocation_hvh" or
	   ability_name == "night_stalker_crippling_fear_aoe_hvh" or
	   ability_name == "mirana_leap" then
		local abilityImagePath = "file://{images}/custom_game/notifications/" .. ability_name .. ".png"
		Notifications:BottomToAll({image=abilityImagePath, continue=true})
	else
		Notifications:BottomToAll({ability=ability_name, continue=true})
	end
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