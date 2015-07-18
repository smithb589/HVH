
require("hvh_utils")

-- Hooks up the constructor call.
if HVHLocationCollection == nil then
	HVHLocationCollection = {}
	HVHLocationCollection.__index = HVHLocationCollection
	setmetatable(HVHLocationCollection, {
		__call = function (locationCollection, ...)
			return locationCollection.new(...)
		end,
	})
end

-- Constructor
function HVHLocationCollection.new(entityClassname, hvhClassname)
	local self = setmetatable({}, HVHLocationCollection)

	self._locations = {}

	self:_SetupLocations(entityClassname, hvhClassname)

	return self
end

function HVHLocationCollection:GetRandomLocations(numberOfLocations)
	local locationsClone = DeepCopy(self._locations)
	local randomLocations = {}

	-- This uses the clone to remove an item from the possible choices.
	for locationCounter=1,numberOfLocations do
		local randomLocationIndex = RandomInt(1, table.getn(locationsClone))
		local location = self._locations[randomLocationIndex]
		if location then
			table.insert(randomLocations, location)
		else
			HVHDebugPrint("No random locations.")
		end
		table.remove(locationsClone, randomLocationIndex)
	end

	return randomLocations
end

function HVHLocationCollection:_SetupLocations(entityClassname, hvhClassname)
	local entities = Entities:FindAllByClassname(entityClassname)
	HVHDebugPrint(string.format("Found %d entities to extract locations from.", table.getn(entities)))
	for _, entity in pairs(entities) do
		self:_AddEntityLocationIfRelevant(entity, hvhClassname)
	end
end

function HVHLocationCollection:_AddEntityLocationIfRelevant(entity, hvhClassname)
	if entity and hvhClassname and (entity.hvh_class == hvhClassname) then
		table.insert(self._locations, entity:GetAbsOrigin())
	elseif entity and not hvhClassname then
		table.insert(self._locations, entity:GetAbsOrigin())
	end
end