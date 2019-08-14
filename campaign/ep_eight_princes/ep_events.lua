
--EIGHT PRINCES CAMPAIGN EVENTS
--Author: Will Wright
--This script contains various listeners and functions related to the Eight Princes campaign events. 
--LISTENERS:
--- 0. ep_starting_flow -- triggers the initial dilemma after you beat the first enemy army
--- 1. empress_death_listener -- listens for the 'Empress Dies' event and triggers Empress bundle/mission removal functions
--- 2. war_with_jin_listener -- checks at the end turn to see if player is at war with the Jin Empire and removes any relevant bundles
--- 3. milestone_3_triggered_listener -- checks to see if the third Milestone event has been triggered, and triggers 'Protector' bundle removal
--- 4. emperor_usurped_listener -- checks to see if the player has chosen to switch from Regent to Emperor in the 'ep_dilemma_contextual_continue_regency_or_become_emperor' dilemma
--- 5. mission_dilemma_listener -- listens for when the player makes a choice in one of the 'mission' dilemmas, hands the data over to the 'trigger_dilemma_mission' function
--FUNCTIONS
--- 1. remove_empress_effect_bundles -- removes any 'Empress' effect bundles from the specified faction. The list of effect bundles is defined in the function itself.
--- 2. remove_empress_missions -- cancels any active empress missions. The list of missions is defined in the function itself.
--- 3. remove_protector_bundle -- removes specific 'Empress' Protector' bundle
--- 4. remove_regent_bundle -- removes 'Regent' bundle
--- 5. trigger_dilemma_mission - takes the info handed to it by the mission_dilemma_listener, looks up the correct mission and issues it to the relevant faction


require("ep_storybook") -- functions in this script will occasionally need to access and modify the eligible events list in the storybook script.
--------------------------------------------------------
--------------------VARIABLES----------------------------
---------------------------------------------------------

empress_death_listener = {};
empress_death_listener.empress_death_event_string = "ep_dilemma_contextual_empress_dies";

war_with_jin_listener = {};
war_with_jin_listener.jin_empire_string = "ep_faction_empire_of_jin"; -- key for the Jin Empire Faction;

milestone_3_triggered_listener = {};
milestone_3_triggered_listener.milestone_3_pattern = "ep_dilemma_milestone_3_sima_.*"; -- key format used by all milestone 3 dilemmas, where the player will become Emperor or regent

emperor_usurped_listener = {};
emperor_usurped_listener.regent_usurps_emperor_dilemma_string = "ep_dilemma_contextual_continue_regency_or_become_emperor"; -- the dilemma that can allow the player to switch from Emperor to Regent

ep_starting_flow = {};

mission_dilemma_listener = { 
--This dictionary links dilemma choices to the associated mission. Format for the dictionary entries is the dilemma key + a number for the choice. This uses the numeric format the script gets in response to the context:choice() function, *not* the DB format: use 0 for the choice in the top left, 1 for top right, 2 for bottom left, 3 for bottom right
ep_dilemma_missions_dynasty_build_vs_destroy0 = 	  "ep_dynasty_mission_kill_enemies",
ep_dilemma_missions_dynasty_build_vs_destroy1 = 	  "ep_dynasty_mission_build",
ep_dilemma_missions_dynasty_domination_vs_peace1 = 	"ep_dynasty_mission_peace",
ep_dilemma_missions_dynasty_domination_vs_peace0 = 	"ep_dynasty_mission_have_vassals",
ep_dilemma_missions_dynasty_few_vs_many0 = 	        "ep_dynasty_mission_food_income",
ep_dilemma_missions_dynasty_few_vs_many1 = 	        "ep_dynasty_mission_attain_character_rank",
ep_dilemma_missions_dynasty_income_vs_military0 = 	"ep_dynasty_mission_support_units",
ep_dilemma_missions_dynasty_income_vs_military1 = 	"ep_dynasty_mission_income",
ep_dilemma_missions_dynasty_money_vs_land0 = 	      "ep_dynasty_mission_gather_money",
ep_dilemma_missions_dynasty_money_vs_land1 = 	      "ep_dynasty_mission_hold_many_settlements",
ep_dilemma_missions_empress_start_generic1 = 	      "ep_empress_mission_traitors_start_heart",
ep_dilemma_missions_empress_start_generic2 = 	      "ep_empress_mission_traitors_money",
ep_dilemma_missions_empress_start_generic0 =      	"ep_empress_mission_traitors_brain",
ep_dilemma_missions_empress_start_generic3 =      	"ep_empress_mission_traitors_fist",
ep_dilemma_missions_empress_start_sima_liang1 =   	"ep_empress_mission_start_sima_liang_brain",
ep_dilemma_missions_empress_start_sima_liang2 = 	  "ep_empress_mission_start_sima_liang_fist",
ep_dilemma_missions_empress_start_sima_liang0 = 	  "ep_empress_mission_start_sima_liang_money",
ep_dilemma_missions_empress_start_sima_liang3 = 	  "ep_empress_mission_start_sima_liang_heart",
ep_dilemma_missions_empress_start_sima_wei1 = 	    "ep_empress_mission_traitors_start_heart",
ep_dilemma_missions_empress_start_sima_wei2 = 	    "ep_empress_mission_traitors_money",
ep_dilemma_missions_empress_start_sima_wei0 = 	    "ep_empress_mission_traitors_brain",
ep_dilemma_missions_empress_start_sima_wei3 =     	"ep_empress_mission_traitors_fist",
ep_dilemma_missions_empress_traitors1 = 	          "ep_empress_mission_traitors_heart",
ep_dilemma_missions_empress_traitors2 = 	          "ep_empress_mission_traitors_money",
ep_dilemma_missions_empress_traitors0 =           	"ep_empress_mission_traitors_brain",
ep_dilemma_missions_empress_traitors3 = 	          "ep_empress_mission_traitors_fist",
ep_dilemma_missions_espionage_imperial_decree1 = 	  "ep_espionage_mission_embed_spy",
string_to_match = "ep_dilemma_missions_.*" --- this is the key format the listener looks for. Dilemmas without this format will not trigger the listener!
};

---------------------------------------------------------
--------------------LISTENERS----------------------------
---------------------------------------------------------


function ep_starting_flow:initialise()
  
  output("ep_starting_flow:initialise()")
  core:add_listener(
    "MissionSucceededDefeatedStartingEnemy",
    "MissionSucceeded",
    function(context) 
      return context:mission():mission_record_key() == string.match(context:mission():mission_record_key(),"ep_mission_introduction_destroy_army.*") -- does the mission string match the pattern specified? If so, trigger listener.
    end,
    function(context)
      local faction_key = context:mission():faction():name();
      core:add_listener(
				"ep_starting_flow_dilemma_trigger_events_battle_completed", -- Unique handle
				"BattleCompleted", -- Campaign Event to listen for
				true,
          function(context) -- What to do if listener fires.
            output("faction"..faction_key.." has killed their first army, giving them a dilemma");
            if faction_key == "ep_faction_prince_of_runan" then
              cm:trigger_dilemma(faction_key,"ep_dilemma_missions_empress_start_sima_liang",true)
            elseif faction_key == "ep_faction_prince_of_chu" then
              cm:trigger_dilemma(faction_key,"ep_dilemma_missions_empress_start_sima_wei",true)
            else cm:trigger_dilemma(faction_key, "ep_dilemma_missions_empress_start_generic",true)
            end
          end,
        false)
    end
  );
end;

--Listens for Empress death event to trigger, then cancels all associated effect bundles and missions.
function empress_death_listener:initialise()
	output("empress_death_listener:initialise()");
    
  core:add_listener(
    "DilemmaIssuedEventEmpressDeath",
    "DilemmaIssuedEvent",
  function(context)
    return context:dilemma() == self.empress_death_event_string --listen for this dilemma to initialise
  end,
  function(context) 
    local faction = context:faction();
    remove_empress_effect_bundles(faction); -- empress is dead, doesn't matter if she likes/dislikes you any more
    remove_empress_missions(faction); -- empress is dead, no point doing missions for her
  end
  );
end;

--Listener that checks if a Milestone 3 dilemma has been issued, removes the Protector bundle
-- function milestone_3_triggered_listener:initialise()
--	output("milestone_3_triggered_listener:initialise()");
    
 -- core:add_listener(
---    "DilemmaChoiceMadeEventMilestone3",
--    "DilemmaChoiceMadeEvent",
--  function(context) 
 --   return context:dilemma() == string.match(context:dilemma(),milestone_3_triggered_listener.milestone_3_pattern) -- does the dilemma string match the pattern specified? If so, trigger listener.
 -- end,
--  function(context) 
--    local faction = context:faction();
--    remove_protector_bundle(faction); -- can't be protector if you're regent or emperor!
 --   cm:trigger_dilemma(faction:name(),"ep_dilemma_contextual_empress_dies",false)
--  end
--  );
--end;

--Listener that checks if the player (as Regent) has chosen to execute the Emperor and become Regent, and removes the Regent bundle.
function emperor_usurped_listener:initialise()
	output("emperor_usurped_listener:initialise()");
    
  core:add_listener(
    "DilemmaChoiceMadeEventUsurpEmperor",
    "DilemmaChoiceMadeEvent",
  function(context) 
    return context:dilemma() == self.regent_usurps_emperor_dilemma_string and context:choice() ~= 0 -- has the player chosen anything other than the first choice in the specified dilemma?
  end,
  function(context) 
    local faction = context:faction();
    remove_regent_bundle(faction); -- can't be regent if there's no Emperor!
  end
  );
end;

--Listens for war with the Jin Empire, then clears all Empress-related effect bundles and missions 
function war_with_jin_listener:initialise()
  output("war_with_jin_listener:initialise()");
  
  core:add_listener(
    "AtWarWithJinFactionTurnEnd",
    "FactionTurnEnd",
  function(context)
    local jin_empire = cm:query_faction("ep_faction_empire_of_jin")
    return context:faction():is_human() and context:faction():has_specified_diplomatic_deal_with("treaty_components_war",jin_empire)
  end,
  function(context) 
  local faction = context:faction();
  output("-*-war_with_jin_listener() - war detected between Jin Empire and "..faction:name() );
    remove_empress_effect_bundles(faction);
    remove_empress_missions(faction);
    remove_protector_bundle(faction);
    cm:trigger_incident(faction,"ep_war_with_the_jin_empire_incident",true)
  end
  );
  
end;

---listens for dilemma choices where the dilemma key matches a specific string (set in variables) and triggers the mission connected to that key.
function mission_dilemma_listener:initialise()
  output("mission_dilemma_listener:initialise()");
  
  core:add_listener(
    "MissionDilemmaChoiceMadeEvent",
    "DilemmaChoiceMadeEvent",
  function(context)
    return context:dilemma() == string.match(context:dilemma(),self.string_to_match)
  end,
  function(context)
    local faction_key = context:faction():name();
    local dilemma_key = context:dilemma();
    local choice_key = context:choice();
    trigger_dilemma_mission(faction_key, dilemma_key, choice_key);
  end,
  true
  );
end;
---------------------------------------------------------
--------------------FUNCTIONS----------------------------
---------------------------------------------------------
---Function for removing all Empress-related bundles
function remove_empress_effect_bundles(faction)
  output("-*-remove_empress_effect_bundles(): removing effect bundles from faction: "..faction:name()); 
  cm:modify_faction(faction):remove_effect_bundle("ep_milestone_payload_diplomacy_empress_negative_1");
  cm:modify_faction(faction):remove_effect_bundle("ep_milestone_payload_diplomacy_empress_negative_2");
  cm:modify_faction(faction):remove_effect_bundle("ep_milestone_payload_diplomacy_empress_negative_3");
  cm:modify_faction(faction):remove_effect_bundle("ep_milestone_payload_diplomacy_empress_positive_1");
  cm:modify_faction(faction):remove_effect_bundle("ep_milestone_payload_diplomacy_empress_positive_2");
  cm:modify_faction(faction):remove_effect_bundle("ep_event_payload_food_donations_small");
  cm:modify_faction(faction):remove_effect_bundle("ep_event_payload_food_donations_medium");
  cm:modify_faction(faction):remove_effect_bundle("ep_event_payload_food_donations_large");
  cm:modify_faction(faction):remove_effect_bundle("ep_event_payload_food_donations_very_large");
end;

---Function for cancelling all Empress-related missions
function remove_empress_missions(faction) 
  output("-*-remove_empress_missions():removing Empress missions from faction: " ..faction:name() ); 
  cm:cancel_custom_mission(faction, "ep_empress_mission_start_sima_liang_brain");
  cm:cancel_custom_mission(faction, "ep_empress_mission_start_sima_liang_fist");
  cm:cancel_custom_mission(faction, "ep_empress_mission_start_sima_liang_heart");
  cm:cancel_custom_mission(faction, "ep_empress_mission_start_sima_liang_money");
  cm:cancel_custom_mission(faction, "ep_empress_mission_traitors_brain");
  cm:cancel_custom_mission(faction, "ep_empress_mission_traitors_heart");
  cm:cancel_custom_mission(faction, "ep_empress_mission_traitors_fist");
  cm:cancel_custom_mission(faction, "ep_empress_mission_traitors_money");
end;	

---Function for removing the 'Protector' bundle (earned via certain Milestone 2 events but should be incompatible with the Regent/Emperor bundles)
function remove_protector_bundle(faction)
  output("-*-remove_protector_bundle() - removing 'Empress Protector' bundle from faction: " ..faction:name() );
  cm:modify_faction(faction):remove_effect_bundle("ep_milestone_payload_protector");
end;
--- Function for removing the 'Regent' bundle (earned via certain Milestone 3 events but incompatible with the Emperor bundle)
function remove_regent_bundle(faction)
  output("-*-remove_regent_bundle() - removing 'Regent' bundle from faction: " ..faction:name() );
  cm:modify_faction(faction):remove_effect_bundle("ep_milestone_payload_regent");
end;

--takes the specified dilemma and choice, concatenates them and matches it to a mission in a dictionary, then immediately triggers that mission for a specified faction
function trigger_dilemma_mission(faction_key, dilemma_key, choice_key)
  output("-*-dilemma mission "..dilemma_key.." detected with choice:"..choice_key);
  if mission_dilemma_listener[dilemma_key..choice_key] == nil then output("no mission for this choice found in dictionary, nothing will happen")
  else cm:trigger_mission(faction_key, mission_dilemma_listener[dilemma_key..choice_key], true)
  end;
end;