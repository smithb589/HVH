-- Create the class for the game mode, unused in this example as the functions for the quest are global
if HVHGameMode == nil then
  HVHGameMode = class({})
end

require("lib/timers")

require("internal/game_mode")
require("internal/event_handlers")

-- Begins processing script for the custom game mode.  This "template_example" contains a main OnThink function.
function HVHGameMode:InitGameMode()
  self:_InitGameMode()

	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(self, 'OnPlayerPickHero'), self)

	print("Hunter v Hunted loaded.")
end
