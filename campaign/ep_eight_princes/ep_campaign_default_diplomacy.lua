-- Call diplomatic restriction functions appropriate to starting a new campaign
function campaign_default_diplomacy_start_new_game()
	apply_default_diplomatic_restrictions();
end;


-- Call diplomatic restriction functions appropriate to loading into a game at any point in a campaign
-- Functions which outright exclude diplomatic treaties from a campaign should be placed in here
-- Take care not to modify any diplomatic restrictions that are modified and stored based upon campaign progression :)
function campaign_default_diplomacy_start_any_game()

	-- set up faction-to-building diplomatic restriction monitors
	-- start_faction_to_building_diplomatic_restriction_monitors();
end;

-- default diplomatic restrictions
-- these are applied at the start of turn one and will stay applied throughout the campaign
function apply_default_diplomatic_restrictions()
	out("* applying default diplomacy restrictions for the eight princes campaign");

	local model = cm:modify_model();
	
	--Function: disable_diplomacy
	--Description: Disable factions being able to propose diplomatic treaty components to other factions with a reason. Filters can contain comma separated elements. Valid elements are "all", --"faction:faction_key", "subculture:subculture_key" and "culture:culture_key". component_keys is a comma separated list of campaign_diplomacy_treaty_component keys. reason_key is a key from the --campaign_diplomacy_treaty_availability_reasons table.
	--Parameters: (String proposer_filter, String recipient_filter, String component_keys, String reason_key)
	--Return: (void)
	
	--Restricting all factions from using faction specific diplomatic actions and various actions to relevant to this campaign
	--Eight princes uses "treaty_components_coalition_to_alliance_yuan_shao" to allow them to always transition their coalitions to military alliances.
	model:disable_diplomacy("all", "all", "treaty_components_attitude_manipulation_positive,treaty_components_attitude_manipulation_negative,treaty_components_attitude_manipulation_positive_sima_yue,treaty_components_attitude_manipulation_negative_sima_yue,treaty_components_instigate_proxy_war_proposer,treaty_components_sima_lun_instigate_proxy_war_proposer,treaty_components_coercion,treaty_components_sima_lun_coercion,treaty_components_recieve_coercion,treaty_components_sima_lun_recieve_coercion,treaty_components_tribute_demand,treaty_components_tribute_offer,treaty_components_create_alliance_yuan_shao,treaty_components_create_alliance_yuan_shao_counter_offer,treaty_components_create_coalition_yuan_shao,treaty_components_create_coalition_yuan_shao_counter_offer,treaty_components_coalition_to_alliance,treaty_components_coalition_to_alliance_yuan_shu,treaty_components_vassalise_proposer_yuan_shu,treaty_components_vassalise_recipient_yuan_shu,treaty_components_vassalise_proposer_sima_liang,treaty_components_vassalise_recipient_sima_liang,treaty_components_instigate_trade_monopoly,treaty_components_recieve_trade_monopoly,treaty_components_acknowledge_legitimacy_demand,treaty_components_acknowledge_legitimacy_offer,treaty_components_liu_bei_confederate_proposer,treaty_components_liu_bei_confederate_recipient,treaty_components_vassalise_proposer_yellow_turban,treaty_components_vassalise_recipient_yellow_turban,treaty_components_multiplayer_victory,treaty_components_abdicate_demand,treaty_components_abdicate_offer,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_create_coalition","hidden")
	
	--Restricting Sima Liang from using default alliance, coalition creation treaty or vassalise recipient
	model:disable_diplomacy("faction:ep_faction_prince_of_runan", "all", "treaty_components_vassalise_recipient", "hidden")
	
	--Restricting all factions from proposing default vassalise proposer recipient to Sima Liang
	model:disable_diplomacy("all", "faction:ep_faction_prince_of_runan", "treaty_components_vassalise_proposer", "hidden")


	--Restricting diplomacy between rebels and all factions
	model:disable_diplomacy("faction:ep_faction_rebels", "all", "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_marriage_give_female,treaty_components_marriage_give_female_male,treaty_components_marriage_give_male,treaty_components_marriage_give_male_female,treaty_components_marriage_recieve_female,treaty_components_marriage_recieve_female_male,treaty_components_marriage_recieve_male,treaty_components_marriage_recieve_male_female,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_abdicate_demand,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war,treaty_components_abdicate_demand,treaty_components_abdicate_offer,treaty_components_create_alliance_yuan_shu,treaty_components_create_alliance_yuan_shu_counter_offer,treaty_components_create_coalition_yuan_shu,treaty_components_create_coalition_yuan_shu_counter_offer,treaty_components_sima_lun_instigate_proxy_war_recipient,treaty_components_vassalise_recipient_sima_liang", "hidden")
  
		model:disable_diplomacy("faction:ep_factions_shadow _rebels", "all", "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_marriage_give_female,treaty_components_marriage_give_female_male,treaty_components_marriage_give_male,treaty_components_marriage_give_male_female,treaty_components_marriage_recieve_female,treaty_components_marriage_recieve_female_male,treaty_components_marriage_recieve_male,treaty_components_marriage_recieve_male_female,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_abdicate_demand,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war,treaty_components_abdicate_demand,treaty_components_abdicate_offer,treaty_components_create_alliance_yuan_shu,treaty_components_create_alliance_yuan_shu_counter_offer,treaty_components_create_coalition_yuan_shu,treaty_components_create_coalition_yuan_shu_counter_offer,treaty_components_sima_lun_instigate_proxy_war_recipient,treaty_components_vassalise_recipient_sima_liang", "hidden")
    
	--Restricting diplomacy between all factions and rebels
	model:disable_diplomacy("all", "faction:ep_faction_rebels", "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_marriage_give_female,treaty_components_marriage_give_female_male,treaty_components_marriage_give_male,treaty_components_marriage_give_male_female,treaty_components_marriage_recieve_female,treaty_components_marriage_recieve_female_male,treaty_components_marriage_recieve_male,treaty_components_marriage_recieve_male_female,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_abdicate_demand,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war,treaty_components_abdicate_demand,treaty_components_abdicate_offer,treaty_components_create_alliance_yuan_shu,treaty_components_create_alliance_yuan_shu_counter_offer,treaty_components_create_coalition_yuan_shu,treaty_components_create_coalition_yuan_shu_counter_offer,treaty_components_sima_lun_instigate_proxy_war_recipient", "hidden")

	model:disable_diplomacy("all", "faction:ep_faction_rebels", "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_marriage_give_female,treaty_components_marriage_give_female_male,treaty_components_marriage_give_male,treaty_components_marriage_give_male_female,treaty_components_marriage_recieve_female,treaty_components_marriage_recieve_female_male,treaty_components_marriage_recieve_male,treaty_components_marriage_recieve_male_female,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_abdicate_demand,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war,treaty_components_abdicate_demand,treaty_components_abdicate_offer,treaty_components_create_alliance_yuan_shu,treaty_components_create_alliance_yuan_shu_counter_offer,treaty_components_create_coalition_yuan_shu,treaty_components_create_coalition_yuan_shu_counter_offer,treaty_components_sima_lun_instigate_proxy_war_recipient", "hidden")
	--Disabling faction specific counter-proposal treaties for their respective factions
	--None at the moment
	
	--Function: enable_diplomacy
	--Description: Enable factions being able to propose diplomatic treaty components to other factions with a reason. Filters can contain comma separated elements. Valid elements are "all", --"faction:faction_key", "subculture:subculture_key" and "culture:culture_key". component_keys is a comma separated list of campaign_diplomacy_treaty_component keys. reason_key is a key from the --campaign_diplomacy_treaty_availability_reasons table.
	--Parameters: (String proposer_filter, String recipient_filter, String component_keys, String reason_key)
	--Return: (void)

	--Enabling faction specific treaties for their respective factions
	model:enable_diplomacy("faction:ep_faction_prince_of_donghai", "subculture:3k_main_chinese", "treaty_components_attitude_manipulation_positive_sima_yue,treaty_components_attitude_manipulation_negative_sima_yue", "hidden")
	model:enable_diplomacy("faction:ep_faction_prince_of_zhao", "subculture:3k_main_chinese", "treaty_components_sima_lun_coercion,treaty_components_sima_lun_instigate_proxy_war_proposer", "hidden")
	model:enable_diplomacy("faction:ep_faction_prince_of_runan", "subculture:3k_main_chinese", "treaty_components_vassalise_recipient_sima_liang", "hidden")
	model:enable_diplomacy("subculture:3k_main_chinese", "faction:ep_faction_prince_of_runan", "treaty_components_vassalise_proposer_sima_liang", "hidden")

	--Disabling faction specific counter-proposal treaties for their respective factions
	model:disable_diplomacy("faction:ep_faction_prince_of_zhao", "subculture:3k_main_chinese","treaty_components_sima_lun_instigate_proxy_war_recipient", "hidden")

	-- Disabling Sima Lun from being able to proxy war the Jin Empire until war becomes unlocked for them later - NO WAIT IT WOOOOOORRRRRRRKS
	--model:disable_diplomacy("faction:ep_faction_prince_of_zhao", "faction:ep_faction_empire_of_jin", "treaty_components_sima_lun_instigate_proxy_war_proposer", "hidden")
	--model:disable_diplomacy("faction:ep_faction_prince_of_zhao", "faction:ep_faction_empire_of_jin","treaty_components_sima_lun_instigate_proxy_war_recipient", "hidden")

	--Restricting diplomatic actions between factions and their separatist counter-parts
	local treaty_set_separatists_restrictions = "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_marriage_give_female,treaty_components_marriage_give_female_male,treaty_components_marriage_give_male,treaty_components_marriage_give_male_female,treaty_components_marriage_recieve_female,treaty_components_marriage_recieve_female_male,treaty_components_marriage_recieve_male,treaty_components_marriage_recieve_male_female,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_abdicate_demand,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war,treaty_components_abdicate_demand,treaty_components_abdicate_offer";
	
	local query_world = cm:query_model():world();
	local faction_list = query_world:faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction_name = faction_list:item_at(i):name();
		
		if not string.find(current_faction_name, "_separatists") and query_world:faction_exists(current_faction_name .. "_separatists") then
			model:disable_diplomacy("faction:" .. current_faction_name .. "_separatists", "faction:" .. current_faction_name, treaty_set_separatists_restrictions, "hidden");
			model:disable_diplomacy("faction:" .. current_faction_name, "faction:" .. current_faction_name .. "_separatists", treaty_set_separatists_restrictions, "hidden");
		end;
	end;

	local treaty_set_player_restrictions = 	
	"treaty_components_annex_vassal,treaty_components_confederate_proposer,treaty_components_confederate_recipient";
	
	local treaty_set_player_availability = 	
	"treaty_components_multiplayer_victory";
	
	local human_factions = cm:get_human_factions();
	
	for i = 1, #human_factions do
		model:disable_diplomacy("all", "faction:" .. human_factions[i], treaty_set_player_restrictions, "hidden");
		
		for j = 1, #human_factions do
			if i ~= j then
				model:disable_diplomacy("faction:" .. human_factions[i], "faction:" .. human_factions[j], treaty_set_player_restrictions, "hidden");
				model:enable_diplomacy("faction:" .. human_factions[i], "faction:" .. human_factions[j], treaty_set_player_availability, "hidden");
				model:disable_diplomacy("faction:" .. human_factions[j], "faction:" .. human_factions[i], treaty_set_player_restrictions, "hidden");
				model:enable_diplomacy("faction:" .. human_factions[j], "faction:" .. human_factions[i], treaty_set_player_availability, "hidden");
			end;
		end;
	end;
end;

function stop_faction_to_building_diplomatic_restriction_monitor(faction_key)
	core:remove_listener("faction_to_building_has_building_restriction_" .. faction_key);
end;


-- Script that enables the diplomatic options against the Jin when the faction hits the required progression level. Re-purposed from the similar YTR script in 3k main
function start_ep_faction_progression_listeners()

	out("* Starting Eight Princes faction progression listeners");

	-- define a list of participating factions (just playable factions for the moment)
	local eligible_faction_list = {
		"ep_faction_prince_of_runan",
		"ep_faction_prince_of_chu",
		"ep_faction_prince_of_donghai",
		"ep_faction_prince_of_changsha",
		"ep_faction_prince_of_chengdu",
		"ep_faction_prince_of_hejian",
		"ep_faction_prince_of_zhao",
		"ep_faction_prince_of_qi"
	}
	
	local progression_level_to_action_mapping = {
		{
			progression_level = 2,
			action = function(faction_key)
        cm:modify_model():enable_diplomacy("faction:"..faction_key,"faction:ep_faction_empire_of_jin","treaty_components_vassalise_recipient", "is_jin_empire_vassalise")

			end
		},
		{
			progression_level = 3,
			action = function(faction_key)
				cm:modify_model():enable_diplomacy("faction:"..faction_key, "faction:ep_faction_empire_of_jin", "treaty_components_annex_vassal,treaty_components_confederate_recipient", "is_jin_empire_annex")
				cm:modify_model():enable_diplomacy("faction:ep_faction_empire_of_jin", "faction:"..faction_key,"treaty_components_annex_vassal,treaty_components_confederate_recipient", "is_jin_empire_annex")
			end
		},
	};
	
	-- get the progression level from the last element in the mapping list (this should be the highest progression level we are listening for!)
	local max_progression_level = progression_level_to_action_mapping[#progression_level_to_action_mapping].progression_level;
	
	-- loop through the faction list and attempt to set up a listener for each
	for i = 1, #eligible_faction_list do
		local current_faction_key = eligible_faction_list[i];
		local current_faction_progression_level_key = current_faction_key .. "_ep_progression_applied";
		
		-- set a default value for the applied progression level for this faction
		if not cm:get_saved_value(current_faction_progression_level_key) then
			cm:set_saved_value(current_faction_progression_level_key, 0);
		end;
				
		-- if the applied progression level for this faction is less than the maximum progression level at which actions exist, then establish a listener
		if cm:get_saved_value(current_faction_progression_level_key) < max_progression_level then
			out("\tfaction " .. current_faction_key .. " has had progression level " .. cm:get_saved_value(current_faction_progression_level_key) .. " applied, starting listener");
			
			core:add_listener(
				current_faction_key .. "_ep_progression",		-- name for listener, we can just use the flag name
				"FactionFameLevelUp",							-- event to listen for
				function(context)								-- condition, returns true if the faction starting the turn is the current faction
					return context:faction():name() == current_faction_key and context:faction():progression_level() > cm:get_saved_value(current_faction_progression_level_key);
				end,   
				function(context)								-- trigger callback
					-- the faction we are interested in has levelled up in progression, so we need to apply one or more progression level actions
					
					-- work out the new progression level of the faction
					local new_progression_level_of_faction = context:faction():progression_level();
					
					-- for each progression level-to-action mapping, apply it if it hasn't already been applied and if the progression level from it 
					-- is less than or equal to the new progression level of the faction
					for j = 1, #progression_level_to_action_mapping do
						local current_mapping = progression_level_to_action_mapping[j];
						if current_mapping.progression_level > cm:get_saved_value(current_faction_progression_level_key) and current_mapping.progression_level <= new_progression_level_of_faction then
							-- apply this progression level action - call the action, passing in the faction name, and update the savegame value for this faction's progression level
							out("* faction " .. current_faction_key .. " has reached progression level " .. new_progression_level_of_faction .. ", applying action for progression level " .. current_mapping.progression_level);
							current_mapping.action(current_faction_key);
							cm:set_saved_value(current_faction_progression_level_key, current_mapping.progression_level);
							
							-- if the progression level action we've just applied is the last in the list, then shut down the progression level listener (for this faction)
							if j == #progression_level_to_action_mapping then
								out("\tno more progression levels to apply for this faction - shutting down listener");
								core:remove_listener(current_faction_key .. "_ep_progression");
							end;
							
							break;
						end;
					end;
				end,
				true											-- continue listening after being triggered
			)
		else
			out("\tfaction " .. current_faction_key .. " has had progression level " .. cm:get_saved_value(current_faction_progression_level_key) .. " applied, not starting listener");
		end;
	end;
end;

--[[ Monitors to see if zhang_yan can engage diplomatic negations with the yellow turban factions 
function start_faction_to_building_diplomatic_restriction_monitors()
	output("start_faction_to_building_diplomatic_restriction_monitors() begin");
	start_faction_to_building_diplomatic_restriction_monitor(
		"3k_main_faction_zhang_yan",
		{
			-- "3k_district_government_administration_black_mountain_1",		-- for test purposes
			"3k_district_government_administration_black_mountain_refuge_3",
			"3k_district_government_administration_black_mountain_refuge_4",
			"3k_district_government_administration_black_mountain_refuge_5"
		},
		function()
			-- no building callback
			output("start_faction_to_building_diplomatic_restriction_monitors() disabling diplomacy between 3k_main_faction_zhang_yan and 3k_main_subculture_yellow_turban");
			local model = cm:modify_model();
			model:disable_diplomacy("subculture:3k_main_subculture_yellow_turban", "faction:3k_main_faction_zhang_yan", "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war", "recipient_black_mountain_refuge_not")
			model:disable_diplomacy("faction:3k_main_faction_zhang_yan", "subculture:3k_main_subculture_yellow_turban", "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war", "proposer_black_mountain_refuge_not")			
		end,
		function()
			-- has building callback
			output("start_faction_to_building_diplomatic_restriction_monitors() enabling diplomacy between 3k_main_faction_zhang_yan and 3k_main_subculture_yellow_turban");
			local model = cm:modify_model();
			model:enable_diplomacy("subculture:3k_main_subculture_yellow_turban", "faction:3k_main_faction_zhang_yan", "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war", "recipient_black_mountain_refuge_not")
			model:enable_diplomacy("faction:3k_main_faction_zhang_yan", "subculture:3k_main_subculture_yellow_turban", "treaty_components_alliance_democratic,treaty_components_alliance_to_alliance_war,treaty_components_alliance_to_faction_war,treaty_components_ancillary_demand,treaty_components_ancillary_offer,treaty_components_annex_vassal,treaty_components_break_deal_proposer_to_recipient_unilateral,treaty_components_confederate_proposer,treaty_components_confederate_recipient,treaty_components_create_alliance,treaty_components_declare_independence,treaty_components_draw_vassal_into_war,treaty_components_faction_to_alliance_war,treaty_components_food_supply_demand,treaty_components_food_supply_offer,treaty_components_alliance_to_alliance_group_peace,treaty_components_alliance_to_faction_group_peace,treaty_components_faction_to_alliance_group_peace,treaty_components_group_war,treaty_components_guarentee_autonomy,treaty_components_join_alliance_proposers,treaty_components_join_alliance_recipients,treaty_components_join_coalition_proposer,treaty_components_join_coalition_recipient,treaty_components_kick_alliance_member,treaty_components_kick_coalition_member,treaty_components_liberate_proposer,treaty_components_liberate_recipient,treaty_components_military_access,treaty_components_non_aggression,treaty_components_payment_demand,treaty_components_payment_offer,treaty_components_payment_regular_demand,treaty_components_payment_regular_offer,treaty_components_peace,treaty_components_proposer_declares_war_against_target,treaty_components_recipient_declares_war_against_target,treaty_components_quit_alliance,treaty_components_quit_coalition,treaty_components_region_demand,treaty_components_region_offer,treaty_components_threaten,treaty_components_trade,treaty_components_vassalise_proposer,treaty_components_vassalise_recipient,treaty_components_call_vassals_to_arms,treaty_components_create_coalition,treaty_components_offer_autonomy,treaty_components_demand_autonomy,treaty_components_vassal_requests_war,treaty_components_vassal_joins_war", "proposer_black_mountain_refuge_not")
		end
	);
	output("start_faction_to_building_diplomatic_restriction_monitors() end");
end;]]

--[[ Starts the monitor to see if zhang_yan can engage diplomatic negations with the yellow turban factions 
function start_faction_to_building_diplomatic_restriction_monitor(faction_key, building_list, no_building_callback, has_building_callback)

	-- check inputs
	if not is_string(faction_key) then
		script_error("ERROR: start_faction_to_building_diplomatic_restriction_monitor() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;
	
	if not is_table(building_list) then
		script_error("ERROR: start_faction_to_building_diplomatic_restriction_monitor() called but supplied building list [" .. tostring(building_list) .. "] is not a table");
		return false;
	end;
	
	if #building_list == 0 then
		script_error("ERROR: start_faction_to_building_diplomatic_restriction_monitor() called but supplied building list [" .. tostring(building_list) .. "] is empty");
		return false;
	end;
	
	for i = 1, #building_list do
		if not is_string(building_list[i]) then
			script_error("ERROR: start_faction_to_building_diplomatic_restriction_monitor() called but element " .. i .. " in supplied building list is not a string, its value is [" .. tostring(building_list[i]) .. "]");
			return false;
		end;
	end;
	
	if not is_function(no_building_callback) then
		script_error("ERROR: start_faction_to_building_diplomatic_restriction_monitor() called but supplied no-building callback [" .. tostring(no_building_callback) .. "] is not a function");
		return false;
	end;
	
	if not is_function(has_building_callback) then
		script_error("ERROR: start_faction_to_building_diplomatic_restriction_monitor() called but supplied has-building callback [" .. tostring(has_building_callback) .. "] is not a function");
		return false;
	end;
	
	local faction_has_building_saved_value_key = "faction_to_building_has_building_restriction_" .. faction_key;
	local listener_name = faction_has_building_saved_value_key;
	
	-- construct a check function which returns true if the supplied faction contains any of the supplied buildings
	local function faction_contains_building_check()
		local faction = cm:query_faction(faction_key);
		for i = 1, #building_list do
			output("start_faction_to_building_diplomatic_restriction_monitors() element " .. i .. " in supplied building list of [" .. tostring(faction_key) .. "] is [" .. tostring(building_list[i]) .. "]");
			if faction_contains_building(faction, building_list[i]) then
				output("start_faction_to_building_diplomatic_restriction_monitors() element [" .. tostring(building_list[i]) .. "] exists");
				return true;
			end;
		end;
		output("start_faction_to_building_diplomatic_restriction_monitors() none of the elements in the supplied building list exists in the faction of [" .. tostring(faction_key) .. "]");
		return false;
	end;
	
	-- Construct a function which applies or un-applies the diplomatic restriction based on the result of faction_contains_building_check() and the current restriction state.
	-- This is what should be called when the restriction state needs to be re-assessed.
	local function update_restriction_check()
		if cm:get_saved_value(faction_has_building_saved_value_key) then
			if not faction_contains_building_check() then
				-- has_building restriction is applied but the faction contains none of the supplied buildings, so lift that restriction
				out("* start_faction_to_building_diplomatic_restriction_monitor() is calling supplied no_building_callback as faction " .. tostring(faction_key) .. " contains none of the supplied buildings [" .. table.concat(building_list, ", ") .. "]");
				cm:set_saved_value(faction_has_building_saved_value_key, false);
				no_building_callback();
			end;
		else
			if faction_contains_building_check() then
				-- has_building restriction is not applied and the faction contains one or more of the supplied buildings, so apply the restriction
				out("* start_faction_to_building_diplomatic_restriction_monitor() is calling supplied has_building_callback as faction " .. tostring(faction_key) .. " contains one of the supplied buildings [" .. table.concat(building_list, ", ") .. "]");
				cm:set_saved_value(faction_has_building_saved_value_key, true);
				has_building_callback();
			end;
		end;
	end;
	
	-- run the check function immediately if this is a new game
	if cm:is_new_game() then
		update_restriction_check();
	end;
	
	-- run the check function when the subject faction starts its turn
	core:add_listener(
		listener_name,
		"FactionTurnStart",
		function(context) return context:faction():name() == faction_key end,
		function(context)
			update_restriction_check();
		end,
		true
	);
	
	-- run the check function when the subject faction completes a building
	core:add_listener(
		listener_name,
		"BuildingCompleted",
		function(context) return context:garrison_residence():faction():name() == faction_key end,
		function(context)
			update_restriction_check();
		end,
		true
	);
	
	-- run the check function when a battle is completed on the players turn
	core:add_listener(
		listener_name,
		"GarrisonOccupiedEvent",
		function(context) return context:query_model():world():whose_turn_is_it():name() == faction_key end,
		function(context)
			update_restriction_check();
		end,
		true	
	);
end;]]
