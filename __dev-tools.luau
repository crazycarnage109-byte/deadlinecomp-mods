-- generic table reader
for i, v in pairs() do
    print(i,v)
end

-- get slot data
for i, v in pairs(players.get("LegitACarWithAGun").get_weapon_data_from_character("throwable1")) do
    print(i,v)
end

-- get the name of your equipment when spawning
on_player_spawned:Connect(function(name)
    local player = players.get(name)

    local weapon_slots = {
        -- "primary",
        -- "secondary",
        -- "throwable1",
        -- "throwable2",
    }

    for _, slot_name in pairs(weapon_slots) do
        local equipment = player.get_weapon_data_from_character(slot_name)
        if not equipment then
            continue
        end

        chat.send_announcement(equipment.name or equipment.client_data and equipment.client_data.name)
    end
end)