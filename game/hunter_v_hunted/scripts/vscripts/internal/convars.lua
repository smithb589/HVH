
--[[]
function HVHConvars:ConvarSetTimeOfDay(time)
	local timeAsFloat = tonumber(time)
	if timeAsFloat >= 0 and timeAsFloat <= 1 then
		GameRules:SetTimeOfDay(timeAsFloat)
	else
		print("Time must be a value between 0 and 1.")
	end
end
]]--

require("item_utils")

function HVHConvars:CreateRune()
	local debugRunSpawner = Entities:FindByName(nil, "hvh_debug_rune_spawner")
	if debugRunSpawner then
		HVHItemUtils:SpawnItem("item_hvh_rune", debugRunSpawner:GetAbsOrigin())
	else
		print("No debug rune spawner.")
	end
end