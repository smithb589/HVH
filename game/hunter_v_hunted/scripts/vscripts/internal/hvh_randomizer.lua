--[[
Handles randomizing arbitrary objects based on "proportional" or "relative" probabilty.
For example, object A with a relative probability of 1 and object B with a relative probability
of 2 implies that object B is twice as common as object A.
]]

require("hvh_utils")

-- Hooks up the constructor call.
if HVHRandomizer == nil then
	HVHRandomizer = {}
	HVHRandomizer.__index = HVHRandomizer
	setmetatable(HVHRandomizer, {
		__call = function (randomizer, ...)
			return randomizer.new(...)
		end,
	})
end

-- Constructor-like method. Invoked with HVHRandomizer(args).
--[[ Expects the argument to be of the format:
	{
		{
			value = something,
			weight = value between .001 and 1000
		},
		{
			-- another
		}
	}
]]
function HVHRandomizer.new(weightedValueObjects)
	local self = setmetatable({}, HVHRandomizer)

	self._totalProbability = 0.0
	self._weightedValues = weightedValueObjects

	self._CalculateTotalProbability(self)
	return self
end

-- Returns a random,
function HVHRandomizer:GetRandomValue()
	local randomFloat = RandomFloat(0.0, self._totalProbability)
	local randomValue = self:_GetValueForRandomProbability(randomFloat)
	HVHDebugPrint(string.format("Got value "..randomValue.." for float %f.", randomFloat))
	return randomValue
end

function HVHRandomizer:DisplayProbabilties()
	local totalProbabilityPercent = 0.0;
	if self._weightedValues then
		for _,weightValuePair in pairs(self._weightedValues) do
			local probabilityPercent = (self:_GetWeight(weightValuePair) / self._totalProbability) * 100.0
			print(string.format("(value=%s, probability=%f%%)", weightValuePair.value, probabilityPercent))
			totalProbabilityPercent = totalProbabilityPercent + probabilityPercent
		end
	end

	print(string.format("Total probability: %f%%", totalProbabilityPercent))
end

-- Determines the total probabilty to use for weighting.
function HVHRandomizer:_CalculateTotalProbability()
	local totalProbability = 0.0
	for index, weightValuePair in pairs(self._weightedValues) do
		local weight = self:_GetWeight(weightValuePair)
		totalProbability = totalProbability + weight
		HVHDebugPrint(string.format("Adding probability %f for item " .. weightValuePair.value, weight))
	end
	self._totalProbability = totalProbability
end

-- Extracts the relative probability from a value-probability paired object.
function HVHRandomizer:_GetWeight(weightValuePair)
	local weight = 0.0
	if weightValuePair and weightValuePair.weight then
		weight = weightValuePair.weight
	else
		HVHDebugPrint("Missing relative probability for " .. weightValuePair.value)
	end
	return weight
end

-- Determines a random value by summing relative probabilities until it is >= to the probability value.
function HVHRandomizer:_GetValueForRandomProbability(probability)
	local probabilitySum = 0.0
	local randomValue = nil
	for index, weightValuePair in pairs(self._weightedValues) do
		probabilitySum = probabilitySum + self:_GetWeight(weightValuePair)
		if probabilitySum >= probability then
			randomValue = weightValuePair.value
			break
		end
	end

	return randomValue
end

