-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- yuan shu Historical Missions -------------------------
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
            core:trigger_event("ScriptEventYuanShuHistoricalMission01Trigger")
            core:remove_listener("start_historical_missions");
            cm:set_saved_value("historical_mission_launched", true);
        end,
        false
    )
end

-- yuan shu historical mission 01
start_historical_mission_listener(
    "3k_main_faction_yuan_shu",                          -- faction key
    "3k_main_objective_yuan_shu_01",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_yellow_turban_rebels"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShuHistoricalMission01Trigger",      -- trigger event 
    "ScriptEventYuanShuHistoricalMission01Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_yellow_turban_rebels"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventYuanShuHistoricalMission01Failure"       -- failure event
)

-- yuan shu historical mission 01a
start_historical_mission_listener(
    "3k_main_faction_yuan_shu",                          -- faction key
    "3k_main_objective_yuan_shu_01a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_yangzhou_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShuHistoricalMission01Failure",      -- trigger event 
    "ScriptEventYuanShuHistoricalMission01Complete"      -- completion event
)

-- yuan shu historical mission 02
start_historical_mission_listener(
    "3k_main_faction_yuan_shu",                          -- faction key
    "3k_main_objective_yuan_shu_02",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_liu_yao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShuHistoricalMission01Complete",      -- trigger event 
    "ScriptEventYuanShuHistoricalMission02Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_liu_yao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventYuanShuHistoricalMission02Failure"       -- failure event
)

-- yuan shu historical mission 02a
start_historical_mission_listener(
    "3k_main_faction_yuan_shu",                          -- faction key
    "3k_main_objective_yuan_shu_02a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 3",
        "faction 3k_main_jianye_capital",
        "faction 3k_main_poyang_capital",
        "faction 3k_main_kuaiji_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_02;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShuHistoricalMission02Failure",      -- trigger event 
    "ScriptEventYuanShuHistoricalMission02Complete"      -- completion event
)

-- yuan shu historical mission 03
start_historical_mission_listener(
    "3k_main_faction_yuan_shu",                          -- faction key
    "3k_main_objective_yuan_shu_03",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_cao_cao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShuHistoricalMission02Complete",      -- trigger event 
    "ScriptEventYuanShuHistoricalMission03Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_cao_cao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventYuanShuHistoricalMission03Failure"       -- failure event
)

-- yuan shu historical mission 03a
start_historical_mission_listener(
    "3k_main_faction_yuan_shu",                          -- faction key
    "3k_main_objective_yuan_shu_03a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_chenjun_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_03;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShuHistoricalMission03Failure",      -- trigger event 
    "ScriptEventYuanShuHistoricalMission03Complete"      -- completion event
)

-- yuan shu historical mission 04
start_historical_mission_listener(
    "3k_main_faction_yuan_shu",                          -- faction key
    "3k_main_objective_yuan_shu_04",                     -- mission key
    "DESTROY_FACTION",                                  -- objective type
    {
        "faction 3k_main_faction_yuan_shao"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShuHistoricalMission03Complete",      -- trigger event 
    "ScriptEventYuanShuHistoricalMission04Complete",     -- completion event
    function()
        if not cm:query_faction("3k_main_faction_yuan_shao"):is_dead() then
            return true
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventYuanShuHistoricalMission04Failure"       -- failure event
)

-- yuan shu historical mission 04a
start_historical_mission_listener(
    "3k_main_faction_yuan_shu",                          -- faction key
    "3k_main_objective_yuan_shu_04a",                    -- mission key
    "CONTROL_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_weijun_capital",
    },                                                   -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_historical_mission_payload_04;turns 5;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventYuanShuHistoricalMission04Failure",      -- trigger event 
    "ScriptEventYuanShuHistoricalMission04Complete"      -- completion event
)