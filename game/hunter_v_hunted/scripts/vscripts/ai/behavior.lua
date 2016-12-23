--------------------------------------------------------------------------------------------------------
-- Behavior superclass
--------------------------------------------------------------------------------------------------------
if Behavior == nil then
	Behavior = DeclareClass({}, function(self)
		self.initialize(self)
	end)
end

function Behavior:initialize()
	self.name = "Default Behavior"
	self.endTime = 0
	self.order = {}
	self.order.OrderType 	= DOTA_UNIT_ORDER_NONE
	self.order.UnitIndex 	= nil -- thisEntity.entindex()
	self.order.TargetIndex 	= nil
	self.order.AbilityIndex = nil
	self.order.Position 	= nil

	if self.unit then
		self.order.UnitIndex = self.unit:entindex()
	end

	self:Setup()
end

function Behavior:Setup()
	print("DEFAULT BEHAVIOR CALLED: Behavior not initialized!")
end

function Behavior:Evaluate()
	return DESIRE_NONE
end

function Behavior:Begin()
end

function Behavior:Continue()
end

function Behavior:End()
end

function Behavior:Think(dt)
end

function Behavior:SetOrderType(v)
	self.order.OrderType = v
end

function Behavior:SetUnitIndex(v)
	--print ("Behavior:SetUnitIndex: " .. v)
	self.order.UnitIndex = v
end

function Behavior:SetTargetIndex(v)
	--print ("Behavior:SetTargetIndex: " .. v)
 	self.order.TargetIndex = v
end

function Behavior:SetAbilityIndex(v)
	self.order.AbilityIndex = v
end

function Behavior:SetPosition(v)
	self.order.Position = v
end