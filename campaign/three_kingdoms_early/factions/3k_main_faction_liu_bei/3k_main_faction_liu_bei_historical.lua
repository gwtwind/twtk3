-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Liu Bei Historical Missions -------------------------
-------------------------------------------------------------------------------
------------------------- Created by Nic: 04/09/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

output("Historical mission script loaded for " .. cm:get_local_faction());

-- start the historical missions
if not cm:get_saved_value("historical_mission_launched") then
    core:add_listener(
        "start_historical_missions",
        "ScriptEventPlayerFactionTurnStart",
        function(context)
            return context:faction():region_list():num_items() >= 3
        end,
        function()
            core:trigger_event("ScriptEventLiuBeiHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

--[[ Not using this as it collides with the start dilemma
-- liu bei historical mission 01
start_historical_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_objective_liu_bei_01",                     -- mission key
    "CONFEDERATE_FACTIONS",                                  -- objective type
    {
        "total 1",
        "faction 3k_main_faction_tao_qian"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventLiuBeiHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_tao_qian"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBeiHistoricalMission01Failure"       -- failure event
)
]]

-- liu bei historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_objective_liu_bei_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_donghai_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventLiuBeiHistoricalMission01Complete"      -- completion event
)

-- liu bei historical mission 02
start_historical_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_objective_liu_bei_02",                     -- mission key
    "CONFEDERATE_FACTIONS",                                  -- objective type
    {
        "total 1",
        "faction 3k_main_faction_liu_biao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiHistoricalMission01Complete",      -- trigger event 
    "ScriptEventLiuBeiHistoricalMission02Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_biao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBeiHistoricalMission02Failure"       -- failure event
)

-- liu bei historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_objective_liu_bei_02a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_xiangyang_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiHistoricalMission02Failure",      -- trigger event 
    "ScriptEventLiuBeiHistoricalMission02Complete"      -- completion event
)

-- liu bei historical mission 03
start_historical_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_objective_liu_bei_03",                     -- mission key
    "MAKE_ALLIANCE",                                  -- objective type
    {
        "faction 3k_main_faction_sun_jian"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiHistoricalMission02Complete",      -- trigger event 
    "ScriptEventLiuBeiHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_sun_jian"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBeiHistoricalMission03Failure"       -- failure event
)

-- liu bei historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_objective_liu_bei_03a",                    -- mission key
    "MAKE_ALLIANCE",                                  -- objective type
    {
        "any_faction true"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiHistoricalMission03Failure",      -- trigger event 
    "ScriptEventLiuBeiHistoricalMission03Complete"      -- completion event
)

-- liu bei historical mission 04
start_historical_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_objective_liu_bei_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_liu_yan"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiHistoricalMission03Complete",      -- trigger event 
    "ScriptEventLiuBeiHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_yan"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBeiHistoricalMission04Failure"       -- failure event
)

-- liu bei historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_objective_liu_bei_04a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_chengdu_capital"
    },                                                   -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiHistoricalMission04Failure",      -- trigger event 
    "ScriptEventLiuBeiHistoricalMission04Complete"      -- completion event
)