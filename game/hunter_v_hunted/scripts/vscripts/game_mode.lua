-- Create the class for the game mode, unused in this example as the functions for the quest are global
if HVHGameMode == nil then
  HVHGameMode = class({})
end

require("internal/hvh_game_mode")
require("internal/event_handlers")
require("convars")

require("item_utils")
require("item_spawn_controller")

-- Begins processing script for the custom game mode.  This "template_example" contains a main OnThink function.
function HVHGameMode:InitGameMode()
	self:_InitGameMode()
	HVHConvars:Setup()
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'OnPlayerPickHero'), self)

	HVHItemSpawnController:Setup()

	
	local spawner = Entities:FindByName(nil, "RadiantCourierSpawner")
	local position = spawner:GetAbsOrigin()
	CreateUnitByName("npc_dota_good_guy_dog", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_good_guy_dog", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
	CreateUnitByName("npc_dota_good_guy_dog", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
	
	
	print("Hunter v Hunted loaded.")
end
