-- Sample adventure script

require('game_mode')

-- If something was being created via script such as a new npc, it would need to be precached here
function Precache( context )
  --[[
    Precache things we know we'll use.  Possible file types include (but not limited to):
      PrecacheResource( "model", "*.vmdl", context )
      PrecacheResource( "soundfile", "*.vsndevts", context )
      PrecacheResource( "particle", "*.vpcf", context )
      PrecacheResource( "particle_folder", "particles/folder", context )
  ]]
  PrecacheUnitByNameSync("npc_dota_hero_sniper", context) 
  PrecacheUnitByNameSync("npc_dota_hero_night_stalker", context)
end

-- Create the game mode class when we activate
function Activate()
	GameRules.AddonAdventure = HVHGameMode()
	GameRules.AddonAdventure:InitGameMode()
end

function HVHGameMode:SetHeroDeathBounty(hero)
  local heroLevel = hero:GetLevel()
  local deathXP = XP_PER_LEVEL_TABLE[heroLevel + 1];
  hero:SetCustomDeathXP(deathXP)
  --Placeholder values
  hero:SetBaseHealthRegen(10)
  hero:SetBaseManaRegen(100)
  --print("Set custom death xp: " .. deathXP)
end