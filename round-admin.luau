-- Round Admin module
-- purpose is to make the process of starting a new round as easy as possible

-- todo: figure out how to freeze the round timer
-- todo: single command to start a match with a given map and gamemode

-- load command bot
if not shared.dlcomp_command_bot then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/command-bot.luau")
end

local active_countdown: thread?

function freeze()
    sharedvars.plr_speed = 0.05 -- 0 seems to completely despawn your gun? lol
end
function unfreeze()
    sharedvars.plr_speed = 1
end

do -- countdown implementation
    function format_countdown_seconds(time_left: number): string?
        if time_left == 0 then
            return "GO GO GO!!!!!!"
        elseif time_left <= 5 then
            -- below five seconds
            return `{time_left}`
        elseif (time_left % 5) == 0 then
            -- multiple of 5
            return `{time_left} seconds`
        else
            return nil
        end
    end

    function process_countdown(duration: number)
        chat.send_announcement(`COUNTDOWN: {duration} seconds`, Color3.new(1, 0, 0))

        for ticks_left = duration-1, 0, -1 do
            task.wait(1)
            local formatted_seconds = format_countdown_seconds(ticks_left)
            if formatted_seconds then
                chat.send_announcement(formatted_seconds)
            end
        end

        unfreeze()
    end

    function cancel_countdown()
        if not active_countdown then
            return
        end
        task.cancel(active_countdown)
        active_countdown = nil
        chat.send_announcement("countdown cancelled")
    end

    function trigger_countdown(duration: number)
        freeze()
        if active_countdown then
            task.cancel(active_countdown)
        end
        active_countdown = task.spawn(process_countdown, duration)
    end
end

shared.dlcomp_command_bot.add_command("countdown", "starts a countdown in chat", function(args: string)
    -- parse countdown duration
    local duration, _ = shared.dlcomp_parser.get_number(args, 5)
    duration = math.ceil(duration)

    -- treat duration <= 0 as cancel, simplest way
    if duration <= 0 then
        cancel_countdown()
        return
    end

    trigger_countdown(duration)
end)
shared.dlcomp_command_bot.add_command("freeze", "freeze the players in place", function(args: string)
    freeze()
end)
shared.dlcomp_command_bot.add_command("unfreeze", "lets the players walk around again", function(args: string)
    unfreeze()
end)

shared.dlcomp_round_admin = {
    trigger_countdown = trigger_countdown,
    cancel_countdown = cancel_countdown,
    freeze = freeze,
    unfreeze = unfreeze,
}

chat.send_announcement("loaded round admin module")
