-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Liu Biao Tutorial Missions --------------------------
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
                "introduction_incident_liu_biao",
                "FactionTurnStart", 
                true,
                function(context)
					out.interventions(" ### Intro how to play incident triggered")
					cdir_events_manager:add_prioritised_incidents( context:faction():command_queue_index(), "3k_main_introduction_liu_biao_incident" );
                    cm:set_saved_value("start_incident_unlocked", true);
                end,
                false
    )
end

-- liu biao introduction mission 01
start_tutorial_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_tutorial_mission_liu_biao_defeat_army",                     -- mission key
    "ENGAGE_FORCE",                                  -- objective type
    {
        "faction 3k_main_faction_yellow_turban_generic",
        "armies_only"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_defeat_force;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventStartTutorialMissions",      -- trigger event 
    "ScriptEventLiuBiaoIntroductionMission01Complete"     -- completion event
)

-- liu biao introduction mission 02
start_tutorial_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_tutorial_mission_liu_biao_capture_settlement",                     -- mission key
	"OWN_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_xiangyang_resource_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_capture_regions;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoIntroductionMission01Complete",      -- trigger event 
    "ScriptEventLiuBiaoIntroductionMission02Complete"     -- completion event
)

-- liu biao introduction mission 03
start_tutorial_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_tutorial_mission_liu_biao_construct_building",                     -- mission key
    "CONSTRUCT_ANY_BUILDING",                                  -- objective type
    {
        "region 3k_main_xiangyang_capital"                                             -- conditions (single string or table of strings)
    },                                                  
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_construct_building;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoIntroductionMission02Complete",      -- trigger event 
    "ScriptEventLiuBiaoIntroductionMission03Complete"     -- completion event
)

-- liu biao introduction mission 04
start_tutorial_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_tutorial_mission_liu_biao_recruit_units",                     -- mission key
    "OWN_N_UNITS",                                  -- objective type
    {
        2       -- special case, just supply the number of units we want the player to recruit
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_recruit_units;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoIntroductionMission03Complete",      -- trigger event 
    "ScriptEventLiuBiaoIntroductionMission04Complete"     -- completion event
)

-- liu biao introduction mission 05
start_tutorial_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_tutorial_mission_liu_biao_secure_province",                     -- mission key
    "OWN_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_liu_biao;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoIntroductionMission04Complete",      -- trigger event 
    "ScriptEventLiuBiaoIntroductionMission05Complete"     -- completion event
)

-- liu biao introduction mission 06
start_tutorial_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_tutorial_mission_liu_biao_perform_assignment",                     -- mission key
    "PERFORM_ASSIGNMENT",                                  -- objective type
    nil,                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_liu_biao;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoIntroductionMission05Complete",      -- trigger event 
    "ScriptEventLiuBiaoIntroductionMission06Complete"     -- completion event
)

-- liu biao introduction mission 07a
start_tutorial_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_tutorial_mission_liu_biao_reach_progression_rank",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 1"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_liu_biao;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoIntroductionMission06Complete",      -- trigger event 
    "ScriptEventLiuBiaoIntroductionMission07Complete",     -- completion event
    function()
        if cm:query_faction("3k_main_faction_dong_zhuo"):is_dead() or progression.has_played_movie_fall_of_dong_zhuo == true then
            return true
        else
            return false
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBiaoIntroductionMission07aFail"       -- failure event
)

-- liu biao introduction mission 07b
start_tutorial_mission_listener(
    "3k_main_faction_liu_biao",                          -- faction key
    "3k_main_tutorial_mission_liu_biao_reach_progression_rank_dong_zhuo",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 1"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_liu_biao;turns 6;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBiaoIntroductionMission07aFail",      -- trigger event 
    "ScriptEventLiuBiaoIntroductionMission07Complete"     -- completion event
)

-- cancel intro missions on faction rank up
start_tutorial_mission_cancel_listener(
    "3k_main_faction_liu_biao",
    {
        "3k_main_tutorial_mission_liu_biao_defeat_army",
        "3k_main_tutorial_mission_liu_biao_capture_settlement",
        "3k_main_tutorial_mission_liu_biao_construct_building",
        "3k_main_tutorial_mission_liu_biao_recruit_units",
        "3k_main_tutorial_mission_liu_biao_secure_province",
        "3k_main_tutorial_mission_liu_biao_perform_assignment"
    },
    "ScriptEventLiuBiaoIntroductionMission07Complete"
)