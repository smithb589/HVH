
require("hvh_constants")

function JoinTables(t1, t2)
  for k,v in ipairs(t2) do
    table.insert(t1, v)
  end

  return t1
end

function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function GetOwningHeroForIllusion(illusion)
  local player = illusion:GetPlayerOwner()
  return player:GetAssignedHero()
end

function IsEntityNightStalker(entity)
  local isNightStalker = false

  if entity ~= nil and entity:GetUnitName() == NIGHT_STALKER_UNIT_NAME and entity:IsRealHero() then
    isNightStalker = true
  end

  return isNightStalker
end

function IsEntityNightStalkerIllusion(entity)
  local isNightStalkerIllusion = false

  if entity ~= nil and entity:GetUnitName() == NIGHT_STALKER_UNIT_NAME and entity:IsIllusion() then
    isNightStalkerIllusion = true
  end  

  return isNightStalkerIllusion
end

function IsEntitySniper(entity)
  local isSniper = false

  if entity ~= nil and entity:GetUnitName() == SNIPER_UNIT_NAME and entity:IsRealHero() then
    isSniper = true
  end  

  return isSniper
end

function CompareFloats(float1, float2, tolerance)
    local difference = float1 - float2
    return (difference < tolerance) or (-difference < tolerance)
end

function AreVectorsEqualWithinTolerance(vector1, vector2, tolerance)
  local difference = vector1 - vector2
  local xWithinTolerance = CompareFloats(vector1.x, vector2.x, tolerance)
  local yWithinTolerance = CompareFloats(vector1.y, vector2.y, tolerance)
  local zWithinTolerance = CompareFloats(vector1.z, vector2.z, tolerance)
  return xWithinTolerance and yWithinTolerance and zWithinTolerance
end

function Length2DBetweenVectors(vector1, vector2)
  local difference = GetGroundPosition(vector1,nil) - GetGroundPosition(vector2,nil)
  return difference:Length2D()
end

-- Note that the array must be indexed by 1..n
function HVHShuffle(array)
  local numberOfItems = table.getn(array)

  -- Take all of the items and perform a Fisher–Yates shuffle
  for currentIndex=1,numberOfItems do
    local exchangeIndex = RandomInt(currentIndex, numberOfItems)
    local temp = array[currentIndex]
    array[currentIndex] = array[exchangeIndex]
    array[exchangeIndex] = temp
  end
  return array
end

function EntIndexToHScriptNillable(entIndex)
  local hScript = nil
  if entIndex then
    hScript = EntIndexToHScript(entIndex)
  end
  return hScript
end

function HVHAssert(value, message)
  if not value then
    print(message)
  end
end

function HVHDebugPrint(...)
  local doPrint = 0 --Convars:GetInt("hvh_debug_output") or 0

  if doPrint == 1 then
    print(...)
  end
end

function HVHDebugPrintVector(vectorName, vector)
  HVHDebugPrint(string.format("%s: <%f, %f, %f>", vectorName, vector.x, vector.y, vector.z))
end

function HVHDebugPrintTable(...)
  local doPrint = 0 --Convars:GetInt('hvh_debug_output') or 0

  if doPrint == 1 then
    PrintTable(...)
  end
end

function AddUnitToSelection( unit )
  --local player = unit:GetPlayerOwner()
  local player = unit:GetOwner() -- can't seem to set player owner of neutral creeps, but this works too
  --print(unit:GetUnitName() .. " added to selection for player " .. player:GetPlayerID())
  CustomGameEventManager:Send_ServerToPlayer(player, "add_to_selection", { ent_index = unit:GetEntityIndex() })
end