-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------ yellow turban rebels Progression Missions -------------------------
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


-- yellow turban rebels progression mission 1
start_progression_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_main_victory_objective_chain_1_he_yi",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "money 2000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYellowTurbanRebelsProgressionMission01Trigger",      -- trigger event 
    "ScriptEventYellowTurbanRebelsProgressionMission01Complete"     -- completion event
)

-- yellow turban rebels progression mission 02
start_progression_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_main_victory_objective_chain_2_yellow_turban",                    -- mission key
    "BECOME_WORLD_LEADER",                                  -- objective type
    nil,                                                    -- conditions (single string or table of strings)
    {
        "money 5000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYellowTurbanRebelsProgressionMission01Complete",      -- trigger event 
    "ScriptEventYellowTurbanRebelsProgressionMission02Complete"      -- completion event
)

-- yellow turban rebels progression mission 03
start_progression_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_main_victory_objective_chain_3_yellow_turban",                     -- mission key
    "DESTROY_ALL_WORLD_LEADERS",                                  -- objective type
    nil,                                                -- conditions (single string or table of strings)
    {
        "money 10000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYellowTurbanRebelsProgressionMission02Complete",      -- trigger event 
    "ScriptEventYellowTurbanRebelsProgressionMission03Complete"     -- completion event
)

-- yellow turban rebels progression mission 04
start_progression_mission_listener(
    "3k_main_faction_yellow_turban_rebels",                          -- faction key
    "3k_main_victory_objective_chain_4",                     -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 95"
    }, 
    {
        "money 15000"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYellowTurbanRebelsProgressionMission03Complete",      -- trigger event 
    ""
)

-- start the progression missions
core:add_listener(
    "start_progression_missions",
    "ScriptEventStartProgressionMissions",
    true,
    function()
        core:trigger_event("ScriptEventYellowTurbanRebelsProgressionMission01Trigger")
    end,
    false
)
    

