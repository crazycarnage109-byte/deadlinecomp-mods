-- without access to deadline I cant properly fill this out yet, TODO
-- remember to reload the window after changing this

export type team_id = "attacker" | "defender"
export type slot_id = "primary" | "secondary" | "throwable1" | "throwable2"

export type player = {
    set_team: (team: team_id) -> nil,
    set_weapon: (slot: slot_id, weapon_name: string, weapon_data: string?) -> nil,
}

declare players: {
    get: (name: string) -> player
}

declare chat: {
    send_announcement: (message: string, color: Color3?) -> nil
}