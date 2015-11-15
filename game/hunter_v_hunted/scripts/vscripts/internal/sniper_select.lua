if HVHSniperSelect == nil then
	HVHSniperSelect = class({})
end

SNIPER_SELECT_REASON_KILLED = 0
SNIPER_SELECT_REASON_FREEBIE = 1

function HVHSniperSelect:Setup()
	CustomGameEventManager:RegisterListener("sniper_select_choose_ability", Dynamic_Wrap(HVHSniperSelect, "ChooseAbility"))
end

function HVHSniperSelect:Check(killer)
	local team = killer:GetTeam()
	if team == DOTA_TEAM_GOODGUYS then
		if self:HasEmptySlot(killer) then
			self:MakeMenuVisible(killer, SNIPER_SELECT_REASON_KILLED)
		else
			self:MakeMenuVisibleToRandomEligibleTeammate(killer)
		end
	end
end

function HVHSniperSelect:HasEmptySlot(hero)
	local ability = hero:FindAbilityByName("sniper_empty")
	
	if ability then
		return true
	else
		return false
	end
end

function HVHSniperSelect:MakeMenuVisible(hero, sniper_select_reason)
	--print("Making menu visible to player ".. hero:GetPlayerOwnerID())
	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "sniper_select_make_visible", { reason = sniper_select_reason})
end

function HVHSniperSelect:MakeMenuVisibleToRandomEligibleTeammate(hero)
	local heroList = HeroList:GetAllHeroes()
	local validSniperList = {}

	for _,hero in pairs(heroList) do
		if hero:GetTeam() == DOTA_TEAM_GOODGUYS and self:HasEmptySlot(hero) then
			table.insert(validSniperList, hero)
		end
	end

	if #validSniperList > 0 then
		local r = RandomInt(1, #validSniperList)
		self:MakeMenuVisible(validSniperList[r], SNIPER_SELECT_REASON_FREEBIE)
	end
end

function HVHSniperSelect:ChooseAbility(args)
	local playerID = args.playerID
	local player = PlayerResource:GetPlayer(playerID)
	local hero = player:GetAssignedHero()
	local character = args.character
	local abilityName = ""

	if character == "Kardel" then
		abilityName = "sniper_sharpshooter"
	elseif character == "Riggs" then
		abilityName = "sniper_flush"
	elseif character == "Florax" then
		abilityName = "sniper_teleportation"
	elseif character == "Jebby" then
		abilityName = "sniper_concoction"
	end

	hero:RemoveAbility("sniper_empty")
	hero:AddAbility(abilityName)
	HVHGameMode:LevelupAbility(hero, abilityName, true)

	CustomGameEventManager:Send_ServerToAllClients("sniper_select_disable_choice", { character = character })
end