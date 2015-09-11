if HVHConvars == nil then
  HVHConvars = class({})
end

require("internal/convars")
require("../hvh_constants")
require("item_spawn_controller")

function HVHConvars:Setup()
	self:RegisterConvars()
	self:RegisterCommands()
end

function HVHConvars:RegisterConvars()
	-- Register custom console variables here.
  	local debugOutput = 0
  	if HVH_DEBUG_OUTPUT then
  		debugOutput = 1
  	end

  	Convars:RegisterConvar("hvh_debug_output", tostring(debugOutput), "Set to 1 for debug output. Default: 0", FCVAR_CHEAT)
end


function HVHConvars:RegisterCommands()
	-- Register custom console command handlers here.

  	-- this is already built into the engine
  	--Convars:RegisterCommand( "set_time_of_day", Dynamic_Wrap(self, 'ConvarSetTimeOfDay'), "Sets the time of day to the indicated value.", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_spawn_dog", Dynamic_Wrap(self, 'SpawnDog'), "Spawn a new Hound at a random spawn point", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_fake_heroes", Dynamic_Wrap(self, 'FakeHeroes'), "Spawn heroes to fill in missing players.", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_chest_probabilties", Dynamic_Wrap(self, 'DisplayChestProbabilties'), "Outputs item drop probabilities.", FCVAR_CHEAT )
    Convars:RegisterCommand("hvh_test_item_cycle", Dynamic_Wrap(self, "DisplayTestItemSpawnCycle"), "Runs a test cycle displaying items.", FCVAR_CHEAT)
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

function HVHConvars:DisplayChestProbabilties()
  HVHItemSpawnController:DisplayChestProbabilties()
end

function HVHConvars:DisplayTestItemSpawnCycle()
  HVHItemSpawnController:RunTestCycle()
end