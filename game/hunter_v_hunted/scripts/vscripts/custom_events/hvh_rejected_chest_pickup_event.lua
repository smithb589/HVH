
require("custom_events/hvh_custom_event")

-- Hooks up the constructor call.
if HVHRejectedChestPickupEvent == nil then
  HVHRejectedChestPickupEvent = {}

  HVHRejectedChestPickupEvent.RejectReason_NoInventory = 1
  HVHRejectedChestPickupEvent.RejectReason_WrongTeam = 2

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

function HVHRejectedChestPickupEvent:new(rejectReason)
  HVHCustomEvent.new(self)
  self._rejectReason = rejectReason
end

function HVHRejectedChestPickupEvent:ConvertToPayload()
  local payload = HVHCustomEvent:ConvertToPayload()

  payload.text = self:_GetRejectReasonText()
  payload.style = { color = "red" }

  return payload
end

function HVHRejectedChestPickupEvent:_GetRejectReasonText()
  local rejectReasonText = ""

  if self._rejectReason == HVHRejectedChestPickupEvent.RejectReason_WrongTeam then
    rejectReasonText = "#ChestReject_WrongTeam"
  elseif self._rejectReason == HVHRejectedChestPickupEvent.RejectReason_NoInventory then
    rejectReasonText = "#ChestReject_NoInventory"
  end

  return rejectReasonText
end