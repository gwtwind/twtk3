-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Liu Bei Tutorial Missions ---------------------------
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
                "introduction_incident_liu_bei",
                "FactionTurnStart", 
                true,
                function(context)
					out.interventions(" ### Intro how to play incident triggered")
					cdir_events_manager:add_prioritised_incidents( context:faction():command_queue_index(), "3k_main_introduction_liu_bei_incident" );
                    cm:set_saved_value("start_incident_unlocked", true);
                end,
                false
    )
end

-- liu bei introduction mission 01
start_tutorial_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_tutorial_mission_liu_bei_defeat_army",                     -- mission key
    "ENGAGE_FORCE",                                  -- objective type
    {
        "faction 3k_main_faction_yellow_turban_generic",
        "armies_only"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_defeat_force;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventStartTutorialMissions",      -- trigger event 
    "ScriptEventLiuBeiIntroductionMission01Complete"     -- completion event
)

-- liu bei introduction mission 02
start_tutorial_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_tutorial_mission_liu_bei_capture_settlement",                     -- mission key
	"OWN_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_dongjun_resource_1"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_capture_regions;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiIntroductionMission01Complete",      -- trigger event 
    "ScriptEventLiuBeiIntroductionMission02Complete"     -- completion event
)


-- liu bei introduction mission 03
start_tutorial_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_tutorial_mission_liu_bei_recruit_units",                     -- mission key
    "OWN_N_UNITS",                                  -- objective type
    {
        2
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_recruit_units;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiIntroductionMission02Complete",      -- trigger event 
    "ScriptEventLiuBeiIntroductionMission03Complete"     -- completion event
)

-- liu bei introduction mission 04
start_tutorial_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_tutorial_mission_liu_bei_secure_province",                     -- mission key
    "OWN_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 3",
        "region 3k_main_langye_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_liu_bei;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiIntroductionMission03Complete",      -- trigger event 
    "ScriptEventLiuBeiIntroductionMission04Complete"     -- completion event
)

-- liu bei introduction mission 05
start_tutorial_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_tutorial_mission_liu_bei_construct_building",                     -- mission key
    "CONSTRUCT_ANY_BUILDING",                                  -- objective type
    nil,                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_construct_building;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiIntroductionMission04Complete",      -- trigger event 
    "ScriptEventLiuBeiIntroductionMission05Complete"     -- completion event
)

-- liu bei introduction mission 06
start_tutorial_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_tutorial_mission_liu_bei_perform_assignment",                     -- mission key
    "PERFORM_ASSIGNMENT",                                  -- objective type
    nil,                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_liu_bei;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiIntroductionMission05Complete",      -- trigger event 
    "ScriptEventLiuBeiIntroductionMission06Complete"     -- completion event
)

-- liu bei introduction mission 07a
start_tutorial_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_tutorial_mission_liu_bei_reach_progression_rank",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 1"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_liu_bei;turns 6;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiIntroductionMission06Complete",      -- trigger event 
    "ScriptEventLiuBeiIntroductionMission07Complete",     -- completion event
    function()
        if cm:query_faction("3k_main_faction_dong_zhuo"):is_dead() or progression.has_played_movie_fall_of_dong_zhuo == true then
            return true
        else
            return false
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventLiuBeiIntroductionMission07aFail"       -- failure event
)

-- liu bei introduction mission 07b
start_tutorial_mission_listener(
    "3k_main_faction_liu_bei",                          -- faction key
    "3k_main_tutorial_mission_liu_bei_reach_progression_rank_dong_zhuo",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 1"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_liu_bei;turns 6;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventLiuBeiIntroductionMission07aFail",      -- trigger event 
    "ScriptEventLiuBeiIntroductionMission07Complete"     -- completion event
)

-- cancel intro missions on faction rank up
start_tutorial_mission_cancel_listener(
    "3k_main_faction_liu_bei",
    {
        "3k_main_tutorial_mission_liu_bei_defeat_army",
        "3k_main_tutorial_mission_liu_bei_capture_settlement",
        "3k_main_tutorial_mission_liu_bei_construct_building",
        "3k_main_tutorial_mission_liu_bei_recruit_units",
        "3k_main_tutorial_mission_liu_bei_secure_province",
        "3k_main_tutorial_mission_liu_bei_perform_assignment"
    },
    "ScriptEventLiuBeiIntroductionMission07Complete"
)