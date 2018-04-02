function ClampToRange(variable, lowerLimit, upperLimit)
  return math.max(math.min(variable, upperLimit), lowerLimit) 
end

function DebugSpeed(hero)
    local v = hero:GetPhysicsVelocity()
    local a = hero:GetPhysicsAcceleration()

    local vx = math.floor(v.x)
    local vy = math.floor(v.y)
    local vz = math.floor(v.z)

    local ax = math.floor(a.x)
    local ay = math.floor(a.y)
    local az = math.floor(a.z)
    
    print("Velocity: " .. vx .. " " .. vy .. " " .. vz ..
      ", Accel: " .. ax .. " " .. ay .. " " .. az) 

end