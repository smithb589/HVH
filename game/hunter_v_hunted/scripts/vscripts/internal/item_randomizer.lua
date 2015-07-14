
require("hvh_utils")

if HVHRandomizer == nil then
	HVHRandomizer = {}
	HVHRandomizer.__index = HVHRandomizer
	setmetatable(HVHRandomizer, {
		__call = function (randomizer, ...)
			return randomizer.new(...)
		end,
	})
end

function HVHRandomizer.new(relativeProbabilityObjects)
	local self = setmetatable({}, HVHRandomizer)

	self._totalProbability = 0.0
	self._relativeProbabilities = relativeProbabilityObjects

	self._CalculateTotalProbability(self, relativeProbabilityObjects)
	--self:_CalculateIndividualProbabilities(relativeProbabilityObjects)
	return self
end

function HVHRandomizer:GetRandomValue()
	local randomFloat = RandomFloat(0.0, self._totalProbability)
	local randomValue = self:_GetValueForRandomProbability(randomFloat)
	return randomValue
end


function HVHRandomizer:_CalculateTotalProbability()
	local totalProbability = 0.0
	for index, objectProbabilityPair in pairs(self._relativeProbabilities) do
		local relativeProbability = self:_GetRelativeProbability(objectProbabilityPair)
		totalProbability = totalProbability + relativeProbability
		HVHDebugPrint(string.format("Adding probability %f for item " .. objectProbabilityPair.value, relativeProbability))
	end
	self._totalProbability = totalProbability
end

function HVHRandomizer:_GetRelativeProbability(objectProbabilityPair)
	local relativeProbability = 0.0
	if objectProbabilityPair and objectProbabilityPair.relativeProbability then
		relativeProbability = objectProbabilityPair.relativeProbability
	else
		HVHDebugPrint("Missing relative probability for " .. relativeProbability.value)
	end
	return relativeProbability
end

function HVHRandomizer:_GetValueForRandomProbability(probability)
	local probabilitySum = 0.0
	local randomValue = nil
	for index, objectProbabilityPair in pairs(self._relativeProbabilities) do
		probabilitySum = probabilitySum + self:_GetRelativeProbability(objectProbabilityPair)
		if probabilitySum >= probability then
			randomValue = objectProbabilityPair.value
			break
		end
	end

	return randomValue
end

