--!strict

-- load command bot
if not shared.dlcomp_command_bot then
    require("https://raw.githubusercontent.com/crazycarnage109-byte/deadlinecomp-mods/refs/heads/main/command-bot.luau")
end
-- load arg parser module
if not shared.dlcomp_parser then
    require("https://raw.githubusercontent.com/crazycarnage109-byte/deadlinecomp-mods/refs/heads/main/arg-parser.luau")
end

shared.dlcomp_command_bot.add_command("cam", "changes the player's cam mode. format: ;cam mode [player]", function(args: string, extra: command_call_info)
	local want_mode, player, info
	want_mode, info = shared.dlcomp_parser.get_string(args)
	player, info = shared.dlcomp_parser.get_player(info.remaining_text)

	-- user didnt specify a player to apply it to, presume they mean themselves
	if info.converted_from == "" then
		player = extra.caller
	end
	
	if player == nil then
		return "unclear target player"
	end

	player.set_camera_mode(want_mode)
	return `set [{player.name}]'s camera mode to [{want_mode}]`
end)

shared.dlcomp_command_bot.add_command("rand", "selects a random value from the argument list", function(args: string, extra: command_call_info)
	-- get all args
	local arg_list = {}
	while true do
		local cur_arg, info = shared.dlcomp_parser.get_string(args)
		if cur_arg == "" then
			break
		end

		table.insert(arg_list, cur_arg)
		args = info.remaining_text
	end

	if #arg_list < 2 then
		return `please include atleast 2 arguments, seperated by whitespace`
	end

	-- choose a random arg
	local index = math.random(#arg_list)

	-- output
	return arg_list[index]
end)
