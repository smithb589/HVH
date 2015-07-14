-- Sniper/NS asynchronous precaching handled by HVHGameMode:_PostLoadPrecache()

PRECACHE_ITEMS = {
	"item_amplify_damage",
	"item_aphotic_shield",
	"item_assassinate",
	"item_black_hole",
	"item_ensnare",
	"item_hand_of_god",
	"item_homing_missile",
	"item_frost_armor",
	"item_land_mines",
	"item_purification",
	"item_tether",
	"item_walrus_punch",
	"item_pounce",
	"item_eye_of_the_storm",
	"item_dream_coil",
	"item_deafening_blast",
	"item_culling_blade",
	"item_chaos_meteor",
	"item_firefly",
	"item_summon_wolves",
	"item_blinding_light",
	"item_windrun",
	"item_mirana_arrow",
	"item_shackleshot",
	"item_ravage",
	"item_stampede",
	"item_kinetic_field",
	"item_meat_hook_new",
	"item_meat_hook"
}

-- TODO: optimize these by finding the correct particles
PRECACHE_UNITS = {
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_enigma", -- black hole crashes game?
	"npc_dota_hero_pudge", -- missing hook/chain
	"npc_dota_hero_tusk",
	"npc_dota_hero_slark",
	"npc_dota_hero_razor",
	"npc_dota_hero_batrider",
	"npc_dota_hero_windrunner", -- only missing tree shackle
	"npc_dota_hero_disruptor",
	"npc_dota_hero_tidehunter",
	"npc_dota_good_guy_dog"
	--"npc_dota_hero_sniper",
	--"npc_dota_hero_night_stalker",
	--"npc_dota_hero_shredder",
	--"npc_dota_hero_disruptor",
	--"npc_dota_hero_centaur"
}

PRECACHE_MODELS = { 
  --"models/heroes/nightstalker/nightstalker_night.vmdl",
  "models/props_gameplay/treasure_chest001.vmdl",
  "models/props_debris/merchant_debris_chest001.vmdl",
  "models/development/invisiblebox.vmdl"
}

PRECACHE_MODEL_FOLDERS = {
	--"models/items/nightstalker/", -- inexplicably, no underscore in name
	--"models/heroes/nightstalker/",
	--"models/items/sniper/",
	--"models/items/lycan/",
	--"models/heroes/sniper/",
	--"models/heroes/lycan/"
}

PRECACHE_PARTICLE_FOLDERS = {
	--"particles/units/heroes/hero_sniper/",
	--"particles/units/heroes/hero_night_stalker/",
	--"particles/econ/items/sniper/", -- can't forget immortal FX!
	--"particles/econ/items/nightstalker/",
	--"particles/units/heroes/hero_keeper_of_the_light/",
	--"particles/units/heroes/hero_windrunner/",
	--"particles/units/heroes/hero_batrider/",
	--"particles/units/heroes/hero_tidehunter/",
	--"particles/units/heroes/hero_mirana/",
	--"particles/units/heroes/hero_doom_bringer/",
	--"particles/units/heroes/hero_meepo/",
	--"particles/units/heroes/hero_pudge/",
	--"particles/units/heroes/hero_lycan/"
}

PRECACHE_PARTICLES = {
	"particles/units/heroes/hero_shredder/shredder_timberchain.vpcf",
	"particles/units/heroes/hero_shredder/shredder_timber_chain_trail.vpcf",
	"particles/units/heroes/hero_shredder/shredder_timber_chain_tree.vpcf",
	"particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf",
	"particles/units/heroes/hero_meepo/meepo_earthbind.vpcf",
	"particles/newplayer_fx/npx_sleeping.vpcf",
	"particles/good_guy_dog_treat.vpcf",
	"particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion_flash_b.vpcf",
	"particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
}

PRECACHE_SOUNDFILES = {
	"soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts",
	"soundevents/game_sounds_heroes/game_sounds_meepo.vsndevts"
	--"soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts",
	--"soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts"
}