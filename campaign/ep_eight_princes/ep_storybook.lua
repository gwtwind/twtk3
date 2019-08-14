--EIGHT PRINCES STORYBOOK FRAMEWORK
--Author: Will Wright, Craig Kirby
--This script governs what used to be the storybook system, which was scrapped. Some vestigial bits remain, however:
-- 1. The system where events are produced on a regular basis (probably could be handled by CDIR now but at least it ensures a regular stream of alignment events so we'll keep it for now.)
-- 2. The system for updating the Faction Summary screen when the player becomes Emperor/Regent
-- 3. The system for triggering events upon capturing the Imperial Capital
-- This could all probably be merged into the ep_events.lua script as they're conceptually quite similar now - will review once everything is finalised.
---------------------------------------------------------
--------------------VARIABLES----------------------------
---------------------------------------------------------

ep_storybook = {}
ep_storybook.humans_intialised = false -- Used for adding the initial events to the human factions
ep_storybook.empress_dead = false

ep_storybook.storybook_event_generator = { -- Events can be added to the eligible_events tables multiple times - this will increase the chance they are generated. 
	["turns_between_events"] = 4, -- This defines how many turns between events firing. n.b. 4 turns between events means an even on every *fifth* turn 
	["ep_faction_prince_of_changsha"] = {
		["turns_since_last_event"] = 0,
		["eligible_events"] = {},
		["emperor_choice"] = 0,
    ["turns_as_regent"] = 0
	},
	["ep_faction_prince_of_qi"] = {
		["turns_since_last_event"] = 0,
		["eligible_events"] = {},
		["emperor_choice"] = 0,
    ["turns_as_regent"] = 0
	},
	["ep_faction_prince_of_runan"] = {
		["turns_since_last_event"] = 0,
		["eligible_events"] = {},
		["emperor_choice"] = 0,
    ["turns_as_regent"] = 0
	},
	["ep_faction_prince_of_zhao"] = {
		["turns_since_last_event"] = 0,
		["eligible_events"] = {},
		["emperor_choice"] = 0,
    ["turns_as_regent"] = 0
	},
	["ep_faction_prince_of_chu"] = {
		["turns_since_last_event"] = 0,
		["eligible_events"] = {},
		["emperor_choice"] = 0,
    ["turns_as_regent"] = 0
	},
	["ep_faction_prince_of_chengdu"] = {
		["turns_since_last_event"] = 0,
		["eligible_events"] = {},
		["emperor_choice"] = 0,
    ["turns_as_regent"] = 0
	},
	["ep_faction_prince_of_hejian"] = {
		["turns_since_last_event"] = 0,
		["eligible_events"] = {},
		["emperor_choice"] = 0,
    ["turns_as_regent"] = 0
	},
	["ep_faction_prince_of_donghai"] = {
		["turns_since_last_event"] = 0,
		["eligible_events"] = {},
		["emperor_choice"] = 0,
    ["turns_as_regent"] = 0
	},
};

ep_storybook.milestone_generator = { --the variables here were previously used to translate the progression level, pooled resource key and faction key into a format that could be used to build a dilemma key. These are no longer used but might be useful in the future so leaving them here until we're finished with everything else.
	[1] = "milestone_1",
	[2] = "milestone_2",
	[3] = "milestone_3",
	[4] = "milestone_4",

	ep_pooled_resource_heart_alignment = "_heart",
	ep_pooled_resource_brain_alignment = "_brain",
	ep_pooled_resource_fist_alignment = "_fist",
	ep_pooled_resource_money_alignment = "_money",

	ep_faction_prince_of_changsha = "_sima_ai",
	ep_faction_prince_of_qi = "_sima_jiong",
	ep_faction_prince_of_runan = "_sima_liang",
	ep_faction_prince_of_zhao = "_sima_lun",
	ep_faction_prince_of_chu = "_sima_wei",
	ep_faction_prince_of_chengdu = "_sima_ying",
	ep_faction_prince_of_hejian = "_sima_yong",
	ep_faction_prince_of_donghai = "_sima_yue",

	prefix = "ep_dilemma_"
}
-- Eligible events lists
-- This is all the events that can trigger from campaign start.
-- These events still obey the usual event generation rules set in the db!
-- adding an event multiple times increases its chance of being generated

ep_storybook.storybook_eligible_events = { 
	"ep_dilemma_rule_land_grab_1",
	"ep_dilemma_rule_lean_year_1",
	"ep_dilemma_rule_lean_year_2",
	"ep_dilemma_rule_good_year",
	"ep_dilemma_rule_ranks",
	"ep_dilemma_rule_serfs",
	"ep_dilemma_character_competition",
	"ep_dilemma_character_debate",
	"ep_dilemma_character_imperial_insult",
	"ep_dilemma_character_scholar_1",
	"ep_dilemma_character_scholar_2",
	"ep_dilemma_character_scholar_3",
	"ep_dilemma_character_toast",
	"ep_dilemma_empress_insult_1",
	"ep_dilemma_empress_insult_1",
	"ep_dilemma_empress_insult_2",
	"ep_dilemma_empress_insult_3",
	"ep_dilemma_empress_supplies_1",
	"ep_dilemma_empress_supplies_1",
	"ep_dilemma_empress_supplies_2",
	"ep_dilemma_empress_supplies_3",
	"ep_dilemma_empress_war_1",
	"ep_dilemma_empress_war_1",
	"ep_dilemma_empress_war_2",
	"ep_dilemma_missions_empress_traitors",
	"ep_dilemma_missions_empress_traitors",
	"ep_dilemma_missions_empress_traitors",
  "ep_dilemma_missions_dynasty_build_vs_destroy",
	"ep_dilemma_missions_dynasty_domination_vs_peace",
	"ep_dilemma_missions_dynasty_few_vs_many",
	"ep_dilemma_missions_dynasty_income_vs_military",
	"ep_dilemma_missions_dynasty_money_vs_land",	
	"ep_dilemma_missions_dynasty_build_vs_destroy",
	"ep_dilemma_missions_dynasty_domination_vs_peace",
	"ep_dilemma_missions_dynasty_few_vs_many",
	"ep_dilemma_missions_dynasty_income_vs_military",
	"ep_dilemma_missions_dynasty_money_vs_land",
  "ep_dilemma_espionage_intercept_a_missive",
	"ep_dilemma_espionage_sensitive_info",
	"ep_dilemma_espionage_traitor",
	"ep_dilemma_espionage_unsavoury_source",
	"ep_dilemma_missions_espionage_imperial_decree"
};

ep_storybook.capital_captured_events = { -- the list of events that can trigger upon capturing the capital. They are in priority order - the script will go though the list until it finds one that can be triggered according to the CDIR limits in the DB
"ep_dilemma_welcomed_into_capital_betray_sima_ai",
"ep_dilemma_welcomed_into_capital_lu_zhi",
"ep_dilemma_welcomed_into_capital_sun_xiu",
"ep_dilemma_welcomed_into_capital_sima_ai",
"ep_dilemma_welcomed_into_capital_cruel_general",
"ep_dilemma_welcomed_into_capital_heart",
"ep_dilemma_welcomed_into_capital_money",
"ep_dilemma_emperor_flees_fist_high",
"ep_dilemma_welcomed_into_capital_generic",
"ep_dilemma_emperor_flees_rank_too_low"
}

ep_storybook.emperor_dilemmas = { -- determines whether a dilemma decision results in the player becoming emperor or regent. used for UI context values
	["ep_dilemma_emperor_flees_fist_high"] = {
		[1] = 2,
	},
	["ep_dilemma_emperor_flees_rank_too_low"] = {
		[1] = 2,
	},
	["ep_dilemma_emperor_flees_taken_by_another"] = {
		[1] = 2,
	},
	["ep_dilemma_milestone_3_sima_yue_fist"] = {
		[1] = 2,
	},
	["ep_dilemma_welcomed_into_capital_sima_ai"] = {
		[1] = 1,
		[2] = 2,
	},
	["ep_dilemma_welcomed_into_capital_generic"] = {
		[1] = 1,
		[2] = 2,
	},
	["ep_dilemma_welcomed_into_capital_heart"] = {
		[1] = 1,
		[2] = 2,
	},
	["ep_dilemma_welcomed_into_capital_sun_xiu"] = {
		[1] = 1,
		[2] = 2,
	},
	["ep_dilemma_welcomed_into_capital_money"] = {
		[1] = 1,
		[2] = 2,
	},
	["ep_dilemma_welcomed_into_capital_lu_zhi"] = {
		[1] = 1,
		[2] = 1,
		[3] = 2,
	},
	["ep_dilemma_welcomed_into_capital_cruel_general"] = {
		[1] = 2,
		[2] = 1,
		[3] = 1,
	},
	["ep_dilemma_welcomed_into_capital_betray_sima_ai"] = {
		[1] = 1,
		[2] = 1,
		[3] = 2,
	},
	["ep_dilemma_contextual_continue_regency_or_become_emperor"] = {
		[1] = 1,
		[2] = 2,
		[3] = 2,
	},
   ["ep_dilemma_protector_generic"] = {
    [1] = 1,
  },
    ["ep_dilemma_protector_heart_1"] = {
    [1] = 1,
  },
    ["ep_dilemma_protector_heart_2"] = {
    [1] = 1,
    [3] = 1
  },
    ["ep_dilemma_protector_heart_3"] = {
    [1] = 1,
  },
    ["ep_dilemma_protector_heart_4"] = {
    [1] = 1,
  },
    ["ep_dilemma_protector_heart_4"] = {
    [1] = 1,
  },
    ["ep_dilemma_protector_sima_ai"] = {
    [1] = 1,
  },
    ["ep_dilemma_protector_money"] = {
    [1] = 1,
  },
    ["ep_dilemma_protector_brain"] = {
    [2] = 1,
  },
    ["ep_dilemma_contextual_emperor_captured"] = {
    [1] = 2,
    [2] = 2
  }
}

ep_storybook.campaign_victory_emperor_choice_achievements = { -- achievements we award after campaign victory based on player choice
	[1] = "TK_DLC02_ACHIEVEMENT_CAMPAIGN_COMPLETE_AS_REGENT",-- Regent
	[2] = "TK_DLC02_ACHIEVEMENT_CAMPAIGN_COMPLETE_AS_EMPEROR", -- Emperor
}

---------------------------------------------------------
--------------------LISTENERS----------------------------
---------------------------------------------------------

-- Every X turns, generate a storybook event

function ep_storybook:initialise()

	output("storybook:initialise()");

	core:add_listener(
		"FactionTurnStartStorybookEventGenerator",
		"FactionTurnStart",
		function(context)
			return context:faction():is_human()
		end,
		function(context)
			local faction_key = context:faction():name();
			if self.storybook_event_generator[faction_key]["turns_since_last_event"] >= self.storybook_event_generator["turns_between_events"] then 
				output("storybook: "..self.storybook_event_generator[faction_key]["turns_since_last_event"].." turns since last Storybook event for "..faction_key.." - time to make an event!")
				ep_storybook:generate_event(faction_key)
				self.storybook_event_generator[faction_key]["turns_since_last_event"] = 0
			else 
				self.storybook_event_generator[faction_key]["turns_since_last_event"] = self.storybook_event_generator[faction_key]["turns_since_last_event"] + 1
				output("storybook: Turns since last storybook event for "..faction_key..": "..self.storybook_event_generator[faction_key]["turns_since_last_event"])
			end;
			self:update_turns_to_next_event_ui(faction_key)
		end,
		true
	);

	-- resets the storybook turn counter if a contextual dilemma fires
	core:add_listener(
		"DilemmaIssuedEventContextualEvent",
		"DilemmaIssuedEvent",
		function(context) 
			return context:dilemma() == string.match(context:dilemma(),"ep_dilemma_contextual.*") -- does the dilemma string match the pattern specified? If so, trigger listener.
		end,
		function(context)
			local faction_key = context:faction():name()
			self.storybook_event_generator[faction_key]["turns_since_last_event"] = 0
			self:update_turns_to_next_event_ui(faction_key)
		end,
		true
	);

--listens for the player occupying the imperial capital in order to trigger the 'captured the capital' dilemma
  core:add_listener(
		"GarrisonOccupiedEventOccupyCapital",
		"GarrisonOccupiedEvent",
		function(context)
      local region = context:garrison_residence():region():name()
      local occupying_faction = context:query_character():faction()
			return region == "3k_main_luoyang_capital" and occupying_faction:is_human()
		end,
		function(context)
      local occupying_faction_key = context:query_character():faction():name()
      local emperor_in_luoyang = self:is_emperor_in_luoyang()
      if context:query_model():pending_battle():is_active() then
        output("player has taken capital but pending battle still active, will wait until battle complete to trigger dilemma")
          core:add_listener(
            "BattleCompletedPlayerTakesCapital", -- Unique handle
            "BattleCompleted", -- Campaign Event to listen for
            true,
            function(context) -- What to do if listener fires.
              self:trigger_capital_captured_event(emperor_in_luoyang,occupying_faction_key)
            end,
          false --Is persistent
          );
        else self:trigger_capital_captured_event(emperor_in_luoyang,occupying_faction_key) -- attempt to trigger the dilemma right away
      end
    end,
		false
	);
	
	--check to see the emperor usurp dilemma state for the ui context on the faction summary screen
	core:add_listener(
		"DilemmaChoiceMadeEventStorybookEmperorUI",
		"DilemmaChoiceMadeEvent",
		function(context) 
			return context:dilemma() == "ep_dilemma_contextual_continue_regency_or_become_emperor" or context:dilemma() == "ep_dilemma_contextual_emperor_captured" or context:dilemma() == string.match(context:dilemma(), "ep_dilemma_welcomed_into_capital_.*") or context:dilemma() == string.match(context:dilemma(), "ep_dilemma_emperor_flees_.*") or context:dilemma() == string.match(context:dilemma(), "ep_dilemma_protector_.*")
		end,
		function(context)
			local faction_key = context:faction():name();
			local emperor_choice = self.emperor_dilemmas[context:dilemma()][context:choice() + 1]
			self.storybook_event_generator[faction_key]["emperor_choice"] = emperor_choice
			self:update_storybook_milestone_events(faction_key)
		end
	);

	--award achievements after campaign finish based on player's choice
	core:add_listener(
		"PlayerCampaignFinishedStorybookEmperor",
		"PlayerCampaignFinished",
		function(context) 
			return context:faction():is_human() and context:player_won()
		end,
		function(context)
			local faction_key = context:faction():name();
			local emperor_choice = self.storybook_event_generator[faction_key]["emperor_choice"]
			local achievement = self.campaign_victory_emperor_choice_achievements[emperor_choice]

			if achievement ~= nil then				
				cm:modify_scripting():award_achievement(achievement)
			end
		end
	);
  
  

	local humans = cm:get_human_factions();
	if #humans > 0 then
		for i = 1, #humans do

			local faction_key = cm:query_faction(humans[i]):name();

			if self.humans_intialised == false then
				self:add_events_to_eligible_list(faction_key, self.storybook_eligible_events)
			end
			
			self:update_storybook_milestone_events(faction_key)
			
		end
		self.humans_intialised = true;
	end
	

end

---------------------------------------------------------
--------------------FUNCTIONS----------------------------
---------------------------------------------------------

-- This passes the turn counter for a faction to the UI for the storybook in the context value <faction_key>_milestone_turns
function ep_storybook:update_turns_to_next_event_ui(faction_key)
	local turns_counter = self.storybook_event_generator["turns_between_events"] + 1 - self.storybook_event_generator[faction_key]["turns_since_last_event"]
	effect.set_context_value(faction_key.."_milestone_turns", turns_counter)
	--output("storybook: it's currently "..faction_key.."'s turn. the turn counter is: "..turns_counter)
end

--picks a random event from the list of eligible events
function ep_storybook:generate_event(faction_key)

	output("storybook: Generating storybook event for "..faction_key);
	local eligible_events = self.storybook_event_generator[faction_key]["eligible_events"]
	local event_number = math.floor(cm:modify_model():random_number(1,#eligible_events+0.99)) --+0.99 so that there isn't a bias against the last event in the list. Cheers Alex C!
	while cm:trigger_dilemma(faction_key, eligible_events[event_number], true) == false do -- try to generate a random event from the eligible events list. if the event chosen can't be generated, keep going until you find one that can
		event_number = math.floor(cm:modify_model():random_number(1,#eligible_events))
	end

end;

-- takes all the events from the specified list and adds them to the eligible list
function ep_storybook:add_events_to_eligible_list(faction_key, list_to_add) 

	for k,v in ipairs(list_to_add) do
		table.insert(self.storybook_event_generator[faction_key]["eligible_events"],v)
	end

end
function ep_storybook:update_storybook_milestone_events(faction_key)
	-- Updates the UI with the choice made on the emperor usurp dilemma. 0 = haven't received the dilemma, 1 = regent, 2 = emperor
	output("storybook: Updating the emperor choice UI context for "..faction_key.." to the script value of: "..self.storybook_event_generator[faction_key]["emperor_choice"])
	effect.set_context_value(faction_key.."_emperor_choice", self.storybook_event_generator[faction_key]["emperor_choice"])

end


function ep_storybook:trigger_capital_captured_event(emperor_in_luoyang, faction_key) -- picks an event to trigger from a list, 
  output("storybook: "..faction_key.."has captured the capital! Working out which event to trigger...")
  local capital_events = self.capital_captured_events
  if emperor_in_luoyang then --check to see if Emps is at home
    for i = 1, #capital_events do 
      local event_key = capital_events[i]
      if cm:trigger_dilemma(faction_key,event_key, true) then -- go through the list until you get an event that can fire, then stop
        break
      end
    end
   else cm:trigger_dilemma(faction_key, "ep_dilemma_emperor_flees_taken_by_another", true)
    output("the Emperor is in another castle!")
  end
end


function ep_storybook:is_emperor_in_luoyang() -- returns true if the emperor owner and the owner of luoyang are one and the same
  local modify_model = cm:modify_model();
  local modify_world = modify_model:get_modify_world();
  local query_tokens = modify_world:query_world():world_power_tokens();
  local emperor_owner = query_tokens:owning_faction("ep_emperor")
  local luoyang_owner = modify_world:query_world():region_manager():region_by_key("3k_main_luoyang_capital"):owning_faction()
  return luoyang_owner == emperor_owner
end
---------------------------------------------------------
--------------------SAVE/LOAD----------------------------
---------------------------------------------------------

function ep_storybook:register_save_load_callbacks()

	cm:add_saving_game_callback(
		function(saving_game_event)
			cm:save_named_value("storybook_event_generator", self.storybook_event_generator);
			cm:save_named_value("storybook_humans_intialised", self.humans_intialised);
		end
	);

	cm:add_loading_game_callback(
		function(loading_game_event)
			self.storybook_event_generator = cm:load_named_value("storybook_event_generator", self.storybook_event_generator);
			self.humans_intialised = cm:load_named_value("storybook_humans_intialised", self.humans_intialised);
		end
	);

end;

ep_storybook:register_save_load_callbacks();
