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
  local difference = vector1 - vector2
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

function HVHDebugPrint(...)
  local doPrint = Convars:GetInt("hvh_debug_output") or 0

  if doPrint == 1 then
    print(...)
  end
end

function HVHDebugPrintTable(...)
  local doPrint = Convars:GetInt('hvh_debug_output') or 0

  if doPrint == 1 then
    PrintTable(...)
  end
end