-- at the beginning of the game, set random team spawn points
-- each info_courier_spawn_radiant entity has an attribute value "id"
-- each info_courier_spawn_dire has a matching "id" value, and it's positioned on the opposite side of map
function HVHGameMode:SetupInitialTeamSpawns()
  local ggSpawns = Entities:FindAllByClassname("info_courier_spawn_radiant")
  local bgSpawns = Entities:FindAllByClassname("info_courier_spawn_dire")

  local ggSpawn = self:GetRandomTeamSpawn()
  local bgSpawn = self:GetMatchingTeamSpawn(ggSpawn)
  
  -- save both spawn points to be accessed by SetupHero() and dog spawning
  local mode = GameRules:GetGameModeEntity()
  mode.GoodGuyTeamSpawn = ggSpawn:GetAbsOrigin()
  mode.BadGuyTeamSpawn  = bgSpawn:GetAbsOrigin()
end

-- choose a random spawn point for team good guys
function HVHGameMode:GetRandomTeamSpawn()
  local ggSpawns = Entities:FindAllByClassname("info_courier_spawn_radiant")
  local r = RandomInt(1, #ggSpawns)
  local ggSpawn = ggSpawns[r]
  return ggSpawn
end

-- find the spawn point's matching bad guy brother
function HVHGameMode:GetMatchingTeamSpawn(ggSpawn)
  local ggSpawnID = ggSpawn:Attribute_GetIntValue("id", 0)
  local bgSpawns = Entities:FindAllByClassname("info_courier_spawn_dire")
  local bgSpawnID = nil
  for _,bgSpawn in pairs(bgSpawns) do
    bgSpawnID = bgSpawn:Attribute_GetIntValue("id", 0)
    if bgSpawnID == ggSpawnID then
      return bgSpawn
    end
  end
end

-- return the position of a random valid spawner
-- a valid spawner has no enemy units or heroes within MINIMUM_RESPAWN_RANGE
-- if no valid spawners are found, fallback on any possible spawner
function HVHGameMode:ChooseFarSpawn(team)
  local possibleSpawners = nil
  local oppositeTeam = nil
  if team == DOTA_TEAM_GOODGUYS then
    possibleSpawners = Entities:FindAllByClassname("info_player_start_goodguys")
    oppositeTeam = DOTA_TEAM_BADGUYS
  else
    possibleSpawners = Entities:FindAllByClassname("info_player_start_badguys")
    oppositeTeam = DOTA_TEAM_GOODGUYS
  end

  local validSpawners = {}
  local leastWorstSpawner = nil
  local leastWorstSpawnerDistance = 0
  for n,spawner in pairs(possibleSpawners) do

    -- find enemy heroes in radius around the spawner
    local position = spawner:GetAbsOrigin()
    local units = FindUnitsInRadius(oppositeTeam,
                  position,
                  nil,
                  MINIMUM_RESPAWN_RANGE,
                  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                  DOTA_UNIT_TARGET_HERO,
                  DOTA_UNIT_TARGET_FLAG_INVULNERABLE, -- doesn't seem to work
                  FIND_CLOSEST,
                  false)

    -- TODO: if we're NS, also find dogs around the spawner and add them to previous units table
    -- table must then be sorted by closeness

    -- if no units found in radius, the spawner is Valid
    if units[1] == nil then
      table.insert(validSpawners, spawner)
      --print(n .. ": No units found in radius.")

    -- otherwise, check if this spawner is the least worst one we've come across
    else
      closestUnitDistance = (units[1]:GetAbsOrigin() - position):Length2D()
      if closestUnitDistance > leastWorstSpawnerDistance then
        leastWorstSpawnerDistance = closestUnitDistance
        leastWorstSpawner = spawner
      end
      --[[
      local nameList = ""
      for _,unit in pairs(units) do
        nameList = unit:GetName() .. ", " .. nameList
      end
      print("Spawner #" .. n .. ": " .. #units .. " units found in radius: " .. nameList)
      --]]
    end
  end

  --print("# of Valid/Possible Spawners: " .. #validSpawners .. " / " .. #possibleSpawners)
  local spawnPoint = nil
  if validSpawners[1] ~= nil then
    local r = RandomInt(1, #validSpawners)
    spawnPoint = validSpawners[r]:GetAbsOrigin()
  else -- fallback
    spawnPoint = leastWorstSpawner:GetAbsOrigin()
  end

  return spawnPoint
end

function HVHGameMode:DetermineRespawn(unit)
  local team = unit:GetTeam()
  local respawnTime = self:GetRespawnTime(unit)
  unit:SetTimeUntilRespawn(respawnTime)

  Timers:CreateTimer(respawnTime - 1.0, function() 
    local pos = HVHGameMode:ChooseFarSpawn(team)
    unit:SetRespawnPosition(pos)
  end)

  if team == DOTA_TEAM_GOODGUYS then
    Timers:CreateTimer(respawnTime, function() 
      HVHParadropper:Begin(unit)
    end)
  end
end

-- random time between MIN and MAX
function HVHGameMode:GetRespawnTime(unit)
  local unit = unit or nil
  local disconnectPenalty = 0

  if unit then 
    local player = unit:GetPlayerOwner()
    if player and PlayerResource:GetConnectionState(player:GetPlayerID()) == CONNECTION_STATE_DISCONNECTED then
      disconnectPenalty = DC_RESPAWN_EXTRA_TIME
    end
  end

  return RandomInt(MIN_RESPAWN_TIME, MAX_RESPAWN_TIME) + disconnectPenalty
end

-------------------------------------------------------------------
-- Dog spawning
-------------------------------------------------------------------
function HVHGameMode:SpawnStartingDogs()
  local missingSnipers = GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS) -
    PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
  
  -- (optional) add a hound for each missing sniper player
  local spawnExtraHounds = false
  if HVHGameMode.HostOptions then
    spawnExtraHounds = HVHGameMode.HostOptions["SpawnExtraHounds"]
  else
    spawnExtraHounds = not DISABLE_BONUS_DOGS
  end

  if spawnExtraHounds then
    while missingSnipers > 0 do
      self:SpawnDog(false)
      missingSnipers = missingSnipers - 1
    end
  end

  -- always add the main hound
  self:SpawnDog(false)
end

-- spawn the dog at the radiant courier spawn (game start) or a random good guy spawner
function HVHGameMode:SpawnDog(random_spawn)
  if DISABLE_DOGS then return end

  local position = nil
  if random_spawn then
    position = HVHGameMode:ChooseFarSpawn(DOTA_TEAM_GOODGUYS)
  else
    local mode = GameRules:GetGameModeEntity()
    position = mode.GoodGuyTeamSpawn
  end
 
  -- create the dog with a random dog model
  local dog = CreateUnitByName("npc_dota_good_guy_dog", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
  --Timers:CreateTimer(0.06, function() 
  local r = RandomInt(1, #HOUND_MODEL_PATHS)
  dog:SetOriginalModel(HOUND_MODEL_PATHS[r])
  --end)

  if random_spawn then 
    HVHParadropper:Begin(dog)
  end
end

