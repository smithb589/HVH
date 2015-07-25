--[[
This script represents a chest conceptually as an item that returns
another random item.
]]

require("internal/hvh_item_group")

-- Hooks up the constructor call.
if HVHChestModel == nil then
	HVHChestModel = {}
	HVHChestModel.__index = HVHChestModel
	setmetatable(HVHChestModel, {
		__call = function (itemChest, ...)
			return itemChest.new(...)
		end,
	})
end

-- constructor
function HVHChestModel.new(chestConfigFileName)
	local self = setmetatable({}, HVHChestModel)

	self._chestName = nil
	self._itemGroups = {}
	self._groupsWithItemsRemainingInCycle = {}

	self:_LoadChestConfig(chestConfigFileName)

	self:ResetItemsRemainingThisCycle()

	return self
end

function HVHChestModel:GetChestName()
	return self._chestName
end

function HVHChestModel:GetRandomItemName()
	local randomItem = nil
	local groups = self:_GetShuffledGroupsWithItemsRemainingThisCycle()

	for index, itemGroup in pairs(groups) do
		randomItem = itemGroup:GetRandomItemName()
		if randomItem then
			self:_DisplayRandomItem(itemGroup:GetGroupName(), randomItem)
			self._groupsWithItemsRemainingInCycle = self:_RemoveGroupIfNoItemsRemainingInCycle(index, itemGroup, groups)
			break
		end
	end
	return randomItem
end

function HVHChestModel:ResetItemsRemainingThisCycle()
	self._groupsWithItemsRemainingInCycle = {}
	for _, itemGroup in pairs(self._itemGroups) do
		itemGroup:ResetItemsRemainingThisCycle()
		table.insert(self._groupsWithItemsRemainingInCycle, itemGroup)
	end
	
end

function HVHChestModel:GetItemsPerCycle()
	local itemsPerCycle = 0
	for _, itemGroup in pairs(self._itemGroups) do
		itemsPerCycle = itemsPerCycle + itemGroup:GetItemsPerCycle()
	end
	return itemsPerCycle
end

function HVHChestModel:IsChestItemName(itemName)
	return itemName == self._chestName
end

function HVHChestModel:DisplayChestProbabilties()
	print(string.format("Chest type %s", self._chestName))
	for _, itemGroup in pairs(self._itemGroups) do
		itemGroup:DisplayGroupProbabilties()
	end
end

function HVHChestModel:_LoadChestConfig(chestConfigFileName)
	local chestConfig = LoadKeyValues(chestConfigFileName)
	self:_LoadItemFile(chestConfig.item_groups_file, chestConfig.item_groups)
	self._chestName = chestConfig.chest_name
end

-- Parses out relevant information from the items kv file.
function HVHChestModel:_LoadItemFile(itemConfigFilename, itemGroups)
	local itemData = LoadKeyValues(itemConfigFilename)
	if not itemData then
		print(string.format("Unable to load items from %s.", itemConfigFilename))
	else
		self:_LoadItemGroups(itemData, itemGroups)
	end
end

function HVHChestModel:_LoadItemGroups(itemData, itemGroups)
	for _, groupConfig in pairs(itemGroups) do
		table.insert(self._itemGroups, HVHItemGroup(groupConfig, itemData))
	end
end

function HVHChestModel:_DisplayRandomItem(groupName, itemName)
	HVHDebugPrint(string.format("Got item %s for group %s.", itemName, groupName))
end

function HVHChestModel:_GetShuffledGroupsWithItemsRemainingThisCycle()
	local shuffledGroups = HVHShuffle(self._groupsWithItemsRemainingInCycle)
	return shuffledGroups
end

function HVHChestModel:_RemoveGroupIfNoItemsRemainingInCycle(index, group, groupArray)
	if not group:HasItemsRemainingThisCycle() then
		table.remove(groupArray, index)
	end
	return groupArray
end