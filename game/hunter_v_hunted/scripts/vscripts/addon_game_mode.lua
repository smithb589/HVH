-- Sample adventure script

require('game_mode')

require('lib/util')
require('lib/timers')
require('lib/physics')

-- If something was being created via script such as a new npc, it would need to be precached here
function Precache( context )
  --[[
    Precache things we know we'll use.  Possible file types include (but not limited to):
      PrecacheResource( "model", "*.vmdl", context )
      PrecacheResource( "soundfile", "*.vsndevts", context )
      PrecacheResource( "particle", "*.vpcf", context )
      PrecacheResource( "particle_folder", "particles/folder", context )
  ]]

  -- [ W ResourceSystem ]: File error loading resource header "particles/reftononexistentsystem/cannotfindremap/nightstalker_black_nihility_void_cast.vpcf_c" (Error: ERROR_FILEOPEN)
  -- [ W ResourceSystem ]: WARNING: RESOURCE_TYPE_MATERIAL resource 'materials/vgui/hud/heroportraits/portraitbackground_moon.vmat' (4CCF3C8C8DA5EE3F) requested but is not in the system. (Missing from from a manifest?)
  -- BUG: Nightstalker immortal loses his wings at night
  -- BUG: These could be optimized. Also sound is missing.
  PrecacheResource("particle_folder", "particles/units/heroes/hero_bounty_hunter/", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_treant/", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_mirana/", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_doom_bringer/", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_meepo/", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_sniper/", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_night_stalker/", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_pudge/", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_lycan/", context)
  PrecacheResource("particle_folder", "particles/econ/items/sniper/", context) -- can't forget immortal FX!
  PrecacheResource("particle_folder", "particles/econ/items/nightstalker/", context)
  PrecacheResource("particle", "particles/newplayer_fx/npx_sleeping.vpcf", context)
  PrecacheResource("particle", "particles/good_guy_dog_treat.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion_flash_b.vpcf", context)
  PrecacheResource("model_folder", "models/items/nightstalker/", context) -- inexplicably, no underscore in name
  PrecacheResource("model_folder", "models/items/sniper/", context)
  PrecacheResource("model_folder", "models/items/lycan/", context)
  PrecacheResource("model_folder", "models/heroes/nightstalker/", context)
  PrecacheResource("model_folder", "models/heroes/sniper/", context)
  PrecacheResource("model_folder", "models/heroes/lycan/", context)
  PrecacheResource("model", "models/props_gameplay/treasure_chest001.vmdl", context)
  PrecacheResource("model", "models/props_debris/merchant_debris_chest001.vmdl", context)
 
  -- TODO: Custom Games: PrecacheUnitByNameSync and PrecacheUnitByNameAsync can optionally take a PlayerID as the last
  -- argument and it will use the cosmetic items from that player when precaching. The player must be connected to the
  -- game otherwise it will fall back to the default cosmetic items.
  PrecacheUnitByNameSync("npc_dota_hero_sniper", context)
  PrecacheUnitByNameSync("npc_dota_hero_night_stalker", context)
end

-- Create the game mode class when we activate
function Activate()
	GameRules.HVH = HVHGameMode()
	GameRules.HVH:InitGameMode()

  --local courier = CreateUnitByName("npc_dota_courier", spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
  
end