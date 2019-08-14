---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Campaign Experience
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to trigger experience changes for characters based on campaign events.
-----				Also adds CEOs when XP is gained by characters.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

out.experience("3k_campaign_experience.lua: Loading");

campaign_experience = {};


--[[
*****************
EXP VALUES
*****************
]]--

-- Character Battle XP.
campaign_experience.xp_battle_kills_to_xp = 1.5; -- How much XP each kill gives (was 2)
campaign_experience.xp_battle_retinue_kills_ratio = 0.75; -- Pct of a retinue_kill towards the character XP (was 1)
campaign_experience.xp_battle_won_mult = 2; -- Multipler for being winner (was 2)
campaign_experience.xp_battle_lost_mult = 1; -- Multipler for being loser (was 1.25)
campaign_experience.xp_battle_min_xp = 250; -- (was 50)
campaign_experience.xp_battle_max_xp = 10000; -- (was 2500)


-- Duels
campaign_experience.xp_battle_duel_proposer_winner_xp = 2500;
campaign_experience.xp_battle_duel_proposer_loser_xp = 100;
campaign_experience.xp_battle_duel_target_winner_xp = 100;
campaign_experience.xp_battle_duel_target_loser_xp = 100;
campaign_experience.xp_battle_duel_not_won_xp = 10;
campaign_experience.xp_battle_duel_outcome_mult = 
{
	["complete"] = 1,
	["interrupted"] = 0.5,
	["refuse"] = 0,
	["runaway"] = 1
}

-- Construction
campaign_experience.xp_building_constructed_governor_primary = 1000;
campaign_experience.xp_building_constructed_governor_secondary = 500;
campaign_experience.xp_building_constructed_governor = 500;

-- Diplomacy
campaign_experience.xp_diplomacy_trade_agreement_faction_leader = 250;
campaign_experience.xp_diplomacy_alliance_faction_leader = 750;
campaign_experience.xp_diplomacy_war_faction_leader = 250;
campaign_experience.xp_diplomacy_vassalise_faction_leader = 500;
campaign_experience.xp_diplomacy_confederate_faction_leader = 500;
campaign_experience.xp_diplomacy_deal_concluded_faction_leader = 250;
campaign_experience.xp_diplomacy_military_access_faction_leader = 250;
campaign_experience.xp_diplomacy_non_agression_faction_leader = 250;
campaign_experience.xp_diplomacy_peace_treaty_faction_leader = 500;

-- Passive Faction Leader XP.
campaign_experience.xp_spy_action_faction_leader = 150;
campaign_experience.xp_pct_passive_faction_leader = 0.05;

-- Ministerial Positions
campaign_experience.xp_minister = 250;
campaign_experience.xp_minister_falloff_pct = { -- When char reaches level X, multiply by pct Y. 
	{["level"] = 3, ["pct"]=0.8},
	{["level"] = 7, ["pct"]=0.4}
}

-- Assignments
campaign_experience.xp_assignment_court_noble = 500;
campaign_experience.xp_assignment_court_noble_falloff_pct = { -- When char reaches level X, multiply by pct Y. 
	{["level"] = 3, ["pct"]=0.8},	--was 0.6
	{["level"] = 5, ["pct"]=0.5},
	{["level"] = 7, ["pct"]=0.2}	--was 0.2
} --All falloffs should follow this schema for them to work with the falloff function- { ["level"]=X, ["pct"]=y }


--[[
*****************
LISTENERS
*****************
]]--

--[[ campaign_experience:setup_experience_triggers()
	Sets up all the XP Listeners.
]]--
function campaign_experience:setup_experience_triggers()


-- BATTLE COMPLETED

	core:add_listener(
		"campaign_experience_battle_logged",
		"CampaignBattleLoggedEvent",
		true,
		function(battle_logged_event)
			out.experience("Trigger Fired: CampaignBattleLoggedEvent");

			-- Battle Logged
			local log_entry = battle_logged_event:log_entry();

			if log_entry:is_null_interface() then
				script_error("campaign_experience:calculate_battle_log_experience(): Log Entry is null");
			end;
		
			local winning_chars = log_entry:winning_characters();
			local losing_chars = log_entry:losing_characters();
			local duels = log_entry:duels();
		
			-- local function since we use it twice!
			local get_character_battle_xp = 
				function(log_character, result_mult, message)
					if not log_character:is_null_interface() then
						local query_character = log_character:character();
						local modify_character = cm:modify_character(query_character);
			
						local personal_kills_base = log_character:personal_kills();
						local retinue_kills_base = log_character:retinue_kills();

						local unit_scale_multiplier = cm:query_model():unit_scale_multiplier();

						local personal_kills = (personal_kills_base / unit_scale_multiplier);
						local retinue_kills = (retinue_kills_base / unit_scale_multiplier);
						
						local combined_kills = personal_kills + (retinue_kills * self.xp_battle_retinue_kills_ratio);
						local xp_gained = (combined_kills * self.xp_battle_kills_to_xp) * result_mult;

						if not query_character:is_dead() then
							self:add_experience(
								modify_character, 
								math.clamp(xp_gained, self.xp_battle_min_xp, self.xp_battle_max_xp), 
								message .. "Personal/Retinue Kills: " .. tostring(personal_kills_base) .. "/" .. tostring(retinue_kills_base) .. ". Unit scale multiplier: " .. tostring(unit_scale_multiplier) .. ". Scaled Personal/Retinue Kills: " .. tostring(personal_kills) .. "/" .. tostring(retinue_kills) .. ". Gained " .. xp_gained .. " raw XP.",
								true
							);
						end;
					end;
				end;

			-- Go through winning characters.
			for i=0, winning_chars:num_items() - 1 do
				out.experience("Battle Char: " .. winning_chars:item_at(i):character():generation_template_key());
				get_character_battle_xp(winning_chars:item_at(i), self.xp_battle_won_mult, "Battle Victory");
			end;
		
			-- Go through losing characters.
			for i=0, losing_chars:num_items() - 1 do
				out.experience("Battle Char: " .. losing_chars:item_at(i):character():generation_template_key());
				get_character_battle_xp(losing_chars:item_at(i), self.xp_battle_lost_mult, "Battle Defeat");
			end;
		
			-- Go through duels.
			for i=0, duels:num_items() - 1 do
				if not duels:item_at(i):is_null_interface() then
		
					local duel_log = duels:item_at(i);
		
					local proposer = duel_log:proposer();
					local target = duel_log:target();
					local winner = duel_log:winner();
					local loser = duel_log:loser();
					local has_winner = duel_log:has_winner();
					local outcome = duel_log:outcome();
					local outcome_mult = self.xp_battle_duel_outcome_mult[outcome] or 1;
					local proposer_won = false;

					if has_winner and not proposer:is_null_interface() and not winner:is_null_interface() then
						proposer_won = proposer:cqi() == winner:cqi();
					end			
		
					-- proposer
					if not proposer:is_null_interface() and not proposer:is_dead() then
						local modify_character = cm:modify_character(proposer);
						if not has_winner then -- Draw
							self:add_experience(modify_character, self.xp_battle_duel_not_won_xp * outcome_mult, "Draw/Inconclusive", false);
						elseif proposer_won then -- Proposer Won
							self:add_experience(modify_character, self.xp_battle_duel_proposer_winner_xp * outcome_mult, "Proposer Won Duel", false);
						else -- Proposer Lost
							self:add_experience(modify_character, self.xp_battle_duel_proposer_loser_xp * outcome_mult, "Proposer Lost Duel", false);
						end;
					end;
		
					-- target
					if not target:is_null_interface() and not target:is_dead() then
						local modify_character = cm:modify_character(target);
						if not has_winner then -- Draw?
							self:add_experience(modify_character, self.xp_battle_duel_not_won_xp * outcome_mult, "Draw/Inconclusive", false);
						elseif not proposer_won then -- Target Won
							self:add_experience(modify_character, self.xp_battle_duel_target_winner_xp * outcome_mult, "Target Won Duel", false);
						else -- Target Lost
							self:add_experience(modify_character, self.xp_battle_duel_target_loser_xp * outcome_mult, "Target Lost Duel", false);
						end;
					end;
		
				end;
			end;

		end,
		true
	);


-- DIPLOMACY

	core:add_listener(
		"PositiveDiplomaticEvent_experience", -- UID
		"PositiveDiplomaticEvent", -- Event
		true, --Conditions for firing
		function(context)
			local proposer_faction_leader_query = context:proposer():faction_leader();
			local recipient_faction_leader_query = context:recipient():faction_leader();
			local proposer_faction_leader_modify = context:modify_model():get_modify_character(proposer_faction_leader_query);
			local recipient_faction_leader_modify = context:modify_model():get_modify_character(recipient_faction_leader_query);

			local xp_to_give = 0;
			local xp_message = ""; 

			if context:is_alliance() then
				xp_to_give = self.xp_diplomacy_alliance_faction_leader;
				xp_message = xp_message .. "Alliance"
			end;

			if context:is_peace_treaty() then
				xp_to_give = self.xp_diplomacy_peace_treaty_faction_leader;
				xp_message = xp_message .. "Peace Treaty";
			end;

			if context:is_military_access() then
				xp_to_give = self.xp_diplomacy_military_access_faction_leader;
				xp_message = xp_message .. "Military Access";
			end;
			
			if context:is_trade_agreement() then
				xp_to_give = self.xp_diplomacy_trade_agreement_faction_leader;
				xp_message = xp_message .. "Trade Argeement";
			end;

			if context:is_non_aggression_pact() then
				xp_to_give = self.xp_diplomacy_non_agression_faction_leader;
				xp_message = xp_message .. "Non-agression Pact";
			end;

			--Add both faction names.
			xp_message = xp_message .. "-" .. proposer_faction_leader_query:faction():name() .. " <-> " .. recipient_faction_leader_query:faction():name();

			--DON'T Give to reciever, seems to fire for both sides! 
			if not context:modify_character():is_null_interface() then
				self:add_experience(context:modify_character(), xp_to_give, xp_message, false);
			end;

		end, -- Function to fire.
		true -- Is Persistent?
	);

	core:add_listener(
		"FactionLeaderDeclaresWar_experience", -- UID
		"FactionLeaderDeclaresWar", -- Event
		true, --Conditions for firing
		function(context)
			local modify_char = context:modify_character()
			
			if not modify_char:is_null_interface() then
				self:add_experience(modify_char, self.xp_diplomacy_war_faction_leader, "Declared War", false);
			end;
		end, -- Function to fire.
		true -- Is Persistent?
	);

	core:add_listener(
		"FactionJoinsConfederation_experience", -- UID
		"FactionJoinsConfederation", -- Event
		true, --Conditions for firing
		function(context)
			local proposer_faction_leader_query = context:faction():faction_leader();
			local recipient_faction_leader_query = context:confederation():faction_leader();
			
			if not proposer_faction_leader_query:is_null_interface() then
				local proposer_faction_leader_modify = context:modify_model():get_modify_character(proposer_faction_leader_query);
				self:add_experience(proposer_faction_leader_modify, self.xp_diplomacy_confederate_faction_leader, "Confederated", false);
			end;

			if not recipient_faction_leader_query:is_null_interface() then
				local recipient_faction_leader_modify = context:modify_model():get_modify_character(recipient_faction_leader_query);
				self:add_experience(recipient_faction_leader_modify, self.xp_diplomacy_confederate_faction_leader, "Confederated", false);
			end;
		end, -- Function to fire.
		true -- Is Persistent?
	);

	core:add_listener(
		"ClanBecomesVassal_experience", -- UID
		"ClanBecomesVassal", -- Event
		true, --Conditions for firing
		function(context)
			local master_faction_leader_query = context:faction():faction_leader();

			if not master_faction_leader_query:is_null_interface() then
				local master_faction_leader_modify = context:modify_model():get_modify_character(master_faction_leader_query);
				self:add_experience(master_faction_leader_modify, self.xp_diplomacy_vassalise_faction_leader, "Created Vassal", false);
			end;
		end, -- Function to fire.
		true -- Is Persistent?
	);
	

-- SPY ACTIONS

	core:add_listener(
		"SpyAction_experience",
		"UndercoverCharacterActionCompleteEvent",
		true,
		function(context)
			local source_query_faction_leader = context:source_faction():faction_leader();
			if not source_query_faction_leader:is_null_interface() then
				self:add_experience(context:modify_model():get_modify_character(source_query_faction_leader), self.xp_spy_action_faction_leader, "Spy Action Completed", false);
			end;
		end,
		true
	);


-- BUILDING CONSTRUCTED

	core:add_listener(
		"CharacterBuildingCompleted_experience", -- UID
		"CharacterBuildingCompleted", -- Event
		true, --Conditions for firing
		function(context)
			local query_char = context:character();
			local slot_type = context:building():slot():type();

			if not query_char:is_null_interface() then
				
				local modify_char = context:modify_model():get_modify_character(query_char);
				self:add_experience(modify_char, self.xp_building_constructed_governor, "Governor constructed building", true);

				--[[
				if slot_type == "primary" then
					local modify_char = context:modify_model():get_modify_character(query_char);
					self:add_experience(modify_char, self.xp_building_constructed_governor_primary, "Governor constructed building", true);

				elseif slot_type == "secondary" then
					local modify_char = context:modify_model():get_modify_character(query_char);
					self:add_experience(modify_char, self.xp_building_constructed_governor_secondary, "Governor constructed building", true);
				
				end;
				]]--

			end;
		end, -- Function to fire.
		true -- Is Persistent?
	);

-- CHARACTER MINISTER
-- Background XP gain for Ministers. Is a character in a ministerial position, including Governor, Faction Leader, Heir?

	core:add_listener(
		"CharacterMinister_experience",
		"CharacterTurnStart",
		function(context)
			if not context:query_character():is_null_interface() 
				and not context:query_character():character_post():is_null_interface() then
					
				return true;
			end;

			return false;
		end,
		function(context)
			-- Per turn when assigned a ministerial position
			local xp_to_give = self.xp_minister * self:calculate_assignment_xp_falloff_pct(context:query_character():rank(), self.xp_minister_falloff_pct);

			self:add_experience(context:modify_character(), xp_to_give, "Ministerial Position Per Turn", false);
		end,
		true
	);

-- CHARACTER ASSIGNMENTS

	core:add_listener(
		"CharacterAssignment_experience",
		"CharacterTurnStart",
		function(context)
			if not context:query_character():is_null_interface() 
				and not context:query_character():active_assignment():is_null_interface()
				and not context:query_character():active_assignment():is_idle_assignment() then
					
				return true;
			end;

			return false;
		end,
		function(context)
			-- Per turn when on assignment
			local xp_to_give = self.xp_assignment_court_noble * self:calculate_assignment_xp_falloff_pct(context:query_character():rank(), self.xp_assignment_court_noble_falloff_pct);

			self:add_experience(context:modify_character(), xp_to_give, "Court Noble Assignment Per Turn", false);
		end,
		true
	);

end;


--[[
*****************
CUSTOM FUNCTIONS
*****************
]]--

--[[ campaign_experience:add_experience(modify_character, exp_value, source_message, passive_leader_xp)
	Takes a character, the xp_to_give and an output_message. Calls the 'add_experience_internal' function and gives xp to the faction_leader if the 'passive_leader_xp' bool is true.
	Must pass in a modify_character interface to change.
]]--
function campaign_experience:add_experience(modify_character, exp_value, source_message, passive_leader_xp)
	self:add_experience_internal(modify_character, exp_value, source_message);

	if modify_character:is_null_interface() then -- Exit if null/nil
		return;
	end;

	-- Faction Leader Passive XP Gain
	-- Only trigger if this character is NOT the faction leader.
	if not modify_character:query_character():is_faction_leader() then

		if passive_leader_xp and self.xp_pct_passive_faction_leader > 0 then

			-- We don't want to give passive XP if the faction leader got the XP.
			if not modify_character:query_character():is_faction_leader() then
				local query_faction_leader = modify_character:query_character():faction():faction_leader();

				if not query_faction_leader:is_null_interface() then
					local faction_leader_interface = cm:modify_model():get_modify_character(query_faction_leader);
					local faction_leader_xp = exp_value * self.xp_pct_passive_faction_leader;

					self:add_experience_internal(faction_leader_interface, faction_leader_xp, "Faction Leader Symbiote XP");
				end;

			end;
		end;

		traits:add_protagonist_points(modify_character, exp_value); -- Ties into the traits system.
	end;
end;


--[[ campaign_experience:add_experience_internal(modify_character, exp_to_give, source_message)
	Takes a character, the xp_to_give and an output_message. Gives the xp to the character, and spits out the message.
	Must pass in a modify_character interface to change.
]]--
function campaign_experience:add_experience_internal(modify_character, exp_to_give, source_message)
	local exp_value = math.floor(exp_to_give);
	
	if modify_character:is_null_interface() then -- Exit if null/nil
		return;
	end;

	if exp_value < 0 then
		script_error("3k_campaign_experience.lua: Exp passed in is less than 0");
		exp_value = 0;
	end;
	
	modify_character:add_experience(exp_value, 0);

	local char_forename = effect.get_localised_string ( modify_character:query_character():get_forename () );
	local char_surname = effect.get_localised_string ( modify_character:query_character():get_surname () );
	out.experience("3k_campaign_experience.lua: Round:" .. cm:query_model():turn_number() .. ". XP Gained: " .. char_surname .." ".. char_forename .. ", " .. exp_value .. "xp, " ..  source_message);
end;


--[[ campaign_experience:calculate_assignment_xp_falloff_pct(char_lvl, falloff_data)
	Takes a character_level and a falloff_data array and returns the 'pct' from the highest 'level' which is below the passed in character_level
]]--
function campaign_experience:calculate_assignment_xp_falloff_pct(char_lvl, falloff_data)
	if #falloff_data < 1 then
		out.experience("3k_campaign_experience.lua: calculate_assignment_xp_falloff_pct(): Empty falloff data passed into function.");
		return 1;
	end;

	return_pct = 1;
	highest_min_level = -1;

	for i=1, #falloff_data do
		if falloff_data[i].level == nil then
			out.experience("3k_campaign_experience.lua: calculate_assignment_xp_falloff_pct(): Falloff data does not contain a 'level' exiting.");
			return 1;
		elseif falloff_data[i].pct == nil then
			out.experience("3k_campaign_experience.lua: calculate_assignment_xp_falloff_pct(): Falloff data does not contain a 'pct' exiting.");
			return 1;
		end;

		if char_lvl > falloff_data[i].level and falloff_data[i].level > highest_min_level then
			return_pct = falloff_data[i].pct;
			highest_min_level = falloff_data[i].level;
		end;

	end;

	return return_pct;
end;
