--[[
Taken from the holdout example.

These are the valid orders, in case you want to use them (easier here than to find them in the C code):

DOTA_UNIT_ORDER_NONE
DOTA_UNIT_ORDER_MOVE_TO_POSITION 
DOTA_UNIT_ORDER_MOVE_TO_TARGET 
DOTA_UNIT_ORDER_ATTACK_MOVE
DOTA_UNIT_ORDER_ATTACK_TARGET
DOTA_UNIT_ORDER_CAST_POSITION
DOTA_UNIT_ORDER_CAST_TARGET
DOTA_UNIT_ORDER_CAST_TARGET_TREE
DOTA_UNIT_ORDER_CAST_NO_TARGET
DOTA_UNIT_ORDER_CAST_TOGGLE
DOTA_UNIT_ORDER_HOLD_POSITION
DOTA_UNIT_ORDER_TRAIN_ABILITY
DOTA_UNIT_ORDER_DROP_ITEM
DOTA_UNIT_ORDER_GIVE_ITEM
DOTA_UNIT_ORDER_PICKUP_ITEM
DOTA_UNIT_ORDER_PICKUP_RUNE
DOTA_UNIT_ORDER_PURCHASE_ITEM
DOTA_UNIT_ORDER_SELL_ITEM
DOTA_UNIT_ORDER_DISASSEMBLE_ITEM
DOTA_UNIT_ORDER_MOVE_ITEM
DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
DOTA_UNIT_ORDER_STOP
DOTA_UNIT_ORDER_TAUNT
DOTA_UNIT_ORDER_BUYBACK
DOTA_UNIT_ORDER_GLYPH
DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH
DOTA_UNIT_ORDER_CAST_RUNE
]]

if AICore == nil then
  AICore = class({})
end

require("utils/ai_utils")
require("utils/hvh_utils")

require("ai/constants")
require("ai/behavior")
require("ai/behavior_add_new_destination")
require("ai/behavior_attack_target")
require("ai/behavior_attack_target_aggressive")
require("ai/behavior_blackhole")
require("ai/behavior_blackhole_channel")
require("ai/behavior_blinkdagger")
require("ai/behavior_choose_next_destination")
require("ai/behavior_despawn")
require("ai/behavior_despawn_forced")
require("ai/behavior_despawn_when_unseen")
require("ai/behavior_earthshock")
require("ai/behavior_eidolon_attack")
require("ai/behavior_enrage")
require("ai/behavior_overpower")
require("ai/behavior_place_mine")
require("ai/behavior_retreat")
require("ai/behavior_slam")
require("ai/behavior_toss")
require("ai/behavior_travel")
require("ai/behavior_travel_aggressive")
require("ai/behavior_wait")

require("ai/dog_behaviors/behavior_defend")
require("ai/dog_behaviors/behavior_follow")
require("ai/dog_behaviors/behavior_pursue")
require("ai/dog_behaviors/behavior_sleep")
require("ai/dog_behaviors/behavior_sprint")
require("ai/dog_behaviors/behavior_wander")
require("ai/dog_behaviors/behavior_warn")
require("ai/dog_behaviors/dog_utils")

function AICore:CreateBehaviorSystem( behaviors )
	local BehaviorSystem = {}

	--PrintTable(behaviors)

	BehaviorSystem.possibleBehaviors = behaviors
	BehaviorSystem.thinkDuration = 1.0
	BehaviorSystem.repeatedlyIssueOrders = true -- if you're paranoid about dropped orders, leave this true

	BehaviorSystem.currentBehavior =
	{
		endTime = 0,
		order = { OrderType = DOTA_UNIT_ORDER_NONE }
	}

	function BehaviorSystem:Think()
		if GameRules:GetGameTime() >= self.currentBehavior.endTime then
			local newBehavior = self:ChooseNextBehavior()
			if newBehavior == nil then 
				-- Do nothing here... this covers possible problems with ChooseNextBehavior
			elseif newBehavior == self.currentBehavior then
				self.currentBehavior:Continue()
			else
				if self.currentBehavior.End then self.currentBehavior:End() end
				self.currentBehavior = newBehavior
				self.currentBehavior:Begin()
			end
		end

		if self.currentBehavior.order and self.currentBehavior.order.OrderType ~= DOTA_UNIT_ORDER_NONE then
			if self.repeatedlyIssueOrders or
				self.previousOrderType ~= self.currentBehavior.order.OrderType or
				self.previousOrderTarget ~= self.currentBehavior.order.TargetIndex or
				self.previousOrderPosition ~= self.currentBehavior.order.Position then

				-- Keep sending the order repeatedly, in case we forgot >.<
				ExecuteOrderFromTable( self.currentBehavior.order )
				self.previousOrderType = self.currentBehavior.order.OrderType
				self.previousOrderTarget = self.currentBehavior.order.TargetIndex
				self.previousOrderPosition = self.currentBehavior.order.Position
			end
		end

		if self.currentBehavior.Think then self.currentBehavior:Think(self.thinkDuration) end

		return self.thinkDuration
	end

	function BehaviorSystem:ChooseNextBehavior()
		local result = nil
		local bestDesire = nil
		for _,behavior in pairs( self.possibleBehaviors ) do
			local thisDesire = behavior:Evaluate()
			if bestDesire == nil or thisDesire > bestDesire then
				result = behavior
				bestDesire = thisDesire
			end
		end

		HVHDebugPrint(string.format("Choosing behavior with score %d", bestDesire))
		--HVHDebugPrintTable(result)

		return result
	end
	
	function BehaviorSystem:Deactivate()
		if self.currentBehavior.End then self.currentBehavior:End() end
	end

	return BehaviorSystem
end