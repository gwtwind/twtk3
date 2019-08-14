

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CAMPAIGN_MANAGER
--
---	@loaded_in_campaign
---	@class campaign_manager Campaign Manager
--- @desc TBD!
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

settlement_prepend_str = "settlement:";

-- __save_counter, used to determine if this is a new game
__save_counter = 0;


function get_cm()
	if __campaign_manager then
		return __campaign_manager;
	else
		script_error("get_cm() called but no campaign manager created as yet");
	end;
end;


__campaign_manager = nil;

campaign_manager = {				-- default values should not be nil, otherwise they'll fail if looked up
	name = "",
	env = false,
	cinematic = false,
	factions = {},
	game_is_created = false,
	pre_first_tick_callbacks = {},
	first_tick_callbacks = {},
	first_tick_callbacks_sp_new = {},
	first_tick_callbacks_sp_each = {},
	first_tick_callbacks_mp_new = {},
	first_tick_callbacks_mp_each = {},
	saving_game_callbacks = {},
	loading_game_callbacks = {},
	game_loaded = false,
	is_multiplayer_campaign = false,
	generic_custom_battlefield_enabled = false,
	local_faction = "",
	human_factions = {},
	post_saving_game_callback = false,
	event_panel_auto_open_enabled = true,
	use_cinematic_borders_for_automated_cutscenes = true,
	ui_hiding_enabled = true,
	
	-- context storing
	context = false,
	last_triggered_event_name = "",
	have_query_interface = false,
	have_modify_interface = false,
	context_stack = {},					-- stack of contexts, for if multiple cascading event trigger
	
	-- saved value system
	saved_values = {},
	
	-- turn manager stuff
	turn_manager_started = false,
	turn_start_callback_list = {},
	turn_end_callback_list = {},
	default_turn_start_callback = false,
	default_turn_end_callback = false,
	
	-- modal queue and ui locking
	modal_queue = {},
	modal_section_active = false,
	modal_system_locked = false,
	ui_locked = false,
	ui_locked_for_mission = false,
	
	-- advice
	pre_dismiss_advice_callbacks = {},
	PROGRESS_ON_ADVICE_FINISHED_REPOLL_TIME = 0.2,
	advice_enabled = true,
	progress_on_advice_dismissed_str = "progress_on_advice_dismissed",
	progress_on_advice_finished_str = "progress_on_advice_finished",
	modify_advice_str = "modify_advice",
	show_advice_text = true,
	
	-- campaign ui
	campaign_ui_manager = false,
	
	-- timer wrapper
	script_timers = {},
	
	-- wait_for_model callback system (singleplayer only)
	modify_model_callback_list = {},
	modify_model_event_created = false,
	
	-- move_npc_army data
	move_npc_army_trigger_count = 0,
	move_npc_army_active_list = {},
	
	-- objective and infotext managers
	objectives = false,
	infotext = false,
	
	-- help page manager
	--hpm = false,  HACK - Disabling help page manager while we decide if we'll do it or not. Re-enable here.
	
	-- mission managers
	mission_managers = {},
	
	-- turn countdown events
	turn_countdown_events = {},
	
	-- intervention manager
	intervention_manager = false,
	
	-- intervention max cost points per session constant
	campaign_intervention_max_cost_points_per_session = 100,
	
	-- turn number modifier
	turn_number_modifier = 0,
	
	-- records whether we're in a battle sequence - between the pre-battle screen appearing and the camera being returned to player control post-battle
	processing_battle = false,					-- saved into savegame
	processing_battle_completing = false,		-- only set to false when post-battle camera movements are completed
	
	-- default diplomacy setup
	all_diplomacy_enabled = true,
	
	-- faction currently processing
	faction_currently_processing = "",
	
	-- diplomacy panel context listener
	diplomacy_panel_context_listener_started = false,
	
	-- faction region change monitor
	faction_region_change_list = {},
	
	-- event feed message suppression
	all_event_feed_messages_suppressed = false,
	
	-- pending battle cache
	pending_battle_cached_attackers = {},
	pending_battle_cached_defenders = {},
	pending_battle_cached_attacker_str = "",
	pending_battle_cached_defender_str = "",
	
	-- cutscene list
	cutscene_list = {},
	
	-- scripted subtitles
	subtitles_component_created = false,
	subtitles_visible = false,
	
	-- chapter mission list
	chapter_missions = {},
	
	-- settlement viewpoint bearing overrides
	settlement_viewpoint_bearings = {},
	
	-- notify on character movement monitors
	notify_on_character_movement_active_monitors = {},
	
	-- check callback frequency system
	check_callback_frequency = false,
	check_callback_frequency_timestamps = {},
	check_callback_frequency_last_callback_count = 0,
	check_callback_frequency_error_on_callback = false,
	CHECK_CALLBACK_FREQUENCY_POLL_TIME = 1,
	CHECK_CALLBACK_FREQUENCY_CALLBACK_THRESHOLD = 50
};





-----------------------------------------------------------------------------
-- tostring and type functions
-----------------------------------------------------------------------------

function campaign_manager:__tostring()
	return TYPE_CAMPAIGN_MANAGER;
end;


function campaign_manager:__type()
	return TYPE_CAMPAIGN_MANAGER;
end;



-----------------------------------------------------------------------------
-- creation
-----------------------------------------------------------------------------

function campaign_manager:new(name)
	
	if __campaign_manager then
		script_error("WARNING: Cannot create more than one campaign manager!");
		return __campaign_manager;
	end;

	if not is_string(name) then
		script_error("ERROR: Attempted to create campaign manager but no campaign name was supplied, or supplied name [" .. tostring(name) .. "] is not a string!");
		return false;
	end;
	
	-- set up campaign manager object
	local cm = {};
	
	setmetatable(cm, campaign_manager);
	self.__index = self;
	__campaign_manager = cm;
	
	cm.env = getfenv(1);
	cm.name = name;
	cm.factions = {};
	cm.pre_first_tick_callbacks = {};
	cm.first_tick_callbacks = {};
	cm.first_tick_callbacks_sp_new = {};
	cm.first_tick_callbacks_sp_each = {};
	cm.first_tick_callbacks_mp_new = {};
	cm.first_tick_callbacks_mp_each = {};
	cm.saving_game_callbacks = {};
	cm.loading_game_callbacks = {};
	cm.pre_dismiss_advice_callbacks = {};
	cm.script_timers = {};
	cm.move_npc_army_active_list = {};
	cm.hyperlink_click_listeners = {};
	cm.mission_succeeded_callbacks = {};
	cm.saved_values = {};
	cm.mission_managers = {};
	cm.turn_countdown_events = {};
	cm.context_stack = {};
	cm.notify_on_character_movement_active_monitors = {};
	
	-- tooltip mouseover listeners
	cm.tooltip_mouseover_listeners = {};
	cm.active_tooltip_mouseover_listeners = {};
	
	-- faction region change monitor
	cm.faction_region_change_list = {};
	
	-- cutscene list
	cm.cutscene_list = {};
	
	-- key stealing
	cm.stolen_keys = {};
	cm.user_input_stolen = false;
	cm.escape_key_stolen = false;
	
	-- callback frequency checking
	cm.check_callback_frequency_timestamps = {};
	
	-- initialise timer system
	core:add_listener(
		"script_timer_system",
		"CampaignTimeTriggerEvent", 
		true,
		function(context)
			cm:check_callbacks(context) 
		end, 
		true
	);
	
	-- listen for stolen keys
	core:add_listener(
		"campaign_stolen_key_listener",
		"OnKeyPressed",
		function(context) return context:is_key_up_event() end,
		function(context) cm:on_key_press_up(context:key_name()) end,
		true	
	);
	
	-- wait_for_model callback system (singleplayer only)
	cm.modify_model_callback_list = {};
	
	-- starts infotext and objectives managers automatically
	cm.infotext = infotext_manager:new();
	cm.objectives = objectives_manager:new();
	-- cm.objectives:set_debug();
	--cm.hpm = help_page_manager:new(); Disabling help page manager
	
	-- stops infotext being added if advice is navigated
	cm:start_advice_navigation_listener();
	
	-- start processing battle listeners in singleplayer mode if it's not an autorun
	core:add_listener(
		"processing_battle_listener",
		"WorldCreated",
		true,
		function(context)
			-- stash whether this is a multiplayer game
			local query_model = context:query_model();
			self.is_multiplayer_campaign = query_model:is_multiplayer();
			-- self.is_multiplayer_campaign = context:query_model():is_multiplayer();

			-- stash the name of the local faction
			local local_faction = self:find_local_faction(context);
			self.local_faction = local_faction;
			
			-- build a list of all human factions that client scripts can query
			self:build_human_factions(context);
			
			-- determine the faction currently processing (at the time of ui creation)
			self.faction_currently_processing = context:query_model():world():whose_turn_is_it():name();
			
			-- start battle-processing listeners if this is not an autorun and not a multiplayer game
			if local_faction and not context:query_model():is_multiplayer() then
				cm:start_processing_battle_listeners_sp();
			end;
		end,
		false
	);
	
	-- start pending battle cache
	cm.pending_battle_cached_attackers = {};
	cm.pending_battle_cached_defenders = {};
	cm:start_pending_battle_cache();
	
	-- list of chapter missions
	cm.chapter_missions = {};
	
	-- output
	out(name ..": Starting campaign_manager.lua");
	
	-- start listener for the FirstTickAfterWorldCreated event: generally used
	-- by users to kick off startup scripts
	core:add_listener(
		name .. "_first_tick_callback",
		"FirstTickAfterWorldCreated",
		true,
		function(context)
			cm:first_tick(context);
		end,
		true
	);
	
	-- start listeners for the SavingGame and LoadingGame events
	core:add_listener(
		name .. "_savegame_callback",
		"SavingGame",
		true,
		function(context)
			cm:saving_game(context);
		end,
		true
	);
	
	core:add_listener(
		name .. "_loadgame_callback",
		"LoadingGame",
		true,
		function(context)
			cm:loading_game(context);
		end,
		true
	);

	return cm;
end;


----------------------------------------------------------------------------
--	Loading campaign files
----------------------------------------------------------------------------

function campaign_manager:get_campaign_folder()
	return "data/script/campaign";
end;


function campaign_manager:require_path_to_campaign_folder()
	package.path = package.path .. ";" .. self:get_campaign_folder() .. "/" .. self.name .. "/factions/?.lua" .. ";"
	package.path = package.path .. ";" .. self:get_campaign_folder() .. "/" .. self.name .. "/?.lua"
end;


function campaign_manager:require_path_to_campaign_faction_folder()
	local local_faction = self:get_local_faction(true);
	
	if not local_faction then
		script_error("ERROR: require_path_to_campaign_faction_folder() called but no local faction could be found - has it been called too early during the load sequence, or during an autotest?");
		return false;
	end;

	package.path = package.path .. ";" .. self:get_campaign_folder() .. "/" .. self.name .. "/factions/" .. local_faction .. "/?.lua" .. ";"
end;







-----------------------------------------------------------------------------
-- FirstTickAfterWorldCreated callback
-----------------------------------------------------------------------------


function campaign_manager:add_pre_first_tick_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_pre_first_tick_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.pre_first_tick_callbacks, callback);
end;


function campaign_manager:add_first_tick_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks, callback);
end;


function campaign_manager:add_first_tick_callback_sp_new(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_sp_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_sp_new, callback);
end;


function campaign_manager:add_first_tick_callback_sp_each(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_sp_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_sp_each, callback);
end;


function campaign_manager:add_first_tick_callback_mp_new(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_mp_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_mp_new, callback);
end;


function campaign_manager:add_first_tick_callback_mp_each(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_mp_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_mp_each, callback);
end;


function campaign_manager:add_first_tick_callback_new(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_first_tick_callback_new() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.first_tick_callbacks_sp_new, callback);
	table.insert(self.first_tick_callbacks_mp_new, callback);
end;
	
	
function campaign_manager:first_tick(context)
	cache_tab();
	output("");
	output("********************************************************************************");
	output(self.name .. " event has occurred:: FirstTickAfterWorldCreated");
	inc_tab();
	
	-- store a link to the campaign manager on _G, as autotest scripts need it occasionally and they can't access it here
	_G.cm = self;
	
	-- client scripts may call functions to determine information about the state of the model or UI from this point
	self.game_is_created = true;
	
	---------------
	---------------
	
	local local_faction = self:get_local_faction(true);
	
	-- start a listener for all faction turn starts so that client scripts can query whos turn it is
	-- also fire a custom event if it's the player's turn
	core:add_listener(
		"faction_currently_processing",
		"FactionTurnStart",
		true,
		function(context)
			self.faction_currently_processing = context:faction():name();
				
			if context:faction():name() == local_faction then
				output("");
				output("********************************************************************************");
				output("* player faction " .. local_faction .. " is starting turn " .. self:query_model():turn_number());
				output("********************************************************************************");
				inc_tab();
				output("triggering event ScriptEventPlayerFactionTurnStart");
				
				core:trigger_event("ScriptEventPlayerFactionTurnStart", context:faction());
			end;
		end,
		true
	);
	
	-- start a listener for the local faction ending a turn which produces output and fires a custom scripted event
	core:add_listener(
		"ScriptEventPlayerFactionTurnEnd",
		"FactionTurnEnd",
		function(context) return context:faction():name() == local_faction end,
		function(context)
			self.faction_currently_processing = "none";
			dec_tab();
			output("********************************************************************************");
			output("********************************************************************************");
			core:trigger_event("ScriptEventPlayerFactionTurnEnd", context:faction());
		end,
		true
	);

	self:modify_scripting():suppress_all_event_feed_event_types(false);
	
	-- mainly for autotesting, but other scripts can listen for it too
	core:trigger_event("ScriptEventGlobalCampaignManagerCreated");
	
	-- mark in the advice history that the player has started a campaign
	effect.set_advice_history_string_seen("player_has_started_campaign");
	
	self:process_first_tick_callbacks(context);
	
	dec_tab();
	output("********************************************************************************");
	output("");
	restore_tab();
end;
	

function campaign_manager:process_first_tick_callbacks(context)

	-- process pre first-tick callbacks
	for i = 1, #self.pre_first_tick_callbacks do
		self.pre_first_tick_callbacks[i](context);
	end;
	
	if self:is_multiplayer() then
		if self:is_new_game() then
			-- process new mp callbacks
			for i = 1, #self.first_tick_callbacks_mp_new do
				self.first_tick_callbacks_mp_new[i](context);
			end;
		end;
	
		-- process each mp callbacks
		for i = 1, #self.first_tick_callbacks_mp_each do
			self.first_tick_callbacks_mp_each[i](context);
		end;
	else
		if self:is_new_game() then
			-- process new sp callbacks
			for i = 1, #self.first_tick_callbacks_sp_new do
				self.first_tick_callbacks_sp_new[i](context);
			end;
		end;
	
		-- process each sp callbacks
		for i = 1, #self.first_tick_callbacks_sp_each do
			self.first_tick_callbacks_sp_each[i](context);
		end;
	end;
	
	-- process shared callbacks
	for i = 1, #self.first_tick_callbacks do
		self.first_tick_callbacks[i](context);
	end;
end;



-----------------------------------------------------------------------------
-- SavingGame callback
-----------------------------------------------------------------------------

function campaign_manager:add_saving_game_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_saving_game_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.saving_game_callbacks, callback);
end;


function campaign_manager:register_post_saving_game_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: register_post_saving_game_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	self.post_saving_game_callback = callback;
end;
	
	
function campaign_manager:saving_game(context)
	cache_tab();
	output("");
	output("********************************************************************************");
	output(self.name .. " event has occurred:: SavingGame");
	inc_tab();
	
	-- increment the __save_counter value
	__save_counter = __save_counter + 1;
	
	-- Save game callbacks first in-case they're saving to the 'saved_values' system for any reason.
	self:process_saving_game_callbacks(context);

	-- saving library values
	self:save_named_value("__save_counter", __save_counter, context);
	self:save_named_value("saved_values", self:saved_values_to_string(), context);
	self:save_named_value("mission_managers", self:mission_managers_to_string(), context);
	self:save_named_value("intervention_manager_state", self:get_intervention_manager():state_to_string(), context);
	self:save_named_value("turn_countdown_events", self:turn_countdown_events_to_string(), context);
	self:save_named_value("faction_region_change_monitor", self:faction_region_change_monitor_to_str(), context);
	-- self:save_named_value("help_page_history", self.hpm:help_page_history_to_string(), context);	 HACK - Disabling help page manager while we decide if we'll do it or not. Re-enable here.
	self:save_named_value("processing_battle", self.processing_battle, context);
	self:save_named_value("faction_currently_processing", self.faction_currently_processing, context);
	
	-- generate pending battle cache strings
	self:pending_battle_cache_to_string();
	self:save_named_value("pending_battle_cached_attacker_str", self.pending_battle_cached_attacker_str, context);
	self:save_named_value("pending_battle_cached_defender_str", self.pending_battle_cached_defender_str, context);
	
	-- invasion manager state
	save_invasion_manager(context);
	
	dec_tab();
	output("********************************************************************************");
	output("");
	restore_tab();
	
	if is_function(self.post_saving_game_callback) then
		self.post_saving_game_callback();
		self.post_saving_game_callback = false;	-- make sure this only happens once
	end;
end;
	

function campaign_manager:process_saving_game_callbacks(context)
	for i = 1, #self.saving_game_callbacks do
		self.saving_game_callbacks[i](context);
	end;
end;


function campaign_manager:save(callback, lock_afterwards)
	if not self:can_modify() then
		return;
	end;
	
	local modify_scripting = self:modify_scripting();
	
	modify_scripting:disable_saving_game(false);
	self:register_post_saving_game_callback(
		function()
			if lock_afterwards then
				self:modify_scripting():disable_saving_game(true);
			end;
			if is_function(callback) then
				callback();
			end;
		end
	);
	modify_scripting:autosave_at_next_opportunity();
end;





-----------------------------------------------------------------------------
-- LoadingGame callback
-----------------------------------------------------------------------------

function campaign_manager:add_loading_game_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_loading_game_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(self.loading_game_callbacks, callback);
end;
	
	
function campaign_manager:loading_game(context)
	cache_tab();
	output("");
	output("********************************************************************************");
	output(self.name .. " event has occurred:: LoadingGame");
	inc_tab();
	
	self.game_loaded = true;

	-- loading library values
	__save_counter = self:load_named_value("__save_counter", 0);
	
	-- only perform these actions if this is not a new game
	if not self:is_new_game() then
		self.processing_battle = self:load_named_value("processing_battle", false);
		
		self.faction_currently_processing = self:load_named_value("faction_currently_processing", "");
		
		self:load_values_from_string(self:load_named_value("saved_values", ""));
		
		-- set up the help page manager even if the tweaker disabling scripts is set
		-- self.hpm:load_history_from_string(self:load_named_value("help_page_history", ""));  HACK - Disabling help page manager while we decide if we'll do it or not. Re-enable here.
		
		local mission_managers_str = self:load_named_value("mission_managers", "", context);
		local intervention_manager_state_str = self:load_named_value("intervention_manager_state", "", context);
		
		-- load pending battle cache strings and then build the tables from them
		self.pending_battle_cached_attacker_str = self:load_named_value("pending_battle_cached_attacker_str", "");
		self.pending_battle_cached_defender_str = self:load_named_value("pending_battle_cached_defender_str", "");
	
		self:pending_battle_cache_from_string();
		
		self:turn_countdown_events_from_string(self:load_named_value("turn_countdown_events", "", context));
		self:faction_region_change_monitor_from_str(self:load_named_value("faction_region_change_monitor", "", context));
		
		-- set up a listener for the faction scripts loading so we can ensure that these objects are ready to have their states rebuilt
		--[[
		core:add_listener(
			"faction_scripts_loaded_listener",
			"ScriptEventFactionScriptsLoaded",
			true,
			function() 
				self:mission_managers_from_string(mission_managers_str);
				self:get_intervention_manager():state_from_string(intervention_manager_state_str);
			end,
			false
		);
		]]
		
		self:add_first_tick_callback(
			function()
				self:mission_managers_from_string(mission_managers_str);
				self:get_intervention_manager():state_from_string(intervention_manager_state_str);
			end
		);
		
		-- invasion manager state
		load_invasion_manager(context);
	end;
	
	self:process_loading_game_callbacks(context);
	
	dec_tab();
	output("********************************************************************************");
	output("");
	restore_tab();
end;
	

function campaign_manager:process_loading_game_callbacks(context)
	for i = 1, #self.loading_game_callbacks do
		self.loading_game_callbacks[i](context);
	end;
end;




-----------------------------------------------------------------------------
-- Saving values - writes the values and outputs to console
-----------------------------------------------------------------------------

function campaign_manager:save_named_value(name, value)

	if not is_string(name) then
		script_error("ERROR: save_named_value() called but supplied value name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	-- saving strings
	if is_string(value) then
		out("Saving string value " .. name .. " [" .. value .. "]");
		self.context:save_string(name, value);
	
	-- saving numbers
	elseif is_number(value) then
		out("Saving number value " .. name .. " [" .. value .. "]");
		self.context:save_int(name, value);
	
	-- saving booleans
	elseif is_boolean(value) then
		out("Saving boolean value " .. name .. " [" .. tostring(value) .. "]");
		self.context:save_bool(name, value);
	
	-- saving tables
	elseif is_table(value) then
		local table_save_state = self:get_table_save_state(value);
		out("save_table_on_saving_game() Saving table " .. name .. " [" .. tostring(value) .. "], save state [" .. table_save_state .. "]");
		self.context:save_string(name, table_save_state);
	
	else
		script_error("ERROR: save_named_value() called with name [" .. name .. "] but value type [" .. type(value) .. " is unsupported");
	end;
end;







-----------------------------------------------------------------------------
-- Loading values - writes the values and outputs to console
-----------------------------------------------------------------------------

function campaign_manager:load_named_value(name, default)

	if not is_string(name) then
		script_error("ERROR: load_named_value() called but supplied value name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	-- loading strings
	if is_string(default) then
		local retval = self.context:load_string(name);
		
		if is_string(retval) and string.len(retval) > 0 then
			out("load_named_value() loading string value " .. name .. " [" .. retval .. "]");
			return retval;
		end;
		
		out("load_named_value() returning default string value for " .. name .. ", value is [" .. default .. "]");
	
	-- loading numbers
	elseif is_number(default) then
		local retval = self.context:load_int(name);
	
		if is_number(retval) then
			out("load_named_value() loading number value " .. name .. " [" .. retval .. "]");
			return retval;
		end;

		out("load_named_value() returning default number value for " .. name .. ", value is [" .. default .. "]");
		
	-- loading booleans
	elseif is_boolean(default) then
		local retval = self.context:load_bool(name);
		
		if is_boolean(retval) then
			out("load_named_value() loading boolean value " .. name .. " [" .. tostring(retval) .. "]");
			return retval;
		end;
		
		out("load_named_value() returning default boolean value for " .. name .. ", value is [" .. tostring(default) .. "]");
		
	-- loading tables
	elseif is_table(default) then
		local table_save_state = self.context:load_string(name);
		
		local error_msg = "<no error>";
		
		-- check that we have a value to convert to a table
		if table_save_state then
			table_func = loadstring(table_save_state);
	  
			if is_function(table_func) then
				local retval = table_func();
				if is_table(retval) then
					out("load_named_value() loading table " .. name .. ", save state is [" .. table_save_state .. "]");
					return retval;
				else
					error_msg = "table value was found in savegame and it converted into a function, but this did not return a table";
				end;
			else
				error_msg = "table value was found in savegame but it did not convert into a table function";
			end;
		else
			error_msg = "no table value was found in savegame";
		end;
		
		out("load_named_value() returning default table value for " .. name .. ", reason: " .. error_msg);
		
	else
		script_error("ERROR: load_named_value() called with name [" .. name .. "] but type [" .. type(default) .. "] of supplied default value is not supported");
	end;
	
	return default;
end;



-----------------------------------------------------------------------------
-- Saved Value system
-- This is an easy interface for client scripts to save and load values into
-- the savegame. Values set with set_saved_value will remain available with
-- get_saved_value
-----------------------------------------------------------------------------

function campaign_manager:set_saved_value(key, value, ...)
	if not is_string(key) then
		script_error("ERROR: set_saved_value() called but specified key [" .. tostring(key) .. "] is not a string");
		return false;
	end;

	if not (is_string(value) or is_number(value) or is_boolean(value)) then
		script_error("ERROR: set_saved_value() called but specified value [" .. tostring(value) .. "] is not a string, number or boolean");
		return false;
	end;
	
	for i = 1, arg.n do
		if not is_string(arg[i]) then
			script_error("ERROR: set_saved_value() called but container name [" .. i .. "] is not a string, its value is [" .. tostring(arg[i]) .. "]")
			return false;
		end;
	end;

	local saved_values_at_level = self.saved_values;

	for i = 1, arg.n do
		if is_nil(saved_values_at_level[arg[i]]) then
			saved_values_at_level[arg[i]] = {};
			saved_values_at_level = saved_values_at_level[arg[i]];
		else
			saved_values_at_level = saved_values_at_level[arg[i]];
			
			if not is_table(saved_values_at_level) then
				script_error("ERROR: set_saved_value() called but container [" .. i .. "] with name [" .. arg[i] .. "] is not a table, its value is [" .. tostring(saved_values_at_level) .. "]");
				return false;
			end;
		end;
	end;

	saved_values_at_level[key] = value;
end;


function campaign_manager:get_saved_value( key, ... )
	if not is_string(key) then
		script_error("ERROR: get_saved_value() called but specified key [" .. tostring(key) .. "] is not a string");
		return nil;
	end;
	
	for i = 1, arg.n do
		if not is_string(arg[i]) then
			script_error("ERROR: get_saved_value() called but container name [" .. i .. "] is not a string, its value is [" .. tostring(arg[i]) .. "]");
			return nil;
		end;
	end;
	
	local saved_values_at_level = self.saved_values;

	for i = 1, arg.n do
		if is_nil(saved_values_at_level[arg[i]]) then
			script_error("ERROR: get_saved_value() called but container [" .. i .. "] with name [" .. arg[i] .. "] is does not exist, so no data is stored.");
			return nil;
		else
			saved_values_at_level = saved_values_at_level[arg[i]];
			
			if not is_table(saved_values_at_level) then
				script_error("ERROR: get_saved_value() called but container [" .. i .. "] with name [" .. arg[i] .. "] is not a table, its value is [" .. tostring(saved_values_at_level) .. "]");
				return nil;
			end;
		end;
	end;

	return saved_values_at_level[key];
end;


function campaign_manager:saved_value_exists( key, ... )
	if not is_string(key) then
		script_error("ERROR: get_saved_value() called but specified key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	for i = 1, arg.n do
		if not is_string(arg[i]) then
			script_error("ERROR: get_saved_value() called but container name [" .. i .. "] is not a string, its value is [" .. tostring(arg[i]) .. "]");
			return false;
		end;
	end;
	
	local saved_values_at_level = self.saved_values;

	for i = 1, arg.n do
		if is_nil(saved_values_at_level[arg[i]]) then
			return false;
		else
			saved_values_at_level = saved_values_at_level[arg[i]];
			
			if not is_table(saved_values_at_level) then
				return false;
			end;
		end;
	end;

	return true;
end;


function campaign_manager:saved_values_to_string()
	local str = "";
	local saved_values = self.saved_values;

	str = self:get_table_save_state(saved_values);

	return str;
end;


function campaign_manager:load_values_from_string(str)

	-- We've moved to a new serliase, so we'll need to find out if the user is in an old or new save.
	local start_string = "return {";
	local is_new_save = string.sub(str, 1, #start_string) == start_string;

	-- New save load system.
	if is_new_save then
		local table_save_state = str;
			
		local error_msg = "<no error>";
		
		-- check that we have a value to convert to a table
		if table_save_state then
			table_func = loadstring(table_save_state);
		
			if is_function(table_func) then
				local retval = table_func();
				if is_table(retval) then
					self.saved_values = retval;
					return true;
				else
					error_msg = "table value was found in savegame and it converted into a function, but this did not return a table";
				end;
			else
				error_msg = "table value was found in savegame but it did not convert into a table function";
			end;
		else
			error_msg = "no table value was found in savegame";
		end;
		
		out("load_values_from_string() returning default table value for reason: " .. error_msg);

		return false;

	-- Legacy save load system.
	else
		out("WARNING: load_values_from_string() This save was made before we changed the save type. Using the legacy system. This should be removed.");

		if not is_string(str) then
			script_error("ERROR: load_values_from_string() called but supplied string [" .. tostring(str) .. "] is not a string");
			return false;
		end;

		local pointer = 1;
		
		while true do
			local next_separator = string.find(str, ":", pointer);
			
			if not next_separator then
				break;
			end;
			
			local value_name = string.sub(str, pointer, next_separator - 1);
			pointer = next_separator + 1;
			
			next_separator = string.find(str, ":", pointer);
			
			if not next_separator then
				script_error("ERROR: load_values_from_string() called but supplied str is malformed: " .. str);
				return false;
			end;
			
			local value_type = string.sub(str, pointer, next_separator - 1);
			pointer = next_separator + 1;
			
			next_separator = string.find(str, ":", pointer);
			
			if not next_separator then
				script_error("ERROR: load_values_from_string() called but supplied str is malformed: " .. str);
				return false;
			end;
			
			local value_length = string.sub(str, pointer, next_separator - 1);
			local num_value_length = tonumber(value_length);
			
			if not num_value_length then
				script_error("ERROR: load_values_from_string() called, but retrieved value_length [" .. tostring(value_length) .. "] could not be converted to a number in string: " .. str);
				return false;
			end;
			
			pointer = next_separator + 1;
			
			local value = string.sub(str, pointer, pointer + num_value_length - 1);
			
			if value_type == "boolean" then
				if value == "true" then
					value = true;
				else
					value = false;
				end;
			elseif value_type == "number" then
				local value_number = tonumber(value);
				
				if not value_number then
					script_error("ERROR: load_values_from_string() called, but couldn't convert loaded numeric value [" .. value .. "] to a number in string: " .. str);
					return false;
				else
					value = value_number;
				end;
			elseif value_type ~= "string" then
				script_error("ERROR: load_values_from_string() called, but couldn't recognise supplied value type [" .. tostring(value_type) .. "] in string: " .. str);
				return false;
			end;
			
			pointer = pointer + num_value_length + 1;
			
			self:set_saved_value(value_name, value);
		end;
	end;
end;


-----------------------------------------------------------------------------
-- Allows saving and loading of tables of any complexity
-----------------------------------------------------------------------------

function campaign_manager:get_table_save_state(tab)
	local ret = "return {"..self:process_table_save(tab).."}";
	return ret;
end

function campaign_manager:process_table_save(tab, _savestring)
	local savestring = _savestring or "";
	local key, val = next(tab, nil);

	while key do	
		if type(val) == "table" then
			if type(key) == "string" then
				savestring = savestring.."[\""..key.."\"]={";
			else
				savestring = savestring.."{";
			end

			savestring = self:process_table_save(val, savestring);
			savestring = savestring.."},";
		elseif type(val) ~= "function" then
			local pref = "";
			
			if type(key) == "string" then
				pref = "[\"" .. key .."\"]=";
			end
			
			if type(val) == "string" then
				savestring = savestring..pref.."\""..val.."\",";
			else
				savestring = savestring..pref..tostring(val)..",";
			end
		end

		key, val = next(tab, key);
	end
	return savestring;
end


-----------------------------------------------------------------------------
-- is_multiplayer, returns true if this is a multiplayer game. Must only
-- be called after the game interface is created
-----------------------------------------------------------------------------

function campaign_manager:is_multiplayer()
	if not self.game_is_created then
		script_error(self.name .. " ERROR: is_multiplayer() called before game has been created!");
		return false;
	end;
	
	return self.is_multiplayer_campaign;
end;


-----------------------------------------------------------------------------
-- is_new_game, returns true if this is a new game, false otherwise.
-- Note that if this is called before the game has been loaded this will
-- return false and throw a script assert
-----------------------------------------------------------------------------

function campaign_manager:is_new_game()
	if not self.game_loaded then
		script_error(self.name .. " WARNING: is_new_game() called before the game has loaded, this call should happen later in the loading process. Returning false.");
		return false;
	end;
	
	return (__save_counter == 1);	-- __save_counter is 0 before the startpos is reprocessed and saved, 1 after the startpos is reprocessed, > 1 after the player first saves
end;






-----------------------------------------------------------------------------
-- query/modify model registry and accessor functions
-----------------------------------------------------------------------------


function campaign_manager:register_model_interface(event_name, context)
	
	-- out.events("register_model_interface() called, event_name is " .. tostring(event_name) .. " and context object is " .. tostring(context));
	-- out.inc_tab("events");

	-- If we already have a context object then push it and its related values onto a stack, from which
	-- they can be popped later. This can happen if some script, while processing, has caused the game to
	-- generate a further event (e.g. triggering a mission)
	if self.context then
		local context_stack_entry = {};
		context_stack_entry.context = self.context;
		context_stack_entry.event_name = self.event_name;
		context_stack_entry.have_query_interface = self.have_query_interface;
		context_stack_entry.have_modify_interface = self.have_modify_interface;

		table.insert(self.context_stack, context_stack_entry);
		
	--	out.events("a context object " .. tostring(self.context) .. " is already registered, adding it to the stack - size of stack is now " .. #self.context_stack);
	-- else
	--	out.events("no previous context object was registered");
	end;

	-- store the context we've been passed
	self.context = context;
	self.last_triggered_event_name = event_name;
	
	-- we should always have a query interface, but let's check
	if type(context["query_model"]) == "function" then
		self.have_query_interface = true;
	else
		self.have_query_interface = false;
	end;
	
	-- test to see if we have a model interface
	if type(context["modify_model"]) == "function" then
		self.have_modify_interface = true;
	else
		self.have_modify_interface = false;
	end;
	
	-- out.events("have_query_interface is now " .. tostring(self.have_query_interface) .. " and have_modify_interface is " .. tostring(self.have_modify_interface));
end;


function campaign_manager:delete_model_interface()
	core:trigger_event("ScriptEventPreDeleteModelInterface");
	
	-- if we have a context on the context stack then restore that as the current context
	-- (and remove it from the stack), else delete the context
	if #self.context_stack > 0 then
		local context_stack_entry = self.context_stack[#self.context_stack];
		self.context = context_stack_entry.context;
		self.last_triggered_event_name = context_stack_entry.event_name;
		self.have_query_interface = context_stack_entry.have_query_interface;
		self.have_modify_interface = context_stack_entry.have_modify_interface;

		table.remove(self.context_stack, #self.context_stack);
		
		-- out.events("delete_model_interface() called, restoring self.context to be " .. tostring(self.context) .. ", size of context stack is now " .. #self.context_stack);
	else
	
		-- delete our context object
		self.context = false;
		self.last_triggered_event_name = "";
		self.have_query_interface = false;
		self.have_modify_interface = false;
		
		-- out.events("delete_model_interface() called, no context to restore, deleting self.context");
	end;
	
	-- out.dec_tab("events");
end;


function campaign_manager:get_last_triggered_event_name()
	return self.last_triggered_event_name;
end;




-----------------------------------------------------------------------------
-- contexts
-----------------------------------------------------------------------------

function campaign_manager:has_current_context()
	if not self.context then
		return false;
	end;

	return true;
end;
function campaign_manager:current_context()
	if not self.context then
		script_error("ERROR: current_context() failed. No context is available. Last event triggered is " .. self:get_last_triggered_event_name());
		return nil;
	end;

	return self.context;
end;



-----------------------------------------------------------------------------
-- query_model and modify_model interfaces
-----------------------------------------------------------------------------


function campaign_manager:can_modify(silent)
	if not self.have_modify_interface then
		if not silent then
			script_error("ERROR: can_modify() failed - no model interface is present. Last event triggered is " .. self:get_last_triggered_event_name(), 1);
		end;
		return false;
	end;
	return true;
end;


function campaign_manager:query_model()	
	return CampaignUI.GetQueryCampaignModel();
end;


function campaign_manager:modify_model()
	if not self:can_modify() then
		return;
	end;
	
	return self.context:modify_model();
end;


-----------------------------------------------------------------------------
-- query_scripting / modify_scripting
-----------------------------------------------------------------------------


-- get query episodic scripting interface
function campaign_manager:query_scripting()
	return self:query_model():episodic_scripting();
end;



-- get modify episodic scripting interface
function campaign_manager:modify_scripting()
	if not self.have_modify_interface then
		script_error("ERROR: modify_scripting() called but we don't have access to modify the model");
		return false;
	end;

	return self:modify_model():get_modify_episodic_scripting();
end;






-----------------------------------------------------------------------------
-- query_faction / modify_faction
-----------------------------------------------------------------------------


function campaign_manager:faction_exists(faction_key)
	if not is_string(faction_key) then
		script_error("ERROR: faction_exists() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;
	
	return self:query_model():world():faction_exists(faction_key);
end;



function campaign_manager:query_faction(faction_key, assert_on_failure)
	if not is_string(faction_key) then
		script_error("ERROR: query_faction() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;
	
	local world = self:query_model():world();
	
	if world:faction_exists(faction_key) then
		return world:faction_by_key(faction_key);
		
	elseif assert_on_failure then
		script_error("ERROR: query_faction() could find no faction with key [" .. tostring(faction_key) .. "]");
	end;
end;

function campaign_manager:query_faction_by_cqi(cqi, assert_on_failure)

	if not is_number(cqi) then
		script_error("ERROR: query_faction_by_cqi() called but supplied faction cqi [" .. tostring(cqi) .. "] is not a number");
		return false;
	end;
	
	if cm:query_model():has_faction_command_queue_index(cqi) then

		return cm:query_model():faction_for_command_queue_index(cqi);
	elseif assert_on_failure then

		script_error("ERROR: query_faction() could find no faction with key [" .. tostring(cqi) .. "]");
	end;
end;


function campaign_manager:modify_faction(obj, assert_on_failure)
	if not self:can_modify() then
		return;
	end;
	
	-- obj is a query faction
	if is_query_faction(obj) then
		return self:modify_model():get_modify_faction(obj);
	end;
	
	-- obj is a faction key
	local query_faction = self:query_faction(obj, assert_on_failure);
	
	if query_faction then
		return self:modify_model():get_modify_faction(query_faction);
	end;
end;


-- for local faction
function campaign_manager:query_local_faction(force)
	local faction_key = self:get_local_faction(force);
	
	if faction_key then
		return self:query_model():world():faction_by_key(faction_key);
	end;
	
	return false;
end;


-- for local faction
function campaign_manager:modify_local_faction(force)
	if not self:can_modify() then
		return;
	end;
	
	local query_faction = self:query_local_faction(force);
	
	if query_faction then
		return self:modify_model():get_modify_faction(query_faction);
	end;
end;




-----------------------------------------------------------------------------
-- query_region / modify_region
-----------------------------------------------------------------------------

function campaign_manager:region_exists(region_key)
	return self:query_region(region_key, true);
end;


function campaign_manager:query_region(region_key, exists)
	if not is_string(region_key) then
		script_error("ERROR: query_region() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return false;
	end;
	
	local query_region = self:query_model():world():region_manager():region_by_key(region_key);
	
	if exists then
		return (not query_region:is_null_interface());
	end;
	
	return query_region;
end;


function campaign_manager:modify_region(obj)
	if not self:can_modify() then
		return;
	end;
	
	-- obj is a query region
	if is_query_region(obj) then
		return self:modify_model():get_modify_region(obj);
	end;
	
	-- obj is a region key
	local query_region = self:query_region(obj);
	
	if query_region then
		return self:modify_model():get_modify_region(query_region);
	end;
end;



-----------------------------------------------------------------------------
-- query_settlement / modify_settlement
-----------------------------------------------------------------------------


function campaign_manager:query_settlement(region_key)
	local query_region = self:query_region(region_key);
	
	if query_region then
		return query_region:settlement();
	end;
end;


function campaign_manager:modify_settlement(obj)
	if not self:can_modify() then
		return;
	end;
	
	-- obj is a query settlement
	if is_query_settlement(obj) then
		return self:modify_model():get_modify_settlement(obj);
	end;
	
	-- obj is a region key
	local query_settlement = self:query_settlement(obj);
	
	if query_settlement then
		return self:modify_model():get_modify_settlement(query_settlement);
	end;
end;



-----------------------------------------------------------------------------
-- query_character / modify_character
-----------------------------------------------------------------------------

function campaign_manager:query_character(cqi)
	if is_string(cqi) then
		cqi = tonumber(cqi);
	end;
	
	if not is_number(cqi) then
		script_error("query_character() called but supplied cqi [" .. tostring(cqi) .. "] is not a number or a string that converts to a number");
		return false;
	end;
	
	return self:query_model():character_for_command_queue_index(cqi);
end;
	
	
function campaign_manager:modify_character(obj)
	if not self:can_modify() then
		return;
	end;
	
	-- obj is a query_character
	if is_query_character(obj) then
		return self:modify_model():get_modify_character(obj);
	end;
	
	-- obj is a cqi
	local query_character = self:query_character(obj);
	
	if query_character then
		return self:modify_model():get_modify_character(query_character);
	end;
end;





-----------------------------------------------------------------------------
-- query_military_force / modify_military_force
-----------------------------------------------------------------------------


function campaign_manager:query_military_force(character_cqi)
	local query_character = self:query_character(character_cqi);
	
	if query_character and query_character:has_military_force() then
		return query_character:military_force();
	end;
end;


function campaign_manager:modify_military_force(obj)
	if not self:can_modify() then
		return;
	end;
	
	-- obj is a query settlement
	if is_query_military_force(obj) then
		return self:modify_model():get_modify_military_force(obj);
	end;
	
	-- obj is a char cqi
	local query_military_force = self:query_military_force(obj);
	
	if query_military_force then
		return self:modify_model():get_modify_military_force(query_military_force);
	end;
end;
	
	
	


-----------------------------------------------------------------------------
-- query_campaign_ai / modify_campaign_ai
-----------------------------------------------------------------------------

function campaign_manager:query_campaign_ai()
	
	return self:query_model():campaign_ai();
end;


function campaign_manager:modify_campaign_ai()
	if not self:can_modify() then
		return;
	end;
		
	return self:modify_model():get_modify_campaign_ai(self:query_campaign_ai());
end;









-----------------------------------------------------------------------------
-- wait_for_model_sp() system
-- calling scripts can call wait_for_model_sp(callback) to ensure that the callback
-- gets called when the model is accessible (either immediately or next tick)
-- This function is singleplayer only
-----------------------------------------------------------------------------


function campaign_manager:wait_for_model_sp(callback)

	if self:is_multiplayer() then
		script_error("ERROR: wait_for_model_sp() called but this is a multiplayer game");
		return false;
	end;

	-- if we have a modify interface then call the callback immediately
	if self:can_modify(true) then
		callback();
		return;
	end;
	
	local context = self.context;
	
	if not self.modify_model_event_created then
		-- No modify model event has been created - this is the first call to wait_for_model_sp this tick. Go ahead and create one.
		if not context then
			script_error("ERROR: wait_for_model_sp() called and we have no stored context - how can this be? - "  .. tostring(context.string));
			return false;
			
		elseif not context:can_request_model_callback() then
			script_error("ERROR: wait_for_model_sp() called and we cannot currently modify or create a modify model event - how can this be? - " .. tostring(context.string));
			return false;
		end;
		
		core:add_listener(
			"campaign_manager_wait_for_model_sp",
			"CampaignModelScriptCallback",
			function(context)
				return context:context():event_id() == "campaign_manager_wait_for_model_sp";
			end,
			function(context)
				self.modify_model_event_created = false;
				self:process_model_callback_list(context);
			end,
			false
		);

		context:create_model_callback_request("campaign_manager_wait_for_model_sp");
		self.modify_model_event_created = true;
	end;
	
	table.insert(self.modify_model_callback_list, callback);
end;



function campaign_manager:process_model_callback_list(context)

	-- make a copy of the callback list, for safety
	local callback_list = {};
	
	for i = 1, #self.modify_model_callback_list do
		callback_list[i] = self.modify_model_callback_list[i];
	end;
	
	-- clear the stored list, so that if any of our callbacks try to add things to it (should be impossible) nothing will break
	self.modify_model_callback_list = {};
	
	for i = 1, #callback_list do
		callback_list[i](context);
	end;
end;









-----------------------------------------------------------------------------
-- tries to load a faction script
-----------------------------------------------------------------------------

function campaign_manager:load_faction_script(scriptname, single_player_only)

	if single_player_only and self:is_multiplayer() then
		output("Multiplayer game detected not loading tutorial script")
		return;
	end;

	if package.loaded[scriptname] then
		return;
	end;
	
	local file = loadfile(scriptname);
	
	if file then
		-- the file has been loaded correctly - set its environment, record that it's been loaded, then execute it
		output("Loading faction script " .. scriptname .. ".lua");
		inc_tab();
		
		setfenv(file, self.env);
		package.loaded[scriptname] = true;
		file();
		
		dec_tab();
		output(scriptname .. ".lua script loaded");
		return true;
	end;
	
	-- the file was not loaded correctly, however loadfile doesn't tell us why. Here we try and load it again with require which is more verbose
	local success, err_code = pcall(function() require(scriptname) end);

	script_error("ERROR: Tried to load faction script " .. scriptname .. " without success - either the script is not present or it is not valid. See error below");
	output("*************");
	output("Returned lua error is:");
	output(err_code);
	output("*************");

	return false;
end;


-----------------------------------------------------------------------------
-- get campaign name
-----------------------------------------------------------------------------

function campaign_manager:get_campaign_name()
	return self.name;
end;



-----------------------------------------------------------------------------
-- find_local_faction, computes and returns the name of the local 
-- faction. For internal use, the cm caches the result which can then
-- be externally fetched with get_local_faction()
-----------------------------------------------------------------------------

function campaign_manager:find_local_faction(context)
	local model = context:query_model();
	local faction_list = model:world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		local faction_name = faction:name();
		
		if faction:is_human() and faction_name == model:local_faction():name() then
			return faction_name;
		end;
	end;
	
	script_error("WARNING: find_local_faction() called but couldn't find a local faction - this should only happen in autoruns");
	return false;
end;



-----------------------------------------------------------------------------
-- get_local_faction, returns the name of the local faction (there should
-- only be one). If it doesn't exist yet throw an error
-----------------------------------------------------------------------------

function campaign_manager:get_local_faction(force)
	if not self.game_is_created then
		script_error(self.name .. " ERROR: get_local_faction() called before game has been created!");
		return false;
	end;
	
	if self:is_multiplayer() and not force then
		script_error(self.name .. " ERROR: get_local_faction() called but this is a multiplayer game, reconsider or force this usage");
		return false;
	end;
	
	return self.local_faction;
end;




-----------------------------------------------------------------------------
-- get_human_factions, returns a table containing the keys of all human
-- factions. If it doesn't exist yet throw an error.
-----------------------------------------------------------------------------

function campaign_manager:get_human_factions()
	if not self.game_is_created then
		script_error(self.name .. " ERROR: get_human_faction() called before game has been created!");
		return false;
	end;
	
	return self.human_factions;
end;


-- build the list of human factions
function campaign_manager:build_human_factions(context)
	local faction_list = context:query_model():world():faction_list();
	local human_factions = {};

	for i = 0, faction_list:num_items() - 1 do
		if faction_list:item_at(i):is_human() then
			table.insert(human_factions, faction_list:item_at(i):name());
		end;
	end;

	self.human_factions = human_factions;
end;








-----------------------------------------------------------------------------
-- Campaign startup handlers
-- These functions can be used to register callbacks
-----------------------------------------------------------------------------

-- require a file in the factions subfolder that matches the name of our local faction. The model will be set up by the time
-- the ui is created, so we wait until this event to query who the local faction is. This is why we defer loading of our
-- faction scripts until this time.
function campaign_manager:load_local_faction_scripts(name_appellation)

	if name_appellation then
		if not is_string(name_appellation) then
			script_error("ERROR: load_local_faction_scripts() called but supplied name appellation [" .. tostring(name_appellation) .. "] is not a string");
			return false;
		end;
	else
		name_appellation = "";
	end;
	
	local local_faction = self:get_local_faction(true);
	
	if not local_faction then
		output("Not loading local faction scripts as no local faction could be determined");
		return false;
	end;
	
	-- include path to scripts in script/campaigns/<campaign_name>/factions/<faction_name>/* associated with this campaign/faction
	self:require_path_to_campaign_faction_folder(campaign_name, faction_name);
	
	local script_name = local_faction .. name_appellation;
	
	output("Loading faction script " .. script_name .. " for faction " .. local_faction);
	
	inc_tab();
		
	-- faction scripts loaded here - function will return true if the load succeeded
	if self:load_faction_script(script_name) then
		dec_tab();
		output("Faction scripts loaded");
	else
		dec_tab();
	end;
end;











-----------------------------------------------------------------------------
--	get_campaign_ui_manager
--	Gets a handle to the campaign ui manager (or creates it)
-----------------------------------------------------------------------------

function campaign_manager:get_campaign_ui_manager()
	if self.campaign_ui_manager then
		return self.campaign_ui_manager;
	end;
	return campaign_ui_manager:new();
end;









-----------------------------------------------------------------------------
-- camera scrolling with output
-----------------------------------------------------------------------------


function campaign_manager:check_valid_camera_waypoint(waypoint)
	if not is_table(waypoint) then
		script_error("ERROR: check_valid_camera_waypoint() called but supplied waypoint [" .. tostring(waypoint) .. "] is not a table");
		return false;
	end;
	
	for i = 1, 5 do
		if not is_number(waypoint[i]) then
			script_error("ERROR: check_valid_camera_waypoint() called but index [" .. i .. "] of supplied waypoint is not a number but is [" .. tostring(waypoint[i]) .. "]");
			return false;
		end;
	end;
	
	-- for waypoints that include a timestamp
	if #waypoint == 6 then
		if not is_number(waypoint[6]) then
			script_error("ERROR: check_valid_camera_waypoint() called but index [" .. 6 .. "] of supplied waypoint is not a number but is [" .. tostring(waypoint[6]) .. "]");
			return false;
		end;
	end;
	
	return true;
end;


-- are the positions the same
function campaign_manager:scroll_camera_position_check(source, dest)
	return source[1] == dest[1] and source[2] == dest[2] and source[3] == dest[3] and source[4] == dest[4] and source[5] == dest[5];
end;


function campaign_manager:camera_position_to_string(x, y, d, b, h)
	if is_table(x) then
		y = x[2];
		d = x[3];
		b = x[4];
		h = x[5];
		x = x[1];
	end;
	
	return "[x: " .. tostring(x) .. ", y: " .. tostring(y) .. ", d: " .. tostring(d) .. ", b: " .. tostring(b) .. ", h: " .. tostring(h) .. "]";
end;


function campaign_manager:scroll_camera_with_direction(valid_endpoint, t, ...)

	local x, y, d, b, h = self:get_camera_position();
	
	valid_endpoint = not not valid_endpoint;
	
	if not is_number(t) or t < 0 then
		script_error("ERROR: scroll_camera_with_direction() called but supplied duration [" .. tostring(t) .. "] is not a positive number");
		return false;
	end;
	
	output("scroll_camera_with_direction() called, valid_endpoint is " .. tostring(valid_endpoint) .. ", time is " .. tostring(t) .. "s, current camera position is " .. self:camera_position_to_string(x, y, d, b, h));
	
	inc_tab();
	for i = 1, arg.n do
		local current_pos = arg[i];
		output("position " .. i .. ": " .. self:camera_position_to_string(current_pos[1], current_pos[2], current_pos[3], current_pos[4], current_pos[5]));
	end;
	dec_tab();
	
	CampaignUI.ScrollCameraWithDirection(valid_endpoint, t, unpack(arg));
end;


function campaign_manager:set_use_cinematic_borders_for_automated_cutscenes(value)
	self.use_cinematic_borders_for_automated_cutscenes = not not value;
end;


function campaign_manager:scroll_camera_from_current(t, correct_endpoint, ...)
	correct_endpoint = correct_endpoint or false;

	-- check our parameters
	if not is_number(t) or t <= 0 then
		script_error("ERROR: scroll_camera_from_current() called but supplied duration [" .. tostring(t) .. "] is not a number");
		return false;
	end;
	
	for i = 1, arg.n do
		if not self:check_valid_camera_waypoint(arg[i]) then
			-- error will be returned by the function above
			return false;
		end;
	end;
	
	-- insert the current camera position as the first position in the sequence
	local x, y, d, b, h = self:get_camera_position();
	
	table.insert(arg, 1, {x, y, d, b, h});
	
	-- output
	output("scroll_camera_from_current() called");
	inc_tab();	
	self:scroll_camera_with_direction(correct_endpoint, t, unpack(arg))
	dec_tab();
end;


function campaign_manager:scroll_camera_with_cutscene(t, end_callback, ...)

	-- check our parameters
	if not is_number(t) or t <= 0 then
		script_error("ERROR: scroll_camera_with_cutscene() called but supplied duration [" .. tostring(t) .. "] is not a number");
		return false;
	end;
	
	if not is_function(end_callback) and not is_nil(end_callback) then
		script_error("ERROR: scroll_camera_with_cutscene() called but supplied end_callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	for i = 1, arg.n do
		if not self:check_valid_camera_waypoint(arg[i]) then
			-- error will be returned by the function above
			return false;
		end;
	end;
	
	-- get the last position now before we start mucking around with the argument list
	local last_pos = arg[arg.n];
	
	-- insert the current camera position as the first position in the sequence
	local x, y, d, b, h = self:get_camera_position();
	
	table.insert(arg, 1, {x, y, d, b, h});
	
	self:cut_and_scroll_camera_with_cutscene(t, end_callback, unpack(arg));
end;



function campaign_manager:cut_and_scroll_camera_with_cutscene(t, end_callback, ...)

	-- check our parameters
	if not is_number(t) or t <=0 then
		script_error("ERROR: cut_and_scroll_camera_with_cutscene() called but supplied duration [" .. tostring(t) .. "] is not a number");
		return false;
	end;
	
	if not is_function(end_callback) and not is_nil(end_callback) then
		script_error("ERROR: cut_and_scroll_camera_with_cutscene() called but supplied end_callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if arg.n < 2 then
		script_error("ERROR: cut_and_scroll_camera_with_cutscene() called but less than two camera positions given");
		return false;
	end;
	
	for i = 1, arg.n do
		if not self:check_valid_camera_waypoint(arg[i]) then
			-- error will be returned by the function above
			return false;
		end;
	end;
		
	-- make a cutscene, add the camera pan as the action and play it
	local cutscene = campaign_cutscene:new(
		"scroll_camera_with_cutscene", 
		t, 
		function() 
			dec_tab();
			if end_callback then
				end_callback();
			end;
		end
	);
	
	cutscene:set_skippable(true, arg[arg.n]);	-- set the last position in the supplied list to be the skip position
	cutscene:set_dismiss_advice_on_end(false);
	
	cutscene:set_use_cinematic_borders(self.use_cinematic_borders_for_automated_cutscenes);
	cutscene:set_disable_settlement_labels(false);
	
	local start_position = arg[1];
	
	cutscene:action(function() self:set_camera_position(unpack(start_position)) end, 0);
	cutscene:action(
		function()
			inc_tab();
			self:scroll_camera_with_direction(true, t, unpack(arg));
			dec_tab();
		end, 
		0
	);
	cutscene:start();
end;


function campaign_manager:scroll_camera_with_cutscene_to_settlement(t, end_callback, region_key)
	if not is_string(region_key) then
		script_error("ERROR: scroll_camera_with_cutscene_to_settlement() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return false;
	end;

	local region = self:query_region(region_key);
	
	if not region then
		script_error("ERROR: scroll_camera_with_cutscene_to_settlement() called but region with supplied key [" .. region_key .. "] could not be found");
		return false;
	end;
	
	local settlement = region:settlement();
	
	local targ_x = settlement:display_position_x();
	local targ_y = settlement:display_position_y();
	
	local x, y, d, b, h = self:get_camera_position();
	
	-- pan camera to calculated target
	self:scroll_camera_with_cutscene(
		t, 
		end_callback,
		{targ_x, targ_y, 8, b, 10}			-- customise constants to suit
	);
end;


function campaign_manager:scroll_camera_with_cutscene_to_character(t, end_callback, char_cqi)
	if not is_number(char_cqi) then
		script_error("ERROR: scroll_camera_with_cutscene_to_character() called but supplied character cqi [" .. tostring(char_cqi) .. "] is not a number");
		return false;
	end;
		
	local character = self:query_character(char_cqi);
	
	if not character then
		script_error("ERROR: scroll_camera_with_cutscene_to_character() called but no character with cqi [" .. char_cqi .. "] could be found");
		return false;
	end;
	
	local targ_x = character:display_position_x();
	local targ_y = character:display_position_y();
	
	local x, y, d, b, h = self:get_camera_position();
	
	-- pan camera to calculated target
	self:scroll_camera_with_cutscene(
		t, 
		end_callback,
		{targ_x, targ_y, 8, b, 10}			-- customise constants to suit
	);
end;


function campaign_manager:position_camera_at_primary_military_force(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: position_camera_at_primary_military_force() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	local query_faction = self:query_faction(faction_name);
	
	if not query_faction then
		script_error("ERROR: position_camera_at_primary_military_force() called but no faction with name [" .. faction_name .. "] could be found");
		return false;
	end;
	
	if not query_faction:has_faction_leader() then
		script_error("ERROR: position_camera_at_primary_military_force() called but no faction leader could be found for faction [" .. faction_name .. "]");
		return false;
	end;
	
	local faction_leader = query_faction:faction_leader();
	local targ_x = nil;
	local targ_y = nil;
	
	local x, y, d, b, h = self:get_camera_position();
	
	if faction_leader:has_military_force() then
		targ_x = faction_leader:display_position_x();
		targ_y = faction_leader:display_position_y();
	else
		local mf_list_item_0 = query_faction:military_force_list():item_at(0);
		
		if mf_list_item_0:has_general() then
			local general = mf_list_item_0:general_character();
			
			targ_x = general:display_position_x();
			targ_y = general:display_position_y();
		else
			script_error("ERROR: position_camera_at_primary_military_force() called but no military force for faction [" .. faction_name .. "] could be found on the map");
		end;
	end
	
	cm:set_camera_position(x, y, 8, b, 10);			-- customise constants to suit
end;







-----------------------------------------------------------------------------
-- get/set camera position wrappers
-----------------------------------------------------------------------------

function campaign_manager:get_camera_position()
	return CampaignUI.GetCameraPosition();
end;


function campaign_manager:set_camera_position(x, y, d, b, h)
	CampaignUI.SetCameraPosition(x, y, d, b, h);
end;





-----------------------------------------------------------------------------
-- advice
-----------------------------------------------------------------------------


function campaign_manager:show_advice(key, progress_button, highlight, playtime, callback, delay)
	if not self.advice_enabled then
		return;
	end;
	
	if not is_string(key) then
		script_error("ERROR: show_advice() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;

	output("show_advice() called, key is " .. tostring(key));
	
	local show_advice_progress_str = "show_advice_progress_on_advice_finished";
	
	self:remove_callback(show_advice_progress_str);
	self:remove_callback(self.modify_advice_str);
	
	-- actually show the advice
	effect.advance_scripted_advice_thread(key, 1);
	
	if not self.show_advice_text then
		self:set_show_advice_text(false);
	end;

	self:modify_advice(progress_button, highlight);

	if not callback then
		return;
	end;
	
	if not is_function(callback) then
		script_error("show_advice() called but supplied callback [" .. tostring(callback) .. "] is not a function. Key is " .. tostring(key));
		return;
	end;
		
	if not is_number(playtime) or playtime < 0 then
		playtime = 0;
	end;
	
	-- delay this by a second in case it returns back straight away
	self:os_clock_callback(function() self:progress_on_advice_finished(callback, delay, playtime, true) end, 1, show_advice_progress_str);
end;


--- @function is_advice_enabled
--- @desc Returns <code>true</code> if the advice system is enabled, or <code>false</code> if it's been disabled with @campaign_manager:set_advice_enabled.
--- @return boolean advice is enabled
function campaign_manager:is_advice_enabled()
	return self.advice_enabled;
end;


--- @function set_advice_enabled
--- @desc Enables or disables the advice system.
--- @p [opt=true] boolean enable advice
function campaign_manager:set_advice_enabled(value)
	if value == false then
		--
		-- delaying this call as a workaround for a floating-point error that seems to occur when it's made in the same tick as the LoadingScreenDismissed event
		self:callback(function() self:modify_scripting():override_ui("disable_advisor_button", true) end, 0.2);
		-- self:modify_scripting():override_ui("disable_advisor_button", true);
		
		set_component_active(false, "menu_bar", "button_show_advice");
		self.advice_enabled = false;
	else
		self:modify_scripting():override_ui("disable_advisor_button", false);
		set_component_active(true, "menu_bar", "button_show_advice");
		self.advice_enabled = true;
	end;
end;


function campaign_manager:set_show_advice_text(value)
	if value ~= false then
		value = true;
	end;
	
	-- find the advice text component
	local uic_advice_text = find_uicomponent(core:get_ui_root(), "advice_interface", "text_parent");
	if not uic_advice_text then
		script_error("ERROR: set_show_advice_text() couldn't find uic_advice_text");
		return false;
	end;
	
	uic_advice_text:SetVisible(value);
	
	-- show a fade-in animation if advice text is going from invisible to visible	
	if value and not self.show_advice_text then
		uic_advice_text:TriggerAnimation("fade_in");
	end;
end;




function campaign_manager:modify_advice(progress_button, highlight)
	-- if the component doesn't exist yet, wait a little bit as it's probably in the process of being created
	if not find_uicomponent(core:get_ui_root(), "advice_interface") then
		self:os_clock_callback(function() self:modify_advice(progress_button, highlight) end, 0.2, self.modify_advice_str);
		return;
	end;

	self:remove_callback(self.modify_advice_str);

	if progress_button then
		show_advisor_progress_button();	
		
		core:remove_listener("dismiss_advice_listener");
		core:add_listener(
			"dismiss_advice_listener",
			"ComponentLClickUp", 
			function(context) return context.string == __advisor_progress_button_name end,
			function(context) self:dismiss_advice() end, 
			false
		);
	else
		show_advisor_progress_button(false);
	end;
	
	if highlight then
		highlight_advisor_progress_button(true);
	else
		highlight_advisor_progress_button(false);
	end;
end;


function campaign_manager:register_pre_dismiss_advice_callback(callback)
	if not is_function(callback) then
		script_error("ERROR: register_pre_dismiss_advice_callback() called but supplied callback [" .. tostring(callback) .."] is not a function");
		return false;
	end;
	
	table.insert(self.pre_dismiss_advice_callbacks, callback);
end;


function campaign_manager:dismiss_advice()
	if not core:is_ui_created() then
		script_error("ERROR: dismiss_advice() called but ui not created");
		return false;
	end;
	
	if not self:can_modify() then
		return false;
	end;
	
	-- call all pre_dismiss_advice_callbacks	
	for i = 1, #self.pre_dismiss_advice_callbacks do
		self.pre_dismiss_advice_callbacks[i]();
	end;
	
	self.pre_dismiss_advice_callbacks = {};
	
	-- perform the advice dismissal
	self:modify_scripting():dismiss_advice();
	self.infotext:clear_infotext();
	
	-- unhighlight advisor progress button	
	highlight_advisor_progress_button(false);
end;


function campaign_manager:progress_on_advice_dismissed(callback, delay, highlight_on_finish)
	if not is_function(callback) then
		script_error("ERROR: progress_on_advice_dismissed() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	if not is_number(delay) or delay < 0 then
		delay = 0;
	end;
	
	-- a test to see if the advisor is visible on-screen at this moment
	local advisor_open_test = function()
		local uic_advisor = find_uicomponent(core:get_ui_root(), "advice_interface");
		return self.advice_enabled and uic_advisor and uic_advisor:Visible(true) and uic_advisor:CurrentAnimationId() == "";
	end;
	
	-- a function to set up listeners for the advisor closing
	local progress_func = function()
		local is_dismissed = false;
		local is_highlighted = false;
		
		core:add_listener(
			self.progress_on_advice_dismissed_str,
			"AdviceDismissedEvent",
			true,
			function()
				self:wait_for_model_sp(
					function()
						is_dismissed = true;
						
						if highlight_on_finish then
							self:cancel_progress_on_advice_finished();
						end;
					
						-- remove the highlight if it's applied
						if is_highlighted then
							self:modify_advice(true, false);
						end;
					
						if delay > 0 then
							self:callback(function() callback() end, delay);
						else
							callback();
						end;
					end
				);
			end,
			false
		);
		
		-- if the highlight_on_finish flag is set, we highlight the advisor close button when the 
		if highlight_on_finish then
			self:progress_on_advice_finished(
				function()
					self:wait_for_model_sp(
						function()
							if not is_dismissed then
								is_highlighted = true;
								self:modify_advice(true, true) 
							end;
						end
					);
				end
			);
		end;
	end;
	
	-- If the advisor open test passes then set up the progress listener, otherwise wait 0.5 seconds and try it again.
	-- If the advisor fails this test three times (i.e over the course of a second) then automatically progress
	if advisor_open_test() then
		progress_func();
	else
		self:os_clock_callback(
			function()
				if advisor_open_test() then
					progress_func();
				else
					self:os_clock_callback(
						function()
							if advisor_open_test() then
								progress_func();
							else
								if delay > 0 then
									self:callback(function() callback() end, delay);
								else
									callback();
								end;
							end;
						end,
						0.5,
						self.progress_on_advice_dismissed_str
					);
				end;
			end,
			0.5,
			self.progress_on_advice_dismissed_str
		);
	end;
end;


function campaign_manager:cancel_progress_on_advice_dismissed()
	core:remove_listener(self.progress_on_advice_dismissed_str);
	self:remove_callback(self.progress_on_advice_dismissed_str);
end;


function campaign_manager:progress_on_advice_finished(callback, delay, playtime, use_os_clock)
	if not is_function(callback) then
		script_error("ERROR: progress_on_advice_finished() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	local callback_function = function()
		self:cancel_progress_on_advice_finished();
		
		-- do the given callback
		if is_number(delay) and delay > 0 then
			if use_os_clock then
				local end_time = os.clock() + delay;
				self:os_clock_callback(function() callback() end, end_time, self.progress_on_advice_finished_str);
			else
				self:callback(function() callback() end, delay, self.progress_on_advice_finished_str);
			end;
		else
			callback();
		end;
	end;
	
	-- if advice is disabled then just finish
	if not self.advice_enabled then
		callback_function();
		return;
	end;
	
	if effect.is_advice_audio_playing() then
		-- advice is currently playing
		core:add_listener(
			self.progress_on_advice_finished_str,
			"AdviceFinishedTrigger",
			true,
			function()
				self:wait_for_model_sp(function() callback_function() end);
			end,
			false
		);
	end;
	
	playtime = playtime or 5;
	
	-- for if sound is disabled
	self:callback(function() self:progress_on_advice_finished_poll(callback, delay, playtime, use_os_clock, 0) end, playtime, self.progress_on_advice_finished_str);
end;


function campaign_manager:progress_on_advice_finished_poll(callback, delay, playtime, use_os_clock, count)
	count = count or 0;
	
	if not effect.is_advice_audio_playing() then
		self:cancel_progress_on_advice_finished();
		
		output("progress_on_advice_finished is progressing as no advice sound is playing after playtime of " .. playtime + (count * self.PROGRESS_ON_ADVICE_FINISHED_REPOLL_TIME) .. "s");
		
		-- do the given callback
		if is_number(delay) then
			if use_os_clock then
				local end_time = os.clock() + delay;
				self:os_clock_callback(function() callback() end, end_time, self.progress_on_advice_finished_str)
			else
				self:callback(function() callback() end, delay, self.progress_on_advice_finished_str);
			end;
		else
			callback();
		end;
		return;
	end;
	
	count = count + 1;
	
	-- sound is still playing, check again in a bit
	if use_os_clock then
		local end_time = os.clock() + self.PROGRESS_ON_ADVICE_FINISHED_REPOLL_TIME;
		self:os_clock_callback(function() self:progress_on_advice_finished_poll(callback, delay, playtime, use_os_clock, count) end, end_time, self.progress_on_advice_finished_str);
	else
		self:callback(function() self:progress_on_advice_finished_poll(callback, delay, playtime, use_os_clock, count) end, self.PROGRESS_ON_ADVICE_FINISHED_REPOLL_TIME, self.progress_on_advice_finished_str);
	end;
end;


function campaign_manager:cancel_progress_on_advice_finished()
	core:remove_listener(self.progress_on_advice_finished_str);
	self:remove_callback(self.progress_on_advice_finished_str);
end;





-------------------------------------------------------
--	progress on fullscreen panel dismissed
-------------------------------------------------------



function campaign_manager:progress_on_fullscreen_panel_dismissed(callback, delay)
	delay = delay or 0;
	
	self:cancel_progress_on_fullscreen_panel_dismissed();
	
	local open_fullscreen_panel = self:get_campaign_ui_manager():get_open_fullscreen_panel();
	
	if open_fullscreen_panel then
		core:add_listener(
			"progress_on_fullscreen_panel_dismissed",
			"ScriptEventPanelClosedCampaign",
			function(context) return context.string == open_fullscreen_panel end,
			function() self:progress_on_fullscreen_panel_dismissed(callback, delay) end,
			false
		);
	else
		self:wait_for_model_sp(function() self:callback(callback, delay) end);
	end;
end;

function campaign_manager:cancel_progress_on_fullscreen_panel_dismissed()
	self:remove_callback("progress_on_fullscreen_panel_dismissed");
end;




-------------------------------------------------------
--	progress on events dismissed
-------------------------------------------------------

function campaign_manager:progress_on_events_dismissed(name, callback, delay, wait_between_tests)
	if cm:is_multiplayer() then
		script_error("ERROR: progress_on_events_dismissed() called in multiplayer mode");
		return false;
	end;

	if not is_string(name) then
		script_error("ERROR: progress_on_events_dismissed() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_function(callback) then
		script_error("ERROR: progress_on_events_dismissed() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;

	delay = delay or 0;
	wait_between_tests = wait_between_tests or 0
	
	if not is_number(delay) or delay < 0 then
		script_error("ERROR: progress_on_events_dismissed() called but supplied delay [" .. tostring(delay) .. "] is not a positive number or nil");
		return false;
	end;
	
	
	if self:get_campaign_ui_manager():is_event_panel_open() then
		core:add_listener(
			name .. "_progress_on_events_dismissed",
			"ScriptEventPanelClosedCampaign",
			function(context) 
				return context.string == "events" or context.string == "event_single";
			end,
			function()
				self:wait_for_model_sp(
					function() 
						self:callback( function() self:progress_on_events_dismissed( name, callback, delay ) end, wait_between_tests );
						
					end
				);
			end,
			false
		);
	else
		self:wait_for_model_sp( 
			function()
				if delay == 0 then
					callback();
				else
					self:callback( callback, delay );
				end;
			end
		);
	end
end;


function campaign_manager:cancel_progress_on_events_dismissed(name)
	core:remove_listener(name .. "_progress_on_events_dismissed");
end;



function campaign_manager:highlight_event_dismiss_button(should_highlight)
	
	local uic_button = find_uicomponent(core:get_ui_root(), "panel_manager", "events", "button_set", "accept_decline", "button_accept");
	local button_highlighted = false;
	
	-- if should_highlight is false, then both potential buttons get unhighlighted
	-- if it's true, then only the first that is found to be visible is highlighted
		
	if uic_button and (uic_button:Visible(true) or not should_highlight) then
		uic_button:Highlight(should_highlight, false, 0);
		button_highlighted = true;
	end;
	
	if button_highlighted and should_highlight then
		return;
	end;
	
	uic_button = find_uicomponent(core:get_ui_root(), "panel_manager", "events", "button_set", "accept_holder", "button_accept");
	
	if uic_button and (uic_button:Visible(true) or not should_highlight) then
		uic_button:Highlight(should_highlight, false, 0);
	end;
end;









-------------------------------------------------------
--	progress on uicomponent animation
--	this polls the animation state of the supplied 
--	uicomponent every 10th of a second, so it's not
--	going to trigger the moment the uicomponent
--	finishes animating
-------------------------------------------------------

function campaign_manager:progress_on_uicomponent_animation(name, uicomponent, callback, delay, animation_id)
	if not is_string(name) then
		script_error("ERROR: progress_on_uicomponent_animation() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_uicomponent(uicomponent) then
		script_error("ERROR: progress_on_uicomponent_animation() called but supplied uicomponent [" .. tostring(uicomponent) .. "] is not a uicomponent");
		return false;
	end;
	
	if not is_function(callback) then
		script_error("ERROR: progress_on_uicomponent_animation() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;

	delay = delay or 0;
	
	if not is_number(delay) or delay < 0 then
		script_error("ERROR: progress_on_uicomponent_animation() called but supplied delay [" .. tostring(delay) .. "] is not a positive number or nil");
		return false;
	end;
	
	animation_id = animation_id or "";
	
	if not is_string(animation_id) then
		script_error("ERROR: progress_on_uicomponent_animation() called but supplied animation id [" .. tostring(animation_id) .. "] is not a string or nil");
		return false;
	end;
	
	self:repeat_callback(
		function()
			if uicomponent:CurrentAnimationId() == animation_id then
				self:remove_callback("progress_on_uicomponent_animation_" .. name);
				
				if delay then
					self:callback(callback, delay, "progress_on_uicomponent_animation_" .. name);
				else
					callback();
				end;
			end;
		end,
		0.1,
		"progress_on_uicomponent_animation_" .. name
	);
end;


function campaign_manager:cancel_progress_on_uicomponent_animation(name)
	self:remove_callback("progress_on_uicomponent_animation_" .. name);
end;










-------------------------------------------------------
--	advice navigation listener
-------------------------------------------------------

-- cancels infotext if advice is navigated
function campaign_manager:start_advice_navigation_listener()
	core:add_listener(
		"advice_navigation_listener",
		"ComponentLClickUp",
		function(context) return context.string == "button_previous" or context.string == "button_next" end,
		function(context) self.infotext:cancel_add_infotext() end,
		true
	);
end;


function campaign_manager:stop_advice_navigation_listener()
	core:remove_listener("advice_navigation_listener");
end;









-------------------------------------------------------
--	progress on loading screen dismissed
-------------------------------------------------------

function campaign_manager:progress_on_loading_screen_dismissed(callback)
	core:progress_on_loading_screen_dismissed(callback);
end;




-------------------------------------------------------
--	progress on loading screen dismissed
-------------------------------------------------------

function campaign_manager:start_intro_cutscene_on_loading_screen_dismissed(callback, fade_in_duration)
	if not is_function(callback) then
		script_error("ERROR: start_intro_cutscene_on_loading_screen_dismissed() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	fade_in_duration = fade_in_duration or 1;
	
	if not is_number(fade_in_duration) or fade_in_duration < 0 then
		script_error("ERROR: start_intro_cutscene_on_loading_screen_dismissed() called but supplied fade in duration [" .. tostring(fade_in_duration) .. "] is not a positive number or nil");
		return false;
	end;

	if not self:can_modify() then
		script_error("ERROR: start_intro_cutscene_on_loading_screen_dismissed() called but we have no modify interface.");
		return false;
	end;
	
	CampaignUI.ToggleCinematicBorders(true);
	self:modify_scripting():fade_scene(0, 0);
	
	-- Wait one second after the loading screen has been dimissed before starting
	-- the fade in. Steal the escape key for this short period.
	core:progress_on_loading_screen_dismissed(
		function()
			self:steal_escape_key(true);
			cm:callback(
				function()
					self:steal_escape_key(false);
					self:modify_scripting():fade_scene(1, fade_in_duration);
					callback();
				end, 
				1
			);
		end
	);
end;



-------------------------------------------------------
--	progress on mission accepted
-------------------------------------------------------



function campaign_manager:progress_on_mission_accepted(callback, delay, should_lock)
	if not is_function(callback) then
		script_error("ERROR: progress_on_mission_accepted() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	local uim = self:get_campaign_ui_manager();
	
	should_lock = not not should_lock;	
	self.ui_locked_for_mission = should_lock;
	
	-- we should lock out elements of the ui so that the player is compelled to accept the mission
	if should_lock then
		uim:lock_ui();
	end;
	
	local callback_func = function()
		if should_lock then
			uim:unlock_ui();
		end;
		callback();
	end;

	core:add_listener(
		"progress_on_mission_accepted",
		"ScriptEventPanelClosedCampaign", 
		function(context) return context.string == "events" or context.string == "quest_details" end,
		function()
			core:remove_listener("progress_on_mission_accepted");
			
			self.ui_locked_for_mission = false;
			
			if is_number(delay) and delay > 0 then
				self:callback(callback_func, delay);
			else
				callback_func();
			end;
		end,
		false
	);
end;


function campaign_manager:cancel_progress_on_mission_accepted()
	if self.ui_locked_for_mission then
		self:get_campaign_ui_manager():unlock_ui();
	end;
	
	core:remove_listener("progress_on_mission_accepted");
end;











-------------------------------------------------------
--	progress on battle completion
-------------------------------------------------------


function campaign_manager:is_processing_battle()
	return self.processing_battle or self.processing_battle_completing;
end;


-- warning, if called at the wrong time this function could lock the game
function campaign_manager:progress_on_battle_completed(name, callback, delay)
	delay = delay or 0;
	
	if not is_string(name) then
		script_error("ERROR: progress_on_battle_completed() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	if not is_function(callback) then
		script_error("ERROR: progress_on_battle_completed() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	if self:is_processing_battle() then
		core:add_listener(
			"progress_on_battle_completed_" .. name,
			"ScriptEventPlayerBattleCompletedSP",
			true,
			function(context)
				self:callback(function() callback() end, delay);
			end,
			false		
		);
	else
		if delay > 0 then
			self:callback(function() callback() end, delay, "progress_on_battle_completed_" .. name);
		else
			callback();
		end;			
	end;
end;


function campaign_manager:cancel_progress_on_battle_completed(name)
	if not is_string(name) then
		script_error("ERROR: cancel_progress_on_battle_completed() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	core:remove_listener("progress_on_battle_completed_" .. name);
	self:remove_callback("progress_on_battle_completed_" .. name);
end;






-------------------------------------------------------
--	progress on camera movement finished
--	mainly for progress_on_battle_completed, but can
--	be used for other contexts too
-------------------------------------------------------

function campaign_manager:progress_on_camera_movement_finished(callback, delay)
	delay = delay or 0;

	if not is_function(callback) then
		script_error("ERROR: progress_on_camera_movement_finished() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	output("progress_on_camera_movement_finished() called");
	
	local x, y, d, b, h = self:get_camera_position();
		
	self:repeat_callback(
		function()
			local new_x, new_y, new_d, new_b, new_h = self:get_camera_position();
			
			if math.abs(x - new_x) < 0.1 and
						math.abs(y - new_y) < 0.1 and
						math.abs(d - new_d) < 0.1 and
						math.abs(b - new_b) < 0.1 and
						math.abs(h - new_h) < 0.1 then
				
				-- camera pos matches, the camera movement is finished
				if delay then
					self:remove_callback("progress_on_camera_movement_finished");
					self:callback(function() callback() end, delay, "progress_on_camera_movement_finished");
				else
					self:remove_callback("progress_on_camera_movement_finished");
					callback();
				end;
			else
				-- camera pos doesn't match
				x = new_x;
				y = new_y;
				d = new_d;
				b = new_b;
				h = new_h;
			end
		end,
		0.2,
		"progress_on_camera_movement_finished"
	);
end;


function campaign_manager:cancel_progress_on_camera_movement_finished()
	self:remove_callback("progress_on_camera_movement_finished");
end;


-------------------------------------------------------
--	progress on player turn
--	calls its callback when it's the player's turn
-------------------------------------------------------

function campaign_manager:progress_on_faction_turn_start(faction_name, callback)
	if not is_string(faction_name) then
		script_error("ERROR: progress_on_faction_turn_start() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;

	if not is_function(callback) then
		script_error("ERROR: progress_on_faction_turn_start() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	-- if it's this faction's turn already, proceed
	if self:get_faction_currently_processing() == faction_name then
		output("progress_on_faction_turn_start() called and it's already the supplied faction's turn [" .. faction_name .. "], proceeding");
		callback();
		return;
	end;
	
	-- otherwise, listen for them starting a turn
	core:add_listener(
		"progress_on_players_turn",
		"FactionTurnStart",
		function(context) return context:faction():name() == faction_name end,
		function()
			output("progress_on_faction_turn_start() is proceeding as it's the supplied faction's turn [" .. faction_name .. "]");
			callback();
		end,
		false
	);
end;


function campaign_manager:cancel_progress_on_faction_turn_start()
	self:remove_callback("progress_on_players_turn");
end;





-------------------------------------------------------
--	progress on post-battle-panel
--	calls its callback when the post-battle panel
--	is fully visible
-------------------------------------------------------

function campaign_manager:progress_on_post_battle_panel_visible(callback, delay)

	local uic_panel = find_uicomponent(core:get_ui_root(), "post_battle_screen", "mid");

	if uic_panel and uic_panel:Visible(true) and is_fully_onscreen(uic_panel) and uic_panel:CurrentAnimationId() == "" then		
		
		if delay and is_number(delay) and delay > 0 then
			self:callback(callback, delay, "progress_on_post_battle_panel_visible");
		else
			callback();
		end;
	else
		self:callback(
			function()
				self:progress_on_post_battle_panel_visible(callback, delay)
			end,
			0.2, 
			"progress_on_post_battle_panel_visible"
		);
	end;
end;











-----------------------------------------------------------------------------
-- turn manager
-----------------------------------------------------------------------------



function campaign_manager:start_turn_manager()
	if self.turn_manager_started then
		return;
	end;
	
	self.turn_manager_started = true;

	self.turn_start_callback_list = {};
	self.turn_end_callback_list = {};
	
	core:add_listener(
		"campaign_manager_on_turn_start",
		"FactionBeginTurnPhaseNormal",
		true,
		function(context) self:on_turn_start(context) end,
		true
	);
	
	core:add_listener(
		"campaign_manager_on_turn_end",
		"FactionTurnEnd",
		true,
		function(context) self:on_turn_end(context) end,
		true
	);
end;


function campaign_manager:on_turn_start(context)
	local callbacks_to_call = {};
	
	local i = 1;
	
	while i <= #self.turn_start_callback_list do
		local current_callback = self.turn_start_callback_list[i];
		
		if current_callback.condition(context) then
			table.insert(callbacks_to_call, current_callback.callback);
			
			if not current_callback.should_repeat then
				table.remove(self.turn_start_callback_list, i);
			else
				i = i + 1;
			end;
		else
			i = i + 1;
		end;
	end;
	
	if #callbacks_to_call > 0 then
		for i = 1, #callbacks_to_call do
			callbacks_to_call[i](context);
		end;
	elseif is_function(self.default_turn_start_callback) and not context:faction():is_human() then
		self.default_turn_start_callback(context);
	end;

end;


function campaign_manager:on_turn_end(context)
	local callbacks_to_call = {};
	
	local i = 1;
	
	while i <= #self.turn_end_callback_list do
		local current_callback = self.turn_end_callback_list[i];
		
		if current_callback.condition(context) then
			table.insert(callbacks_to_call, current_callback.callback);
			
			if not current_callback.should_repeat then
				table.remove(self.turn_end_callback_list, i);
			else
				i = i + 1;
			end;
		else
			i = i + 1;
		end;
	end;
	
	if #callbacks_to_call > 0 then
		for i = 1, #callbacks_to_call do
			callbacks_to_call[i]();
		end;
	elseif is_function(self.default_turn_end_callback) then
		self.default_turn_callback(context);
	end;
end;


function campaign_manager:set_default_turn_start_callback(callback)
	if not is_function(callback) and not is_nil(callback) then
		script_error("campaign_manager ERROR:: set_default_turn_start_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function or nil");
		return false;
	end;
	
	-- start turn manager if it hasn't been already
	self:start_turn_manager();
	
	self.default_turn_start_callback = callback;
end;


function campaign_manager:add_turn_start_callback(new_name, new_condition, new_callback, new_should_repeat)
	if not is_string(new_name) then
		script_error("campaign_manager ERROR: add_turn_start_callback() called but supplied name [" .. tostring(new_name) .. "] is not a string");
		return false;
	end;
	
	if not is_function(new_condition) then
		script_error("campaign_manager ERROR: add_turn_start_callback() called but supplied condition [" .. tostring(new_condition) .. "] is not a function");
		return false;
	end;
	
	if not is_function(new_callback) then
		script_error("campaign_manager ERROR: add_turn_start_callback() called but supplied callback [" .. tostring(new_callback) .. "] is not a function");
		return false;
	end;
	
	new_should_repeat = new_should_repeat or false;
	
	-- start turn manager if it hasn't been already
	self:start_turn_manager();
	
	local new_turn_start_callback = {
		name = new_name,
		condition = new_condition,
		callback = new_callback,
		should_repeat = new_should_repeat
	};
	
	table.insert(self.turn_start_callback_list, new_turn_start_callback);
end;


function campaign_manager:add_turn_start_callback_for_faction(name, faction_name, callback, should_repeat)
	if not is_string(faction_name) then
		script_error("campaign_manager ERROR: add_turn_start_callback_for_faction() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;

	local condition = function(context)
		return context:faction():name() == faction_name;
	end;
	
	self:add_turn_start_callback(name, condition, callback, should_repeat);
end;


function campaign_manager:remove_turn_start_callback(name)
	for i = 1, #self.turn_start_callback_list do
		local current_callback = self.turn_start_callback_list[i];
		
		if current_callback.name == name then
			table.remove(self.turn_start_callback_list, i);
			self:remove_turn_start_callback(name);
			return;
		end;
	end;
end;


function campaign_manager:clear_turn_start_callbacks()
	self.turn_start_callback_list = {};
end;


function campaign_manager:set_default_turn_end_callback(callback)
	if not is_function(callback) and not is_nil(callback) then
		script_error("campaign_manager ERROR:: set_default_turn_end_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function or nil");
		return false;
	end;
	
	-- start turn manager if it hasn't been already
	self:start_turn_manager();
	
	self.default_turn_end_callback = callback;
end;


function campaign_manager:add_turn_end_callback(new_name, new_condition, new_callback, new_should_repeat)
	if not is_string(new_name) then
		script_error("campaign_manager ERROR: add_turn_end_callback() called but supplied name [" .. tostring(new_name) .. "] is not a string");
		return false;
	end;
	
	if not is_function(new_condition) then
		script_error("campaign_manager ERROR: add_turn_end_callback() called but supplied condition [" .. tostring(new_condition) .. "] is not a function");
		return false;
	end;
	
	if not is_function(new_callback) then
		script_error("campaign_manager ERROR: add_turn_end_callback() called but supplied callback [" .. tostring(new_callback) .. "] is not a function");
		return false;
	end;
	
	new_should_repeat = new_should_repeat or false;
	
	-- start turn manager if it hasn't been already
	self:start_turn_manager();
	
	local new_turn_end_callback = {
		name = new_name,
		condition = new_condition,
		callback = new_callback,
		should_repeat = new_should_repeat
	};
	
	table.insert(self.turn_end_callback_list, new_turn_end_callback);
end;


function campaign_manager:add_turn_end_callback_for_faction(name, faction_name, callback, should_repeat)
	if not is_string(faction_name) then
		script_error("campaign_manager ERROR: add_turn_end_callback_for_faction() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;

	local condition = function(context)
		return context:faction():name() == faction_name;
	end;
	
	self:add_turn_end_callback(name, condition, callback, should_repeat);
end;


function campaign_manager:remove_turn_end_callback(name)
	for i = 1, #self.turn_end_callback_list do
	
		local current_callback = self.turn_end_callback_list[i];
		
		if current_callback.name == name then
			table.remove(self.turn_end_callback_list, i);
			self:remove_turn_end_callback(name);
			return;
		end;
	end;
end;


function campaign_manager:clear_turn_end_callbacks()
	self.turn_end_callback_list = {};
end;




















-----------------------------------------------------------------------------
-- quit()
-- immediately exits to the frontend
-----------------------------------------------------------------------------


function campaign_manager:quit()
	out("campaign_manager:quit() called");
	
	self:dismiss_advice();

	self:callback(
		function()
			self:steal_user_input(true);
			interface_function(core:get_ui_root(), "QuitForScript");
		end,
		1
	);
end;


-----------------------------------------------------------------------------
-- create_force override - outputs to console, and attempts to verify that
-- the force was actually created
-----------------------------------------------------------------------------

function campaign_manager:create_force(faction_key, unit_list, region_key, x, y, id, exclude_named_characters, success_callback)
	if not is_string(faction_key) then
		script_error("ERROR: create_force() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: create_force() called but no faction with supplied key [" .. faction_key .. "] was found");
		return;
	end;
	
	if not is_string(unit_list) then
		script_error("ERROR: create_force() called but supplied unit list [" .. tostring(unit_list) .. "] is not a string");
		return;
	end;
	
	if unit_list == "" then
		script_error("ERROR: create_force() called but supplied unit list [" .. tostring(unit_list) .. "] is an empty string");
		return;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: create_force() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: create_force() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: create_force() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	if not is_string(id) then
		script_error("ERROR: create_force() called but supplied id [" .. tostring(id) .. "] is not a string");
		return;
	end;
	
	if not is_boolean(exclude_named_characters) then
		script_error("ERROR: create_force() called but supplied exclude named characters switch [" .. tostring(exclude_named_characters) .. "] is not a boolean value");	
		return;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: create_force() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	local listener_name = "campaign_manager_create_force_" .. id;
	
	output("create_force() called:");
	inc_tab();
	
	output("faction_key: " .. faction_key);
	output("unit_list: " .. unit_list);
	output("region_key: " .. region_key);
	output("x: " .. tostring(x));
	output("y: " .. tostring(y));
	output("id: " .. id);
	output("exclude_named_characters: " .. tostring(exclude_named_characters));
	
	dec_tab();
	
	-- make the call to create the force
	self:modify_faction(faction_key):create_force(unit_list, region_key, x, y, id, exclude_named_characters);
	
	return self:force_created(id, listener_name, faction_key, x, y, success_callback);
end;


-----------------------------------------------------------------------------
-- create_force_with_general override - outputs to console, and attempts to verify that
-- the force was actually created
-----------------------------------------------------------------------------

function campaign_manager:create_force_with_general(faction_key, unit_list, region_key, x, y, agent_type, agent_subtype, character_template_key, id, make_faction_leader, success_callback)
	if not is_string(faction_key) then
		script_error("ERROR: create_force_with_general() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: create_force_with_general() called but no faction with supplied key [" .. faction_key .. "] was found");
		return;
	end;
	
	if not is_string(unit_list) then
		script_error("ERROR: create_force_with_general() called but supplied unit list [" .. tostring(unit_list) .. "] is not a string");
		return;
	end;
	
	if unit_list == "" then
		script_error("ERROR: create_force() called but supplied unit list [" .. tostring(unit_list) .. "] is an empty string");
		return;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: create_force_with_general() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: create_force_with_general() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: create_force_with_general() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	if not is_string(agent_type) then
		script_error("ERROR: create_force_with_general() called but supplied agent_type [" .. tostring(agent_type) .. "] is not a string");
		return;
	end;
	
	if not is_string(agent_subtype) then
		script_error("ERROR: create_force_with_general() called but supplied agent_subtype [" .. tostring(agent_subtype) .. "] is not a string");
		return;
	end;
	
	if not is_string(character_template_key) then
		script_error("ERROR: create_force_with_general() called but supplied character template key [" .. tostring(character_template_key) .. "] is not a string");
		return;
	end;
	
	if not is_string(id) then
		script_error("ERROR: create_force_with_general() called but supplied id [" .. tostring(id) .. "] is not a string");
		return;
	end;

	if not is_boolean(make_faction_leader) then
		script_error("ERROR: create_force() called but supplied make faction leader switch [" .. tostring(make_faction_leader) .. "] is not a boolean value");
		return;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: create_force_with_general() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	local listener_name = "campaign_manager_create_force_" .. id;
	
	core:add_listener(
		listener_name,
		"ScriptedForceCreated",
		true,
		function() self:force_created(id, listener_name, faction_key, x, y, success_callback) end,
		true
	);
	
	output("create_force_with_general() called:");
	inc_tab();
	
	output("faction_key: " .. faction_key);
	output("unit_list: " .. unit_list);
	output("region_key: " .. region_key);
	output("x: " .. tostring(x));
	output("y: " .. tostring(y));
	output("agent_type: " .. agent_type);
	output("agent_subtype: " .. agent_subtype);
	output("character_template_key: " .. character_template_key);
	output("id: " .. id);
	output("make_faction_leader: " .. tostring(make_faction_leader));
	
	dec_tab();
	
	-- make the call to create the force
	self:modify_faction(faction_key):create_force_with_general(unit_list, region_key, x, y, agent_type, agent_subtype, character_template_key, id, make_faction_leader);
end;


-----------------------------------------------------------------------------
-- create_force_with_existing_general override - outputs to console, and attempts to verify that
-- the force was actually created
-----------------------------------------------------------------------------

function campaign_manager:create_force_with_existing_general(char_str, faction_key, unit_list, region_key, x, y, id, success_callback)
	if not is_string(char_str) then
		script_error("ERROR: create_force_with_existing_general() called but supplied character string [" .. tostring(char_str) .. "] is not a string");
		return;
	end;
	
	if not is_string(faction_key) then
		script_error("ERROR: create_force_with_existing_general() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: create_force_with_existing_general() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return;
	end;
	
	if not is_string(unit_list) then
		script_error("ERROR: create_force_with_existing_general() called but supplied unit list [" .. tostring(unit_list) .. "] is not a string");
		return;
	end;
	
	if unit_list == "" then
		script_error("ERROR: create_force() called but supplied unit list [" .. tostring(unit_list) .. "] is an empty string");
		return;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: create_force_with_existing_general() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: create_force_with_existing_general() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: create_force_with_existing_general() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	if not is_string(id) then
		script_error("ERROR: create_force_with_existing_general() called but supplied id [" .. tostring(id) .. "] is not a string");
		return;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: create_force_with_existing_general() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	local listener_name = "campaign_manager_create_force_" .. id;
	
	core:add_listener(
		listener_name,
		"ScriptedForceCreated",
		true,
		function() self:force_created(id, listener_name, faction_key, x, y, success_callback) end,
		true
	);
	
	output("create_force_with_existing_general() called:");
	inc_tab();
	
	output("char_str: " .. char_str);
	output("faction_key: " .. faction_key);
	output("unit_list: " .. unit_list);
	output("region_key: " .. region_key);
	output("x: " .. tostring(x));
	output("y: " .. tostring(y));
	output("id: " .. id);
	
	dec_tab();
	
	-- make the call to create the force
	self:modify_faction(faction_key):create_force_with_existing_general(char_str, unit_list, region_key, x, y, id);
end;


-- called by create_force() when a force has been created, either directly (if the force was not created via the command queue) or
-- via the ScriptedForceCreated event (if the force was created via the command queue). This attempts to find the newly-created character
-- and returns its cqi to the calling code. Multiple instances of this listener could be running at the time a ScriptedForceCreated event
-- has occurred, so if this function can't find the force it's looking for chances are there are a load being spawned at once and that
-- the relevant one will be along in a bit.
function campaign_manager:force_created(id, listener_name, faction_key, x, y, success_callback)
	if not is_function(success_callback) then
		return;
	end;
	
	-- find the cqi of the force just created
	local character_list = self:query_faction(faction_key):character_list();
	
	for i = 0, character_list:num_items() - 1 do
		local char = character_list:item_at(i);
		
		if char:logical_position_x() == x and char:logical_position_y() == y then
			
			if char:has_military_force() and char:military_force():has_general() then
				-- we have found it, remove this listener, call the success callback with the character cqi as parameter and exit
				core:remove_listener(listener_name);
				
				local cqi = char:cqi();
				success_callback(cqi);
				return cqi;
			end;
		end;
	end;
	
	return false;
end;


-----------------------------------------------------------------------------
-- create_agent override - outputs to console
-----------------------------------------------------------------------------

function campaign_manager:create_agent(faction_key, agent_key, subtype_key, x, y, id, character_template_key, success_callback)
	if not is_string(faction_key) then
		script_error("ERROR: create_agent() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not is_string(agent_key) then
		script_error("ERROR: create_agent() called but supplied agent key [" .. tostring(agent_key) .. "] is not a string");
		return;
	end;
	
	if not is_string(subtype_key) then
		script_error("ERROR: create_agent() called but supplied agent subtype key [" .. tostring(subtype_key) .. "] is not a string");
		return;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: create_agent() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: create_agent() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	if not is_string(id) then
		script_error("ERROR: create_agent() called but supplied id [" .. tostring(id) .. "] is not a string");
		return;
	end;
	
	if not is_string(character_template_key) then
		script_error("ERROR: create_agent() called but supplied character template key [" .. tostring(character_template_key) .. "] is not a string");
		return;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: create_agent() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	output("create_agent() called:");
	inc_tab();
	
	output("faction_key: " .. faction_key);
	output("agent_key: " .. agent_key);
	output("subtype_key: " .. subtype_key);
	output("x: " .. tostring(x));
	output("y: " .. tostring(y));
	output("id: " .. id);
	out("character template key: " .. character_template_key);
	
	dec_tab();
	
	-- make the call to create the agent
	self:modify_faction(faction_key):create_agent(agent_key, subtype_key, x, y, id, character_template_key);
	
	return self:agent_created(id, faction_key, x, y, success_callback);
end;


-- called by create_agent() when an agent has been created, either directly (if the agent was not created via the command queue) or
-- via the ScriptedAgentCreated event (if the agent was created via the command queue). This attempts to find the newly-created character
-- and returns its cqi to the calling code. Multiple instances of this listener could be running at the time a ScriptedAgentCreated event
-- has occurred, so if this function can't find the agent it's looking for chances are there are a load being spawned at once and that
-- the relevant one will be along in a bit.
function campaign_manager:agent_created(id, faction_key, x, y, success_callback)	
	if not is_function(success_callback) then
		return;
	end;
	
	-- find the cqi of the agent just created
	local character_list = self:query_faction(faction_key):character_list();
	
	for i = 0, character_list:num_items() - 1 do
		local char = character_list:item_at(i);
		
		if char:logical_position_x() == x and char:logical_position_y() == y then
			
			if char:character_type("champion") or char:character_type("dignitary") or char:character_type("spy") or char:character_type("engineer") or char:character_type("wizard") or char:character_type("runesmith") then
				-- we have found it, remove this listener, call the success callback with the character cqi as parameter and exit
				
				local cqi = char:cqi();
				success_callback(cqi);
				return cqi;
			end;
		end;
	end;
	
	return false;
end;






-----------------------------------------------------------------------------
-- output wrappers for apply_effect_bundle and friends
-----------------------------------------------------------------------------

function campaign_manager:apply_effect_bundle(bundle_key, faction_key, turns)
	if not is_string(bundle_key) then
		script_error("ERROR: apply_effect_bundle() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(faction_key) then
		script_error("ERROR: apply_effect_bundle() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: apply_effect_bundle() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;
	
	if not is_number(turns) then
		script_error("ERROR: apply_effect_bundle() called but supplied turn count [" .. tostring(turns) .. "] is not a number");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	out(" & Applying effect bundle [" .. bundle_key .. "] to faction [" .. faction_key .. "] for [" .. turns .. "] turns");
	
	return self:modify_faction(faction_key):apply_effect_bundle(bundle_key, turns);
end;


function campaign_manager:remove_effect_bundle(bundle_key, faction_name)
	if not is_string(bundle_key) then
		script_error("ERROR: remove_effect_bundle() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(faction_name) then
		script_error("ERROR: remove_effect_bundle() called but supplied faction key [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: remove_effect_bundle() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	out(" & Removing effect bundle [" .. bundle_key .. "] from faction [" .. faction_name .. "]");
	
	return self:modify_faction(faction_key):remove_effect_bundle(bundle_key);
end;


function campaign_manager:apply_effect_bundle_to_region(bundle_key, region_key, turns)
	if not is_string(bundle_key) then
		script_error("ERROR: apply_effect_bundle_to_region() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: apply_effect_bundle_to_region() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return false;
	end;
	
	if not self:region_exists(region_key) then
		script_error("ERROR: apply_effect_bundle_to_region() called but no region with supplied key [" .. tostring(region_key) .. "] could be found");
		return false;
	end;
	
	if not is_number(turns) then
		script_error("ERROR: apply_effect_bundle_to_region() called but supplied turn count [" .. tostring(turns) .. "] is not a number");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	out(" & Applying effect bundle [" .. bundle_key .. "] to region with key [" .. region_key .. "] for [" .. turns .. "] turns");
	
	self:modify_region(region_key):apply_effect_bundle(bundle_key, turns);
end;


function campaign_manager:remove_effect_bundle_from_region(bundle_key, region_key)
	if not is_string(bundle_key) then
		script_error("ERROR: remove_effect_bundle_from_region() called but supplied bundle key [" .. tostring(bundle_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(region_key) then
		script_error("ERROR: remove_effect_bundle_from_region() called but supplied region key [" .. tostring(region_key) .. "] is not a string");
		return false;
	end;
	
	if not self:region_exists(region_key) then
		script_error("ERROR: remove_effect_bundle_from_region() called but no region with supplied key [" .. tostring(region_key) .. "] could be found");
		return false;
	end;

	if not self:can_modify() then
		return;
	end;
	
	out(" & Removing effect bundle [" .. bundle_key .. "] from region with key [" .. region_key .. "]");
	
	self:modify_region(region_key):remove_effect_bundle(bundle_key);
end;





-----------------------------------------------------------------------------
-- co-ordinate conversion
-----------------------------------------------------------------------------

function campaign_manager:log_to_dis(x, y)
	if not is_number(x) or x < 0 then
		script_error("ERROR: log_to_dis() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: log_to_dis() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return;
	end;
	
	local display_x = x * 678.5 / 1016;
	local display_y = y * 555.37 / 720;
	
	return display_x, display_y;
end;





-----------------------------------------------------------------------------
--	lift_all_shroud
--	lifts the shroud on all regions. For use in in-game camera-pans. Restore
--	the shroud by taking a snapshot beforehand and restoring it afterwards.
-----------------------------------------------------------------------------

function campaign_manager:lift_all_shroud()

	if not self:can_modify() then
		return;
	end;

	local region_list = self:query_model():world():region_manager():region_list();
	
	local modify_faction = self:modify_faction(self:get_local_faction());
	
	if modify_faction then
		for i = 0, region_list:num_items() - 1 do
			local current_region = region_list:item_at(i);
			
			modify_faction:make_region_visible_in_shroud(current_region:name());
		end;
	end;
end;






-----------------------------------------------------------------------------
-- random number wrapper
-----------------------------------------------------------------------------

function campaign_manager:random_number(max_num, min_num)
	if not self:can_modify() then
		return;
	end;

	if is_nil(max_num) then
		max_num = 100;
	end;
	
	if is_nil(min_num) then
		min_num = 1;
	end;
	
	if not is_number(max_num) or math.floor(max_num) < max_num then
		script_error("random_number ERROR: supplied max number [" .. tostring(max_num) .. "] is not a valid integer");
		return 0;
	end;
	
	if max_num == min_num then
		return max_num;
	end;
	
	-- ask modify model for a random number. Note the switched parameters.
	return self:modify_model():random_number(min_num, max_num);
end;





-----------------------------------------------------------------------------
-- roll chance
-- Takes a value and rolls against it.
-----------------------------------------------------------------------------

function campaign_manager:roll_random_chance( chance, is_debug )
	is_debug = is_debug or false;
	
	local success = false;

	if not self:can_modify() then
		script_error( "Rolling random chance while no modify interface is present. Will return false." );
		return false;
	end;

	local roll = self:modify_model():random_percentage();

	if chance >= roll then -- Check for success here.
		success = true;
	end;

	if is_debug then
		--output( "roll_random_chance: Roll(" .. roll .. ") >= Chance(" .. chance .. ") = " .. tostring(success) );
	end;

	return success;
end;





-----------------------------------------------------------------------------
-- random sort
-- this is safe to use in multiplayer, as long as the
-- rest of the script is deterministic
-----------------------------------------------------------------------------

function campaign_manager:random_sort(t)
	local retval = {};
	local table_size = #t;
	local n = 0;
				
	for i = 1, table_size do
			
		-- pick an entry from t, add it to retval, then remove it from t
		n = self:random_number(#t);
						
		table.insert(retval, t[n]);
		table.remove(t, n);
	end;
	
	return retval;
end;
















----------------------------------------------------------------------------
--	Restricting units, buildings and technologies
----------------------------------------------------------------------------

--	restrict_units_for_faction
--	supply a string faction name, a table of unit keys to restrict and a boolean
--	switch specifying whether to restrict them or not.
--	WARNING: due to a code bug this function is unreliable. Do not use with units
--	that can either be upgraded to or can be upgraded from.
function campaign_manager:restrict_units_for_faction(faction_key, unit_list, value)	
	if not is_string(faction_key) then
		script_error("ERROR: restrict_units_for_faction() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not is_table(unit_list) then
		script_error("ERROR: restrict_units_for_faction() called but supplied unit_list [" .. tostring(unit_list) .. "] is not a table");
		return;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	local modify_faction = self:modify_faction(faction_key);
	
	if not modify_faction then
		script_error("ERROR: restrict_units_for_faction() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;
	
	if value then
		for i = 1, #unit_list do
			local current_unit = unit_list[i];
			modify_faction:add_event_restricted_unit_record(current_unit);
		end;
		out("restricted " .. tostring(#unit_list) .. " unit records for faction " .. faction_key);
	else
		for i = 1, #unit_list do
			local current_unit = unit_list[i];
			modify_faction:remove_event_restricted_unit_record(current_unit);
		end;
		out("unrestricted " .. tostring(#unit_list) .. " unit records for faction " .. faction_key);
	end;	
end;


--	restrict_buildings_for_faction
--	supply a string faction name, a table of building keys and a boolean switch
--	specifying whether to apply the restriction or lift it.
function campaign_manager:restrict_buildings_for_faction(faction_key, building_list, value)
	if not is_string(faction_key) then
		script_error("ERROR: restrict_buildings_for_faction() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not is_table(building_list) then
		script_error("ERROR: restrict_buildings_for_faction() called but supplied building_list [" .. tostring(building_list) .. "] is not a table");
		return;
	end;
	
	
	if not self:can_modify() then
		return;
	end;
	
	local modify_faction = self:modify_faction(faction_key);
	
	if not modify_faction then
		script_error("ERROR: restrict_buildings_for_faction() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;
	
	if value then
		for i = 1, #building_list do
			local current_building = building_list[i];
		
			modify_faction:add_event_restricted_building_record(current_building);
		end;
		output("restricted " .. tostring(#building_list) .. " building records for faction " .. faction_key);
	else
		for i = 1, #building_list do
			local current_building = building_list[i];
		
			modify_faction:remove_event_restricted_building_record(current_building);
		end;
		output("unrestricted " .. tostring(#building_list) .. " building records for faction " .. faction_key);
	end;
end;


--	restrict_technologies_for_faction
--	supply a string faction name, a table of tech keys and a boolean switch
--	specifying whether to apply the restriction or lift it.
function campaign_manager:restrict_technologies_for_faction(faction_key, tech_list, value)
	if not is_string(faction_key) then
		script_error("ERROR: restrict_technologies_for_faction() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return;
	end;
	
	if not is_table(tech_list) then
		script_error("ERROR: restrict_technologies_for_faction() called but supplied tech_list [" .. tostring(tech_list) .. "] is not a table");
		return;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	local modify_faction = self:modify_faction(faction_key);
	
	if not modify_faction then
		script_error("ERROR: restrict_technologies_for_faction() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;
	
	if value then
		for i = 1, #tech_list do
			local current_technology = tech_list[i];
		
			modify_faction:lock_technology(current_technology);
		end;
		out("restricted " .. tostring(#tech_list) .. " tech records for faction " .. faction_key);
	else
		for i = 1, #tech_list do
			local current_technology = tech_list[i];
			
			modify_faction:unlock_technology(current_technology);
		end;
		out("unrestricted " .. tostring(#tech_list) .. " tech records for faction " .. faction_key);
	end;
end;

















----------------------------------------------------------------------------
--	Restricting diplomacy
----------------------------------------------------------------------------

campaign_manager.diplomacy_types = {
	["trade agreement"] = 2^0,
	["hard military access"] = 2^1,
	["cancel hard military access"] = 2^2,
	["military alliance"] = 2^3,
	["regions"] = 2^4,
	["technology"] = 2^5,
	["state gift"] = 2^6,
	["payments"] = 2^7,
	["vassal"] = 2^8,
	["peace"] = 2^9,
	["war"] = 2^10,
	["join war"] = 2^11,
	["break trade"] = 2^12,
	["break alliance"] = 2^13,
	["hostages"] = 2^14,
	["marriage"] = 2^15,
	["non aggression pact"] = 2^16,
	["soft military access"] = 2^17,
	["cancel soft military access"] = 2^18,
	["defensive alliance"] = 2^19,
	["client state"] = 2^20,
	["form confederation"] = 2^21,
	["break non aggression pact"] = 2^22,
	["break soft military access"] = 2^23,
	["break defensive alliance"] = 2^24,
	["break vassal"] = 2^25,
	["break client state"] = 2^26,
	["state gift unilateral"] = 2^27--[[,
	["all"] = (2^28 - 1)
]]
};


function campaign_manager:generated_diplomacy_bitmask(str)
	if not is_string(str) then
		script_error("ERROR: generate_diplomacy_bitmask() called but supplied diplomacy string [" .. tostring(str) .. "] is not a string");
		return 0;
	end;
	
	if string.len(str) == 0 then
		return 0;
	end;
	
	-- specifically allow a token of "all"
	if str == "all" then
		return self.diplomacy_types["all"];
	end;
	
	local tokens = {};
	
	local pointer = 1;
	
	while true do
		local next_separator = string.find(str, ",", pointer);
		
		if not next_separator then
			-- this is the last token, so exit the loop after storing it
			table.insert(tokens, string.sub(str, pointer));
			break;
		end;
		
		table.insert(tokens, string.sub(str, pointer, next_separator - 1));
		
		pointer = next_separator + 1;
	end;
	
	local bitmask = 0;
	
	for i = 1, #tokens do
		local current_token = tokens[i];
		
		if current_token == "all" then
			-- combining "all" with other token types is not allowed
			script_error("WARNING: generate_diplomacy_bitmask() was given a string [" .. str .. "] containing token [" .. current_token .. "] with other tokens - this token can only be used on its own, ignoring");
		else		
			local current_token_value = self.diplomacy_types[current_token];		
			if not current_token_value then
				script_error("WARNING: generate_diplomacy_bitmask() was given a string [" .. str .. "] containing unrecognised token [" .. current_token .. "], ignoring");
			else
				bitmask = bitmask + current_token_value;
			end;
		end;
	end;
	
	return bitmask;
end;



















----------------------------------------------------------------------------
--	Timer Wrapper
--	we don't use a timer_manager in campaign as this system is event
--	driven, the timer_manager uses callbacks.
----------------------------------------------------------------------------


function campaign_manager:set_check_callback_frequency(value)
	if value == false then
		self.check_callback_frequency = false;
	else
		self.check_callback_frequency = true;
	end;
end;


--	adds a repeating callback
function campaign_manager:repeat_callback(new_callback, new_t, new_name)
	self:impl_callback(new_callback, new_t, new_name, true);
end;


--	adds a singleshot callback
function campaign_manager:callback(new_callback, new_t, new_name)
	self:impl_callback(new_callback, new_t, new_name, false);
end;



-- internal callback wrapper. Do not call externally.
function campaign_manager:impl_callback(new_callback, new_t, new_name, is_repeating)
	is_repeating = is_repeating or false;

	if not is_function(new_callback) then
		script_error("callback() called but callback " .. tostring(new_callback) .. " is not a function !!");
		return false;
	end;
	if not is_number(new_t) then
		script_error("callback() called but time value " .. tostring(new_t) .. " is not a number !!");
		return false;
	end;
	
	if self.check_callback_frequency_error_on_callback then
		script_error("WARNING: callback() called with callback [" .. tostring(new_callback) .. "], time [" .. tostring(new_t) .. "] and name [" .. tostring(new_name) .. "] but the check callback frequency test has been failed - there have been " .. self.check_callback_frequency_last_callback_count .. " callbacks in the last " .. self.CHECK_CALLBACK_FREQUENCY_POLL_TIME .. "s which exceeds the given threshold (" .. self.CHECK_CALLBACK_FREQUENCY_CALLBACK_THRESHOLD .. ") - investigate what is generating so many callbacks");
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	if new_t == 0 then
		new_callback();
		return;
	end;
	
	local script_timers = self.script_timers;
	
	-- generate unique id for this call
	local new_id = 0;	
	while script_timers[tostring(new_id)] do
		new_id = new_id + 1;
	end;
	
	new_id = tostring(new_id);
	
	local new_timer = {callback = new_callback, name = new_name, callstack = debug.traceback(), repeating = is_repeating};
	
	-- if the callback is repeated the garbage collector seems to get confused, so force a pass here
	-- collectgarbage(); -- SM: Commenting this out at request of Steve V and Peter E, as this causes a LOT of performance issues.
	
	-- casting 'new_id' to a string, as an integer will cause issues when being passed to the model.
	self:modify_scripting():add_time_trigger(new_id, new_t, is_repeating);
	
	script_timers[new_id] = new_timer;
end;


--	adds an os-clock based callback. This polls the os-clock to determine when the callback should be called. 
--	The timing of this is accurate only to within 0.5 of a second, but it works in situations where the usual
--	script timing breaks down i.e during the end-turn sequence.
function campaign_manager:os_clock_callback(callback, delay, name)
	self:process_os_clock_callback(callback, os.clock() + delay, name)
end;


--	process os-clock callbacks, for internal use only
function campaign_manager:process_os_clock_callback(callback, end_time, name)
	if os.clock() >= end_time then
		callback();
	else
		self:callback(function() self:process_os_clock_callback(callback, end_time, name) end, 0.5, name)
	end;
end;


--	removes a callback by name
function campaign_manager:remove_callback(name)
	local script_timers = self.script_timers;
	
	for id, timer_entry in pairs(script_timers) do
		if timer_entry.name == name then
			self:modify_scripting():remove_time_trigger(tostring(id));
			script_timers[id] = nil;
		end;
	end;
end;


--	called by the event system when a timer has triggered. For internal use only
function campaign_manager:check_callbacks(context)
	-- if the check_callback_frequency flag is set then record when this callback has happened and cull any that have happened more than CHECK_CALLBACK_FREQUENCY_POLL_TIME ago
	if self.check_callback_frequency then
		local timestamp = os.clock();
		local check_callback_frequency_timestamps = self.check_callback_frequency_timestamps;
		local check_callback_frequency_poll_time = self.CHECK_CALLBACK_FREQUENCY_POLL_TIME;
	
		-- insert a timestamp record into check_callback_frequency_timestamps for this callback
		table.insert(check_callback_frequency_timestamps, timestamp);
		
		-- remove all records for callbacks that happened more than CHECK_CALLBACK_FREQUENCY_POLL_TIME ago
		while check_callback_frequency_timestamps[1] and check_callback_frequency_timestamps[1] + check_callback_frequency_poll_time < timestamp do
			table.remove(check_callback_frequency_timestamps, 1);
		end;
		
		self.check_callback_frequency_last_callback_count = #check_callback_frequency_timestamps;
		
		if self.check_callback_frequency_last_callback_count >= self.CHECK_CALLBACK_FREQUENCY_CALLBACK_THRESHOLD then
			self.check_callback_frequency_error_on_callback = true;
		else
			self.check_callback_frequency_error_on_callback = false;
		end;
	end;
	
	local timer_entry = self.script_timers[context:id()];
	
	if timer_entry then
		local callback = timer_entry.callback;
		local callstack = timer_entry.callstack;
		if not timer_entry.repeating then -- SM: Remove the timer only if the function isn't repeating.
			self.script_timers[context:id()] = nil;
		end;
		core:monitor_performance(callback, 0.1, callstack);
	end;
end;


--	prints all timers to console
function campaign_manager:dump_timers()
	inc_tab();
	output("Dumping timers, os.clock is " .. tostring(os.clock()));
	inc_tab();
	
	local script_timers = self.script_timers;
	for id, timer_entry in pairs(script_timers) do
		output("id: " .. tostring(id) .. ", name: " .. tostring(timer_entry.name) .. ", callback: " .. tostring(timer_entry.callback));
	end;
	
	dec_tab();
	dec_tab();
end;





















----------------------------------------------------------------------------
--	Army Movement
--	Some functions to assist in moving armies around
----------------------------------------------------------------------------


function campaign_manager:move_npc_army(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback)
		
	if not is_number(char_cqi) and not is_string(char_cqi) then
		script_error("move_npc_army ERROR: cqi provided [" .. tostring(char_cqi) .. "] is not a number or string");
		return false;
	end;
		
	if not is_number(log_x) or log_x < 0 then
		script_error("move_npc_army ERROR: supplied logical x co-ordinate [" .. tostring(log_x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(log_y) or log_y < 0 then
		script_error("move_npc_army ERROR: supplied logical y co-ordinate [" .. tostring(log_x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("move_npc_army ERROR: supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if not is_function(fail_callback) and not is_nil(fail_callback) then
		script_error("move_npc_army ERROR: supplied failure callback [" .. tostring(fail_callback) .. "] is not a function or nil");
		return false;
	end;
	
	inc_tab();
	
	local char_str = char_lookup_str(char_cqi);
	local trigger_name = "move_npc_army_" .. char_str .. "_" .. tostring(self.move_npc_army_trigger_count);
	self.move_npc_army_trigger_count = self.move_npc_army_trigger_count + 1;
	
	local modify_character = self:modify_character(char_cqi);
	
	if should_replenish then
		modify_character:replenish_action_points();
		
		-- listen for the army running out of movement points
		core:add_listener(
			trigger_name,
			"MovementPointsExhausted",
			true,
			function()
				output("move_npc_army() :: MovementPointsExhausted event has occurred, replenishing character action points and moving it to destination");
				local modify_character = self:modify_character(char_cqi);
				modify_character:replenish_action_points();
				modify_character:walk_to(log_x, log_y);
			end,
			true
		);
	end;
	
	output("move_npc_army() moving character (" .. char_str .. ") to [" .. log_x .. ", " .. log_y .. "]");
	
	modify_character:enable_movement();
	modify_character:walk_to(log_x, log_y);
	
	-- add this trigger to the active list, for if we wish to cancel it
	table.insert(self.move_npc_army_active_list, trigger_name);
	
	-- set up this notification to catch the character halting without reaching the destination
	self:notify_on_character_halt(
		char_cqi, 
		function()
			self:move_npc_army_halted(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback, trigger_name) 
		end
	);
	
	local dis_x, dis_y = self:log_to_dis(log_x, log_y)
	
	-- detection trigger
	-- we do this as the AI can take the army and continue marching with it, which evades the other detection method
	self:modify_scripting():add_circle_area_trigger(dis_x, dis_y, 1.5, trigger_name, "character_cqi:" .. char_cqi, true, false, true);
	
	core:add_listener(
		trigger_name,
		"AreaEntered", 
		function(context) return conditions.IsMessageType(trigger_name, context) end,
		function(context) self:move_npc_army_arrived(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback, trigger_name) end, 
		false
	);
	
	dec_tab();
end;


--	a character moved by move_npc_army has finished moving for some reason
function campaign_manager:move_npc_army_halted(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback, trigger_name)
	
	self:stop_notify_on_character_halt(char_cqi);
	core:remove_listener(trigger_name);
	
	local character = self:query_character(char_cqi);
	
	if not character then
		script_error("ERROR: move_npc_army_halted() called but couldn't find a character with cqi [" .. tostring(char_cqi) .."]");
		return false;
	end;
	
	-- if we're not within 3 hexes of our intended destination, then call the failure callback
	if distance_squared(log_x, log_y, character:logical_position_x(), character:logical_position_y()) > 9 then
		if is_function(fail_callback) then
			fail_callback();		
		end;
	else
		if is_function(success_callback) then
			success_callback();
		end;
	end;
end;



--	a character moved by move_npc_army has arrived at its destination
function campaign_manager:move_npc_army_arrived(char_cqi, log_x, log_y, should_replenish, allow_movement_afterwards, success_callback, fail_callback, trigger_name)
	
	self:stop_notify_on_character_halt(char_cqi);
	core:remove_listener(trigger_name);
	
	inc_tab();

	local char_str = char_lookup_str(char_cqi);
	
	core:remove_listener(trigger_name);
	
	-- remove this trigger from the active list
	for i = 1, #self.move_npc_army_active_list do
		if self.move_npc_army_active_list[i] == trigger_name then
			table.remove(self.move_npc_army_active_list, i);
			break;
		end;
	end;
	
	output("Character (" .. char_str .. ") has arrived");
	
	if not allow_movement_afterwards then
		self:disable_movement_for_character(char_str);
	end;
	
	dec_tab();
	
	if is_function(success_callback) then
		success_callback();
	end;
end;


function campaign_manager:cancel_all_move_npc_army()
	for i = 1, #self.move_npc_army_active_list do
		core:remove_listener(self.move_npc_army_active_list[i]);
	end;
	
	self.move_npc_army_active_list = {};
end;

	
--	Takes a record of the character's position, waits 0.5 seconds and then takes another. If the
--	character has moved in that time the is_moving_callback is called, else the is_not_moving_callback
--	is called
function campaign_manager:is_character_moving(char_cqi, is_moving_callback, is_not_moving_callback)
		
	if not is_number(char_cqi) then
		script_error("ERROR: is_character_moving() called but supplied cqi [" .. tostring(char_cqi) .. "] is not a number");
		return false;
	end;
	
	local cached_char = self:query_character(char_cqi);

	if not cached_char then
		script_error("ERROR: is_character_moving() called but couldn't find char with cqi of [" .. char_cqi .. "]");
		return false;
	end;
	
	local cached_pos_x = cached_char:logical_position_x();
	local cached_pos_y = cached_char:logical_position_y();
	
	local callback_name = "is_character_moving_" .. char_lookup_str(char_cqi);
	
	self:os_clock_callback(
		function()
			local current_char = self:query_character(char_cqi);
			
			if not current_char then
				-- script_error("WARNING: is_character_moving_action() called but couldn't find char with cqi of [" .. char_cqi .. "] after movement - did it die?");
				return false;
			end;
			
			local current_pos_x = current_char:logical_position_x();
			local current_pos_y = current_char:logical_position_y();
			
			if cached_pos_x == current_pos_x and cached_pos_y == current_pos_y then
				-- character hasn't moved
				if is_function(is_not_moving_callback) then
					is_not_moving_callback();
				end;
			else
				-- character has moved
				if is_function(is_moving_callback) then
					is_moving_callback();
				end;
			end;
		end,
		0.5,
		callback_name
	);
end;


--	stops a running is_character_moving() check
function campaign_manager:stop_is_character_moving(char_cqi)
	local callback_name = "is_character_moving_" .. char_lookup_str(char_cqi);
	
	self:remove_callback(callback_name);
end;


--	calls a callback as soon as a character is determined to not be moving
function campaign_manager:notify_on_character_halt(char_cqi, callback, must_move_first)
	if not is_function(callback) then
		script_error("ERROR: notify_on_character_halt() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	if must_move_first then
		-- character must be seen to have moved
		self:is_character_moving(
			char_cqi,
			function()
				-- character is now moving, notify when they stop
				self:is_character_moving(
					char_cqi, 
					function()
						self:notify_on_character_halt(char_cqi, callback, false);
					end,
					function()
						callback(char_cqi);
					end
				);
			end,
			function()
				self:notify_on_character_halt(char_cqi, callback, must_move_first);
			end
		);
	else
		-- can return immediately if the character's stationary
		self:is_character_moving(
			char_cqi, 
			function()
				self:notify_on_character_halt(char_cqi, callback);
			end,
			function()
				callback(char_cqi);
			end
		);
	end;
end;


function campaign_manager:stop_notify_on_character_halt(char_cqi)
	self:stop_is_character_moving(char_cqi);
end;



--- @function notify_on_character_movement
--- @desc Calls the supplied callback as soon as a character is determined to be moving.
--- @p number cqi, Command-queue-index of the subject character.
--- @p function callback, Callback to call.
--- @p [opt=false] boolean land only, Only movement over land should be considered.
function campaign_manager:notify_on_character_movement(process_name, char_cqi, callback, land_only)
	if not is_string(process_name) then
		script_error("ERROR: notify_on_character_movement() called but supplied process name [" .. tostring(process_name) .. "] is not a string");
		return false;
	end;

	if not is_number(char_cqi) then
		script_error("ERROR: notify_on_character_movement() called but supplied character cqi [" .. tostring(char_cqi) .. "] is not a number");
		return false;
	end;
	
	local character = self:query_character(char_cqi);
	
	if not character then
		script_error("ERROR: notify_on_character_movement() called but no character with the supplied cqi [" .. tostring(char_cqi) .. "] could be found");
		return false;
	end;
	
	if not is_function(callback) then
		script_error("ERROR: notify_on_character_movement() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	local char_str = "";

	if character:character_type("general") then	-- matches any character of the whole faction, thus copes with the target general dying
		char_str = "faction:" .. character:faction():name() .. ",type:general";
	end;
	
	local char_x = character:display_position_x();
	local char_y = character:display_position_y();
	local monitor_name = "notify_on_character_movement_" .. tostring(char_cqi);
	
	-- create an entry in our active monitors list
	if not self.notify_on_character_movement_active_monitors[process_name] then
		self.notify_on_character_movement_active_monitors[process_name] = {};
	end;
	table.insert(self.notify_on_character_movement_active_monitors[process_name], char_cqi);
	
	-- adding multiple areas as this method is unreliable - this may not trigger if the character leaves a port
	-- or settlement as they jump over the edge of the circle. This should be rewritten to poll character position, maybe
	local modify_scripting = self:modify_scripting();
	modify_scripting:remove_area_trigger(monitor_name);
	modify_scripting:add_circle_area_trigger(char_x, char_y, 3, monitor_name, char_str, false, true, true);
	modify_scripting:add_circle_area_trigger(char_x, char_y, 6, monitor_name, char_str, false, true, true);
	
	core:add_listener(
		monitor_name,
		"AreaExited",
		function(context) return context:area_trigger_name() == monitor_name end,
		function()
			if land_only then
				-- re-fetch the character and see if it is in a region
				local character = self:query_character(char_cqi);
				
				if not (character and character:has_region()) then
					out("restarting notify_on_character_movement() listener as character may be at sea");
					self:callback(function() notify_on_character_movement(character, callback, land_only) end, 300);
					return;
				end;
			end;
			
			self:notify_on_character_halt(char_cqi, callback, char_x, char_y);
		end,
		false
	);
end;


--- @function stop_notify_on_character_movement
--- @desc Stops any monitor started by @campaign_manager:notify_on_character_movement, by character cqi.
--- @p number cqi, Command-queue-index of the subject character.
function campaign_manager:stop_notify_on_character_movement(process_name)
	if not self:can_modify() then
		return;
	end;
	
	if not is_table(self.notify_on_character_movement_active_monitors[process_name]) then
		return;
	end;
	
	for i = 1, #self.notify_on_character_movement_active_monitors[process_name] do
		local monitor_name = "notify_on_character_movement_" .. tostring(self.notify_on_character_movement_active_monitors[process_name][i]);
		
		self:modify_scripting():remove_area_trigger(monitor_name);
		core:remove_listener(monitor_name);
	end;
end;











----------------------------------------------------------------------------
--	Objective Manager passthrough interface
----------------------------------------------------------------------------

function campaign_manager:set_objective(...)
	return self.objectives:set_objective(...);
end;


function campaign_manager:complete_objective(...)
	return self.objectives:complete_objective(...);
end;


function campaign_manager:fail_objective(...)
	return self.objectives:fail_objective(...);
end;


function campaign_manager:remove_objective(...)
	return self.objectives:remove_objective(...);
end;


function campaign_manager:activate_objective_chain(...)
	return self.objectives:activate_objective_chain(...);
end;


function campaign_manager:update_objective_chain(...)
	return self.objectives:update_objective_chain(...);
end;


function campaign_manager:end_objective_chain(...)
	return self.objectives:end_objective_chain(...);
end;


function campaign_manager:reset_objective_chain(...)
	return self.objectives:reset_objective_chain(...);
end;



----------------------------------------------------------------------------
--	Infotext Manager passthrough interface
----------------------------------------------------------------------------

function campaign_manager:remove_infotext(...)
	return self.infotext:remove_infotext(...);
end;


function campaign_manager:clear_infotext(...)
	return self.infotext:clear_infotext(...);
end;


function campaign_manager:add_infotext(...)
	return self.infotext:add_infotext(...);
end;





-----------------------------------------------------------------------------
-- trigger_custom_mission() override
-- cancels missions before adding them, in case they were previously added
-- also outputs to console and whitelists mission events so they get shown
-----------------------------------------------------------------------------


function campaign_manager:trigger_custom_mission(faction_key, mission_key, do_not_cancel, whitelist)	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_mission_issuedevent_feed_target_mission_faction");
	end;
	
	local modify_faction = self:modify_faction(faction_key, true);
	
	if not do_not_cancel then
		modify_faction:cancel_custom_mission(mission_key);
	end;

	out("++ triggering mission [" .. tostring(mission_key) .. "] for faction [" .. tostring(faction_key) .. "]");

	modify_faction:trigger_custom_mission(mission_key);
end;


function campaign_manager:cancel_custom_mission(faction_key, mission_key)
	self:modify_faction(faction_key, true):cancel_custom_mission(mission_key);
end;


function campaign_manager:trigger_custom_mission_from_string(faction_key, mission_string, whitelist)
	out("++ triggering mission from string for faction [" .. tostring(faction_key) .. "] mission string is " .. tostring(mission_string));
	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_mission_issuedevent_feed_target_mission_faction");
	end;
	
	self:modify_faction(faction_key, true):trigger_custom_mission_from_string(mission_string);
end;


function campaign_manager:trigger_mission(faction_key, mission_key, fire_immediately, whitelist)
	fire_immediately = not not fire_immediately;

	out("++ triggering mission from db [" .. tostring(mission_key) .. "] for faction [" .. tostring(faction_key) .. "], fire_immediately: " .. tostring(fire_immediately) .. ", whitelist: " .. tostring(whitelist));
	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_mission_issuedevent_feed_target_mission_faction");
	end;
	
	return self:modify_faction(faction_key, true):trigger_mission(mission_key, fire_immediately);
end;


function campaign_manager:trigger_dilemma(faction_key, dilemma_key, fire_immediately, whitelist)
	fire_immediately = not not fire_immediately;

	out("++ triggering dilemma from db [" .. tostring(dilemma_key) .. "] for faction [" .. tostring(faction_key) .. "], fire_immediately: " .. tostring(fire_immediately) .. ", whitelist: " .. tostring(whitelist));
	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_dilemmaevent_feed_target_dilemma_faction");
	end;
	
	return self:modify_faction(faction_key, true):trigger_dilemma(dilemma_key, fire_immediately);
end;


function campaign_manager:trigger_incident(faction_key, incident_key, fire_immediately, whitelist)
	fire_immediately = not not fire_immediately;

	out("++ triggering incident from db [" .. tostring(incident_key) .. "] for faction [" .. tostring(faction_key) .. "], fire_immediately: " .. tostring(fire_immediately) .. ", whitelist: " .. tostring(whitelist));
	
	if whitelist == true then
		self:whitelist_event_feed_event_type("faction_event_incidentevent_feed_target_incident_faction");
	end;
	
	return self:modify_faction(faction_key, true):trigger_incident(incident_key, fire_immediately);
end;



-----------------------------------------------------------------------------
--	mission manager (management) script
--	handles the saving and loading of mission managers to the savegame
-----------------------------------------------------------------------------


function campaign_manager:get_mission_manager(mission_key)
	return self.mission_managers[mission_key];
end;


function campaign_manager:register_mission_manager(mission_manager)
	if not is_missionmanager(mission_manager) then
		script_error("ERROR: register_mission_manager() called but supplied mission manager [" .. tostring(mission_manager) .. "] is not a mission manager");
		return false;
	end;

	if self:get_mission_manager(mission_manager.mission_key) then
		script_error("ERROR: register_mission_manager() called but supplied mission manager with key [" .. mission_manager.mission_key .. "] is already registered");
		return false;
	end;
	
	self.mission_managers[mission_manager.mission_key] = mission_manager;
end;


function campaign_manager:mission_managers_to_string()
	local str = "";
	for mission_key, mission_manager in pairs(self.mission_managers) do
		str = str .. mission_manager:state_to_string();
	end;
	
	return str;
end;


function campaign_manager:mission_managers_from_string(str)
	local pointer = 1;
	
	while true do
		local next_separator = string.find(str, "%", pointer);
		
		if not next_separator then
			break;
		end;
	
		local mission_key = string.sub(str, pointer, next_separator - 1);
		pointer = next_separator + 1;
		
		next_separator = string.find(str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: mission_managers_from_string() called but supplied string is malformed: " .. str);
			return false;
		end;
		
		local started = string.sub(str, pointer, next_separator - 1);
		
		if started == "true" then
			started = true;
		elseif started == "false" then
			started = false;
		else
			script_error("ERROR: mission_managers_from_string() called but parsing failed, boolean flag [" .. tostring(started) .. "] couldn't be decyphered, string is " .. str);
		end;
		
		pointer = next_separator + 1;
		
		next_separator = string.find(str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: mission_managers_from_string() called but supplied string is malformed: " .. str);
			return false;
		end;
		
		local completed = string.sub(str, pointer, next_separator - 1);
		
		if completed == "true" then
			completed = true;
		elseif completed == "false" then
			completed = false;
		else
			script_error("ERROR: mission_managers_from_string() called but parsing failed, boolean flag [" .. tostring(completed) .. "] couldn't be decyphered, string is " .. str);
			return false;
		end;
		
		-- find the mission manager in the registered list and set it up
		local mission_manager = self:get_mission_manager(mission_key);
		
		if not mission_manager then
			script_error("ERROR:  mission_managers_from_string() is attempting to set up a mission with key [" .. tostring(mission_manager) .. "] but it isn't registered. All missions should be registered before the first tick.");
			return false;
		end;
		
		mission_manager:start_from_savegame(started, completed);
		
		pointer = next_separator + 1;
	end;
end;








-----------------------------------------------------------------------------
--	turn countdown event system
--	fires a custom event after a given number of turns
-----------------------------------------------------------------------------

function campaign_manager:add_turn_countdown_event(faction_name, turn_offset, event_name, context_str)
	if not is_string(faction_name) then
		script_error("ERROR: add_turn_countdown_event() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	-- if it's not the current faction's turn, then increase the turn_offset by 1, as when the faction starts their turn that will count
	if self:get_faction_currently_processing() ~= faction_name then
		turn_offset = turn_offset + 1;
	end;

	return self:add_absolute_turn_countdown_event(faction_name, turn_offset + self:query_model():turn_number(), event_name, context_str);
end;


function campaign_manager:add_absolute_turn_countdown_event(faction_key, turn_to_trigger, event_name, context_str)
	if not is_string(faction_key) then
		script_error("ERROR: add_absolute_turn_countdown_event() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(turn_to_trigger) then
		script_error("ERROR: add_absolute_turn_countdown_event() called but supplied trigger turn [" .. tostring(turn_to_trigger) .. "] is not a number");
		return false;
	end;
	
	if not is_string(event_name) then
		script_error("ERROR: add_absolute_turn_countdown_event() called but supplied event name [" .. tostring(event_name) .. "] is not a string");
		return false;
	end;
	
	if not context_str then
		context_str = "";
	end;
	
	if not is_string(context_str) then
		script_error("ERROR: add_absolute_turn_countdown_event() called but supplied context string [" .. tostring(context_str) .. "] is not a string or nil");
		return false;
	end;
	
	local record = {};
	record.turn_to_trigger = turn_to_trigger;
	record.event_name = event_name;
	record.context_str = context_str;
	
	-- if we have no sub-table for this faction then create it
	if not self.turn_countdown_events[faction_key] then
		self.turn_countdown_events[faction_key] = {};
	end;
	
	-- if we have no elements then start the listener
	if #self.turn_countdown_events[faction_key] == 0 then
		core:add_listener(
			"turn_start_countdown_" .. faction_key,
			"FactionTurnStart",
			function(context) return context.string == faction_key end,
			function(context) self:check_turn_countdown_events(context.string) end,
			true
		);
	end;
	
	table.insert(self.turn_countdown_events[faction_key], record);
end;


function campaign_manager:check_turn_countdown_events(faction_name)
	local turn_countdown_events = self.turn_countdown_events[faction_name];

	if not is_table(turn_countdown_events) then
		script_error("WARNING: check_turn_countdown_events() called but could not find a table corresponding to given faction name [" .. faction_name .. "], how can this be?");
		return false;
	end;
	
	for i = 1, #turn_countdown_events do
		local current_record = turn_countdown_events[i];
		
		if current_record.turn_to_trigger <= self:modify_scripting():query_model():turn_number() then
			local event_name = current_record.event_name;
			local context_str = current_record.context_str;
			table.remove(turn_countdown_events, i);
			
			-- trigger the event itself
			core:trigger_event(event_name, context_str);
			
			self:check_turn_countdown_events(faction_name);
			return;
		end;
	end;
	
	if #turn_countdown_events == 0 then
		core:remove_listener("turn_start_countdown_" .. faction_name);
	end;
end;


function campaign_manager:turn_countdown_events_to_string()
	local state_str = "";
	
	output("turn_countdown_events_to_string() called");
	for faction_name, record_list in pairs(self.turn_countdown_events) do
		for i = 1, #record_list do
			local record = record_list[i];
	
			output("\tprocessing faction " .. faction_name);
			output("\t\trecord is " .. tostring(record));
			output("\t\trecord.turn_to_trigger is " .. tostring(record.turn_to_trigger));
			output("\t\trecord.event_name is " .. tostring(record.event_name));
			output("\t\trecord.context_str is " .. tostring(record.context_str));
		
			state_str = state_str .. faction_name .. "%" .. record.turn_to_trigger .. "%" .. record.event_name .. "%" .. record.context_str .. "%";
		end;
	end;
		
	return state_str;
end;


function campaign_manager:turn_countdown_events_from_string(state_str)
	local pointer = 1;
	
	while true do
		local next_separator = string.find(state_str, "%", pointer);
		
		if not next_separator then
			break;
		end;
	
		local faction_name = string.sub(state_str, pointer, next_separator - 1);
		pointer = next_separator + 1;
		
		next_separator = string.find(state_str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: turn_countdowns_from_string() called but supplied string is malformed: " .. state_str);
			return false;
		end;
		
		local turn_to_trigger_str = string.sub(state_str, pointer, next_separator - 1);
		local turn_to_trigger = tonumber(turn_to_trigger_str);
		
		if not turn_to_trigger then
			script_error("ERROR: turn_countdowns_from_string() called but parsing failed, turns remaining number [" .. tostring(turn_to_trigger_str) .. "] couldn't be decyphered, string is " .. state_str);
			return false;
		end;
		
		pointer = next_separator + 1;
		
		next_separator = string.find(state_str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: turn_countdowns_from_string() called but supplied string is malformed: " .. state_str);
			return false;
		end;
		
		local event_name = string.sub(state_str, pointer, next_separator - 1);
		
		pointer = next_separator + 1;
		
		next_separator = string.find(state_str, "%", pointer);
		
		if not next_separator then
			script_error("ERROR: turn_countdowns_from_string() called but supplied string is malformed: " .. state_str);
			return false;
		end;
		
		local context_str = string.sub(state_str, pointer, next_separator - 1);
		
		pointer = next_separator + 1;
		
		self:add_absolute_turn_countdown_event(faction_name, turn_to_trigger, event_name, context_str);
	end;
end;
















-----------------------------------------------------------------------------
--	intervention manager
-----------------------------------------------------------------------------

function campaign_manager:set_intervention_manager(im)
	self.intervention_manager = im;
end;


function campaign_manager:get_intervention_manager()
	if self.intervention_manager then
		return self.intervention_manager;
	else
		return intervention_manager:new();
	end;
end;





-----------------------------------------------------------------------------
--	turn number modifier
-----------------------------------------------------------------------------

function campaign_manager:turn_number()
	return self:query_model():turn_number() + self.turn_number_modifier;
end;


function campaign_manager:set_turn_number_modifier(modifier)
	if not is_number(modifier) or math.floor(modifier) ~= modifier then
		script_error("ERROR: set_turn_number_modifier() called but supplied modifier [" .. tostring(modifier) .. "] is not an integer");
		return false;
	end;
	
	self.turn_number_modifier = modifier;
end;








-----------------------------------------------------------------------------
--	chapter mission registration
-----------------------------------------------------------------------------

function campaign_manager:register_chapter_mission(ch)
	self.chapter_missions[ch.chapter_number] = ch;
end;


function campaign_manager:chapter_mission_exists_with_number(value)
	return not not self.chapter_missions[value];
end;











-----------------------------------------------------------------------------
--	is processing battle listeners
-----------------------------------------------------------------------------

function campaign_manager:start_processing_battle_listeners_sp()

	core:add_listener(
		"processing_battle_listener",
		"ComponentLClickUp",
		function(context) return context.string == "button_attack" or context.string == "button_autoresolve" end,
		function()
			core:trigger_event("ScriptEventPlayerBattleStartedSP");
		end,
		true
	);
	
	-- Sets up a listener for the BattleCompletedCameraMove event, which is sent when the camera starts to scroll back up to normal altitude after a battle sequence has been completed.
	-- The listener goes on to listen for the BattleCompleted event if a battle was actually fought (if maintaining a siege/retreating/etc no battle will have been fought).
	-- ScriptEventPlayerBattleSequenceFullyCompleteSP is triggered in all circumstances when everything is finished.
	core:add_listener(
		"processing_battle_listener",
		"BattleCompletedCameraMove",
		true,
		function()
		
			out("**** BattleCompletedCameraMove event received ****");
			
			-- only proceed if the player was involved
			if not self:pending_battle_cache_faction_was_involved(self:get_local_faction()) then
				out("\tplayer faction was not involved, returning");
				self.processing_battle = false;
				return;
			end;
			
			local num_monitors_active = 1;
			local pb = self:query_model():pending_battle();
			local battle_fought = pb:has_been_fought();
			
			-- Set up a callback to be called when the full battle sequence is completed. This should happen when the
			-- camera has returned back to normal altitude/player control. It is triggered regardless of whether a battle
			-- was actually fought or not (e.g. maintain siege/retreat)
			local full_battle_sequence_completed = function()			
				self:remove_callback("processing_battle_sequence_listener");
				core:remove_listener("processing_battle_sequence_listener");
				self.processing_battle = false;
				self.processing_battle_completing = false;
				
				if battle_fought then
					out("**** full battle sequence completed - triggering ScriptEventPlayerBattleCompletedSP (as the player fought in the battle) and ScriptEventPlayerBattleSequenceFullyCompleteSP");
					core:trigger_event("ScriptEventPlayerBattleCompletedSP");
				else
					out("**** full battle sequence completed - triggering ScriptEventPlayerBattleSequenceFullyCompleteSP");
				end;
				
				core:trigger_event("ScriptEventPlayerBattleSequenceFullyCompleteSP");
			end;
			
			-- Set up a callback that gets called after a battle has been fought, or would have been fought, by the player
			local battle_completed_callback = function()
				num_monitors_active = num_monitors_active - 1;
				if num_monitors_active <= 0 then
					full_battle_sequence_completed();
				end;
			end;
			
			-- If it's the players turn then also impose a wait for a little for any post-battle movements and for the camera to scroll up to the normal gameplay altitude
			-- (this is a bit of a hack - we wait for two seconds but in many cases the time we should wait is longer)
			if self:is_local_players_turn() then
				out("\tthis is the player's turn, waiting two seconds for camera movement to finish");
				
				-- We set the processing_battle flag to false at this point because the model will shortly force a save on legendary 
				-- difficulty, which will save this flag into the savegame. We set processing_battle_completing to true until the 
				-- sequence is completed, which is also queried by campaign_manager:is_processing_battle()
				self.processing_battle = false;
				self.processing_battle_completing = true;
				
				num_monitors_active = num_monitors_active + 1;
				self:callback(
					function()
						num_monitors_active = num_monitors_active - 1;
						if num_monitors_active <= 0 then
							full_battle_sequence_completed();
						end;
					end,
					2,
					"processing_battle_sequence_listener"
				);
			else
				out("\tthis is not the player's turn, not waiting two seconds");
			end;
			
			
			-- listen for the BattleCompleted event if an actual battle has been fought
			-- (this is when dead characters are all cleaned up)
			if battle_fought then
				out("\tbattle has been fought, establishing BattleCompleted listener");
			
				core:add_listener(
					"processing_battle_sequence_listener",
					"BattleCompleted",
					true,
					function()
						out("**** BattleCompleted event received ****");
						battle_completed_callback();
					end,
					false
				);
			else
				out("\tbattle has not been fought");
				battle_completed_callback();
			end;
		end,
		true
	);
	
	--
	--	work out what's happening pre-battle so we can send a custom event
	--
	core:add_listener(
		"processing_battle_listener",
		"PanelOpenedCampaign",
		function(context) 
			return context.string == "pre_battle_screen" 
		end,
		function(context)
			core:progress_on_loading_screen_dismissed(function() self:wait_for_model_sp(function() cm:on_pre_battle() end) end, true);
		end,
		true
	);
	
	--
	--	work out what happened post-battle so we can send a custom event
	--
	core:add_listener(
		"processing_battle_listener",
		"PanelOpenedCampaign",
		function(context) 
			return context.string == "post_battle_screen" 
		end,
		function(context)
			self:wait_for_model_sp(function() cm:on_post_battle() end);
		end,
		true
	);
end;

function campaign_manager:on_pre_battle()
	self.processing_battle = true;
		
	local pb = self:query_model():pending_battle();
	local battle_type = pb:battle_type();
	
	core:trigger_event("ScriptEventPreBattlePanelOpenedSP", pb);
	
	-- check if this is an ambush
	output("pre_battle_screen panel has opened, battle type is " .. battle_type);			
	
	if battle_type == "land_ambush" then
		local local_faction = self:get_local_faction(true);
		if self:pending_battle_cache_faction_was_defender(local_faction) then
			-- this is an ambush battle in which the player is the defender
			core:trigger_event("ScriptEventPreBattlePanelOpenedAmbushPlayerDefenderSP", pb);
		else
			-- this is an ambush 
			core:trigger_event("ScriptEventPreBattlePanelOpenedAmbushPlayerAttackerSP", pb);
		end;
		
		return;
	end;		
	
	--[[
	-- encampment not yet available using river_crossing_battle as dummy
	if battle_type == "land_encampment" then
		local local_faction = self:get_local_faction(true);
		if self:pending_battle_cache_faction_was_defender(local_faction) then
			-- this is an encampment battle in which the player is the defender
			core:trigger_event("ScriptEventPreBattlePanelOpenedEncampmentPlayerDefenderSP", pb);
		else
			-- this is an encampment battle 
			core:trigger_event("ScriptEventPreBattlePanelOpenedEncampmentPlayerAttackerSP", pb);
		end;
		
		return;
	end;	
	]]--

	
	-- if siege buttons are visible then this must be a siege battle
	local uic_button_set_siege = find_uicomponent(core:get_ui_root(), "pre_battle_screen", "button_set_siege");
	
	if uic_button_set_siege and uic_button_set_siege:Visible() then
		-- this is a battle at a settlement, if the encircle button is visible then it's a minor settlement
		local uic_encircle_button = find_uicomponent(core:get_ui_root(), "pre_battle_screen", "button_surround");
	
		if uic_encircle_button and uic_encircle_button:Visible() then
			-- this is a battle at a minor settlement
			core:trigger_event("ScriptEventPreBattlePanelOpenedMinorSettlementSP", pb);
		else
			-- this is a battle at a province capital
			core:trigger_event("ScriptEventPreBattlePanelOpenedProvinceCapitalSP", pb);
		end;
	else
		-- this is a regular field battle
		core:trigger_event("ScriptEventPreBattlePanelOpenedFieldSP", pb);
	end;

end;


function campaign_manager:on_post_battle()
	local pb = self:query_model():pending_battle();
	local local_faction = self:get_local_faction(true);
	
	local player_was_primary_attacker = faction_attacker_in_battle(pb, local_faction);
	local player_was_primary_defender = faction_defender_in_battle(pb, local_faction);
	
	local player_was_attacker = player_was_primary_attacker;
	local player_was_defender = player_was_primary_defender;
	
	if not (player_was_primary_attacker or player_was_primary_defender) then
		player_was_attacker = self:pending_battle_cache_faction_was_attacker(local_faction);
		player_was_defender = self:pending_battle_cache_faction_was_defender(local_faction);
	end;
	
	local is_settlement_battle = pb:has_contested_garrison();
	
	output("***");
	output("*** Battle involving the player has completed");
	
	if player_was_defender then			
		if pb:has_defender() and pb:defender():won_battle() then
			-- player was defender and the defender won the battle					
			if is_settlement_battle then
				if pb:battle_type() == "settlement_sally" then
					-- the player was defending a sally battle (i.e. besieging the settlement and the enemy sallied) and won
					output("*** player won a sally battle as the besieger, triggering event ScriptEventPlayerDefendsSettlementSP");
					core:trigger_event("ScriptEventPlayerWinsBattleSP", pb);
					core:trigger_event("ScriptEventPlayerDefendsSettlementSP", pb);
				else
					-- it was a siege defence that the player won
					output("*** player won siege defence, triggering event ScriptEventPlayerDefendsSettlementSP");
					core:trigger_event("ScriptEventPlayerWinsBattleSP", pb);
					core:trigger_event("ScriptEventPlayerDefendsSettlementSP", pb);
				end;
			else
				-- it was a field battle defense that the player won
				output("*** player won field battle defence, triggering event ScriptEventPlayerWinsFieldBattleSP");
				core:trigger_event("ScriptEventPlayerWinsBattleSP", pb);
				core:trigger_event("ScriptEventPlayerWinsFieldBattleSP", pb);
			end;
		elseif pb:has_attacker() and pb:attacker():won_battle() then
			-- player was defender and the defender didn't win the battle					
			if is_settlement_battle then
				if pb:battle_type() == "settlement_sally" then
					-- the player lost a sally battle as the defender (i.e. was besieger)
					output("*** player lost a sally battle as the defender, triggering event ScriptEventPlayerLosesFieldBattleSP");
					core:trigger_event("ScriptEventPlayerLosesBattleSP", pb);
					core:trigger_event("ScriptEventPlayerLosesFieldBattleSP", pb);
				elseif player_was_primary_defender then
					-- the player has lost a settlement
					output("*** player has lost a settlement, triggering event ScriptEventPlayerLosesSettlementBattleSP");
					core:trigger_event("ScriptEventPlayerLosesBattleSP", pb);
					core:trigger_event("ScriptEventPlayerLosesSettlementBattleSP", pb);
				else
					-- the player has lost a battle over a settlement that wasn't theirs
					output("*** player has lost a battle over a settlement but wasn't the primary defender, triggering event ScriptEventPlayerLosesFieldBattleSP");
					core:trigger_event("ScriptEventPlayerLosesBattleSP", pb);
					core:trigger_event("ScriptEventPlayerLosesFieldBattleSP", pb);
				end;
			else
				-- the player has lost a field battle
				output("*** player has lost a field battle, triggering event ScriptEventPlayerLosesFieldBattleSP");
				core:trigger_event("ScriptEventPlayerLosesBattleSP", pb);
				core:trigger_event("ScriptEventPlayerLosesFieldBattleSP", pb);
			end;					
		end;					
	else
		if pb:has_attacker() and pb:attacker():won_battle() then
			-- player was attacker and the attacker won the battle
			is_player_victory = true;
			
			if is_settlement_battle then
				-- it was a battle at a settlement the player won
				
				if pb:battle_type() == "settlement_sally" then
					-- the player has won a sally battle as the attacker - i.e. the player attacked out of the settlement
					output("*** player has won a sally battle as the attacker, triggering event ScriptEventPlayerWinsSettlementBattleSP");
					core:trigger_event("ScriptEventPlayerWinsBattleSP", pb);
					core:trigger_event("ScriptEventPlayerWinsSettlementBattleSP", pb);
					
				elseif player_was_primary_attacker then
					-- the player has won a battle at a settlement
					output("*** player has won a settlement battle as the primary attacker, triggering event ScriptEventPlayerWinsSettlementBattleSP");
					core:trigger_event("ScriptEventPlayerWinsBattleSP", pb);
					core:trigger_event("ScriptEventPlayerWinsSettlementBattleSP", pb);
				else
					-- the player was not the primary attacker in a battle victory at a settlement
					output("*** player has won a battle at a settlement but not as the primary attacker, triggering event ScriptEventPlayerWinsFieldBattleSP");
					core:trigger_event("ScriptEventPlayerWinsBattleSP", pb);
					core:trigger_event("ScriptEventPlayerWinsFieldBattleSP", pb);
				end;
			else
				-- the player wins a field battle
				output("*** player has won a field battle as an attacker, triggering event ScriptEventPlayerWinsFieldBattleSP");
				core:trigger_event("ScriptEventPlayerWinsBattleSP", pb);
				core:trigger_event("ScriptEventPlayerWinsFieldBattleSP", pb);
			end;
		elseif pb:has_defender() and pb:defender():won_battle() then
			-- player was attacker and the defender won
			output("*** player has lost a field battle as an attacker, triggering event ScriptEventPlayerLosesFieldBattleSP");
			core:trigger_event("ScriptEventPlayerLosesBattleSP", pb);
			core:trigger_event("ScriptEventPlayerLosesFieldBattleSP", pb);
		end;
	end;
	
	output("***")
end;



















----------------------------------------------------------------------------
-- custom event generator
-- fires custom events whenever supplied conditions are met
-- the context data generator is an anonymous function that takes 
-- the event context as a parameter and returns the bit of data of
-- interest e.g. the character or the military force. This is so it
-- can be re-packaged up as custom context downstream
----------------------------------------------------------------------------

function campaign_manager:start_custom_event_generator(event, condition, target_event, context_data_generator)
	if not is_string(event) then
		script_error("ERROR: add_custom_event_generator() called but supplied event [" .. tostring(event) .. "] is not a string");
		return false;
	end;
	
	if not is_function(condition) then
		script_error("ERROR: add_custom_event_generator() called but supplied condition [" .. tostring(condition) .. "] is not a function");
		return false;
	end;
	
	if not is_string(target_event) then
		script_error("ERROR: add_custom_event_generator() called but supplied target_event [" .. tostring(target_event) .. "] is not a string");
		return false;
	end;
	
	if not is_function(context_data_generator) and not is_nil(context_data_generator) then
		script_error("ERROR: add_custom_event_generator() called but supplied context data generator [" .. tostring(target_event) .. "] is not a function or nil");
		return false;
	end;
	
	core:add_listener(
		"custom_event_generator_" .. target_event,
		event,
		function(context) 
			return condition(context) 
		end,
		function(context)
			if context_data_generator then
				core:trigger_event(target_event, context_data_generator(context));
			else
				core:trigger_event(target_event);
			end;
		end,
		true
	);
end;


function campaign_manager:stop_custom_event_generator(target_event)
	core:remove_listener("custom_event_generator_" .. target_event);
end;








----------------------------------------------------------------------------
-- returns the string name of the currently processing faction
----------------------------------------------------------------------------

function campaign_manager:get_faction_currently_processing()
	return self.faction_currently_processing;
end;


function campaign_manager:is_local_players_turn()
	return self:get_faction_currently_processing() == self:get_local_faction(true);
end;





----------------------------------------------------------------------------
-- get diplomacy panel context
----------------------------------------------------------------------------

-- list of all diplomatic options, which the diplomacy panel displays
-- option is the name of the uicomponent
-- result is a string signifying its meaning to the interventions listening to it
-- priority is the priority of the meaning (so the context of a compound offer like an alliance with a payment is always of the more-significant component)
campaign_manager.diplomatic_options = {
	{["option"] = "diplomatic_option_trade_agreement", 				["result"] = "trade",						["priority"] = 2},
	{["option"] = "diplomatic_option_cancel_trade_agreement", 		["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_hard_access", 					["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_cancel_hard_access", 			["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_military_alliance", 			["result"] = "alliance",					["priority"] = 2},
	{["option"] = "diplomatic_option_cancel_military_alliance",		["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_trade_regions",				["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_trade_technology",				["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_state_gift",					["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_payment",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_vassal",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_cancel_vassal",				["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_peace",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "war_declared",									["result"] = "war",							["priority"] = 2},
	{["option"] = "diplomatic_option_join_war",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_trade_agreement",		["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_military_alliance",		["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_hostage",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_mariiage",						["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_nonaggression_pact",			["result"] = "nap",							["priority"] = 2},
	{["option"] = "diplomatic_option_cancel_nonaggression_pact",	["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_soft_access",					["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_cancel_soft_access",			["result"] = "noninteractive",				["priority"] = 1},	
	{["option"] = "diplomatic_option_defensive_alliance",			["result"] = "alliance",					["priority"] = 2},
	{["option"] = "diplomatic_option_cancel_defensive_alliance",	["result"] = "noninteractive",				["priority"] = 1},
	{["option"] = "diplomatic_option_client_state",					["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_cancel_client_state",			["result"] = "noninteractive",				["priority"] = 1},	
	{["option"] = "diplomatic_option_confederation",				["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_nonaggression_pact",		["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_soft_access",			["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_defensive_alliance",		["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_vassal",					["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_break_client_state",			["result"] = "interactive",					["priority"] = 1},
	{["option"] = "diplomatic_option_state_gift_unilateral",		["result"] = "interactive",					["priority"] = 1}
};



function campaign_manager:start_diplomacy_panel_context_listener()
	if self.diplomacy_panel_context_listener_started then
		return false;
	end;
	
	self.diplomacy_panel_context_listener_started = true;

	self:callback(function() self:poll_diplomacy_panel_context() end, 0.2);
end;


function campaign_manager:poll_diplomacy_panel_context()
	local diplomacy_panel_context = self:get_diplomacy_panel_context();
	
	if diplomacy_panel_context ~= "" then
		self.diplomacy_panel_context_listener_started = false;
		core:trigger_event("ScriptEventDiplomacyPanelContext", diplomacy_panel_context);
	else
		self:callback(function() self:poll_diplomacy_panel_context() end, 0.2);
	end;
end;




function campaign_manager:get_diplomacy_panel_context()
	local uic_diplomacy = find_uicomponent(core:get_ui_root(), "diplomacy_dropdown");
	
	local diplomatic_options = self.diplomatic_options;
	local result = "";
	local result_priority = 0;	
	
	-- If we couldn't find the panel or it doesn't seem to be open then return a state so that the polling completes.
	-- Not really sure how this happens but it does.
	if not uic_diplomacy or not self:get_campaign_ui_manager():is_panel_open("diplomacy_dropdown") then
		return "invalid";
	end;
	
	for i = 1, #diplomatic_options do
		local current_option = diplomatic_options[i].option;
		
		local uic_option = find_uicomponent(uic_diplomacy, current_option);
		
		if uic_option and uic_option:Visible() then
			if diplomatic_options[i].priority > result_priority then
				result_priority = diplomatic_options[i].priority;
				result = diplomatic_options[i].result;
				
				-- return immediately if the result is important enough
				if result_priority == 2 then
					break;
				end;
			end;
		end;
	end;
		
	return result;
end;







----------------------------------------------------------------------------
-- toggle ui hiding
----------------------------------------------------------------------------

function campaign_manager:enable_ui_hiding(value)
	self.ui_hiding_enabled = value;
	
	if not self:can_modify() then
		return;
	end;
	
	local modify_scripting = self:modify_scripting();
	
	modify_scripting:disable_shortcut("root", "toggle_ui", not value);
	modify_scripting:disable_shortcut("root", "toggle_ui_with_borders", not value);
end;


function campaign_manager:is_ui_hiding_enabled()
	return self.ui_hiding_enabled;
end;






----------------------------------------------------------------------------
-- faction region change monitor
----------------------------------------------------------------------------
-- When started, this stores a record of what regions a faction holds when their turn
-- ends and compares it to the regions the same faction holds when their next turn starts.
-- If the two don't match, then the faction has gained or lost a region and this system
-- fires some custom script events accordingly to notify other script.

function campaign_manager:start_faction_region_change_monitor(faction_name)
	
	if not is_string(faction_name) then
		script_error("ERROR: start_faction_region_change_monitor() called but supplied name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	-- see if we already have listeners started for this faction (the data may be reinstated from the savegame)
	if not self.faction_region_change_list[faction_name] then
		self.faction_region_change_list[faction_name] = {};
	end;
	
	core:remove_listener("faction_region_change_monitor_" .. faction_name);
	
	core:add_listener(
		"faction_region_change_monitor_" .. faction_name,
		"FactionTurnStart",
		function(context) return context:faction():name() == faction_name end,
		function(context)
			self:faction_region_change_monitor_process_turn_start(context:faction())
		end,
		true
	);
	
	core:add_listener(
		"faction_region_change_monitor_" .. faction_name,
		"FactionTurnEnd",
		function(context) return context:faction():name() == faction_name end,
		function(context)
			self:faction_region_change_monitor_process_turn_end(context:faction())
		end,
		true
	);
	
	self:add_first_tick_callback(
		function() 
			self:faction_region_change_monitor_validate_on_load(faction_name);
		end
	);
end;


function campaign_manager:faction_region_change_monitor_validate_on_load(faction_name)
	-- if it's currently this faction's turn then process the turn end - this means that the data will be current if loading from a savegame (or from a new game)
	if self:get_faction_currently_processing() == faction_name then
		 self:faction_region_change_monitor_process_turn_end(get_faction(faction_name));
	else
		-- validate that the cached region list contains valid data
		local cached_region_list = self.faction_region_change_list[faction_name];
		
		-- compare cached list to current list, to see if the subject faction has lost a region
		for i = 1, #cached_region_list do
			local current_cached_region = cached_region_list[i];
			
			if not self:region_exists(current_cached_region) then		
				script_error("WARNING: faction_region_change_monitor_validate_on_load() called but couldn't find region corresponding to key [" .. current_cached_region .. "] stored in cached region list - regenerating cached list");
				self:faction_region_change_monitor_process_turn_end(get_faction(faction_name));
				return;
			end;
		end;
	end;
end;


function campaign_manager:stop_faction_region_change_monitor(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: stop_faction_region_change_monitor() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	core:remove_listener("faction_region_change_monitor_" .. faction_name);
	
	self.faction_region_change_list[faction_name] = nil;
end;


function campaign_manager:faction_region_change_monitor_process_turn_end(faction)
	local faction_name = faction:name();
	local region_list = faction:region_list();
	
	self.faction_region_change_list[faction_name] = {};

	for i = 0, region_list:num_items(i) - 1 do		
		table.insert(self.faction_region_change_list[faction_name], region_list:item_at(i):name());
	end;
end;


function campaign_manager:faction_region_change_monitor_process_turn_start(faction)
	local should_issue_grudge_messages = true;

	-- don't do anything on turn one or two
	if self:query_model():turn_number() <= 2 then
		should_issue_grudge_messages = false;
	end;

	local faction_name = faction:name();
	local region_list = faction:region_list();
		
	-- create a list of the regions the faction currently has
	local current_region_list = {};
	
	for i = 0, region_list:num_items(i) - 1 do
		table.insert(current_region_list, region_list:item_at(i):name());
	end;
	
	local cached_region_list = self.faction_region_change_list[faction_name];
	
	local regions_gained = {};
	local regions_lost = {};
	
	-- compare cached list to current list, to see if the subject faction has lost a region
	for i = 1, #cached_region_list do
		local current_cached_region = cached_region_list[i];
		local current_cached_region_found = false;
		
		if self:region_exists(current_cached_region) then		
			for j = 1, #current_region_list do
				if current_cached_region == current_region_list[j] then
					current_cached_region_found = true;
					break;
				end;
			end;
		
			if not current_cached_region_found then
				table.insert(regions_lost, current_cached_region);
			end;
		else
			script_error("WARNING: faction_region_change_monitor_process_turn_start() called but couldn't find region corresponding to key [" .. current_cached_region .. "] stored in cached region list - discarding cached list and using current");
			cached_region_list = current_region_list;
			regions_lost = {};
		end;
	end;
	
	-- compare current list to cached list, to see if the subject faction has gained a region
	for i = 1, #current_region_list do
		local current_region = current_region_list[i];
		local current_region_found = false;
		
		for j = 1, #cached_region_list do
			if current_region == cached_region_list[j] then
				current_region_found = true;
				break;
			end;
		end;
		
		if not current_region_found then
			table.insert(regions_gained, current_region);
		end;
	end;
	
	-- trigger script events for each region this faction has lost or gained
	if should_issue_grudge_messages then
		for i = 1, #regions_lost do
			core:trigger_event("ScriptEventFactionLostRegion", faction, self:query_region(regions_lost[i]));
		end;
		
		for i = 1, #regions_gained do
			core:trigger_event("ScriptEventFactionGainedRegion", faction, self:query_region(regions_lost[i]));
		end;
	end;
end;


function campaign_manager:faction_region_change_monitor_to_str()
	local savestr = "";
	
	for faction_name, region_table in pairs(self.faction_region_change_list) do
		savestr = savestr .. faction_name;
		
		for i = 1, #region_table do
			savestr = savestr .. "%" .. region_table[i];
		end;
		
		savestr = savestr .. ";";
	end;
	
	return savestr;
end;


function campaign_manager:faction_region_change_monitor_from_str(str)
	if str == "" then
		return;
	end;
	
	local pointer = 1;
	
	while true do
		local next_separator = string.find(str, ";", pointer);
		
		if not next_separator then	
			script_error("ERROR: faction_region_change_monitor_from_str() called but supplied string is malformed: " .. str);
			return false;
		end;
		
		local faction_str = string.sub(str, pointer, next_separator - 1);
		
		if string.len(faction_str) == 0 then
			script_error("ERROR: faction_region_change_monitor_from_str() called but supplied string contains a zero-length faction record: " .. str);
			return false;
		end;
		
		self:single_faction_region_change_monitor_from_str(faction_str);
		
		pointer = next_separator + 1;
		
		if pointer > string.len(str) then
			-- we have reached the end of the string
			return;
		end;
	end;
end;



function campaign_manager:single_faction_region_change_monitor_from_str(str)
	local pointer = 1;
	local next_separator = string.find(str, "%", pointer);
	
	if not next_separator then
		-- we have a faction with no regions, so just start the monitor
		self:start_faction_region_change_monitor(str);
		return;
	end;
	
	local faction_name = string.sub(str, pointer, next_separator - 1);
	
	-- create a record in the faction_region_change_list for this faction
	self.faction_region_change_list[faction_name] = {};
	
	local pointer = next_separator + 1;
	
	while true do
		next_separator = string.find(str, "%", pointer);
		
		if not next_separator then
			-- this is the last region in the string, so add it, start the monitor and then return
			table.insert(self.faction_region_change_list[faction_name], string.sub(str, pointer));
			self:start_faction_region_change_monitor(faction_name);
			return;
		end;
		
		table.insert(self.faction_region_change_list[faction_name], string.sub(str, pointer, next_separator - 1));
		
		pointer = next_separator + 1;
	end;
end;









----------------------------------------------------------------------------
-- event feed message suppression
-- Mechanisms exist to suppress event feed messages on both the model
-- side and the UI side. We only suppress event feed messages on the UI
-- side now.
----------------------------------------------------------------------------

function campaign_manager:suppress_all_event_feed_messages(value)
	if value ~= false then
		value = true;
	end;

	if self.all_event_feed_messages_suppressed == value then
		return;
	end;
	
	self.all_event_feed_messages_suppressed = value;
	
	-- cancel any previous advice suppressions requests that might still be waiting for advice to be complete
	self:cancel_progress_on_advice_finished();
	
	out(">> suppress_all_event_feed_messages(" .. tostring(value) .. ") called");
	
	CampaignUI.SuppressAllEventTypesInUI(value);
	
	-- if we are suppressing, then whitelist certain event types so that they still get through
	if value then		
		-- whitelist dilemma messages in the UI, in case there's one already pending
		self:whitelist_event_feed_event_type("faction_event_dilemmaevent_feed_target_dilemma_faction");
		
		-- also whitelist mission succeeded events, the flow just works better if the player gets immediate feedback about these things
		self:whitelist_event_feed_event_type("faction_event_mission_successevent_feed_target_mission_faction");
	end;
end;


function campaign_manager:whitelist_event_feed_event_type(event_type)
	out(">> whitelist_event_feed_event_type() called, event_type is " .. tostring(event_type));
	
	CampaignUI.WhiteListEventTypeInUI(event_type);
end;









----------------------------------------------------------------------------
-- Cindy playback
----------------------------------------------------------------------------

-- parameters: path to cindy scene file, [blend in duration, blend out duration]
-- uses default blend time if nothing is passed
function campaign_manager:cindy_playback(file, blend_in, blend_out)
	if not self:can_modify() then
		return false;
	end;

	out("Starting cinematic playback of file: " .. file .. ".");
	self:get_cinematic():cindy_playback(file, blend_in, blend_out);
end;

function campaign_manager:stop_cindy_playback(clear_anim_scenes)
	if not self:can_modify() then
		return false;
	end;

	out("Stopping cinematic playback");	
	self:get_cinematic():stop_cindy_playback(clear_anim_scenes);
end;



----------------------------------------------------------------------------
-- Script link history
----------------------------------------------------------------------------

function campaign_manager:help_page_seen(page_name)
	return effect.get_advice_history_string_seen(page_name) or effect.get_advice_history_string_seen("script_link_campaign_" .. page_name);
end;





----------------------------------------------------------------------------
-- Loading exported files
----------------------------------------------------------------------------


function campaign_manager:load_exported_files(filename, path_str)

	if not is_string(filename) then
		script_error("ERROR: load_exported_files() called but no string filename supplied");
		return false;
	end;
	
	if path_str and not is_string(path_str) then
		script_error("ERROR: load_exported_files() called but supplied path [" .. tostring(path_str) .. "] is not a string");
		return false;
	end;
	
	path_str = path_str or "script";
	package.path = package.path .. ";" .. path_str .. "/?.lua;";
	
	local all_files_str = self:modify_scripting():filesystem_lookup("/" .. path_str .. "/", filename .. "*.lua");

	if not is_string(all_files_str) or string.len(all_files_str) == 0 then
		script_error("WARNING: load_exported_files() couldn't find any files with supplied name " .. filename);
		return;
	end;
	
	local files_to_load = {};
	local pointer = 1;
	
	while true do
		local next_separator = string.find(all_files_str, ",", pointer);
		
		if not next_separator then
			-- this is the last entry
			table.insert(files_to_load, string.sub(all_files_str, pointer));
			break;
		end;
		
		table.insert(files_to_load, string.sub(all_files_str, pointer, next_separator - 1));
		
		pointer = next_separator + 1;
	end;
		
	-- strip the path off the start and the .lua off the end
	for i = 1, #files_to_load do
		local current_str = files_to_load[i];
			
		-- find the last '\' or '/' character
		local pointer = 1;
		while true do
			local next_separator = string.find(current_str, "\\", pointer) or string.find(current_str, "/", pointer);
			
			if next_separator then
				pointer = next_separator + 1;
			else
				-- this is the last separator
				if pointer > 1 then
					current_str = string.sub(current_str, pointer);
				end;
				break;
			end;
		end;
			
		-- remove the .lua suffix, if any
		local suffix = string.sub(current_str, string.len(current_str) - 3);
		
		if string.lower(suffix) == ".lua" then
			current_str = string.sub(current_str, 1, string.len(current_str) - 4);
		end;
		
		files_to_load[i] = current_str;
		
		inc_tab();
		self:load_faction_script(current_str);
		dec_tab();
	end;	
end;




----------------------------------------------------------------------------
-- pending battle cache
----------------------------------------------------------------------------

function campaign_manager:start_pending_battle_cache()
	core:add_listener(
		"pending_battle_cache",
		"PendingBattle",
		true,
		function() self:cache_pending_battle() end,
		true
	);
	
	-- removed this, as removing the characters from the pending battle cache when they withdraw can cause issues, such
	-- as the progress_on_battle_completed listener never progressing
	--[[
	core:add_listener(
		"character_withdraw_cache",
		"CharacterWithdrewFromBattle",
		true,
		function(context) self:pending_battle_cache_remove_character(context) end,
		true
	);
	]]
end;


function campaign_manager:pending_battle_cache_remove_character(context)
	local char = context:character();
	
	-- attempt to remove from attacker list
	for i = 1, #self.pending_battle_cached_attackers do
		local current_cached_attacker = self.pending_battle_cached_attackers[i];
		
		if current_cached_attacker.cqi == char:cqi() then
			table.remove(self.pending_battle_cached_attackers, i);
			
			-- if we have no attackers left, then clear the defender list as well
			if #self.pending_battle_cached_attackers == 0 then
				self.pending_battle_cached_defenders = {};
			end;
			
			return;
		end;
	end;
	
	-- attempt to remove from defender list
	for i = 1, #self.pending_battle_cached_defenders do
		local current_cached_defender = self.pending_battle_cached_defenders[i];
		
		if current_cached_defender.cqi == char:cqi() then
			table.remove(self.pending_battle_cached_defenders, i);
			
			-- if we have no defenders left, then clear the attacker list as well
			if #self.pending_battle_cached_defenders == 0 then
				self.pending_battle_cached_attackers = {};
			end;
			
			return;
		end;
	end;
end;


function campaign_manager:cache_pending_battle_character(list, character)
	local record = {};
	
	record.cqi = character:cqi();
	record.faction_name = character:faction():name();
	
	if character:has_military_force() then
		record.mf_cqi = character:military_force():command_queue_index();
	else
		script_error("WARNING: cache_pending_battle_character() called but supplied character (cqi: [" .. character:cqi() .. "], faction name: [" .. character:faction():name() .. "]) has no military force, how can this be? Not going to add CQI.");
		return;
	end;
	
	table.insert(list, record);
end;


function campaign_manager:cache_pending_battle()
	local pb = self:query_model():pending_battle();

	local attackers = {};
	local defenders = {};
	
	-- cache attackers
	
	-- primary
	if pb:has_attacker() then
		self:cache_pending_battle_character(attackers, pb:attacker());
	end;
	
	-- secondary
	local secondary_attacker_list = pb:secondary_attackers();
	for i = 0, secondary_attacker_list:num_items() - 1 do
		self:cache_pending_battle_character(attackers, secondary_attacker_list:item_at(i));
	end;
	
	-- cache defenders
	
	-- defenders
	if pb:has_defender() then
		self:cache_pending_battle_character(defenders, pb:defender());
	end;
	
	-- defenders
	local secondary_defenders_list = pb:secondary_defenders();
	for i = 0, secondary_defenders_list:num_items() - 1 do
		self:cache_pending_battle_character(defenders, secondary_defenders_list:item_at(i));
	end;
	
	self.pending_battle_cached_attackers = attackers;
	self.pending_battle_cached_defenders = defenders;
	
	self:set_pending_battle_svr_state(pb);
	
	if not self:is_multiplayer() and self:is_local_players_turn() then
		self:print_pending_battle_cache();
	end;
	
	core:trigger_event("ScriptEventPendingBattle", pb);
end;


function campaign_manager:print_pending_battle_cache()
	local attackers = self.pending_battle_cached_attackers;
	local defenders = self.pending_battle_cached_defenders;

	out("*****");
	out("printing pending battle cache");
	out("\tattackers:");
	for i = 1, #attackers do
		local current_record = attackers[i];
		out("\t\t" .. i .. " faction: [" .. current_record.faction_name .. "], char cqi: [" .. current_record.cqi .. "], mf cqi: [" .. current_record.mf_cqi .. "]");
	end;
	out("\tdefenders:");
	for i = 1, #defenders do
		local current_record = defenders[i];
		out("\t\t" .. i .. " faction: [" .. current_record.faction_name .. "], char cqi: [" .. current_record.cqi .. "], mf cqi: [" .. current_record.mf_cqi .. "]");
	end;
	out("*****");
end;


-- called when the game is saving
function campaign_manager:pending_battle_cache_to_string()
	local attackers = self.pending_battle_cached_attackers;
	local defenders = self.pending_battle_cached_defenders;

	-- pack data into strings for saving
	local attacker_str = "";
	for i = 1, #attackers do
		local current_record = attackers[i];
		if current_record.mf_cqi then
			attacker_str = attacker_str .. current_record.cqi .. "," .. current_record.mf_cqi .. "," .. current_record.faction_name .. ";"
		else
			-- support for old savegames with no military force cqi embedded
			attacker_str = attacker_str .. current_record.cqi .. "," .. current_record.faction_name .. ";"
		end;
	end;
	
	local defender_str = "";
	for i = 1, #defenders do
		local current_record = defenders[i];
		if current_record.mf_cqi then
			defender_str = defender_str .. current_record.cqi .. "," .. current_record.mf_cqi .. "," .. current_record.faction_name .. ";"
		else
			-- support for old savegames with no military force cqi embedded
			defender_str = defender_str .. current_record.cqi .. "," .. current_record.faction_name .. ";"
		end;
	end;

	self.pending_battle_cached_attacker_str = attacker_str;
	self.pending_battle_cached_defender_str = defender_str;
end;


-- called when the game is loading
function campaign_manager:pending_battle_cache_from_string()
	self.pending_battle_cached_attackers = self:pending_battle_cache_table_from_string(self.pending_battle_cached_attacker_str);
	self.pending_battle_cached_defenders = self:pending_battle_cache_table_from_string(self.pending_battle_cached_defender_str);
end;


function campaign_manager:pending_battle_cache_table_from_string(str)
	local list = {};
	
	local pointer = 1;
	while true do
		local next_separator = string.find(str, ",", pointer);
		
		if not next_separator then
			break;
		end;
		
		local record = {};
		
		local cqi_str = string.sub(str, pointer, next_separator - 1);
		local cqi = tonumber(cqi_str);
		
		if not cqi then
			script_error("ERROR: pending_battle_cache_table_from_string() could not convert character cqi string [" .. tostring(cqi_str) .. "] into a number, inserting -1");
			cqi = -1;
		end;
		
		record.cqi = cqi;
		
		pointer = next_separator + 1;
		next_separator = string.find(str, ",", pointer);
		
		-- temp support for savegames that have no military force cqis embedded
		if next_separator then
			local mf_cqi_str = string.sub(str, pointer, next_separator - 1);
			local mf_cqi = tonumber(mf_cqi_str);
						
			if not mf_cqi then
				script_error("ERROR: pending_battle_cache_table_from_string() could not convert military force cqi string [" .. tostring(mf_cqi_str) .. "] into a number, inserting -1");
				cqi = -1;
			end;
			
			record.mf_cqi = mf_cqi;
			
			pointer = next_separator + 1;
		end;	
		
		next_separator = string.find(str, ";", pointer);
		
		local faction_name = string.sub(str, pointer, next_separator - 1);
		record.faction_name = faction_name;
		
		pointer = next_separator + 1;
		
		table.insert(list, record);
	end;
	
	return list;
end;


function campaign_manager:pending_battle_cache_num_attackers()
	return #self.pending_battle_cached_attackers;
end;


function campaign_manager:pending_battle_cache_get_attacker(index)
	if not is_number(index) or index < 0 or index > #self.pending_battle_cached_attackers then
		script_error("ERROR: pending_battle_cache_get_attacker() called but supplied index [" .. tostring(index) .. "] is out of range");
		return false;
	end;
	
	-- support for savegames that have no military force info embedded
	local mf_cqi = self.pending_battle_cached_attackers[index].mf_cqi;
	
	if not mf_cqi then
		mf_cqi = -1;
	end;
	
	return self.pending_battle_cached_attackers[index].cqi, mf_cqi, self.pending_battle_cached_attackers[index].faction_name;
end;


function campaign_manager:pending_battle_cache_num_defenders()
	return #self.pending_battle_cached_defenders;
end;


function campaign_manager:pending_battle_cache_get_defender(index)
	if not is_number(index) or index < 0 or index > #self.pending_battle_cached_defenders then
		script_error("ERROR: pending_battle_cache_get_defender() called but supplied index [" .. tostring(index) .. "] is out of range");
		return false;
	end;
	
	-- support for savegames that have no military force info embedded
	local mf_cqi = self.pending_battle_cached_defenders[index].mf_cqi;
	
	if not mf_cqi then
		mf_cqi = -1;
	end;
	
	return self.pending_battle_cached_defenders[index].cqi, mf_cqi, self.pending_battle_cached_defenders[index].faction_name;
end;



function campaign_manager:pending_battle_cache_faction_was_attacker(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: pending_battle_cache_faction_was_attacker() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		if current_faction_name == faction_name then
			return true;
		end;
	end;
	
	return false;
end;


function campaign_manager:pending_battle_cache_faction_was_defender(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: pending_battle_cache_faction_was_defender() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;

	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		if current_faction_name == faction_name then
			return true;
		end;
	end;
	
	return false;
end;


function campaign_manager:pending_battle_cache_faction_was_involved(faction_name)
	return self:pending_battle_cache_faction_was_attacker(faction_name) or self:pending_battle_cache_faction_was_defender(faction_name);
end;


function campaign_manager:pending_battle_cache_human_was_attacker()
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		local query_faction = self:query_faction(current_faction_name);
		
		if query_faction and query_faction:is_human() then
			return true;
		end;
	end;
	
	return false;
end;


function campaign_manager:pending_battle_cache_human_was_defender()
	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		local query_faction = self:query_faction(current_faction_name);
		
		if query_faction and query_faction:is_human() then
			return true;
		end;
	end;
	
	return false;
end;


function campaign_manager:pending_battle_cache_human_was_involved()
	return self:pending_battle_cache_human_was_attacker() or self:pending_battle_cache_human_was_defender();
end;


function campaign_manager:pending_battle_cache_char_was_attacker(obj)
	local char_cqi;

	-- support passing in the actual character
	if is_query_character(obj) then
		char_cqi = obj:cqi();
	else
		char_cqi = obj;
	end;
	
	-- cast it to string
	char_cqi = tostring(char_cqi);
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		if current_char_cqi == char_cqi then
			return true;
		end;
	end;
	
	return false;
end;


function campaign_manager:pending_battle_cache_char_was_defender(obj)
	local char_cqi;

	-- support passing in the actual character
	if is_query_character(obj) then
		char_cqi = obj:cqi();
	else
		char_cqi = obj;
	end;
	
	-- cast it to string
	char_cqi = tostring(char_cqi);
	
	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		if current_char_cqi == char_cqi then
			return true;
		end;
	end;
	
	return false;
end;


function campaign_manager:pending_battle_cache_char_was_involved(obj)
	local char_cqi;

	-- support passing in the actual character
	if is_query_character(obj) then
		char_cqi = obj:cqi();
	else
		char_cqi = obj;
	end;
	
	return self:pending_battle_cache_char_was_attacker(char_cqi) or self:pending_battle_cache_char_was_defender(char_cqi);
end;


function campaign_manager:pending_battle_cache_mf_was_attacker(obj)
	local mf_cqi;
	
	if is_query_military_force(obj) then
		mf_cqi = obj:command_queue_index();
	else
		mf_cqi = obj;
	end;
	
	-- cast it to string
	mf_cqi = tostring(mf_cqi);
	
	for i = 1, self:pending_battle_cache_num_attackers() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_attacker(i);
		
		if current_mf_cqi == mf_cqi then
			return true;
		end;
	end;
	
	return false;
end;


function campaign_manager:pending_battle_cache_mf_was_defender(obj)
	local mf_cqi;
	
	if is_query_military_force(obj) then
		mf_cqi = obj:command_queue_index();
	else
		mf_cqi = obj;
	end;
	
	-- cast it to string
	mf_cqi = tostring(mf_cqi);
	
	for i = 1, self:pending_battle_cache_num_defenders() do
		local current_char_cqi, current_mf_cqi, current_faction_name = self:pending_battle_cache_get_defender(i);
		
		if current_mf_cqi == mf_cqi then
			return true;
		end;
	end;
	
	return false;
end;


function campaign_manager:pending_battle_cache_mf_was_involved(obj)
	local mf_cqi;

	-- support passing in the actual character
	if is_query_military_force(obj) then
		mf_cqi = obj:cqi();
	else
		mf_cqi = obj;
	end;
	
	return self:pending_battle_cache_mf_was_attacker(mf_cqi) or self:pending_battle_cache_mf_was_defender(mf_cqi);
end;


-- returns a table of characters that were the enemy of the supplied character in the pending battle (if applicable)
function campaign_manager:pending_battle_cache_get_enemies_of_char(character)
	if not is_character(character) then
		script_error("ERROR: pending_battle_cache_get_enemies_of_character() called but supplied character [" .. tostring(character) .. "] is not a character");
		return false;
	end;
	
	local retval = {};

	if self:pending_battle_cache_char_was_attacker(character) then
		for i = 1, self:pending_battle_cache_num_defenders() do
			table.insert(retval, cm:query_character(self:pending_battle_cache_get_defender(i)));
		end;
	
	elseif self:pending_battle_cache_char_was_defender(character) then
		for i = 1, self:pending_battle_cache_num_attackers() do
			table.insert(retval, cm:query_character(self:pending_battle_cache_get_attacker(i)));
		end;
	end;
	
	return retval;
end;




----------------------------------------------------------------------------
-- set svr values that can be tested in-battle
----------------------------------------------------------------------------

function campaign_manager:set_pending_battle_svr_state(pb)

	local primary_attacker_faction_name = "";
	local primary_attacker_subculture = "";
	local primary_defender_faction_name = "";
	local primary_defender_subculture = "";
	
	if pb:has_attacker() then
		primary_attacker_faction_name = pb:attacker():faction():name();
		primary_attacker_subculture = pb:attacker():faction():subculture();
	end;
	
	if pb:has_defender() then
		primary_defender_faction_name = pb:defender():faction():name();
		primary_defender_subculture = pb:defender():faction():subculture();
	end;
	
	core:svr_save_string("battle_type", pb:battle_type());
	core:svr_save_string("primary_attacker_faction_name", primary_attacker_faction_name);
	core:svr_save_string("primary_attacker_subculture", primary_attacker_subculture);
	core:svr_save_string("primary_defender_faction_name", primary_defender_faction_name);
	core:svr_save_string("primary_defender_subculture", primary_defender_subculture);
	
	-- only in sp
	if not self:is_multiplayer() then
		local local_faction = cm:get_local_faction();
		
		if primary_attacker_faction_name == local_faction then
			core:svr_save_bool("primary_attacker_is_player", true);
			core:svr_save_bool("primary_defender_is_player", false);
		elseif primary_defender_faction_name == local_faction then
			core:svr_save_bool("primary_attacker_is_player", false);
			core:svr_save_bool("primary_defender_is_player", true);
		else
			core:svr_save_bool("primary_attacker_is_player", false);
			core:svr_save_bool("primary_defender_is_player", false);
		end;
	end;
end;











----------------------------------------------------------------------------
-- starts a process which sends out an event each turn start notifying
-- listening scripts which is the region with the lowest public order for
-- the specified faction
----------------------------------------------------------------------------

function campaign_manager:find_lowest_public_order_region_on_turn_start(faction_key)

	if not is_string(faction_key) then
		script_error("ERROR: find_lowest_public_order_region_on_turn_start() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: find_lowest_public_order_region_on_turn_start() called but no faction with supplied name [" .. faction_key .. "] could be found");
		return false;
	end;

	core:add_listener(
		"find_lowest_public_order_region_on_turn_start",
		"ScriptEventPlayerFactionTurnStart",
		true,
		function(context)
			local lowest_public_order = 200;
			local lowest_public_order_region = false;
			local region_list = self:query_faction(faction_key):region_list();
			
			-- find lowest public order
			for i = 0, region_list:num_items() - 1 do
				local current_region = region_list:item_at(i);
				local current_public_order = current_region:public_order();
				
				if current_public_order < lowest_public_order then
					lowest_public_order = current_public_order;
					lowest_public_order_region = current_region;
				end;
			end;
			
			if lowest_public_order_region then
				output("*** triggering ScriptEventPlayerFactionTurnStartLowestPublicOrder, lowest_public_order_region is " .. lowest_public_order_region:name());
				core:trigger_event("ScriptEventPlayerFactionTurnStartLowestPublicOrder", lowest_public_order_region);
			end;
		end,
		true	
	);
end;







----------------------------------------------------------------------------
-- region_rebels events are generated as the player ends their turn but
-- before the FactionTurnEnd event is received. This mechanism just waits
-- for the FactionTurnEnd event and sends a separate event.
----------------------------------------------------------------------------

function campaign_manager:generate_region_rebels_event_for_faction(faction_key)
	
	if not is_string(faction_key) then
		script_error("ERROR: generate_region_rebels_event_for_faction() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: generate_region_rebels_event_for_faction() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;

	core:add_listener(
		"region_rebels_event_for_faction",
		"RegionRebels",
		function(context) return context:region():owning_faction():name() == faction_key end,
		function(context)
		
			local region_name = context:region():name();
		
			-- a region has rebelled, listen for the FactionTurnEnd event and send the message then
			core:add_listener(
				"region_rebels_event_for_faction",
				"FactionTurnEnd",
				function(context) return context:faction():name() == faction_key end,
				function(context)
					core:trigger_event("ScriptEventRegionRebels", self:query_faction(faction_key), self:query_region(region_name));
				end,
				false
			);
		end,
		true
	)
end;





----------------------------------------------------------------------------
-- listens for hero actions committed against a specified faction and sends
-- out further events based on the outcome
----------------------------------------------------------------------------


function campaign_manager:start_hero_action_listener(faction_key)

	-- listen for hero actions committed against characters in specified faction
	core:add_listener(
		"character_character_target_action_" .. faction_key,
		"CharacterCharacterTargetAction",
		function(context)
			return context:target_character():faction():name() == faction_key and context:character():faction():name() ~= faction_key;
		end,
		function(context)
			if context:mission_result_critial_success() or context:mission_result_success() then
				core:trigger_event("ScriptEventAgentActionSuccessAgainstCharacter", context:target_character());
			else
				core:trigger_event("ScriptEventAgentActionFailureAgainstCharacter", context:target_character());
			end;
		end,
		true
	);
	
	-- listen for hero actions committed against characters in specified faction
	core:add_listener(
		"character_character_target_action_" .. faction_key,
		"CharacterGarrisonTargetAction",
		function(context)
			return context:garrison_residence():faction():name() == faction_key and context:character():faction():name() ~= faction_key;
		end,
		function(context)
			if context:mission_result_critial_success() or context:mission_result_success() then
				core:trigger_event("ScriptEventAgentActionSuccessAgainstGarrison", context:garrison_residence());
			else
				core:trigger_event("ScriptEventAgentActionFailureAgainstGarrison", context:garrison_residence());
			end;
		end,
		true
	);
end;





----------------------------------------------------------------------------
-- disable_event_feed_events wrapper
-- for validation/output
----------------------------------------------------------------------------

function campaign_manager:disable_event_feed_events(disable, categories, subcategories, events)

	if not self:can_modify() then
		return;
	end;

	disable = disable or false;
	categories = categories or "";
	subcategories = subcategories or "";
	events = events or "";
	--out("disable_event_feed_events() called: ["..tostring(disable).."], ["..categories.."], ["..subcategories.."], ["..events.."]");
	
	if categories == "all" then
		local all_categories = "3k_event_category_characters;3k_event_category_diplomacy;3k_event_category_domestic;3k_event_category_faction;3k_event_category_military;3k_event_category_spies;3k_event_category_world"
		self:modify_scripting():disable_event_feed_events(disable, all_categories, subcategories, events);
	else
		self:modify_scripting():disable_event_feed_events(disable, categories, subcategories, events);
	end
end



----------------------------------------------------------------------------
-- show_message_event and show_message_event_located wrappers
-- for validation/output
----------------------------------------------------------------------------

function campaign_manager:show_message_event(faction_key, title_loc_key, primary_detail_loc_key, secondary_detail_loc_key, is_persistent, index_num, end_callback, delay, suppress_whitelist)	
	if not is_string(title_loc_key) then
		script_error("ERROR: show_message_event() called but supplied title localisation key [" .. tostring(title_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(primary_detail_loc_key) then
		script_error("ERROR: show_message_event() called but supplied primary detail localisation key [" .. tostring(primary_detail_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(secondary_detail_loc_key) then
		script_error("ERROR: show_message_event() called but supplied secondary detail localisation key [" .. tostring(secondary_detail_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_boolean(is_persistent) then
		script_error("ERROR: show_message_event() called but supplied is_persistent flag [" .. tostring(is_persistent) .. "] is not a boolean value");
		return false;
	end;
	
	if not is_number(index_num) then
		script_error("ERROR: show_message_event() called but supplied index number [" .. tostring(index_num) .. "] is not a number");
		return false;
	end;
	
	if end_callback and not is_function(end_callback) then
		script_error("ERROR: show_message_event() called but supplied end_callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if delay and not is_number(delay) then
		script_error("ERROR: show_message_event() called but supplied end_callback [" .. tostring(delay) .. "] is not a number or nil");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: show_message_event_located() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;
	
	out("show_message_event() called, showing event for faction [" .. faction_key .. "] with title [" .. title_loc_key .. "], primary detail [" .. primary_detail_loc_key .. "] and secondary detail [" .. secondary_detail_loc_key .. "]");
	
	if end_callback then
		output("\tsetting up progress listener");
		local progress_name = "show_message_event_" .. title_loc_key;
	
		core:add_listener(
			progress_name,
			"PanelOpenedCampaign",
			function(context) return context.string == "events" end,
			function()
				self:progress_on_events_dismissed(
					progress_name,
					end_callback,
					delay
				);
			end,
			false
		);
	else
		output("\tNOT setting up progress listener");
	end;
	
	if not suppress_whitelist then
		if is_persistent then
			cm:whitelist_event_feed_event_type("scripted_persistent_eventevent_feed_target_faction");
		else
			cm:whitelist_event_feed_event_type("scripted_transient_eventevent_feed_target_faction");
		end;
	end;
	
	self:modify_faction(faction_key):show_message_event_located(title_loc_key, primary_detail_loc_key, secondary_detail_loc_key, is_persistent, index_num);
end;


function campaign_manager:show_message_event_located(faction_key, title_loc_key, primary_detail_loc_key, secondary_detail_loc_key, x, y, is_persistent, index_num, end_callback, delay)	
	if not is_string(title_loc_key) then
		script_error("ERROR: show_message_event_located() called but supplied title localisation key [" .. tostring(title_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(primary_detail_loc_key) then
		script_error("ERROR: show_message_event_located() called but supplied primary detail localisation key [" .. tostring(primary_detail_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(secondary_detail_loc_key) then
		script_error("ERROR: show_message_event_located() called but supplied secondary detail localisation key [" .. tostring(secondary_detail_loc_key) .. "] is not a string");
		return false;
	end;
	
	if not is_number(x) then
		script_error("ERROR: show_message_event_located() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a number");
		return false;
	end;
	
	if not is_number(y) then
		script_error("ERROR: show_message_event_located() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a number");
		return false;
	end;
	
	if not is_boolean(is_persistent) then
		script_error("ERROR: show_message_event_located() called but supplied is_persistent flag [" .. tostring(is_persistent) .. "] is not a boolean value");
		return false;
	end;
	
	if not is_number(index_num) then
		script_error("ERROR: show_message_event_located() called but supplied index_num [" .. tostring(index_num) .. "] is not a number");
		return false;
	end;
	
	if end_callback and not is_function(end_callback) then
		script_error("ERROR: show_message_event_located() called but supplied end_callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if delay and not is_number(delay) then
		script_error("ERROR: show_message_event_located() called but supplied end_callback [" .. tostring(delay) .. "] is not a number or nil");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	if not self:faction_exists(faction_key) then
		script_error("ERROR: show_message_event_located() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;
	
	out("show_message_event_located() called, showing event for faction [" .. faction_key .. "] with title [" .. title_loc_key .. "], primary detail [" .. primary_detail_loc_key .. "] and secondary detail [" .. secondary_detail_loc_key .. "] at co-ordinates [" .. x .. ", " .. y .. "]");
	
	if end_callback then
		local progress_name = "show_message_event_located_" .. title_loc_key;
	
		core:add_listener(
			progress_name,
			"PanelOpenedCampaign",
			function(context) return context.string == "events" end,
			function()
				self:progress_on_events_dismissed(
					progress_name,
					end_callback,
					delay
				);
			end,
			false
		);
	end;
	
	self:modify_faction(faction_key):show_message_event_located(title_loc_key, primary_detail_loc_key, secondary_detail_loc_key, x, y, is_persistent, index_num);
end;




----------------------------------------------------------------------------
-- add_agent_experience wrapper
-- for validation/output
----------------------------------------------------------------------------

function campaign_manager:add_agent_experience(char_str, exp_to_give)
	out("add_agent_experience() called, char_str is " .. tostring(char_str) .. " and experience to give is " .. tostring(exp_to_give));
	return self:modify_scripting():add_agent_experience(char_str, exp_to_give);
end;





----------------------------------------------------------------------------
-- campaign subtitles
----------------------------------------------------------------------------

function campaign_manager:show_subtitle(key, full_key_supplied, should_force)

	if not is_string(key) then
		script_error("ERROR: show_subtitle() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	-- only proceed if we're forcing the subtitle to play, or if the subtitle preferences setting is on
	if not should_force and not effect.subtitles_enabled() then
		return;
	end;
	
	local full_key;
	
	if not full_key_supplied then
		full_key = "scripted_subtitles_localised_text_" .. key;
	else
		full_key = key;
	end;
	
	local localised_text = effect.get_localised_string(full_key);
	
	if not is_string(localised_text) then
		script_error("ERROR: show_subtitle() called but could not find any localised text corresponding with supplied key [" .. tostring(key) .. "] in scripted_subtitles table");
		return false;
	end;

	local ui_root = core:get_ui_root();
	
	output("show_subtitle() called, supplied key is [" .. key .. "] and localised text is [" .. localised_text .. "]");

	-- create the subtitles component if it doesn't already exist
	if not self.subtitles_component_created then
		ui_root:CreateComponent("scripted_subtitles", "UI/Campaign UI/scripted_subtitles");
		self.subtitles_component_created = true;
	end;
	
	-- find the subtitles component
	local uic_subtitles = find_uicomponent(ui_root, "scripted_subtitles", "text_child");
	
	if not uic_subtitles then
		script_error("ERROR: show_subtitles() could not find the scripted_subtitles uicomponent");
		return false;
	end;
	
	-- set the text on it
	uic_subtitles:SetStateText(localised_text);
	
	-- make the subtitles component visible if it's not already
	if not self.subtitles_visible then
		uic_subtitles:SetVisible(true);
		uic_subtitles:RegisterTopMost();
		self.subtitles_visible = true;
	end;
	
	output_uicomponent(uic_subtitles);
end;



function campaign_manager:hide_subtitles()
	if self.subtitles_visible then
		-- find the subtitles component
		local uic_subtitles = find_uicomponent(core:get_ui_root(), "scripted_subtitles", "text_child");
		if uic_subtitles then
			uic_subtitles:RemoveTopMost();
			uic_subtitles:SetVisible(false);
		end
		self.subtitles_visible = false;
	end;
end;




----------------------------------------------------------------------------
-- campaign manager generated null interface
----------------------------------------------------------------------------
function campaign_manager:null_interface()
	local null_interface = {};
	
	null_interface.is_null_interface = function() return true end;
	
	return null_interface;
end;









-----------------------------------------------------------------------------
-- benchmark script loader
-----------------------------------------------------------------------------

function campaign_manager:show_benchmark_if_required(non_benchmark_callback, cindy_str, duration, start_x, start_y, start_d, start_b, start_h)

	if not is_function(non_benchmark_callback) then
		script_error("ERROR: show_benchmark_if_required() called but supplied callback [" .. tostring(non_benchmark_callback) .. "] is not a function");
		return false;
	end;
	
	if not is_string(cindy_str) then
		script_error("ERROR: show_benchmark_if_required() called but supplied cindy path [" .. tostring(cindy_str) .. "] is not a string");
		return false;
	end;
	
	if not is_number(duration) or duration <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied duration [" .. tostring(duration) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(start_x) or start_x <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied start x co-ordinate [" .. tostring(start_x) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(start_y) or start_y <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied start y co-ordinate [" .. tostring(start_y) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(start_d) or start_d <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied start camera distance [" .. tostring(start_d) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not is_number(start_b) then
		script_error("ERROR: show_benchmark_if_required() called but supplied start camera bearing [" .. tostring(start_b) .. "] is not a number");
		return false;
	end;
	
	if not is_number(start_h) or start_h <= 0 then
		script_error("ERROR: show_benchmark_if_required() called but supplied start camera height [" .. tostring(start_h) .. "] is not a number greater than zero");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	if not self:query_model():is_benchmark_mode() then
		-- don't do benchmark camera pan
		non_benchmark_callback();
		return;
	end;
	
	out("*******************************************************************************");
	out("show_benchmark_if_required() is showing benchmark");
	out("showing cindy scene: " .. cindy_str .. " with duration " .. tostring(duration));
	out("*******************************************************************************");
	
	
	local ui_root = core:get_ui_root();
	
	self:set_camera_position(start_x, start_y, start_d, start_b, start_h);

	-- fade out shroud instantly (duration, target alpha)
	self:modify_scripting():fade_shroud(0, 0);

	self:modify_scripting():show_shroud(false);	
	CampaignUI.ToggleCinematicBorders(true);
	ui_root:LockPriority(50)
	self:modify_scripting():override_ui("disable_settlement_labels", true);
	self:cindy_playback(cindy_str, true, true);
	
	self:callback(
		function()
			ui_root:UnLockPriority();
			interface_function(ui_root, "QuitForScript");
		end,
		duration
	);
end;




-----------------------------------------------------------------------------
-- Campaign accessor for cinematic handle
-----------------------------------------------------------------------------
function campaign_manager:get_cinematic()
	return self:modify_scripting():cinematic();
end;


----------------------------------------------------------------------------
--	Cutscenes
----------------------------------------------------------------------------

function campaign_manager:register_cutscene(cutscene)
	if not is_campaigncutscene(cutscene) then
		script_error("ERROR: register_cutscene() called but supplied object [" .. tostring(cutscene) .. "] is not a campaign cutscene");
		return false;
	end;
	
	table.insert(self.cutscene_list, cutscene);
end;



function campaign_manager:is_any_cutscene_running()

	if #self.cutscene_list == 0 then		
		return false;
	end;
	
	for i = 1, #self.cutscene_list do
		if self.cutscene_list[i]:is_active() then
			return true;
		end;
	end;
	
	return false;
end;


-- skips any running campaign cutscene
function campaign_manager:skip_all_campaign_cutscenes()
	local cm = get_cm();
	for i = 1, #self.cutscene_list do
		self.cutscene_list[i]:skip();
	end;
end;



----------------------------------------------------------------------------
--	key stealing
----------------------------------------------------------------------------

-- actually steal the escape key
function campaign_manager:steal_escape_key(value)
	if value and not self.escape_key_stolen then
		out(" * Stealing ESC key");
		self.escape_key_stolen = true;
		self:modify_scripting():steal_escape_key(true);
	else
		out(" * Releasing ESC key");
		self.escape_key_stolen = false;
		self:modify_scripting():steal_escape_key(false);
	end;
end;


-- actually steal user input
function campaign_manager:steal_user_input(value)
	if value and not self.user_input_stolen then
		out(" * Stealing user input");
		self.user_input_stolen = true;
		self:modify_scripting():steal_user_input(true);
	elseif not value and self.user_input_stolen then
		out(" * Releasing user input");
		self.user_input_stolen = false;
		self:modify_scripting():steal_user_input(false);
	end;
end;


function campaign_manager:on_key_press_up(key)
	-- if anything has stolen this key, then execute the callback on the top of the relevant stack, then remove it
	local key_table = self.stolen_keys[key];
	if is_table(key_table) and #key_table > 0 then
		local callback = key_table[#key_table].callback;
		table.remove(key_table, #key_table);
		callback();
	end;
end;


-- debug output of key steal entries
function campaign_manager:print_key_steal_entries()
	out.inc_tab();
	out("*****");
	out("printing key_steal_entries");
	for key, entries in pairs(self.stolen_keys) do
		out("\tkey " .. key);
		for i = 1, #entries do
			local entry = entries[i];
			out("\t\tentry " .. i .. " name is " .. entry.name .. " and callback is " .. tostring(entry.callback));
		end;
	end;
	out("*****");
	out.dec_tab();
end;


-- Steal a key, and register a callback to be called when it's pressed. It will be un-stolen when this occurs.
-- steal_user_input() will need to be called separately for this mechanism to work, unless it's the escape key where steal_escape_key()
-- may be called instead (or preferably use the steal_escape_key_with_callback() wrapper below)
function campaign_manager:steal_key_with_callback(name, key, callback)
	if not is_string(name) then
		script_error("ERROR: steal_key_with_callback() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	if not is_string(key) then
		script_error("ERROR: steal_key_with_callback() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	-- create a table for this key if one doesn't already exist
	if not is_table(self.stolen_keys[key]) then
		self.stolen_keys[key] = {};
	end;

	local key_steal_entries_for_key = self.stolen_keys[key];
	
	-- don't proceed if a keysteal entry with this name already exists
	for i = 1, #key_steal_entries_for_key do
		if key_steal_entries_for_key[i].name == name then
			script_error("ERROR: steal_key_with_callback() called but a steal entry with supplied name [" .. name .. "] already exists for supplied key [" .. tostring(key) .. "]");
			return false;
		end;
	end;
	
	-- create a key steal entry
	local key_steal_entry = {
		["name"] = name,
		["callback"] = callback
	};
	
	-- add this key steal entry at the end of the list
	table.insert(key_steal_entries_for_key, key_steal_entry);
	
	return true;
end;


-- releases a key stolen with steal_key_with_callback()
function campaign_manager:release_key_with_callback(name, key)
	if not is_string(name) then
		script_error("ERROR: release_key_with_callback() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	if not is_string(key) then
		script_error("ERROR: release_key_with_callback() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	local key_steal_entries_for_key = self.stolen_keys[key];
	
	for i = 1, #key_steal_entries_for_key do
		if key_steal_entries_for_key[i].name == name then
			table.remove(key_steal_entries_for_key, i);
			break;
		end;
	end;
	
	return true;
end;


-- wrapper to steal the escape key with a callback
function campaign_manager:steal_escape_key_with_callback(name, callback)	
	-- attempt to steal the escape key if our attempt to register a callback succeeds
	if self:steal_key_with_callback(name, "ESCAPE", callback) then
		self:steal_escape_key(true);
	end;
end;


-- wrapper to release the escape key with a callback
function campaign_manager:release_escape_key_with_callback(name)
	-- attempt to release the escape key if our attempt to unregister a callback succeeds, and if the list of things now listening for the escape key is empty	
	if self:release_key_with_callback(name, "ESCAPE") then
		local esc_key_stealers = self.stolen_keys["ESCAPE"];
		if is_table(esc_key_stealers) and #esc_key_stealers == 0 then
			self:steal_escape_key(false);
		end;
	end;
end;



-- wrapper to steal escape key and spacebar with callback
function campaign_manager:steal_escape_key_and_space_bar_with_callback(name, callback)
	if self:steal_key_with_callback(name, "SPACE", callback) then
		self:steal_escape_key_with_callback(name, callback);
	end;
end;


-- wrapper to release escape key and spacebar with callback
function campaign_manager:release_escape_key_and_space_bar_with_callback(name)
	if self:release_key_with_callback(name, "SPACE", callback) then
		self:release_escape_key_with_callback(name, callback);
	end;
end;

--- function get_closest_general_to_position_from_faction
function campaign_manager:get_closest_general_to_position_from_faction(faction, x, y, consider_garrison_commanders)
	return self:get_closest_character_to_position_from_faction(faction, x, y, true, consider_garrison_commanders);
end;


--- function get_closest_character_to_position_from_faction
function campaign_manager:get_closest_character_to_position_from_faction(faction, x, y, generals_only, consider_garrison_commanders)
	generals_only = not not generals_only;
	consider_garrison_commanders = not not consider_garrison_commanders;
	
	if not generals_only then
		consider_garrison_commanders = true;
	end;

	local faction_found = false;
	
	if is_string(faction) then
		faction = cm:query_faction(faction);
		if faction then
			faction_found = true;
		end;
	end;
	
	if not faction_found then
		script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied faction [" .. tostring(faction) .. "] is not a valid faction, or a string name of a faction");
		return false;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return false;
	end;
	
	local char_list = faction:character_list();
	local closest_char = false;
	local closest_distance_squared = 100000000;
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		-- if we aren't only looking for generals OR if we are and this is a general AND if we are considering garrison commanders OR if we aren't and it is a general proceed
		if not generals_only or (current_char:has_military_force() and (consider_garrison_commanders or not current_char:military_force():is_armed_citizenry())) then			
			local current_char_x, current_char_y = char_logical_pos(current_char);
			local current_distance_squared = distance_squared(x, y, current_char_x, current_char_y);
			if current_distance_squared < closest_distance_squared then
				closest_char = current_char;
				closest_distance_squared = current_distance_squared;
			end;
		end;
	end;
	
	return closest_char, closest_distance_squared ^ 0.5;
end;



-----------------------------------------------------------------------------
-- get preferences
-----------------------------------------------------------------------------

function campaign_manager:get_preference_bool(preference_key)
	return CampaignUI.PrefAsBool( preference_key );
end;