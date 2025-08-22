-- load command bot
if not shared.dlcomp_command_bot then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/command-bot.luau")
end
-- load arg parser module
if not shared.dlcomp_parser then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/arg-parser.luau")
end

shared.dlcomp_command_bot.add_command("ban", "bans a person from the server", function(args: string)
	local player, _ = shared.dlcomp_parser.get_player(args)
	if not player then
		return "unclear target player"
	end
	player.ban_from_server()
	return `banned {player.name}`
end)

shared.dlcomp_command_bot.add_command("kick", "kicks a person from the server", function(args: string)
	local player, _ = shared.dlcomp_parser.get_player(args)
	if not player then
		return "unclear target player"
	end
	player.kick()
	return `kicked {player.name}`
end)

shared.dlcomp_command_bot.add_command("kick_except", "kicks everyone except a list of players, and you", function(args: string)
	-- dont allow admins to get kicked
	local exception_list = table.clone(shared.dlcomp_command_bot.admin_list)

	-- add all the custom exceptions
	while true do
		local player, info = shared.dlcomp_parser.get_player(args)
		if player == nil then
			break
		end

		table.insert(exception_list, player.name)
		args = info.remaining_text
	end

	-- kick anyone who isnt in the exception list
	local amount_kicked = 0
	for _, player in pairs( players.get_all() ) do
		if table.find(exception_list, player.name) then
			continue
		end

		player.kick()
		amount_kicked += 1
	end

	return `kicked {amount_kicked} players`
end)

shared.dlcomp_command_bot.add_command("respawn", "respawns a player if theyre alive", function(args: string)
	local player, _ = shared.dlcomp_parser.get_player(args)
	if not player then
		return "unclear target player"
	end

	if player.is_alive() then
		player.respawn()
		return `respawned [{player.name}]`
	else
		return `[{player.name}] isnt spawned`
	end
end)
