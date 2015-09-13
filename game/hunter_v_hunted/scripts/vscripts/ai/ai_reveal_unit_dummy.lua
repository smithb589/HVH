
require("hvh_utils")

function Spawn( entityKeyValues )

  thisEntity.SetTarget = function(self, target, duration)
    thisEntity._Target = target
    thisEntity._RevealDuration = duration
    HVHDebugPrint(string.format("%s is now following %s.", thisEntity:GetUnitName(), target:GetUnitName()))
  end

  thisEntity.HasTimeLeft = function(self)
    local hasTimeLeft = GameRules:GetGameTime() < (thisEntity._RevealBeginTime + thisEntity._RevealDuration)
    return hasTimeLeft
  end

  thisEntity.ResetDuration = function(self, newDuration)
    thisEntity._RevealBeginTime = GameRules:GetGameTime()
    thisEntity._RevealDuration = newDuration
  end

  thisEntity.MoveToRevealTarget = function(self)
    thisEntity:SetAbsOrigin(thisEntity._Target:GetAbsOrigin())
  end

  thisEntity.IsTargetValid = function(self)
    local targetValid = (thisEntity._Target ~= nil) and thisEntity._Target:IsAlive()
    return targetValid
  end

  thisEntity._Target = nil
  thisEntity._ThinkInterval = 0.03
  -- Defaulting this to a think interval to make sure we are able to receive a target and duration
  thisEntity._RevealDuration = thisEntity._ThinkInterval
  thisEntity._RevealBeginTime = GameRules:GetGameTime()

  thisEntity:SetContextThink("ThinkReavealUnitDummy", ThinkReavealUnitDummy, thisEntity._ThinkInterval)

  HVHDebugPrint(string.format("Starting AI for %s.", thisEntity:GetUnitName(), thisEntity:GetEntityIndex()))
end

function ThinkReavealUnitDummy()
  local nextThink = nil

  if thisEntity:HasTimeLeft() and thisEntity:IsTargetValid() then
    thisEntity:MoveToRevealTarget()
  else
    thisEntity:RemoveSelf()
  end

  return thisEntity._ThinkInterval
end