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

    gamemode.force_set_gamemode(want_gamemode)
    want_gamemode = nil
end

-- countdown ended
shared.dlcomp_countdown.finished:Connect(function()
    round_started()
end)

shared.dlcomp_command_bot.add_command("round", `starts a round with a countdown. format: {ROUND_COMMAND_FORMAT}`, function(args)
    local map_name, game_mode, round_duration, countdown_duration, info
    map_name, info = shared.dlcomp_parser.get_string(args)
    game_mode, info = shared.dlcomp_parser.get_string(info.remaining_text)
    round_duration, info = shared.dlcomp_parser.get_number(info.remaining_text, sharedvars.gm_match_time_minutes, 1)
    countdown_duration, info = shared.dlcomp_parser.get_number(info.remaining_text, last_countdown_duration, 5)

    -- handle bad arguments
    do
        local errors = {}
        
        -- are all the required arguments given? fall through to print all the maps and gamemodes aswell
        if map_name == "" or game_mode == "" then
            table.insert(errors, `missing required arguments, command format: {ROUND_COMMAND_FORMAT}`)
        end

        -- does the given map exist?
        if not table.find(map.get_maps(), map_name) then
            table.insert(errors, `no map with name [{map_name}] found, list of maps: {table.concat(map.get_maps(), ", ")}`)
        end

        -- does the given gamemode exist?
        if not gamemode.available_gamemodes[game_mode] then
            local gamemode_list = {}
            for name in pairs(gamemode.available_gamemodes) do
                table.insert(gamemode_list, name)
            end
            table.insert(errors, `no gamemode with name [{game_mode}] found, list of gamemodes: {table.concat(gamemode_list, ", ")}`)
        end

        if #errors > 0 then
            for _, err_reason in pairs(errors) do
                chat.send_announcement(err_reason)
            end
            return
        end
    end

    prepare_round(map_name, game_mode, round_duration, countdown_duration)
end)

shared.dlcomp_round = {}
