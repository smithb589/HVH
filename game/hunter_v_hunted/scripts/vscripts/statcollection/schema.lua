customSchema = class({})

function customSchema:init()

    -- Check the schema_examples folder for different implementations

    -- Flag Example
    statCollection:setFlags({version = HVH_VERSION})

    -- Listen for changes in the current state
    ListenToGameEvent('game_rules_state_change', function(keys)
        local state = GameRules:State_Get()

        -- Send custom stats when the game ends
        if state == DOTA_GAMERULES_STATE_POST_GAME then

            -- Build game array
            local game = BuildGameArray()

            -- Build players array
            local players = BuildPlayersArray()

            -- Print the schema data to the console
            if statCollection.TESTING then
                PrintSchema(game, players)
            end

            -- Send custom stats
            if statCollection.HAS_SCHEMA then
                statCollection:sendCustom({ game = game, players = players })
            end
        end
    end, nil)
end

-------------------------------------

-- In the statcollection/lib/utilities.lua, you'll find many useful functions to build your schema.
-- You are also encouraged to call your custom mod-specific functions

-- Returns a table with our custom game tracking.
function BuildGameArray()
    local game = {}

    -- Add game values here as game.someValue = GetSomeGameValue()
    game.gg = GetTeamLivesRemaining(DOTA_TEAM_GOODGUYS)
    game.bg = GetTeamLivesRemaining(DOTA_TEAM_BADGUYS)
    --game.dt = GetDOTATimeToNearestMinute()
    game.dh = GameRules:GetGameModeEntity().DeadHounds -- total hounds killed during the course of the game

    -- claimed and unclaimed chests per team
    game.ggcc = GetClaimedChestsForTeam(DOTA_TEAM_GOODGUYS)
    game.bgcc = GetClaimedChestsForTeam(DOTA_TEAM_BADGUYS)
    game.gguc = GetUnclaimedChests(DOTA_TEAM_GOODGUYS)
    game.bguc = GetUnclaimedChests(DOTA_TEAM_BADGUYS)

    return game
end

-- Returns a table containing data for every player in the game
function BuildPlayersArray()
    local players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then

                local hero = PlayerResource:GetSelectedHeroEntity(playerID)

                table.insert(players, {
                    -- steamID32 required in here
                    steamID32 = PlayerResource:GetSteamAccountID(playerID),
                    tn = GetEnglishTeamName(hero),
                    cc = GetClaimedChests(hero), -- claimed chests per player
                    pk = hero:GetKills(), -- Kills
                    pa = hero:GetAssists(), -- Assists
                    pd = hero:GetDeaths(), -- Deaths
                    -- Example functions for generic stats are defined in statcollection/lib/utilities.lua
                    -- Add player values here as someValue = GetSomePlayerValue(),
                })
            end
        end
    end

    return players
end

-- Prints the custom schema, required to get an schemaID
function PrintSchema(gameArray, playerArray)
    print("-------- GAME DATA --------")
    DeepPrintTable(gameArray)
    print("\n-------- PLAYER DATA --------")
    DeepPrintTable(playerArray)
    print("-------------------------------------")
end

-- Write 'test_schema' on the console to test your current functions instead of having to end the game
if Convars:GetBool('developer') then
    Convars:RegisterCommand("test_schema", function() PrintSchema(BuildGameArray(), BuildPlayersArray()) end, "Test the custom schema arrays", 0)
end

-------------------------------------

-- If your gamemode is round-based, you can use statCollection:submitRound(bLastRound) at any point of your main game logic code to send a round
-- If you intend to send rounds, make sure your settings.kv has the 'HAS_ROUNDS' set to true. Each round will send the game and player arrays defined earlier
-- The round number is incremented internally, lastRound can be marked to notify that the game ended properly
function customSchema:submitRound(isLastRound)

    local winners = BuildRoundWinnerArray()
    local game = BuildGameArray()
    local players = BuildPlayersArray()

    statCollection:sendCustom({ game = game, players = players })

    isLastRound = isLastRound or false --If the function is passed with no parameter, default to false.
    return { winners = winners, lastRound = isLastRound }
end

-- A list of players marking who won this round
function BuildRoundWinnerArray()
    local winners = {}
    local current_winner_team = GameRules.Winner or 0 --You'll need to provide your own way of determining which team won the round
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                winners[PlayerResource:GetSteamAccountID(playerID)] = (PlayerResource:GetTeam(playerID) == current_winner_team) and 1 or 0
            end
        end
    end
    return winners
end

-------------------------------------
-- HVH STAT COLLECTION UTIL FUNCTIONS
-------------------------------------
-- Round (number_to_round) to nearest (multiple) (DEPRECATED)
function RoundToNearest(multiple, number_to_round)
    -- ex. 11 / 3 = 3.66. Then 3.66 + 0.5 = 4.16. Floored to 4. Finally 4 * 3 = 12.
    -- 11 rounded to the nearest multiple of 3 rounds to 12.
    return math.floor((number_to_round / multiple) + 0.5) * multiple    
end

function GetUnclaimedChests(team)
    local unclaimedChests = 0
    if team == DOTA_TEAM_GOODGUYS then
        unclaimedChests = HVHItemSpawnController._ggUnclaimedItems -- integer
    elseif team == DOTA_TEAM_BADGUYS then
        unclaimedChests = HVHItemSpawnController._bgUnclaimedItems -- integer
    end
    return unclaimedChests
end

function GetClaimedChestsForTeam(team)
    local teamChests = 0
    local heroList = HeroList:GetAllHeroes()
    for _,hero in pairs(heroList) do
        if hero:GetTeam() == team then
            teamChests = teamChests + GetClaimedChests(hero)
        end
    end
    return teamChests
end

function GetClaimedChests(hero)
    return hero.ClaimedItems
end

function GetEnglishTeamName(hero)
    local team = hero:GetTeam()
    local teamName = "N/A"
    if team == DOTA_TEAM_GOODGUYS then
        teamName = "Snipers"
    elseif team == DOTA_TEAM_BADGUYS then
        teamName = "Night Stalker"
    end

    return teamName
end

function GetTeamLivesRemaining(team)
    local mode = GameRules:GetGameModeEntity()
    local lives = 0

    if team == DOTA_TEAM_GOODGUYS then
        lives = mode.GoodGuyLives
    elseif team == DOTA_TEAM_BADGUYS then
        lives = mode.BadGuyLives
    end

    return lives
end

 -- round to nearest whole minute
function GetDOTATimeToNearestMinute()
    local time = math.floor((GameRules:GetDOTATime(false,false) / 60) + 0.5)
    return time
end