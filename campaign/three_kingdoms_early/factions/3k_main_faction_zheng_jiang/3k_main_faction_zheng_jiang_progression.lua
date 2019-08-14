-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------ zheng jiang Progression Missions -------------------------
-------------------------------------------------------------------------------
------------------------ Created by Leif: 21/11/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

output("Progression mission script loaded for " .. cm:get_local_faction());

-- OWN_N_REGIONS_INCLUDING
-- CAPTURE_REGIONS
-- CONTROL_N_PROVINCES_INCLUDING
-- CONTROL_N_REGIONS_INCLUDING
-- BE_AT_WAR_WITH_N_FACTIONS       -- db, total, faction_record, religion_record
-- BE_AT_WAR_WITH_FACTION          -- db, faction_record
-- CONFEDERATE_FACTIONS             -- db, total, faction_record

-- start the progression missions
core:add_listener(
    "start_progression_missions",
    "ScriptEventZhengJiangIntroductionMission07Complete",
    true,
    function()
        core:trigger_event("ScriptEventZhengJiangProgressionMission01Trigger")
    end,
    false
)

-- zheng jiang progression mission 1
start_progression_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_victory_objective_chain_1_zheng_jiang",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 2000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangProgressionMission01Trigger",      -- trigger event 
    "ScriptEventZhengJiangProgressionMission01Complete"     -- completion event
)

-- zheng jiang progression mission 02
start_progression_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_victory_objective_chain_2_outlaws",                    -- mission key
    "BECOME_WORLD_LEADER",                                  -- objective type
    nil,                                                    -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangProgressionMission01Complete",      -- trigger event 
    "ScriptEventZhengJiangProgressionMission02Complete"      -- completion event
)

-- zheng jiang progression mission 03
start_progression_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_victory_objective_chain_3_outlaws",                     -- mission key
    "DESTROY_ALL_WORLD_LEADERS",                                  -- objective type
    nil,                                                -- conditions (single string or table of strings)
    {
        "money 10000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangProgressionMission02Complete",      -- trigger event 
    "ScriptEventZhengJiangProgressionMission03Complete"     -- completion event
)

-- zheng jiang progression mission 04
start_progression_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_victory_objective_chain_4",                     -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 95"
    }, 
    {
        "money 15000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangProgressionMission03Complete",      -- trigger event 
    ""
)