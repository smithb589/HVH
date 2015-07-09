require("hvh_settings")

if HVHTimerUtils == nil then
  HVHTimerUtils = class({})
end

MINS_PER_CYCLE         = 8 -- standard minutes in a combined day/night cycle
SECS_PER_CYCLE         = MINS_PER_CYCLE * 60
TIME_OF_DAY_PER_SECOND = 1 / SECS_PER_CYCLE

EXTRA_FLOAT_TIME_PER_SECOND = TIME_OF_DAY_PER_SECOND * (DAY_NIGHT_CYCLE_MULTIPLIER - 1) -- add this to SetTimeOfDay

-- GetTimeOfDay() is expressed as a float from 0.0 to 1.0, where ~0.25 is sunrise and ~0.75 is sunset
DAWN_TIME    = 0.25
EVENING_TIME = 0.75

function HVHTimerUtils:GetSecondsUntilNextDawn()
  local floatTimePerSecond = TIME_OF_DAY_PER_SECOND + EXTRA_FLOAT_TIME_PER_SECOND
  local currentTime = GameRules:GetTimeOfDay()

  local timeUntilDawn = 0
  if currentTime < DAWN_TIME then
    timeUntilDawn = DAWN_TIME - currentTime
  else
    timeUntilDawn = (1 - currentTime) + DAWN_TIME
  end

  local minsTilDawn = (timeUntilDawn * MINS_PER_CYCLE) / DAY_NIGHT_CYCLE_MULTIPLIER
  local secsTilDawn = minsTilDawn * 60
  --print("Time Until Next Dawn: " .. secsTilDawn .. " ( or " .. minsTilDawn .. " minutes) " .. timeUntilDawn)
  return secsTilDawn
end