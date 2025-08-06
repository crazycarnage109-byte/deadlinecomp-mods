--- used by arg-parser.luau
export type command_parse_info = {
	--- all the text After the current argument
    remaining_text: string,
    --- the string the return value value was made from, the raw argument section, useful if you wanna re-parse after a fail
    converted_from: string,
}

declare shared: {
	[string]: any,
	dlcomp_command_bot: {
		add_command: (name: string, explanation: string, callback: (args: string) -> string?) -> nil,
	},
	dlcomp_parser: {
		get_string: (args: string) -> (string, command_parse_info),
		get_number: (args: string, default: number?, min: number?, max: number?) -> (number?, command_parse_info),
		get_player: (args: string, match_exact: boolean?) -> (player?, command_parse_info),
	},
	dlcomp_countdown: {
		countdown: (duration: number) -> nil,
		cancel_countdown: () -> nil,
		freeze: () -> nil,
		unfreeze: () -> nil,
	
		finished: Signal<>,
	},
	dlcomp_geneva: {
		-- rules, human-facing
		set_banned_weapons: (new_bans: {string}) -> nil,
		set_max_grenades: (max_grenades: number) -> nil,
		-- behaviour, human-facing
		should_announce_equipment_cleaning: (want: boolean) -> nil,
		should_announce_unknown_equipment: (want: boolean) -> nil,
		toggle_rules: (enabled: boolean?) -> nil,
		-- information, entierly human-facing
		print_known_weapons: () -> nil,
		announce_ruleset: () -> nil,
	},
	dlcomp_round: {},
}