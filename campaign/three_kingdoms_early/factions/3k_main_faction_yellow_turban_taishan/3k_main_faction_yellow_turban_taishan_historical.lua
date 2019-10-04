-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Huang Shao Historical Missions -------------------------
-------------------------------------------------------------------------------
------------------------- Created by Eva: 21/09/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- start the historical missions
-- fix me to make it just start the first one on the first turn
--core:add_listener(
 --   "start_historical_missions",
 --   "ScriptEventPlayerFactionTurnStart",
 --   true,
  --  function()
   --     core:trigger_event("ScriptEventHuangShaoMissionInitialTrigger")
   -- end,
   -- false
--)

if not cm:get_saved_value("start_incident_unlocked") then 
    core:add_listener(
                "introduction_incident_huang_shao",
                "FactionTurnStart", 
                true,
                function(context)
					out.interventions(" ### Intro how to play incident triggered")
					cdir_events_manager:add_prioritised_incidents( context:faction():command_queue_index(), "3k_ytr_introduction_huang_shao_incident" );
                    cm:set_saved_value("start_incident_unlocked", true);
                end,
                false
    )
end

output("Historical mission script loaded for " .. cm:get_local_faction());

-- OWN_N_REGIONS_INCLUDING
-- CAPTURE_REGIONS
-- CONTROL_N_PROVINCES_INCLUDING
-- CONTROL_N_REGIONS_INCLUDING
-- BE_AT_WAR_WITH_N_FACTIONS       -- db, total, faction_record, religion_record
-- BE_AT_WAR_WITH_FACTION          -- db, faction_record
-- CONFEDERATE_FACTIONS             -- db, total, faction_record


-- huang shao rank 1 mission 1 (start of game)

start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_defeat_army",               -- mission key
    "ScriptEventHuangShaoMissionInitialTrigger",      -- trigger event 
    "ScriptEventHuangShaoMission0101Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_defeat_army",               -- mission key
    "ENGAGE_FORCE",                                  -- objective type
    {
		"requires_victory"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMissionInitialTrigger",      -- trigger event 
    "ScriptEventHuangShaoMission0101Complete"     -- completion event
)
]]

-- huang shao rank 1 mission 2 (start of game)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_research_any_technology",               -- mission key
    "ScriptEventHuangShaoMissionInitialTrigger",      -- trigger event 
    "ScriptEventHuangShaoMission0102Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_research_any_technology",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
	{
        "technology 3k_ytr_tech_yellow_turban_heaven_1_2"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 2000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMissionInitialTrigger",      -- trigger event 
    "ScriptEventHuangShaoMission0102Complete"    -- completion event
)
]]

-- huang shao rank 1 mission 3 (combat sub branch A pt1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_recruit_captain",               -- mission key
    "ScriptEventHuangShaoMission0101Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0103Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_recruit_character",                     -- mission key
    "HIRE_CHARACTER",                                  -- objective type
    false, --any                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0101Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0103Complete"     -- completion event
)
]]



-- huang shao rank 1 mission 4 (combat sub branch A pt2)

start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_have_units",               -- mission key
    "ScriptEventHuangShaoMission0103Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0104Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_have_units",                    -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 21"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 2500"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0103Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0104Complete"      -- completion event
)
]]

-- huang shao rank 1 mission 5 (combat sub branch B pt1)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_capture_region",                     -- mission key
    "CAPTURE_REGIONS",                                                  -- conditions (single string or table of strings)
	false,
    {
        "money 2000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0101Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0105Complete"     -- completion event
)

-- huang shao rank 1 mission 6 (combat sub branch B pt2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                            -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_construct_any_building",                    -- mission key
    "CONSTRUCT_ANY_BUILDING",                                  -- objective type
    false,                                                  -- conditions (single string or table of strings)
    {
        "money 1500"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0105Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0106Complete"      -- completion event
)

-- huang shao rank 1 mission 7 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_reach_rank_2",               -- mission key
    "ScriptEventHuangShaoMission0105Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0107Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_1_reach_rank_2",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 1",
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0102Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0107Complete"     -- completion event
)
]]

-- huang shao rank 2 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_2_reach_rank_3",               -- mission key
    "ScriptEventHuangShaoMission0107Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0201Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_2_reach_rank_3",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 2",
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0107Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0201Complete"     -- completion event
)
]]

-- huang shao rank 2 mission 2 (combat branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_2_perform_assignment",               -- mission key
    "ScriptEventHuangShaoMission0107Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0202Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_2_perform_assignment",                     -- mission key
    "PERFORM_ASSIGNMENT",                                  -- objective type
    {
        "character_assignment 3k_ytr_assignment_promote_wisdom"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 2000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0107Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0202Complete"     -- completion event
)
]]

-- huang shao rank 2 mission 3 (civic branch pt 1)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_2_construct_scholar_building",                     -- mission key
    "CONSTRUCT_BUILDINGS_INCLUDING",                                  -- objective type
    {
        "total 1",
		"building_level 3k_ytr_district_government_scholars_yellow_turban_3",
		"faction 3k_main_faction_yellow_turban_taishan"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0107Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0203Complete"     -- completion event
)

start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_2_have_units",               -- mission key
    "ScriptEventHuangShaoMission0202Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0204Complete"     -- completion event
);

--[[

-- huang shao rank 2 mission 5 (civic branch pt 2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_2_have_units",                     -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 50"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0202Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0204Complete"     -- completion event
)
]]

start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_2_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0203Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0205Complete"     -- completion event
)

-- huang shao rank 3 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_3_reach_rank_4",               -- mission key
    "ScriptEventHuangShaoMission0201Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0301Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_3_reach_rank_4",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0201Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0301Complete"     -- completion event
)
]]

-- huang shao rank 3 mission 2 (civic branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_3_research_harmonious_architecture",               -- mission key
    "ScriptEventHuangShaoMission0201Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0302Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_3_research_harmonious_architecture",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "technology 3k_ytr_tech_yellow_turban_heaven_3_4"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0201Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0302Complete"     -- completion event
)
]]

-- huang shao rank 3 mission 3 (civic branch pt 2)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_3_construct_garden_building",                     -- mission key
    "CONSTRUCT_BUILDINGS_INCLUDING",                                  -- objective type
    {
        "building_level 3k_ytr_district_government_yellow_turban_gardens_4",
		"total 1",
		"faction 3k_main_faction_yellow_turban_taishan"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 8000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0302Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0303Complete"     -- completion event
)

-- huang shao rank 3 mission 4 (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_3_have_units",               -- mission key
    "ScriptEventHuangShaoMission0201Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0304Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_3_have_units",                     -- mission key
    "HAVE_N_UNITS_IN_ARMY",                                  -- objective type
    {
        "total 80"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0201Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0304Complete"     -- completion event
)
]]

-- huang shao rank 3 mission 5 (generic)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_3_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 5"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 8000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0201Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0305Complete"     -- completion event
)


-- huang shao rank 4 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_4_reach_rank_5",               -- mission key
    "ScriptEventHuangShaoMission0301Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0401Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_4_reach_rank_5",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 4"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0301Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0401Complete"     -- completion event
)
]]

-- huang shao rank 4 mission 2 (civic branch pt 1)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_4_research_martial_enlightenment",               -- mission key
    "ScriptEventHuangShaoMission0301Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0402Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_4_research_martial_enlightenment",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "technology 3k_ytr_tech_yellow_turban_heaven_4_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0301Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0402Complete"     -- completion event
)
]]

-- huang shao rank 4 mission 3 (civic branch pt 2)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_4_have_scholar_warriors",               -- mission key
    "ScriptEventHuangShaoMission0402Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0403Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_4_have_scholar_warriors",                     -- mission key
    "RECRUIT_N_UNITS_FROM",                                  -- objective type
    {
        "total 3",
		"unit 3k_ytr_unit_metal_scholar_warriors"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0402Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0403Complete"     -- completion event
)
]]

-- huang shao rank 4 mission 4 (generic)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_4_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 8"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 12000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0301Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0404Complete"     -- completion event
)

-- huang shao rank 5 mission 1 (progression)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_5_reach_rank_6",               -- mission key
    "ScriptEventHuangShaoMission0401Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0501Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_5_reach_rank_6",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "faction_level 5"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0401Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0501Complete"     -- completion event
)
]]

-- huang shao rank 5 mission 2 (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_5_research_heavens_humility",               -- mission key
    "ScriptEventHuangShaoMission0401Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0502Complete"     -- completion event
);

--[[
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_5_research_heavens_humility",                     -- mission key
    "RESEARCH_TECHNOLOGY",                                  -- objective type
    {
        "tech 3k_ytr_tech_yellow_turban_heaven_5_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 200"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0401Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0502Complete"     -- completion event
)
]]

-- huang shao rank 5 mission 3 (generic)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_ytr_tutorial_mission_huang_shao_5_own_provinces",                     -- mission key
    "OWN_N_PROVINCES",                                  -- objective type
    {
        "total 12"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 25000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0401Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0503Complete"     -- completion event
)

-- huang shao rank 6 final mission (generic)
start_historical_mission_db_listener(
	"3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_main_victory_objective_chain_3_yellow_turban",               -- mission key
    "ScriptEventHuangShaoMission0501Complete",      -- trigger event 
    "ScriptEventHuangShaoMission0601Complete"     -- completion event
);

-- huang shao rank 6 final mission (followup)
start_historical_mission_listener(
    "3k_main_faction_yellow_turban_taishan",                          -- faction key
    "3k_main_victory_objective_chain_4",                     -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 95"
    }, 
    {
        "money 15000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventHuangShaoMission0601Complete",      -- trigger event 
    ""
)
    
-- cancel intro missions on faction rank up
start_historical_mission_cancel_listener(
    "3k_main_faction_yellow_turban_taishan",
    {
        "3k_ytr_tutorial_mission_huang_shao_1_defeat_army",
        "3k_ytr_tutorial_mission_huang_shao_1_recruit_captain",
        "3k_ytr_tutorial_mission_huang_shao_1_have_units",
        "3k_ytr_tutorial_mission_huang_shao_1_capture_region"
    },
    "ScriptEventHuangShaoMission0107Complete"
)
    

