
require("internal/hvh_randomizer")
require("hvh_utils")

-- Hooks up the constructor call.
if HVHItemGroup == nil then
    HVHItemGroup = {}
    HVHItemGroup.__index = HVHItemGroup
    setmetatable(HVHItemGroup, {
        __call = function (itemGroup, ...)
            return itemGroup.new(...)
        end,
    })
end

-- constructor
function HVHItemGroup.new(groupConfig, itemData)
    local self = setmetatable({}, HVHItemGroup)

    self._groupName = groupConfig.group_name
    --print(string.format("Creating item group for %s.", self._groupName))
    local itemGroup = itemData[self._groupName]
    HVHAssert(itemGroup, string.format("No item group defined with name %s.", self._groupName))
    self._itemRandomizer = HVHRandomizer(itemGroup)
    self._itemsPerCycle = groupConfig.items_per_cycle

    self._itemsRemainingThisCycle = self._itemsPerCycle

    return self
end

function HVHItemGroup:GetItemsPerCycle()
    return self._itemsPerCycle
end

function HVHItemGroup:GetGroupName()
    return self._groupName
end

function HVHItemGroup:GetRandomItemName()
    local item = nil
    if self:HasItemsRemainingThisCycle() then
         item = self._itemRandomizer:GetRandomValue()
         self._itemsRemainingThisCycle = self._itemsRemainingThisCycle - 1
    else
        HVHDebugPrint("Tried to get a random item with no items remaining in cycle.")
    end

    return item
end

function HVHItemGroup:HasItemsRemainingThisCycle()
    return self._itemsRemainingThisCycle > 0
end

function HVHItemGroup:ResetItemsRemainingThisCycle()
    self._itemsRemainingThisCycle = self._itemsPerCycle
end

function HVHItemGroup:DisplayGroupProbabilties()
    print(self._groupName)
    if self._itemRandomizer then
        self._itemRandomizer:DisplayProbabilties()
    end
end

