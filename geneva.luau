-- Geneva, a module for enforcing equipment rules
-- terms:
-- - equipment/weapon = everything thats equippable, slots 1-4
-- - gun = firearms and rpgs, everything thats in slots 1 and 2
-- - utility = grenades and knives, everything thats in slots 3 and 4, internally called `throwable`

-- todo: integrate with command bot

-- rules
local banned_gun_list = {}
local banned_utility_list = {}
local max_equippable_grenades = 2

-- behaviour
local enforce_rules = true -- whether the rules are active
local announce_equipment_cleaning = true -- announces in chat what equipment was removed from a player's loadout, does not affect rules themselves
local announce_unknown_equipment = true -- announces in chat when unknown equipment is found in a player's loadout

-- hints
local known_guns = {
    -- Assault Rifles
    "AK_545", "AK_545_Carbine",
    "AK_762", "M4A1",
    "SA58", "SCARL",
    "SCARH", "G3",
    "HK416A5", "SCAR47",
    "AK12", "AK308",
    "QBZ95", "AUG_A3",
    -- SMGS
    "AK_9", "MK9",
    "MP5", "UMP",
    "Vector",
    -- Shotguns
    "MP133", "Remington870",
    -- Pistols
    "Glock17", "Glock20",
    "Makarov", "TT33",
    "EDC_X9",
    -- Bolt Actions
    "MosinNagant", "Remington700",
    -- Launchers
    "PSRL", "RPG7", -- dont own the PSRL, just guessing
}
local known_utility = {
    -- lethals
    "F1", "M67",
    -- knives
    "M11_EOD", "M9",
    "IZHEVSK_AKM_TYPE1",
    "IZHEVSK_AKM_TYPE2",
}
local limited_utility = {"F1", "M67"} -- these count towards max_equippable_grenades

-- constants
local slots_gun = {"primary", "secondary"}
local slots_utility = {"throwable1", "throwable2"}
local slot_order = {"primary", "secondary", "throwable1", "throwable2"}
local slot_empty = "nothing"

type cleaning_context = {
    -- warning/info about the loadout, key being the slot name
    feedback: {[string]: string},
    -- how many more grenades the player can have
    allowed_nades_left: number,
}

do -- shared
    function values_not_in_list(compare_against: {any}, values: {any}): {any}
        local not_found = {}
        for _, value in pairs(values) do
            if not table.find(compare_against, value) then
                table.insert(not_found, value)
            end
        end

        return not_found
    end
end

do -- human-facing command-line stuff

    -- rules:
    function set_banned_guns(new_bans: {string})
        -- warn the user if we're not aware of all of the guns
        local unknown_list = values_not_in_list(known_guns, new_bans)
        if #unknown_list ~= 0 then
            warn(`unknown guns in ban list: `, table.concat(unknown_list, ", "))
        end

        banned_gun_list = new_bans
    end

    function set_banned_utility(new_bans: {string})
        -- warn the user if we're not aware of all of the utility
        local unknown_list = values_not_in_list(known_utility, new_bans)
        if #unknown_list ~= 0 then
            warn(`unknown utility in ban list: `, table.concat(unknown_list, ", "))
        end

        banned_utility_list = new_bans
    end

    function set_max_grenades(max_grenades: number)
        max_equippable_grenades = math.max(max_grenades, 0)
    end


    -- behaviour:
    function should_announce_unknown_equipment(want: boolean)
        announce_unknown_equipment = want
        print(`announce_unknown_equipment = {want}`)
    end

    function should_announce_equipment_cleaning(want: boolean)
        announce_equipment_cleaning = want
        print(`announce_equipment_cleaning = {want}`)
    end

    function toggle_rules(enabled: boolean?)
        if enabled == nil then
            enabled = not enforce_rules
        end
        enforce_rules = enabled

        print(`enforce_rules = {enabled}`)
        chat.send_announcement(`GENEVA rules have been {enforce_rules and "enabled" or "disabled"}`)
    end


    -- info:
    function print_known_guns()
        print(table.concat(known_guns, ", "))
    end
    
    function print_known_utility()
        print(table.concat(known_utility, ", "))
    end
end


do -- implementation
    function format_feedback(feedback: {[string]: string}): string?
        local formatted_list = {}

        -- convert the map into an array
        for _, slot_name in pairs(slot_order) do
            local warning = feedback[slot_name]
            if not warning then
                continue
            end
            -- format text
            table.insert(formatted_list, `({slot_name}) {warning}`)
        end

        if #formatted_list == 0 then
            return nil
        end
        return table.concat(formatted_list, ", ")
    end

    function handle_slot(player: any, slot_name: string, slot_bans: {string}, slot_known: {string}, context: cleaning_context)
        local equipment = player.get_weapon_data_from_character(slot_name)
        if not equipment then
            return
        end

        -- get name of equipped weapon
        -- theyre stored differently between guns and utility
        local equipment_name = equipment.name or equipment.client_data and equipment.client_data.name

        -- check if weapon is banned
        if table.find(slot_bans, equipment_name) then
            if announce_equipment_cleaning then
                context.feedback[slot_name] = `{equipment_name} is banned`
            end
            player.set_weapon(slot_name, slot_empty)
            return
        end

        -- allowed to only carry a limited amount of this type of weapon
        if table.find(limited_utility, equipment_name) then
            if context.allowed_nades_left <= 0 then
                context.feedback[slot_name] = `max {max_equippable_grenades} grenades`
                player.set_weapon(slot_name, slot_empty)
                return
            end
            context.allowed_nades_left -= 1
            return
        end

        -- check if we're unaware of the weapon
        if announce_unknown_equipment and not table.find(slot_known, equipment_name) then
            context.feedback[slot_name] = `unknown name {equipment_name}`
            return
        end
    end

    on_player_spawned:Connect(function(player_name)
        if enforce_rules then
            return
        end

        local player = players.get(player_name)
        local context: cleaning_context = {
            feedback = {},
            allowed_nades_left = max_equippable_grenades,
        }

        -- check gun slots
        for _, slot_name in pairs(slots_gun) do
            handle_slot(
                player, slot_name,
                banned_gun_list, known_guns,
                context
            )
        end
        -- check utility slots
        for _, slot_name in pairs(slots_utility) do
            handle_slot(
                player, slot_name,
                banned_utility_list, known_utility,
                context
            )
        end

        -- print feedback
        local feedback_string = format_feedback(context.feedback)
        if feedback_string then
            chat.send_announcement(`GENEVA for [{player_name}]: {feedback_string}`)
        end
    end)
end

shared.dlcomp_geneva = {
    known_guns = known_guns,
    known_utility = known_utility,

    -- rules, human-facing
    set_banned_guns = set_banned_guns,
    set_banned_utility = set_banned_utility,
    set_max_grenades = set_max_grenades,
    -- behaviour, human-facing
    should_announce_equipment_cleaning = should_announce_equipment_cleaning,
    should_announce_unknown_equipment = should_announce_unknown_equipment,
    toggle_rules = toggle_rules,
    -- information, entierly human-facing
    print_known_guns = print_known_guns,
    print_known_utility = print_known_utility,
}
