--------------------------------------------------------------------------------------------------------
-- ModifierStackManager class
--------------------------------------------------------------------------------------------------------
if ModifierStackManager == nil then
	ModifierStackManager = DeclareClass({}, function(self, caster, ability, modifier_name)
		self.caster = caster
		self.ability = ability
		self.modifier_name = modifier_name
		self.current_charges = 0
		self.isCharging = true
		self.cooldown = 0.0
		self._initialize(self)
	end)
end

function ModifierStackManager:_initialize()
	--self.caster:SetModifierStackCount( self.modifier_name, caster, 0 )
	self:_RefreshAbilitySpecialValues()
	self.ability:ApplyDataDrivenModifier( self.caster, self.caster, self.modifier_name, {} )
	self.caster:SetModifierStackCount( self.modifier_name, self.caster, self.maximum_charges )
end

function ModifierStackManager:_RefreshAbilitySpecialValues()
	self.maximum_charges = 		 self.ability:GetLevelSpecialValueFor("maximum_charges", self.ability:GetLevel() - 1)
	self.charge_replenish_time = self.ability:GetLevelSpecialValueFor("charge_replenish_time", self.ability:GetLevel() - 1)
	self.minimum_cooldown = 	 self.ability:GetLevelSpecialValueFor("minimum_cooldown", self.ability:GetLevel() - 1)
end

function ModifierStackManager:_StartCharging()
	-- create timer to restore stack
	Timers:CreateTimer( function()
		-- Restore charge
		if self.isCharging and self.current_charges < self.maximum_charges then

			-- Calculate stacks
			local nextCharge = self.current_charges + 1
			self.caster:RemoveModifierByName( self.modifier_name )
			if nextCharge ~= self.maximum_charges then
				self.ability:ApplyDataDrivenModifier( self.caster, self.caster, self.modifier_name, { Duration = self.charge_replenish_time } )
			else
				self.ability:ApplyDataDrivenModifier( self.caster, self.caster, self.modifier_name, {} )
				self.isCharging = false
			end

			self.caster:SetModifierStackCount( self.modifier_name, self.caster, nextCharge )
			
			-- Update stack
			self.current_charges = nextCharge
		end
		
		-- Check if max is reached then check every 0.5 seconds if the charge is used
		if self.current_charges ~= self.maximum_charges then
			self.isCharging = true
			return self.charge_replenish_time
		else
			return 0.5
		end
	end)
end

-- Stick in OnUpgrade in your ability lua
function ModifierStackManager:OnUpgrade()
	self:_RefreshAbilitySpecialValues()

	-- Begin charging at first level
	if self.ability:GetLevel() == 1 then
		self:_StartCharging()
	else -- leveling up past first level
		 -- instantly grant a new charge and end cooldown
		self.current_charges = self.current_charges + 1
		self.caster:SetModifierStackCount( self.modifier_name, self.caster, self.current_charges)
		self.ability:EndCooldown()
	end
end

-- Stick in OnSpellStart in your ability lua
function ModifierStackManager:ExpendCharge()
	-- Reduce stack if more than 0 else refund mana
	if self.current_charges > 0 then
		-- Deplete charge
		local nextCharge = self.current_charges - 1

		if self.current_charges == self.maximum_charges then
			self.caster:RemoveModifierByName( self.modifier_name )
			self.ability:ApplyDataDrivenModifier( self.caster, self.caster, self.modifier_name, { Duration = self.charge_replenish_time } )
		end

		self.caster:SetModifierStackCount( self.modifier_name, self.caster, nextCharge )
		self.current_charges = nextCharge
		
		-- If we've used the last charge, set cooldown = remaining time on charge
		if self.current_charges == 0 then
			local remainingTime = self.caster:FindModifierByName(self.modifier_name):GetRemainingTime()
			self.ability:StartCooldown(remainingTime)
		-- Otherwise (we have charges) so set cooldown to special "minimum cooldown"
		else
			self.ability:StartCooldown(self.minimum_cooldown)
		end
	else
		--self.ability:RefundManaCost()
	end
end