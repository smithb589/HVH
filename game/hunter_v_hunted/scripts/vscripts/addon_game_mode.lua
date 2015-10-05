
require('game_mode')
require('precache')
require('convars')

require("time_utils")
require("item_utils")
require("item_spawn_controller")

require("hvh_settings")
require("hvh_utils")
require("hvh_constants")

require('lib/util')
require('lib/timers')
require('lib/physics')
require('lib/notifications')
require('lib/animations')

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