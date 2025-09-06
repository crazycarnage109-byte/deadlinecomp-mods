--!strict

-- load command bot
if not shared.dlcomp_command_bot then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/command-bot.luau")
end
-- load arg parser module
if not shared.dlcomp_parser then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/arg-parser.luau")
end

local banned_players = {}

shared.dlcomp_command_bot.add_command("ban", "bans a player from the server", function(args: string)
	local player, _ = shared.dlcomp_parser.get_player(args)
	if not player then
		return "unclear target player"
	end

	table.insert(banned_players, player.name)
	player.kick()
	return `banned {player.name}`
end)

shared.dlcomp_command_bot.add_command("unban", "unbans a player from the server", function(args: string)
	local want_name, _ = shared.dlcomp_parser.get_string(args)

	-- partial match with banned_players
	local index
	for i, name in pairs(banned_players) do
		if not string.match(name, want_name) then
			continue
		end

		if index ~= nil then
			return `multiple banned players match the input [{want_name}]`
		end
		index = i
	end

	local full_name = table.remove(banned_players, index)
	return `unbanned [{full_name}]`
end)

shared.dlcomp_command_bot.add_command("kick", "kicks a person from the server", function(args: string)
	local player, _ = shared.dlcomp_parser.get_player(args)
	if not player then
		return "unclear target player"
	end
	player.kick()
	return `kicked {player.name}`
end)

shared.dlcomp_command_bot.add_command("kick_except", "kicks everyone except admins and a list of players ", function(args: string)
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

shared.dlcomp_command_bot.add_command("kill", "kills a player", function(args: string)
	local player, _ = shared.dlcomp_parser.get_player(args)
	if not player then
		return "unclear target player"
	end

	player.kill()
	return `killed [{player.name}]`
end)

-- kick any banned players that try to rejoin
on_player_joined:Connect(function(player_name: string)
	if not table.find(banned_players, player_name) then
		return
	end

	local player = players.get(player_name)
	if not player then
		return
	end

	player.kick()
end)
