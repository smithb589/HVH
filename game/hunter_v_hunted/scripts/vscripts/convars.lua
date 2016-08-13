if HVHConvars == nil then
  HVHConvars = class({})
end

require("hvh_constants")
require("internal/convars")
require("item_spawn/item_spawn_controller")

function HVHConvars:Setup()
	--self:RegisterConvars()
	self:RegisterCommands()
end

function HVHConvars:RegisterConvars()
	-- Register custom console variables here.
  	local debugOutput = 0
  	if HVH_DEBUG_OUTPUT then
  		debugOutput = 1
  	end

  	--Convars:RegisterConvar("hvh_debug_output", tostring(debugOutput), "Set to 1 for debug output. Default: 0", FCVAR_CHEAT)
end


function HVHConvars:RegisterCommands()
	-- Register custom console command handlers here.

  	-- this is already built into the engine
  	--Convars:RegisterCommand( "set_time_of_day", Dynamic_Wrap(self, 'ConvarSetTimeOfDay'), "Sets the time of day to the indicated value.", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_spawn_all_items", Dynamic_Wrap(self, 'SpawnAllItems'), "Spawn all custom items near the hero's feet", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_spawn_dog", Dynamic_Wrap(self, 'SpawnDog'), "Spawn a new Hound at a random spawn point", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_fake_heroes", Dynamic_Wrap(self, 'FakeHeroes'), "Spawn heroes to fill in missing players.", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_chest_probabilties", Dynamic_Wrap(self, 'DisplayChestProbabilties'), "Outputs item drop probabilities.", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_test_item_cycle", Dynamic_Wrap(self, "DisplayTestItemSpawnCycle"), "Runs a test cycle displaying items.", FCVAR_CHEAT)
    Convars:RegisterCommand("hvh_spawn_creeps", Dynamic_Wrap(self, "SpawnCreeps"), "Spawns creeps.", FCVAR_CHEAT)
    Convars:RegisterCommand("hvh_spawn_wards", Dynamic_Wrap(self, "SpawnWards"), "Spawns wards.", FCVAR_CHEAT)
    Convars:RegisterCommand("hvh_test_anim", Dynamic_Wrap(self, "TestAnimation"), "Tests animation.", FCVAR_CHEAT)
    Convars:RegisterCommand("hvh_team_swap", Dynamic_Wrap(self, "TeamSwap"), "Swaps team.", FCVAR_CHEAT)
end

-- ability level issues
-- scoreboard and topboard issues
function HVHConvars:TeamSwap()
  local humanPlayer = Convars:GetCommandClient()
  local hero = humanPlayer:GetAssignedHero()
  local team = hero:GetTeamNumber()
  local newTeam = ""

  if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
    newTeam = DOTA_TEAM_BADGUYS
  else
    newTeam = DOTA_TEAM_GOODGUYS
  end

  print("Swapping team")

  print("Before: GG " .. GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS) ..
    " and BG " .. GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS) )

  GameRules:SetCustomGameTeamMaxPlayers(newTeam, GameRules:GetCustomGameTeamMaxPlayers(newTeam) + 1)
  humanPlayer:SetTeam(newTeam)
  hero:SetOwner(humanPlayer)
  hero:SetControllableByPlayer(humanPlayer:GetPlayerID(), false)
  hero:SetTeam(newTeam)
  hero:ForceKill(false)
  GameRules:SetCustomGameTeamMaxPlayers(team, GameRules:GetCustomGameTeamMaxPlayers(team) - 1)

  print("After: GG " .. GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS) ..
    " and BG " .. GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS) )
end

function HVHConvars:TestAnimation()
  local humanPlayer = Convars:GetCommandClient()
  local hero = humanPlayer:GetAssignedHero()

  print("Test anim!!")
  StartAnimation(hero, {duration=1.0, activity=ACT_DOTA_ATTACK, rate=1.0})
  hero:EmitSound("Lycan_Wolf.PreAttack")
end

function HVHConvars:SpawnWards()
  local humanPlayer = Convars:GetCommandClient()
  local humanPlayerID = humanPlayer:GetPlayerID()
  local team = PlayerResource:GetTeam(humanPlayerID)

  local masterList = AICore:GetAllPointsOfInterest()

  for _,entity in pairs(masterList) do
    local pos = entity:GetAbsOrigin()
    local dummy = CreateUnitByName("npc_dummy_ward", pos, true, nil, nil, team)
    --local ward = CreateUnitByName("npc_dota_observer_wards", pos, true, nil, nil, team)
    --ward:AddNewModifier(ward, nil, "modifier_invisible", {})
    --ward:AddAbility("dummy_truesight_immune")
  end
end

function HVHConvars:SpawnCreeps()
  HVHNeutralCreeps:SpawnCreepsConvar()
end

function HVHConvars:SpawnDog()
  HVHGameMode:SpawnDog(true)
end

function HVHConvars:FakeHeroes()
  local empty_gg = CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) 
  local empty_bg = CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  - PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)
  local humanPlayer = Convars:GetCommandClient()
  local humanPlayerID = humanPlayer:GetPlayerID()

  -- spawn missing good guys
  while empty_gg ~= 0 do
    --local spawner = HVHGameMode:ChooseRandomSpawn("info_player_start_goodguys")
    --local position = spawner:GetAbsOrigin()
    --local hero = CreateUnitByName("npc_dota_hero_sniper", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
    local msg = "dota_create_unit npc_dota_hero_sniper"
    if PlayerResource:GetTeam(humanPlayerID) ~= DOTA_TEAM_GOODGUYS then
      msg = msg .. " enemy"
    end
     SendToServerConsole(msg)
    empty_gg = empty_gg - 1
  end

  -- spawn missing bad guys
  while empty_bg ~= 0 do
    local msg = "dota_create_unit npc_dota_hero_night_stalker"
    if PlayerResource:GetTeam(humanPlayerID) ~= DOTA_TEAM_BADGUYS then
      msg = msg .. " enemy"
    end
    SendToServerConsole(msg)
    empty_bg = empty_bg - 1
  end

end

function HVHConvars:SpawnAllItems()
  local itemsKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  local humanPlayer = Convars:GetCommandClient()
  local hero = humanPlayer:GetAssignedHero()
  local pos = hero:GetAbsOrigin()

  -- alphabetical sort
  local sortedItems = {}
  for item in pairs(itemsKV) do
    table.insert(sortedItems, item)
  end
  table.sort(sortedItems)

  local MAX_X = 600
  local INC_X = 50
  local INC_Y = -50
  local original_x = pos.x

  for _,item in pairs(sortedItems) do
    HVHItemUtils:SpawnItem(item, pos)
    if (pos.x - original_x > MAX_X) then
      pos.x = original_x
      pos.y = pos.y + INC_Y
    else
      pos.x = pos.x + INC_X
    end
  end
end

function HVHConvars:DisplayChestProbabilties()
  HVHItemSpawnController:DisplayChestProbabilties()
end

function HVHConvars:DisplayTestItemSpawnCycle()
  HVHItemSpawnController:RunTestCycle()
end