-- without access to deadline I cant properly fill this out yet, TODO
-- remember to reload the window after changing this

type team_id = "attacker" | "defender"
type slot_id = "primary" | "secondary" | "throwable1" | "throwable2"

declare player: {
    set_team: (team: team_id) -> nil,
    set_weapon: (slot: slot_id, weapon_name: string, weapon_data: string?) -> nil,
}

declare chat: {
    send_announcement: (message: string, color: Color3?) -> nil
}