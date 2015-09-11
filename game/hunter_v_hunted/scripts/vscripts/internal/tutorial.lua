if HVHTutorial == nil then
	HVHTutorial = class({})
end

STR_TUTORIAL_GG = {
	"You are a SNIPER.",
	"During the day, you must HUNT the Night Stalker.",
	"During the night, you must RUN from the Night Stalker and collect ITEMS!",
	"FOLLOW THE HOUND!",
	"The hound's aura will protect and heal you, but only during the day.",
	"Now... HUNT!"
}

STR_TUTORIAL_BG = {
	"You are the NIGHT STALKER.",
	"During the day, you must RUN from the Snipers and collect ITEMS!",
	"During the night, you must HUNT the Snipers.",
	"BEWARE THE HOUND!",
	"Becoming invisible will regenerate you, but the Hound can still find you.",
	"Now... RUN!"
}

function HVHTutorial:Start(playerID)
	local tutorialStrings = {}
	local colorHex = ""
	if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
		tutorialStrings = STR_TUTORIAL_GG
		colorHex = SNIPERS_COLOR_HEX
	else
		tutorialStrings = STR_TUTORIAL_BG
		colorHex = NS_COLOR_HEX
	end

	TUTORIAL_DELAY = 4.8
	local i = 1 -- Lua arrays start at 1
	Timers:CreateTimer(TUTORIAL_DELAY, function()
		Notifications:Top(playerID, {text=tutorialStrings[i], duration=TUTORIAL_DELAY, style={color=colorHex}})
		i = i + 1
		if tutorialStrings[i] ~= nil then
			return TUTORIAL_DELAY
		else
			return nil
		end
	end)
end