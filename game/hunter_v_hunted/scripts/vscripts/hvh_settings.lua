-- In this file you can set up all the properties and settings for your game mode.
HVH_VERSION 		= "1.7.1"

-- HVH Leveling and Abilities
STARTING_LEVEL		= 16
MAX_LEVEL 			= 16
MAX_OUT_ABILITIES   = false -- max out ALL abilities or only starting abilities?
DISABLE_DOGS 		= false  -- disables hound spawning
DISABLE_BONUS_DOGS  = false  -- disable extra hounds for missing sniper players

-- HVH Time
START_WITH_DAY		= true 			-- true for day, false for night
DAY_SECONDS         = 60.0  		-- 60.0
NIGHT_SECONDS       = 90.0			-- 90.0
DAY_SECONDS_RANDOM_EXTRA   = 0.0	-- randomly increase/decrease each half-cycle by -(Value) to Value seconds
NIGHT_SECONDS_RANDOM_EXTRA = 0.0	-- randomly increase/decrease each half-cycle by -(Value) to Value seconds
PRE_GAME_TIME = 30.0                -- How long after people select their heroes should the horn blow and the game start?
PREGAME_SLEEP = true 				-- play the tutorial and put players to sleep for first ~30 seconds
DC_TIME_ALLOWANCE	= 60.0			-- How much time is given after a whole team DCs before victory is declared

-- HVH Respawn
BADGUY_LIVES  = 6
GOODGUY_LIVES = 18
MIN_RESPAWN_TIME = 18
MAX_RESPAWN_TIME = 23
RESPAWN_DISCONNECT_MULTIPLIER = 3
RESPAWN_BADGUYTEAM_MULTIPLIER = 0.5
MINIMUM_RESPAWN_RANGE = 2500		-- if no respawn points are found outside this range, the least worst will be used


-- HVH Neutral Creeps
NEUTRAL_CREEPS 				   = true  		-- enable neutral creep spawns?
NEUTRAL_CREEPS_UNIT_POINTS_NONE		= 0 
NEUTRAL_CREEPS_UNIT_POINTS_LOW		= 6 
NEUTRAL_CREEPS_UNIT_POINTS_MEDIUM	= 12 	-- default (when host options are unspecified)
NEUTRAL_CREEPS_UNIT_POINTS_HIGH		= 18 
NEUTRAL_CREEPS_UNIT_POINTS_EXTREME	= 24
NEUTRAL_CREEPS_START_TIME	   = 10.0		-- start spawning at X seconds
NEUTRAL_CREEPS_REPEAT_TIME     = 10.0		-- respawn every Y seconds after start time

-- HVH Item Spawning
NS_CHEST_HEAL			= 	0.05		-- percentage of maximum health per moonrock pickup
SUN_SHARD_BONUS_TIME	=	3			-- extra seconds per sun shard use
SUN_SHARD_PICKUP_CHANCE	=	1.0			-- chance of getting a sun shard on pickup: 0.0 = 0%, 1.0 = 100%
SUN_SHARD_DEATH_PENALTY	=	0.5			-- percentage of sunshards lost on death, round down
-- TODO: on death destroy half of sunshard inventory, round down

-- HVH Power Stages for reinforcements / evolutions
GG_POWER_STAGE_THRESHOLDS = {}
GG_POWER_STAGE_THRESHOLDS[0] = GOODGUY_LIVES
GG_POWER_STAGE_THRESHOLDS[1] = 17 -- +1 shrapnel (2)
GG_POWER_STAGE_THRESHOLDS[2] = 15 -- meepo nets
GG_POWER_STAGE_THRESHOLDS[3] = 13  -- +1 hound
GG_POWER_STAGE_THRESHOLDS[4] = 12 -- timberchain
GG_POWER_STAGE_THRESHOLDS[5] = 9 -- +1 shrapnel (3)
GG_POWER_STAGE_THRESHOLDS[6] = 7 -- +1 hound
GG_POWER_STAGE_THRESHOLDS[7] = 0
BG_POWER_STAGE_THRESHOLDS = {}
BG_POWER_STAGE_THRESHOLDS[0] = BADGUY_LIVES
BG_POWER_STAGE_THRESHOLDS[1] = 5 -- dread leap
BG_POWER_STAGE_THRESHOLDS[2] = 4 -- echolocation
BG_POWER_STAGE_THRESHOLDS[3] = 2 -- aoe crippling fear
BG_POWER_STAGE_THRESHOLDS[4] = 0

-- HVH Hound Models
HOUND_MODEL_PATHS = {
	"models/heroes/lycan/summon_wolves.vmdl",
	"models/heroes/lycan/summon_wolves.vmdl",
	"models/heroes/lycan/summon_wolves.vmdl",
	"models/heroes/lycan/summon_wolves.vmdl",
	"models/items/lycan/wolves/alpha_summon_01/alpha_summon_01.vmdl",
	"models/items/lycan/wolves/ambry_summon/ambry_summon.vmdl",
	"models/items/lycan/wolves/hunter_kings_wolves/hunter_kings_wolves.vmdl",
	"models/items/lycan/wolves/icewrack_pack/icewrack_pack.vmdl"
}

-- HVH Other
GOLD_PER_KILL = 0
SNIPERS_COLOR_HEX = "#FCAF3D" -- day
NS_COLOR_HEX 	  = "#99CCFF" -- night

-- HVH Unused
XP_MULTIPLIER_FOR_SNIPER_KILLS = 4
XP_PER_KILL 		= 2	-- NS gets this XP. Snipers get this times XP_MULTIPLIER_FOR_SNIPER_KILLS
XP_PER_TICK      	= 1	-- every XP_TICK_INTERVAL seconds, living heroes get XP_PER_TICK
XP_TICK_INTERVAL 	= 30

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 20.0              -- How long should we let people select their hero?
--PRE_GAME_TIME = 30.0  -- moved to HVH Time
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 40.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 0                       -- How much gold should players get per tick?
GOLD_TICK_TIME = 0                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = true      -- Should we disable the recommened builds for heroes
--CAMERA_DISTANCE_OVERRIDE = 1134.0       -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = false    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false               -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

-- custom hero levels means each entry = total XP you need to reach that level
-- default hero levels means each entry = XP you need for next level (i think)
USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_FACTOR = 10
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = (i-1) * XP_FACTOR
end

ENABLE_FIRST_BLOOD = true               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = false               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = true        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?

-- Warning!  This setting currently does not work well with custom teams beyond Radiant and Dire!
-- VEG: This option seems to be ignored in favor of the hammer dota_custom_game_events entity's option
FORCE_PICKED_HERO = "npc_dota_hero_sniper"    -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = 3                  -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = -1   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 600              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

RUNE_SPAWN_TIME = 60	                -- How long in seconds should we wait between rune spawns?
-- NOTE: You always need at least 2 non-bounty (non-regen while broken) type runes to be able to spawn or your game will crash!
ENABLED_RUNES = {}                      -- Which runes should be enabled to spawn in our game mode?
ENABLED_RUNES[DOTA_RUNE_DOUBLEDAMAGE] = true
ENABLED_RUNES[DOTA_RUNE_HASTE] = true
ENABLED_RUNES[DOTA_RUNE_ILLUSION] = true
ENABLED_RUNES[DOTA_RUNE_INVISIBILITY] = true
ENABLED_RUNES[DOTA_RUNE_REGENERATION] = true -- Regen runes are currently not spawning as of the writing of this comment
ENABLED_RUNES[DOTA_RUNE_BOUNTY] = false

MAX_NUMBER_OF_TEAMS = 4              -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = true          -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = true          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 252, 175, 61 } -- HVH day
TEAM_COLORS[DOTA_TEAM_BADGUYS]  = { 153, 204, 255 } -- HVH night

USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 4
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 1