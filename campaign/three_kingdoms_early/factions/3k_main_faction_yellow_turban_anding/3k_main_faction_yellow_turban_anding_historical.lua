-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Gong Du Historical Missions -------------------------
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
                "introduction_incident_gong_du",
                "FactionTurnStart", 
                true,
                function(context)
                    out.interventions(" ### Intro how to play incident triggered")
					cdir_events_manager:add_prioritised_incidents( context:faction():command_queue_index(), "3k_ytr_introduction_gong_du_incident" );
                    cm:set_saved_value("start_incident_unlocked", true);
                end,
                false
    )
end

-- gong du rank 1 mission 1 (start of game)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_defeat_army",               -- mission key
    "ScriptEventGongDuMissionInitialTrigger",      -- trigger event 
    "ScriptEventGongDuMission0101Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_defeat_army",               -- mission key
    "ENGAGE_FORCE",                                  -- objective type
    {
		"requires_victory"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMissionInitialTrigger",      -- trigger event 
    "ScriptEventGongDuMission0101Complete"     -- completion event
)
]]

-- gong du rank 1 mission 2 (start of game)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_research_any_technology",               -- mission key
    "ScriptEventGongDuMissionInitialTrigger",      -- trigger event 
    "ScriptEventGongDuMission0102Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_research_any_technology",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
	{
        "technology 3k_ytr_tech_yellow_turban_land_1_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMissionInitialTrigger",      -- trigger event 
    "ScriptEventGongDuMission0102Complete"    -- completion event
)
]]

-- gong du rank 1 mission 3 (combat sub branch A pt1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_recruit_captain",               -- mission key
    "ScriptEventGongDuMission0101Complete",      -- trigger event 
    "ScriptEventGongDuMission0103Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_recruit_character",                     -- mission key
    "HIRE_CHARACTER",                                  -- objective type
    false, --any                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0101Complete",      -- trigger event 
    "ScriptEventGongDuMission0103Complete"     -- completion event
)
]]

-- gong du rank 1 mission 4 (combat sub branch A pt2)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_have_units",               -- mission key
    "ScriptEventGongDuMission0103Complete",      -- trigger event 
    "ScriptEventGongDuMission0104Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_have_units",                    -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 30"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0103Complete",      -- trigger event 
    "ScriptEventGongDuMission0104Complete"      -- completion event
)
]]

-- gong du rank 1 mission 5 (combat sub branch B pt1)

start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_capture_region",                     -- mission key
    "CAPTURE_REGIONS",                                                  -- conditions (single string or table of strings)
	false,
    {
        "money 2000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0101Complete",      -- trigger event 
    "ScriptEventGongDuMission0105Complete"     -- completion event
)

-- gong du rank 1 mission 6 (combat sub branch B pt2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                            -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_construct_any_building",                    -- mission key
    "CONSTRUCT_ANY_BUILDING",                                  -- objective type
    false,                                                  -- conditions (single string or table of strings)
    {
        "money 1500"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0105Complete",      -- trigger event 
    "ScriptEventGongDuMission0106Complete"      -- completion event
)

-- gong du rank 1 mission 7 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_reach_rank_2",               -- mission key
    "ScriptEventGongDuMission0102Complete",      -- trigger event 
    "ScriptEventGongDuMission0107Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_1_reach_rank_2",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 1",
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0102Complete",      -- trigger event 
    "ScriptEventGongDuMission0107Complete"     -- completion event
)
]]

-- gong du rank 2 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_2_reach_rank_3",               -- mission key
    "ScriptEventGongDuMission0107Complete",      -- trigger event 
    "ScriptEventGongDuMission0201Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_2_reach_rank_3",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 2",
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0107Complete",      -- trigger event 
    "ScriptEventGongDuMission0201Complete"     -- completion event
)
]]

-- gong du rank 2 mission 2 (combat branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_2_perform_assignment",               -- mission key
    "ScriptEventGongDuMission0107Complete",      -- trigger event 
    "ScriptEventGongDuMission0202Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_2_perform_assignment",                     -- mission key
    "PERFORM_ASSIGNMENT",                                  -- objective type
    {
        "character_assignment 3k_ytr_assignment_development_planning"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0107Complete",      -- trigger event 
    "ScriptEventGongDuMission0202Complete"     -- completion event
)
]]

-- gong du rank 2 mission 3 (civic branch pt 1)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_2_construct_scholar_building",                     -- mission key
    "CONSTRUCT_BUILDINGS_INCLUDING",                                  -- objective type
    {
        "total 1",
		"building_level 3k_ytr_district_government_scholars_yellow_turban_3",
		"faction 3k_main_faction_yellow_turban_anding"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0107Complete",      -- trigger event 
    "ScriptEventGongDuMission0203Complete"     -- completion event
)

-- gong du rank 2 mission 4 (combat branch pt 2)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_2_have_units",               -- mission key
    "ScriptEventGongDuMission0202Complete",      -- trigger event 
    "ScriptEventGongDuMission0204Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_2_have_units",                     -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 50"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0202Complete",      -- trigger event 
    "ScriptEventGongDuMission0204Complete"     -- completion event
)
]]

-- gong du rank 2 mission 5 (civic branch pt 2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_2_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0203Complete",      -- trigger event 
    "ScriptEventGongDuMission0205Complete"     -- completion event
)

-- gong du rank 3 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_3_reach_rank_4",               -- mission key
    "ScriptEventGongDuMission0201Complete",      -- trigger event 
    "ScriptEventGongDuMission0301Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_3_reach_rank_4",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0201Complete",      -- trigger event 
    "ScriptEventGongDuMission0301Complete"     -- completion event
)
]]

-- gong du rank 3 mission 2 (civic branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_3_research_build_to_last",               -- mission key
    "ScriptEventGongDuMission0201Complete",      -- trigger event 
    "ScriptEventGongDuMission0302Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_3_research_build_to_last",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "technology 3k_ytr_tech_yellow_turban_land_3_4"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0201Complete",      -- trigger event 
    "ScriptEventGongDuMission0302Complete"     -- completion event
)
]]

-- gong du rank 3 mission 3 (civic branch pt 2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_3_construct_caches_building",                     -- mission key
    "CONSTRUCT_BUILDINGS_INCLUDING",                                  -- objective type
    {
        "building_level 3k_ytr_district_military_yellow_turban_caches_4",
		"total 1",
		"faction 3k_main_faction_yellow_turban_anding"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 8000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0302Complete",      -- trigger event 
    "ScriptEventGongDuMission0303Complete"     -- completion event
)

-- gong du rank 3 mission 4 (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_3_have_units",               -- mission key
    "ScriptEventGongDuMission0201Complete",      -- trigger event 
    "ScriptEventGongDuMission0304Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_3_have_units",                     -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 80"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0201Complete",      -- trigger event 
    "ScriptEventGongDuMission0304Complete"     -- completion event
)
]]

-- gong du rank 3 mission 5 (generic)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_3_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 5"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 8000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0201Complete",      -- trigger event 
    "ScriptEventGongDuMission0305Complete"     -- completion event
)

-- gong du rank 4 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_4_reach_rank_5",               -- mission key
    "ScriptEventGongDuMission0301Complete",      -- trigger event 
    "ScriptEventGongDuMission0401Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_4_reach_rank_5",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 4"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0301Complete",      -- trigger event 
    "ScriptEventGongDuMission0401Complete"     -- completion event
)
]]

-- gong du rank 4 mission 2 (civic branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_4_research_rally_noble_sympathizers",               -- mission key
    "ScriptEventGongDuMission0301Complete",      -- trigger event 
    "ScriptEventGongDuMission0402Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_4_research_rally_noble_sympathizers",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "technology 3k_ytr_tech_yellow_turban_land_4_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0301Complete",      -- trigger event 
    "ScriptEventGongDuMission0402Complete"     -- completion event
)
]]

-- gong du rank 4 mission 3 (civic branch pt 2)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_4_have_virtuous_noblemen",               -- mission key
    "ScriptEventGongDuMission0402Complete",      -- trigger event 
    "ScriptEventGongDuMission0403Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_4_have_virtuous_noblemen",                     -- mission key
    "RECRUIT_N_UNITS_FROM",                                  -- objective type
    {
        "total 3",
		"unit 3k_ytr_unit_earth_virtuous_noblemen"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0402Complete",      -- trigger event 
    "ScriptEventGongDuMission0403Complete"     -- completion event
)
]]

-- gong du rank 4 mission 4 (generic)

start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_4_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 8"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 12000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0301Complete",      -- trigger event 
    "ScriptEventGongDuMission0404Complete"     -- completion event
)

-- gong du rank 5 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_5_reach_rank_6",               -- mission key
    "ScriptEventGongDuMission0401Complete",      -- trigger event 
    "ScriptEventGongDuMission0501Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_5_reach_rank_6",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 5"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0401Complete",      -- trigger event 
    "ScriptEventGongDuMission0501Complete"     -- completion event
)
]]

-- gong du rank 5 mission 2 (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_5_research_lands_frugality",               -- mission key
    "ScriptEventGongDuMission0401Complete",      -- trigger event 
    "ScriptEventGongDuMission0502Complete"     -- completion event
);
--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_5_research_lands_frugality",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "tech 3k_ytr_tech_yellow_turban_land_5_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0401Complete",      -- trigger event 
    "ScriptEventGongDuMission0502Complete"     -- completion event
)
]]

-- gong du rank 5 mission 3 (generic)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_ytr_tutorial_mission_gong_du_5_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 12"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 20000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0401Complete",      -- trigger event 
    "ScriptEventGongDuMission0503Complete"     -- completion event
)

-- gong du rank 6 final mission (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_main_victory_objective_chain_3_yellow_turban",               -- mission key
    "ScriptEventGongDuMission0501Complete",      -- trigger event 
    "ScriptEventGongDuMission0601Complete"     -- completion event
);
    
-- gong du rank 6 final mission (followup)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_anding",                          -- faction key
    "3k_main_victory_objective_chain_4",                     -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 95"
    }, 
    {
        "money 15000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventGongDuMission0601Complete",      -- trigger event 
    ""
)
    
-- cancel intro missions on faction rank up
start_historical_mission_cancel_listener(
    "3k_main_faction_yellow_turban_anding",
    {
        "3k_ytr_tutorial_mission_gong_du_1_defeat_army",
        "3k_ytr_tutorial_mission_gong_du_1_research_any_technology",
        "3k_ytr_tutorial_mission_gong_du_1_recruit_captain",
        "3k_ytr_tutorial_mission_gong_du_1_have_units",
        "3k_ytr_tutorial_mission_gong_du_1_capture_region",
        "3k_ytr_tutorial_mission_gong_du_1_construct_any_building"
    },
    "ScriptEventGongDuMission0107Complete"
)
