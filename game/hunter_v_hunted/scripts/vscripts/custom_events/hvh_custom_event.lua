
-- Hooks up the constructor call.
if HVHCustomEvent == nil then
    HVHCustomEvent = {}
    HVHCustomEvent.__index = HVHCustomEvent
    setmetatable(HVHCustomEvent, {
        __call = function (event, ...)
            local self = setmetatable({}, event)
            self:new(...)
            return self
        end
    })
end

function HVHCustomEvent:new()
    --self._eventName = eventName
end

--[[
function HVHCustomEvent:GetEventName()
    return self._eventName
end]]

function HVHCustomEvent:ConvertToPayload()
    return { continue = true }
end