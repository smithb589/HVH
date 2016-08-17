function SunShard_OnUse(keys)
	local caster = keys.caster
	local target = keys.target
	local item = keys.ability

	if not HVHPhoenix:IsPhoenix(target) and not HVHPhoenix:IsEgg(target) then
		print("Invalid target")
		return
	end

	local mode = GameRules:GetGameModeEntity()

	if GameRules:IsDaytime() then
		mode.HalfCycleTimeRemaining = mode.HalfCycleTimeRemaining + SUN_SHARD_BONUS_TIME
	else
		mode.HalfCycleTimeRemaining = mode.HalfCycleTimeRemaining - SUN_SHARD_BONUS_TIME
	end		

	--TODO: create tracking particle

	ParticleManager:CreateParticle("particles/ui/ui_generic_treasure_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
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

--[[
   	"OnSpellStart"
	{
		"TrackingProjectile"
		{
			"Target" 		"TARGET"
		    "EffectName"  	"particles/thrown_sunshard.vpcf"
		    "MoveSpeed"   	"750"
		    "StartPosition" "attach_origin"
		}

		"FireSound"
		{
			"EffectName"	"Hero_ChaosKnight.idle_throw"
			"Target" 		"CASTER"
		}
	}

	"OnProjectileHitUnit"
	{
		"RunScript"
		{
			"Target"		"TARGET"
			"ScriptFile"	"spells/item_sun_shard_hvh.lua"
			"Function"		"SunShard_OnHit"
		}

		"FireSound"
		{
			"EffectName"	"DOTA_Item.MedallionOfCourage.Activate"
			"Target" 		"TARGET"
		}
	}
--]]