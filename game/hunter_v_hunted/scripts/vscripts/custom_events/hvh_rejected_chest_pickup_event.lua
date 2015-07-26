
require("custom_events/hvh_custom_event_constants")
require("custom_events/hvh_custom_event")

-- Hooks up the constructor call.
if HVHRejectedChestPickupEvent == nil then
    HVHRejectedChestPickupEvent = {}
    HVHRejectedChestPickupEvent.__index = HVHRejectedChestPickupEvent
    setmetatable(HVHRejectedChestPickupEvent, {
        __index = HVHCustomEvent
        __call = function (event, ...)
            local self = setmetatable({}, event)
            return self:new(...)
        end,
    })
end

function HVHRejectedChestPickupEvent.new()
    HVHCustomEvent.new(self, HVHCustomEventConstants.rejectedChestPickup)
    
end