-- usage:
  -- just put this in your server autorun: require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/rulesets/default.luau")
  -- if you think you wanna edit it, just copy this entire file into your server autorun, no automatic updates then tho
-- intentionally written in a way where you can run it multiple times safely

-- load all modules
if not shared.dlcomp_all_loaded then
	require("https://raw.githubusercontent.com/LegitACarWithAGun/deadlinecomp-mods/refs/heads/main/init.luau")
end


local geneva = shared.dlcomp_geneva

-- ruleset
geneva.set_banned_weapons({
	"RPG7",
	"PSRL",
	"M67",
	-- "F1",
})
geneva.set_max_grenades(1)

-- behavior
geneva.should_announce_equipment_cleaning(true)
geneva.should_announce_unknown_equipment(true)


-- quality of life sharedvars
sharedvars.gm_team_balancing_threshold = 9999
sharedvars.chat_tips_enabled = false


-- finish
geneva.toggle_rules(true) -- this also announces the ruleset in chat
