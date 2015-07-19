
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
	local shuffledLocations = self:_GetShuffledLocations()
	if numberOfLocations > table.getn(shuffledLocations) then
		numberOfLocations = table.getn(shuffledLocations)
		HVHDebugPrint("Attempted to get more random locations than existed.")
	end

	local randomLocations = self:_GetFirstNLocations(shuffledLocations, numberOfLocations)
	--HVHDebugPrint(string.format("Created %d random locations:", numberOfLocations))
	--HVHDebugPrintTable(randomLocations)
	return randomLocations
end

function HVHLocationCollection:GetNearestLocation(queryLocation)
	local nearestLocation = nil
	local nearestDistance = 99999

	for _,storedLocation in pairs(self._locations) do
		local currentDistance = Length2DBetweenVectors(storedLocation, queryLocation)

		if currentDistance < nearestDistance then
			nearestLocation = storedLocation
			nearestDistance = currentDistance
		end
	end

	return nearestLocation
end

function HVHLocationCollection:_GetShuffledLocations()
	local locationsClone = DeepCopy(self._locations)
	local numberOfLocations = table.getn(locationsClone)

	-- Take all of the locations and perform a Fisher–Yates shuffle
	for currentIndex=1,numberOfLocations do
		local exchangeIndex = RandomInt(currentIndex, numberOfLocations)
		local temp = locationsClone[currentIndex]
		locationsClone[currentIndex] = locationsClone[exchangeIndex]
		locationsClone[exchangeIndex] = temp
	end

	return locationsClone
end

function HVHLocationCollection:_GetFirstNLocations(locations, n)
	local nLocations = {}
	for locationCounter=1,n do
		table.insert(nLocations, locations[locationCounter])
	end

	return nLocations
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