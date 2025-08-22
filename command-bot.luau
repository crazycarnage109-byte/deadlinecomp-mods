-- Command Bot module
-- listens for commands written in chat and passes them to other modules
-- exists because the built-in command bot doesnt let you register custom commands

-- check if a version of the bot is already running
if shared.dlcomp_command_bot then
    return
end

-- load arg parser module
if not shared.dlcomp_parser then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/arg-parser.luau")
end

local prefix = ";"
local commands: {[string]: command_data} = {}
local admins = {
    [sharedvars.vip_owner] = true,
}

type command_callback = (args: string) -> string?
type command_data = {
    name: string,
    explanation: string,
    callback: command_callback,
}

function add_command(name: string, explanation: string, callback: (args: string) -> string?)
    commands[name] = {
        name = name,
        explanation = explanation,
        callback = callback,
    }
end

function toggle_admin(player_name: string, toggle: boolean?): (boolean, string)
    -- is the target player already a admin?
    local is_admin = admins[player_name]

    -- user wants to switch the player's admin powers
    if toggle == nil then
        toggle = not is_admin
    end

    -- actually update the admin list
    admins[player_name] = toggle and true or nil

    -- returns
    if toggle == is_admin then
        return false, "no changes"
    elseif toggle then
        return true, `gave [{player_name}] admin powers`
    else
        return true, `removed [{player_name}]'s admin powers`
    end
end

function format_admin_list()
    local keys = {}
    for admin in pairs(admins) do
        table.insert(keys, admin)
    end

    return table.concat(keys, ", ")
end

-- listen for messages in chat
chat.player_chatted:Connect(function(sender, channel, content)
    -- check if the message has the command prefix
    if content:sub(1, prefix:len()) ~= prefix then
        return
    end
    -- remove the command prefix
    content = content:sub(prefix:len()+1)

    -- only let admins execute commands
    if not admins[sender] then
        chat.send_announcement(`youre not a admin. admin list: {format_admin_list()}`)
        return
    end

    -- treat everything before the next whitespace as the command name
    local command_name = string.match(content, "^%S+") or ""

    -- attempt to find command from name
    local command_info = commands[command_name]
    if not command_info then
        chat.send_announcement(`no command with name [{command_name}]`)
        return
    end

    -- leave the rest of the user input raw, and let the callback deal with it
    local command_args = string.sub(content, command_name:len()+2)

    -- execute command
    local result = command_info.callback(command_args)
    if result ~= nil then
        chat.send_announcement(result)
    end
end)





-- built in commands
add_command("help", "prints this message", function(args: string)
    local results = {}
    for _, info in pairs(commands) do
        table.insert(results, `{info.name} - {info.explanation}`)
    end
    return table.concat(results, "\n")
end)

add_command("admin", "toggles a player's ability to run commands, format: ;admin player_name [toggle]", function(args: string)
    local info, want_player, toggle
    want_player, info = shared.dlcomp_parser.get_player(args)
    toggle, info = shared.dlcomp_parser.get_bool(info.remaining_text)

    -- no args given, print the name of every admin
    if not string.match(args, "%S+") then
        return format_admin_list()
    end

    if not want_player then
        return "unclear player name"
    end

    local success, message = toggle_admin(want_player.name, toggle)
    return `{success and "SUCCESS" or "FAIL"}: {message}`
end)

-- let other mods add/remove commands
shared.dlcomp_command_bot = {
    add_command = add_command,
    toggle_admin = toggle_admin,
}

chat.send_announcement(`loaded dlcomp_command_bot with prefix {prefix}`)
