if HVHTutorial == nil then
	HVHTutorial = class({})
end

TUTORIAL_DELAY = 4.8

-- Print messages to the player at the start of the match
function HVHTutorial:Start(playerID)
	local tutorialStrings = {}
	local colorHex = ""
	if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
		tutorialStrings = LoadKeyValues("resource/addon_english.txt")["Tokens"]["HVH_Tutorial_Snipers"]
		colorHex = SNIPERS_COLOR_HEX
	else
		tutorialStrings = LoadKeyValues("resource/addon_english.txt")["Tokens"]["HVH_Tutorial_NS"]
		colorHex = NS_COLOR_HEX
	end

	local i = 1 -- Lua arrays start at 1
	Timers:CreateTimer(TUTORIAL_DELAY, function()
		Notifications:Top(playerID, {text=tutorialStrings["MSG_"..i], duration=TUTORIAL_DELAY, style={color=colorHex}})
		i = i + 1
		if tutorialStrings["MSG_"..i] ~= nil then
			return TUTORIAL_DELAY
		else
			return nil
		end
	end)
end