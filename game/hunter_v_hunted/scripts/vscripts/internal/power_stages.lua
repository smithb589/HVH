if HVHPowerStages == nil then
	HVHPowerStages = class({})
end

SNIPERS_LANDSCAPE_PATH = "file://{images}/custom_game/notifications/snipers_landscape.psd"
NS_LANDSCAPE_PATH = "file://{images}/custom_game/notifications/nightstalker_landscape.psd"

NOTIFICATION_DURATION = 6.5

-- Power Stages convey benefits to your entire team based on your team's lives remaining
function HVHPowerStages:Setup()
	ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnEntityKilled"), self)
	self.gg_stage = 0
	self.bg_stage = 0

	-- English-only right now
	self.localization = LoadKeyValues("resource/addon_english.txt")["Tokens"]["HVH_PowerStages"]
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
		self:NotifyVictory( DOTA_TEAM_BADGUYS )		
		GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
	elseif mode.BadGuyLives <= 0 then
		GameRules:SetSafeToLeave( true )
		self:NotifyVictory( DOTA_TEAM_GOODGUYS )
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
				self:GrantSniperShrapnelCharge()
				self:GrantSniperEarthbind()
			elseif newPowerStage == 2 then
				self:GrantSniperShrapnelCharge()	
				self:GrantSniperTimberchain()
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

-- improves an ability by a single level for all heroes matching hero_name
-- optional: old ability "replaced_ability_name" can be removed
-- optional: "maxout" will level the ability up to the maximum level
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

--------------------------------------------------------- GRANT ABILITIES AND PRINT NOTIFICATIONS
function HVHPowerStages:GrantSniperShrapnelCharge()
	-- short delay before posting
	Timers:CreateTimer(NOTIFICATION_DURATION, function()
		self:LevelupAbilityForAll("npc_dota_hero_sniper", "sniper_shrapnel_hvh", nil, false)
		self:Notify(self.localization["Snipers_Upgrade"], self.localization["Snipers_Shrapnel"], "", DOTA_TEAM_GOODGUYS)
		return nil
	end)
end

function HVHPowerStages:GrantSniperEarthbind()
	self:LevelupAbilityForAll("npc_dota_hero_sniper", "meepo_earthbind", nil, true)
	self:Notify(self.localization["Snipers_Upgrade"], self.localization["Snipers_Earthbind"], "meepo_earthbind", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantSniperTimberchain()
	self:LevelupAbilityForAll("npc_dota_hero_sniper", "shredder_timber_chain", nil, true)
	self:Notify(self.localization["Snipers_Upgrade"], self.localization["Snipers_Timberchain"], "shredder_timber_chain", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantSniperBonusHounds()
	HVHGameMode:SpawnDog(true)
	HVHGameMode:SpawnDog(true)
	self:Notify(self.localization["Snipers_Upgrade"], self.localization["Snipers_BonusHounds"], "lycan_summon_wolves", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantNSLeap()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "night_stalker_leap_hvh", nil, true)
	self:Notify(self.localization["NS_Upgrade"], self.localization["NS_Leap"], "night_stalker_leap_hvh", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:GrantNSEcholocation()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "night_stalker_echolocation_hvh", nil, true)
	self:Notify(self.localization["NS_Upgrade"], self.localization["NS_Echolocation"], "night_stalker_echolocation_hvh", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:GrantNSCripplingFearAOE()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "night_stalker_crippling_fear_aoe_hvh", "night_stalker_crippling_fear_hvh", true)
	self:Notify(self.localization["NS_Upgrade"], self.localization["NS_CripplingHysteria"], "night_stalker_crippling_fear_aoe_hvh", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:Notify(heading, subtext, ability_name, team)
	local teamColor = self:GetTeamColor(team)
	local imagePath = self:GetImagePath(team)

	local cssTable = self:GetCSS(teamColor)
	local cssStyleHeading = cssTable["heading"]
	local cssStyleGained = cssTable["gained"]

	Notifications:TopToAll({text=heading..subtext, duration=NOTIFICATION_DURATION, style=cssStyleHeading})

	if ability_name ~= "" then
		Notifications:TopToAll({image=imagePath, duration=NOTIFICATION_DURATION})
		Notifications:TopToAll({text="&nbsp;&nbsp;&nbsp;gained&nbsp;&nbsp;&nbsp;", style=cssStyleGained, continue=true})

		-- notifications.lua doesn't seem to like custom ability images and won't compile images into vtex_c
		-- search "PrecacheHacks" under the ../content/dota_addons/hunter_v_hunted/panorama/ folder to add more 
		if ability_name == "night_stalker_echolocation_hvh" or
		   ability_name == "night_stalker_crippling_fear_aoe_hvh" or
		   ability_name == "night_stalker_leap_hvh" then
			local abilityImagePath = "file://{images}/custom_game/notifications/" .. ability_name .. ".png"
			Notifications:TopToAll({image=abilityImagePath, continue=true})
		else
			Notifications:TopToAll({ability=ability_name, continue=true})
		end

	end
end

----------------------------------------------------------- MISC. FUNCTIONS
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

function HVHPowerStages:GetImagePath(team)
	if team == DOTA_TEAM_GOODGUYS then
		return SNIPERS_LANDSCAPE_PATH
	else
		return NS_LANDSCAPE_PATH
	end
end

function HVHPowerStages:GetTeamColor(team)
	if team == DOTA_TEAM_GOODGUYS then
		return SNIPERS_COLOR_HEX
	else
		return NS_COLOR_HEX
	end
end

function HVHPowerStages:GetCSS(teamColor)
	local cssStyleHeading = {
		["color"] = teamColor,
		["font-size"] = "28px",
		["background-color"] = "#000000", -- black
		["padding"] ="5px 20px 5px 20px"
	}

	local cssStyleGained = {
		["color"] = teamColor,
		["font-size"] ="48px"
	}

	local cssTable = {}
	cssTable["heading"] = cssStyleHeading
	cssTable["gained"] = cssStyleGained
	return cssTable
end

------------------------------------------------------ BROKEN FUNCTIONS
-- BUG: panorama notifications do not seem to function post-victory, so this function won't work
function HVHPowerStages:NotifyVictory(team)
	local teamColor = self:GetTeamColor(team)
	local imagePath = self:GetImagePath(team)

	local cssTable = self:GetCSS(teamColor)
	local cssStyleHeading = cssTable["heading"]

	Notifications:BottomToAll({image=imagePath, duration=NOTIFICATION_DURATION})
	Notifications:BottomToAll({text="VICTORY", duration=NOTIFICATION_DURATION, style=cssStyleHeading, continue=true})
	Notifications:BottomToAll({image=imagePath, duration=NOTIFICATION_DURATION, continue=true})
end

-- BUG: borrowed from Noya's dotacraft; does not seem to work either
function HVHPowerStages:PrintWinMessageForTeam( teamID )
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player:GetTeamNumber() == teamID then
				local playerName = PlayerResource:GetPlayerName(playerID)
				if playerName == "" then playerName = "Player "..playerID end
				GameRules:SendCustomMessage(playerName .. " was victorious!", 0, 0)
			end
		end
	end
end