function HVHGameMode:OnPlayerConnectFull()
	self:SetupGameMode()
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
  elseif state == DOTA_GAMERULES_STATE_WAIT_FOR_MAP_TO_LOAD then
    --
  elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
    self:DisableMinimapCheck()
  elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    self:StartTeamAbandonmentListener(DOTA_TEAM_GOODGUYS)
    self:StartTeamAbandonmentListener(DOTA_TEAM_BADGUYS)
    self:BackpackDisabler()
    self:DisplayHostOptions()
    self:SpawnStartingDogs()
    HVHTutorial:WakeUpHeroes()
    HVHCycles:SetupFastTime()
    HVHItemSpawnController:Setup()
    HVHPowerStages:Setup()
    HVHNeutralCreeps:Setup()
    HVHSniperSelect:Setup()
    HVHPhoenix:Setup()
  end
end

function HVHGameMode:DeclareWinner(team)
  GameRules:SetSafeToLeave( true )
  HVHPowerStages:NotifyVictory( team )
  GameRules:SetGameWinner( team )
end

function HVHGameMode:DecrementDisconnectTimeRemaining(seconds, losingTeam)
  local mode = GameRules:GetGameModeEntity()
  mode.DisconnectTimeRemaining = mode.DisconnectTimeRemaining - seconds
  if mode.DisconnectTimeRemaining <= 0.0 then
    self:DeclareWinner(GetOppositeTeam(losingTeam))
  else
    --print(mode.DisconnectTimeRemaining .. " seconds remaining on the DC clock.")
    local msg = "Enemy team disconnected. Your team will be victorious in " .. mode.DisconnectTimeRemaining .. " seconds."
    GameRules:SendCustomMessage(msg, 0, 0)
  end
end

function HVHGameMode:StartTeamAbandonmentListener(team)
  local checkEvery = 5.0
  Timers:CreateTimer(function()
    local teamTotal = PlayerResource:GetPlayerCountForTeam(team)
    local teamConnected = 0
    for i = 1, teamTotal do
      local playerID = PlayerResource:GetNthPlayerIDOnTeam(team, i)
      local state = PlayerResource:GetConnectionState(playerID) 
      if state == CONNECTION_STATE_BOT or state == CONNECTION_STATE_PLAYER then
        teamConnected = teamConnected + 1
      end
      --print("T"..team.." " .. PlayerResource:GetPlayerName(playerID) .. " ID: " .. playerID .. ", ConnState: " .. state)
    end

    --  (intentional!) 0/0 can happen in single-player so there's no auto-quit
    if teamTotal ~= 0 and (teamConnected / teamTotal) == 0 then
      --print("T"..team.." players all DISCONNECTED.")
      self:DecrementDisconnectTimeRemaining(checkEvery, team)
    else
      --print("T"..team.." players connected: "..teamConnected.."/"..teamTotal)
    end

    return checkEvery
  end)
end

-- triggers after hero is force picked, or fake heroes are made
-- will keep repeating until successful
function HVHGameMode:OnPlayerPickHero(keys)
  local player = EntIndexToHScript(keys.player)
  local playerID = player:GetPlayerID()
  --local heroUnitName = keys.hero
  --local heroIndex = keys.heroindex

  Timers:CreateTimer(function()
    local successfulHeroSetup = self:AttemptToReplaceAndSetupHeroForPlayer(player)
    if successfulHeroSetup then
      return false -- end loop
    else
      return 0.1 -- try again in 0.1 sec
    end
  end)
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