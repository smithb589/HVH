--[[Author: Pizzalol
	Date: 05.01.2015.
	Leaps the target forward]]
function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local leap_distance = ability:GetLevelSpecialValueFor("leap_distance", (ability:GetLevel() - 1))
	local leap_speed = ability:GetLevelSpecialValueFor("leap_speed", (ability:GetLevel() - 1))
	local leap_height = ability:GetLevelSpecialValueFor("leap_height", (ability:GetLevel() - 1))
	local modifier_leap_immunity = keys.modifier_leap_immunity

	-- Clears any current command
	caster:Stop()

	-- Physics
	local casterPosition = caster:GetAbsOrigin()
	local end_time = leap_distance / leap_speed
	local ground_speed = leap_speed * 1.4
	local half_time = end_time/2	
	local veritcal_velocity_initial = CalculateInitialVerticalVelocity(casterPosition.z, casterPosition.z + leap_height, half_time)
	local gravity = CalculateVerticalAcceleration(veritcal_velocity_initial, half_time)
	local velocityVector = (caster:GetForwardVector() * ground_speed) + Vector(0, 0, veritcal_velocity_initial)

	Physics:Unit(caster)

	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)	
	caster:SetPhysicsVelocity(velocityVector)
	caster:SetPhysicsAcceleration(Vector(0, 0, -gravity))

	-- HVH: plays flight animation, disjoints projectiles, and applies immunity
	--StartAnimation(caster, {duration=end_time, activity=ACT_DOTA_RUN, rate=1.0, translate="haste"})
	ProjectileManager:ProjectileDodge(caster)
	ability:ApplyDataDrivenModifier(caster, caster, modifier_leap_immunity, {})

	-- Move the unit
	Timers:CreateTimer(end_time, function()
		local ground_position = GetGroundPosition(caster:GetAbsOrigin() , caster)

		caster:SetPhysicsAcceleration(Vector(0,0,0))
		caster:SetPhysicsVelocity(Vector(0,0,0))
		caster:OnPhysicsFrame(nil)
		caster:PreventDI(false)
		caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
		caster:SetAutoUnstuck(true)
		caster:FollowNavMesh(true)
		caster:SetPhysicsFriction(.05)
		
		-- HVH prevents getting stuck, removes immunity
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
		caster:RemoveModifierByName(modifier_leap_immunity)

		return nil	
	end)
end

function CalculateInitialVerticalVelocity(initialHeight, finalHeight, halfTime)
	local initialVerticalVelocity = (2 * (finalHeight - initialHeight)) / halfTime
	--print(string.format("initialVerticalVelocity: %f", initialVerticalVelocity))
	return initialVerticalVelocity
end

function CalculateVerticalAcceleration(initialVerticalSpeed, halfTime)
	local verticalAcceleration = initialVerticalSpeed / halfTime
	return verticalAcceleration
end