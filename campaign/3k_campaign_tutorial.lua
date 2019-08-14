---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			CDir Events Manager
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to trigger events for player factions, especially when they're out of turn.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

output("3k_campaign_tutorial.lua: Loaded");

require("lib_state_machine");

campaign_tutorial = {};


--[AUTO POPULATED VALUES]
campaign_tutorial.own_faction_key = "";
campaign_tutorial.main_force_cqi = 0;
campaign_tutorial.enemy_force_cqi = 0;
campaign_tutorial.target_settlement_key = nil;
campaign_tutorial.own_settlement_key = nil;
campaign_tutorial.own_settlement_building_cqi = nil;
campaign_tutorial.starting_force_position = nil;
campaign_tutorial.own_force_label_left = false;
campaign_tutorial.enemy_force_label_left = false;


--[VARIABLES]
campaign_tutorial.finished_tutorial_advice_key = "scripted_campaign_campaign_tutorial_completed"; -- We won't trigger advice if this has ever fired.
campaign_tutorial.started_tutorial_advice_key = "scripted_campaign_campaign_tutorial_started";
campaign_tutorial.should_fight_tutorial_battle = "scripted_campaign_campaign_tutorial_should_fight_tutorial";
campaign_tutorial.has_fought_tutorial_battle = "has_played_tutorial_battle";

--[STATES]
local states = {
	ENTRY_POINT = "ENTRY_POINT",
	CLOSE_WINDOWS = "CLOSE_WINDOWS",
	CLOSE_WINDOWS_WAIT_FOR_CLOSE = "CLOSE_WINDOWS_WAIT_FOR_CLOSE",
	ZOOM_TO_BUTTON = "ZOOM_TO_BUTTON",
	SELECT_OWN_FORCE = "SELECT_OWN_FORCE",
	ATTACK_ENEMY_FORCE = "ATTACK_ENEMY_FORCE",
	WAIT_FOR_BATTLE_COMPLETE = "WAIT_FOR_BATTLE_COMPLETE",
	SELECT_OWN_FORCE_2 = "SELECT_OWN_FORCE_2",
	ATTACK_ENEMY_TOWN = "ATTACK_ENEMY_TOWN",
	WAIT_FOR_BATTLE_COMPLETE_2 = "WAIT_FOR_BATTLE_COMPLETE_2",
	SELECT_OWN_TOWN = "SELECT_OWN_TOWN",
	HIGHLIGHT_BUILDING_SLOT = "HIGHLIGHT_BUILDING_SLOT",
	HIGHLIGHT_NOTIFICATIONS = "HIGHLIGHT_NOTIFICATIONS",
	WAIT_HIGHLIGHT_END_TURN = "WAIT_HIGHLIGHT_END_TURN",
	HIGHLIGHT_END_TURN = "HIGHLIGHT_END_TURN",
	END = "END"
};

-- Setup a new state machine for our tutorial.
local sm = state_machine:new( "campaign_tutorial_state_machine", states.ENTRY_POINT, false );


-- Campaign tutorial data for factions.
campaign_tutorial.faction_settings = {
	["3k_main_faction_cao_cao"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = "3k_main_chenjun_resource_1",
		own_settlement_key = "3k_main_chenjun_capital",
		own_settlement_building_index = 2,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_gongsun_zan"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = "3k_main_youzhou_resource_1",
		own_settlement_key = "3k_main_youbeiping_capital",
		own_settlement_building_index = 2,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_kong_rong"] = {
		enemy_faction_key = "3k_main_faction_yellow_turban_generic",
		target_settlement_key = "3k_main_beihai_resource_1",
		own_settlement_key = "3k_main_beihai_capital",
		own_settlement_building_index = 2,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_liu_bei"] = {
		enemy_faction_key = "3k_main_faction_yellow_turban_generic",
		target_settlement_key = "3k_main_dongjun_resource_1",
		own_settlement_key = "3k_main_dongjun_resource_1",
		own_settlement_building_index = 0,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_liu_biao"] = {
		enemy_faction_key = "3k_main_faction_yellow_turban_generic",
		target_settlement_key = "3k_main_xiangyang_resource_1",
		own_settlement_key = "3k_main_xiangyang_capital",
		own_settlement_building_index = 4,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_ma_teng"] = {
		enemy_faction_key = "3k_main_faction_yellow_turban_generic",
		target_settlement_key = "3k_main_wudu_capital",
		own_settlement_key = "3k_main_wudu_capital",
		own_settlement_building_index = 0,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_sun_jian"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = "3k_main_jingzhou_capital",
		own_settlement_key = "3k_main_changsha_capital",
		own_settlement_building_index = 2,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_yellow_turban_anding"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = nil,
		own_settlement_key = "3k_main_wudu_resource_2",
		own_settlement_building_index = 0,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_yellow_turban_rebels"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = nil,
		own_settlement_key = "3k_main_runan_capital",
		own_settlement_building_index = 0,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_yellow_turban_taishan"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = nil,
		own_settlement_key = "3k_main_dongjun_capital",
		own_settlement_building_index = 2,
		starting_force_position = {533, 529},
		own_force_label_left = false,
		enemy_force_label_left = true
	},
	["3k_main_faction_yuan_shao"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = "3k_main_weijun_resource_1",
		own_settlement_key = "3k_main_weijun_capital",
		own_settlement_building_index = 2,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_yuan_shu"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = "3k_main_nanyang_resource_1",
		own_settlement_key = "3k_main_nanyang_capital",
		own_settlement_building_index = 2,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_zhang_yan"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = "3k_main_yanmen_resource_1",
		own_settlement_key = "3k_main_yanmen_capital",
		own_settlement_building_index = 2,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	},
	["3k_main_faction_zheng_jiang"] = {
		enemy_faction_key = "3k_main_faction_han_empire",
		target_settlement_key = "3k_main_taiyuan_capital",
		own_settlement_key = "3k_main_taiyuan_capital",
		own_settlement_building_index = 2,
		starting_force_position = nil,
		own_force_label_left = false,
		enemy_force_label_left = false
	}
};



--[[
*******************************************************
*******************************************************
	ENTRY/EXIT
*******************************************************
*******************************************************
]]--



function campaign_tutorial:initialise()
	out.design("3k_campaign_tutorial: Initialise");

	-- Don't fire in multiplayer as there is no one local faction.
	if cm:is_multiplayer() then
		out.design("3k_campaign_tutorial: Tutorials disabled in MP Campaigns.");
		return false;
	end;


	-- GET THE TUTORIAL DATA
	self.own_faction_key = cm:get_local_faction();

	if not self.own_faction_key then
		out.design("3k_campaign_tutorial: No local faction.");
		return false;
	end;

	local faction_settings = self.faction_settings[self.own_faction_key];

	-- Check that our faction has a tutorial.
	if not faction_settings then
		out.design("3k_campaign_tutorial: No tutorial data found for the faction [" .. self.own_faction_key .. "]");
		return false;
	end;

	local local_faction = cm:query_local_faction(true);
	

	-- DECIDE IF WE EXIT, RESTART OR START NEW


	local is_reloading = false;

	if core:is_tweaker_set("enable_experimental_lua") then -- Internal testing.
		out.design("3k_campaign_tutorial: START: Debug force start.");
		is_reloading = false;

	else
		if self:has_finished() then -- Check if we've completed the tutorial this session. If we have exit.
			out.design("3k_campaign_tutorial: START: Seen in this playthrough, not starting.");
			return false;
		
		elseif self:has_started() then -- If the save says we started, but we've not finished, we're reloading. This stops certain things baked into the save from never getting cleared (i.e. diplomacy lock).
			out.design("3k_campaign_tutorial: START: loading from saved game, resuming tutorial.");
			is_reloading = true;

		elseif self:has_ever_played_tutorial() then -- Has the user completed the tutorial in another play through
			out.design("3k_campaign_tutorial: START: Seen in previous playthroughs, not starting.");
			return false;
			
		elseif effect.get_advice_level() < 2 then -- Are we playing on high advice?
			out.design("3k_campaign_tutorial: START: Advice level too low, and hasn't ever seen. Marking as seen, and skipping tutorial battle.");

			-- We mark these as seen, as we assume the user has the knowledge at this point.
			self:set_has_ever_played_tutorial();
			effect.set_advice_history_string_seen(self.has_fought_tutorial_battle);

			return false;

		elseif (not self:has_ever_played_tutorial() and effect.get_advice_level() == 2) or core:is_tweaker_set("enable_experimental_lua") then -- Finally, are we a new user?
			out.design("3k_campaign_tutorial: START: Never seen before, starting new.");
			is_reloading = false;
		
		else -- This *should* never fire, but let's catch it just in case for debugging.
			script_error("3k_campaign_tutorial.lua: Unexpected state reached when loading the tutorial! Exiting tutorial." );
			return false;

		end;
	end;

	out.design("3k_campaign_tutorial: Validation passed, loading data.");



	-- GET OWN COMMANDER



	-- Get our own force commander. If we specified a starting position use that.
	local main_force_commander = nil;
	if faction_settings.starting_force_position then
		local starting_force_general = cm:get_closest_general_to_position_from_faction(
			local_faction:name(), 
			faction_settings.starting_force_position[1],
			faction_settings.starting_force_position[2],
			false); 

		main_force_commander = starting_force_general;
	else
		if local_faction:character_list():num_items() > 0 then
			-- We'd prefer the faction leader if possible.
			local faction_leader = local_faction:faction_leader();
			if faction_leader and faction_leader:has_military_force() then
				main_force_commander = faction_leader;
			else
				for i=0, local_faction:military_force_list():num_items() -1 do
					local force = local_faction:military_force_list():item_at(i);

					-- Find the first force commander.
					if force and not force:is_null_interface() and force:has_general() then
						main_force_commander = force:general_character();
						break;
					end;
				end;
			end;
		end;
	end;



	--- VALIDATION



	if not main_force_commander or main_force_commander:is_null_interface() then
		script_error("3k_campaign_tutorial.lua: Invalid: main_force_commander. Must be character or nil." );
		return;
	end;

	if not main_force_commander:military_force() or main_force_commander:military_force():is_null_interface() then
		script_error("3k_campaign_tutorial.lua: Invalid: main_force_commander force. Must be character or nil. [" .. tostring(main_force_commander:generation_template_key()) .. "]" );
		return;
	end;
	
	self.main_force_cqi = main_force_commander:military_force():command_queue_index();

	-- Required
	if not self.main_force_cqi or self.main_force_cqi == 0 then
		script_error("3k_campaign_tutorial.lua: Unable to find a main force commander.");
		return;
	end;

	if not faction_settings.enemy_faction_key or not is_string(faction_settings.enemy_faction_key) then
		script_error("3k_campaign_tutorial.lua: Invalid: enemy_faction_key. Must be string or nil." );
		return;
	end;


	-- Optional
	if faction_settings.target_settlement_key and not is_string(faction_settings.target_settlement_key) then
		script_error("3k_campaign_tutorial.lua: Invalid: target_settlement_key. Must be string or nil." );
		return;
	end;

	if faction_settings.own_settlement_key and not is_string(faction_settings.own_settlement_key) then
		script_error("3k_campaign_tutorial.lua: Invalid: own_settlement_key. Must be string or nil." );
		return;
	end;

	if faction_settings.own_settlement_key and (not faction_settings.own_settlement_building_index or not is_number(faction_settings.own_settlement_building_index)) then
		script_error("3k_campaign_tutorial.lua: Invalid: own_settlement_building_index. Must be number or nil." );
		return;
	end;


	--- ASSIGN VALUES



	-- Get enemy army CQI.
	local enemy_character = cm:get_closest_general_to_position_from_faction(
		faction_settings.enemy_faction_key, 
		main_force_commander:logical_position_x(), 
		main_force_commander:logical_position_y(), 
		false); 

	if not enemy_character or enemy_character:is_null_interface() then
		script_error("3k_campaign_tutorial.lua: Unable to find an enemy general in faction " .. tostring(faction_settings.enemy_faction_key) .. ". This will break." );
		return;
	end;

	self.enemy_force_cqi = enemy_character:military_force():command_queue_index();

	-- Target settlement.
	if faction_settings.target_settlement_key then
		self.target_settlement_key = faction_settings.target_settlement_key;
	end;

	-- Own settlement.
	if faction_settings.own_settlement_key then
		self.own_settlement_key = faction_settings.own_settlement_key;
	
		-- Own settlement building index.
		if faction_settings.own_settlement_building_index then

			local query_region = cm:query_region(self.own_settlement_key);

			if not query_region or query_region:is_null_interface() then
				script_error("ERROR: 3k_campaign_tutorial.lua: Attempting to get settlement with key [" .. self.own_settlement_key .. "], but it doesn't exist.");
				return;
			end;

			local num_slots = query_region:slot_list():num_items();

			if num_slots < faction_settings.own_settlement_building_index then
				script_error("ERROR: 3k_campaign_tutorial.lua: Attempting to get a slot with id [" .. faction_settings.own_settlement_building_index .. "] but region only has [" .. num_slots .. "] slots.");
				return;
			end;

			self.own_settlement_building_cqi = query_region:slot_list():item_at( faction_settings.own_settlement_building_index ):command_queue_index();
		end;

	end;

	self.starting_force_position = faction_settings.starting_force_position;
	self.own_force_label_left = faction_settings.own_force_label_left;
	self.enemy_force_label_left = faction_settings.enemy_force_label_left;


	out.design("3k_campaign_tutorial: Data loaded. Loading state machine states.");


	-- ADD STATES
	self:add_states_turn_start();
	self:add_states_attack_force();
	self:add_states_attack_settlement();
	self:add_states_build_buildings();
	self:add_states_end_turn();
	self:global_listeners(); -- Global listeners which will override behaviours.


	-- SET OUR STARTING PROPERTIES.
	self:toggle_suppress_all_notifications( true );
			
	self:set_diplomacy_button_enabled(false);

	-- ACTUALLY LOAD/START OUR GAME
	if is_reloading then
		sm:restart();
	else
		self:set_has_started();
		sm:start();
	end;

	
end;


function campaign_tutorial:destroy()
	sm:destroy();
	sm = nil;

	self:set_has_ever_played_tutorial(); -- Persistent variable for new games.
	self:set_has_finished(); -- Mark the tutorial as completed in the save.

	self:set_diplomacy_button_enabled(true);

	self:toggle_suppress_all_notifications( false );

	start_global_interventions(); -- Re enable the advisor.
end;

-- Global skip_to functions. when somthing goes wrong this will override the script to a specific point.
function campaign_tutorial:global_listeners()

	-- If user ends turn at ANY point, end the tutorial.
	sm:global_state_change_listener(
		states.END, -- State to move to
		"FactionTurnEnd", -- Event key
		function(context) -- Criteria
			return true;
		end,
		false -- Is persistent.
	);

	-- If they lose the battle, we exit.
	sm:global_state_change_listener(
		states.END, -- State to move to
		"CampaignBattleLoggedEvent", -- Event key
		function(context) -- Criteria
			for i=0, context:log_entry():losing_factions():num_items() - 1 do
				local faction = context:log_entry():losing_factions():item_at(i);
				if faction:name() == self.own_faction_key then
					return true;
				end;
			end;

			return false;
		end,
		false -- Is persistent.
	);

	-- Example: trigger_cli_debug_event intro_tutorial.set_state(HIGHLIGHT_END_TURN)
	core:add_cli_listener("intro_tutorial.set_state", 
		function(key)
			sm:change_to(key);
		end
	);
end;



--[[
*******************************************************
*******************************************************
	STATES
*******************************************************
*******************************************************
]]--



function campaign_tutorial:add_states_turn_start()

	sm:add_state( states.ENTRY_POINT, -- name
		function()
			out.design("Entry point!");

			-- State Change
			sm:state_change_listener(
				states.CLOSE_WINDOWS, 
				"PanelOpenedCampaign", 
				function(context) 
					return context.string == "event_single";
				end 
			);

			sm:state_change_listener(
				states.ATTACK_ENEMY_FORCE, 
				"CharacterSelected", 
				function(context) 
					return context:character():military_force():command_queue_index() == self.main_force_cqi;
				end 
			);
		end, --on_enter_callback
		nil, --on_exit_callback 
		states.CLOSE_WINDOWS -- Resume state
	);

	sm:add_state( states.CLOSE_WINDOWS, -- name
		function(context)
			self:highlight_event_close_button();

			-- State Change
			sm:state_change_listener(
				states.CLOSE_WINDOWS_WAIT_FOR_CLOSE,
				"PanelClosedCampaign",
				function(context) 
					return context.string == "event_single";
				end
			);

			-- State Change
			sm:state_change_listener(
				states.ATTACK_ENEMY_FORCE, 
				"CharacterSelected", 
				function(context) 
					return context:character():military_force():command_queue_index() == self.main_force_cqi;
				end 
			);
		end, --on_enter_callback
		function(context)
			self:remove_event_close_highlight();
		end, --on_exit_callback
		states.CLOSE_WINDOWS -- Resume state
	);

	sm:add_state( states.CLOSE_WINDOWS_WAIT_FOR_CLOSE, -- name
		function(context)
			
			-- State Change
			sm:state_change_callback(states.ZOOM_TO_BUTTON, 0.25);
		end, --on_enter_callback
		nil --on_exit_callback
	);

	sm:add_state( states.ZOOM_TO_BUTTON, -- name
		function(context)
			self:highlight_event_zoom_button();

			-- State Change
			sm:state_change_listener(
				states.SELECT_OWN_FORCE,
				"ComponentLClickUp",
				function(context) 
					return context:component_id() == "button_zoom";
				end
			);

			sm:state_change_listener(
				states.SELECT_OWN_FORCE,
				"PanelClosedCampaign",
				function(context) 
					return true;
				end
			);

			sm:state_change_listener(
				states.ATTACK_ENEMY_FORCE, 
				"CharacterSelected", 
				function(context) 
					return context:character():military_force():command_queue_index() == self.main_force_cqi;
				end 
			);
		end, --on_enter_callback
		function(context)
			self:remove_event_zoom_highlight();
		end, --on_exit_callback
		states.SELECT_OWN_FORCE -- Resume state
	);
end;

function campaign_tutorial:add_states_attack_force()
	
	sm:add_state( states.SELECT_OWN_FORCE, -- name
		function(context)
			if self.own_force_label_left then
				self:highlight_army_id(self.main_force_cqi, "select_left");
			else
				self:highlight_army_id(self.main_force_cqi, "select_right");
			end;

			-- State Change
			sm:state_change_listener(
				states.WAIT_FOR_BATTLE_COMPLETE,
				"PendingBattle",
				function() return true end
			);

			sm:state_change_listener(
				states.ATTACK_ENEMY_FORCE, 
				"CharacterSelected", 
				function(context) 
					return context:character():military_force():command_queue_index() == self.main_force_cqi;
				end 
			);
			
		end, --on_enter_callback
		function() 
			self:remove_army_highlight();
		end--on_exit_callback 
	);

	sm:add_state( states.ATTACK_ENEMY_FORCE, -- name
		function(context)

			-- Highlight enemy force.
			if self.enemy_force_label_left then
				self:highlight_army_id(self.enemy_force_cqi, "attack_left");
			else
				self:highlight_army_id(self.enemy_force_cqi, "attack_right");
			end;

			-- Trigger an advice we can use to check iof the tutorial battle should happen.
			self:set_should_fight_tutorial_battle();

			-- State Change
			sm:state_change_listener(
				states.WAIT_FOR_BATTLE_COMPLETE,
				"PendingBattle",
				function() return true end
			);

			sm:state_change_listener(
				states.SELECT_OWN_FORCE,
				"CharacterDeselected",
				function() return true end
			);
		end, --on_enter_callback
		function(context)
			self:remove_army_highlight();
		end, --on_exit_callback
		states.SELECT_OWN_FORCE -- load state
	);
end;

function campaign_tutorial:add_states_attack_settlement()
	
	sm:add_state( states.WAIT_FOR_BATTLE_COMPLETE, -- name
		function(context)

			-- Check if the Tutorial battle will fire and highlight if so. mirrors the campaign/battle_start.lua
			if (effect.get_advice_history_string_seen(self.should_fight_tutorial_battle) -- Enabled if the campaign tutorial has allowed the battle
				and not effect.get_advice_history_string_seen(self.finished_tutorial_advice_key) -- If we've completed, then don't fire
				and not effect.get_advice_history_string_seen(self.has_fought_tutorial_battle) -- If we've played the tutorial battle ever, then don't fire
			)
			or core:is_tweaker_set("enable_experimental_lua") then

				self:toggle_highlight_start_battle_button(true);
			end;

			-- State Change
			sm:state_change_listener(
				states.SELECT_OWN_FORCE_2,
				"BattleCompleted",
				function() return true end
			);

			-- There's a delay between the states, so to fix this I also check here. Bug - 40285 
			sm:state_change_listener(
				states.ATTACK_ENEMY_TOWN, 
				"CharacterSelected", 
				function(context) 
					return context:character():military_force():command_queue_index() == self.main_force_cqi;
				end 
			);
		end, --on_enter_callback
		function(context)
			self:toggle_highlight_start_battle_button(false);
		end--on_exit_callback
	);

	sm:add_state( states.SELECT_OWN_FORCE_2, -- name
		function(context)
			-- If we don't have a settlement to 'conquer' then skip this state.
			if not self.target_settlement_key then
				out.design("Skipping attack settlement stage.");
				sm:change_to(states.SELECT_OWN_TOWN);
				return;
			end;

			if self.own_force_label_left then
				self:highlight_army_id(self.main_force_cqi, "select_left");
			else
				self:highlight_army_id(self.main_force_cqi, "select_right");
			end;

			-- State Change
			sm:state_change_listener(
				states.ATTACK_ENEMY_TOWN, 
				"CharacterSelected", 
				function(context) 
					return context:character():military_force():command_queue_index() == self.main_force_cqi;
				end 
			);
			
		end, --on_enter_callback
		function(context)
			self:remove_army_highlight();
		end --on_exit_callback
	);

	sm:add_state( states.ATTACK_ENEMY_TOWN, -- name
		function(context)
			-- If we don't have a settlement to 'conquer' then skip this state.
			if not self.target_settlement_key then
				out.design("Skipping attack settlement stage.");
				sm:change_to(states.SELECT_OWN_TOWN);
				return;
			end;

			self:highlight_settlement_id(self.target_settlement_key, "attack");

			cm:wait_for_model_sp(function() 
				local region = cm:query_region(self.target_settlement_key);
	
				if not region then
					script_error("ERROR: scroll_camera_with_cutscene_to_settlement() called but region with supplied key [" .. tostring(region_key) .. "] could not be found");
					return false;
				end;
				
				local settlement = region:settlement();

				local x, y, d, b, h = cm:get_camera_position();
				local targ_x = settlement:display_position_x();
				local targ_y = settlement:display_position_y();

				local duration = 0.025 * distance_squared(x, y, targ_x, targ_y);

				duration = math.min(duration, 6);

				if duration > 0 then
					cm:scroll_camera_from_current(duration, true, {targ_x, targ_y, 8, b, 10});
				end;
			end);

			-- State Change
			sm:state_change_listener(
				states.SELECT_OWN_FORCE_2,
				"CharacterDeselected",
				function() return true end
			);

			sm:state_change_listener(
				states.SELECT_OWN_FORCE_2,
				"SettlementSelected",
				function() return true end
			);

			sm:state_change_listener(
				states.WAIT_FOR_BATTLE_COMPLETE_2,
				"CharacterBesiegesSettlement",
				function() return true end
			);

			sm:state_change_listener(
				states.SELECT_OWN_TOWN,
				"GarrisonOccupiedEvent",
				function() return true end
			);

			sm:state_change_listener( -- Handling of Annex Action
				states.SELECT_OWN_TOWN,
				"CharacterPerformsSettlementSiegeAction",
				function() return true end
			);
		end, --on_enter_callback
		function(context)
			self:remove_settlement_highlight();
		end, --on_exit_callback
		states.SELECT_OWN_FORCE_2 -- load state
	);
end;

function campaign_tutorial:add_states_build_buildings()

	sm:add_state( states.WAIT_FOR_BATTLE_COMPLETE_2, -- name
		function(context)
			
			-- State Change
			sm:state_change_listener(
				states.SELECT_OWN_TOWN,
				"BattleCompleted",
				function() return true end
			);
			
			sm:state_change_listener(
				states.SELECT_OWN_TOWN,
				"GarrisonOccupiedEvent",
				function() return true end
			);

			sm:state_change_listener( -- Handling of Annex Action
				states.SELECT_OWN_TOWN,
				"CharacterPerformsSettlementSiegeAction",
				function() return true end
			);
		end, --on_enter_callback
		nil --on_exit_callback
	);

	sm:add_state( states.SELECT_OWN_TOWN, -- name
		function(context)
			if not self.own_settlement_key then
				out.design("Skipping select own town stage.");
				sm:change_to(states.HIGHLIGHT_NOTIFICATIONS);
				return;
			end;

			-- After X seconds highlight settlement. - Allows us to get out of battle before.
			cm:wait_for_model_sp(function() 		
				cm:callback(
					function()				
						self:highlight_settlement_id(self.own_settlement_key, "select");
						
						local region = cm:query_region(self.own_settlement_key);
	
						if not region then
							script_error("ERROR: scroll_camera_with_cutscene_to_settlement() called but region with supplied key [" .. tostring(region_key) .. "] could not be found");
							return false;
						end;
						
						local settlement = region:settlement();

						local x, y, d, b, h = cm:get_camera_position();
						local targ_x = settlement:display_position_x();
						local targ_y = settlement:display_position_y();

						local duration = 0.2 * distance_squared(x, y, targ_x, targ_y);

						duration = math.min(duration, 5);

						if duration > 0 then
							cm:scroll_camera_from_current(duration, true, {targ_x, targ_y, 8, b, 10});
						end;
					end,
					1,
					sm:get_listener_name()
				);
			end);

			-- State Change
			sm:state_change_listener(
				states.HIGHLIGHT_BUILDING_SLOT,
				"SettlementSelected",
				function(context)
					return context:settlement():region():name() == self.own_settlement_key;
				end
			)
		end, --on_enter_callback
		function(context)
			self:remove_settlement_highlight();
		end --on_exit_callback
	);

	sm:add_state( states.HIGHLIGHT_BUILDING_SLOT, -- name
		function(context)
			self:highlight_building_slot_index( self.own_settlement_building_cqi );
			
			-- State Change
			sm:state_change_listener(
				states.SELECT_OWN_TOWN,
				"SettlementDeselected",
				function(context)
					return true;
				end
			);

			sm:state_change_listener(
				states.HIGHLIGHT_NOTIFICATIONS,
				"ComponentLClickUp",
				function(context) 
					return context:component_id() == "expand_overlay" or context:component_id() == "city_icon";
				end
			);

			sm:state_change_listener(
				states.HIGHLIGHT_NOTIFICATIONS,
				"BuildingConstructionIssuedByPlayer",
				function(context) 
					return true;
				end
			);
		end, --on_enter_callback
		function(context)
			self:remove_building_slot_highlight();
		end, --on_exit_callback
		states.SELECT_OWN_TOWN -- load state
	);

end;

function campaign_tutorial:add_states_end_turn()

	sm:add_state( states.HIGHLIGHT_NOTIFICATIONS, -- name
		function(context)
			cm:wait_for_model_sp(function() 
				self:toggle_suppress_all_notifications( false );
			end );

			if not cm:get_preference_bool("ui_notifications_toggled") then
				self:highlight_notifications();

				-- State Change
				sm:state_change_listener(
					states.WAIT_HIGHLIGHT_END_TURN,
					"ComponentLClickUp",
					function(context) 
						return context:component_id() == "button_end_notifications";
					end
				);
			else
				sm:state_change_callback( states.WAIT_HIGHLIGHT_END_TURN, 0 );
			end;

			
			
		end, --on_enter_callback
		function(context)
			self:remove_notifications_highlight();
		end --on_exit_callback
	);

	sm:add_state( states.WAIT_HIGHLIGHT_END_TURN, -- name
		function(context)
			-- Restore diplomacy here.
			self:set_diplomacy_button_enabled(true);

			-- State Change
			sm:state_change_callback( states.HIGHLIGHT_END_TURN, 45 );
		end, --on_enter_callback
		nil --on_exit_callback
	);

	sm:add_state( states.HIGHLIGHT_END_TURN, -- name
		function(context)
			self:highlight_end_turn();

			-- State Change
			sm:state_change_callback( states.END, 40 );
		end, --on_enter_callback
		function(context)
			self:remove_end_turn_highlight();		
		end --on_exit_callback
	);

	sm:add_state( states.END,
		function()
			self:destroy();
		end,
		nil
	);
end;



--[[
*******************************************************
*******************************************************
	HELPERS
*******************************************************
*******************************************************
]]--


function campaign_tutorial:has_ever_played_tutorial()
	return effect.get_advice_history_string_seen(self.finished_tutorial_advice_key);
end;

function campaign_tutorial:set_has_ever_played_tutorial()
	effect.set_advice_history_string_seen(self.finished_tutorial_advice_key);
end;

function campaign_tutorial:set_should_fight_tutorial_battle()
	effect.set_advice_history_string_seen(self.should_fight_tutorial_battle);
end;

function campaign_tutorial:has_started()
	return cm:get_saved_value("campaign_tutorial_has_started");
end;

function campaign_tutorial:has_finished()
	return cm:get_saved_value("campaign_tutorial_has_finished");
end;

function campaign_tutorial:set_has_started()
	cm:set_saved_value("campaign_tutorial_has_started", true);
end;

function campaign_tutorial:set_has_finished()
	cm:set_saved_value("campaign_tutorial_has_finished", true);
end;


function campaign_tutorial:toggle_script_disable_end_turn_highlight(is_disabled)
	if is_disabled then
		effect.set_context_value("suppress_end_turn_anim", 1);
	else
		effect.set_context_value("suppress_end_turn_anim", 0);
	end;
end;

function campaign_tutorial:highlight_event_close_button()
	effect.set_context_value("highlighted_event_close", 1);
end;

function campaign_tutorial:remove_event_close_highlight()
	effect.set_context_value("highlighted_event_close", 0);
end;

function campaign_tutorial:highlight_event_zoom_button()
	effect.set_context_value("highlighted_event_zoom", 1);
end;

function campaign_tutorial:remove_event_zoom_highlight()
	effect.set_context_value("highlighted_event_zoom", 0);
end;

-- Sets a highlight on the specified army CQI.
-- If do_highlight is true and one already exists, the previous one will be deleted.
function campaign_tutorial:highlight_army_id(cqi, state) 
    if not is_number(cqi) then
		out.design("[ERROR] Army id should be supplied as string.");
		return;
	end;
	
	if not is_string(state) then
		out.design("[ERROR] Army state should be supplied as string.");
		return;
    end;

	effect.set_context_value("highlighted_character_id", cqi);
	effect.set_context_value("highlighted_character_state", state);
end;

-- Removes the army highlight, if it exists.
function campaign_tutorial:remove_army_highlight()
	effect.set_context_value("highlighted_character_id", -1);
end;

-- Takes a settlement key and higlights that settlement in the UI.
-- Will always delete the previous one if it exists.
function campaign_tutorial:highlight_settlement_id(id, state) 
    if not is_string(id) then
		out.design("[ERROR] Settlement id should be supplied as string.");
		return;
	end;
	
	if not is_string(state) then
		out.design("[ERROR] Settlement state should be supplied as string.");
		return;
    end;

	effect.set_context_value("highlighted_settlement_id", id);
	effect.set_context_value("highlighted_settlement_state", state);
end;

-- Removes the settlement highlight, if it exists.
function campaign_tutorial:remove_settlement_highlight()
	effect.set_context_value("highlighted_settlement_id", "");
end;

function campaign_tutorial:highlight_building_slot_index(index)
	effect.set_context_value("highlighted_building_slot_id", index);
end;

function campaign_tutorial:remove_building_slot_highlight()
	effect.set_context_value("highlighted_building_slot_id", -1);
end;

function campaign_tutorial:highlight_notifications()
	effect.set_context_value("highlighted_notifications", 1);
end;

function campaign_tutorial:remove_notifications_highlight()
	effect.set_context_value("highlighted_notifications", 0);
end;

function campaign_tutorial:toggle_highlight_start_battle_button(enable)
	if enable then
		effect.set_context_value("highlighted_start_battle", 1);
	else
		effect.set_context_value("highlighted_start_battle", 0);
	end
end;



function campaign_tutorial:highlight_end_turn()
	effect.set_context_value("highlighted_end_turn", 1);
end;

function campaign_tutorial:remove_end_turn_highlight()
	effect.set_context_value("highlighted_end_turn", 0);
end;

function campaign_tutorial:toggle_suppress_all_notifications( suppressed )
	local mm = cm:modify_model();

	self:toggle_script_disable_end_turn_highlight( suppressed );

	mm:set_end_turn_notification_suppressed( "ARMY_AP_AVAILABLE", suppressed );
	mm:set_end_turn_notification_suppressed( "CHARACTER_DEFECTION_IMMINENT", suppressed );
	mm:set_end_turn_notification_suppressed( "CHARACTER_SATISFACTION_LOW", suppressed );
	mm:set_end_turn_notification_suppressed( "CHARACTER_UPGRADE_AVAILABLE", suppressed );
	mm:set_end_turn_notification_suppressed( "DAMAGED_BUILDING", suppressed );
	mm:set_end_turn_notification_suppressed( "ECONOMICS_PROJECTED_NEGATIVE", suppressed );
	mm:set_end_turn_notification_suppressed( "ECONOMICS_PROJECTED_NEGATIVE_WITH_DIPLOMATIC_EXPENDITURE", suppressed );
	mm:set_end_turn_notification_suppressed( "FACTION_COUNCIL_INVOCATION_NO_MISSIONS", suppressed );
	mm:set_end_turn_notification_suppressed( "FACTION_COUNCIL_INVOCATION_TIMEOUT", suppressed );
	mm:set_end_turn_notification_suppressed( "GARRISONED_ARMY_AP_AVAILABLE", suppressed );
	mm:set_end_turn_notification_suppressed( "HEIR_SLOT_AVAILABLE", suppressed );
	mm:set_end_turn_notification_suppressed( "IMMINENT_REBELLION", suppressed );
	mm:set_end_turn_notification_suppressed( "LOW_FUNDS", suppressed );
	mm:set_end_turn_notification_suppressed( "LOW_PROVINCIAL_SUPPLIES", suppressed );
	mm:set_end_turn_notification_suppressed( "MILITARY_FORCE_MORALE_LOW", suppressed );
	mm:set_end_turn_notification_suppressed( "NEGATIVE_FOOD_BALANCE", suppressed );
	--mm:set_end_turn_notification_suppressed( "NOT_RESEARCHING_TECH", suppressed ); -- SM: YT get this turn one, so removing
	mm:set_end_turn_notification_suppressed( "PROVINCES_NO_CONSTRUCTION_PROJECT", suppressed );
	mm:set_end_turn_notification_suppressed( "PROVINCES_REBELLION_MUSTERING", suppressed );
	mm:set_end_turn_notification_suppressed( "PROVINCES_RESOURCE_MISSING", suppressed );
	mm:set_end_turn_notification_suppressed( "PUBLIC_ORDER_LOW", suppressed );
	mm:set_end_turn_notification_suppressed( "SETTLEMENT_UNDER_SIEGE", suppressed );
	mm:set_end_turn_notification_suppressed( "SIEGE_CONSTRUCTION_AVAILABLE", suppressed );
	mm:set_end_turn_notification_suppressed( "SIEGE_NO_EQUIPMENT", suppressed );
	mm:set_end_turn_notification_suppressed( "SPARE_GOVERNOR_SLOT", suppressed );
	mm:set_end_turn_notification_suppressed( "SPARE_MINISTER_SLOT", suppressed );
	mm:set_end_turn_notification_suppressed( "SPARE_SPY_SLOT", suppressed );
	mm:set_end_turn_notification_suppressed( "TRADE_AGREEMENT_SLOTS_AVAILABLE", suppressed );
	mm:set_end_turn_notification_suppressed( "UNDERCOVER_CHARACTER_LOYAL_TO_CURRENT_FACTION", suppressed );
end;

function campaign_tutorial:set_diplomacy_button_enabled( enabled )
	if not is_boolean(enabled) then
		script_error("3k_campaign_tutorial:toggle_diplomacy_suppression() The passed in parameter is not a boolean.")
		return false;
	end;

	out.design("3k_campaign_tutorial: Diplomacy button state changed. enabled= " .. tostring(enabled));

	uim:override("diplomacy"):set_allowed(enabled);
	uim:override("diplomacy_double_click"):set_allowed(enabled);
end;


--***********************************************************************************************************
--***********************************************************************************************************
-- SAVE LOAD
--***********************************************************************************************************
--***********************************************************************************************************



function campaign_tutorial:register_save_load_callbacks()
	cm:add_saving_game_callback(
		function(saving_game_event)
			if self:has_started() and not self:has_finished() then -- These are separately saved into the campaign saved game.
				sm:save();
			end;
		end
	);


	cm:add_loading_game_callback(
		function(loading_game_event)
			if self:has_started() and not self:has_finished() then -- These are separately saved into the campaign saved game.
				sm:load();
			end;
		end
	);
end;

campaign_tutorial:register_save_load_callbacks();