-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Kong Rong Historical Missions -------------------------
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
            core:trigger_event("ScriptEventKongRongHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

-- kong rong historical mission 01
start_historical_mission_listener(
    "3k_main_faction_kong_rong",                          -- faction key
    "3k_main_objective_kong_rong_02",                     -- mission key
    "TRADE_INCOME_AT_LEAST_X",                                  -- objective type
    {
        "total 1000"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventKongRongHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventKongRongHistoricalMission01Complete"     -- completion event
)

-- kong rong historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_kong_rong",                          -- faction key
    "3k_main_objective_kong_rong_01",                     -- mission key
    "MAKE_ALLIANCE",                                  -- objective type
    {
        "any_faction true"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventKongRongHistoricalMission01Complete",      -- trigger event 
    "ScriptEventKongRongHistoricalMission02Complete",     -- completion event
    function()
        if cm:query_faction("3k_main_faction_kong_rong"):progression_level() >= 1 then
           return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventKongRongHistoricalMission02Failure"       -- failure event
)

-- kong rong historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_kong_rong",                          -- faction key
    "3k_main_objective_kong_rong_01a",                    -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_yellow_turban_taishan"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventKongRongHistoricalMission02Failure",      -- trigger event 
    "ScriptEventKongRongHistoricalMission02Complete"      -- completion event
)

-- kong rong historical mission 03
start_historical_mission_listener(
    "3k_main_faction_kong_rong",                          -- faction key
    "3k_main_objective_kong_rong_03",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_yuan_shao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventKongRongHistoricalMission02Complete",      -- trigger event 
    "ScriptEventKongRongHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_yuan_shao"):is_dead() then
           return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventKongRongHistoricalMission03Failure"       -- failure event
)

-- kong rong historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_kong_rong",                          -- faction key
    "3k_main_objective_kong_rong_03a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_weijun_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventKongRongHistoricalMission03Failure",      -- trigger event 
    "ScriptEventKongRongHistoricalMission03Complete"      -- completion event
)

-- kong rong historical mission 04
start_historical_mission_listener(
    "3k_main_faction_kong_rong",                          -- faction key
    "3k_main_objective_kong_rong_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_cao_cao",
        "faction 3k_main_faction_sun_jian"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventKongRongHistoricalMission03Complete",      -- trigger event 
    "ScriptEventKongRongHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_cao_cao"):is_dead() and not cm:query_faction("3k_main_faction_sun_jian") then
           return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventKongRongHistoricalMission04Failure"       -- failure event
)

-- kong rong historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_kong_rong",                          -- faction key
    "3k_main_objective_kong_rong_04a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 6",
        "region 3k_main_luoyang_capital",
        "region 3k_main_chengdu_capital",
        "region 3k_main_weijun_capital",
        "region 3k_main_changsha_capital",
        "region 3k_main_youbeiping_capital",
        "region 3k_main_jianye_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventKongRongHistoricalMission04Failure",      -- trigger event 
    "ScriptEventKongRongHistoricalMission04Complete"      -- completion event
)