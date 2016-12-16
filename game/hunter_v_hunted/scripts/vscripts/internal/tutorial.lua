if HVHTutorial == nil then
	HVHTutorial = class({})
end

TUTORIAL_DELAY = 4.8
TUTORIAL_MSGS = 6

-- Print messages to the player at the start of the match
function HVHTutorial:Start(playerID)
	local tutorialString = ""
	local colorHex = ""
	if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
		tutorialString = "#Tutorial_GG_MSG_"
		colorHex = SNIPERS_COLOR_HEX
	else
		tutorialString = "#Tutorial_BG_MSG_"
		colorHex = NS_COLOR_HEX
	end

	local i = 1 -- Lua arrays start at 1
	Timers:CreateTimer(TUTORIAL_DELAY, function()
		Notifications:Top(playerID, {text=tutorialString..i, duration=TUTORIAL_DELAY, style={color=colorHex}})
		i = i + 1
		if i <= TUTORIAL_MSGS then
			return TUTORIAL_DELAY
		else
			return nil
		end
	end)
end

function HVHTutorial:WakeUpHeroes()
  local heroList = HeroList:GetAllHeroes()
  for _,hero in pairs(heroList) do
    if hero:IsAlive() and hero:HasModifier("modifier_tutorial_sleep") then
      hero:RemoveModifierByName("modifier_tutorial_sleep")
    end
  end
end