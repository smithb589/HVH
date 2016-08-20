function HVHGameMode:OnPlayerConnectFull()
	self:_SetupGameMode()
end

function HVHGameMode:OnGameRulesStateChange()
  state = GameRules:State_Get()
  if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
    HVHCycles:SetupCycleTimer()
  elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
    self:PostLoadPrecache()
    self:RegisterHostOptions()
    self:SetupInitialTeamSpawns()
    self:PushScoreToCustomNetTable()
    self:GlimpseFix()
  elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    self:DisplayHostOptions()
    self:WakeUpHeroes()
    self:SpawnStartingDogs()
    HVHCycles:SetupFastTime()
    HVHItemSpawnController:Setup()
    HVHPowerStages:Setup()
    HVHNeutralCreeps:Setup()
    HVHSniperSelect:Setup()
    HVHPhoenix:Setup()
  end
end

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

function HVHGameMode:OnPlayerPickHero(keys)
  local playerIndex = keys.player
  local player = EntIndexToHScript(playerIndex)
  local playerID = player:GetPlayerID()
  local heroUnitName = keys.hero
  --local heroIndex = keys.heroindex

  local team = player:GetTeam()
  -- Night Stalker starts as a forced sniper hero, so we need to replace him first
  if heroUnitName == "npc_dota_hero_sniper" and team == DOTA_TEAM_BADGUYS then
    local oldHero = player:GetAssignedHero()
    local newHero = PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_night_stalker", 0, 0)
    UTIL_Remove(oldHero)
  else  -- OnPlayerPickHero() is called twice for NS, and only once for Snipers
    Timers:CreateTimer(SINGLE_FRAME_TIME, function()
      local hero = player:GetAssignedHero()
      self:SetupHero(hero)
    end)

  end
end

function HVHGameMode:OnEntityKilled(killedArgs)
 	local unit = EntIndexToHScript(killedArgs.entindex_killed)
  local killer = EntIndexToHScript(killedArgs.entindex_attacker)

  if unit and unit:GetUnitName() == "npc_dota_good_guy_dog" then
    local mode = GameRules:GetGameModeEntity()
    mode.DeadHounds = mode.DeadHounds + 1 -- stat collection
    Timers:CreateTimer(HVHGameMode:GetRespawnTime(), function()
      HVHGameMode:SpawnDog(true)
    end)
  end
end

-- Overridden Valve items will not consume charges or get destroyed, even with ItemPermanent "0". This fixes that problem.
-- BUG: This will BREAK existing charged items
function HVHGameMode:OnAbilityUsed(keys)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
  local hero = player:GetAssignedHero() -- BUG: won't work for using charged items on secondary heroes/creeps

  -- don't waste our time on non-item abilities
  if not hero:HasItemInInventory(abilityName) then
      --print(abilityName .. " not found in " .. hero:GetName() .. "'s inventory.")
      return
  end

  -- BUG: Won't this always use the first item in the inventory rather than the one that was actually cast?
  -- Check all 6 item slots for items with charges that match abilityName, then expend the charge
  for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
    local item = hero:GetItemInSlot(i)
    if item ~= nil and HVHItemUtils:IsChargedItem(item) then
      local itemName = item:GetName()
      if itemName == abilityName then
        HVHItemUtils:ExpendCharge(item)
        break
      end
    end
  end
end