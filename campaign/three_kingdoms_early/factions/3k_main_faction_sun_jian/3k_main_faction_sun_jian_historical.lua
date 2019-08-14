-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Sun Jian Historical Missions -------------------------
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
            core:trigger_event("ScriptEventSunJianHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

-- sun jian historical mission 01
start_historical_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_objective_sun_jian_01",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_huang_zu",
        "faction 3k_main_faction_cai_mao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventSunJianHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_huang_zu"):is_dead() and not cm:query_faction("3k_main_faction_cai_mao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventSunJianHistoricalMission01Failure"       -- failure event
)

-- sun jian historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_objective_sun_jian_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_luoyang_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianHistoricalMission01Failure",      -- trigger event 
    "ScriptEventSunJianHistoricalMission01Complete"      -- completion event
)

-- sun jian historical mission 02
start_historical_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_objective_sun_jian_02",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_liu_yao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianHistoricalMission01Complete",      -- trigger event 
    "ScriptEventSunJianHistoricalMission02Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_yao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventSunJianHistoricalMission02Failure"       -- failure event
)

-- sun jian historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_objective_sun_jian_02a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_jianye_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianHistoricalMission02Failure",      -- trigger event 
    "ScriptEventSunJianHistoricalMission02Complete"      -- completion event
)

-- sun jian historical mission 03
start_historical_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_objective_sun_jian_03",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_shi_xie"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianHistoricalMission02Complete",      -- trigger event 
    "ScriptEventSunJianHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_shi_xie"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventSunJianHistoricalMission03Failure"       -- failure event
)

-- sun jian historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_objective_sun_jian_03a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 2",
        "region 3k_main_kuaiji_capital",
        "region 3k_main_dongou_capital",
        "region 3k_main_jianan_capital",
        "region 3k_main_hepu_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianHistoricalMission03Failure",      -- trigger event 
    "ScriptEventSunJianHistoricalMission03Complete"      -- completion event
)

-- sun jian historical mission 04
start_historical_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_objective_sun_jian_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_liu_bei",
        "faction 3k_main_faction_cao_cao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianHistoricalMission03Complete",      -- trigger event 
    "ScriptEventSunJianHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_bei"):is_dead() and not cm:query_faction("3k_main_faction_cao_cao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventSunJianHistoricalMission04Failure"       -- failure event
)

-- sun jian historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_objective_sun_jian_04a",                    -- mission key
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
    "ScriptEventSunJianHistoricalMission04Failure",      -- trigger event 
    "ScriptEventSunJianHistoricalMission04Complete"      -- completion event
)