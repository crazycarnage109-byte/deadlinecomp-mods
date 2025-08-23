-- load command bot
if not shared.dlcomp_command_bot then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/command-bot.luau")
end
-- load countdown module
if not shared.dlcomp_countdown then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/countdown.luau")
end
-- load parser module
if not shared.dlcomp_parser then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/arg-parser.luau")
end

local ROUND_COMMAND_FORMAT = ";round map_name game_mode [round_duration] [countdown_duration]"

local last_countdown_duration = 15
local want_gamemode: string?

local gamemode_aliases = {
    tdm = "team_deathmatch",
    dom = "domination"
}

function prepare_round(map_name: string, mode_name: string, round_duration: number, countdown_duration: number)
    last_countdown_duration = countdown_duration
    want_gamemode = mode_name

    map.set_map(map_name)
    gamemode.force_set_gamemode("none") -- see the round_started comment
    sharedvars.gm_match_time_minutes = round_duration

    -- will eventually call round_started
    shared.dlcomp_countdown.countdown(countdown_duration)
end

-- called when the countdown has reached 0
-- setting the gamemode here because:
-- - we have no way of pausing the round timer
-- - switchng from the "none" gamemode is instant and doesnt end the round
function round_started()
    -- did we cause the countdown?
    -- todo: this can cause unexpected behavior when manually switching maps/gamemodes
    if not want_gamemode then
        return
    end

    -- we also have to prevent the teams from getting scrambled by the game
    local team_scrambling_reset_value = sharedvars.gm_team_scrambling
    sharedvars.gm_team_scrambling = false

    -- offically starts the round and timer
    gamemode.force_set_gamemode(want_gamemode)
    want_gamemode = nil

    -- reset the team scrambling sharedvar to whatever it was before
    sharedvars.gm_team_scrambling = team_scrambling_reset_value
end

-- countdown ended
shared.dlcomp_countdown.finished:Connect(function()
    round_started()
end)


function sections_after_match(sections: {string}, value: string): {string}?
    local leftover_sections
    for _, section in pairs( sections ) do
        -- check if we hit the first match
        if string.match(section, value) and not leftover_sections then
            leftover_sections = {}
            continue
        end

        -- store all the sections after the first match
        if leftover_sections then
            table.insert(leftover_sections, section)
        end
    end

    return leftover_sections
end

-- reasoning: typing the full map name is quite annoying, but a simple partial-match search is bad because theres a lot of maps with similar names, ie claustro v3 and v4
-- but those also immiedietly propose a solution; by doing multiple partial-matches on different sections of the map name,
-- you can be imprecise with long sections, and precise with small differences
-- ie to search for claustrophobic_v3, yould just type `cla_3`
function match_by_sections(haystack: {string}, needle: string, seperator: string): {string}
    needle = string.lower(needle)

    local option_sections = {}
    for _, option in pairs(haystack) do
        option = string.lower(option)
        option_sections[option] = string.split(option, seperator)
    end

    -- loop over every section of the needle
    for _, needle_section in pairs( string.split(needle, seperator) ) do
        -- loop over every option, discarding it if it doesnt have any matches
        for option, remaining_sections in pairs( option_sections ) do
            option_sections[option] = sections_after_match(remaining_sections, needle_section)
        end
    end

    -- turn the result into a useful format (list of strings)
    local results = {}
    for option, _ in pairs(option_sections) do
        table.insert(results, option)
    end

    return results
end

-- chat command
shared.dlcomp_command_bot.add_command("round", `starts a round with a countdown. format: {ROUND_COMMAND_FORMAT}`, function(args)
    local map_name, game_mode, round_duration, countdown_duration, info
    map_name, info = shared.dlcomp_parser.get_string(args)
    game_mode, info = shared.dlcomp_parser.get_string(info.remaining_text)
    round_duration, info = shared.dlcomp_parser.get_number(info.remaining_text, sharedvars.gm_match_time_minutes, 1)
    countdown_duration, info = shared.dlcomp_parser.get_number(info.remaining_text, last_countdown_duration, 5)

    -- handle arguments
    do
        -- are all the required arguments given?
        if map_name == "" or game_mode == "" then
            return `missing required arguments, command format: {ROUND_COMMAND_FORMAT}`
        end

        -- find the map the player's searching for
        local possible_maps = match_by_sections(map.get_maps(), map_name, "_")
        if #possible_maps == 0 then
            return `list of all maps: {table.concat(map.get_maps(), ", ")}`
        elseif #possible_maps > 1 then
            return `multiple maps match the argument: {table.concat(possible_maps, ", ")}`
        else
            map_name = possible_maps[1]
        end

        -- custom short names for gamemodes, because partial-matching just wont work for the mess that team_deathmatch is
        game_mode = string.lower(game_mode)
        if gamemode_aliases[game_mode] then
            game_mode = gamemode_aliases[game_mode]
        end

        -- does the gamemode exist?
        if not gamemode.available_gamemodes[game_mode] then
            local gamemode_list = {}
            for name in pairs(gamemode.available_gamemodes) do
                table.insert(gamemode_list, name)
            end
            return `no gamemode with name [{game_mode}] found, list of gamemodes: {table.concat(gamemode_list, ", ")}`
        end
    end

    prepare_round(map_name, game_mode, round_duration, countdown_duration)
    return
end)

shared.dlcomp_round = {
    prepare_round = prepare_round,
    gamemode_aliases = gamemode_aliases,
}
