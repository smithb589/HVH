
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
			relativeProbability = value between .001 and 1000
		},
		{
			-- another
		}
	}
]]
function HVHRandomizer.new(relativeProbabilityObjects)
	local self = setmetatable({}, HVHRandomizer)

	self._totalProbability = 0.0
	self._relativeProbabilities = relativeProbabilityObjects

	self._CalculateTotalProbability(self, relativeProbabilityObjects)
	return self
end

-- Returns a random,
function HVHRandomizer:GetRandomValue()
	local randomFloat = RandomFloat(0.0, self._totalProbability)
	local randomValue = self:_GetValueForRandomProbability(randomFloat)
	HVHDebugPrint(string.format("Got value "..randomValue.." for float %f.", randomFloat))
	return randomValue
end

-- Determines the total probabilty to use for weighting.
function HVHRandomizer:_CalculateTotalProbability()
	local totalProbability = 0.0
	for index, objectProbabilityPair in pairs(self._relativeProbabilities) do
		local relativeProbability = self:_GetRelativeProbability(objectProbabilityPair)
		totalProbability = totalProbability + relativeProbability
		HVHDebugPrint(string.format("Adding probability %f for item " .. objectProbabilityPair.value, relativeProbability))
	end
	self._totalProbability = totalProbability
end

-- Extracts the relative probability from a value-probability paired object.
function HVHRandomizer:_GetRelativeProbability(objectProbabilityPair)
	local relativeProbability = 0.0
	if objectProbabilityPair and objectProbabilityPair.relativeProbability then
		relativeProbability = objectProbabilityPair.relativeProbability
	else
		HVHDebugPrint("Missing relative probability for " .. relativeProbability.value)
	end
	return relativeProbability
end

-- Determines a random value by summing relative probabilities until it is >= to the probability value.
function HVHRandomizer:_GetValueForRandomProbability(probability)
	local probabilitySum = 0.0
	local randomValue = nil
	for index, objectProbabilityPair in pairs(self._relativeProbabilities) do
		probabilitySum = probabilitySum + self:_GetRelativeProbability(objectProbabilityPair)
		-- TODO: probably need to make this a comparison with tolerance
		if probabilitySum >= probability then
			randomValue = objectProbabilityPair.value
			break
		end
	end

	return randomValue
end

