-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Yuan Shao Historical Missions -------------------------
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
            core:trigger_event("ScriptEventYuanShaoHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end
   
-- yuan shao historical mission 01
start_historical_mission_listener(
    "3k_main_faction_yuan_shao",                          -- faction key
    "3k_main_objective_yuan_shao_01",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_han_fu"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                               -- mission rewards (table of strings)
    "ScriptEventYuanShaoHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventYuanShaoHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_han_fu"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventYuanShaoHistoricalMission01Failure"       -- failure event
)

-- yuan shao historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_yuan_shao",                          -- faction key
    "3k_main_objective_yuan_shao_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_anping_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShaoHistoricalMission01Failure",      -- trigger event 
    "ScriptEventYuanShaoHistoricalMission01Complete"      -- completion event
)

-- yuan shao historical mission 02
start_historical_mission_listener(
    "3k_main_faction_yuan_shao",                          -- faction key
    "3k_main_objective_yuan_shao_03",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_gongsun_zan"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShaoHistoricalMission01Complete",      -- trigger event 
    "ScriptEventYuanShaoHistoricalMission02Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_gongsun_zan"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventYuanShaoHistoricalMission02Failure"       -- failure event
)

-- yuan shao historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_yuan_shao",                          -- faction key
    "3k_main_objective_yuan_shao_03a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_youbeiping_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShaoHistoricalMission02Failure",      -- trigger event 
    "ScriptEventYuanShaoHistoricalMission02Complete"      -- completion event
)

-- yuan shao historical mission 03
start_historical_mission_listener(
    "3k_main_faction_yuan_shao",                          -- faction key
    "3k_main_objective_yuan_shao_02",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_zhang_yan"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShaoHistoricalMission02Complete",      -- trigger event 
    "ScriptEventYuanShaoHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_zhang_yan"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventYuanShaoHistoricalMission03Failure"       -- failure event
)

-- yuan shao historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_yuan_shao",                          -- faction key
    "3k_main_objective_yuan_shao_02a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 2",
        "region 3k_main_shangdang_capital",
        "region 3k_main_yanmen_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShaoHistoricalMission03Failure",      -- trigger event 
    "ScriptEventYuanShaoHistoricalMission03Complete"      -- completion event
)

-- yuan shao historical mission 04
start_historical_mission_listener(
    "3k_main_faction_yuan_shao",                          -- faction key
    "3k_main_objective_yuan_shao_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_liu_bei",
        "faction 3k_main_faction_cao_cao",
        "faction 3k_main_faction_sun_jian"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShaoHistoricalMission03Complete",      -- trigger event 
    "ScriptEventYuanShaoHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_bei"):is_dead() and not cm:query_faction("3k_main_faction_sun_jian"):is_dead() and not cm:query_faction("3k_main_faction_cao_cao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventYuanShaoHistoricalMission04Failure"       -- failure event
)

-- yuan shao historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_yuan_shao",                          -- faction key
    "3k_main_objective_yuan_shao_04a",                    -- mission key
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
    "ScriptEventYuanShaoHistoricalMission04Failure",      -- trigger event 
    "ScriptEventYuanShaoHistoricalMission04Complete"      -- completion event
)