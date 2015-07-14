-- Sniper/NS asynchronous precaching handled by HVHGameMode:_PostLoadPrecache()

PRECACHE_ITEMS = {
	"item_chaos_meteor"
}

PRECACHE_UNITS = {
	--"npc_dota_hero_sniper",
	--"npc_dota_hero_night_stalker",
	"npc_dota_hero_shredder",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_centaur"
}

PRECACHE_MODELS = { 
  --"models/heroes/nightstalker/nightstalker_night.vmdl",
  "models/props_gameplay/treasure_chest001.vmdl",
  "models/props_debris/merchant_debris_chest001.vmdl",
  "models/development/invisiblebox.vmdl"
}

PRECACHE_MODEL_FOLDERS = {
	--"models/items/nightstalker/", -- inexplicably, no underscore in name
	--"models/items/sniper/",
	"models/items/lycan/",
	"models/heroes/nightstalker/",
	"models/heroes/sniper/",
	"models/heroes/lycan/"
}

PRECACHE_PARTICLE_FOLDERS = {
	--"particles/units/heroes/hero_sniper/",
	--"particles/units/heroes/hero_night_stalker/",
	--"particles/econ/items/sniper/", -- can't forget immortal FX!
	--"particles/econ/items/nightstalker/",
	"particles/units/heroes/hero_keeper_of_the_light/",
	"particles/units/heroes/hero_windrunner/",
	"particles/units/heroes/hero_batrider/",
	"particles/units/heroes/hero_tidehunter/",
	"particles/units/heroes/hero_mirana/",
	"particles/units/heroes/hero_doom_bringer/",
	"particles/units/heroes/hero_meepo/",
	"particles/units/heroes/hero_pudge/",
	"particles/units/heroes/hero_lycan/"
}

PRECACHE_PARTICLES = {
	"particles/newplayer_fx/npx_sleeping.vpcf",
	"particles/good_guy_dog_treat.vpcf",
	"particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion_flash_b.vpcf",
	"particles/units/heroes/hero_slardar/slardar_sprint.vpcf"

}

PRECACHE_SOUNDFILES = {
	"soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts"
}