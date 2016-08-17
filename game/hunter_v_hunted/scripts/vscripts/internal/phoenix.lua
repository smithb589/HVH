if HVHPhoenix == nil then
	HVHPhoenix = class({})
end

function HVHPhoenix:Setup(vec)
	local start = vec or AICore:ChooseRandomPointOfInterest()
	local destinationList =	HVHNeutralCreeps:CreateDestinationList(start, 1, RANGE_TYPICAL_MIN)
	local phoenix = HVHNeutralCreeps:SpawnNeutrals("npc_hvh_phoenix", 1, start, DOTA_TEAM_CUSTOM_1)
	HVHNeutralCreeps:SetDestinationList(phoenix[1], destinationList)
	
	Timers:CreateTimer(0.1, function()
		local phoenixVis = VisionDummy(phoenix[1], "npc_dummy_reveal_phoenix")
	end)
	-- face that bird
	--Timers:CreateTimer(0.1, function()
	--	local direction = (HVHNeutralCreeps:GetDestination(phoenix) - phoenix:GetAbsOrigin()):Normalized()
	--	phoenix:SetForwardVector(direction)
	--end)
end

function HVHPhoenix:SetupEgg(phoenix)
	self:MakeEggsImmortal()
	
	local t = 1.0
	Timers:CreateTimer(t, function()
		if GameRules:IsDaytime() then
			HVHPhoenix:Rebirth(phoenix)
			return nil
		else
			return t
		end
	end)
end

function HVHPhoenix:MakeEggsImmortal()
	local eggs = self:FindEggs()
	for _,egg in pairs(eggs) do
		egg:AddNewModifier(egg,nil,"modifier_invulnerable",{})
		egg:AddAbility("phoenix_passives")
		Timers:CreateTimer(0.1, function()
			local eggVis = VisionDummy(egg, "npc_dummy_reveal_phoenix") -- egg vision
		end)
	end
end

-- won't work for multiple phoenixes: perhaps finding closest egg would do better?
function HVHPhoenix:FindEggs()
	local eggs = {}

	-- phoenix egg's classname is npc_dota_base_additive and has modifier_phoenix_sun
	local ents = Entities:FindAllByClassname("npc_dota_base_additive")
	--print("Found " .. #ents)
	for _,ent in pairs(ents) do
		if ent:HasModifier("modifier_phoenix_sun") then
			table.insert(eggs, ent)
		end
	end

	return eggs
end

function HVHPhoenix:Rebirth(phoenix)
	local origin = phoenix:GetAbsOrigin()
	local eggs = self:FindEggs()

	for _,egg in pairs(eggs) do
		egg:RemoveModifierByName("modifier_phoenix_sun") -- removing modifier seems to destroy the sun
		phoenix:AddNoDraw()
		phoenix:ForceKill(false)
		self:Setup(origin) -- spawn a new phoenix. fitting, right?		
	end
end

function HVHPhoenix:IsPhoenix(ent)
	local class = ent:GetClassname()
	if (class == "npc_dota_creature" and ent:GetUnitName() == "npc_hvh_phoenix") then
		return true
	else
		return false
	end
end

function HVHPhoenix:IsEgg(ent)
	local class = ent:GetClassname()
	if (class == "npc_dota_base_additive" and ent:HasModifier("modifier_phoenix_sun")) then
		return true
	else
		return false
	end
end