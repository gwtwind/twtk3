-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Liu Biao Historical Missions -------------------------
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
            core:trigger_event("ScriptEventLiuBiaoHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

-- liu biao historical mission 01
start_historical_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_objective_liu_biao_01",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_sun_jian"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventLiuBiaoHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_sun_jian"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBiaoHistoricalMission01Failure"       -- failure event
)

-- liu biao historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_objective_liu_biao_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_changsha_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoHistoricalMission01Failure",      -- trigger event 
    "ScriptEventLiuBiaoHistoricalMission01Complete"      -- completion event
)

-- liu biao historical mission 02
start_historical_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_objective_liu_biao_02",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_yuan_shu"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoHistoricalMission01Complete",      -- trigger event 
    "ScriptEventLiuBiaoHistoricalMission02Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_yuan_shu"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBiaoHistoricalMission02Failure"       -- failure event
)

-- liu biao historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_objective_liu_biao_02a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_nanyang_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoHistoricalMission02Failure",      -- trigger event 
    "ScriptEventLiuBiaoHistoricalMission02Complete"      -- completion event
)

-- liu biao historical mission 03
start_historical_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_objective_liu_biao_03",                     -- mission key
    "CONFEDERATE_FACTIONS",                                  -- objective type
    {
        "total 1",
        "faction 3k_main_faction_liu_bei"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoHistoricalMission02Complete",      -- trigger event 
    "ScriptEventLiuBiaoHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_bei"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBiaoHistoricalMission03Failure"       -- failure event
)

-- liu biao historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_objective_liu_biao_03a",                    -- mission key
    "MAKE_ALLIANCE",                                  -- objective type
    {
        "any_faction true"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoHistoricalMission03Failure",      -- trigger event 
    "ScriptEventLiuBiaoHistoricalMission03Complete"      -- completion event
)

-- liu biao historical mission 04
start_historical_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_objective_liu_biao_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_cao_cao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoHistoricalMission03Complete",      -- trigger event 
    "ScriptEventLiuBiaoHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_cao_cao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBiaoHistoricalMission04Failure"       -- failure event
)

-- liu biao historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_objective_liu_biao_04a",                    -- mission key
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
    "ScriptEventLiuBiaoHistoricalMission04Failure",      -- trigger event 
    "ScriptEventLiuBiaoHistoricalMission04Complete"      -- completion event
)