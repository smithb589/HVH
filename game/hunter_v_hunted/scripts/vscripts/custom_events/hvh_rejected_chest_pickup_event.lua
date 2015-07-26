
require("custom_events/hvh_custom_event")

-- Hooks up the constructor call.
if HVHRejectedChestPickupEvent == nil then
    HVHRejectedChestPickupEvent = {}
    HVHRejectedChestPickupEvent.__index = HVHRejectedChestPickupEvent
    setmetatable(HVHRejectedChestPickupEvent, {
        __index = HVHCustomEvent,
        __call = function (event, ...)
            local self = setmetatable({}, event)
            self:new(...)
            return self
        end,
    })
end

function HVHRejectedChestPickupEvent:new()
    HVHCustomEvent.new(self)
end

function HVHRejectedChestPickupEvent:ConvertToPayload()
    local payload = HVHCustomEvent:ConvertToPayload()

    payload.text = "You cannot pick up that type of chest."
    payload.style = { color = "red" }

    return payload
end