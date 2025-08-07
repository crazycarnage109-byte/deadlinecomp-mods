-- load command bot
if not shared.dlcomp_command_bot then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/command-bot.luau")
end
-- load arg parser module
if not shared.dlcomp_parser then
    require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/arg-parser.luau")
end


--- returns the id of the new team
function switch_player_team(player: player): team_id
    -- swap team
    local want_team = player.get_team() == "attacker" and "defender" or "attacker"
    player.set_team(want_team)

    -- respawn if alive
    if player.is_alive() then
        player.respawn()
    end

    -- return their new team
    return want_team
end

shared.dlcomp_command_bot.add_command("switch", "switch the team of the specified player", function(args: string)
    local want_player, _ = shared.dlcomp_parser.get_player(args)
    if not want_player then
        return "player not found"
    end

    switch_player_team(want_player)

    return nil
end)

shared.dlcomp_command_bot.add_command("team_swap", "swap the teams of everyone", function(args: string): string?
    for _, player in pairs( players.get_all() ) do
        switch_player_team(player)
    end
    return nil
end)

shared.dlcomp_command_bot.add_command("team_scramble", "scramble players into teams randomly", function(args: string)
    -- scramble the order of the players into a new list (scrambled_player_list)
    local original_player_list = players.get_all()
    local scrambled_player_list = {}
    while #original_player_list > 0 do
        local index = math.random(1, #original_player_list)
        local chosen_player = table.remove(original_player_list, index)
        table.insert(scrambled_player_list, chosen_player)
    end

    -- alternate which team you place them in
    -- scrambled_player_list is in a random order so the resulting teams are random aswell
    local next_team: team_id = "attacker"
    for _, player in pairs(scrambled_player_list) do
        -- move to team
        player.set_team(next_team)

        -- respawn if alive
        if player.is_alive() then
            player.respawn()
        end

        next_team = (next_team == "attacker" and "defender" or "attacker") :: team_id
    end

    return "teams have been scrambled"
end)

shared.dlcomp_team = {}
