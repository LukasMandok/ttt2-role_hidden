L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[STALKER.name] = "Stalker"
L[STALKER.defaultTeam] = "Team Stalker"
L["hilite_win_" .. STALKER.defaultTeam] = "Team Stalkers Win"
L["info_popup_" .. STALKER.name] = [[You are the Stalker! 
Press Reload to transform permanently and begin killing.]]
L["body_found_" .. STALKER.abbr] = "They were a Stalker!"
L["search_role_" .. STALKER.abbr] = "This person was a Stalker!"
L["target_" .. STALKER.name] = "Stalker"
L["ttt2_desc_" .. STALKER.name] = [[The Stalker is a neutral killer. By unleashing their power, they gain speed and invisibility but 
are limited to their claws and telekinesis.]]

--Weapons
L["weapon_ttt_slk_nade_name"] = "Telekinesis"
L["weapon_ttt_slk_knife_name"] = "Claws"

--EPOP
L["slk_epop_title"] = "{nick} is the Stalker!"
L["slk_epop_desc"] = "Kill them before they kill you all!"
L["slk_epop_defeat_title"] = "{nick} the Stalker has been defeated!"
L["slk_epop_defeat_desc"] = "You survived the Stalker threat."

--EVENT STRINGS
L["slk_activate_title"] = "A Stalker activated their power"
L["slk_activate_desc"] = "{nick} entered Stalker mode"
L["slk_defeat_title"] = "A Stalker has been defeated"
L["slk_defeat_score"] = "Stalker Defeated: "
L["tooltip_slk_defeat_score"] = "Stalker Defeated: {score}"

