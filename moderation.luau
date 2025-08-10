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
		return "no player found"
	end
	player.ban_from_server()
	return `banned {player.name}`
end)

shared.dlcomp_command_bot.add_command("kick", "kicks a person from the server", function(args: string)
	local player, _ = shared.dlcomp_parser.get_player(args)
	if not player then
		return "no player found"
	end
	player.kick()
	return `kicked {player.name}`
end)

shared.dlcomp_command_bot.add_command("kick_except", "kicks everyone except a list of players, and you", function(args: string)
	local self = players.get(sharedvars.vip_owner)
	local player_list = {self.id}
	while true do
		local player, info = shared.dlcomp_parser.get_player(args)
		if player == nil then
			break
		end

		table.insert(player_list, player.id)
		args = info.remaining_text
	end

	local amount_kicked = 0
	for _, player in pairs( players.get_all() ) do
		if table.find(player_list, player.id) then
			continue
		end

		player.kick()
		amount_kicked += 1
	end

	return `kicked {amount_kicked} players`
end)
