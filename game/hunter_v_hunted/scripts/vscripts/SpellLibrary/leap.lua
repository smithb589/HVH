--[[Author: Pizzalol
	Date: 05.01.2015.
	Leaps the target forward]]
function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local leap_distance = ability:GetLevelSpecialValueFor("leap_distance", (ability:GetLevel() - 1))
	local leap_speed = ability:GetLevelSpecialValueFor("leap_speed", (ability:GetLevel() - 1))
	local modifier_leap_immunity = keys.modifier_leap_immunity

	-- Clears any current command
	caster:Stop()

	-- Physics
	local direction = caster:GetForwardVector()
	local velocity = leap_speed * 1.4
	local end_time = leap_distance / leap_speed
	local time_elapsed = 0
	local half_time = end_time/2
	local jump = end_time/0.015

	Physics:Unit(caster)

	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)	
	caster:SetPhysicsVelocity(direction * velocity)

	-- HVH: plays flight animation, disjoints projectiles, and applies immunity
	--StartAnimation(caster, {duration=end_time, activity=ACT_DOTA_RUN, rate=1.0, translate="haste"})
	ProjectileManager:ProjectileDodge(caster)
	ability:ApplyDataDrivenModifier(caster, caster, modifier_leap_immunity, {})

	-- Move the unit
	Timers:CreateTimer(0, function()
		local ground_position = GetGroundPosition(caster:GetAbsOrigin() , caster)
		time_elapsed = time_elapsed + 0.03

		if time_elapsed < half_time then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,jump)) -- Going up
		-- If the target reached the ground then remove physics
		elseif caster:GetAbsOrigin().z - ground_position.z <= 0 then
			caster:SetPhysicsAcceleration(Vector(0,0,0))
			caster:SetPhysicsVelocity(Vector(0,0,0))
			caster:OnPhysicsFrame(nil)
			caster:PreventDI(false)
			caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
			caster:SetAutoUnstuck(true)
			caster:FollowNavMesh(true)
			caster:SetPhysicsFriction(.05)
			
			-- HVH prevents getting stuck, removes immunity
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			caster:RemoveModifierByName(modifier_leap_immunity)

			return nil
		else
			caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector(0,0,jump)) -- Going down
		end

		return 0.03
	end)
end