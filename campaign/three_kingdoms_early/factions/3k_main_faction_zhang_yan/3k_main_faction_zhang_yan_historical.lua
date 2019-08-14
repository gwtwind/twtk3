-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Zhang Yan Historical Missions -------------------------
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
            return context:faction():region_list():num_items() >= 5
        end,
        function()
            core:trigger_event("ScriptEventZhangYanHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

-- zhang yan historical mission 01
start_historical_mission_listener(
    "3k_main_faction_zhang_yan",                          -- faction key
    "3k_main_objective_zhang_yan_01",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_yuan_shao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhangYanHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventZhangYanHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_yuan_shao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventZhangYanHistoricalMission01Failure"       -- failure event
)

-- zhang yan historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_zhang_yan",                          -- faction key
    "3k_main_objective_zhang_yan_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_weijun_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhangYanHistoricalMission01Failure",      -- trigger event 
    "ScriptEventZhangYanHistoricalMission01Complete"      -- completion event
)

-- zhang yan historical mission 02
start_historical_mission_listener(
    "3k_main_faction_zhang_yan",                          -- faction key
    "3k_main_objective_zhang_yan_02",                     -- mission key
    "MAKE_ALLIANCE",                                  -- objective type
    {
        "faction 3k_main_faction_gongsun_zan"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhangYanHistoricalMission01Complete",      -- trigger event 
    "ScriptEventZhangYanHistoricalMission02Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_gongsun_zan"):is_dead() then
            return true
        end
    end,
    "ScriptEventZhangYanHistoricalMission02Failure"
)

-- zhang yan historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_zhang_yan",                          -- faction key
    "3k_main_objective_zhang_yan_02a",                    -- mission key
    "MAKE_ALLIANCE",                                  -- objective type
    {
        "any_faction true"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhangYanHistoricalMission02Failure",      -- trigger event 
    "ScriptEventZhangYanHistoricalMission02Complete"      -- completion event
)

-- zhang yan historical mission 03
start_historical_mission_listener(
    "3k_main_faction_zhang_yan",                          -- faction key
    "3k_main_objective_zhang_yan_03",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_dong_zhuo"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhangYanHistoricalMission02Complete",      -- trigger event 
    "ScriptEventZhangYanHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_dong_zhuo"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventZhangYanHistoricalMission03Failure"       -- failure event
)

-- zhang yan historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_zhang_yan",                          -- faction key
    "3k_main_objective_zhang_yan_03a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_changan_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhangYanHistoricalMission03Failure",      -- trigger event 
    "ScriptEventZhangYanHistoricalMission03Complete"      -- completion event
)

-- zhang yan historical mission 04
start_historical_mission_listener(
    "3k_main_faction_zhang_yan",                          -- faction key
    "3k_main_objective_zhang_yan_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_cao_cao",
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhangYanHistoricalMission03Complete",      -- trigger event 
    "ScriptEventZhangYanHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_cao_cao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventZhangYanHistoricalMission04Failure"       -- failure event
)

-- zhang yan historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_zhang_yan",                          -- faction key
    "3k_main_objective_zhang_yan_04a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 7",
        "region 3k_main_chenjun_capital",
        "region 3k_main_luoyang_capital",
        "region 3k_main_chengdu_capital",
        "region 3k_main_weijun_capital",
        "region 3k_main_changsha_capital",
        "region 3k_main_youbeiping_capital"
    },                                                   -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhangYanHistoricalMission04Failure",      -- trigger event 
    "ScriptEventZhangYanHistoricalMission04Complete"      -- completion event
)