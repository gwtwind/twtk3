-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- He Yi Historical Missions -------------------------
-------------------------------------------------------------------------------
------------------------- Created by Eva: 26/09/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

output("Historical mission script loaded for " .. cm:get_local_faction());

-- OWN_N_REGIONS_INCLUDING
-- CAPTURE_REGIONS
-- CONTROL_N_PROVINCES_INCLUDING
-- CONTROL_N_REGIONS_INCLUDING
-- BE_AT_WAR_WITH_N_FACTIONS       -- db, total, faction_record, religion_record
-- BE_AT_WAR_WITH_FACTION          -- db, faction_record
-- CONFEDERATE_FACTIONS             -- db, total, faction_record

if not cm:get_saved_value("start_incident_unlocked") then 
    core:add_listener(
                "introduction_incident_he_yi",
                "FactionTurnStart", 
                true,
                function(context)
                    out.interventions(" ### Intro how to play incident triggered")
					cdir_events_manager:add_prioritised_incidents( context:faction():command_queue_index(), "3k_ytr_introduction_he_yi_incident" );
                    cm:set_saved_value("start_incident_unlocked", true);
                end,
                false
    )
end

-- He Yi rank 1 mission 1 (start of game)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_defeat_army",               -- mission key
    "ScriptEventHeYiMissionInitialTrigger",      -- trigger event 
    "ScriptEventHeYiMission0101Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_defeat_army",               -- mission key
    "ENGAGE_FORCE",                                  -- objective type
    {
		"requires_victory"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMissionInitialTrigger",      -- trigger event 
    "ScriptEventHeYiMission0101Complete"     -- completion event
)
]]

-- He Yi rank 1 mission 2 (start of game)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_research_any_technology",               -- mission key
    "ScriptEventHeYiMissionInitialTrigger",      -- trigger event 
    "ScriptEventHeYiMission0102Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_research_any_technology",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
	{
        "technology 3k_ytr_tech_yellow_turban_people_1_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMissionInitialTrigger",      -- trigger event 
    "ScriptEventHeYiMission0102Complete"    -- completion event
)
]]

-- He Yi rank 1 mission 3 (combat sub branch A pt1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_recruit_captain",               -- mission key
    "ScriptEventHeYiMission0101Complete",      -- trigger event 
    "ScriptEventHeYiMission0103Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_recruit_character",                     -- mission key
    "HIRE_CHARACTER",                                  -- objective type
    false, --any                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0101Complete",      -- trigger event 
    "ScriptEventHeYiMission0103Complete"     -- completion event
)
]]

-- He Yi rank 1 mission 4 (combat sub branch A pt2)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_have_units",               -- mission key
    "ScriptEventHeYiMission0103Complete",      -- trigger event 
    "ScriptEventHeYiMission0104Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_have_units",                    -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 30"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0103Complete",      -- trigger event 
    "ScriptEventHeYiMission0104Complete"      -- completion event
)
]]

-- He Yi rank 1 mission 5 (combat sub branch B pt1)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_capture_region",                     -- mission key
    "CAPTURE_REGIONS",                                                  -- conditions (single string or table of strings)
	false,
    {
        "money 2000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0101Complete",      -- trigger event 
    "ScriptEventHeYiMission0105Complete"     -- completion event
)

-- He Yi rank 1 mission 6 (combat sub branch B pt2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                            -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_construct_any_building",                    -- mission key
    "CONSTRUCT_ANY_BUILDING",                                  -- objective type
    false,                                                  -- conditions (single string or table of strings)
    {
        "money 1500"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0105Complete",      -- trigger event 
    "ScriptEventHeYiMission0106Complete"      -- completion event
)

-- He Yi rank 1 mission 7 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_reach_rank_2",               -- mission key
    "ScriptEventHeYiMission0105Complete",      -- trigger event 
    "ScriptEventHeYiMission0107Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_1_reach_rank_2",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 1",
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0102Complete",      -- trigger event 
    "ScriptEventHeYiMission0107Complete"     -- completion event
)
]]

-- He Yi rank 2 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_2_reach_rank_3",               -- mission key
    "ScriptEventHeYiMission0107Complete",      -- trigger event 
    "ScriptEventHeYiMission0201Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_2_reach_rank_3",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 2",
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0107Complete",      -- trigger event 
    "ScriptEventHeYiMission0201Complete"     -- completion event
)
]]

-- He Yi rank 2 mission 2 (combat branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_2_perform_assignment",               -- mission key
    "ScriptEventHeYiMission0107Complete",      -- trigger event 
    "ScriptEventHeYiMission0201Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_2_perform_assignment",                     -- mission key
    "PERFORM_ASSIGNMENT",                                  -- objective type
    {
        "character_assignment 3k_ytr_assignment_employ_volunteers"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0107Complete",      -- trigger event 
    "ScriptEventHeYiMission0202Complete"     -- completion event
)
]]

-- He Yi rank 2 mission 3 (civic branch pt 1)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_2_construct_scholar_building",                     -- mission key
    "CONSTRUCT_BUILDINGS_INCLUDING",                                  -- objective type
    {
        "total 1",
		"building_level 3k_ytr_district_government_scholars_yellow_turban_3",
		"faction 3k_main_faction_yellow_turban_rebels"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0107Complete",      -- trigger event 
    "ScriptEventHeYiMission0203Complete"     -- completion event
)

-- He Yi rank 2 mission 4 (combat branch pt 2)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_2_have_units",               -- mission key
    "ScriptEventHeYiMission0202Complete",      -- trigger event 
    "ScriptEventHeYiMission0204Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_2_have_units",                     -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 50"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0202Complete",      -- trigger event 
    "ScriptEventHeYiMission0204Complete"     -- completion event
)
]]

-- He Yi rank 2 mission 5 (civic branch pt 2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_2_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0203Complete",      -- trigger event 
    "ScriptEventHeYiMission0205Complete"     -- completion event
)

-- He Yi rank 3 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_3_reach_rank_4",               -- mission key
    "ScriptEventHeYiMission0201Complete",      -- trigger event 
    "ScriptEventHeYiMission0301Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_3_reach_rank_4",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0201Complete",      -- trigger event 
    "ScriptEventHeYiMission0301Complete"     -- completion event
)
]]

-- He Yi rank 3 mission 2 (civic branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_3_research_flawless_construction",               -- mission key
    "ScriptEventHeYiMission0201Complete",      -- trigger event 
    "ScriptEventHeYiMission0302Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_3_research_flawless_construction",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "technology 3k_ytr_tech_yellow_turban_people_3_4"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0201Complete",      -- trigger event 
    "ScriptEventHeYiMission0302Complete"     -- completion event
)
]]

-- He Yi rank 3 mission 3 (civic branch pt 2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_3_construct_healer_building",                     -- mission key
    "CONSTRUCT_BUILDINGS_INCLUDING",                                  -- objective type
    {
        "building_level 3k_ytr_district_government_rural_healers_4",
		"total 1",
		"faction 3k_main_faction_yellow_turban_rebels"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 8000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0302Complete",      -- trigger event 
    "ScriptEventHeYiMission0303Complete"     -- completion event
)

-- He Yi rank 3 mission 4 (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_3_have_units",               -- mission key
    "ScriptEventHeYiMission0201Complete",      -- trigger event 
    "ScriptEventHeYiMission0304Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_3_have_units",                     -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 80"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0201Complete",      -- trigger event 
    "ScriptEventHeYiMission0304Complete"     -- completion event
)
]]

-- He Yi rank 3 mission 5 (generic)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_3_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 5"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 8000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0201Complete",      -- trigger event 
    "ScriptEventHeYiMission0305Complete"     -- completion event
)

-- He Yi rank 4 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_4_reach_rank_5",               -- mission key
    "ScriptEventHeYiMission0301Complete",      -- trigger event 
    "ScriptEventHeYiMission0401Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_4_reach_rank_5",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 4"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0301Complete",      -- trigger event 
    "ScriptEventHeYiMission0401Complete"     -- completion event
)
]]

-- He Yi rank 4 mission 2 (civic branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_4_research_appoint_peacekeepers",               -- mission key
    "ScriptEventHeYiMission0301Complete",      -- trigger event 
    "ScriptEventHeYiMission0402Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_4_research_appoint_peacekeepers",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "technology 3k_ytr_tech_yellow_turban_people_4_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0301Complete",      -- trigger event 
    "ScriptEventHeYiMission0402Complete"     -- completion event
)
]]

-- He Yi rank 4 mission 3 (civic branch pt 2)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_4_have_arm_of_peace",               -- mission key
    "ScriptEventHeYiMission0402Complete",      -- trigger event 
    "ScriptEventHeYiMission0403Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_4_have_arm_of_peace",                     -- mission key
    "RECRUIT_N_UNITS_FROM",                                  -- objective type
    {
        "total 3",
		"unit 3k_ytr_unit_metal_arm_of_the_supreme_peace"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0402Complete",      -- trigger event 
    "ScriptEventHeYiMission0403Complete"     -- completion event
)
]]

-- He Yi rank 4 mission 4 (generic)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_4_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 8"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 12000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0301Complete",      -- trigger event 
    "ScriptEventHeYiMission0404Complete"     -- completion event
)

-- He Yi rank 5 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_5_reach_rank_6",               -- mission key
    "ScriptEventHeYiMission0401Complete",      -- trigger event 
    "ScriptEventHeYiMission0501Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_5_reach_rank_6",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 5"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0401Complete",      -- trigger event 
    "ScriptEventHeYiMission0501Complete"     -- completion event
)
]]

-- He Yi rank 5 mission 2 (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_5_research_peoples_compassion",               -- mission key
    "ScriptEventHeYiMission0401Complete",      -- trigger event 
    "ScriptEventHeYiMission0502Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_5_research_peoples_compassion",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "tech 3k_ytr_tech_yellow_turban_people_5_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0401Complete",      -- trigger event 
    "ScriptEventHeYiMission0502Complete"     -- completion event
)
]]

-- He Yi rank 5 mission 3 (generic)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_ytr_tutorial_mission_he_yi_5_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 12"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 25000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0401Complete",      -- trigger event 
    "ScriptEventHeYiMission0503Complete"     -- completion event
)

-- he yi rank 6 final mission (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_main_victory_objective_chain_3_yellow_turban",               -- mission key
    "ScriptEventHeYiMission0501Complete",      -- trigger event 
    "ScriptEventHeYiMission0601Complete"     -- completion event
);

-- he yi rank 6 final mission (followup)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_main_victory_objective_chain_4",                     -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 95"
    }, 
    {
        "money 15000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHeYiMission0601Complete",      -- trigger event 
    ""
)
    
-- cancel intro missions on faction rank up
start_historical_mission_cancel_listener(
    "3k_main_faction_yellow_turban_rebels",
    {
        "3k_ytr_tutorial_mission_he_yi_1_defeat_army",
        "3k_ytr_tutorial_mission_he_yi_1_recruit_captain",
        "3k_ytr_tutorial_mission_he_yi_1_have_units",
        "3k_ytr_tutorial_mission_he_yi_1_capture_region"
    },
    "ScriptEventHeYiMission0107Complete"
)
    

