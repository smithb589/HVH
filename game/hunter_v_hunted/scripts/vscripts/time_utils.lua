require("hvh_settings")

if HVHTimeUtils == nil then
  HVHTimeUtils = class({})
end

MINS_PER_CYCLE         = 8 -- standard minutes in a combined day/night cycle
SECS_PER_CYCLE         = MINS_PER_CYCLE * 60
TIME_OF_DAY_PER_SECOND = 1 / SECS_PER_CYCLE

EXTRA_FLOAT_TIME_PER_SECOND = TIME_OF_DAY_PER_SECOND * (DAY_NIGHT_CYCLE_MULTIPLIER - 1) -- add this to SetTimeOfDay

-- GetTimeOfDay() is expressed as a float from 0.0 to 1.0, where ~0.25 is sunrise and ~0.75 is sunset
TIME_NEXT_DAWN    = 0.25
TIME_NEXT_EVENING = 0.75

function HVHTimeUtils:GetSecondsUntil(time_const)
  local floatTimePerSecond = TIME_OF_DAY_PER_SECOND + EXTRA_FLOAT_TIME_PER_SECOND
  local currentTime = GameRules:GetTimeOfDay()

  local timeUntil = 0
  if currentTime < time_const then
    timeUntil = time_const - currentTime
  else
    timeUntil = (1 - currentTime) + time_const
  end

  local minsTil = (timeUntil * MINS_PER_CYCLE) / DAY_NIGHT_CYCLE_MULTIPLIER
  local secsTil = minsTil * 60
  --print("Time Until Next Dawn: " .. secsTil .. " ( or " .. minsTil .. " minutes) " .. timeUntilDawn)
  return secsTil
end

function HVHTimeUtils:GetRespawnTime(team)
  local next_time = 0

  if team == DOTA_TEAM_GOODGUYS then
    next_time = self:GetSecondsUntil(TIME_NEXT_DAWN)
  else
    next_time = self:GetSecondsUntil(TIME_NEXT_EVENING)
  end

  --print("next_time: " .. next_time .. " and MIN_RESPAWN_TIME: " .. MIN_RESPAWN_TIME)
  if next_time <= MIN_RESPAWN_TIME then
    return MIN_RESPAWN_TIME
  else
    return next_time
  end
end