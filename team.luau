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
    local want_team = player.get_team() == "attacker" and "defender" or "attacker"
    player.set_team(want_team)
    return want_team
end

shared.dlcomp_command_bot.add_command("switch", "switch the team of the specified player", function(args: string)
    local want_player, _ = shared.dlcomp_parser.get_player(args)
    if not want_player then
        return "player not found"
    end

    switch_player_team(want_player)
    -- respawn if alive
    if want_player.is_alive() then
        want_player.respawn()
    end

    return nil
end)

shared.dlcomp_command_bot.add_command("team_swap", "swap the teams of everyone", function(args: string): string?
    for _, player in pairs( players.get_all() ) do
        switch_player_team(player)
    end
    return nil
end)
