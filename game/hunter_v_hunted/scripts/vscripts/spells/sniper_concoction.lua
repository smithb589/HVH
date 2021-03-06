--[[
	Author: Noya
	Date: 10.1.2015.
	Tracks when the first ability is cast, swaps with the sub ability and plays a sound that can be stopped later
]]
function StartBrewing( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	ability.brew_start = GameRules:GetGameTime()
	
	-- Swap sub_ability
	local sub_ability_name = event.sub_ability_name
	local main_ability_name = ability:GetAbilityName()

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_unstable_concoction_brewing", {})
	--print("Applied brewing modifier")

	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
	--print("Swapped "..main_ability_name.." with " ..sub_ability_name)

	-- Play the sound, which will be stopped when the sub ability fires
	caster:EmitSound("Hero_Alchemist.UnstableConcoction.Fuse")
end	

--[[
	Author: Noya
	Date: 10.1.2015.
	Updates the numeric particle every 0.5 think interval
]]
function UpdateTimerParticle( event )

	local caster = event.caster
	local ability = event.ability
	local brew_explosion = ability:GetLevelSpecialValueFor( "brew_explosion", ability:GetLevel() - 1 )

	-- Show the particle to all allies
	local allHeroes = HeroList:GetAllHeroes()
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"
	local preSymbol = 0 -- Empty
	local digits = 2 -- "5.0" takes 2 digits
	local number = GameRules:GetGameTime() - ability.brew_start - brew_explosion - 0.1 --the minus .1 is needed because think interval comes a frame earlier

	-- Get the integer. Add a bit because the think interval isn't a perfect 0.5 timer
	local integer = math.floor(math.abs(number))

	-- Round the decimal number to .0 or .5
	local decimal = math.abs(number) % 1

	if decimal < 0.5 then 
		decimal = 1 -- ".0"
	else 
		decimal = 8 -- ".5"
	end

	--print(integer,decimal)

	for k, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			-- Don't display the 0.0 message
			if integer == 0 and decimal == 1 then
				
			else
				local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_OVERHEAD_FOLLOW, caster, PlayerResource:GetPlayer( v:GetPlayerID() ) )
				
				ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
				ParticleManager:SetParticleControl( particle, 1, Vector( preSymbol, integer, decimal) )
				ParticleManager:SetParticleControl( particle, 2, Vector( digits, 0, 0) )
			end
		end
	end

end

--[[
	Author: Noya
	Date: 10.1.2015.
	When the sub_ability is cast, stops the sound, the particle thinker and sets the time charged
	Also swaps the abilities back to the original state
]]
function EndBrewing( event )

	local caster = event.caster
	local sub_ability = event.ability

	-- Stops the charging sound
	caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")

	-- Swap the sub_ability back to normal
	local sub_ability_name = sub_ability:GetAbilityName()
	local main_ability_name = event.main_ability_name

	caster:SwapAbilities(main_ability_name, sub_ability_name, true, false)
	--print("Swapped "..main_ability_name.." with " ..sub_ability_name)

	-- Get the handle of the main ability to get the time started
	local ability = caster:FindAbilityByName(main_ability_name)

	-- Set how much time the spell charged
	ability.time_charged = GameRules:GetGameTime() - ability.brew_start

	-- Remove the brewing modifier
	caster:RemoveModifierByName("modifier_unstable_concoction_brewing")

end	

--[[
	Author: Noya
	Date: 16.1.2015.
	After destroying the modifier, checks how much time was the spell charged for, and does a explosion around self if charged over the brew_explosion time
]]
function CheckSelfStun( event )

	local caster = event.caster
	local ability = event.ability
	local brew_explosion = ability:GetLevelSpecialValueFor( "brew_explosion", ability:GetLevel() - 1 )
	local heroes_around = event.target_entities
	table.insert(heroes_around, caster)

	-- Set how much time the spell charged
	ability.time_charged = GameRules:GetGameTime() - ability.brew_start

	if ability.time_charged >= brew_explosion then
		--print("Stun Self")

		-- Stops the charging sound
		caster:StopSound("Hero_Alchemist.UnstableConcoction.Fuse")

		-- Plays the Concoction Stun sound
		caster:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")

		-- Swap the sub_ability back to normal
		local main_ability_name = ability:GetAbilityName()
		local sub_ability_name = event.sub_ability_name

		caster:SwapAbilities(sub_ability_name, main_ability_name, false, true)
		--print("Swapped "..sub_ability_name.." with " ..main_ability_name)

		-- Apply the self stun for max duration and damage
		local subAbility = caster:FindAbilityByName(sub_ability_name)
		local max_stun = ability:GetLevelSpecialValueFor( "max_stun", ability:GetLevel() - 1 )
		local max_damage = ability:GetLevelSpecialValueFor( "max_damage", ability:GetLevel() - 1 )
		local mainAbilityDamageType = ability:GetAbilityDamageType()

		-- for each affected hero, apply stun and damage
		for _,unit in pairs(heroes_around) do
			if not unit:IsMagicImmune() and not unit:IsOutOfGame() then
				local stun_duration = max_stun
				if unit:GetTeam() ~= caster:GetTeam() then
					-- halve duration of stun against enemies
					stun_duration = max_stun * 0.5
				end 
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_unstable_concoction_stun", {duration = stun_duration})
				ApplyDamage({ victim = unit, attacker = caster, damage = max_damage, damage_type = mainAbilityDamageType })
			end
		end

		-- Fire the explosion effect
		local particleName = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf"
		local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
				
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end

end

--[[
	Author: Noya
	Date: 16.01.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)
	if not ability_handle then
		print("Could not find " .. ability_name)
		return
	end
	local ability_level = ability_handle:GetLevel()
	--print(string.format("%s L%s -> %s L%s", this_abilityName, this_abilityLevel, ability_name, ability_level))

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function ConcoctionHit( event )
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local brew_time = ability:GetLevelSpecialValueFor( "brew_time", ability:GetLevel() - 1 )
	local mainAbility = caster:FindAbilityByName("sniper_concoction")

	-- Check the time charged to set the duration
	local charged_duration = mainAbility.time_charged
	if charged_duration >= brew_time then
		charged_duration = brew_time
	end

	-- How much of the possible charge time was charged
	local charged_percent = charged_duration / brew_time

	-- Final ability level based on charged_percent
	-- e.g., charge 50% of a 4-level ability and get L12
	local level_if_maxlevel_4 = math.max(1, math.floor(4 * charged_percent + 0.5)) -- rounded, at least L1
	local level_if_maxlevel_3 = math.max(1, math.floor(3 * charged_percent + 0.5)) -- rounded, at least L1

	-- ChemRage 20%, Tangos 10%, Natures 10%, Timewalk 15%, Timelapse 15%, BorrowedTime 15%, Minisnipers 15%
	local r = RandomInt(1, 100)
	if r <= 20 then
		ChemicalRage(target, level_if_maxlevel_3)
	elseif r <= 30 then
		TangoBloom(target, level_if_maxlevel_4)
	elseif r <= 40 then
		DoForceCast(target, "enchantress_natures_attendants", 12.0, level_if_maxlevel_4)
	elseif r <= 55 then
		TimeWalk(target, level_if_maxlevel_4)
	elseif r <= 70 then
		DoForceCast(target, "weaver_time_lapse", 10.0) -- level doesn't matter
	elseif r <= 85 then
		DoForceCast(target, "abaddon_borrowed_time", 10.0, level_if_maxlevel_3)
	else
		SpawnMiniSnipers(target, level_if_maxlevel_3)
	end

	--for i=0, 15 do
	--	local abi = caster:GetAbilityByIndex(i)
	--	if abi then print(abi:GetAbilityName() .. " L" .. abi:GetLevel()) end
	--end
end

function SpawnMiniSnipers(target, level)
	local DUR = 25.0

	local player = target:GetPlayerOwner()
	local playerID = player:GetPlayerID()

	for i=1, level do
		local pos = target:GetAbsOrigin() + RandomVector(RandomFloat(150,200))
		local unit = CreateUnitByName("npc_mini_sniper", pos, true, player:GetAssignedHero(), player:GetAssignedHero(), target:GetTeamNumber())
		unit:SetControllableByPlayer(playerID, true)
		unit:AddNewModifier(unit, nil, "modifier_kill", {duration = DUR})
		ParticleManager:CreateParticle("particles/neutral_fx/skeleton_spawn.vpcf", 0, unit)
		AddUnitToSelection(unit)

		Timers:CreateTimer(0.1, function()
			FindClearSpaceForUnit(unit, pos, true)
		end)
		--unit:SetIdleAcquire(false)
		--Timers:CreateTimer(0.5, function() unit:SetIdleAcquire(true) end)
	end
end

function TangoBloom(target, level)
	for i=1, level do
	    local pos = target:GetAbsOrigin()
		local item = CreateItem("item_tango_single", nil, nil)
		local drop = CreateItemOnPositionForLaunch(pos, item)
	    local pos_launch = pos + RandomVector(RandomFloat(150,200))
	    item:LaunchLoot(false, 200, 0.75, pos_launch)
	end
end

function TimeWalk(target, level)
	local position = target:GetAbsOrigin() + RandomVector(1300.0)
	DoForceCast(target, "faceless_void_time_walk", 10.0, level, position)
end

function ChemicalRage(target, level)
	target:SetModelScale(1.4)
	DoForceCast(target, "alchemist_chemical_rage", 30.0, level)
	Timers:CreateTimer(25.0, function()
		if not target:IsNull() then
			target:SetModelScale(1.0)
		end
	end)
end