--------------------------------------------------------------------------------------------------------
-- DespawnWhenUnseen behavior
--------------------------------------------------------------------------------------------------------
if BehaviorDespawnWhenUnseen == nil then
	BehaviorDespawnWhenUnseen = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MEDIUM
		Behavior.init(self)
	end)
end

function BehaviorDespawnWhenUnseen:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.killAfter = 6.0
	self.killTime = nil -- setup later
end

function BehaviorDespawnWhenUnseen:Evaluate()
	local desire = DESIRE_NONE

	if self:IsUnitUnseenToAllHeroes(self.unit) then
		desire = self.desire
	end

	return desire -- DESIRE_MEDIUM
end

function BehaviorDespawnWhenUnseen:Begin()
	self:SetKillTime()
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorDespawnWhenUnseen:Continue()
	--print(GameRules:GetGameTime())
	if GameRules:GetGameTime() >= self.killTime then
		self.unit:ForceKill(false)
		--print("Despawning unseen creep")
	end
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorDespawnWhenUnseen:End()
	self.killTime = nil
end

function BehaviorDespawnWhenUnseen:Think(dt)
end

function BehaviorDespawnWhenUnseen:SetKillTime()
	self.killTime = GameRules:GetGameTime() + self.killAfter
	--print("Kill time: " .. self.killTime)
end

function BehaviorDespawnWhenUnseen:IsUnitUnseenToAllHeroes(unit)
	local heroList = HeroList:GetAllHeroes()
	for _,hero in pairs(heroList) do
		if hero:CanEntityBeSeenByMyTeam(self.unit) then
			--print(self.unit:GetUnitName() .. " CAN be seen by " .. hero:GetUnitName() .. " RETURNING FALSE.")
			return false
		end
	end

	--print(self.unit:GetUnitName() .. " is unseen by all. RETURNING TRUE.")
	return true
end