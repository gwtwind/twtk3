

out.random_army("random_army!");
out.experience("experience!");
out.events("events!");
out.advice("advice!");

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	INTERVENTIONS SCRIPTS
--	Declare scripts for campaign interventions (when the advisor appears to
--	inform the player about a game feature) here
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- set to false for release
BOOL_INTERVENTIONS_DEBUG = true;

function start_global_interventions()

	--[[ 
	Disable advice with gating tweaker
	if core:is_tweaker_set("FORCE_DISABLE_GATING") then
		return
	end;
	]]--

	-- Disable advice if we're in the tutorial and it hasn't finished. ~The campaign tutorial should call this manually when it's completed.
	if effect.get_advice_level() >= 2 and not effect.get_advice_history_string_seen(campaign_tutorial.finished_tutorial_advice_key) then
		return;
	end;
	

	out.interventions("");
	out.interventions("* start_global_interventions() called");
	out("* start_global_interventions() called - see output in interventions tab");
	out.interventions("");
	
	-- guard against being called in multiplayer
	if cm:is_multiplayer() then
		out.interventions("* not starting global interventions as this is a multiplayer game");
		return;
	end;
	
	local local_faction = cm:get_local_faction();
	local local_subculture = cm:query_local_faction():subculture();
	
	-- guard against being called in autoruns
	if not is_string(local_faction) or local_faction == "" then
		out.interventions("* not starting global interventions as this is an autorun");
	end;
		
	--
	--	start interventions here
	--
	
	if local_faction ~= "3k_main_faction_dong_zhuo" and local_subculture ~= "3k_main_subculture_yellow_turban" then 
		in_spy_advice:start()
		in_diplomacy_advice_01:start()
		in_diplomacy_advice_02:start()
		in_diplomacy_advice_03:start()
		in_ancillary_advice:start()
		in_population_advice:start()
		in_corruption_advice:start()
		in_public_order_advice:start()
		in_food_advice:start()
		in_tax_advice:start()
		in_satisfaction_advice:start()
		in_friendsrival_advice:start()
	end

	if local_faction == "3k_main_faction_yuan_shao" then
		in_captains_advice:start()
	end

	if local_subculture ~= "3k_main_subculture_yellow_turban" then
		in_faction_04_advice:start()
		in_faction_08_advice:start()
		in_minister_advice:start()
		in_trade_02_advice:start()
		in_marriage_advice:start()
		in_faction_03_advice:start()
		in_family_tree_advice:start()
		in_court_nobles_advice:start()
		in_faction_07_advice:start()
	end

	in_ambush_defence_advice:start()
	in_ambush_stance_advice:start()
	in_movement_points_exhausted_advice:start()
	in_attrition_advice:start()
	in_autoresolving_advice:start()
	in_near_bankruptcy_advice:start()
	in_bankruptcy_advice:start()

	in_buildings_damaged_advice:start()
	in_building_construction_advice:start()
	in_character_skill_advice:start()
	in_low_satisfaction_advice:start()
	in_dilemma_advice:start()

	in_player_reinforcements_advice:start()
	in_enemy_reinforcements_advice:start()
	in_resources_advice:start()
	in_low_food_advice:start()
	in_economy_advice:start()
	in_battle_types_advice:start()
	in_battles_advice:start()
	in_building_effects_advice:start()
	in_building_scope_advice:start()
	in_events_advice:start()
	in_council_mission_advice:start()

	--in_imperial_recommendation_advice:start()
	in_character_wounded_advice:start()
	in_force_created_advice:start()
	in_governor_advice:start()
	in_heroes_01_advice:start()
	in_craftsmen_advice:start()

	in_assignments_advice:start()
	in_building_slot_advice:start()
	in_civil_war_advice:start()
	in_encampment_advice:start()
	in_encampment_stance_advice:start()
	in_faction_01_advice:start()
	in_faction_02_advice:start()
	in_faction_05_advice:start()
	in_faction_06_advice:start()

	in_heroes_02_advice:start()
	in_military_conquest_advice:start()
	in_missions_advice:start()
	in_money_advice:start()
	in_politics_advice:start()
	in_post_battle_defeated_advice:start()
	in_post_battle_land_advice:start()
	in_post_battle_siege_advice:start()
	in_pre_battle_01_advice:start()
	in_pre_battle_02_advice:start()
	in_pre_battle_03_advice:start()
	in_province_management_01_advice:start()
	in_province_management_02_advice:start()
	in_province_management_03_advice:start()
	in_province_management_04_advice:start()
	in_province_management_05_advice:start()
	in_province_management_06_advice:start()
	in_province_management_07_advice:start()
	in_razing_advice:start()
	in_razing_advice_dong_zhuo:start()
	in_retinues_advice:start()
	in_force_selected_advice:start()
	in_recruitment_advice:start()
	in_unit_types_advice:start()
	in_units_01_advice:start()
	in_units_02_advice:start()
	in_units_03_advice:start()
	in_units_04_advice:start()
	in_units_05_advice:start()
	in_units_06_advice:start()
	in_force_supply_advice:start()
	in_revolts_01_advice:start()
	in_revolts_02_advice:start()
	in_roads_advice:start()
	in_siegeing_advice:start()
	in_besieged_advice:start()
	in_spy_actions_advice:start()
	in_spy_discovered_advice:start()
	in_strategic_map_advice:start()
	in_tax_auto_advice:start()
	in_terrain_types_advice:start()
	-- in_trade_01_advice:start() not used
	in_traits_advice:start()

	in_vendetta_advice:start()
	in_hostages_advice:start()

	in_stances_advice:start()

	in_diplomacy_attitudes_advice:start()
	in_diplomacy_firststeps_advice:start()
	in_diplomacy_flow_01_advice:start()
	in_diplomacy_flow_02_advice:start()
	in_diplomacy_personalities_advice:start()
	in_diplomacy_role_advice:start()
	in_diplomacy_threats_advice:start()
	in_diplomacy_treachery_advice:start()
	in_diplomacy_voting_advice:start()

	in_war_advice:start()
	in_military_access:start()
	in_non_aggression:start()

	in_help_mode:start()
	in_technology_advice:start()

end;

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- GATING ADVICE ----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------
--
--	Ancillary advice
--
---------------------------------------------------------------

in_ancillary_advice = intervention:new(
	"ancillary_advice", 														-- string name
	60, 																	-- cost
	function() in_ancillary_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_ancillary_advice:add_advice_key_precondition("3k_campaign_advice_ancillary_01");
in_ancillary_advice:set_min_advice_level(1);
in_ancillary_advice:give_priority_to_intervention("character_skill_advice");
in_ancillary_advice:set_min_turn(3);

-- CEO EVENTS (FactionCeoAdded)
in_ancillary_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "character_details"
	end
);

function in_ancillary_advice_trigger()

	in_ancillary_advice:play_advice_for_intervention(
		"3k_campaign_advice_ancillary_01",
		{
			"3k_campaign_advice_ancillary_info_01"
		}
	);
	in_ancillary_advice:trigger_ui_context_for_duration("highlighted_ancillaries", 1, -1, 10);

end;

---------------------------------------------------------------
--
--	Population advice
--
---------------------------------------------------------------

in_population_advice = intervention:new(
	"population_advice", 														-- string name
	60, 																	-- cost
	function() in_population_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_population_advice:add_advice_key_precondition("3k_campaign_advice_population_01");
in_population_advice:set_min_advice_level(1);
in_population_advice:set_min_turn(5);
in_population_advice:give_priority_to_intervention("province_management_01_advice");
in_population_advice:give_priority_to_intervention("building_construction_advice");
in_population_advice:give_priority_to_intervention("building_slot_advice");
in_population_advice:give_priority_to_intervention("building_effects_advice");

in_population_advice:add_trigger_condition(
	"SettlementSelected", 
	function(context)
		return context:settlement():faction():is_human();
	end
);

function in_population_advice_trigger()
	in_population_advice:play_advice_for_intervention(
		"3k_campaign_advice_population_01",
		{
			"3k_campaign_advice_population_info_01"
		}
	);

	--context_key, enable_value, disable_value, duration
	-- Show everywhere! Province Panel, City Info Bar
	in_population_advice:trigger_ui_context_for_duration("highlighted_population", "true", "false", 10);
	
end;

---------------------------------------------------------------
--
--	Corruption advice
--
---------------------------------------------------------------

in_corruption_advice = intervention:new(
	"corruption_advice", 														-- string name
	60, 																	-- cost
	function() in_corruption_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_corruption_advice:add_advice_key_precondition("3k_campaign_advice_corruption_01");
in_corruption_advice:set_min_advice_level(1);

in_corruption_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart", 
	function(context)
		local region_list = context:faction():faction_province_list();
		
		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);

			if region:tax_administration_cost() ~= 0 then
				return true
			end
		end
	end
); 

function in_corruption_advice_trigger()
	in_corruption_advice:play_advice_for_intervention(
		"3k_campaign_advice_corruption_01",
		{
			"3k_campaign_advice_corruption_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Public Order advice
--
---------------------------------------------------------------

in_public_order_advice = intervention:new(
	"public_order_advice", 														-- string name
	60, 																	-- cost
	function() in_public_order_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_public_order_advice:add_advice_key_precondition("3k_campaign_advice_public_order_01");
in_public_order_advice:set_min_advice_level(1);

in_public_order_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart", 
	function(context)
		local region_list = context:faction():region_list();
		
		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);
			out.interventions("*-* Public order check for region " .. region:name() .. ' public order is ' .. region:public_order())
			if region:public_order() < -20 then				
				return true;				
			end;
		end;
		
		return false;
	end
); 

function in_public_order_advice_trigger()
	in_public_order_advice:play_advice_for_intervention(
		"3k_campaign_advice_public_order_01",
		{
			"3k_campaign_advice_public_order_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Food advice
--
---------------------------------------------------------------

in_food_advice = intervention:new(
	"food_advice", 														-- string name
	60, 																	-- cost
	function() in_food_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_food_advice:add_advice_key_precondition("3k_campaign_advice_food_01");
in_food_advice:set_min_advice_level(1);

in_food_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart", 
	function(context)
		local food = context:faction():pooled_resources():resource('3k_main_pooled_resource_food'):value();

		if food < 0 then
			return true;
		end;		
		
		return false;
	end
);

function in_food_advice_trigger()
	in_food_advice:play_advice_for_intervention(
		"3k_campaign_advice_food_01",
		{
			"3k_campaign_advice_food_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Tax advice
--
---------------------------------------------------------------

in_tax_advice = intervention:new(
	"tax_advice", 														-- string name
	0, 																	-- cost
	function() in_tax_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_tax_advice:add_advice_key_precondition("3k_campaign_advice_tax_01");
in_tax_advice:set_min_advice_level(1);

in_tax_advice:add_trigger_condition(
	"FactionFameLevelUp", 
	function(context)
		if context:faction():progression_level() > 0 then
			return context:faction():is_human()
		end
	end
); 

function in_tax_advice_trigger()	
	in_tax_advice:play_advice_for_intervention(
		"3k_campaign_advice_tax_01",
		{
			"3k_campaign_advice_tax_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy advice for progression level 0
--
---------------------------------------------------------------

in_diplomacy_advice_01 = intervention:new(
	"diplomacy_advice_01", 														-- string name
	40, 																	-- cost
	function() in_diplomacy_advice_01_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_advice_01:add_advice_key_precondition("3k_campaign_advice_diplomacy_01");
in_diplomacy_advice_01:set_min_advice_level(1);
in_diplomacy_advice_01:give_priority_to_intervention("diplomacy_role_advice");
in_diplomacy_advice_01:set_wait_for_fullscreen_panel_dismissed(false);

-- Trigger diplomacy advice right away
in_diplomacy_advice_01:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "diplomacy_panel"
	end
);

function in_diplomacy_advice_01_trigger()

	in_diplomacy_advice_01:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_01",
		{
			"3k_campaign_advice_diplomacy_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy advice for progression level 2
--
---------------------------------------------------------------

in_diplomacy_advice_02 = intervention:new(
	"diplomacy_advice_02", 														-- string name
	0, 																	-- cost
	function() in_diplomacy_advice_02_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_advice_02:add_advice_key_precondition("3k_campaign_advice_diplomacy_02");
in_diplomacy_advice_02:set_min_advice_level(1);

-- Trigger diplomacy advice 2 when reaching progression_level 2
in_diplomacy_advice_02:add_trigger_condition(
	"FactionFameLevelUp",
	function(context)
		if context:faction():progression_level() > 1 then
			return context:faction():is_human()
		end
	end
);

function in_diplomacy_advice_02_trigger()

	in_diplomacy_advice_02:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_02",
		{
			"3k_campaign_advice_diplomacy_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy advice for vassals
--
---------------------------------------------------------------

in_diplomacy_advice_03 = intervention:new(
	"diplomacy_advice_03", 														-- string name
	0, 																	-- cost
	function() in_diplomacy_advice_03_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_advice_03:add_advice_key_precondition("3k_campaign_advice_diplomacy_03");
in_diplomacy_advice_03:set_min_advice_level(1);
in_diplomacy_advice_03:give_priority_to_intervention("diplomacy_advice_02");

-- Trigger diplomacy advice for vassals when reaching Marquis
in_diplomacy_advice_03:add_trigger_condition(
	"FactionFameLevelUp",
	function(context)
		if context:faction():progression_level() > 2 then
			return context:faction():is_human()
		end
	end
);

function in_diplomacy_advice_03_trigger()

	in_diplomacy_advice_03:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_03",
		{
			"3k_campaign_advice_diplomacy_info_03"
		}
	);
end;

---------------------------------------------------------------
--
--	Satisfaction advice
--
---------------------------------------------------------------

in_satisfaction_advice = intervention:new(
	"satisfaction_advice", 														-- string name
	60, 																	-- cost
	function() in_satisfaction_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_satisfaction_advice:add_advice_key_precondition("3k_campaign_advice_satisfaction_01");
in_satisfaction_advice:set_min_advice_level(1);

-- Trigger satisfaction advice when character below certain satisfaction
in_satisfaction_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart", 
	function(context)
		local character_list = context:faction():character_list();
		
		for i = 0, character_list:num_items() - 1 do
			local character = character_list:item_at(i);
			out.interventions("*-* Satisfaction check for character " .. character:cqi() .. ' satisfaction is ' .. character:loyalty())

			if character:loyalty() < 20 then				
				return true;				
			end;
		end;
	end
); 

function in_satisfaction_advice_trigger()
	in_satisfaction_advice:play_advice_for_intervention(
		"3k_campaign_advice_satisfaction_01",
		{
			"3k_campaign_advice_satisfaction_info_01"
		}
	);
	in_satisfaction_advice:trigger_ui_context_for_duration("highlighted_satisfaction", 1, -1, 10);
end;

---------------------------------------------------------------
--
--	Friendsrival advice
--
---------------------------------------------------------------

in_friendsrival_advice = intervention:new(
	"friendsrival_advice", 												    -- string name
	60, 																	-- cost
	function() in_friendsrival_advice_trigger() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_friendsrival_advice:add_advice_key_precondition("3k_campaign_advice_friendsrival_01");
in_friendsrival_advice:set_min_advice_level(1);

-- Trigger friends and rivals advice
in_friendsrival_advice:add_trigger_condition(
	"CharacterRelationshipCreatedEvent", 
	function(context)
		out.interventions("*-* CharacterRelationshipChangedEvent event received, type of relationship is " .. context:relationship():relationship_record_key());

		local characters = context:relationship():get_relationship_characters();
		for i=0, characters:num_items() - 1 do
			if characters:item_at(i):faction():name() == cm:query_model():local_faction():name() then
				return true;
			end;
		end;

		return false;
	end
); 

function in_friendsrival_advice_trigger()
	in_friendsrival_advice:play_advice_for_intervention(
		"3k_campaign_advice_friends_01",
		{
			"3k_campaign_advice_friends_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Spy advice
--
---------------------------------------------------------------

in_spy_advice = intervention:new(
	"spy_advice", 														    -- string name
	0, 																	-- cost
	function() in_spy_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_spy_advice:add_advice_key_precondition("3k_campaign_advice_spy_assignment_01");
in_spy_advice:set_min_advice_level(1);

-- Trigger spy advice
in_spy_advice:add_trigger_condition(
	"FactionFameLevelUp", 
	function(context)
		local progression_level = context:faction():progression_level()
		out.interventions("*-* gating.lua: Current progression level is " .. progression_level)
		if context:faction():is_human() == true then
			return progression_level > 0
		end
	end
);

function in_spy_advice_trigger()

	in_spy_advice:play_advice_for_intervention(
		"3k_campaign_advice_spy_assignment_01",
		{
			"3k_campaign_advice_spy_assignment_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Character skill advice
--
---------------------------------------------------------------

in_character_skill_advice = intervention:new(
	"character_skill_advice", 												-- string name
	60, 																	-- cost
	function() in_character_skill_advice_trigger() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_character_skill_advice:add_advice_key_precondition("3k_campaign_advice_character_levelup_01");
in_character_skill_advice:set_min_advice_level(1);

in_character_skill_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "character_details"
	end
);

function in_character_skill_advice_trigger()

	in_character_skill_advice:play_advice_for_intervention(
		"3k_campaign_advice_character_levelup_01",
		{
			"3k_campaign_advice_character_levelup_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Technology advice
--
---------------------------------------------------------------

in_technology_advice = intervention:new(
	"technology_advice", 												-- string name
	60, 																	-- cost
	function() in_technology_advice_trigger() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_technology_advice:add_advice_key_precondition("3k_campaign_advice_technology_01");
in_technology_advice:set_min_advice_level(1);
in_technology_advice:set_wait_for_fullscreen_panel_dismissed(false);

in_technology_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "tech_panel"
	end
);

function in_technology_advice_trigger()

	in_technology_advice:play_advice_for_intervention(
		"3k_campaign_advice_technology_01",
		{
			"3k_campaign_advice_technology_info_01"
		}
	);
end;

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- CAMPAIGN ADVICE --------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------
--
--	Diplomacy general advice
--
---------------------------------------------------------------

in_diplomacy_role_advice = intervention:new(
	"diplomacy_role_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_role_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_role_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_role");
in_diplomacy_role_advice:set_min_advice_level(1);
in_diplomacy_role_advice:set_wait_for_fullscreen_panel_dismissed(false);

-- Trigger diplomacy advice
in_diplomacy_role_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "diplomacy_panel"
	end
);

function in_diplomacy_role_advice_trigger()

	in_diplomacy_role_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_role",
		{
			"3k_campaign_advice_diplomacy_role_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy personality advice
--
---------------------------------------------------------------

in_diplomacy_personalities_advice = intervention:new(
	"diplomacy_personalities_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_personalities_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_personalities_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_personalities");
in_diplomacy_personalities_advice:set_min_advice_level(1);
in_diplomacy_personalities_advice:set_min_turn(5);
in_diplomacy_personalities_advice:give_priority_to_intervention("diplomacy_role_advice");
in_diplomacy_personalities_advice:give_priority_to_intervention("diplomacy_advice_01");

-- Trigger diplomacy advice
in_diplomacy_personalities_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local progression = context:faction():progression_level()

		if progression > 0 then
			return true
		end
	end
);

function in_diplomacy_personalities_advice_trigger()

	in_diplomacy_personalities_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_personalities",
		{
			"3k_campaign_advice_diplomacy_personalities_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy attitudes advice
--
---------------------------------------------------------------

in_diplomacy_attitudes_advice = intervention:new(
	"diplomacy_attitudes_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_attitudes_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_attitudes_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_attitudes");
in_diplomacy_attitudes_advice:set_min_advice_level(1);
in_diplomacy_attitudes_advice:set_min_turn(8);
in_diplomacy_attitudes_advice:give_priority_to_intervention("diplomacy_role_advice");
in_diplomacy_attitudes_advice:give_priority_to_intervention("diplomacy_advice_01");
in_diplomacy_attitudes_advice:give_priority_to_intervention("diplomacy_firststeps_advice");
in_diplomacy_attitudes_advice:set_wait_for_fullscreen_panel_dismissed(false);

-- Trigger diplomacy advice
in_diplomacy_attitudes_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "diplomacy_panel"
	end
);

function in_diplomacy_attitudes_advice_trigger()

	in_diplomacy_attitudes_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_attitudes",
		{
			"3k_campaign_advice_diplomacy_attitudes_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy firststeps advice
--
---------------------------------------------------------------

in_diplomacy_firststeps_advice = intervention:new(
	"diplomacy_firststeps_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_firststeps_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_firststeps_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_firststeps");
in_diplomacy_firststeps_advice:set_min_advice_level(1);
in_diplomacy_firststeps_advice:set_min_turn(12);
in_diplomacy_firststeps_advice:give_priority_to_intervention("diplomacy_role_advice");
in_diplomacy_firststeps_advice:give_priority_to_intervention("diplomacy_advice_01");
in_diplomacy_firststeps_advice:set_wait_for_fullscreen_panel_dismissed(false);

-- Trigger diplomacy advice
in_diplomacy_firststeps_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "diplomacy_panel"
	end
);

function in_diplomacy_firststeps_advice_trigger()

	in_diplomacy_firststeps_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_firststeps",
		{
			"3k_campaign_advice_diplomacy_firststeps_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy flow 01 advice
--
---------------------------------------------------------------

in_diplomacy_flow_01_advice = intervention:new(
	"diplomacy_flow_01_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_flow_01_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_flow_01_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_flow_01");
in_diplomacy_flow_01_advice:set_min_advice_level(1);
in_diplomacy_flow_01_advice:set_min_turn(15);
in_diplomacy_flow_01_advice:give_priority_to_intervention("diplomacy_role_advice");
in_diplomacy_flow_01_advice:give_priority_to_intervention("diplomacy_advice_01");
in_diplomacy_flow_01_advice:give_priority_to_intervention("diplomacy_firststeps_advice");
in_diplomacy_flow_01_advice:give_priority_to_intervention("diplomacy_attitudes_advice");
in_diplomacy_flow_01_advice:set_wait_for_fullscreen_panel_dismissed(false);

-- Trigger diplomacy advice
in_diplomacy_flow_01_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "diplomacy_panel"
	end
);

function in_diplomacy_flow_01_advice_trigger()

	in_diplomacy_flow_01_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_flow_01",
		{
			"3k_campaign_advice_diplomacy_flow_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy flow 02 advice
--
---------------------------------------------------------------

in_diplomacy_flow_02_advice = intervention:new(
	"diplomacy_flow_02_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_flow_02_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_flow_02_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_flow_02");
in_diplomacy_flow_02_advice:set_min_advice_level(1);
in_diplomacy_flow_02_advice:set_min_turn(18);
in_diplomacy_flow_02_advice:give_priority_to_intervention("diplomacy_role_advice");
in_diplomacy_flow_01_advice:give_priority_to_intervention("diplomacy_advice_01");
in_diplomacy_flow_02_advice:give_priority_to_intervention("diplomacy_firststeps_advice");
in_diplomacy_flow_02_advice:give_priority_to_intervention("diplomacy_attitudes_advice");
in_diplomacy_flow_02_advice:give_priority_to_intervention("diplomacy_flow_01_advice");
in_diplomacy_flow_02_advice:set_wait_for_fullscreen_panel_dismissed(false);

-- Trigger diplomacy advice
in_diplomacy_flow_02_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "diplomacy_panel"
	end
);

function in_diplomacy_flow_02_advice_trigger()

	in_diplomacy_flow_02_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_flow_02",
		{
			"3k_campaign_advice_diplomacy_flow_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy threats advice
--
---------------------------------------------------------------

in_diplomacy_threats_advice = intervention:new(
	"diplomacy_threats_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_threats_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_threats_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_threats");
in_diplomacy_threats_advice:set_min_advice_level(1);
in_diplomacy_threats_advice:set_min_turn(22);
in_diplomacy_threats_advice:give_priority_to_intervention("diplomacy_02_advice");
in_diplomacy_threats_advice:give_priority_to_intervention("diplomacy_voting_advice");

-- Trigger diplomacy advice
in_diplomacy_threats_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local progression = context:faction():progression_level()

		if progression > 1 then
			return true
		end
	end
);

function in_diplomacy_threats_advice_trigger()

	in_diplomacy_threats_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_threats",
		{
			"3k_campaign_advice_diplomacy_threats_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy treachery advice
--
---------------------------------------------------------------

in_diplomacy_treachery_advice = intervention:new(
	"diplomacy_treachery_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_treachery_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_treachery_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_treachery");
in_diplomacy_treachery_advice:set_min_advice_level(1);
in_diplomacy_treachery_advice:set_min_turn(26);
in_diplomacy_treachery_advice:give_priority_to_intervention("diplomacy_personalities_advice");

-- Trigger diplomacy advice
in_diplomacy_treachery_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local progression = context:faction():progression_level()

		if progression > 0 then
			return true
		end
	end
);

function in_diplomacy_treachery_advice_trigger()

	in_diplomacy_treachery_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_treachery",
		{
			"3k_campaign_advice_diplomacy_treachery_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Diplomacy voting advice
--
---------------------------------------------------------------

in_diplomacy_voting_advice = intervention:new(
	"diplomacy_voting_advice", 														-- string name
	60, 																	-- cost
	function() in_diplomacy_voting_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_diplomacy_voting_advice:add_advice_key_precondition("3k_campaign_advice_diplomacy_voting");
in_diplomacy_voting_advice:set_min_advice_level(1);
in_diplomacy_voting_advice:set_min_turn(30);
in_diplomacy_voting_advice:give_priority_to_intervention("diplomacy_02_advice");

-- Trigger diplomacy advice
in_diplomacy_voting_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local progression = context:faction():progression_level()

		if progression > 1 then
			return true
		end
	end
);

function in_diplomacy_voting_advice_trigger()

	in_diplomacy_voting_advice:play_advice_for_intervention(
		"3k_campaign_advice_diplomacy_voting",
		{
			"3k_campaign_advice_diplomacy_voting_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Ambush Defence advice
--
---------------------------------------------------------------

in_ambush_defence_advice = intervention:new(
	"ambush_defence_advice", 																-- string name
	0, 																			-- cost
	function() in_ambush_defence_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 													-- show debug output
);

in_ambush_defence_advice:add_advice_key_precondition("3k_campaign_advice_ambushes_01");
in_ambush_defence_advice:set_min_advice_level(2);
in_ambush_defence_advice:set_wait_for_battle_complete(false);

in_ambush_defence_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedAmbushPlayerDefenderSP",
	true
);

function in_ambush_defence_advice_trigger()
	local listener_str = "in_ambush_defence_advice";
	
	-- if the player closes panel immediately then just complete
	core:add_listener(
		listener_str,
		"PanelClosedCampaign",
		function(context) return context.string == "pre_battle_screen" end,
		function()
			cm:remove_callback(listener_str);
			in_ambush_defence_advice:complete();
		end,
		false
	);
	
	cm:callback(
		function()
			core:remove_listener(listener_str);
			in_ambush_defence_advice_play();
		end,
		0.5,
		listener_str
	);
end;

function in_ambush_defence_advice_play()
	in_ambush_defence_advice:play_advice_for_intervention(
		-- An ambush, my lord! Ready your warriors for battle!
		"3k_campaign_advice_ambushes_01",
		{
			"3k_campaign_advice_ambushes_info_01"		
		}
	);
end;

---------------------------------------------------------------
--
--	Encampment advice
--
---------------------------------------------------------------

in_encampment_advice = intervention:new(
	"encampment_advice", 																-- string name
	0, 																			-- cost
	function() in_encampment_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 													-- show debug output
);

in_encampment_advice:add_advice_key_precondition("3k_campaign_advice_encampment_01");
in_encampment_advice:set_min_advice_level(2);
in_encampment_advice:set_player_turn_only(false);
in_encampment_advice:set_wait_for_battle_complete(false);

in_encampment_advice:add_trigger_condition(
	"PendingBattle",
	function(context)
		local stance = context:query_model():pending_battle():defender():military_force():active_stance();

		if stance == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_SET_CAMP" then
			return context:query_model():is_player_turn()
		end
	end
);

function in_encampment_advice_trigger()
	local listener_str = "in_encampment_advice";
	
	-- if the player closes panel immediately then just complete
	core:add_listener(
		listener_str,
		"PanelClosedCampaign",
		function(context) return context.string == "pre_battle_screen" end,
		function()
			cm:remove_callback(listener_str);
			in_encampment_advice:complete();
		end,
		false
	);
	
	cm:callback(
		function()
			core:remove_listener(listener_str);
			in_encampment_advice_play();
		end,
		0.5,
		listener_str
	);
end;

function in_encampment_advice_play()
	in_encampment_advice:play_advice_for_intervention(
		"3k_campaign_advice_encampment_01",
		{
			"3k_campaign_advice_encampment_info_01"		
		}
	);
end;

---------------------------------------------------------------
--
--	Ambush stance advice
--
---------------------------------------------------------------

-- intervention declaration
in_ambush_stance_advice = intervention:new(
	"ambush_stance_advice",	 														-- string name
	60, 																		-- cost
	function() in_ambush_stance_advice_trigger() end,									-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_ambush_stance_advice:set_min_advice_level(2);
in_ambush_stance_advice:add_precondition(function() return not effect.get_advice_history_string_seen("ambush_defence_advice") end);
in_ambush_stance_advice:add_advice_key_precondition("3k_campaign_advice_ambushes_02");
in_ambush_stance_advice:give_priority_to_intervention("stances_advice");
in_ambush_stance_advice:set_min_turn(5);

in_ambush_stance_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)	
		-- return true the player is at war
		return context:faction():has_specified_diplomatic_deal_with_anybody("treaty_components_war");
	end
);

function in_ambush_stance_advice_trigger()
	in_ambush_stance_advice:play_advice_for_intervention( 
		"3k_campaign_advice_ambushes_02", 
		{
			"3k_campaign_advice_ambushes_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Encampment stance advice
--
---------------------------------------------------------------

-- intervention declaration
in_encampment_stance_advice = intervention:new(
	"encampment_stance_advice",	 														-- string name
	60, 																		-- cost
	function() in_encampment_stance_advice_trigger() end,									-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_encampment_stance_advice:set_min_advice_level(2);
in_encampment_stance_advice:add_advice_key_precondition("3k_campaign_advice_encampment_02");
in_encampment_stance_advice:give_priority_to_intervention("stances_advice");
in_encampment_stance_advice:set_min_turn(10);

in_encampment_stance_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_encampment_stance_advice_trigger()
	in_encampment_stance_advice:play_advice_for_intervention( 
		"3k_campaign_advice_encampment_02", 
		{
			"3k_campaign_advice_encampment_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Movement Points Exhausted advice
--
---------------------------------------------------------------

-- intervention declaration
in_movement_points_exhausted_advice = intervention:new(
	"movement_points_exhausted_advice",	 													-- string name
	60, 																				-- cost
	function() in_movement_points_exhausted_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 														-- show debug output
);

in_movement_points_exhausted_advice:set_min_advice_level(1);
in_movement_points_exhausted_advice:add_advice_key_precondition("3k_campaign_advice_army_movement_01");

in_movement_points_exhausted_advice:add_trigger_condition(
	"ScriptEventPlayerCharacterFinishedMovingEvent",
	function(context)
		local character = context:character();
		-- return true if the character is of the player's faction, has a military force but hasn't fought a battle
		return character:faction():name() == cm:get_local_faction() and character:has_military_force() and character:action_points_remaining_percent() < 10;
	end
);

function in_movement_points_exhausted_advice_trigger()
	in_movement_points_exhausted_advice:play_advice_for_intervention( 
		"3k_campaign_advice_army_movement_01", 
		{
			"3k_campaign_advice_army_movement_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Stances advice
--
---------------------------------------------------------------

-- intervention declaration
in_stances_advice = intervention:new(
	"stances_advice",	 													-- string name
	60, 																				-- cost
	function() in_stances_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 														-- show debug output
);

in_stances_advice:set_min_advice_level(1);
in_stances_advice:add_advice_key_precondition("3k_campaign_advice_stances_01");
in_stances_advice:give_priority_to_intervention("force_selected_advice");
in_stances_advice:give_priority_to_intervention("force_supply_advice");
in_stances_advice:set_min_turn(5);

in_stances_advice:add_trigger_condition(
	"CharacterSelected",
	function(context)
		return context:character():faction():is_human() and not context:character():in_settlement()
	end
);

function in_stances_advice_trigger()
	in_stances_advice:play_advice_for_intervention( 
		"3k_campaign_advice_stances_01", 
		{
			"3k_campaign_advice_stances_info_01"
		}
	);

	-- on panel.
	in_stances_advice:trigger_ui_context_for_duration("highlighted_stances", "true", "false", 10)
end;

---------------------------------------------------------------
--
--	Attrition advice
--
---------------------------------------------------------------

-- intervention declaration
in_attrition_advice = intervention:new(
	"attrition_advice",	 													-- string name
	60, 																		-- cost
	function() in_attrition_advice_general_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_attrition_advice:set_min_advice_level(1);
in_attrition_advice:add_advice_key_precondition("3k_campaign_advice_attrition_01");

in_attrition_advice:add_trigger_condition(
	"AttritionEffectsApplied",
	function(context)
		return context:military_force():faction():is_human();
	end
);

function in_attrition_advice_general_trigger()
	in_attrition_advice:scroll_camera_to_character_for_intervention(
		in_attrition_advice.char_cqi,
		"3k_campaign_advice_attrition_01",
		{
			"3k_campaign_advice_attrition_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Autoresolving advice
--
---------------------------------------------------------------

-- intervention declaration
in_autoresolving_advice = intervention:new(
	"autoresolving_advice", 																		-- string name
	60, 																					-- cost
	function() in_autoresolving_advice_trigger() end,										-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 															-- show debug output
);

in_autoresolving_advice:add_advice_key_precondition("3k_campaign_advice_autoresolving_01");
in_autoresolving_advice:set_min_advice_level(1);
in_autoresolving_advice:give_priority_to_intervention("battles_advice");
in_autoresolving_advice:set_wait_for_battle_complete(false);
in_autoresolving_advice:set_min_turn(1);

in_autoresolving_advice:add_precondition(function() return not uim:get_interaction_monitor_state("autoresolve_selected") end);

in_autoresolving_advice:add_trigger_condition(
	"PendingBattle",
	function(context)
		local battle = context:query_model():pending_battle()
		if battle:attacker_is_stronger() and battle:attacker():faction():is_human() then
			return true
		end
	end	
)

--[[
in_autoresolving_advice:add_trigger_condition(
	"ScriptEventTriggerAutoresolvingAdvice",
	function()
		core:remove_listener("autoresolve_advice");
	
		-- only trigger if the autoresolve button is enabled
		local uic_deployment = find_uicomponent(core:get_ui_root(), "pre_battle_screen", "mid", "regular_deployment");
		if uic_deployment then
			-- siege autoresolve button
			local uic_button_autoresolve_siege = find_uicomponent(uic_deployment, "button_set_siege", "button_autoresolve");
			if uic_button_autoresolve_siege and uic_button_autoresolve_siege:Visible(true) and uic_button_autoresolve_siege:CurrentState() ~= "inactive" then
				return true;
			end;
			
			-- field autoresolve button
			local uic_button_autoresolve_attack = find_uicomponent(uic_deployment, "button_set_attack", "button_autoresolve");
			if uic_button_autoresolve_attack and uic_button_autoresolve_attack:Visible(true) and uic_button_autoresolve_attack:CurrentState() ~= "inactive" then
				return true;
			end;
		end;

	end
);
]]--

--[[
in_autoresolving_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedSPField",
	function()
		if uim:get_interaction_monitor_state("autoresolve_selected") then
			out("\tstopping in_autoresolving as autoresolve option has previously been selected");
			in_autoresolving_advice:stop();
			return false;
		end;
		
		-- a bit hacky - we may be able to trigger, but we have to wait for Pre Battle Panel to get fully on-screen so we can test the state of the autoresolve button.
		-- fire another event which this intervention picks up on (see script above).
		cm:callback(function() core:trigger_event("ScriptEventTriggerAutoresolvingAdvice") end, 0.5, "autoresolve_advice");
		
		-- listen for the panel closing, indicating that an option has already been chosen
		core:add_listener(
			"autoresolve_advice",
			"PanelClosedCampaign",
			function(context) return context.string == "pre_battle_screen" end,
			function()
				cm:remove_callback("autoresolve_advice");
			end,
			false
		);
		
		return false;
	end
);


function in_autoresolving_advice_trigger()
	local listener_str = "in_autoresolving";

	-- if the player closes the pre-battle panel immediately then just complete
	core:add_listener(
		listener_str,
		"PanelClosedCampaign",
		function(context) return context.string == "pre_battle_screen" end,
		function()
			cm:remove_callback(listener_str);
			in_autoresolving_advice:complete();
		end,
		false
	);
	
	cm:callback(
		function()
			core:remove_listener(listener_str);
			in_autoresolving_advice_play();
		end,
		1,
		listener_str
	);
end;
]]--

function in_autoresolving_advice_trigger()
	in_autoresolving_advice:play_advice_for_intervention(
		"3k_campaign_advice_autoresolving_01",
		{
			"3k_campaign_advice_autoresolving_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Near bankruptcy advice
--
---------------------------------------------------------------

-- intervention declaration
in_near_bankruptcy_advice = intervention:new(
	"near_bankruptcy_advice",					 														-- string name
	60, 																						-- cost
	function() in_near_bankruptcy_advice_trigger() end,											-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 																-- show debug output
);

in_near_bankruptcy_advice:set_min_advice_level(1);
in_near_bankruptcy_advice:add_advice_key_precondition("3k_campaign_advice_bankruptcy_01");

in_near_bankruptcy_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local faction = context:faction();
		return faction:losing_money() and faction:treasury() < 1000 and faction:treasury() > 0;
	end
);

function in_near_bankruptcy_advice_trigger()
	in_near_bankruptcy_advice:play_advice_for_intervention(
		"3k_campaign_advice_bankruptcy_01",
		{
			"3k_campaign_advice_bankruptcy_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Bankruptcy advice
--
---------------------------------------------------------------

-- intervention declaration
in_bankruptcy_advice = intervention:new(
	"bankruptcy_advice",					 														-- string name
	60, 																					-- cost
	function() in_bankruptcy_advice_trigger() end,													-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 															-- show debug output
);

in_bankruptcy_advice:set_min_advice_level(1);
in_bankruptcy_advice:add_advice_key_precondition("3k_campaign_advice_bankruptcy_02");

in_bankruptcy_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local faction = context:faction();
		return faction:losing_money() and faction:treasury() <= 0;
	end
);

function in_bankruptcy_advice_trigger()
	in_bankruptcy_advice:play_advice_for_intervention( 
		"3k_campaign_advice_bankruptcy_02", 
		{
			"3k_campaign_advice_bankruptcy_info_02"
		}
	);
end;



---------------------------------------------------------------
--
--	Battles advice
--
---------------------------------------------------------------

in_battles_advice = intervention:new(
	"battles_advice", 														-- string name
	60, 																	-- cost
	function() in_battles_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_battles_advice:add_advice_key_precondition("3k_campaign_advice_battles_01");
in_battles_advice:set_min_advice_level(1);
in_battles_advice:set_player_turn_only(false);
in_battles_advice:set_wait_for_battle_complete(false);

-- Condition
in_battles_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedSP",
	true
);

function in_battles_advice_trigger()

	in_battles_advice:play_advice_for_intervention(
		"3k_campaign_advice_battles_01",
		{
			"3k_campaign_advice_battles_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Battle types advice
--
---------------------------------------------------------------

in_battle_types_advice = intervention:new(
	"battle_types_advice", 														-- string name
	60, 																	-- cost
	function() in_battle_types_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_battle_types_advice:add_advice_key_precondition("3k_campaign_advice_battle_type_01");
in_battle_types_advice:set_min_advice_level(1);
in_battle_types_advice:give_priority_to_intervention("battles_advice");
in_battle_types_advice:set_wait_for_battle_complete(false);
in_battle_types_advice:set_min_turn(2);

-- Condition
in_battle_types_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedSP",
	true
);

function in_battle_types_advice_trigger()

	in_battle_types_advice:play_advice_for_intervention(
		"3k_campaign_advice_battle_type_01",
		{
			"3k_campaign_advice_battle_type_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Buildings damaged adivce
--
---------------------------------------------------------------

-- intervention declaration
in_buildings_damaged_advice = intervention:new(
	"buildings_damaged_advice",	 													-- string name
	60, 																		-- cost
	function() in_buildings_damaged_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_buildings_damaged_advice:set_min_advice_level(1);
in_buildings_damaged_advice:add_advice_key_precondition("3k_campaign_advice_building_repair_01");
in_buildings_damaged_advice:set_turn_countdown_restart(5);


in_buildings_damaged_advice:add_trigger_condition(
	"ScriptEventPlayerBattleCompletedSP",
	function(context)
		local local_faction = cm:get_local_faction();
	
		-- only consider battles on the player's turn
		if cm:query_model():world():whose_turn_is_it():name() ~= local_faction then 
			return false;
		end;
	
		local region_list = cm:query_faction(local_faction):region_list();
	
		for i = 0, region_list:num_items() - 1 do
			local current_region = region_list:item_at(i);
			local current_gr = current_region:garrison_residence();
			
			if not current_gr:is_under_siege() then
				local current_slot_list = current_region:slot_list();
				
				for j = 0, current_slot_list:num_items() - 1 do
					local current_slot = current_slot_list:item_at(j);
					
					if current_slot:has_building() then
						if current_slot:building():percent_health() < 100 then
							in_buildings_damaged_advice.region_name = current_region:name();
							return true;
						end;
					end;
				end;
			end;
		end;
		
		return false;
	end
);

function in_buildings_damaged_advice_trigger()
	in_buildings_damaged_advice:play_advice_for_intervention(
		"3k_campaign_advice_building_repair_01",
		{
			"3k_campaign_advice_building_repair_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Building construction advice
--
---------------------------------------------------------------

-- intervention declaration
in_building_construction_advice = intervention:new(
	"building_construction_advice",	 											-- string name
	60, 																	-- cost
	function() in_building_construction_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_building_construction_advice:add_advice_key_precondition("3k_campaign_advice_buildings_01");
-- in_building_construction_advice:add_precondition(function() return not uim:get_interaction_monitor_state("building_constructed") end);
in_building_construction_advice:set_min_advice_level(1);
in_building_construction_advice:give_priority_to_intervention("province_management_01_advice");
in_building_construction_advice:set_min_turn(3);

in_building_construction_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		local regions = context:settlement():faction():region_list():is_empty()

		if regions == false then
			return context:settlement():faction():is_human()
		else
			return false
		end
	end 
);

function in_building_construction_advice_trigger()
	in_building_construction_advice:play_advice_for_intervention(
		"3k_campaign_advice_buildings_01",
		{
			"3k_campaign_advice_buildings_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Building slots advice
--
---------------------------------------------------------------

-- intervention declaration
in_building_slot_advice = intervention:new(
	"building_slot_advice",	 											-- string name
	60, 																	-- cost
	function() in_building_slot_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_building_slot_advice:add_advice_key_precondition("3k_campaign_advice_buildings_02");
-- in_building_slot_advice:add_precondition(function() return not uim:get_interaction_monitor_state("building_constructed") end);
in_building_slot_advice:set_min_advice_level(1);
in_building_slot_advice:set_min_turn(5);
in_building_slot_advice:give_priority_to_intervention("province_management_01_advice");
in_building_slot_advice:give_priority_to_intervention("building_construction_advice");


in_building_slot_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		local regions = context:settlement():faction():region_list():is_empty()

		if regions == false then
			return context:settlement():faction():is_human()
		else
			return false
		end
	end 
);

function in_building_slot_advice_trigger()
	in_building_slot_advice:play_advice_for_intervention(
		"3k_campaign_advice_buildings_02",
		{
			"3k_campaign_advice_buildings_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Building effects advice
--
---------------------------------------------------------------

-- intervention declaration
in_building_effects_advice = intervention:new(
	"building_effects_advice",	 											-- string name
	60, 																	-- cost
	function() in_building_effects_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_building_effects_advice:add_advice_key_precondition("3k_campaign_advice_buildings_03");
-- in_building_effects_advice:add_precondition(function() return not uim:get_interaction_monitor_state("building_constructed") end);
in_building_effects_advice:set_min_advice_level(1);
in_building_effects_advice:set_min_turn(7);
in_building_effects_advice:give_priority_to_intervention("province_management_01_advice");
in_building_effects_advice:give_priority_to_intervention("building_construction_advice");
in_building_effects_advice:give_priority_to_intervention("building_slot_advice");

in_building_effects_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		local regions = context:settlement():faction():region_list():is_empty()

		if regions == false then
			return context:settlement():faction():is_human()
		else
			return false
		end
	end 
);

function in_building_effects_advice_trigger()
	in_building_effects_advice:play_advice_for_intervention(
		"3k_campaign_advice_buildings_03",
		{
			"3k_campaign_advice_buildings_info_03"
		}
	);
end;

---------------------------------------------------------------
--
--	Building scope advice
--
---------------------------------------------------------------

-- intervention declaration
in_building_scope_advice = intervention:new(
	"building_scope_advice",	 											-- string name
	60, 																	-- cost
	function() in_building_scope_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);


in_building_scope_advice:add_advice_key_precondition("3k_campaign_advice_buildings_04");
in_building_scope_advice:add_precondition(function() return not uim:get_interaction_monitor_state("building_constructed") end);
in_building_scope_advice:set_min_advice_level(1);
in_building_scope_advice:set_min_turn(9);
in_building_scope_advice:give_priority_to_intervention("province_management_01_advice");
in_building_scope_advice:give_priority_to_intervention("building_construction_advice");
in_building_scope_advice:give_priority_to_intervention("building_slot_advice");
in_building_scope_advice:give_priority_to_intervention("building_effects_advice");
in_building_scope_advice:give_priority_to_intervention("province_management_02_advice");

in_building_scope_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		local regions = context:settlement():faction():region_list():is_empty()

		if regions == false then
			return context:settlement():faction():is_human()
		else
			return false
		end
	end 
);

function in_building_scope_advice_trigger()
	in_building_scope_advice:play_advice_for_intervention(
		"3k_campaign_advice_buildings_04",
		{
			"3k_campaign_advice_buildings_info_04"
		}
	);
end;

---------------------------------------------------------------
--
--	Events advice
--
---------------------------------------------------------------

-- intervention declaration
in_events_advice = intervention:new(
	"events_advice",	 											-- string name
	60, 																	-- cost
	function() in_events_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_events_advice:add_advice_key_precondition("3k_campaign_advice_events_01");
in_events_advice:set_min_advice_level(2);
in_events_advice:set_min_turn(5);

in_events_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "event_feed_records"
	end
);

function in_events_advice_trigger()
	in_events_advice:play_advice_for_intervention(
		"3k_campaign_advice_events_01",
		{
			"3k_campaign_advice_events_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Council mission advice
--
---------------------------------------------------------------

-- intervention declaration
in_council_mission_advice = intervention:new(
	"council_mission_advice",	 											-- string name
	60, 																	-- cost
	function() in_council_mission_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_council_mission_advice:add_advice_key_precondition("3k_campaign_advice_faction_council_missions_01");
in_council_mission_advice:set_min_advice_level(1);
in_council_mission_advice:set_min_turn(5);

in_council_mission_advice:add_trigger_condition(
	"MissionIssued",
	function(context)
		local mission = context:mission():mission_record_key();

		if mission:starts_with("3k_main_council_") == true then
			return true;
		end
	end
);

function in_council_mission_advice_trigger()
	in_council_mission_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_council_missions_01",
		{
			"3k_campaign_advice_faction_council_missions_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Character rebel advice
--
---------------------------------------------------------------

-- intervention declaration
in_low_satisfaction_advice = intervention:new(
	"in_low_satisfaction_advice",														-- string name
	60,	 																	-- cost
	function() trigger_in_low_satisfaction_advice() end,							-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_low_satisfaction_advice:set_min_advice_level(1);
in_low_satisfaction_advice:set_min_turn(5);
--in_low_satisfaction_advice:set_turn_countdown_restart(8);
in_low_satisfaction_advice:add_advice_key_precondition("3k_campaign_advice_character_rebel_01");

in_low_satisfaction_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local character_list = cm:query_faction(cm:get_local_faction()):character_list();
		for i = 0, character_list:num_items() - 1 do
			local current_char = character_list:item_at(i);
			
			if current_char:has_military_force() and current_char:loyalty() <= 20 then
				in_low_satisfaction_advice.char_cqi = current_char:cqi();
				return true;
			end;
		end;
	
		return false;
	end
);

function trigger_in_low_satisfaction_advice()
	if not in_low_satisfaction_advice.char_cqi or not core:is_advice_level_high() then
		in_low_satisfaction_advice:play_advice_for_intervention(
			"3k_campaign_advice_character_rebel_01",
			"3k_campaign_advice_character_rebel_info_01"
		);
	end;

end;

---------------------------------------------------------------
--
--	Civil war advice
--
---------------------------------------------------------------

-- intervention declaration

in_civil_war_advice = intervention:new(
	"civil_war_advice",	 														-- string name
	0, 																	-- cost
	function() in_civil_war_advice_trigger() end,									-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_civil_war_advice:set_min_advice_level(1);
in_civil_war_advice:add_advice_key_precondition("3k_campaign_advice_civil_war_01");

in_civil_war_advice:add_trigger_condition(
	"FactionCivilWarOccured",
	function(context)
		return context:faction():is_human();
	end
);

function in_civil_war_advice_trigger()
	--[[
	if cm:get_character_by_cqi(char_cqi) then
		scroll_camera_to_character_for_intervention(
			in_civil_war,
			in_civil_war_advice.char_cqi,
			"3k_campaign_advice_civil_war_01",
			{
				"3k_campaign_advice_civil_war_info_01"
			}
		);
	else

	end;
	]]--
	in_civil_war_advice:play_advice_for_intervention(
			"3k_campaign_advice_civil_war_01",
			{
				"3k_campaign_advice_civil_war_info_01"
			}
		);
end;

---------------------------------------------------------------
--
--	Court nobles advice
--
---------------------------------------------------------------

in_court_nobles_advice = intervention:new(
	"court_nobles_advice", 														    -- string name
	60, 																	-- cost
	function() in_court_nobles_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_court_nobles_advice:add_advice_key_precondition("3k_campaign_advice_court_nobles_01");
in_court_nobles_advice:set_min_advice_level(1);

-- Trigger spy advice
in_court_nobles_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return context:faction():progression_level() >= 1;
	end
);

function in_court_nobles_advice_trigger()

	in_court_nobles_advice:play_advice_for_intervention(
		"3k_campaign_advice_court_nobles_01",
		{
			"3k_campaign_advice_court_nobles_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Dilemma advice
--
---------------------------------------------------------------

in_dilemma_advice = intervention:new(
	"dilemma_advice", 														    -- string name
	60, 																	-- cost
	function() in_dilemma_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_dilemma_advice:add_advice_key_precondition("3k_campaign_advice_dilemmas_01");
in_dilemma_advice:set_min_advice_level(2);
in_dilemma_advice:set_min_turn(1);

-- Trigger dilemma advice
in_dilemma_advice:add_trigger_condition(
	"DilemmaIssuedEvent",
	function(context)
		return context:faction():is_human();
	end
);

function in_dilemma_advice_trigger()

	in_dilemma_advice:play_advice_for_intervention(
		"3k_campaign_advice_dilemmas_01",
		{
			"3k_campaign_advice_dilemmas_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Faction 01 advice - Intro
--
---------------------------------------------------------------

in_faction_01_advice = intervention:new(
	"faction_01_advice", 														    -- string name
	60, 																	-- cost
	function() in_faction_01_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_faction_01_advice:add_advice_key_precondition("3k_campaign_advice_faction_01");
in_faction_01_advice:set_min_advice_level(1);
in_faction_01_advice:set_min_turn(2);

-- Trigger faction 01 advice
in_faction_01_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_faction_01_advice_trigger()

	in_faction_01_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_01",
		{
			"3k_campaign_advice_faction_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Faction 02 advice - Victory Conditions
--
---------------------------------------------------------------

in_faction_02_advice = intervention:new(
	"faction_02_advice", 														    -- string name
	60, 																	-- cost
	function() in_faction_02_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_faction_02_advice:add_advice_key_precondition("3k_campaign_advice_faction_02");
in_faction_02_advice:set_min_advice_level(1);
in_faction_02_advice:give_priority_to_intervention("faction_01_advice");

-- Trigger faction 02 advice
in_faction_02_advice:add_trigger_condition(
	"FactionFameLevelUp",
	function(context)
		return context:faction():is_human()
	end
);

function in_faction_02_advice_trigger()

	in_faction_02_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_02",
		{
			"3k_campaign_advice_faction_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Faction 03 advice - Faction Leader and Heir
--
---------------------------------------------------------------

in_faction_03_advice = intervention:new(
	"faction_03_advice", 														    -- string name
	60, 																	-- cost
	function() in_faction_03_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_faction_03_advice:add_advice_key_precondition("3k_campaign_advice_faction_03");
in_faction_03_advice:set_min_advice_level(1);
in_faction_03_advice:set_min_turn(6);
in_faction_03_advice:give_priority_to_intervention("family_tree_advice");
in_faction_03_advice:give_priority_to_intervention("politics_advice");
in_faction_03_advice:set_wait_for_fullscreen_panel_dismissed(false);

-- Trigger faction 03 advice
in_faction_03_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "family_court_panel"
	end
);

function in_faction_03_advice_trigger()

	in_faction_03_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_03",
		{
			"3k_campaign_advice_faction_info_03"
		}
	);
end;

---------------------------------------------------------------
--
--	Faction 04 advice - Prestige
--
---------------------------------------------------------------

in_faction_04_advice = intervention:new(
	"faction_04_advice", 														    -- string name
	60, 																	-- cost
	function() in_faction_04_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_faction_04_advice:add_advice_key_precondition("3k_campaign_advice_faction_04");
in_faction_04_advice:set_min_advice_level(1);
in_faction_04_advice:set_min_turn(3);
in_faction_04_advice:give_priority_to_intervention("faction_01_advice");

-- Trigger faction 04 advice
in_faction_04_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_faction_04_advice_trigger()

	in_faction_04_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_04",
		{
			"3k_campaign_advice_faction_info_04"
		}
	);
end;

---------------------------------------------------------------
--
--	Faction 05 advice - Faction Rank
--
---------------------------------------------------------------

in_faction_05_advice = intervention:new(
	"faction_05_advice", 														    -- string name
	60, 																	-- cost
	function() in_faction_05_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_faction_05_advice:add_advice_key_precondition("3k_campaign_advice_faction_05");
in_faction_05_advice:set_min_advice_level(1);
in_faction_05_advice:give_priority_to_intervention("faction_01_advice");
in_faction_05_advice:give_priority_to_intervention("faction_03_advice");
in_faction_05_advice:give_priority_to_intervention("faction_04_advice");

-- Trigger faction 05 advice
in_faction_05_advice:add_trigger_condition(
	"FactionFameLevelUp",
	function(context)
		return context:faction():is_human()
	end
);

function in_faction_05_advice_trigger()

	in_faction_05_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_05",
		{
			"3k_campaign_advice_faction_info_05"
		}
	);
end;

---------------------------------------------------------------
--
--	Faction 06 advice - Player Emperor
--
---------------------------------------------------------------

in_faction_06_advice = intervention:new(
	"faction_06_advice", 														    -- string name
	60, 																	-- cost
	function() in_faction_06_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_faction_06_advice:add_advice_key_precondition("3k_campaign_advice_faction_06");
in_faction_06_advice:set_min_advice_level(1);

-- Trigger faction 06 advice
in_faction_06_advice:add_trigger_condition(
	"FactionBecomesWorldLeader",
	function(context)
		if context:faction():is_human() == true then
			return true
		end
	end
);

function in_faction_06_advice_trigger()

	in_faction_06_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_06",
		{
			"3k_campaign_advice_faction_info_06"
		}
	);
end;

---------------------------------------------------------------
--
--	Faction 07 advice - Player Emperor
--
---------------------------------------------------------------

in_faction_07_advice = intervention:new(
	"faction_07_advice", 														    -- string name
	60, 																	-- cost
	function() in_faction_07_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_faction_07_advice:add_advice_key_precondition("3k_campaign_advice_faction_07");
in_faction_07_advice:set_min_advice_level(1);
in_faction_07_advice:give_priority_to_intervention("faction_06_advice");

-- Trigger faction 07 advice
in_faction_07_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_faction_07_advice_trigger()

	in_faction_07_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_07",
		{
			"3k_campaign_advice_faction_info_07"
		}
	);
end;

---------------------------------------------------------------
--
--	Faction 08 advice - Player Emperor
--
---------------------------------------------------------------

in_faction_08_advice = intervention:new(
	"faction_08_advice", 														    -- string name
	60, 																	-- cost
	function() in_faction_08_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_faction_08_advice:add_advice_key_precondition("3k_campaign_advice_faction_08");
in_faction_08_advice:set_min_advice_level(1);

-- Trigger faction 08 advice
in_faction_08_advice:add_trigger_condition(
	"FactionBecomesWorldLeader",
	function(context)
		if context:faction():is_human() == false then
			return true
		end
	end
);

function in_faction_08_advice_trigger()

	in_faction_08_advice:play_advice_for_intervention(
		"3k_campaign_advice_faction_08",
		{
			"3k_campaign_advice_faction_info_08"
		}
	);
end;

---------------------------------------------------------------
--
--	Family tree advice
--
---------------------------------------------------------------

in_family_tree_advice = intervention:new(
	"family_tree_advice", 														    -- string name
	60, 																	-- cost
	function() in_family_tree_advice_trigger() end,								    -- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_family_tree_advice:add_advice_key_precondition("3k_campaign_advice_family_tree_01");
in_family_tree_advice:set_min_advice_level(1);
in_family_tree_advice:give_priority_to_intervention("politics_advice");
in_family_tree_advice:set_wait_for_fullscreen_panel_dismissed(false);

-- Trigger family tree advice
in_family_tree_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "family_court_panel"
	end
);

function in_family_tree_advice_trigger()

	in_family_tree_advice:play_advice_for_intervention(
		"3k_campaign_advice_family_tree_01",
		{
			"3k_campaign_advice_family_tree_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Player reinforcements advice
--
---------------------------------------------------------------

-- intervention declaration
in_player_reinforcements_advice = intervention:new(
	"in_player_reinforcements_advice",	 											-- string name
	60, 																	-- cost
	function() in_player_reinforcements_advice_trigger() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_player_reinforcements_advice:set_min_advice_level(1);
in_player_reinforcements_advice:add_advice_key_precondition("3k_campaign_advice_reinforcements_01");
in_player_reinforcements_advice:set_player_turn_only(false);
in_player_reinforcements_advice:set_wait_for_battle_complete(false);

in_player_reinforcements_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedSP",
	function(context)
		
		-- don't process if this is a siege battle
		if string.find(cm:query_model():pending_battle():battle_type(), "settlement") then
			return false;
		end;
		
		if cm:pending_battle_cache_faction_was_attacker(cm:get_local_faction()) then
			if cm:pending_battle_cache_num_attackers() > 1 then
				return true;
			end;
		else
			if cm:pending_battle_cache_num_defenders() > 1 then
				return true;
			end;
		end;
		
		return false;
	end
);

function in_player_reinforcements_advice_trigger()
	in_player_reinforcements_advice:play_advice_for_intervention( 
		"3k_campaign_advice_reinforcements_02",
		{
			"3k_campaign_advice_reinforcements_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Enemy reinforcements advice
--
---------------------------------------------------------------

-- intervention declaration
in_enemy_reinforcements_advice = intervention:new(
	"enemy_reinforcements_advice",	 												-- string name
	60, 																	-- cost
	function() in_enemy_reinforcements_advice_trigger() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_enemy_reinforcements_advice:set_min_advice_level(1);
in_enemy_reinforcements_advice:add_advice_key_precondition("3k_campaign_advice_reinforcements_02");
in_enemy_reinforcements_advice:set_player_turn_only(false);
in_enemy_reinforcements_advice:set_wait_for_battle_complete(false);

in_enemy_reinforcements_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedSP",
	function(context)
		
		-- don't process if this is a siege or ambush battle
		local battle_type = cm:query_model():pending_battle():battle_type();
		if string.find(battle_type, "settlement") or string.find(battle_type, "ambush") then
			return false;
		end;
		
		if cm:pending_battle_cache_faction_was_attacker(cm:get_local_faction()) then
			if cm:pending_battle_cache_num_defenders() > 1 then
				return true;
			end;
		else
			if cm:pending_battle_cache_num_attackers() > 1 then
				return true;
			end;
		end;
		
		return false;
	end
);

function in_enemy_reinforcements_advice_trigger()
	in_enemy_reinforcements_advice:play_advice_for_intervention( 
		"3k_campaign_advice_reinforcements_01", 
		{
			"3k_campaign_advice_reinforcements_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Resources advice
--
---------------------------------------------------------------

-- intervention declaration
in_resources_advice = intervention:new(
	"resources_advice",	 														-- string name
	60, 																	-- cost
	function() in_resources_advice_trigger() end,									-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_resources_advice:set_min_advice_level(1);
in_resources_advice:add_advice_key_precondition("3k_campaign_advice_resources_01");
in_resources_advice:give_priority_to_intervention("province_management_01_advice");
in_resources_advice:give_priority_to_intervention("province_management_02_advice");
in_resources_advice:give_priority_to_intervention("province_management_03_advice");
in_resources_advice:give_priority_to_intervention("province_management_04_advice");
in_resources_advice:give_priority_to_intervention("province_management_05_advice");
in_resources_advice:give_priority_to_intervention("province_management_06_advice");
in_resources_advice:set_min_turn(9);

in_resources_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		return context:settlement():faction():is_human()
	end
);

function in_resources_advice_trigger()
	in_resources_advice:play_advice_for_intervention(
		"3k_campaign_advice_resources_01",
		{
			"3k_campaign_advice_resources_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Food low advice
--
---------------------------------------------------------------

in_low_food_advice = intervention:new(
	"low_food_advice", 														-- string name
	60, 																	-- cost
	function() in_low_food_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_low_food_advice:add_advice_key_precondition("3k_campaign_advice_food_02");
in_low_food_advice:set_min_advice_level(1);

in_low_food_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart", 
	function(context)
		local food = context:faction():pooled_resources():resource('3k_main_pooled_resource_food'):value();

		if food < 0 then
			return true;
		end;		
					
		return false;
	end
);

function in_low_food_advice_trigger()
	in_low_food_advice:play_advice_for_intervention(
		"3k_campaign_advice_food_02",
		{
			"3k_campaign_advice_food_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Captains advice
--
---------------------------------------------------------------

in_captains_advice = intervention:new(
	"captains_advice", 														-- string name
	60, 																	-- cost
	function() in_captains_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_captains_advice:add_advice_key_precondition("3k_campaign_advice_captains_01");
in_captains_advice:set_min_advice_level(1);
in_captains_advice:set_min_turn(2);

in_captains_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart", 
	function(context)
		local character = context:faction():character_list():num_items();
		out.interventions("#captains_advice# Player faction contains: " .. character .. " characters")

		if character > 10 and context:faction():name() == "3k_main_faction_yuan_shao" then
			return true;
		end;

		return false;
	end
);

function in_captains_advice_trigger()
	in_captains_advice:play_advice_for_intervention(
		"3k_campaign_advice_captains_01",
		{
			"3k_campaign_advice_captains_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Economy advice
--
---------------------------------------------------------------

in_economy_advice = intervention:new(
	"economy_advice", 														-- string name
	60, 																	-- cost
	function() in_economy_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_economy_advice:add_advice_key_precondition("3k_campaign_advice_economy_01");
in_economy_advice:set_min_advice_level(2);
in_economy_advice:set_min_turn(10);

in_economy_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart", 
	function(context)
		local treasury = context:faction():treasury();

		if treasury < 2000 then
			return true;
		end;

		return false;
	end
);

function in_economy_advice_trigger()
	in_economy_advice:play_advice_for_intervention(
		"3k_campaign_advice_economy_01",
		{
			"3k_campaign_advice_economy_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Marriage advice
--
---------------------------------------------------------------

in_marriage_advice = intervention:new(
	"marriage_advice", 														-- string name
	60, 																	-- cost
	function() in_marriage_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_marriage_advice:add_advice_key_precondition("3k_campaign_advice_marriage_01");
in_marriage_advice:set_min_advice_level(1);
in_marriage_advice:set_min_turn(10);

in_marriage_advice:add_trigger_condition(
	"CharacterComesOfAge", 
	function(context)
		if context:query_character():faction():is_human() == true then
			return true;
		end
	end
);

function in_marriage_advice_trigger()
	in_marriage_advice:play_advice_for_intervention(
		"3k_campaign_advice_marriage_01",
		{
			"3k_campaign_advice_marriage_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Character wounded advice
--
---------------------------------------------------------------

in_character_wounded_advice = intervention:new(
	"character_wounded_advice", 							-- string name
	60, 													-- cost
	function() in_character_wounded_advice_trigger() end,	-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 							-- show debug output
);

in_character_wounded_advice:add_advice_key_precondition("3k_campaign_advice_wounds_01");
in_character_wounded_advice:set_min_advice_level(1);

in_character_wounded_advice:add_trigger_condition(
	"CharacterWoundReceivedEvent", 
	function(context, wound)
		return context:query_character():faction():is_human()
	end
);

function in_character_wounded_advice_trigger()
	in_character_wounded_advice:play_advice_for_intervention(
		"3k_campaign_advice_wounds_01",
		{
			"3k_campaign_advice_wounds_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Governor advice
--
---------------------------------------------------------------

in_governor_advice = intervention:new(
	"governor_advice", 														-- string name
	60, 																	-- cost
	function() in_governor_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_governor_advice:add_advice_key_precondition("3k_campaign_advice_governors_01");
in_governor_advice:set_min_advice_level(1);
in_governor_advice:set_min_turn(2);

-- Condition
in_governor_advice:add_trigger_condition(
	"FactionFameLevelUp", 
	function(context)
		local progression_level = context:faction():progression_level();
		if progression_level > 0 then
			return context:faction():is_human()
		end
	end
);

function in_governor_advice_trigger()

	in_governor_advice:play_advice_for_intervention(
		"3k_campaign_advice_governors_01",
		{
			"3k_campaign_advice_governors_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Minister advice
--
---------------------------------------------------------------

in_minister_advice = intervention:new(
	"minister_advice", 														-- string name
	0, 																	-- cost
	function() in_minister_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_minister_advice:add_advice_key_precondition("3k_campaign_advice_ministers_01");
in_minister_advice:set_min_advice_level(1);
in_minister_advice:set_min_turn(2);

-- Condition
in_minister_advice:add_trigger_condition(
	"FactionFameLevelUp", 
	function(context)
		if context:faction():progression_level() > 0 then
			return context:faction():is_human()
		end
	end
);

function in_minister_advice_trigger()

	in_minister_advice:play_advice_for_intervention(
		"3k_campaign_advice_ministers_01",
		{
			"3k_campaign_advice_ministers_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Heroes 01 advice 
--
---------------------------------------------------------------

in_heroes_01_advice = intervention:new(
	"heroes_01_advice", 														-- string name
	60, 																	-- cost
	function() in_heroes_01_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_heroes_01_advice:add_advice_key_precondition("3k_campaign_advice_heroes_01");
in_heroes_01_advice:set_min_advice_level(1);
in_heroes_01_advice:set_min_turn(2);

-- Condition
in_heroes_01_advice:add_trigger_condition(
	"CharacterRank",
	function(context)
		return	context:query_character():faction():is_human() == true and context:query_character():rank() > 2
	end
);

function in_heroes_01_advice_trigger()

	in_heroes_01_advice:play_advice_for_intervention(
		"3k_campaign_advice_heroes_01",
		{
			"3k_campaign_advice_heroes_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Heroes 02 advice 
--
---------------------------------------------------------------

in_heroes_02_advice = intervention:new(
	"heroes_02_advice", 														-- string name
	60, 																	-- cost
	function() in_heroes_02_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_heroes_02_advice:add_advice_key_precondition("3k_campaign_advice_heroes_02");
in_heroes_02_advice:set_min_advice_level(1);
in_heroes_02_advice:set_min_turn(3);

-- Condition
in_heroes_02_advice:add_trigger_condition(
	"CharacterRank",
	function(context)
		return	context:query_character():faction():is_human() == true and context:query_character():rank() > 4
	end
);

function in_heroes_02_advice_trigger()

	in_heroes_02_advice:play_advice_for_intervention(
		"3k_campaign_advice_heroes_02",
		{
			"3k_campaign_advice_heroes_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Master craftsman advice
--
---------------------------------------------------------------

local craftsmen_building = 
{
	"3k_resource_metal_craftsmen_animal_0", 
	"3k_resource_metal_craftsmen_animal_1",
	"3k_resource_metal_craftsmen_animal_2",
	"3k_resource_metal_craftsmen_animal_3",
	"3k_resource_metal_craftsmen_armour_0",
	"3k_resource_metal_craftsmen_armour_1",
	"3k_resource_metal_craftsmen_armour_2",
	"3k_resource_metal_craftsmen_armour_3",
	"3k_resource_metal_craftsmen_weapon_0",
	"3k_resource_metal_craftsmen_weapon_1",
	"3k_resource_metal_craftsmen_weapon_2",
	"3k_resource_metal_craftsmen_weapon_3"
}	 

in_craftsmen_advice = intervention:new(
	"craftsmen_advice", 														-- string name
	60, 																	-- cost
	function() in_craftsmen_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_craftsmen_advice:add_advice_key_precondition("3k_campaign_advice_master_craftsman_unique_01");
in_craftsmen_advice:set_min_advice_level(1);

-- Condition
in_craftsmen_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		local region_list = context:faction():region_list();
 
		
		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);
			
			for i = 1, #craftsmen_building do
				if region:building_exists(craftsmen_building[i]) == true then				
					return true;				
				end;
			end;
		end;
		
		return false;
	end
);

function in_craftsmen_advice_trigger()

	in_craftsmen_advice:play_advice_for_intervention(
		"3k_campaign_advice_master_craftsman_unique_01",
		{
			"3k_campaign_advice_master_craftsman_unique_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Hostages advice
--
---------------------------------------------------------------

in_hostages_advice = intervention:new(
	"hostages_advice", 														-- string name
	60, 																	-- cost
	function() in_hostages_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_hostages_advice:add_advice_key_precondition("3k_campaign_advice_hostages_01");
in_hostages_advice:set_min_advice_level(1);
in_hostages_advice:set_min_turn(20);

-- Condition
in_hostages_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_hostages_advice_trigger()

	in_hostages_advice:play_advice_for_intervention(
		"3k_campaign_advice_hostages_01",
		{
			"3k_campaign_advice_hostages_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Missions advice
--
---------------------------------------------------------------

in_missions_advice = intervention:new(
	"missions_advice", 														-- string name
	60, 																	-- cost
	function() in_missions_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_missions_advice:add_advice_key_precondition("3k_campaign_advice_missions_01");
in_missions_advice:set_min_advice_level(2);
in_missions_advice:set_min_turn(2);

-- Condition
in_missions_advice:add_trigger_condition(
	"ScriptEventButtonMissionsClicked",
	true
);

function in_missions_advice_trigger()

	in_missions_advice:play_advice_for_intervention(
		"3k_campaign_advice_missions_01",
		{
			"3k_campaign_advice_missions_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Assignments advice
--
---------------------------------------------------------------

in_assignments_advice = intervention:new(
	"assignments_advice", 														-- string name
	60, 																	-- cost
	function() in_assignments_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_assignments_advice:add_advice_key_precondition("3k_campaign_advice_assignments_01");
in_assignments_advice:set_min_advice_level(1);

-- Condition
in_assignments_advice:add_trigger_condition(
	"ScriptEventButtonAssigneeClicked",
	true
);

function in_assignments_advice_trigger()

	in_assignments_advice:play_advice_for_intervention(
		"3k_campaign_advice_assignments_01",
		{
			"3k_campaign_advice_assignments_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Imperial recommendation advice
--
---------------------------------------------------------------

in_imperial_recommendation_advice = intervention:new(
	"imperial_recommendation_advice", 														-- string name
	60, 																	-- cost
	function() in_imperial_recommendation_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_imperial_recommendation_advice:add_advice_key_precondition("3k_campaign_advice_imperialrec_01");
in_imperial_recommendation_advice:set_min_advice_level(1);
in_imperial_recommendation_advice:set_min_turn(2);

-- Condition
in_imperial_recommendation_advice:add_trigger_condition(
	"NewCharacterEnteredRecruitmentPool",
	function(context)
		return context:character():faction():is_human()
	end
);

function in_imperial_recommendation_advice_trigger()

	in_imperial_recommendation_advice:play_advice_for_intervention(
		"3k_campaign_advice_imperialrec_01",
		{
			"3k_campaign_advice_imperialrec_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Military conquest advice
--
---------------------------------------------------------------

in_military_conquest_advice = intervention:new(
	"military_conquest_advice", 														-- string name
	60, 																	-- cost
	function() in_military_conquest_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_military_conquest_advice:add_advice_key_precondition("3k_campaign_advice_military_conquest_01");
in_military_conquest_advice:set_min_advice_level(2);

-- Condition
in_military_conquest_advice:add_trigger_condition(
	"GarrisonOccupiedEvent",
	function(context)
		return context:garrison_residence():faction():is_human()
	end
);

function in_military_conquest_advice_trigger()
	in_military_conquest_advice:play_advice_for_intervention(
		"3k_campaign_advice_military_conquest_01",
		{
			"3k_campaign_advice_military_conquest_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Mission issued advice
--
---------------------------------------------------------------

in_mission_advice = intervention:new(
	"mission_advice", 														-- string name
	60, 																	-- cost
	function() in_mission_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_mission_advice:add_advice_key_precondition("3k_campaign_advice_missions_01");
in_mission_advice:set_min_advice_level(2);

-- Condition
in_mission_advice:add_trigger_condition(
	"MissionIssued",
	function(context)
		return context:faction():is_human()
	end
);

function in_mission_advice_trigger()
	in_mission_advice:play_advice_for_intervention(
		"3k_campaign_advice_missions_01",
		{
			"3k_campaign_advice_missions_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Money advice
--
---------------------------------------------------------------

in_money_advice = intervention:new(
	"money_advice", 														-- string name
	60, 																	-- cost
	function() in_money_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_money_advice:add_advice_key_precondition("3k_campaign_advice_money_01");
in_money_advice:set_min_advice_level(1);

-- Condition
in_money_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	function(context)
		return context:faction():losing_money()
	end
);

function in_money_advice_trigger()
	in_money_advice:play_advice_for_intervention(
		"3k_campaign_advice_money_01",
		{
			"3k_campaign_advice_money_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Politics advice
--
---------------------------------------------------------------

in_politics_advice = intervention:new(
	"politics_advice", 														-- string name
	60, 																	-- cost
	function() in_politics_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_politics_advice:add_advice_key_precondition("3k_campaign_advice_politics_01");
in_politics_advice:set_min_advice_level(1);
in_politics_advice:set_wait_for_fullscreen_panel_dismissed(false);

-- Condition
in_politics_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "family_court_panel"
	end
);

function in_politics_advice_trigger()
	in_politics_advice:play_advice_for_intervention(
		"3k_campaign_advice_politics_01",
		{
			"3k_campaign_advice_politics_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Post battle defeat advice
--
---------------------------------------------------------------

-- intervention declaration
in_post_battle_defeated_advice = intervention:new(
	"post_battle_defeated", 												-- string name
	90, 																		-- cost
	function() in_post_battle_defeated_advice_trigger() end,				-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_post_battle_defeated_advice:add_advice_key_precondition("3k_campaign_advice_post_battle_defeat_01");
in_post_battle_defeated_advice:set_min_advice_level(1);
in_post_battle_defeated_advice:set_player_turn_only(false);
in_post_battle_defeated_advice:set_wait_for_battle_complete(false);

in_post_battle_defeated_advice:add_trigger_condition(
	"ScriptEventPlayerLosesFieldBattleSP",
	true
);

--[[
function in_post_battle_defeated_advice_trigger()
	local listener_str = "in_post_battle_defeated_advice";

	-- if the player closes post-battle options immediately then just complete
	core:add_listener(
		listener_str,
		"PanelClosedCampaign",
		function(context) return context.string == "pre_battle_screen" end,
		function()
			in_post_battle_defeated_advice:complete();
			cm:remove_callback(listener_str) 
		end,
		false
	);
		
	cm:os_clock_callback(
		function()
			core:remove_listener(listener_str);
			in_post_battle_defeated_advice_play();
		end,
		1,
		listener_str
	);
end;


function in_post_battle_defeated_advice_play()

	in_post_battle_defeated_advice:play_advice_for_intervention(
		-- Your forces meet with defeat! Gather the survivors, rebuild your strength and take the fight back to the enemy!
		"3k_campaign_advice_post_battle_defeat_01",
		{
			"3k_campaign_advice_post_battle_defeat_info_01"
		}								
	);
	
	-- also complete when the post-battle panel gets closed
	core:add_listener(
		"post_battle_defeated",
		"PanelClosedCampaign",
		true,
		function(context)
			if context:component_id() == "post_battle_screen" then	
				in_post_battle_defeated_advice:cancel_play_advice_for_intervention();
				
				if in_post_battle_defeated_advice.is_active then
					in_post_battle_defeated_advice:complete();
				end;
			end
		end,
		false
	);
end;
]]

function in_post_battle_defeated_advice_trigger()
	in_post_battle_defeated_advice:play_advice_for_intervention(
		"3k_campaign_advice_post_battle_defeat_01",
		{
			"3k_campaign_advice_post_battle_defeat_info_01"
		}
	);
end;


---------------------------------------------------------------
--
--	Post battle land advice
--
---------------------------------------------------------------

in_post_battle_land_advice = intervention:new(
	"post_battle_land_advice", 														-- string name
	60, 																	-- cost
	function() in_post_battle_land_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_post_battle_land_advice:add_advice_key_precondition("3k_campaign_advice_post_battle_options_01");
in_post_battle_land_advice:set_min_advice_level(1);
in_post_battle_land_advice:set_player_turn_only(false);
in_post_battle_land_advice:set_wait_for_battle_complete(false);


-- Condition
in_post_battle_land_advice:add_trigger_condition(
	"ScriptEventPlayerWinsBattleSP",
	true
);

function in_post_battle_land_advice_trigger()
	in_post_battle_land_advice:play_advice_for_intervention(
		"3k_campaign_advice_post_battle_options_01",
		{
			"3k_campaign_advice_post_battle_options_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Post battle siege advice
--
---------------------------------------------------------------

in_post_battle_siege_advice = intervention:new(
	"post_battle_siege_advice", 														-- string name
	60, 																	-- cost
	function() in_post_battle_siege_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_post_battle_siege_advice:add_advice_key_precondition("3k_campaign_advice_post_battle_options_02");
in_post_battle_siege_advice:set_min_advice_level(1);
in_post_battle_siege_advice:set_player_turn_only(false);
in_post_battle_siege_advice:set_wait_for_battle_complete(false);

-- Condition
in_post_battle_siege_advice:add_trigger_condition(
	"ScriptEventPlayerWinsSettlementBattleSP",
	true
);

function in_post_battle_siege_advice_trigger()
	in_post_battle_siege_advice:play_advice_for_intervention(
		"3k_campaign_advice_post_battle_options_02",
		{
			"3k_campaign_advice_post_battle_options_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Pre battle 01 advice
--
---------------------------------------------------------------

in_pre_battle_01_advice = intervention:new(
	"pre_battle_01_advice", 														-- string name
	60, 																	-- cost
	function() in_pre_battle_01_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_pre_battle_01_advice:add_advice_key_precondition("3k_campaign_advice_pre_battle_options_01");
in_pre_battle_01_advice:set_min_advice_level(1);
in_pre_battle_01_advice:set_player_turn_only(false);
in_pre_battle_01_advice:set_wait_for_battle_complete(false);
in_pre_battle_01_advice:give_priority_to_intervention("battles_advice");
in_pre_battle_01_advice:set_min_turn(3);

-- Condition
in_pre_battle_01_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedSP",
	true
);

function in_pre_battle_01_advice_trigger()
	in_pre_battle_01_advice:play_advice_for_intervention(
		"3k_campaign_advice_pre_battle_options_01",
		{
			"3k_campaign_advice_pre_battle_options_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Pre battle 02 advice
--
---------------------------------------------------------------

in_pre_battle_02_advice = intervention:new(
	"pre_battle_02_advice", 														-- string name
	60, 																	-- cost
	function() in_pre_battle_02_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_pre_battle_02_advice:add_advice_key_precondition("3k_campaign_advice_pre_battle_options_02");
in_pre_battle_02_advice:set_min_advice_level(1);
in_pre_battle_02_advice:set_player_turn_only(false);
in_pre_battle_02_advice:set_wait_for_battle_complete(false);
in_pre_battle_02_advice:give_priority_to_intervention("pre_battle_01_advice");
in_pre_battle_02_advice:give_priority_to_intervention("battles_advice");
in_pre_battle_02_advice:set_min_turn(4);

-- Condition
in_pre_battle_02_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedSP",
	function(context)
		local pending_battle = cm:query_model():pending_battle()
		if pending_battle:attacker_is_stronger() and pending_battle:defender():faction():is_human() then
			return true;
		end;
		if not pending_battle:attacker_is_stronger() and pending_battle:attacker():faction():is_human() then
			return true;
		end;
	end
);

function in_pre_battle_02_advice_trigger()
	in_pre_battle_02_advice:play_advice_for_intervention(
		"3k_campaign_advice_pre_battle_options_02",
		{
			"3k_campaign_advice_pre_battle_options_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Pre battle 03 advice
--
---------------------------------------------------------------

in_pre_battle_03_advice = intervention:new(
	"pre_battle_03_advice", 														-- string name
	60, 																	-- cost
	function() in_pre_battle_03_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_pre_battle_03_advice:add_advice_key_precondition("3k_campaign_advice_pre_battle_options_03");
in_pre_battle_03_advice:set_min_advice_level(1);
in_pre_battle_03_advice:set_player_turn_only(false);
in_pre_battle_03_advice:set_wait_for_battle_complete(false);
in_pre_battle_03_advice:give_priority_to_intervention("battles_advice");
in_pre_battle_03_advice:give_priority_to_intervention("pre_battle_01_advice");
in_pre_battle_03_advice:give_priority_to_intervention("pre_battle_02_advice");
in_pre_battle_03_advice:set_min_turn(5);

-- Condition
in_pre_battle_03_advice:add_trigger_condition(
	"ScriptEventPreBattlePanelOpenedSP",
	true
);

function in_pre_battle_03_advice_trigger()
	in_pre_battle_03_advice:play_advice_for_intervention(
		"3k_campaign_advice_pre_battle_options_03",
		{
			"3k_campaign_advice_pre_battle_options_info_03"
		}
	);
end;

---------------------------------------------------------------
--
--	Province management 01 advice
--
---------------------------------------------------------------

in_province_management_01_advice = intervention:new(
	"province_management_01_advice", 														-- string name
	60, 																	-- cost
	function() in_province_management_01_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_province_management_01_advice:add_advice_key_precondition("3k_campaign_advice_province_management_01");
in_province_management_01_advice:set_min_advice_level(1);

-- Condition
in_province_management_01_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		local regions = context:settlement():faction():region_list():is_empty()

		if regions == false then
			return context:settlement():faction():is_human()
		else
			return false
		end
	end 
);

function in_province_management_01_advice_trigger()
	in_province_management_01_advice:play_advice_for_intervention(
		"3k_campaign_advice_province_management_01",
		{
			"3k_campaign_advice_province_management_info_02"
		}
	);

	-- flash ENTIRE commandery.
	-- flash ALL settlements of commandery...
	in_province_management_01_advice:trigger_ui_context_for_duration("highlighted_commandery", "true", "false", 10);

end;

---------------------------------------------------------------
--
--	Province management 02 advice
--
---------------------------------------------------------------

in_province_management_02_advice = intervention:new(
	"province_management_02_advice", 														-- string name
	60, 																	-- cost
	function() in_province_management_02_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_province_management_02_advice:add_advice_key_precondition("3k_campaign_advice_province_management_02");
in_province_management_02_advice:set_min_advice_level(1);
in_province_management_02_advice:give_priority_to_intervention("province_management_01_advice");
in_province_management_02_advice:give_priority_to_intervention("building_construction_advice");
in_province_management_02_advice:give_priority_to_intervention("building_slot_advice");
in_province_management_02_advice:give_priority_to_intervention("building_effects_advice");
in_province_management_02_advice:give_priority_to_intervention("population_advice");
in_province_management_02_advice:set_min_turn(12);

-- Condition
in_province_management_02_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		return context:settlement():faction():is_human()
	end 
);

function in_province_management_02_advice_trigger()
	in_province_management_02_advice:play_advice_for_intervention(
		"3k_campaign_advice_province_management_02",
		{
			"3k_campaign_advice_province_management_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Province management 03 advice
--
---------------------------------------------------------------

in_province_management_03_advice = intervention:new(
	"province_management_03_advice", 														-- string name
	60, 																	-- cost
	function() in_province_management_03_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_province_management_03_advice:add_advice_key_precondition("3k_campaign_advice_province_management_03");
in_province_management_03_advice:set_min_advice_level(1);
in_province_management_03_advice:give_priority_to_intervention("province_management_01_advice");
in_province_management_03_advice:give_priority_to_intervention("building_construction_advice");
in_province_management_03_advice:give_priority_to_intervention("building_slot_advice");
in_province_management_03_advice:give_priority_to_intervention("building_effects_advice");
in_province_management_03_advice:give_priority_to_intervention("population_advice");
in_province_management_03_advice:give_priority_to_intervention("province_management_02_advice");
in_province_management_03_advice:set_min_turn(14);

-- Condition
in_province_management_03_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		return context:settlement():faction():is_human()
	end 
);

function in_province_management_03_advice_trigger()
	in_province_management_03_advice:play_advice_for_intervention(
		"3k_campaign_advice_province_management_03",
		{
			"3k_campaign_advice_province_management_info_03"
		}
	);
end;

---------------------------------------------------------------
--
--	Province management 04 advice
--
---------------------------------------------------------------

in_province_management_04_advice = intervention:new(
	"province_management_04_advice", 														-- string name
	60, 																	-- cost
	function() in_province_management_04_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_province_management_04_advice:add_advice_key_precondition("3k_campaign_advice_province_management_04");
in_province_management_04_advice:set_min_advice_level(1);
in_province_management_04_advice:give_priority_to_intervention("province_management_01_advice");
in_province_management_04_advice:give_priority_to_intervention("building_construction_advice");
in_province_management_04_advice:give_priority_to_intervention("building_slot_advice");
in_province_management_04_advice:give_priority_to_intervention("building_effects_advice");
in_province_management_04_advice:give_priority_to_intervention("population_advice");
in_province_management_04_advice:give_priority_to_intervention("province_management_02_advice");
in_province_management_04_advice:give_priority_to_intervention("province_management_03_advice");
in_province_management_04_advice:set_min_turn(16);

-- Condition
in_province_management_04_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		return context:settlement():faction():is_human()
	end 
);

function in_province_management_04_advice_trigger()
	in_province_management_04_advice:play_advice_for_intervention(
		"3k_campaign_advice_province_management_04",
		{
			"3k_campaign_advice_province_management_info_04"
		}
	);
end;

---------------------------------------------------------------
--
--	Province management 05 advice
--
---------------------------------------------------------------

in_province_management_05_advice = intervention:new(
	"province_management_05_advice", 														-- string name
	60, 																	-- cost
	function() in_province_management_05_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_province_management_05_advice:add_advice_key_precondition("3k_campaign_advice_province_management_05");
in_province_management_05_advice:set_min_advice_level(1);
in_province_management_05_advice:give_priority_to_intervention("province_management_01_advice");
in_province_management_05_advice:give_priority_to_intervention("building_construction_advice");
in_province_management_05_advice:give_priority_to_intervention("building_slot_advice");
in_province_management_05_advice:give_priority_to_intervention("building_effects_advice");
in_province_management_05_advice:give_priority_to_intervention("population_advice");
in_province_management_05_advice:give_priority_to_intervention("province_management_02_advice");
in_province_management_05_advice:give_priority_to_intervention("province_management_03_advice");
in_province_management_05_advice:give_priority_to_intervention("province_management_04_advice");
in_province_management_05_advice:set_min_turn(18);

-- Condition
in_province_management_05_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		return context:settlement():faction():is_human()
	end 
);

function in_province_management_05_advice_trigger()
	in_province_management_05_advice:play_advice_for_intervention(
		"3k_campaign_advice_province_management_05",
		{
			"3k_campaign_advice_province_management_info_05"
		}
	);
end;

---------------------------------------------------------------
--
--	Province management 06 advice
--
---------------------------------------------------------------

in_province_management_06_advice = intervention:new(
	"province_management_06_advice", 														-- string name
	60, 																	-- cost
	function() in_province_management_06_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_province_management_06_advice:add_advice_key_precondition("3k_campaign_advice_province_management_06");
in_province_management_06_advice:set_min_advice_level(1);
in_province_management_06_advice:give_priority_to_intervention("province_management_01_advice");
in_province_management_06_advice:give_priority_to_intervention("building_construction_advice");
in_province_management_06_advice:give_priority_to_intervention("building_slot_advice");
in_province_management_06_advice:give_priority_to_intervention("building_effects_advice");
in_province_management_06_advice:give_priority_to_intervention("population_advice");
in_province_management_06_advice:give_priority_to_intervention("province_management_02_advice");
in_province_management_06_advice:give_priority_to_intervention("province_management_03_advice");
in_province_management_06_advice:give_priority_to_intervention("province_management_04_advice");
in_province_management_06_advice:give_priority_to_intervention("province_management_05_advice");
in_province_management_06_advice:set_min_turn(20);

-- Condition
in_province_management_06_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		return context:settlement():faction():is_human()
	end 
);

function in_province_management_06_advice_trigger()
	in_province_management_06_advice:play_advice_for_intervention(
		"3k_campaign_advice_province_management_06",
		{
			"3k_campaign_advice_province_management_info_06"
		}
	);
end;

---------------------------------------------------------------
--
--	Province management 07 advice
--
---------------------------------------------------------------

in_province_management_07_advice = intervention:new(
	"province_management_07_advice", 														-- string name
	60, 																	-- cost
	function() in_province_management_07_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_province_management_07_advice:add_advice_key_precondition("3k_campaign_advice_province_management_07");
in_province_management_07_advice:set_min_advice_level(1);
in_province_management_07_advice:give_priority_to_intervention("province_management_01_advice");
in_province_management_07_advice:give_priority_to_intervention("building_construction_advice");
in_province_management_07_advice:give_priority_to_intervention("building_slot_advice");
in_province_management_07_advice:give_priority_to_intervention("building_effects_advice");
in_province_management_07_advice:give_priority_to_intervention("population_advice");
in_province_management_07_advice:give_priority_to_intervention("province_management_02_advice");
in_province_management_07_advice:give_priority_to_intervention("province_management_03_advice");
in_province_management_07_advice:give_priority_to_intervention("province_management_04_advice");
in_province_management_07_advice:give_priority_to_intervention("province_management_05_advice");
in_province_management_07_advice:give_priority_to_intervention("province_management_06_advice");
in_province_management_07_advice:set_min_turn(22);

-- Condition
in_province_management_07_advice:add_trigger_condition(
	"SettlementSelected",
	function(context)
		return context:settlement():faction():is_human()
	end 
);

function in_province_management_07_advice_trigger()
	in_province_management_07_advice:play_advice_for_intervention(
		"3k_campaign_advice_province_management_07",
		{
			"3k_campaign_advice_province_management_info_07"
		}
	);
end;

---------------------------------------------------------------
--
--	Razing 01 advice
--
---------------------------------------------------------------

-- intervention declaration
in_razing_advice = intervention:new(
	"razing_advice",	 												-- string name
	30, 																		-- cost
	function() in_razing_advice_trigger() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_razing_advice:set_min_advice_level(1);
in_razing_advice:add_advice_key_precondition("3k_campaign_advice_razing_01");

in_razing_advice:add_trigger_condition(
	"SettlementRazed",
	true
);

function in_razing_advice_trigger()
	in_razing_advice:play_advice_for_intervention(
		"3k_campaign_advice_razing_01",
		{
			"3k_campaign_advice_razing_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Razing 02 advice
--
---------------------------------------------------------------

-- intervention declaration
in_razing_advice_dong_zhuo = intervention:new(
	"razing_advice_dong_zhuo",	 												-- string name
	20, 																		-- cost
	function() in_razing_advice_dong_zhuo_trigger() end,						-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 												-- show debug output
);

in_razing_advice_dong_zhuo:set_min_advice_level(1);
in_razing_advice_dong_zhuo:add_advice_key_precondition("3k_campaign_advice_razing_02");

in_razing_advice_dong_zhuo:add_trigger_condition(
	"SettlementRazed",
	function(context)
		return context:query_model():local_faction():name() == "3k_main_faction_dong_zhuo"
	end
);

function in_razing_advice_dong_zhuo_trigger()
	in_razing_advice_dong_zhuo:play_advice_for_intervention(
		"3k_campaign_advice_razing_02",
		{
			"3k_campaign_advice_razing_info_02"
		}
	);
end;


---------------------------------------------------------------
--
--	Generals 01 advice
--
---------------------------------------------------------------

in_force_selected_advice = intervention:new(
	"force_selected_advice", 														-- string name
	60, 																	-- cost
	function() in_force_selected_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_force_selected_advice:add_advice_key_precondition("3k_campaign_advice_generals_01");
in_force_selected_advice:set_min_advice_level(1);

-- Condition
in_force_selected_advice:add_trigger_condition(
	"CharacterSelected",
	function(context)
		return context:character():faction():is_human()
	end
);

function in_force_selected_advice_trigger()
	in_force_selected_advice:play_advice_for_intervention(
		"3k_campaign_advice_generals_01",
		{
			"3k_campaign_advice_generals_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Generals 02 advice
--
---------------------------------------------------------------

in_force_created_advice = intervention:new(
	"forces_created_advice", 														-- string name
	60, 																	-- cost
	function() in_force_created_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_force_created_advice:add_advice_key_precondition("3k_campaign_advice_generals_02");
in_force_created_advice:set_min_advice_level(1);

-- Condition
in_force_created_advice:add_trigger_condition(
	"MilitaryForceCreated",
	function(context)
		return context:military_force_created():faction():is_human()
	end
);

function in_force_created_advice_trigger()
	in_force_created_advice:play_advice_for_intervention(
		"3k_campaign_advice_generals_02",
		{
			"3k_campaign_advice_generals_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Generals 03 advice
--
---------------------------------------------------------------

in_force_supply_advice = intervention:new(
	"force_supply_advice", 														-- string name
	60, 																	-- cost
	function() in_force_supply_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_force_supply_advice:add_advice_key_precondition("3k_campaign_advice_generals_03");
in_force_supply_advice:set_min_advice_level(1);
in_force_supply_advice:give_priority_to_intervention("force_selected_advice");
in_force_supply_advice:set_min_turn(2);

-- Condition
in_force_supply_advice:add_trigger_condition(
	"CharacterSelected",
	function(context)
		local military_force_morale = context:character():military_force():morale();
		out.interventions("Selected character army morale is: " .. military_force_morale)

		if context:character():faction():is_human() and military_force_morale < 550 then 
			return true
		end
	end
);

function in_force_supply_advice_trigger()
	in_force_supply_advice:play_advice_for_intervention(
		"3k_campaign_advice_generals_03",
		{
			"3k_campaign_advice_generals_info_03"
		}
	);
	
	-- On panel - and force context. + floating ui
	in_force_supply_advice:trigger_ui_context_for_duration("highlighted_military_supply", "true", "false", 10);
end;

---------------------------------------------------------------
--
--	Retinues advice
--
---------------------------------------------------------------

in_retinues_advice = intervention:new(
	"retinues_advice", 														-- string name
	60, 																	-- cost
	function() in_retinues_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_retinues_advice:add_advice_key_precondition("3k_campaign_advice_retinues_01");
in_retinues_advice:set_min_advice_level(1);
in_retinues_advice:give_priority_to_intervention("force_selected_advice");
in_retinues_advice:set_min_turn(2);

-- Condition
in_retinues_advice:add_trigger_condition(
	"CharacterSelected",
	function(context)
		return context:character():faction():is_human()
	end
);

function in_retinues_advice_trigger()
	in_retinues_advice:play_advice_for_intervention(
		"3k_campaign_advice_retinues_01",
		{
			"3k_campaign_advice_retinues_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Recruitment advice
--
---------------------------------------------------------------

in_recruitment_advice = intervention:new(
	"recruitment_advice", 														-- string name
	60, 																	-- cost
	function() in_recruitment_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_recruitment_advice:add_advice_key_precondition("3k_campaign_advice_unit_recruitment_01");
in_recruitment_advice:set_min_advice_level(1);
in_recruitment_advice:give_priority_to_intervention("force_selected_advice");
in_recruitment_advice:give_priority_to_intervention("retinues_advice");

-- Condition
in_recruitment_advice:add_trigger_condition(
	"ScriptEventButtonEnableRecruitmentClicked",
	true
);

function in_recruitment_advice_trigger()
	in_recruitment_advice:play_advice_for_intervention(
		"3k_campaign_advice_unit_recruitment_01",
		{
			"3k_campaign_advice_unit_recruitment_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Unit types advice
--
---------------------------------------------------------------

in_unit_types_advice = intervention:new(
	"unit_types_advice", 														-- string name
	60, 																	-- cost
	function() in_unit_types_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_unit_types_advice:add_advice_key_precondition("3k_campaign_advice_unit_recruitment_01");
in_unit_types_advice:set_min_advice_level(1);
in_unit_types_advice:give_priority_to_intervention("force_selected_advice");
in_unit_types_advice:give_priority_to_intervention("retinues_advice");
in_unit_types_advice:give_priority_to_intervention("recruitment_advice");
in_unit_types_advice:set_min_turn(4);

-- Condition
in_unit_types_advice:add_trigger_condition(
	"ScriptEventButtonEnableRecruitmentClicked",
	true
);

function in_unit_types_advice_trigger()
	in_unit_types_advice:play_advice_for_intervention(
		"3k_campaign_advice_unit_recruitment_01",
		{
			"3k_campaign_advice_unit_recruitment_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Units advice
--
---------------------------------------------------------------

in_units_01_advice = intervention:new(
	"units_01_advice", 														-- string name
	60, 																	-- cost
	function() in_units_01_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_units_01_advice:add_advice_key_precondition("3k_campaign_advice_units_01");
in_units_01_advice:set_min_advice_level(1);
in_units_01_advice:give_priority_to_intervention("force_selected_advice");
in_units_01_advice:give_priority_to_intervention("retinues_advice");
in_units_01_advice:give_priority_to_intervention("recruitment_advice");
in_units_01_advice:give_priority_to_intervention("unit_types_advice");
in_units_01_advice:set_min_turn(4);

-- Condition
in_units_01_advice:add_trigger_condition(
	"ScriptEventButtonEnableRecruitmentClicked",
	true
);

function in_units_01_advice_trigger()
	in_units_01_advice:play_advice_for_intervention(
		"3k_campaign_advice_units_01",
		{
			"3k_campaign_advice_units_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Units infantry advice
--
---------------------------------------------------------------

in_units_02_advice = intervention:new(
	"units_02_advice", 														-- string name
	60, 																	-- cost
	function() in_units_02_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_units_02_advice:add_advice_key_precondition("3k_campaign_advice_units_02");
in_units_02_advice:set_min_advice_level(1);
in_units_02_advice:give_priority_to_intervention("force_selected_advice");
in_units_02_advice:give_priority_to_intervention("retinues_advice");
in_units_02_advice:give_priority_to_intervention("recruitment_advice");
in_units_02_advice:give_priority_to_intervention("unit_types_advice");
in_units_02_advice:give_priority_to_intervention("units_01_advice");
in_units_02_advice:set_min_turn(5);

-- Condition
in_units_02_advice:add_trigger_condition(
	"ScriptEventButtonEnableRecruitmentClicked",
	true
);

function in_units_02_advice_trigger()
	in_units_02_advice:play_advice_for_intervention(
		"3k_campaign_advice_units_02",
		{
			"3k_campaign_advice_units_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Units missile advice
--
---------------------------------------------------------------

in_units_03_advice = intervention:new(
	"units_03_advice", 														-- string name
	60, 																	-- cost
	function() in_units_03_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_units_03_advice:add_advice_key_precondition("3k_campaign_advice_units_03");
in_units_03_advice:set_min_advice_level(1);
in_units_03_advice:give_priority_to_intervention("force_selected_advice");
in_units_03_advice:give_priority_to_intervention("retinues_advice");
in_units_03_advice:give_priority_to_intervention("recruitment_advice");
in_units_03_advice:give_priority_to_intervention("unit_types_advice");
in_units_03_advice:give_priority_to_intervention("units_01_advice");
in_units_03_advice:give_priority_to_intervention("units_02_advice");
in_units_03_advice:set_min_turn(6);

-- Condition
in_units_03_advice:add_trigger_condition(
	"ScriptEventButtonEnableRecruitmentClicked",
	true
);

function in_units_03_advice_trigger()
	in_units_03_advice:play_advice_for_intervention(
		"3k_campaign_advice_units_03",
		{
			"3k_campaign_advice_units_info_03"
		}
	);
end;

---------------------------------------------------------------
--
--	Units cavalry advice
--
---------------------------------------------------------------

in_units_04_advice = intervention:new(
	"units_04_advice", 														-- string name
	60, 																	-- cost
	function() in_units_04_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_units_04_advice:add_advice_key_precondition("3k_campaign_advice_units_04");
in_units_04_advice:set_min_advice_level(1);
in_units_04_advice:give_priority_to_intervention("force_selected_advice");
in_units_04_advice:give_priority_to_intervention("retinues_advice");
in_units_04_advice:give_priority_to_intervention("recruitment_advice");
in_units_04_advice:give_priority_to_intervention("unit_types_advice");
in_units_04_advice:give_priority_to_intervention("units_01_advice");
in_units_04_advice:give_priority_to_intervention("units_02_advice");
in_units_04_advice:give_priority_to_intervention("units_03_advice");
in_units_04_advice:set_min_turn(7);

-- Condition
in_units_04_advice:add_trigger_condition(
	"ScriptEventButtonEnableRecruitmentClicked",
	true
);

function in_units_04_advice_trigger()
	in_units_04_advice:play_advice_for_intervention(
		"3k_campaign_advice_units_04",
		{
			"3k_campaign_advice_units_info_04"
		}
	);
end;

---------------------------------------------------------------
--
--	Units artillery advice
--
---------------------------------------------------------------

in_units_05_advice = intervention:new(
	"units_05_advice", 														-- string name
	60, 																	-- cost
	function() in_units_05_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_units_05_advice:add_advice_key_precondition("3k_campaign_advice_units_05");
in_units_05_advice:set_min_advice_level(1);
in_units_05_advice:give_priority_to_intervention("force_selected_advice");
in_units_05_advice:give_priority_to_intervention("retinues_advice");
in_units_05_advice:give_priority_to_intervention("recruitment_advice");
in_units_05_advice:give_priority_to_intervention("unit_types_advice");
in_units_05_advice:give_priority_to_intervention("units_01_advice");
in_units_05_advice:give_priority_to_intervention("units_02_advice");
in_units_05_advice:give_priority_to_intervention("units_03_advice");
in_units_05_advice:give_priority_to_intervention("units_04_advice");
in_units_05_advice:set_min_turn(8);

-- Condition
in_units_05_advice:add_trigger_condition(
	"ScriptEventButtonEnableRecruitmentClicked",
	true
);

function in_units_05_advice_trigger()
	in_units_05_advice:play_advice_for_intervention(
		"3k_campaign_advice_units_05",
		{
			"3k_campaign_advice_units_info_05"
		}
	);
end;

---------------------------------------------------------------
--
--	Units hybrids advice
--
---------------------------------------------------------------

in_units_06_advice = intervention:new(
	"units_06_advice", 														-- string name
	60, 																	-- cost
	function() in_units_06_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_units_06_advice:add_advice_key_precondition("3k_campaign_advice_units_06");
in_units_06_advice:set_min_advice_level(1);
in_units_06_advice:give_priority_to_intervention("force_selected_advice");
in_units_06_advice:give_priority_to_intervention("retinues_advice");
in_units_06_advice:give_priority_to_intervention("recruitment_advice");
in_units_06_advice:give_priority_to_intervention("unit_types_advice");
in_units_06_advice:give_priority_to_intervention("units_01_advice");
in_units_06_advice:give_priority_to_intervention("units_02_advice");
in_units_06_advice:give_priority_to_intervention("units_03_advice");
in_units_06_advice:give_priority_to_intervention("units_04_advice");
in_units_06_advice:give_priority_to_intervention("units_05_advice");
in_units_06_advice:set_min_turn(9);

-- Condition
in_units_06_advice:add_trigger_condition(
	"ScriptEventButtonEnableRecruitmentClicked",
	true
);

function in_units_06_advice_trigger()
	in_units_06_advice:play_advice_for_intervention(
		"3k_campaign_advice_units_06",
		{
			"3k_campaign_advice_units_info_06"
		}
	);
end;

---------------------------------------------------------------
--
--	Revolts advice
--
---------------------------------------------------------------

in_revolts_01_advice = intervention:new(
	"revolts_01_advice", 														-- string name
	60, 																	-- cost
	function() in_revolts_01_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_revolts_01_advice:add_advice_key_precondition("3k_campaign_advice_revolts_01");
in_revolts_01_advice:set_min_advice_level(1);

-- Condition
in_revolts_01_advice:add_trigger_condition(
	"ScriptEventRegionRebels",
	function(context)
		return context:faction():is_human()
	end
);

function in_revolts_01_advice_trigger()
	in_revolts_01_advice:play_advice_for_intervention(
		"3k_campaign_advice_revolts_01",
		{
			"3k_campaign_advice_revolts_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Revolts advice
--
---------------------------------------------------------------

in_revolts_02_advice = intervention:new(
	"revolts_02_advice", 														-- string name
	60, 																	-- cost
	function() in_revolts_02_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_revolts_02_advice:add_advice_key_precondition("3k_campaign_advice_revolts_02");
in_revolts_02_advice:set_min_advice_level(1);
in_revolts_02_advice:give_priority_to_intervention("revolts_01_advice");

-- Condition
in_revolts_02_advice:add_trigger_condition(
	"ScriptEventRegionRebels",
	function(context)
		return context:faction():is_human()
	end
);

function in_revolts_02_advice_trigger()
	in_revolts_02_advice:play_advice_for_intervention(
		"3k_campaign_advice_revolts_02",
		{
			"3k_campaign_advice_revolts_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Revolts advice
--
---------------------------------------------------------------

in_roads_advice = intervention:new(
	"roads_advice", 														-- string name
	60, 																	-- cost
	function() in_roads_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_roads_advice:add_advice_key_precondition("3k_campaign_advice_roads_01");
in_roads_advice:set_min_advice_level(1);
in_roads_advice:set_min_turn(10);

-- Condition
in_roads_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_roads_advice_trigger()
	in_roads_advice:play_advice_for_intervention(
		"3k_campaign_advice_roads_01",
		{
			"3k_campaign_advice_roads_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Siege warfare attacker advice
--
---------------------------------------------------------------

local city_building = 
{
	"3k_city_4",
	"3k_city_5",
	"3k_city_6",
	"3k_city_7",
	"3k_city_8",
	"3k_city_9",
	"3k_city_10"
}	

in_siegeing_advice = intervention:new(
	"siegeing_advice", 														-- string name
	60, 																	-- cost
	function() in_siegeing_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_siegeing_advice:add_advice_key_precondition("3k_campaign_advice_siege_warfare_01");
in_siegeing_advice:set_min_advice_level(1);
in_siegeing_advice:set_player_turn_only(false);
in_siegeing_advice:set_wait_for_battle_complete(false);

-- Condition
in_siegeing_advice:add_trigger_condition(
	"CharacterBesiegesSettlement",
	function(context)
		for i = 1, #city_building do
			if context:query_region():building_exists(city_building[i]) == true then				
				return context:query_character():faction():is_human() and context:query_region():is_province_capital()				
			end;
		end;	
	end
);

function in_siegeing_advice_trigger()
	in_siegeing_advice:play_advice_for_intervention(
		"3k_campaign_advice_siege_warfare_02",
		{
			"3k_campaign_advice_siege_warfare_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Siege warfare defender advice
--
---------------------------------------------------------------

in_besieged_advice = intervention:new(
	"besieged_advice", 														-- string name
	60, 																	-- cost
	function() in_besieged_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_besieged_advice:add_advice_key_precondition("3k_campaign_advice_siege_warfare_02");
in_besieged_advice:set_min_advice_level(1);
in_besieged_advice:set_player_turn_only(false);
in_besieged_advice:set_wait_for_battle_complete(false);

-- Condition
in_besieged_advice:add_trigger_condition(
	"CharacterBesiegesSettlement",
	function(context)
		return context:query_region():owning_faction():is_human() and context:query_region():is_province_capital()
	end
);

function in_besieged_advice_trigger()
	in_besieged_advice:play_advice_for_intervention(
		"3k_campaign_advice_siege_warfare_01",
		{
			"3k_campaign_advice_siege_warfare_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Spy action advice
--
---------------------------------------------------------------

in_spy_actions_advice = intervention:new(
	"spy_actions_advice", 														-- string name
	60, 																	-- cost
	function() in_spy_actions_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_spy_actions_advice:add_advice_key_precondition("3k_campaign_advice_spy_actions_01");
in_spy_actions_advice:set_min_advice_level(1);

-- Condition
in_spy_actions_advice:add_trigger_condition(
	"UndercoverCharacterAddedEvent",
	function(context)
		local character_list = context:query_character():undercover_character_links()
		
		for i = 0, character_list:num_items() - 1 do 
			local character = character_list:item_at(i)
			
			if character:is_hired_by_non_source_faction() == true and character:source_faction():is_human() == true then
				return true
			end
		end
	end
);

function in_spy_actions_advice_trigger()
	in_spy_actions_advice:play_advice_for_intervention(
		"3k_campaign_advice_spy_actions_01",
		{
			"3k_campaign_advice_spy_actions_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Spy discovered advice
--
---------------------------------------------------------------

in_spy_discovered_advice = intervention:new(
	"spy_discovered_advice", 														-- string name
	60, 																	-- cost
	function() in_spy_discovered_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_spy_discovered_advice:add_advice_key_precondition("3k_campaign_advice_spy_actions_02");
in_spy_discovered_advice:set_min_advice_level(1);

-- Condition
in_spy_discovered_advice:add_trigger_condition(
	"UndercoverCharacterDiscoverResolvedEvent",
	function(context)
		return context:discovering_faction():is_human()
	end
);

function in_spy_discovered_advice_trigger()
	in_spy_discovered_advice:play_advice_for_intervention(
		"3k_campaign_advice_spy_actions_02",
		{
			"3k_campaign_advice_spy_actions_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Strategic map advice
--
---------------------------------------------------------------

in_strategic_map_advice = intervention:new(
	"strategic_map_advice", 														-- string name
	60, 																	-- cost
	function() in_strategic_map_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_strategic_map_advice:add_advice_key_precondition("3k_campaign_advice_strategic_map_01");
in_strategic_map_advice:set_min_advice_level(2);
in_strategic_map_advice:set_min_turn(5);

-- Condition
in_strategic_map_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_strategic_map_advice_trigger()
	in_strategic_map_advice:play_advice_for_intervention(
		"3k_campaign_advice_strategic_map_01",
		{
			"3k_campaign_advice_strategic_map_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Tax auto advice
--
---------------------------------------------------------------

in_tax_auto_advice = intervention:new(
	"tax_auto_advice", 														-- string name
	60, 																	-- cost
	function() in_tax_auto_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_tax_auto_advice:add_advice_key_precondition("3k_campaign_advice_tax_auto_01");
in_tax_auto_advice:set_min_advice_level(1);
in_tax_auto_advice:set_min_turn(10);
in_tax_auto_advice:give_priority_to_intervention("tax_advice");

-- Condition
in_tax_auto_advice:add_trigger_condition(
	"FactionFameLevelUp",
	function(context)
		return context:faction():is_human()
	end
);

function in_tax_auto_advice_trigger()
	in_tax_auto_advice:play_advice_for_intervention(
		"3k_campaign_advice_tax_auto_01",
		{
			"3k_campaign_advice_tax_auto_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Terrain types advice
--
---------------------------------------------------------------

in_terrain_types_advice = intervention:new(
	"terrain_types_advice", 														-- string name
	60, 																	-- cost
	function() in_terrain_types_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_terrain_types_advice:add_advice_key_precondition("3k_campaign_advice_terrain_types_01");
in_terrain_types_advice:set_min_advice_level(1);
in_terrain_types_advice:set_min_turn(5);
in_terrain_types_advice:give_priority_to_intervention("movement_points_exhausted_advice");

-- Condition
in_terrain_types_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_terrain_types_advice_trigger()
	in_terrain_types_advice:play_advice_for_intervention(
		"3k_campaign_advice_terrain_types_01",
		{
			"3k_campaign_advice_terrain_types_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Trade 01 advice
--
---------------------------------------------------------------

-- not used as trigger is not able to find out when trade is offered
in_trade_01_advice = intervention:new(
	"trade_01_advice", 														-- string name
	60, 																	-- cost
	function() in_trade_01_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_trade_01_advice:add_advice_key_precondition("3k_campaign_advice_trade_01");
in_trade_01_advice:set_min_advice_level(1);
in_trade_01_advice:set_min_turn(10);

-- Condition
in_trade_01_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_trade_01_advice_trigger()
	in_trade_01_advice:play_advice_for_intervention(
		"3k_campaign_advice_trade_01",
		{
			"3k_campaign_advice_trade_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Trade 02 advice
--
---------------------------------------------------------------

in_trade_02_advice = intervention:new(
	"trade_02_advice", 														-- string name
	60, 																	-- cost
	function() in_trade_02_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_trade_02_advice:add_advice_key_precondition("3k_campaign_advice_trade_02");
in_trade_02_advice:set_min_advice_level(1);
in_trade_02_advice:set_min_turn(15);
in_trade_02_advice:give_priority_to_intervention("trade_01_advice");

-- Condition
in_trade_02_advice:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_trade_02_advice_trigger()
	in_trade_02_advice:play_advice_for_intervention(
		"3k_campaign_advice_trade_02",
		{
			"3k_campaign_advice_trade_info_02"
		}
	);
end;

---------------------------------------------------------------
--
--	Traits advice
--
---------------------------------------------------------------

in_traits_advice = intervention:new(
	"traits_advice", 														-- string name
	60, 																	-- cost
	function() in_traits_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_traits_advice:add_advice_key_precondition("3k_campaign_advice_traits_01");
in_traits_advice:set_min_advice_level(1);
in_traits_advice:give_priority_to_intervention("ancillary_advice");
in_traits_advice:set_min_turn(5);

-- Condition
in_traits_advice:add_trigger_condition(
	"PanelOpenedCampaign",
	function(context)
		return context:component_id() == "character_details"
	end
);

function in_traits_advice_trigger()
	in_traits_advice:play_advice_for_intervention(
		"3k_campaign_advice_traits_01",
		{
			"3k_campaign_advice_traits_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Vendetta advice
--
---------------------------------------------------------------

in_vendetta_advice = intervention:new(
	"vendetta_advice", 														-- string name
	60, 																	-- cost
	function() in_vendetta_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_vendetta_advice:add_advice_key_precondition("3k_campaign_advice_traits_01");
in_vendetta_advice:set_min_advice_level(1);
in_vendetta_advice:set_min_turn(10);

-- Condition
in_vendetta_advice:add_trigger_condition(
	"CharacterDied",
	function(context)
		return context:query_character():faction():is_human() and context:was_recruited_in_faction()
	end
);

function in_vendetta_advice_trigger()
	in_vendetta_advice:play_advice_for_intervention(
		"3k_campaign_advice_vendetta_01",
		{
			"3k_campaign_advice_vendetta_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	War advice
--
---------------------------------------------------------------

in_war_advice = intervention:new(
	"war_advice", 														-- string name
	60, 																	-- cost
	function() in_war_advice_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_war_advice:add_advice_key_precondition("3k_campaign_advice_war_01");
in_war_advice:set_min_advice_level(1);
in_war_advice:set_min_turn(2);

-- Condition
in_war_advice:add_trigger_condition(
	"DiplomacyDealNegotiated",
	function(context)
		local deals = context:deals():deals()
		for i=0, deals:num_items() - 1 do
			for j=0, deals:item_at(i):components():num_items() - 1 do
				if deals:item_at(i):components():item_at(j):treaty_component_key() == "treaty_components_war" then					
					out.interventions("##The treaty between the two factions is " .. deals:item_at(i):components():item_at(j):treaty_component_key() .. " ## Faction A is " .. deals:item_at(i):components():item_at(j):proposer():name() .. " ## Faction B is " .. deals:item_at(i):components():item_at(j):recipient():name())
					return deals:item_at(i):components():item_at(j):proposer():is_human() or deals:item_at(i):components():item_at(j):recipient():is_human()
				end
			end
		end
	end
);

function in_war_advice_trigger()
	in_vendetta_advice:play_advice_for_intervention(
		"3k_campaign_advice_war_01",
		{
			"3k_campaign_advice_war_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Military access advice
--
---------------------------------------------------------------

in_military_access = intervention:new(
	"military_access_advice", 														-- string name
	60, 																	-- cost
	function() in_military_access_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_military_access:add_advice_key_precondition("3k_campaign_advice_military_access_01");
in_military_access:set_min_advice_level(1);
in_military_access:set_min_turn(10);
in_military_access:give_priority_to_intervention("diplomacy_role_advice");
in_military_access:give_priority_to_intervention("diplomacy_advice_01");
in_military_access:give_priority_to_intervention("diplomacy_firststeps_advice");
in_military_access:give_priority_to_intervention("diplomacy_attitudes_advice");
in_military_access:give_priority_to_intervention("diplomacy_flow_01_advice");
in_military_access:give_priority_to_intervention("diplomacy_flow_02_advice");

-- Condition
in_military_access:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_military_access_trigger()
	in_military_access:play_advice_for_intervention(
		"3k_campaign_advice_military_access_01",
		{
			"3k_campaign_advice_military_access_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Non aggression advice
--
---------------------------------------------------------------

in_non_aggression = intervention:new(
	"non_aggression_advice", 														-- string name
	60, 																	-- cost
	function() in_non_aggression_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_non_aggression:add_advice_key_precondition("3k_campaign_advice_non_aggression_pact_01");
in_non_aggression:set_min_advice_level(1);
in_non_aggression:set_min_turn(10);
in_non_aggression:give_priority_to_intervention("diplomacy_role_advice");
in_non_aggression:give_priority_to_intervention("diplomacy_advice_01");
in_non_aggression:give_priority_to_intervention("diplomacy_firststeps_advice");
in_non_aggression:give_priority_to_intervention("diplomacy_attitudes_advice");
in_non_aggression:give_priority_to_intervention("diplomacy_flow_01_advice");
in_non_aggression:give_priority_to_intervention("diplomacy_flow_02_advice");

-- Condition
in_non_aggression:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_non_aggression_trigger()
	in_non_aggression:play_advice_for_intervention(
		"3k_campaign_advice_non_aggression_pact_01",
		{
			"3k_campaign_advice_non_aggression_pact_info_01"
		}
	);
end;

---------------------------------------------------------------
--
--	Help mode advice
--
---------------------------------------------------------------

in_help_mode = intervention:new(
	"help_mode_advice", 														-- string name
	60, 																	-- cost
	function() in_help_mode_trigger() end,								-- trigger callback
	BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
);

in_help_mode:add_advice_key_precondition("3k_campaign_advice_help_mode_01");
in_help_mode:set_min_advice_level(1);

-- Condition
in_help_mode:add_trigger_condition(
	"ScriptEventPlayerFactionTurnStart",
	true
);

function in_help_mode_trigger()
	in_help_mode:play_advice_for_intervention(
		"3k_campaign_advice_help_mode_01",
		{
			"3k_campaign_advice_help_mode_info_01"
		}
	);
end;
