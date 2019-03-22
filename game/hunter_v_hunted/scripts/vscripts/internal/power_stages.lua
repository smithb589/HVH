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
end

function HVHPowerStages:OnEntityKilled(killedArgs)
	local unit = EntIndexToHScript(killedArgs.entindex_killed)
	local killer = EntIndexToHScript(killedArgs.entindex_attacker)

	if unit and unit:IsRealHero() and not unit:IsReincarnating() then
		local team = unit:GetTeam()
		self:HandlePlayerDeath(unit)
		self:CheckForWinner()
		self:CheckPowerStages(team)
		HVHSniperSelect:Check(killer, unit)
	end
end

function HVHPowerStages:HandlePlayerDeath(unit)
	local decrementLivesBy = 1
	local team = unit:GetTeam()
	local mode = GameRules:GetGameModeEntity()
	local player = unit:GetPlayerOwner()

	-- don't count the deaths of disconnected players
	if player and PlayerResource:GetConnectionState(player:GetPlayerID()) == CONNECTION_STATE_DISCONNECTED then
		HVHErrorUtils:SendNoteToScreenBottomAll("#DisconnectedPlayerKill")
		decrementLivesBy = 0
	end

	-- decrement remaining lives and set respawn timers
	if team == DOTA_TEAM_GOODGUYS then
		mode.GoodGuyLives = mode.GoodGuyLives - decrementLivesBy
		mode:SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, mode.GoodGuyLives)
    	HVHGameMode:PushScoreToCustomNetTable()
    	HVHGameMode:DetermineRespawn(unit)
    	self:NotifyLivesRemaining(DOTA_TEAM_GOODGUYS)
	elseif team == DOTA_TEAM_BADGUYS then
		mode.BadGuyLives = mode.BadGuyLives - decrementLivesBy
		mode:SetTopBarTeamValue(DOTA_TEAM_BADGUYS, mode.BadGuyLives)
		HVHGameMode:PushScoreToCustomNetTable()
		HVHGameMode:DetermineRespawn(unit)
    	self:NotifyLivesRemaining(DOTA_TEAM_BADGUYS)
	end
end

function HVHPowerStages:CheckForWinner()
	local mode = GameRules:GetGameModeEntity()
	if mode.GoodGuyLives <= 0 then
		HVHGameMode:DeclareWinner(DOTA_TEAM_BADGUYS)
	elseif mode.BadGuyLives <= 0 then
		HVHGameMode:DeclareWinner(DOTA_TEAM_GOODGUYS)
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

	if MAX_OUT_ABILITIES then return end -- ignore power stages when cheating

	-- delay the notification by a few arbitrary seconds
	local delay = HVHGameMode:GetRespawnTime() * 0.4
	Timers:CreateTimer(delay, function()
		if team == DOTA_TEAM_GOODGUYS then
			if     newPowerStage == 1 then self:GrantSniperShrapnelCharge()
			elseif newPowerStage == 2 then self:GrantSniperEarthbind()
			elseif newPowerStage == 3 then self:GrantSniperBonusHounds(1)				
			elseif newPowerStage == 4 then self:GrantSniperTimberchain()
			elseif newPowerStage == 5 then self:GrantSniperShrapnelCharge()	
			elseif newPowerStage == 6 then self:GrantSniperBonusHounds(1)
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
	self:LevelupAbilityForAll("npc_dota_hero_sniper", "sniper_shrapnel_hvh", nil, false)
	self:Notify("#PowerStages_Snipers_Upgrade_Supplies", "#PowerStages_Snipers_Shrapnel", "", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantSniperEarthbind()
	self:LevelupAbilityForAll("npc_dota_hero_sniper", "meepo_earthbind", nil, true)
	self:Notify("#PowerStages_Snipers_Upgrade_Supplies", "#PowerStages_Snipers_Earthbind", "meepo_earthbind", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantSniperTimberchain()
	self:LevelupAbilityForAll("npc_dota_hero_sniper", "shredder_timber_chain", nil, true)
	self:Notify("#PowerStages_Snipers_Upgrade_Supplies", "#PowerStages_Snipers_Timberchain", "shredder_timber_chain", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantSniperBonusHounds(houndCount)
	for i=1, houndCount do
		HVHGameMode:SpawnDog(true)
	end

	self:Notify("#PowerStages_Snipers_Upgrade_Reinforcements", "#PowerStages_Snipers_BonusHounds", "lycan_summon_wolves", DOTA_TEAM_GOODGUYS)
end

function HVHPowerStages:GrantNSLeap()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "night_stalker_leap_hvh", nil, true)
	self:Notify("#PowerStages_NS_Upgrade", "#PowerStages_NS_Leap", "night_stalker_leap_hvh", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:GrantNSEcholocation()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "night_stalker_echolocation_hvh", nil, true)
	self:Notify("#PowerStages_NS_Upgrade", "#PowerStages_NS_Echolocation", "night_stalker_echolocation_hvh", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:GrantNSCripplingFearAOE()
	self:LevelupAbilityForAll("npc_dota_hero_night_stalker", "night_stalker_crippling_fear_aoe_hvh", "night_stalker_crippling_fear_hvh", true)
	self:Notify("#PowerStages_NS_Upgrade", "#PowerStages_NS_CripplingHysteria", "night_stalker_crippling_fear_aoe_hvh", DOTA_TEAM_BADGUYS)
end

function HVHPowerStages:Notify(heading, subtext, ability_name, team)
	local teamColor = self:GetTeamColor(team)
	local imagePath = self:GetImagePath(team)

	local cssTable = self:GetCSS(teamColor)
	local cssStyleHeading = cssTable["heading"]
	local cssStyleGained = cssTable["gained"]

	Notifications:TopToAll({text=heading, duration=NOTIFICATION_DURATION, style=cssStyleHeading})
	Notifications:TopToAll({text=subtext, duration=NOTIFICATION_DURATION, style=cssStyleHeading, continue=true})

	if ability_name ~= "" then
		Notifications:TopToAll({image=imagePath, duration=NOTIFICATION_DURATION})
		Notifications:TopToAll({text="#PowerStages_Gained", style=cssStyleGained, continue=true})

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

function HVHPowerStages:NotifyLivesRemaining(team)
	local keys = self:GetTeamVariables(team)
	local thresholds   = keys["thresholds"]
	local currentLives = keys["currentLives"]

	local teamColor = self:GetTeamColor(team)
	local cssTable = self:GetCSS(teamColor)
	local cssStyle = cssTable["livesRemaining"]

	if team == DOTA_TEAM_GOODGUYS then
		teamString = "#PowerStages_Snipers_LivesRemaining"
	else
		teamString = "#PowerStages_NS_LivesRemaining"
	end

	Notifications:BottomToAll({text=teamString, duration=NOTIFICATION_DURATION, style=cssStyle})
	Notifications:BottomToAll({text=currentLives, duration=NOTIFICATION_DURATION, style=cssStyle, continue=true})
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
		keys["teamName"]	 = "#DOTA_GoodGuys"
		keys["thresholds"]	 = GG_POWER_STAGE_THRESHOLDS
		keys["currentStage"] = self.gg_stage
		keys["currentLives"] = mode.GoodGuyLives
	else
		keys["teamName"]	 = "#DOTA_BadGuys"
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
		["padding"] ="5px 20px 5px 20px",
		["border-radius"] = "10px"
	}

	local cssStyleGained = {
		["color"] = teamColor,
		["font-size"] ="48px",
		["text-shadow"] = "8px 8px 16px 6.0 black"
	}

	local cssStyleLivesRemaining = {
		["color"] = teamColor,
		["font-size"] = "24px",
		["text-shadow"] = "4px 4px 8px 6.0 black"
	}

	local cssTable = {}
	cssTable["heading"] = cssStyleHeading
	cssTable["gained"] = cssStyleGained
	cssTable["livesRemaining"] = cssStyleLivesRemaining
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