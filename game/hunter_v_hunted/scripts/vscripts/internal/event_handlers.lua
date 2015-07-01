
function HVHGameMode:OnConnectFull()
	self:_SetupGameMode()
end

function HVHGameMode:OnPlayerSpawn(playerSpawnArgs)
	local unit = EntIndexToHScript(playerSpawnArgs.entindex)
	print("Spawned unit ")
	DeepPrintTable(unit)
	print("Spawn unit bounty: " .. unit:GetDeathXP())
	if unit and unit:IsHero() then
		self:SetHeroDeathBounty(unit)
	end
end

function HVHGameMode:OnEntityKilled(killedArgs)
 	local unit = EntIndexToHScript(killedArgs.entindex_killed)
 	print("Unit Killed.")
 	if unit and unit:IsHero() then
 		--print("XP bounty on killed unit: " .. unit:GetCustomDeathXP())
 	end
end