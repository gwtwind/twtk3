-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Dong Zhuo Historical Missions -------------------------
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
            return context:faction():region_list():num_items() >= 10
        end,
        function()
            core:trigger_event("ScriptEventDongZhuoHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

-- dong zhuo historical mission 01
start_historical_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_objective_dong_zhuo_01",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_sun_jian",
        "faction 3k_main_faction_yuan_shu",
        "faction 3k_main_faction_yuan_shao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventDongZhuoHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventDongZhuoHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_sun_jian"):is_dead() and  not cm:query_faction("3k_main_faction_yuan_shu"):is_dead() and not cm:query_faction("3k_main_faction_yuan_shao"):is_dead() then
           return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventDongZhuoHistoricalMission01Failure"       -- failure event
)

-- dong zhuo historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_objective_dong_zhuo_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 3",
        "region 3k_main_luoyang_capital",
        "region 3k_main_nanyang_capital",
        "region 3k_main_weijun_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventDongZhuoHistoricalMission01Failure",      -- trigger event 
    "ScriptEventDongZhuoHistoricalMission01Complete"      -- completion event
)

-- dong zhuo historical mission 02
start_historical_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_objective_dong_zhuo_02",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_cao_cao",
        "faction 3k_main_faction_liu_bei"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventDongZhuoHistoricalMission01Complete",      -- trigger event 
    "ScriptEventDongZhuoHistoricalMission02Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_cao_cao"):is_dead() and not cm:query_faction("3k_main_faction_liu_bei"):is_dead() then
           return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventDongZhuoHistoricalMission02Failure"       -- failure event
)

-- dong zhuo historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_objective_dong_zhuo_02a",                    -- mission key
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
    "ScriptEventDongZhuoHistoricalMission02Failure",      -- trigger event 
    "ScriptEventDongZhuoHistoricalMission02Complete"      -- completion event
)