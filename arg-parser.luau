-- Argument Parser module
-- intended to use arguments attached to chat commands
-- in its own module and not integrated into the command-bot because I dont wanna get in the way of people doing their own thing with their arguments
-- honestly not super confident in this

-- creates a new parse_info instance, just for convenience
-- see _interface.d.luau for the contents of the command_parse_info type
function new_info(): command_parse_info
    return {
        remaining_text = "",
        converted_from = "",
    }
end
-- just removes whitespace from the start of a string
function trim_start(str: string): string
    return string.gsub(str, "^%s+", "", 1)
end


-- treats the next argument as a string
-- cant fail
function get_string(args: string): (string, command_parse_info)
    local info = new_info()

    -- remove whitespace from start
    args = trim_start(args)

    -- scan until next whitespace
    local current_arg = string.match(args, "^%S*")

    -- see parse_info's comments
    info.converted_from = current_arg
    info.remaining_text = string.sub(args, current_arg:len()+1) -- 99% sure +1 is correct here 

    return current_arg, info
end

-- treats the next argument as a number,
-- will return nil if it cant be turned into a number, but the section will still get removed in info
function get_number(args: string, default: number?, min: number?, max: number?): (number?, command_parse_info)
    local arg, info = get_string(args)

    -- process arg
    local result = tonumber(arg) or default
    if result and min then
        result = math.max(result, min)
    end
    if result and max then
        result = math.min(result, max)
    end

    return result, info
end

-- treats the next argument as a player name,
-- will return nil if no such player exists, but the section will still get removed in info
function get_player(args: string): (player?, command_parse_info)
    local arg, info = get_string(args)
    return players.get(arg), info
end

shared.dlcomp_parser = {
    get_string = get_string,
    get_number = get_number,
    get_player = get_player,
}
