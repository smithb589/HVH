if VisionDummy == nil then
	VisionDummy = DeclareClass({}, function(self, unit, dummy_str)
		self.unit = unit
		self.dummy_str = dummy_str
		self.initialize(self)
	end)
end

function VisionDummy:initialize()
	print(self.unit)
	self.active = true
	local pos = self.unit:GetAbsOrigin()
	self.vis_dummy_1 = CreateUnitByName(self.dummy_str, pos, false, nil, nil, DOTA_TEAM_GOODGUYS)
	self.vis_dummy_2 = CreateUnitByName(self.dummy_str, pos, false, nil, nil, DOTA_TEAM_BADGUYS)

	Timers:CreateTimer(0.1, function()
		if self.active then
			self:Think()
			return 0.1
		else
			return nil
		end
	end)
end

function VisionDummy:Think()
	if self.unit and not self.unit:IsNull() and self.unit:IsAlive() then
	    self:MoveVisionDummy()
    else
	    self:KillVisionDummy()
	end
end

-- vision dummy follows the target
function VisionDummy:MoveVisionDummy()
	local pos = self.unit:GetAbsOrigin()
	self.vis_dummy_1:SetOrigin(pos)
	self.vis_dummy_2:SetOrigin(pos)
end

function VisionDummy:KillVisionDummy(target)
	self.vis_dummy_1:ForceKill(false)
	self.vis_dummy_2:ForceKill(false)
	self.active = false
end