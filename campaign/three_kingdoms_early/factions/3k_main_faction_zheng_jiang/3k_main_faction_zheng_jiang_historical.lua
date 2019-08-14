-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- zheng jiang Historical Missions -------------------------
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
            core:trigger_event("ScriptEventZhengJiangHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

-- zheng jiang historical mission 01
start_historical_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_objective_zheng_jiang_01",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_zhang_yan"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventZhengJiangHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_zhang_yan"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventZhengJiangHistoricalMission01Failure"       -- failure event
)

-- zheng jiang historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_objective_zheng_jiang_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_shangdang_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangHistoricalMission01Failure",      -- trigger event 
    "ScriptEventZhengJiangHistoricalMission01Complete"      -- completion event
)

-- zheng jiang historical mission 02
start_historical_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_objective_zheng_jiang_02",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_yuan_shao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangHistoricalMission01Complete",      -- trigger event 
    "ScriptEventZhengJiangHistoricalMission02Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_yuan_shao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventZhengJiangHistoricalMission02Failure"       -- failure event
)

-- zheng jiang historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_objective_zheng_jiang_02a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_weijun_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangHistoricalMission02Failure",      -- trigger event 
    "ScriptEventZhengJiangHistoricalMission02Complete"      -- completion event
)

-- zheng jiang historical mission 03
start_historical_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_objective_zheng_jiang_03",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_han_empire"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangHistoricalMission02Complete",      -- trigger event 
    "ScriptEventZhengJiangHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_han_empire"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventZhengJiangHistoricalMission03Failure"       -- failure event
)

-- zheng jiang historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_objective_zheng_jiang_03a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_luoyang_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangHistoricalMission03Failure",      -- trigger event 
    "ScriptEventZhengJiangHistoricalMission03Complete"      -- completion event
)

-- zheng jiang historical mission 04
start_historical_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_objective_zheng_jiang_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_liu_bei",
        "faction 3k_main_faction_liu_yan",
        "faction 3k_main_faction_liu_biao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangHistoricalMission03Complete",      -- trigger event 
    "ScriptEventZhengJiangHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_bei"):is_dead() and not cm:query_faction("3k_main_faction_liu_biao"):is_dead() and not cm:query_faction("3k_main_faction_liu_yan"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventZhengJiangHistoricalMission04Failure"       -- failure event
)

-- zheng jiang historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_zheng_jiang",                          -- faction key
    "3k_main_objective_zheng_jiang_04a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 6",
        "region 3k_main_luoyang_capital",
        "region 3k_main_chengdu_capital",
        "region 3k_main_weijun_capital",
        "region 3k_main_changsha_capital",
        "region 3k_main_youbeiping_capital",
        "region 3k_main_jianye_capital"
    },                                                   -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventZhengJiangHistoricalMission04Failure",      -- trigger event 
    "ScriptEventZhengJiangHistoricalMission04Complete"      -- completion event
)