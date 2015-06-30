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

function HVHGameMode:OnPlayerPickHero(keys)
  local heroClass = keys.hero
  if heroClass == "npc_dota_hero_axe" then
    print("Hero being replaced " .. heroClass)
    local heroEntity = EntIndexToHScript(keys.heroindex)
    local player = EntIndexToHScript(keys.player)
    local playerID = player:GetPlayerID()

    local newHero = nil
    if player:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
      newHero = "npc_dota_hero_sniper"
    else
      newHero = "npc_dota_hero_night_stalker"
    end

    print("Replacing hero for player with ID " .. playerID)
    
    PlayerResource:ReplaceHeroWith(playerID, newHero, 0, 0)
    print("Replaced hero.")
  end
end