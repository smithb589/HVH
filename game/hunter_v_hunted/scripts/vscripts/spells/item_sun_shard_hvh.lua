function SunShard_Use(keys)
	local caster = keys.caster
	local target = keys.target
	local item = keys.ability

	local charges = item:GetCurrentCharges()
	local seconds = charges * 3.0
	local mode = GameRules:GetGameModeEntity()
	--print("Spending "..charges.." charges to add/subtract "..seconds.." seconds.")

	if GameRules:IsDaytime() then
		mode.HalfCycleTimeRemaining = mode.HalfCycleTimeRemaining + seconds
	else
		mode.HalfCycleTimeRemaining = mode.HalfCycleTimeRemaining - seconds
	end		

	caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
	
	Timers:CreateTimer(0.1, function()
		caster:RemoveItem(item)
	end)
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