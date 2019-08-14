-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------ sun jian Progression Missions -------------------------
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
    "ScriptEventSunJianIntroductionMission07Complete",
    true,
    function()
        core:trigger_event("ScriptEventSunJianProgressionMission01Trigger")
    end,
    false
)

-- sun jian progression mission 1
start_progression_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_victory_objective_chain_1_sun_jian",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 2000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianProgressionMission01Trigger",      -- trigger event 
    "ScriptEventSunJianProgressionMission01Complete"     -- completion event
)

-- sun jian progression mission 02
start_progression_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_victory_objective_chain_2_han_warlords",                    -- mission key
    "BECOME_WORLD_LEADER",                                  -- objective type
    nil,                                                    -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianProgressionMission01Complete",      -- trigger event 
    "ScriptEventSunJianProgressionMission02Complete"      -- completion event
)

-- sun jian progression mission 03
start_progression_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_victory_objective_chain_3_han",                     -- mission key
    "DESTROY_ALL_WORLD_LEADERS",                                  -- objective type
    nil,                                                -- conditions (single string or table of strings)
    {
        "money 10000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianProgressionMission02Complete",      -- trigger event 
    "ScriptEventSunJianProgressionMission03Complete"     -- completion event
)

-- sun jian progression mission 04
start_progression_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_victory_objective_chain_4",                     -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 95"
    }, 
    {
        "money 15000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianProgressionMission03Complete",      -- trigger event 
    ""
)