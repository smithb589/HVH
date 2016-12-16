require("ai/dog_behaviors/dog_utils")

function Spawn( entityKeyValues )
	-- preview pane is now spawning creatures in it, as of ~7.00
	if not IsServer() then return end

	thisEntity.FedBy = function(self, newFeeder, feedDuration, loyaltyDuration)
		if self._LastFeeder then
			HVHDogUtils:RemoveLoyaltyBuff(self._LastFeeder)
		end

		self._LastFeeder = newFeeder -- new feeder becomes the last feeder here
		self._FeedDuration = feedDuration
		self._LoyaltyDuration = loyaltyDuration

		self._FeedTime = GameRules:GetGameTime()
		self._LoyaltyEndsAt = self._FeedTime + self._LoyaltyDuration

		HVHDogUtils:ApplyLoyaltyBuff(newFeeder, thisEntity)
		--print("LOYALTY ENDS AT: " .. self._LoyaltyEndsAt)
	end

	thisEntity.IsFed = function(self)
		local currentTime = GameRules:GetGameTime() 
		return (self._FeedTime + self._FeedDuration) > currentTime
	end

	-- This stores the location we started wandering from so the dog
	-- can't just run across the entire map.
	thisEntity._WanderingOrigin = Vector(0, 0)
	thisEntity._MaxWanderingDistance = 500.0 --150.0
	thisEntity._MaxDefendRange = thisEntity:GetNightTimeVisionRange()

	thisEntity._LastFeeder = nil
	thisEntity._LoyaltyDuration = 0
	thisEntity._FeedDuration = 0
	-- Arbitrarily age this so the dog doesn't start fed.
	thisEntity._FeedTime = GameRules:GetGameTime() - 60
	thisEntity._LoyaltyEndsAt = 0

	thisEntity._LastWarnTime = 0.0

	print("dog is setting context think")
	thisEntity:SetContextThink("Think", Think, 0.1)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorWander(thisEntity, DESIRE_MAX, DESIRE_MEDIUM), -- either
		BehaviorSprint(thisEntity, DESIRE_MAX),      -- day
		BehaviorDefend(thisEntity, DESIRE_HIGH+1),   -- night
		BehaviorWarn  (thisEntity, DESIRE_HIGH),     -- either
		BehaviorFollow(thisEntity, DESIRE_MEDIUM+1), -- night
		BehaviorPursue(thisEntity, DESIRE_LOW),      -- day
		BehaviorSleep (thisEntity, DESIRE_LOW)       -- night
	})
	thisEntity.behaviorSystem.thinkDuration = 0.1
	HVHDebugPrint(string.format("Starting AI for %s. Entity Index: %s", thisEntity:GetUnitName(), thisEntity:GetEntityIndex()))
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		print ("dog deactivating")
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end