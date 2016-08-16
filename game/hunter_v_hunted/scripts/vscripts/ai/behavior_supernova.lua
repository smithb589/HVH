--------------------------------------------------------------------------------------------------------
-- Phoenix Supernova
--------------------------------------------------------------------------------------------------------
if BehaviorSupernova == nil then
	BehaviorSupernova = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorSupernova:Setup()
	self.supernovaAbility = self.unit:FindAbilityByName("phoenix_supernova")
	self.order.AbilityIndex  = self.supernovaAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET
end

function BehaviorSupernova:Evaluate()
	local desire = DESIRE_NONE

	if not GameRules:IsDaytime() then
		desire = self.desire --DESIRE_MAX
	end

	return desire
end

function BehaviorSupernova:Begin()
	Timers:CreateTimer(0.1, function()
		HVHPhoenix:MakeEggsImmortal()
	end)
	--self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorSupernova:Continue()

end

function BehaviorSupernova:End()
	HVHPhoenix:Rebirth(self.unit)
end

	--[[
	local ents = Entities:FindAllInSphere(origin, 256.0)
	print("Found " .. #ents)
	for _,ent in pairs(ents) do
		--AICore:DebugDraw(ent:GetAbsOrigin(), ent:GetAbsOrigin(), Vector(255,0,0), 1.0)
		print("..."..ent:GetClassname())
		if ent:GetClassname() == "npc_dota_base_additive" and ent:HasModifier("modifier_phoenix_sun") then
			ent:RemoveModifierByName("modifier_phoenix_sun")
			self.unit:AddNoDraw()
			self.unit:ForceKill(false)
			HVHPhoenix:Setup(origin)
		end
	end
	--]]

function BehaviorSupernova:Think(dt)
end