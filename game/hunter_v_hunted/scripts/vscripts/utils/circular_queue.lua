
require("utils/hvh_utils")

-- Hooks up the constructor call.
if HVHCircularQueue == nil then
  HVHCircularQueue = {}
  HVHCircularQueue.__index = HVHCircularQueue
  setmetatable(HVHCircularQueue, {
    __call = function (newQueue, ...)
      return newQueue.new(...)
    end,
  })
end

function HVHCircularQueue.new(queueSize)
  local self = setmetatable({}, HVHCircularQueue)
  self._storedValues = {}
  self._oldestStoredValueIndex = 1
  self._nextStoreIndex = 1
  if queueSize < 2 then
    HVHDebugPrint("Attempted to create a circular queue with size less than 2.")
  end
  self._queueSize = queueSize
  return self
end

function HVHCircularQueue:IsEmpty()
  return self._nextStoreIndex == self._oldestStoredValueIndex
end

function HVHCircularQueue:GetCount()
  -- Assume next is equal to oldest (i.e. empty)
  local count = 0

  if self._oldestStoredValueIndex < self._nextStoreIndex then
    count = self._nextStoreIndex - self._oldestStoredValueIndex
  elseif self._nextStoreIndex < self._oldestStoredValueIndex then
    count = self._queueSize - self._oldestStoredValueIndex + self._nextStoreIndex
  end

  return count
end

function HVHCircularQueue:Store(value)
  self._storedValues[self._nextStoreIndex] = value
  self._nextStoreIndex = self:_GetNextQueueIndex(self._nextStoreIndex)
end

function HVHCircularQueue:Peek()
  value = self._storedValues[self._oldestStoredValueIndex]
  return value
end

function HVHCircularQueue:Pop()
  local value = self._storedValues[self._oldestStoredValueIndex]
  self:_AdvanceOldestStoredValue()
  return value
end

function HVHCircularQueue:_AdvanceOldestStoredValue()
  if self._oldestStoredValueIndex ~= self._nextStoreIndex then
    self._oldestStoredValueIndex = self:_GetNextQueueIndex(self._oldestStoredValueIndex)
  end
end

function HVHCircularQueue:_GetNextQueueIndex(currentIndex)
  local nextIndex = currentIndex + 1
  if nextIndex > self._queueSize then
    nextIndex = 1
  end
  return nextIndex
end

