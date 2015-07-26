
-- Hooks up the constructor call.
if HVHCustomEvent == nil then
    HVHCustomEvent = {}
    HVHCustomEvent.__index = HVHCustomEvent
    setmetatable(HVHCustomEvent, {
        __call = function (event, ...)
            local self = setmetatable({}, event)
            return self:new(...)
        end
    })
end

function HVHCustomEvent:new(eventID)
    self._eventID = eventID
end

function HVHCustomEvent:GetEventID()
    return self._eventID
end