-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Cao Cao Historical Missions -------------------------
-------------------------------------------------------------------------------
------------------------- Created by Nic: 04/09/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

output("Historical mission script loaded for " .. cm:get_local_faction());

-- OWN_N_REGIONS_INCLUDING
-- CAPTURE_REGIONS
-- CONTROL_N_PROVINCES_INCLUDING
-- CONTROL_N_REGIONS_INCLUDING
-- BE_AT_WAR_WITH_N_FACTIONS       -- db, total, faction_record, religion_record
-- BE_AT_WAR_WITH_FACTION          -- db, faction_record
-- CONFEDERATE_FACTIONS             -- db, total, faction_record

-- start the historical missions
if not cm:get_saved_value("historical_mission_launched") then
    core:add_listener(
        "start_historical_missions",
        "ScriptEventPlayerFactionTurnStart",
        function(context)
            return context:faction():region_list():num_items() >= 4
        end,
        function()
            core:trigger_event("ScriptEventCaoCaoHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

-- cao cao historical mission 01
start_historical_mission_listener(
    "3k_main_faction_cao_cao",                          -- faction key
    "3k_main_objective_cao_cao_01",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_tao_qian"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventCaoCaoHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventCaoCaoHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_tao_qian"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventCaoCaoHistoricalMission01Failure"       -- failure event
)

-- cao cao historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_cao_cao",                          -- faction key
    "3k_main_objective_cao_cao_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_donghai_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventCaoCaoHistoricalMission01Failure",      -- trigger event 
    "ScriptEventCaoCaoHistoricalMission01Complete"      -- completion event
)

-- cao cao historical mission 02
start_historical_mission_listener(
    "3k_main_faction_cao_cao",                          -- faction key
    "3k_main_objective_cao_cao_02",                     -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_luoyang_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventCaoCaoHistoricalMission01Complete",      -- trigger event 
    "ScriptEventCaoCaoHistoricalMission02Complete"     -- completion event
)

-- cao cao historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_cao_cao",                          -- faction key
    "3k_main_objective_cao_cao_02a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 3",
        "region 3k_main_luoyang_capital",
        "region 3k_main_yingchuan_capital",
        "region 3k_main_pengchang_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventCaoCaoHistoricalMission02Failure",      -- trigger event 
    "ScriptEventCaoCaoHistoricalMission02Complete"      -- completion event
)

-- cao cao historical mission 03
start_historical_mission_listener(
    "3k_main_faction_cao_cao",                          -- faction key
    "3k_main_objective_cao_cao_03",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_yuan_shao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventCaoCaoHistoricalMission02Complete",      -- trigger event 
    "ScriptEventCaoCaoHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_yuan_shao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventCaoCaoHistoricalMission03Failure"       -- failure event
)

-- cao cao historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_cao_cao",                          -- faction key
    "3k_main_objective_cao_cao_03a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 2",
        "region 3k_main_weijun_capital",
        "region 3k_main_youbeiping_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventCaoCaoHistoricalMission03Failure",      -- trigger event 
    "ScriptEventCaoCaoHistoricalMission03Complete"      -- completion event
)

-- cao cao historical mission 04
start_historical_mission_listener(
    "3k_main_faction_cao_cao",                          -- faction key
    "3k_main_objective_cao_cao_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_liu_bei",
        "faction 3k_main_faction_sun_jian"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventCaoCaoHistoricalMission03Complete",      -- trigger event 
    "ScriptEventCaoCaoHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_bei"):is_dead() and not cm:query_faction("3k_main_faction_sun_jian"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventCaoCaoHistoricalMission04Failure"       -- failure event
)

-- cao cao historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_cao_cao",                          -- faction key
    "3k_main_objective_cao_cao_04a",                    -- mission key
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
    "ScriptEventCaoCaoHistoricalMission04Failure",      -- trigger event 
    "ScriptEventCaoCaoHistoricalMission04Complete"      -- completion event
)