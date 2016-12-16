function HVHGameMode:RegisterHostOptions()
  CustomGameEventManager:RegisterListener("load_host_options", Dynamic_Wrap(self, "LoadHostOptions"))
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(0), "save_host_options",{})
end

function HVHGameMode:LoadHostOptions(args)
  -- convert 1s and 0s to trues and falses
  for i,val in pairs(args) do
    if val == 0 then
      args[i] = false
    elseif val == 1 then
      args[i] = true
    end
  end

  HVHGameMode.HostOptions = {}
  if args["HostOptionsEnabled"] then
    HVHGameMode.HostOptions = args
  else
    HVHGameMode.HostOptions = nil
  end

  -- if host options are enabled and tutorial disabled, then set pregame time to 6.0
  if (HVHGameMode.HostOptions and not HVHGameMode.HostOptions["EnableTutorial"]) then
      GameRules:SetPreGameTime( 6.0 )
  end
end

function HVHGameMode:DisplayHostOptions()
  local HO = HVHGameMode.HostOptions
  if not HO then return end

  local f1 = "<font color='#99CCFF'>" -- blue
  local f2 = "<font color='#FCAF3D'>" -- yellow
  local fX = "</font>"

  local intro = f1.."<u>The host has enabled the following options:</u>"..fX
  local tut = f2.."Enable tutorial: "    ..fX..tostring(HO["EnableTutorial"])
  local ext = f2.."Spawn extra hounds: " ..fX..tostring(HO["SpawnExtraHounds"])
  local pop = f2.."Neutral creep population: "..fX..tostring(HO["NeutralCreeps"])
  local dis = f2.."Disable creeps: "     ..fX
  local min = f2.."Enable minimap: "     ..fX..tostring(HO["EnableMinimap"])
  local cam = f2.."Camera settings: "    ..fX..tostring(HO["CameraSettings"])

  local creepList = ""
  for key,value in pairs(HO) do
    if string.find(key, "Disable") and value then
      creepList = creepList .. string.gsub(key, "Disable", "") .. ", "
    end
  end
  dis = dis .. creepList

  --PrintTable(HVHGameMode.HostOptions)
  GameRules:SendCustomMessage(intro, 0, 0)

  if not HO["EnableTutorial"] then
    GameRules:SendCustomMessage(tut, 0, 0) end
  if HO["NeutralCreeps"] ~= "medium" then
    GameRules:SendCustomMessage(pop, 0, 0) end
  if creepList ~= "" then
    GameRules:SendCustomMessage(dis, 0, 0) end
  if not HO["SpawnExtraHounds"] then
    GameRules:SendCustomMessage(ext, 0, 0) end
  if not HO["EnableMinimap"] then 
    GameRules:SendCustomMessage(min, 0, 0) end
  if HO["CameraSettings"] ~= "default" then
    GameRules:SendCustomMessage(cam, 0, 0) end 
end

-- if host options allow, disable everybody's minimap
function HVHGameMode:DisableMinimapCheck()
  if not HVHGameMode.HostOptions["EnableMinimap"] then
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
      if PlayerResource:IsValidPlayerID(playerID) then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "disable_minimap",{})
      end
    end
  end
end