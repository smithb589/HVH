function SunShard_OnUse(keys)
	local caster = keys.caster
	local target = keys.target
	local item = keys.ability

	if not HVHPhoenix:IsPhoenix(target) and not HVHPhoenix:IsEgg(target) then
		HVHErrorUtils:SendErrorToScreenTop(caster:GetPlayerOwner(), "#SunShardReject_WrongTarget")
		return
	end

	--Create a tracking projectile from player 1 that follows player 2
	ProjectileManager:CreateTrackingProjectile(	{
		Target = target,
		Source = caster,
		Ability = item,	
		EffectName = "particles/thrown_sunshard.vpcf",
	        iMoveSpeed = 1000,
		vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
		bDrawsOnMinimap = false,                          -- Optional
	        bDodgeable = false,                                -- Optional
	        bIsAttack = false,                                -- Optional
	        bVisibleToEnemies = true,                         -- Optional
	        --bReplaceExisting = false,                         -- Optional
	    	flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
		bProvidesVision = true,                           -- Optional
		iVisionRadius = 400,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
	} )

	ParticleManager:CreateParticle("particles/ui/ui_generic_treasure_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)	
end

function SunShard_OnHit(keys)
	local target = keys.target
	local item = keys.ability

	local mode = GameRules:GetGameModeEntity()
	local color,symbol = nil,nil
	if GameRules:IsDaytime() then
		mode.HalfCycleTimeRemaining = mode.HalfCycleTimeRemaining + SUN_SHARD_BONUS_TIME
		color = Vector(252, 175, 61)
		symbol = POPUP_SYMBOL_PRE_PLUS
	else
		mode.HalfCycleTimeRemaining = mode.HalfCycleTimeRemaining - SUN_SHARD_BONUS_TIME
		color = Vector(150, 225, 255)
		symbol = POPUP_SYMBOL_PRE_MINUS
	end	

	PopupNumbers(target, "damage", color, 6.0, SUN_SHARD_BONUS_TIME, symbol, POPUP_SYMBOL_POST_POINTZERO)

	ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	target:EmitSound("Hero_Omniknight.Purification")
	HVHItemUtils:ExpendCharge(item)
end



function SunShard_OnDeath(keys)
	local caster = keys.caster
	local item = keys.ability	

	for i=1, item:GetCurrentCharges() do
		local pos = caster:GetAbsOrigin()
		local item = CreateItem("item_sun_shard_hvh", nil, nil)
		local drop = CreateItemOnPositionForLaunch(pos, item)
		local distance = RandomFloat(200,1600)
		local pos_launch = pos + RandomVector(distance)
		item:LaunchLoot(false, 100 + (distance * 0.2), 1.0 + (distance * 0.001), pos_launch)
	end

	Timers:CreateTimer(0.1, function()
		caster:RemoveItem(item)
	end)
end