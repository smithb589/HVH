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