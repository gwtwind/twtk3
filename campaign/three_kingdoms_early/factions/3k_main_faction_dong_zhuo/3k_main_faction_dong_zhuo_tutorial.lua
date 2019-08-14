-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Dong Zhuo Tutorial Missions -------------------------
-------------------------------------------------------------------------------
------------------------- Created by Nic: 29/05/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

output("Introduction mission script loaded for " .. cm:get_local_faction());

function should_start_tutorial_missions()
	return not core:is_tweaker_set("FORCE_DISABLE_TUTORIAL");
end;

if not cm:get_saved_value("start_incident_unlocked") then 
    core:add_listener(
                "introduction_incident_dong_zhuo",
                "FactionTurnStart", 
                true,
                function(context)
                    out.interventions(" ### Intro how to play incident triggered")
					cdir_events_manager:add_prioritised_incidents( context:faction():command_queue_index(), "3k_main_introduction_dong_zhuo_incident" );
                    cm:set_saved_value("start_incident_unlocked", true);
                end,
                false
    )
end

-- dong zhuo introduction mission 01
start_tutorial_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_tutorial_mission_dong_zhuo_capture_settlement",                     -- mission key
    "OWN_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_anding_resource_2"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_capture_regions;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventStartTutorialMissions",      -- trigger event 
    "ScriptEventDongZhuoIntroductionMission01Complete"     -- completion event
)

-- dong zhuo introduction mission 02
start_tutorial_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_tutorial_mission_dong_zhuo_construct_building",                     -- mission key
    "CONSTRUCT_ANY_BUILDING",                                  -- objective type
    nil,                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_construct_building;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventDongZhuoIntroductionMission01Complete",      -- trigger event 
    "ScriptEventDongZhuoIntroductionMission02Complete"     -- completion event
)

-- dong zhuo introduction mission 03
start_tutorial_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_tutorial_mission_dong_zhuo_recruit_units",                     -- mission key
    "OWN_N_UNITS",                                  -- objective type
    {
        2       -- special case, just supply the number of units we want the player to recruit
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_recruit_units;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventDongZhuoIntroductionMission02Complete",      -- trigger event 
    "ScriptEventDongZhuoIntroductionMission03Complete"     -- completion event
)

-- dong zhuo introduction mission 04
start_tutorial_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_tutorial_mission_dong_zhuo_perform_assignment",                     -- mission key
    "PERFORM_ASSIGNMENT",                                  -- objective type
    nil,                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_dong_zhuo;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventDongZhuoIntroductionMission03Complete",      -- trigger event 
    "ScriptEventDongZhuoIntroductionMission04Complete"     -- completion event
)

-- dong zhuo introduction mission 05
start_tutorial_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_tutorial_mission_dong_zhuo_secure_province",                     -- mission key
    "OWN_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 8"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_dong_zhuo;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventDongZhuoIntroductionMission04Complete",      -- trigger event 
    "ScriptEventDongZhuoIntroductionMission05Complete"     -- completion event
)

-- dong zhuo introduction mission 06
start_tutorial_mission_listener(
    "3k_main_faction_dong_zhuo",                          -- faction key
    "3k_main_tutorial_mission_dong_zhuo_reach_progression_rank",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_dong_zhuo;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventDongZhuoIntroductionMission05Complete",      -- trigger event 
    "ScriptEventDongZhuoIntroductionMission06Complete"     -- completion event
)

-- cancel intro missions on faction rank up
start_tutorial_mission_cancel_listener(
    "3k_main_faction_dong_zhuo",
    {
        "3k_main_tutorial_mission_dong_zhuo_capture_settlement",
        "3k_main_tutorial_mission_dong_zhuo_construct_building",
        "3k_main_tutorial_mission_dong_zhuo_recruit_units",
        "3k_main_tutorial_mission_dong_zhuo_secure_province",
        "3k_main_tutorial_mission_dong_zhuo_perform_assignment"
    },
    "ScriptEventDongZhuoIntroductionMission06Complete"
)