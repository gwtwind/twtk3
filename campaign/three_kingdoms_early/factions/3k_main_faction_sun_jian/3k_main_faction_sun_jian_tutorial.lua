-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Sun Jian Tutorial Missions ---------------------------
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
                "introduction_incident_sun_jian",
                "FactionTurnStart", 
                true,
                function(context)
					out.interventions(" ### Intro how to play incident triggered")
					cdir_events_manager:add_prioritised_incidents( context:faction():command_queue_index(), "3k_main_introduction_sun_jian_incident" );
                    cm:set_saved_value("start_incident_unlocked", true);
                end,
                false
    )
end

-- sun jian introduction mission 01
start_tutorial_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_tutorial_mission_sun_jian_defeat_army",                     -- mission key
    "ENGAGE_FORCE",                                  -- objective type
    {
        "faction 3k_main_faction_han_empire",
        "armies_only"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_defeat_force;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventStartTutorialMissions",      -- trigger event 
    "ScriptEventSunJianIntroductionMission01Complete"     -- completion event
)

-- sun jian introduction mission 02
start_tutorial_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_tutorial_mission_sun_jian_capture_settlement",                     -- mission key
	"OWN_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 1",
        "region 3k_main_jingzhou_capital"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_capture_regions;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianIntroductionMission01Complete",      -- trigger event 
    "ScriptEventSunJianIntroductionMission02Complete"     -- completion event
)

-- sun jian introduction mission 03
start_tutorial_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_tutorial_mission_sun_jian_construct_building",                     -- mission key
    "CONSTRUCT_ANY_BUILDING",                                  -- objective type
    {
        "region 3k_main_changsha_capital"                                             -- conditions (single string or table of strings)
    },                                                  
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_construct_building;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianIntroductionMission02Complete",      -- trigger event 
    "ScriptEventSunJianIntroductionMission03Complete"     -- completion event
)

-- sun jian introduction mission 04
start_tutorial_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_tutorial_mission_sun_jian_recruit_units",                     -- mission key
    "OWN_N_UNITS",                                  -- objective type
    {
        2       -- special case, just supply the number of units we want the player to recruit
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_recruit_units;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianIntroductionMission03Complete",      -- trigger event 
    "ScriptEventSunJianIntroductionMission04Complete"     -- completion event
)

-- sun jian introduction mission 05
start_tutorial_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_tutorial_mission_sun_jian_secure_province",                     -- mission key
    "OWN_N_REGIONS_INCLUDING",                                  -- objective type
    {
        "total 3"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_sun_jian;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianIntroductionMission04Complete",      -- trigger event 
    "ScriptEventSunJianIntroductionMission05Complete"     -- completion event
)

-- sun jian introduction mission 06
start_tutorial_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_tutorial_mission_sun_jian_perform_assignment",                     -- mission key
    "PERFORM_ASSIGNMENT",                                  -- objective type
    nil,                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_sun_jian;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianIntroductionMission05Complete",      -- trigger event 
    "ScriptEventSunJianIntroductionMission06Complete"     -- completion event
)

-- sun jian introduction mission 07a
start_tutorial_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_tutorial_mission_sun_jian_reach_progression_rank",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 1"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_sun_jian;turns 3;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianIntroductionMission06Complete",      -- trigger event 
    "ScriptEventSunJianIntroductionMission07Complete",     -- completion event
    function()
        if cm:query_faction("3k_main_faction_dong_zhuo"):is_dead() or progression.has_played_movie_fall_of_dong_zhuo == true then
            return true
        else
            return false
        end
    end,                                                -- precondition (nil, or a function that returns a boolean)
    "ScriptEventSunJianIntroductionMission07aFail"       -- failure event
)

-- sun jian introduction mission 07b
start_tutorial_mission_listener(
    "3k_main_faction_sun_jian",                          -- faction key
    "3k_main_tutorial_mission_sun_jian_reach_progression_rank_dong_zhuo",                     -- mission key
    "ATTAIN_FACTION_PROGRESSION_LEVEL",                                  -- objective type
    {
        "total 1"
    },                                                  -- conditions (single string or table of strings)
    {
        "effect_bundle{bundle_key 3k_main_introduction_mission_payload_sun_jian;turns 6;}"
    },                                                  -- mission rewards (table of strings)
    "ScriptEventSunJianIntroductionMission07aFail",      -- trigger event 
    "ScriptEventSunJianIntroductionMission07Complete"     -- completion event
)

-- cancel intro missions on faction rank up
start_tutorial_mission_cancel_listener(
    "3k_main_faction_sun_jian",
    {
        "3k_main_tutorial_mission_sun_jian_defeat_army",
        "3k_main_tutorial_mission_sun_jian_capture_settlement",
        "3k_main_tutorial_mission_sun_jian_construct_building",
        "3k_main_tutorial_mission_sun_jian_recruit_units",
        "3k_main_tutorial_mission_sun_jian_secure_province",
        "3k_main_tutorial_mission_sun_jian_perform_assignment"
    },
    "ScriptEventSunJianIntroductionMission07Complete"
)