
require("../hvh_utils")

function Spawn( entityKeyValues )

	thisEntity:SetContextThink("ThinkDog", ThinkDog, 1)
	HVHDebugPrint("Starting AI for "..thisEntity:GetUnitName().." "..thisEntity:GetEntityIndex())

end

function ThinkDog()
	--print("Thinking...")
	if GameRules:IsDaytime() then

		if IsFed() then

			local target = AcquireTarget()
			if target then
				Pursue(target)
			else -- target dead or missing
				HVHDebugPrint("Target not found.")
				Wander()
			end

		else -- is not fed
			Wander()
		end

	else -- is night
		Sleep()
	end

	return 1
end

-- TODO: tie in with sniper ability
function IsFed()
	return 1
end

-- returns the closest badguy hero
function AcquireTarget()
	HVHDebugPrint("Acquiring target...")
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
		 	thisEntity:GetAbsOrigin(),
			nil,
			FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			false)
	if units[1] ~= nil then
		return units[1]
	else
		return false
	end
end

function Pursue(target)
	HVHDebugPrint("Pursuing " .. target:GetUnitName() .. "!")
	thisEntity:MoveToNPC(target)
end

-- TODO
function Disable(target)
end

-- TODO: actual wandering
function Wander()
	if not thisEntity:IsIdle() then
		thisEntity:Stop()
	end
	HVHDebugPrint("Wandering...")
end

function Sleep()
	if not thisEntity:IsIdle() then
		thisEntity:Stop()
	end
	HVHDebugPrint("Sleeping...")
end