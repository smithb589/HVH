if HVHTutorial == nil then
	HVHTutorial = class({})
end

STR_TUTORIAL_GG = {
	"You are a SNIPER.",
	"During the day, you must HUNT the Night Stalker.",
	"During the night, you must RUN from the Night Stalker and collect ITEMS!",
	"FOLLOW THE HOUND!",
	"The hound's aura will protect and heal you... but only during the day.",
	"Now... HUNT!"
}

STR_TUTORIAL_BG = {
	"You are the NIGHT STALKER.",
	"During the day, you must RUN from the Snipers and collect ITEMS!",
	"During the night, you must HUNT the Snipers.",
	"BEWARE THE HOUND!",
	"Becoming invisible will regenerate your health... but the Hound can still smell you.",
	"Now... RUN!"
}

function HVHTutorial:Start(playerID)
	local tutorialStrings = {}
	local colorHex = SNIPERS_COLOR_HEX
	if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
		tutorialStrings = STR_TUTORIAL_GG
	else
		tutorialStrings = STR_TUTORIAL_BG
	end

	local i = 1 -- Lua arrays start at 1
	Timers:CreateTimer(5.0, function()
		Notifications:Top(playerID, {text=tutorialStrings[i], duration=5.0, style={color=colorHex}})
		i = i + 1
		if tutorialStrings[i] ~= nil then
			return 5.0
		else
			return nil
		end
	end)
end