if HVHPhoenix == nil then
	HVHPhoenix = class({})
end

function HVHPhoenix:Setup(vec)
	if HVHGameMode.HostOptions["DisablePhoenix"] then return end

	local start = vec or AICore:ChooseRandomPointOfInterest()
	local destinationList =	HVHNeutralCreeps:CreateDestinationList(start, 1, RANGE_TYPICAL_MIN)
	local phoenixList = HVHNeutralCreeps:SpawnNeutrals("npc_hvh_phoenix", 1, start, DOTA_TEAM_CUSTOM_1)
	local phoenix = phoenixList[1]
	HVHNeutralCreeps:SetDestinationList(phoenix, destinationList)
end

function HVHPhoenix:IsPhoenix(ent)
	local class = ent:GetClassname()
	return (class == "npc_dota_creature" and ent:GetUnitName() == "npc_hvh_phoenix")
end

function HVHPhoenix:IsEgg(ent)
	return ent:HasModifier("modifier_supernova_egg_form_hvh")
end

--[[
function HVHPhoenix:SetupEgg(phoenix)
	self:MakeEggsImmortal()
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

function HVHPhoenix:FindPhoenixes()
	local phoenixes = {}
	local ents = Entities:FindAllByClassname("npc_dota_creature")

	for _,ent in pairs(ents) do
		if ent:GetUnitName() == "npc_hvh_phoenix" then
			table.insert(phoenixes, ent)
		end
	end

	return phoenixes
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
]]