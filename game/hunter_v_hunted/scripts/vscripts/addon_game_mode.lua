
require('game_mode')
require('precache')
require('convars')

require("utils/class_utils")
require("utils/css_utils")
require("utils/time_utils")
require("utils/item_utils")
require("utils/hvh_utils")
require("item_spawn/item_spawn_controller")

require("hvh_settings")
require("hvh_constants")

require('lib/util')
require('lib/timers')
require('lib/physics')
require('lib/notifications')
require('lib/animations')
require('lib/popups')

require("internal/power_stages")
require("internal/tutorial")
require("internal/neutral_creeps")
require("internal/vision_dummy")
require("internal/force_cast")
require("internal/sniper_select")
require("internal/cycles")
require("internal/phoenix")

require("statcollection/init")
require('ai/ai_core')

-- If something was being created via script such as a new npc, it would need to be precached here
function Precache( context )

  for _,entry in pairs(PRECACHE_UNITS) do
    PrecacheUnitByNameSync(entry, context)
  end

  for _,entry in pairs(PRECACHE_ITEMS) do
    PrecacheItemByNameSync(entry, context)
  end

  for _,entry in pairs(PRECACHE_MODELS) do
    PrecacheResource("model", entry, context)
  end

  for _,entry in pairs(PRECACHE_MODEL_FOLDERS) do
    PrecacheResource("model_folder", entry, context)
  end

  for _,entry in pairs(PRECACHE_PARTICLES) do
    PrecacheResource("particle", entry, context)
  end

  for _,entry in pairs(PRECACHE_PARTICLE_FOLDERS) do
    PrecacheResource("particle_folder", entry, context)
  end

  for _,entry in pairs(PRECACHE_SOUNDFILES) do
    PrecacheResource("soundfile", entry, context)
  end

end

-- Create the game mode class when we activate
function Activate()
  HVHConvars:Setup()
	GameRules.HVHGameMode = HVHGameMode()
	GameRules.HVHGameMode:InitGameMode()

  --local courier = CreateUnitByName("npc_dota_courier", spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
  
end