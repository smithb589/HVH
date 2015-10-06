--------------------------------------------------------------------------------------------------------
-- Despawn behavior
--------------------------------------------------------------------------------------------------------
if BehaviorDespawn == nil then
	BehaviorDespawn = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MEDIUM
		Behavior.init(self)
	end)
end

function BehaviorDespawn:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.killAfter = 1.0
end

function BehaviorDespawn:Evaluate()
	return self.desire -- DESIRE_MEDIUM
end

function BehaviorDespawn:Begin()
	self.endTime = GameRules:GetGameTime() + self.killAfter
	--local fadeParticle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
	--ParticleManager:SetParticleControl(fadeParticle, 1, self.unit:GetAb
end

function BehaviorDespawn:Continue()
	--thisEntity:AddNewModifier(self.unit, nil, "modifier_invisible", {})
	self.unit:ForceKill(false)
end

function BehaviorDespawn:End()
end

function BehaviorDespawn:Think(dt)
end
