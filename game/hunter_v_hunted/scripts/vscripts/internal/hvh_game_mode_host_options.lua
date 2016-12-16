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

  local f1 = "<font color='#99CCFF'>" -- blue
  local f2 = "<font color='#FCAF3D'>" -- yellow
  local fX = "</font>"

  local intro = f1.."<u>The host has enabled the following options:</u>"..fX
  local tut = f2.."Enable tutorial: "    ..fX..tostring(HO["EnableTutorial"])
  local ext = f2.."Spawn extra hounds: " ..fX..tostring(HO["SpawnExtraHounds"])
  local pop = f2.."Neutral creep population: "..fX..tostring(HO["NeutralCreeps"])
  local dis = f2.."Disable creeps: "     ..fX

  for key,value in pairs(HO) do
    if string.find(key, "Disable") and value then
      dis = dis .. string.gsub(key, "Disable", "") .. ", "
    end
  end

  --PrintTable(HVHGameMode.HostOptions)
  GameRules:SendCustomMessage(intro, 0, 0)
  GameRules:SendCustomMessage(tut, 0, 0)
  GameRules:SendCustomMessage(pop, 0, 0)
  GameRules:SendCustomMessage(dis, 0, 0)
  GameRules:SendCustomMessage(ext, 0, 0)
end