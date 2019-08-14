




----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CAMPAIGN UI MANAGER
--
--- @loaded_in_campaign
--- @class campaign_ui_manager Campaign UI Manager
--- @desc TBD!
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------




----------------------------------------------------------------------------
--	Definition
----------------------------------------------------------------------------

campaign_ui_manager = {
	cm = false,
	
	-- table of end turn warnings and the custom script events to fire
	end_turn_warning_types = {
		["bankrupt"] = "ScriptEventBankruptcyWarningIssued",
		["tech"] = "ScriptEventTechnologyWarningIssued",
		["edict"] = "ScriptEventCommandmentWarningIssued",
		["character"] = "ScriptEventCharacterSkillPointWarningIssued",
		["army"] = "ScriptEventMilitaryForceSkillPointWarningIssued",
		["politics"] = "ScriptEventOverseerWarningIssued",
		["siege"] = "ScriptEventSiegeNoEquipmentWarningIssued",
		["morale"] = "ScriptEventMoraleWarningIssued"
	},
	
	-- end of turn warning suppression system
	end_of_turn_warnings_to_suppress = {},
	end_of_turn_warning_suppression_system_started = false,
	
	-- ui overrides
	override_list = {},
	should_save_override_state = true,
	
	-- whitelists
	character_selection_whitelist = {},
	settlement_selection_whitelist = {},
	all_whitelists_disabled = false,
	
	-- selection listeners
	panels_open = {},
	character_selected = "",
	character_selected_faction = "",
	settlement_selected = "",
	
	-- highlighting
	highlighted_settlements_vfx = {},
	highlighted_settlements_markers = {},
	highlighted_settlements_near_camera = {},
	highlighted_characters_vfx = {},
	highlighted_characters_markers = {},
	highlighted_characters_near_camera = {},
	
	-- modal queue and ui locking
	modal_queue = {},
	modal_section_active = false,
	modal_system_locked = false,
	ui_locked = false,
	
	-- multiple calling scripts can lock the ui, the ui only gets unlocked when the lock level reaches 0
	ui_lock_level = 0,
	event_panel_auto_open_lock_level = 0,
	
	-- visibility state of various ui features (that get hidden on the first turn)
	faction_buttons_displayed = true,
	resources_bar_displayed = true,
	
	-- list of fullscreen panels
	fullscreen_panels = {
		"faction_summary_panel",
		--"family_court_panel",
		"event_feed_records",
		"diplomacy_panel",
		"tech_panel",
		"undercover_network_panel",
		"esc_menu_campaign",
		"scripted_sequence",
		"event_single"
	};
	
	output_stamp = 0,
	
	diplomacy_audio_lock_level = 0,
	
	button_pulse_strength = 10,
	panel_pulse_strength = 5,
	
	help_page_link_highlighting_permitted = true,
	
	unhighlight_action_list = {}
};




----------------------------------------------------------------------------
--	Creation
----------------------------------------------------------------------------


function campaign_ui_manager:new()
	
	local cm = get_cm();
	
	-- there can only be one of these objects, if the cm already has a link to one return that instead
	if cm.campaign_ui_manager then
		return cm.campaign_ui_manager;
	end;
	
	-- check that the ui isn't already initialised or the game is not already loaded
	if core:is_ui_created() then
		script_error("ERROR: an attempt was made to create a campaign_ui_manager object but the UI has already been initialised or the game has already been loaded. Create this object earlier.");
		return false;
	end;

	local ui = {};
	
	setmetatable(ui, self);
	self.__index = self;
	self.__tostring = function() return TYPE_CAMPAIGN_UI_MANAGER end;
	
	ui.cm = cm;
	
	-- end of turn warning suppression system
	local warnings_to_suppress = {};
	
	warnings_to_suppress.bankrupt = false;
	warnings_to_suppress.tech = false;
	warnings_to_suppress.edict = false;
	warnings_to_suppress.character = false;
	warnings_to_suppress.army = false;
	warnings_to_suppress.politics = false;
	warnings_to_suppress.siege = false;
	warnings_to_suppress.morale = false;
	
	ui.end_of_turn_warnings_to_suppress = warnings_to_suppress;
	
	-- start end of turn warning listener automatically
	ui:start_end_of_turn_warning_listener_system();
	
	-- ui overrides
	ui.override_list = {};
	
	cm:add_pre_first_tick_callback(
		function(context) 
			if not cm:is_multiplayer() then
				ui:set_all_overrides();
			end;
		end
	);
	
	cm:add_saving_game_callback(function(context) ui:save_override_state(context) end);
	cm:add_loading_game_callback(function(context) ui:load_override_state(context) end);
	
	-- selection whitelists
	ui.character_selection_whitelist = {};
	
	-- selection listeners
	ui.panels_open = {};
	
	-- highlighting
	ui.highlighted_settlements_vfx = {};
	ui.highlighted_settlements_markers = {};
	ui.highlighted_characters_vfx = {};
	ui.highlighted_characters_markers = {};
	ui.highlighted_settlements_near_camera = {};
	ui.highlighted_characters_near_camera = {};
	ui.unhighlight_action_list = {};
	
	-- modal queue
	ui.modal_queue = {};
	
	-- register this object with the campaign manager
	cm.campaign_ui_manager = ui;
	
	ui:start_campaign_ui_listeners();
	
	-- load in ui overrides
	ui:load_ui_overrides();
	
	return ui;
end;






----------------------------------------------------------------------------
--	End of Turn warning listener system
----------------------------------------------------------------------------

-- started automatically with the uim
-- listens for the eot warning panel, works out what warnings are present and fires custom script events to notify any listeners
function campaign_ui_manager:start_end_of_turn_warning_listener_system()
	core:add_listener(
		"end_of_turn_warning_listener_system",
		"PanelOpenedCampaign",
		function(context) return context.string == "end_turn_warning" end,
		function(context) self:end_of_turn_warnings_displayed_for_listener(context) end,	
		true
	);
end;


function campaign_ui_manager:end_of_turn_warnings_displayed_for_listener(context)
	local cm = self.cm;
	
	local uic_warnings_list = find_uicomponent(core:get_ui_root(), "end_turn_warning", "warnings_list", "list_clip", "list_box");
	
	if not uic_warnings_list then
		script_error("ERROR: end_of_turn_warnings_displayed_for_listener() couldn't find uic_warnings_list");
		return false;
	end;
	
	-- make a list of all children of the warnings list, removing the _x appended to the end
	local warnings_list = {};
	for i = 0, uic_warnings_list:ChildCount() - 1 do
		local warning = UIComponent(uic_warnings_list:Find(i)):Id();
		
		-- find the last underscore in the name of the component (there should only really be one)
		local search_pos = 1;
		local last_underscore_pos = 0;
		
		while search_pos do
			search_pos = string.find(warning, "_", last_underscore_pos + 1);
			if search_pos then
				last_underscore_pos = search_pos;
			else
				break;
			end;
		end;
		
		if last_underscore_pos > 0 then
			warning = string.sub(warning, 1, last_underscore_pos - 1);
		end;
		
		table.insert(warnings_list, warning);
	end;
	
	local end_turn_warning_types = self.end_turn_warning_types;
	
	for warning_type, event_message in pairs(end_turn_warning_types) do
		
		for i = 1, #warnings_list do
			if warnings_list[i] == warning_type then
				core:trigger_event(event_message);
				break;
			end;
		end;
	end;
end;




----------------------------------------------------------------------------
--	End of Turn warning suppression system
----------------------------------------------------------------------------

-- starts this system
-- dont call this externally - use suppress_end_of_turn_warning() and the
-- system will start automatically
function campaign_ui_manager:start_end_of_turn_warning_suppression_system()
	if self.end_of_turn_warning_suppression_system_started then
		return;
	end;
		
	core:add_listener(
		"end_of_turn_warning_suppression_system",
		"PanelOpenedCampaign",
		function(context) return context.string == "end_turn_warning" end,
		function() self:end_of_turn_warnings_displayed_for_suppression() end,
		true		
	);
	
	self.end_of_turn_warning_suppression_system_started = true;
end;


-- stops this system
function campaign_ui_manager:stop_end_of_turn_warning_suppression_system()
	core:remove_listener("end_of_turn_warning_suppression_system");
	
	self.end_of_turn_warning_suppression_system_started = false;
end;


-- called when the system is started and the end turn warnings panel appears
function campaign_ui_manager:end_of_turn_warnings_displayed_for_suppression()
	-- get a handle to the end turn warning panel
	local uic_warnings_panel = find_uicomponent(core:get_ui_root(), "end_turn_warning");
	
	if not uic_warnings_panel then
		script_error("ERROR: end_of_turn_warnings_displayed_for_suppression() cannot find uic_warnings_panel");
		return false;
	end;
	
	-- for each of our warnings types, we must check if it's not suppressed and enable the warning if so
	for k, v in pairs(self.end_of_turn_warnings_to_suppress) do
		if not v then
			-- uic_warnings_panel:InterfaceFunction("enable_warning_for_script", k);
			interface_function(uic_warnings_panel, "enable_warning_for_script", k);
		end;
	end;
end;


-- sets the desired state of an end of turn warning, to be called externally
function campaign_ui_manager:suppress_end_of_turn_warning(warning, value)
	if not (self.end_of_turn_warnings_to_suppress[warning] == true or self.end_of_turn_warnings_to_suppress[warning] == false) then
		script_error("ERROR: suppress_end_of_turn_warning() called but supplied warning [" .. tostring(warning) .. "] not recognised");
		return false;
	end;
	
	self.end_of_turn_warnings_to_suppress[warning] = not not value;
	
	self:update_end_of_turn_warning_suppression_system();
end;


-- called when an end of turn warning state is changed by suppress_end_of_turn_warning
-- re-assesses whether we need to start or stop this system
function campaign_ui_manager:update_end_of_turn_warning_suppression_system()

	local all_warnings_unsuppressed = true;
	local all_warnings_suppressed = true;

	-- go through all our warnings and see if either all of them or none of them are active
	for k, v in pairs(self.end_of_turn_warnings_to_suppress) do
		if v then
			all_warnings_unsuppressed = false;
		else
			all_warnings_suppressed = false;
		end;
	end;
	
	-- if all warnings are suppressed then disable all warnings
	local override = self:override("end_of_turn_warnings");
	if all_warnings_suppressed then
		override:lock();
	-- otherwise if we are currently disabling all warnings, un-disable this
	elseif override:is_locked() then
		override:unlock();
	end;
	
	-- start or stop this whole system if appropriate
	if not self.end_of_turn_warning_suppression_system_started and not all_warnings_unsuppressed then
		self:start_end_of_turn_warning_suppression_system();
	elseif self.end_of_turn_warning_suppression_system_started and all_warnings_unsuppressed then
		self:stop_end_of_turn_warning_suppression_system();
	end;
end;









----------------------------------------------------------------------------
--	Output Stamps
--	This gets a number that helps sync output between
--	lua tabs. The campaign ui manager can be quite
--	verbose so it was found to be better to put that
--	output onto a different tab and use a stamp to
--	sync output
----------------------------------------------------------------------------

function campaign_ui_manager:get_next_output_stamp()
	self.output_stamp = self.output_stamp + 1;
	return self.output_stamp;
end;









----------------------------------------------------------------------------
--	Locking/Unlocking UI
----------------------------------------------------------------------------

--	lock_ui()
--	Enables whitelists and cycles through all 
--	registered overrides and locks them. This 
--	turns off the associated area of the UI.
--	Useful for directing the player's attention to
--	specific areas of the UI during sections of
--	modal/corridor gameplay.
function campaign_ui_manager:lock_ui()
	self.ui_lock_level = self.ui_lock_level + 1;
	
	-- script_error("lock_ui() called, ui_lock_level is now " .. self.ui_lock_level);

	if self.ui_locked then
		return;
	end;
	
	self.ui_locked = true;
	
	local cm = self.cm;
	
	local stamp = self:get_next_output_stamp();
	local out_str = "lock_ui() called, output stamp is " .. tostring(stamp);
	
	output(out_str);
	out.ui();
	out.ui("****************");
	out.ui(out_str);
	inc_tab();
	
	---------------------------------------
	-- Lock ui overrides
	---------------------------------------
	
	--[[
	for override_name, override in pairs(self.override_list) do
		override:lock(false, true, true);
	end;
	]]
	self:override("end_turn"):lock(false, false, true);
	self:override("giving_orders"):lock(false, false, true);
	self:override("events_rollout"):lock(false, false, true);
	self:override("prebattle_attack_for_advice"):lock(false, false, true);
	self:override("autoresolve_for_advice"):lock(false, false, true);
	
	dec_tab();
	out.ui("ending lock_ui() output, stamp " .. tostring(stamp));
	out.ui("****************");
end;











--	unlock_ui()
--	Disables whitelists and cycles through all 
--	registered overrides and unlocks them. This allows
--	the player to access those ui features, assuming
--	that the overrides are allowed.
function campaign_ui_manager:unlock_ui()

	-- decrement ui_lock_level if it's greater than 0, and only unlock if it was 1 (and is hence now 0)
	local should_unlock = false;
	
	if self.ui_lock_level == 1 then
		should_unlock = true;
	end;
	
	if self.ui_lock_level > 0 then
		self.ui_lock_level = self.ui_lock_level - 1;
	end;
	
	-- script_error("unlock_ui() called, ui_lock_level is now " .. self.ui_lock_level .. ", should_unlock is " .. tostring(should_unlock));
	
	if not should_unlock then
		return;
	end;
	
	self.ui_locked = false;
	
	local cm = self.cm;
	
	local stamp = self:get_next_output_stamp();
	
	local out_str = "unlock_ui() called, output stamp is " .. tostring(stamp);
	
	output(out_str);
	out.ui();
	out.ui("****************");
	out.ui(out_str);
	inc_tab();
	
	---------------------------------------
	-- Unlock ui overrides
	---------------------------------------
	--[[
	for override_name, override in pairs(self.override_list) do
		override:unlock(false, true);
	end;
	]]
	
	self:override("end_turn"):unlock(false, true);
	self:override("giving_orders"):unlock(false, true);
	self:override("events_rollout"):unlock(false, true);
	
	dec_tab();
	out.ui("ending unlock_ui() output, stamp " .. tostring(stamp));
	out.ui("****************");
end;





-----------------------------------------------------------------------------
--	enable_event_panel_auto_open
--	the disable_event_panel_auto_open override prevents event panels from
--	opening automatically
-----------------------------------------------------------------------------

-- toggle event panel auto open
function campaign_ui_manager:enable_event_panel_auto_open(value)
	if value then
		-- only unlock if the lock_level hits 0
		local should_unlock = false;
		
		if self.event_panel_auto_open_lock_level == 1 then
			should_unlock = true;
		end;
		
		if self.event_panel_auto_open_lock_level > 0 then
			self.event_panel_auto_open_lock_level = self.event_panel_auto_open_lock_level - 1;
		end;
		
		if not should_unlock then
			return;
		end;

		output(">> enable_event_panel_auto_open() allowing event panels");
	
		self.cm:modify_scripting():override_ui("disable_event_panel_auto_open", false);
	else
		self.event_panel_auto_open_lock_level = self.event_panel_auto_open_lock_level + 1;
	
		if self.event_panel_auto_open_lock_level > 1 then
			return;
		end;
		
		output(">> enable_event_panel_auto_open() preventing event panels");
		
		self.cm:modify_scripting():override_ui("disable_event_panel_auto_open", true);
	end;
end;














-- allows client script to set whether the uim should save override states, defaults to true. If this is set
-- to false then ui overrides will not save their states and all ui overrides will be inactive when the game
-- is reloaded
function campaign_ui_manager:set_should_save_override_state(value)
	if value == false then
		self.should_save_override_state = false;
	else
		self.should_save_override_state = true;
	end;
end;





--	set_all_overrides()
--	During campaign startup it's common to set the
--	state of ui overrides before the UI is created.
--	Attempting to manipulate UI objects at this time
--	would cause a crash, so if the UI is not ready
--	the ui overrides instead defer their manipulations 
--	until set_all_overrides() is called.
function campaign_ui_manager:set_all_overrides()
	local stamp = self:get_next_output_stamp();
	local out_str = "set_all_overrides() called, output stamp is " .. tostring(stamp);
	
	output(out_str);
	out.ui();
	out.ui("****************");
	out.ui(out_str);
	inc_tab();

	for override_name, override in pairs(self.override_list) do
		if override:get_allowed() then
			override:unlock(true, true);
		else
			override:lock(true);
		end;
	end;
	
	dec_tab();
	out.ui("ending set_all_overrides() output, stamp " .. tostring(stamp));
	out.ui("****************");
end;


--	reset_all_overrides()
--	Called on campaign shutdown - allows all overrides
function campaign_ui_manager:reset_all_overrides()
	local stamp = self:get_next_output_stamp();
	local out_str = "reset_all_overrides() called, output stamp is " .. tostring(stamp);
	
	output(out_str);
	out.ui();
	out.ui("****************");
	out.ui(out_str);
	inc_tab();

	for override_name, override in pairs(self.override_list) do
		override:set_allowed(true, true);
	end;
	
	dec_tab();
	out.ui("ending reset_all_overrides() output, stamp " .. tostring(stamp));
	out.ui("****************");
end;


--	save_override_state()
--	To be called on game save. Saves the state of
--	disallowed ui overrides into the savegame.
function campaign_ui_manager:save_override_state(context)	
	local save_str = "";
	
	if self.should_save_override_state then
		for override_name, override in pairs(self.override_list) do		
			if not override:get_allowed() then
				save_str = save_str .. override.name .. ";";
			end;
		end;
	end;
	
	self.cm:save_named_value("campaign_ui_manager_disallowed_overrides", save_str);
end;


--	load_override_state()
--	To be called on game load. Loads the state of
--	disallowed ui overrides from the samegame.
function campaign_ui_manager:load_override_state(context)
	-- read in a single string from the savegame (always do this, so that it's saved into the savegame)
	local load_str = self.cm:load_named_value("campaign_ui_manager_disallowed_overrides", "");

	local stamp = self:get_next_output_stamp();
	local out_str = "load_override_state() called, output stamp is " .. tostring(stamp);
	
	output(out_str);
	out.ui();
	out.ui("****************");
	out.ui(out_str);
	inc_tab();
	
	-- load the overrides if we're set to do so
	if self.should_save_override_state then
		-- pattern match the string ([^,]+ matches comma-delimited strings of length greater than 0)
		-- and disallow any overrides found
		for override_name in string.gmatch(load_str, "[^;]+") do
			out("Setting internal state of override with name " .. tostring(override_name))	
			self.override_list[override_name]:set_allowed(false);
		end;
	else
		out.ui("\tshould_save_override_state is false, not loading anything");
	end;

	dec_tab();
	out.ui("ending load_override_state() output, stamp " .. tostring(stamp));
	out.ui("****************");
end;



















----------------------------------------------------------------------------
--	Disable Whitelists
--	Commands to blanket enable/disable character and settlement whitelist
--	systems
----------------------------------------------------------------------------

function campaign_ui_manager:enable_all_whitelists(value)
	if value == false then
		self.all_whitelists_disabled = true;
	else
		self.all_whitelists_disabled = false;
	end;
end;







----------------------------------------------------------------------------
--	Character Whitelist System
--	This system allows the scripter to designate a whitelist of
--	characters that can be selected (other characters that are clicked
--	on are immediately deselected before any visual update is given to
--	the player). By activating the system with no characters in the 
--	whitelist, the player won't be able to select any generals/agents etc.
----------------------------------------------------------------------------


--	Returns the index if a character exists in our whitelist, false
--	otherwise. Mainly for internal use.
function campaign_ui_manager:find_character_selection_whitelist(cqi)
	for i = 1, #self.character_selection_whitelist do
		if self.character_selection_whitelist[i] == cqi then
			return i;
		end;
	end;
	
	return false;
end;


--	Adds a character to the whitelist
function campaign_ui_manager:add_character_selection_whitelist(cqi)
	if not is_number(cqi) then
		script_error("ERROR: add_character_selection_whitelist() called but supplied cqi [" .. tostring(cqi) .. "] is not a number");
		return false;
	end;

	if self:find_character_selection_whitelist(cqi) then
		return false;
	end;
		
	output("Adding character to selection whitelist :: cqi:" .. tostring(cqi));
	
	table.insert(self.character_selection_whitelist, cqi);
end;


--	Removes a character from the whitelist
function campaign_ui_manager:remove_character_selection_whitelist(cqi)
	local entry_to_remove = find_character_selection_whitelist(cqi);
	
	if not entry_to_remove then
		return;
	end;
	
	output("Removing character from selection whitelist :: cqi: " .. cqi);
	
	table.remove(self.character_selection_whitelist, entry_to_remove);
end;


--	Removes all characters from the whitelist
function campaign_ui_manager:clear_character_selection_whitelist()
	output("Clearing character selection whitelist");
	self.character_selection_whitelist = {};
end;


--	Enables the whitelist, so that it starts being enforced
function campaign_ui_manager:enable_character_selection_whitelist()
	
	self:disable_character_selection_whitelist(true);
	
	output("Enabling character selection whitelist");
	
	if not self.all_whitelists_disabled then
		core:add_listener(
			"character_selected_whitelist",
			"CharacterSelected",
			true,
			function(context)		
				local character_selected = context:character();
				
				if not self:find_character_selection_whitelist(character_selected:cqi()) then
					CampaignUI.ClearSelection();
				end;
			end,
			true
		);
	end;
end;


--	Disable the whitelist, so that it stops being enforced
function campaign_ui_manager:disable_character_selection_whitelist(no_output)
	if not no_output then
		output("Disabling character selection whitelist");
	end;

	core:remove_listener("character_selected_whitelist");
end;


--	Shorthand methods to add all characters from a faction to whitelist
function campaign_ui_manager:add_all_characters_for_faction_selection_whitelist(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: add_all_characters_for_faction_selection_whitelist() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	local query_faction = cm:query_faction(faction_name);
	
	if not query_faction then
		script_error("ERROR: add_all_characters_for_faction_selection_whitelist() called but couldn't find faction with name [" .. tostring(faction_name) .. "]");
		return false;
	end;
	
	local character_list = query_faction:character_list();
	
	output("add_all_characters_for_faction_selection_whitelist() called for faction " .. faction_name);
	inc_tab();	
	for i = 0, character_list:num_items() - 1 do
		self:add_character_selection_whitelist(character_list:item_at(i):cqi());
	end;
	dec_tab();
end;









----------------------------------------------------------------------------
--	Settlement Whitelist System
--	This system allows the scripter to designate a whitelist of
--	settlements that can be selected (other settlements that are clicked
--	on are immediately deselected before any visual update is given to
--	the player). By activating the system with no settlements in the 
--	whitelist, the player won't be able to select any settlements at all.
----------------------------------------------------------------------------


--	add a settlement to the whitelist by name
function campaign_ui_manager:add_settlement_selection_whitelist(settlement_name)
	if not is_string(settlement_name) then
		script_error("ERROR: add_settlement_selection_whitelist() called but supplied settlement [" .. tostring(settlement_name) .. "] is not a string");
		return false;
	end;
	
	-- check we don't already have it
	for i = 1, #self.settlement_selection_whitelist do
		if self.settlement_selection_whitelist[i] == settlement_name then
			return;
		end;
	end;
	
	output("Adding settlement to selection whitelist : " .. settlement_name);
	
	table.insert(self.settlement_selection_whitelist, settlement_name);
end;


--	remove a settlement from the whitelist
function campaign_ui_manager:remove_settlement_selection_whitelist(settlement_name)
	if not is_string(settlement_name) then
		script_error("ERROR: remove_settlement_selection_whitelist() called but supplied settlement [" .. tostring(settlement_name) .. "] is not a string");
		return false;
	end;
	
	for i = 1, #self.settlement_selection_whitelist do
		if self.settlement_selection_whitelist[i] == settlement_name then
			output("Removing settlement selection whitelist :: " .. settlement_name);
			table.remove(self.settlement_selection_whitelist, i);
			return;
		end;
	end;
end;


--	clears out the settlement whitelist
function campaign_ui_manager:clear_settlement_selection_whitelist()
	output("Clearing settlement selection whitelist");
	
	self.settlement_selection_whitelist = {};
end;


--	enables the settlement whitelist, so that it starts to be enforced
function campaign_ui_manager:enable_settlement_selection_whitelist()
	self:disable_settlement_selection_whitelist(true);
		
	if not self.all_whitelists_disabled then
		output("Enabling settlement selection whitelist");
				
		core:add_listener(
			"settlement_selected_whitelist",
			"SettlementSelected",
			true,
			function(context)		
				local settlement_selected = "settlement:" .. context:garrison_residence():region():name();
				
				-- if we find the selected settlement in our whitelist, return before we get the chance
				-- to clear the selection
				for i = 1, #self.settlement_selection_whitelist do
					if self.settlement_selection_whitelist[i] == settlement_selected then
						return;
					end;
				end;
				
				CampaignUI.ClearSelection();
			end,
			true
		);
	end;
end;


--	disables the settlement whitelist, so that it stops being enforced
function campaign_ui_manager:disable_settlement_selection_whitelist(no_output)
	if not no_output then
		output("Disabling settlement selection whitelist");
	end;

	core:remove_listener("settlement_selected_whitelist");
end;


-- method for adding all settlements belonging to a given faction
function campaign_ui_manager:add_all_settlements_for_faction_selection_whitelist(faction_name)
	if not is_string(faction_name) then
		script_error("ERROR: add_all_settlements_for_faction_selection_whitelist() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	local query_faction = self.cm:query_faction(faction_name);
	
	if not query_faction then
		script_error("ERROR: add_all_settlements_for_faction_selection_whitelist() called but couldn't find faction with name [" .. tostring(faction_name) .. "]");
		return false;
	end;
	
	local region_list = query_faction:region_list();
	
	output("add_all_settlements_for_faction_selection_whitelist() called for faction " .. faction_name);
	inc_tab();	
	for i = 0, region_list:num_items() - 1 do
		self:add_settlement_selection_whitelist(settlement_prepend_str .. region_list:item_at(i):name());
	end;
	dec_tab();
end;
















----------------------------------------------------------------------------
-- get pulse strength constants
----------------------------------------------------------------------------

function campaign_ui_manager:get_panel_pulse_strength()
	return self.panel_pulse_strength;
end;


function campaign_ui_manager:get_button_pulse_strength()
	return self.button_pulse_strength;
end;











----------------------------------------------------------------------------
--	UI Listeners
--	Keeps track of what settlement/character is selected, what
--	ui panels are open and more
----------------------------------------------------------------------------


--	starts this system - called internally when the campaign_ui_manager object is set up
function campaign_ui_manager:start_campaign_ui_listeners()
	local cm = self.cm;
	
	-- panel opened
	core:add_listener(
		"campaign_selection_listener",
		"PanelOpenedCampaign",
		true,
		function(context)
			local panel = context.string;
			out.ui("Panel opened " .. panel);
			
			if not self:is_panel_open(panel) then
				table.insert(self.panels_open, panel);
			end;
			
			core:trigger_event("ScriptEventPanelOpenedCampaign", context.string);
		end,
		true
	);
	
	-- panel closed
	core:add_listener(
		"campaign_selection_listener",
		"PanelClosedCampaign",
		true,
		function(context)
			local panel = context.string;
			out.ui("Panel closed " .. panel);
			
			local panel_entry = self:is_panel_open(panel);
			if panel_entry then
				table.remove(self.panels_open, panel_entry);
			end;
			
			core:trigger_event("ScriptEventPanelClosedCampaign", context.string);
		end,
		true
	);
	
	-- panel closed failsafe
	-- when player ends their turn, assume that all panels are closed
	core:add_listener(
		"campaign_selection_listener",
		"ScriptEventPlayerFactionTurnEnd",
		true,
		function()
			out.ui("Player is ending turn - clearing the open panels list");
			self.panels_open = {};
		end,
		false	
	);


	-- character selected
	core:add_listener(
		"campaign_selection_listener",
		"CharacterSelected",
		true,
		function(character_selected_context)
			local char = character_selected_context:character();
			out.ui("Character selected, forename " .. tostring(char:get_forename()) .. ", surname " .. tostring(char:get_surname()) .. ", position [" .. char:logical_position_x() .. ", " .. char:logical_position_y() .. "], faction " .. char:faction():name() .. ", cqi " .. tostring(char:cqi()));
			
			self.character_selected = char_lookup_str(char);
			self.character_selected_faction = char:faction():name();
			self.settlement_selected = "";
		end,
		true
	);
	
	
	-- character deselected (only fired when no other character is selected)
	core:add_listener(
		"campaign_selection_listener",
		"CharacterDeselected",
		true,
		function(character_deselected_context)
			self.character_selected = "";
			self.character_selected_faction = "";
		end,
		true
	);
	
	
	-- settlement selected
	core:add_listener(
		"campaign_selection_listener",
		"SettlementSelected",
		true,
		function(settlement_selected_context) 
			local settlement = "settlement:" .. settlement_selected_context:settlement():region():name();
			out.ui("Settlement selected " .. settlement);
			
			self.settlement_selected = settlement;
			self.character_selected = "";
			self.character_selected_faction = "";
		end,
		true
	);
	
	-- settlement deselected (only fired when no other settlement is selected)
	core:add_listener(
		"campaign_selection_listener",
		"SettlementDeselected",
		true,
		function(settlement_deselected_context) 
			self.settlement_selected = "";
		end,
		true
	);
end;


--	returns true if the supplied panel is in our open panels list, false otherwise
function campaign_ui_manager:is_panel_open(panel)
	for i = 1, #self.panels_open do
		if self.panels_open[i] == panel then
			return i;		-- needs to return index rather than bool - panel open/close mechanic uses this
		end;
	end;
	
	return false;
end;


-- returns true if an event panel is currently showing, false otherwise
function campaign_ui_manager:is_event_panel_open()
	local event_panels = {"events", "event_single"};
	local ui_root = core:get_ui_root();
	for i = 1, #event_panels do
		local uic = find_uicomponent(ui_root, event_panels[i]);
		if uic and uic:Visible(true) then
			return true
		end;
	end;
	return false; 
end;


-- returns true if an event panel showing a dilemma is currently visible, false otherwise
-- NB: this erroneously returns false if the test is done at the moment the PanelOpenedCampaign event is received. To fix.
function campaign_ui_manager:is_dilemma_open()
	local uic_layout_dilemma = find_uicomponent(core:get_ui_root(), "layout", "event_feed_hub", "event_single", "layout_dilemma");
	
	return uic_layout_dilemma and uic_layout_dilemma:Visible(true);
end;


-- returns the name of the first fullscreen panel that's open, false otherwise
function campaign_ui_manager:get_open_fullscreen_panel()
	local fullscreen_panels = self.fullscreen_panels;

	for i = 1, #fullscreen_panels do
		if self:is_panel_open(fullscreen_panels[i]) then
			return fullscreen_panels[i];
		end;
	end;
	
	return false;
end;


-- returns true if the supplied char object is selected, false otherwise
function campaign_ui_manager:is_char_selected(char)
	return self.character_selected == char_lookup_str(char);
end;


function campaign_ui_manager:get_char_selected()
	return self.character_selected;
end;


-- returns true if a character from the supplied faction name is selected, false otherwise
function campaign_ui_manager:is_char_selected_from_faction(faction_name)
	return self.character_selected_faction == faction_name;
end;


-- returns true if the supplied settlement is selected, false otherwise
function campaign_ui_manager:is_settlement_selected(settlement_name)
	return self.settlement_selected == settlement_name;
end;


-- scripted sequence started
-- This is a mechanism by which client scripts can notify the ui manager that a scripted sequence has started, which registers
-- "scripted_sequence" in the panel open list. By doing this, scripts can stall any pending interventions. Avoid using this unless
-- you really have to, probably the only case where it's valid is in the case of script that must work in SP and also MP. Client
-- scripts MUST call stop_scripted_sequence() after calling start_scripted_sequence(), not doing so will cause softlocks
function campaign_ui_manager:start_scripted_sequence()		
	if not self:is_panel_open("scripted_sequence") then
		out.ui("Scripted sequence started - spoofing panel opening");
		table.insert(self.panels_open, "scripted_sequence");
	end;
end;


function campaign_ui_manager:stop_scripted_sequence()
	out.ui("Scripted sequence ended - spoofing panel closing");
			
	local panel_entry = self:is_panel_open("scripted_sequence");
	if panel_entry then
		table.remove(self.panels_open, panel_entry);
		
		-- induce progress_on_fullscreen_panel_dismissed() to progress
		core:trigger_event("ScriptEventPanelClosedCampaign", "scripted_sequence");
	end;
end;













----------------------------------------------------------------------------
--	Settlement Highlighting
--	Provides methods to allow for easy highlighting/unhighlighting of
--	one or more settlements at a time
----------------------------------------------------------------------------


--	highlight a settlement. x_offset and z_offset allow the scripter to specify
--	an offset, as sometimes it's better not to highlight a settlement's central
--	position if a character is stood there, as it's unclear what's being highlighted
function campaign_ui_manager:highlight_settlement(settlement_name, marker_type, x_offset, y_offset, z_offset)
	if not is_string(settlement_name) then
		script_error("ERROR: highlight_settlement() called but given settlement name [" .. tostring(settlement_name) .. "] is not a string");
		return false;
	end;
	
	if not is_nil(x_offset) and not is_number(x_offset) then
		script_error("ERROR: highlight_settlement() called but given x_offset [" .. tostring(x_offset) .. "] is not a number or nil");
		return false;
	end;
	
	if not is_nil(y_offset) and not is_number(y_offset) then
		script_error("ERROR: highlight_settlement() called but given y_offset [" .. tostring(y_offset) .. "] is not a number or nil");
		return false;
	end;
	
	if not is_nil(z_offset) and not is_number(z_offset) then
		script_error("ERROR: highlight_settlement() called but given z_offset [" .. tostring(z_offset) .. "] is not a number or nil");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	z_offset = z_offset or 3;
	
	-- out("highlight_settlement() called, settlement_name: " .. tostring(settlement_name));

	local cm = self.cm;
	local settlement = cm:query_model():world():region_manager():settlement_by_key(settlement_name);
	
	if not is_query_settlement(settlement) then
		script_error("ERROR: highlight_settlement() called but given settlement [" .. settlement_name .. "] could not be found");
		return false;
	end;
	
	x_offset = x_offset or 0;
	y_offset = y_offset or 0;
	
	if marker_type then
		-- if this settlement is currently highlighted then abort
		if self.highlighted_settlements_markers[settlement_name] then
			return false;
		end;
		
		if not is_string(marker_type) then
			marker_type = "select_vfx";
		end;
		
		cm:modify_scripting():add_marker(settlement_name .. "_marker", marker_type, settlement:display_position_x() + x_offset, settlement:display_position_y() + y_offset, z_offset);
		self.highlighted_settlements_markers[settlement_name] = true;
	else
		-- if this settlement is currently highlighted then abort
		if self.highlighted_settlements_vfx[settlement_name] then
			return false;
		end;
		
		cm:modify_scripting():add_vfx(settlement_name .. "_marker", "advice_settlement_marker", settlement:display_position_x() + x_offset, settlement:display_position_y() + y_offset, z_offset);
		self.highlighted_settlements_vfx[settlement_name] = true;
	end;
	
	return true;
end;


--	unhighlights a settlement by name
function campaign_ui_manager:unhighlight_settlement(settlement_name, use_marker)
	if not is_string(settlement_name) then
		script_error("ERROR: unhighlight_settlement() called but given settlement name [" .. tostring(settlement_name) .. "] is not a string.");
		return false;
	end;
	
	if not self:can_modify() then
		return;
	end;
	
	if use_marker then
		-- unhighlight this settlement if it's currently highlighted
		if self.highlighted_settlements_markers[settlement_name] then
			self.cm:modify_scripting():remove_marker(settlement_name .. "_marker");
			self.highlighted_settlements_markers[settlement_name] = false;
			return true;
		end;
	else
		-- unhighlight this settlement if it's currently highlighted
		if self.highlighted_settlements_vfx[settlement_name] then
			self.cm:modify_scripting():remove_vfx(settlement_name .. "_marker");
			self.highlighted_settlements_vfx[settlement_name] = false;
			return true;
		end;
	end;
end;



--	shorthand method for highlighting all settlements belonging to a specific faction
function campaign_ui_manager:highlight_all_settlements_for_faction(faction_name, value, marker_type)
	if not is_string(faction_name) then
		script_error("ERROR: highlight_all_settlements_for_faction() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return;
	end;

	local query_faction = self.cm:query_faction(faction_name);
	
	if not query_faction then
		script_error("ERROR: highlight_all_settlements_for_faction() called but no faction with supplied key [" .. faction_name .. "] could be found");
		return;
	end;
		
	local region_list = query_faction:region_list();
	
	local process_func = false;
	
	if value then
		process_func = function(settlement_name) self:highlight_settlement(settlement_name, marker_type) end;
	else
		process_func = function(settlement_name) self:unhighlight_settlement(settlement_name, marker_type) end;
	end;
	
	for i = 0, region_list:num_items() - 1 do
		local curr_region = region_list:item_at(i);
		process_func(settlement_prepend_str .. curr_region:name());
	end;
end;



-- TODO: make this properly support a camera that is moving (this system would need to keep track of all currently highlighted
-- settlements, the camera position they're related to, then when the camera moves update the list removing old entries) and
-- also the highlighting and then unhighlight of settlements that are already highlighted - highlight and unhighlight need to
-- incremement/decrement some form of counter.
-- Supply an optional condition to test against each subject settlement
function campaign_ui_manager:highlight_all_settlements_near_camera(value, radius, condition)
	local cm = self.cm;
		
	if value then	
		local radius_squared = radius * radius;
		local cam_x, cam_y = cm:get_camera_position();
		local region_list = cm:query_model():world():region_manager():region_list();
	
		for i = 0, region_list:num_items() - 1 do
			local curr_region = region_list:item_at(i);
			local curr_settlement = curr_region:settlement();
			
			if not is_function(condition) or condition(curr_settlement) then
				local distance_to_settlement_squared = distance_squared(curr_settlement:display_position_x(), curr_settlement:display_position_y(), cam_x, cam_y);
				
				if distance_to_settlement_squared < radius_squared then					
					-- only highlight if this settlement is visible to the local alliance
					local char = get_garrison_commander_of_region(curr_region);
					
					if char and char:is_visible_to_faction(cm:get_local_faction(true)) then					
						local curr_settlement_name = settlement_prepend_str .. curr_region:name();

						self:highlight_settlement(curr_settlement_name, false);
						table.insert(self.highlighted_settlements_near_camera, curr_settlement_name);
					end;
				end;
			end;
		end;
	else
		for i = 1, #self.highlighted_settlements_near_camera do
			self:unhighlight_settlement(self.highlighted_settlements_near_camera[i]);
		end;
		
		self.highlighted_settlements_near_camera = {};
	end;
end;









----------------------------------------------------------------------------
--	Character Highlighting
--	Provides methods to allow for easy highlighting/unhighlighting of
--	one or more characters at a time
----------------------------------------------------------------------------

--	highlights a character object
function campaign_ui_manager:highlight_character(char, marker_type, altitude)
	local marker_name = char_lookup_str(char);
	
	if not self:can_modify() then
		return;
	end;
	
	altitude = altitude or 0;
	
	if marker_type then
		-- if this character is currently highlighted then abort
		if self.highlighted_characters_markers[marker_name] then
			return false;
		end;
		
		if not is_string(marker_type) then
			marker_type = "select_vfx";
		end;
		
		self.cm:modify_scripting():add_marker(marker_name, marker_type, char:display_position_x(), char:display_position_y(), altitude);
		
		self.highlighted_characters_markers[marker_name] = true;
	else
		-- if this character is currently highlighted then abort
		if self.highlighted_characters_vfx[marker_name] then
			return false;
		end;
			
		self.cm:modify_scripting():add_vfx(marker_name, "advice_character_marker", char:display_position_x(), char:display_position_y(), altitude);
		
		self.highlighted_characters_vfx[marker_name] = true;
	end;	
	
	return true;
end;


--	the business end of unhighlight_character, not to be called externally
function campaign_ui_manager:unhighlight_character_action(marker_name, use_marker)

	if use_marker then
		if self.highlighted_characters_markers[marker_name] then
			self.cm:remove_marker(marker_name);
			self.highlighted_characters_markers[marker_name] = false;
			return true;
		end;
	else
		if self.highlighted_characters_vfx[marker_name] then
			self.cm:remove_vfx(marker_name);
			self.highlighted_characters_vfx[marker_name] = false;
			return true;
		end;
	end;
end;


-- unhighlights a character object
function campaign_ui_manager:unhighlight_character(char, use_marker)
	return self:unhighlight_character_action(char_lookup_str(char), use_marker);
end;


--	unhighlights a character by cqi
function campaign_ui_manager:unhighlight_character_by_cqi(cqi, use_marker)
	return self:unhighlight_character_action(char_lookup_str(char), use_marker);
end;



--	shorthand method for highlighting/unhighlighting all faction armies
function campaign_ui_manager:highlight_all_general_characters_for_faction(faction_name, value)
	if not is_string(faction_name) then
		script_error("ERROR: highlight_all_general_characters_for_faction() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;

	local query_faction = self.cm:query_faction(faction_name);
	
	if not query_faction then
		script_error("ERROR: highlight_all_general_characters_for_faction() called but no faction with supplied key [" .. tostring(faction_name) .. "] could be found");
		return false;
	end;
	
	local military_force_list = query_faction:military_force_list();
	
	local process_func = false;
	
	if value then
		process_func = function(char) self:highlight_character(char) end;
	else
		process_func = function(char) self:unhighlight_character(char) end;
	end;
	
	for i = 0, military_force_list:num_items() - 1 do
		local military_force = military_force_list:item_at(i);
		
		if military_force:has_general() and military_force_is_mobile(military_force) then
			process_func(military_force:general_character());
		end;
	end;
end;




function campaign_ui_manager:highlight_all_characters_near_camera(value, radius, condition)
	local cm = self.cm;
	
	if value then
		local faction_list = cm:query_model():world():faction_list();
		local cam_x, cam_y = cm:get_camera_position();
		local radius_squared = radius * radius;
		
		for i = 0, faction_list:num_items() - 1 do
			local char_list = faction_list:item_at(i):character_list();
			
			for j = 0, char_list:num_items() - 1 do
				local char = char_list:item_at(j);
				
				if distance_squared(char:display_position_x(), char:display_position_y(), cam_x, cam_y) < radius_squared and char:is_visible_to_faction(cm:get_local_faction(true)) then
					if not is_function(condition) or condition(char) then
				
						table.insert(
							self.highlighted_characters_near_camera, 
							{
								["faction_name"] = char:faction():name(), 
								["cqi"] = char:cqi()
							}
						);
						self:highlight_character(char);
					end;
				end;
			end;
		end;
		
	else
		for i = 1, #self.highlighted_characters_near_camera do
			local current_record = self.highlighted_characters_near_camera[i];
			local char = cm:query_character(current_record.cqi);
			if char then
				self:unhighlight_character();
			end;
		end;
		self.highlighted_characters_near_camera = {};
	end;
end;


function campaign_ui_manager:highlight_all_generals_near_camera(value, radius, condition)
	local my_condition = false;
	
	if not condition then
		my_condition = function(char) return char_is_mobile_general_with_army(char) end;
	else
		my_condition = function(char) return char_is_mobile_general_with_army(char) and condition(char) end;
	end;
	
	return self:highlight_all_characters_near_camera(value, radius, my_condition);
end;


function campaign_ui_manager:highlight_all_heroes_near_camera(value, radius, condition)
	local my_condition = false;
	
	if not condition then
		my_condition = function(char) return char_is_agent(char) end;
	else
		my_condition = function(char) return char_is_agent(char) and condition(char) end;
	end;
	
	return self:highlight_all_characters_near_camera(value, radius, my_condition);
end;







----------------------------------------------------------------------------
--	Highlighting Character/Settlement for Selection
--	Allows highlighting of a character or settlement for the player
--	to select and then calls a callback when it's selected
----------------------------------------------------------------------------


--	highlight a character for selection
function campaign_ui_manager:highlight_character_for_selection(char, callback, altitude)
	if not is_query_character(char) then
		script_error("ERROR: highlight_character_for_selection() called but supplied character [" .. tostring(char) .. "] is not a character");
		return false;
	end;
	
	if not is_function(callback) then
		script_error("ERROR: highlight_character_for_selection() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	altitude = altitude or 0;

	local char_cqi = char:cqi();
	self:highlight_character(char, true, altitude);
	
	core:add_listener(
		"highlight_character_for_selection:" .. char_cqi,
		"CharacterSelected",
		function(context) return context:character():cqi() == char_cqi end,
		function()
			local current_char = cm:query_character(char_cqi);
			if current_char then
				self:unhighlight_character(current_char, true, altitude);
			end;
			
			callback();
		end,
		false
	);
end;


--	unhighlight a character for selection
function campaign_ui_manager:unhighlight_character_for_selection(char)
	if not is_query_character(char) then
		script_error("ERROR: unhighlight_character_for_selection() called but supplied character [" .. tostring(char) .. "] is not a character");
		return false;
	end;

	local char_cqi = char:cqi();
	local cm = get_cm();
	
	self:unhighlight_character(char, true);
	
	core:remove_listener("highlight_character_for_selection:" .. char_cqi);
end;


--	highlight a settlement for selection
--	the province name (key) must also be provided as the player may select a settlement in
--	the same province, which has to count as it opens the same screen
function campaign_ui_manager:highlight_settlement_for_selection(settlement_name, province_name, callback, x_offset, y_offset)
	if not is_string(settlement_name) then
		script_error("ERROR: highlight_settlement_for_selection() called but supplied settlement name [" .. tostring(settlement_name) .. "] is not a string");
		return false;
	end;
	
	if province_name and not is_string(province_name) then
		script_error("ERROR: highlight_settlement_for_selection() called but supplied province_name name [" .. tostring(province_name) .. "] is not a string or nil");
		return false;
	end;
	
	if not is_function(callback) then
		script_error("ERROR: highlight_settlement_for_selection() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	self:highlight_settlement(settlement_name, true, x_offset, y_offset);
	
	core:add_listener(
		"highlight_settlement_for_selection:" .. settlement_name,
		"SettlementSelected",
		function(context)
			local selected_settlement = settlement_prepend_str .. context:garrison_residence():region():name();
			
			-- if the player selects a settlement in the same province that opens the same screen, so it counts as selecting the intended settlement
			if settlement_name == selected_settlement or (province_name and string.find(selected_settlement, province_name)) then
				return true;
			end;
			return false;
		end,
		function()
			self:unhighlight_settlement(settlement_name, true);
			callback();
		end,
		false
	);
end;


--	unhighlights a settlement for selection by name
function campaign_ui_manager:unhighlight_settlement_for_selection(settlement_name)
	if not is_string(settlement_name) then
		script_error("ERROR: highlight_settlement_for_selection() called but supplied settlement name [" .. tostring(settlement_name) .. "] is not a string");
		return false;
	end;
	
	self:unhighlight_settlement(settlement_name, true);
	
	core:remove_listener("highlight_settlement_for_selection:" .. settlement_name);
end;
















--
--	first-turn ui overrides
--

function campaign_ui_manager:display_first_turn_ui(value)	
	local cm = self.cm;
	
	if not cm:can_modify() then
		return false;
	end;
	
	self:override("events_panel"):set_allowed(value);
	self:override("events_rollout"):set_allowed(value);
	self:override("saving"):set_allowed(value);
	self:override("missions"):set_allowed(value);
	self:override("technology"):set_allowed(value);
	self:override("rituals"):set_allowed(value);
	self:override("finance"):set_allowed(value);
	self:override("diplomacy"):set_allowed(value);
	self:override("faction_button"):set_allowed(value);
	self:override("recruit_units"):set_allowed(value);
	self:override("cancel_recruitment"):set_allowed(value);
	self:override("dismantle_building"):set_allowed(value);
	self:override("repair_building"):set_allowed(value);
	self:override("cancel_construction"):set_allowed(value);
	self:override("building_upgrades"):set_allowed(value);
	self:override("non_city_building_upgrades"):set_allowed(value);
	self:override("enlist_agent"):set_allowed(value);
	self:override("raise_army"):set_allowed(value);
	self:override("recruit_mercenaries"):set_allowed(value);
	self:override("stances"):set_allowed(value);
	self:override("book_of_grudges"):set_allowed(value);
	self:override("offices"):set_allowed(value);
	self:override("tax_exemption"):set_allowed(value);
	self:override("end_turn"):set_allowed(value);
	self:override("building_browser"):set_allowed(value);
	self:override("diplomacy_double_click"):set_allowed(value);
	self:override("tactical_map"):set_allowed(value);
	self:override("character_details"):set_allowed(value);
	self:override("disband_unit"):set_allowed(value);
	self:override("ping_clicks"):set_allowed(value);
	self:override("settlement_renaming"):set_allowed(value);
	self:override("autoresolve"):set_allowed(value);
	self:override("retreat"):set_allowed(value);
	self:override("advice_settings_button"):set_allowed(value);
	self:override("spell_browser"):set_allowed(value);
	self:override("camera_settings"):set_allowed(value);
	self:override("army_panel_help_button"):set_allowed(value);
	self:override("pre_battle_panel_help_button"):set_allowed(value);
	self:override("province_overview_panel_help_button"):set_allowed(value);
	self:override("intrigue_at_the_court"):set_allowed(value);
	self:override("slaves"):set_allowed(value);
	self:override("geomantic_web"):set_allowed(value);
	self:override("garrison_details"):set_allowed(value);
	self:override("end_turn_options"):set_allowed(value);
	self:override("skaven_corruption"):set_allowed(value);
	self:override("tax_slider"):set_allowed(value);
	
	cm:enable_ui_hiding(value);
	
	local should_suppress = not value;
	
	-- ensure info panel is shown over the top of advice..
	local uic_info_panel_holder = find_uicomponent(core:get_ui_root(), "info_panel_holder");
	if uic_info_panel_holder then
		if value then
			uic_info_panel_holder:RemoveTopMost();
		else
			uic_info_panel_holder:RegisterTopMost();
		end;
	end;
	
	-- ..but prevent it from being pinned
	cm:modify_scripting():override_ui("disable_info_panel_pinning", should_suppress);
	
	self:suppress_end_of_turn_warning("bankrupt", should_suppress);
	self:suppress_end_of_turn_warning("tech", should_suppress);
	self:suppress_end_of_turn_warning("edict", should_suppress);
	self:suppress_end_of_turn_warning("character", should_suppress);
	self:suppress_end_of_turn_warning("army", should_suppress);
	self:suppress_end_of_turn_warning("politics", should_suppress);
	self:suppress_end_of_turn_warning("siege", should_suppress);
	self:suppress_end_of_turn_warning("morale", should_suppress);
	
	cm:enable_all_diplomacy(value);
	
	self:display_faction_buttons(value);
	self:display_resources_bar(value);
	
	local local_faction = cm:get_local_faction(true);
	
	if value then
		-- unlocking
		play_component_animation("show", "resources_bar");
		play_component_animation("show", "bar_small_top");
		play_component_animation("show", "radar_things");
		
		self:disable_character_selection_whitelist();
		self:disable_settlement_selection_whitelist();
		
		cm:modify_faction(local_faction):enable_movement();
		
	else
		-- locking		
		play_component_animation("hide", "bar_small_top");
		play_component_animation("hide", "radar_things");
		
		self:enable_character_selection_whitelist();
		self:enable_settlement_selection_whitelist();
		
		if cm:faction_exists(local_faction) then
			cm:modify_faction(local_faction):disable_movement();
		end;
	end;
end;


function campaign_ui_manager:display_faction_buttons(value)
	if value == false then
		if self.faction_buttons_displayed then
			self.faction_buttons_displayed = false;
			play_component_animation("hide", "faction_buttons_docker");
		end;
	else
		if not self.faction_buttons_displayed then
			self.faction_buttons_displayed = true;
			play_component_animation("show", "faction_buttons_docker");
		end;
	end;
end;


function campaign_ui_manager:display_resources_bar(value)
	if value == false then
		if self.resources_bar_displayed then
			self.resources_bar_displayed = false;
			play_component_animation("hide", "resources_bar");
		end;
	else
		if not self.resources_button_displayed then
			self.resources_button_displayed = true;
			play_component_animation("show", "resources_bar");
		end;
	end;
end;












----------------------------------------------------------------------------
-- toggle ai turns indicator
----------------------------------------------------------------------------

function campaign_ui_manager:toggle_ai_turns(value)
	if value then
		return;
	end;
	
	local ai_turns = find_uicomponent(core:get_ui_root(), "ai_turns")
		
	if ai_turns then
		ai_turns:SetVisible(value);
	end;
end;





----------------------------------------------------------------------------
-- modal queueing system
----------------------------------------------------------------------------

-- actually add the modal section
function campaign_ui_manager:add_modal_section_to_queue(insert_at_front, name, callback, params, lock_ui, is_filler)
	if not is_function(callback) then
		script_error("ERROR: add_modal_section_to_queue() called but supplied callback is not a function");
		return;
	end;
	
	output("*** add_modal_section_to_queue() called, name is [" .. tostring(name) .. "]");
	
	if self.modal_system_locked then
		output("\tAttempted to add modal section to queue but modal system is locked, discarding");
		return;
	end;
	
	-- if this modal section is marked as filler then only play it if there's nothing else to play.
	-- That means that if the queue already has something in at the point of addition we don't add it
	if is_filler then		
		if #self.modal_queue > 0 or self.modal_section_active then
			output("\tnot adding this filler modal section as other sections are enqueued");
			return;
		end;
	end;
	
	if not is_table(params) then
		params = {};
	end;
	
	lock_ui = not not lock_ui;
	
	local new_entry = {
		["name"] = name,
		["callback"] = callback,
		["params"] = params,
		["lock_ui"] = lock_ui,
		["is_filler"] = is_filler
	};
	
	if insert_at_front then
		table.insert(self.modal_queue, 1, new_entry);
	else
		table.insert(self.modal_queue, new_entry);
	end;
	
	if not self.modal_section_active then
		self:next_modal_section();
	end;
end;


--	add the supplied modal section to the front of the queue (only use this for super-important sections)
function campaign_ui_manager:insert_modal_section(name, callback, params, lock_ui)
	self:add_modal_section_to_queue(true, name, callback, params, lock_ui, false);
end;


--	add the supplied modal section to the back of the queue
function campaign_ui_manager:add_modal_section(name, callback, params, lock_ui, is_filler)
	self:add_modal_section_to_queue(false, name, callback, params, lock_ui, is_filler);
end;


--	start the next modal section, if there is one. For internal use.
function campaign_ui_manager:next_modal_section()
	if #self.modal_queue == 0 then
		dec_tab();
		self:modal_sections_end();
		return;
	end;
	
	local cm = self.cm;
	
	local entry = self.modal_queue[1];
	table.remove(self.modal_queue, 1);
	
	if self.modal_section_active then
		dec_tab();
		script_error("*** Starting another modal section, name is [" .. tostring(entry.name) .. "]");
	else
		self.modal_section_active = true;
		script_error("*** Starting new modal section, name is [" .. tostring(entry.name) .. "]");
	end;
	
	inc_tab();
		
	if entry.lock_ui then
		output("next_modal_section() is locking the ui");
		self:lock_ui();
	else
		self:unlock_ui();
		output("next_modal_section() is unlocking the ui");
		
		-- specifically prevent ending turn though
		self:override("end_turn"):lock();
	end;
	
	-- disable movement for the player faction
	cm:disable_movement_for_faction(cm:get_local_faction(true));
	
	-- if the entry is filler, then wait a second and see if there's any further entries queued
	-- up behind it. If so, cancel this entry and run the next
	if not entry.is_filler then
		cm:progress_on_loading_screen_dismissed(function() entry.callback(entry.params) end);
	else	
		cm:callback(
			function()
				if #self.modal_queue == 0 and not self.modal_system_locked then
					cm:progress_on_loading_screen_dismissed(function() entry.callback(entry.params) end);
				else
					output("next_modal_section() : skipping modal section [" .. entry.name .. "] as there's another in the queue or the queue is locked");
					self:next_modal_section();
				end;			
			end,
			1000,
			"modal_section_filler_entry"
		);
	end;
end;


--	called internally when a sequence of modal sections ends. UI is restored and the player can move again.
function campaign_ui_manager:modal_sections_end()
	dec_tab();
	output("*** Ending modal sections");
	self.modal_section_active = false;
	self:unlock_ui();
	
	-- trigger a script message
	core:trigger_event("ScriptEventModalSectionsEnd");
	
	-- explicitly unlock the end turn as it might be locked from before
	self:override("end_turn"):unlock();
	
	-- enable movement for the player faction
	self.cm:modify_character(self.cm:get_local_faction(true)):enable_movement();
end;


--	called externally - clears the modal queue
function campaign_ui_manager:clear_modal_queue()
	if not self.modal_system_locked then
		self.modal_queue = {};
	end;
end;


--	called externally - locks the modal queue, so no more modal sections can be played or added
function campaign_ui_manager:lock_modal_queue(value)
	self.modal_system_locked = not not value;
end;


function campaign_ui_manager:is_modal_queue_empty()
	return #self.modal_queue == 0;
end;


function campaign_ui_manager:is_modal_section_active()
	return self.modal_section_active;
end;











----------------------------------------------------------------------------
-- interaction monitor
----------------------------------------------------------------------------


function campaign_ui_manager:add_interaction_monitor(key, event_name, test)
	if not is_string(key) then
		script_error("ERROR: add_interaction_monitor() called but supplied key [" .. tostring(key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(event_name) then
		script_error("ERROR: add_interaction_monitor() called but supplied event name [" .. tostring(event_name) .. "] is not a string");
		return false;
	end;
	
	test = test or true;
	
	if not is_function(test) and test ~= true then
		script_error("ERROR: add_interaction_monitor() called but supplied callback [" .. tostring(test) .. "] is not a function, true or nil");
		return false;
	end;
	
	-- if we have already seen this interaction then don't bother starting the monitor
	if effect.get_advice_history_string_seen(key) then
		return;
	end;
	
	core:add_listener(
		"interaction_monitor_" .. key,
		event_name,
		test,
		function() effect.set_advice_history_string_seen(key) end,
		false
	);
end;


function campaign_ui_manager:add_click_interaction_monitor(key, component_name)
	self:add_interaction_monitor(key, "ComponentLClickUp", function(context) return context.string == component_name end);
end;


function campaign_ui_manager:add_campaign_panel_closed_interaction_monitor(key, panel_name)
	self:add_interaction_monitor(key, "PanelClosedCampaign", function(context) return context.string == panel_name end);
end;


function campaign_ui_manager:get_interaction_monitor_state(key)
	return effect.get_advice_history_string_seen(key);
end;









----------------------------------------------------------------------------
-- diplomacy audio locking
-- this ui override may be locked by multiple interventions. It should be
-- locked when any one of them desires it locked and not unlocked unless
-- ALL want it unlocked.
----------------------------------------------------------------------------

function campaign_ui_manager:lock_diplomacy_audio()
	self.diplomacy_audio_lock_level = self.diplomacy_audio_lock_level + 1;
	
	if self.diplomacy_audio_lock_level == 1 then
		self:override("diplomacy_audio"):lock();
	end;
end;


function campaign_ui_manager:unlock_diplomacy_audio()
	self.diplomacy_audio_lock_level = self.diplomacy_audio_lock_level - 1;
	
	if self.diplomacy_audio_lock_level == 0 then
		self:override("diplomacy_audio"):unlock();
	end;
end;







----------------------------------------------------------------------------
-- highlight component range
----------------------------------------------------------------------------


function campaign_ui_manager:highlight_all_visible_children(uic, padding)
	
	if not is_uicomponent(uic) then
		script_error("ERROR: highlight_all_visible_children() called but supplied uicomponent [" .. tostring(uic) .. "] is not a uicomponent");
		return false;
	end;
	
	padding = padding or 0;
	
	local components_to_highlight = {};
	
	for i = 0, uic:ChildCount() - 1 do
		local uic_child = UIComponent(uic:Find(i));
			
		if uic_child:Visible() then
			table.insert(components_to_highlight, uic_child);
		end;
	end;
	
	self:highlight_component_table(padding, unpack(components_to_highlight));
end;


function campaign_ui_manager:unhighlight_all_visible_children()
	self:unhighlight_component_table();
end;


function campaign_ui_manager:highlight_component_table(padding, ...)

	local cm = self.cm;
	local component_list = arg;

	if not is_number(padding) or padding < 0 then
		-- if the first parameter is a uicomponent then insert it at the start of our component list
		if is_uicomponent(padding) then
			table.insert(component_list, 1, padding);
			padding = 0;
		else
			script_error("ERROR: highlight_component_table() called but supplied padding value [" .. tostring(padding) .. "] is not a positive number (or a uicomponent)");
			return false;
		end;
	end;
	
	local min_x = 10000000;
	local min_y = 10000000;
	local max_x = 0;
	local max_y = 0;
		
	for i = 1, #component_list do
		local current_component = component_list[i];
		
		if not is_uicomponent(current_component) then
			script_error("ERROR: highlight_component_table() called but parameter " .. i .. " in supplied list is a [" .. tostring(current_component) .. "] and not a uicomponent");
			return false;
		end;
		
		local current_min_x, current_min_y = current_component:Position();
		local size_x, size_y = current_component:Dimensions();
		
		local current_max_x = current_min_x + size_x;
		local current_max_y = current_min_y + size_y;
		
		if current_min_x < min_x then
			min_x = current_min_x;
		end;
		
		if current_min_y < min_y then
			min_y = current_min_y;
		end;
		
		if current_max_x > max_x then
			max_x = current_max_x;
		end;
		
		if current_max_y > max_y then
			max_y = current_max_y;
		end;
	end;
	
	-- apply padding
	min_x = min_x - padding;
	min_y = min_y - padding;
	max_x = max_x + padding;
	max_y = max_y + padding;
	
	-- create the dummy component if we don't already have one lurking around somewhere
	local ui_root = core:get_ui_root();
	
	local uic_dummy = find_uicomponent(ui_root, "highlight_dummy");
	
	if not uic_dummy then
		ui_root:CreateComponent("highlight_dummy", core.path_to_dummy_component);
		uic_dummy = find_uicomponent(ui_root, "highlight_dummy");
	end;
	
	if not uic_dummy then
		script_error("ERROR: highlight_component_table() cannot find uic_dummy, how can this be?");
		return false;
	end;
	
	-- resize and move the dummy
	local size_x = max_x - min_x;
	local size_y = max_y - min_y;
	
	-- uic_dummy:SetMoveable(true);
	uic_dummy:MoveTo(min_x, min_y);
	uic_dummy:Resize(size_x, size_y);
	
	local new_pos_x, new_pos_y = uic_dummy:Position();
	
	uic_dummy:Highlight(true, true, 0);
end;


function campaign_ui_manager:unhighlight_component_table()
	highlight_component(false, true, "highlight_dummy");
end;






----------------------------------------------------------------------------
-- specific component highlighting
----------------------------------------------------------------------------

-- unhighlighting all

function campaign_ui_manager:unhighlight_all_for_tooltips(force_unhighlight)
	if not self.help_page_link_highlighting_permitted and not force_unhighlight then
		return;
	end;

	local unhighlight_action_list = self.unhighlight_action_list;
	
	for i = 1, #unhighlight_action_list do
		unhighlight_action_list[i]();
	end;
	
	self.unhighlight_action_list = {};
end;




function campaign_ui_manager:highlight_advice_history_buttons(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = get_cm();
	local ui_root = core:get_ui_root();
	local uic_button_next = find_uicomponent(ui_root, "advice_interface", "button_next");
	pulse_strength = pulse_strength or self.button_pulse_strength;
	
	if uic_button_next and uic_button_next:Visible(true) and is_fully_onscreen(uic_button_next) then
		pulse_uicomponent(uic_button_next, value, pulse_strength);
		
		local uic_button_previous = find_uicomponent(ui_root, "advice_interface", "button_previous");
		
		if uic_button_previous and uic_button_previous:Visible(true) then
			pulse_uicomponent(uic_button_previous, value, pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_advice_history_buttons(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_advisor_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_advisor_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "menu_bar", "button_show_advice");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_advisor_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_advisor(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = get_cm();
	local uic_advice_interface = find_uicomponent(core:get_ui_root(), "advice_interface");
	
	if uic_advice_interface and uic_advice_interface:Visible(true) and is_fully_onscreen(uic_advice_interface) then
		pulse_strength = pulse_strength or self.panel_pulse_strength;
		
		local uic_text_parent = find_uicomponent(uic_advice_interface, "text_parent");
		if uic_text_parent then
			pulse_uicomponent(uic_text_parent, value, pulse_strength);
		end;
		
		local uic_frame = find_uicomponent(uic_advice_interface, "frame");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength);
		end;
		
		local uic_button_options = find_uicomponent(uic_advice_interface, "button_toggle_options");
		if uic_button_options  then
			pulse_uicomponent(uic_button_options, value, pulse_strength);
		end;
		
		local uic_button_close = find_uicomponent(uic_advice_interface, "button_close");
		if uic_button_close then
			pulse_uicomponent(uic_button_close, value, pulse_strength);
		end;
				
		if value then
			self:highlight_advice_history_buttons(value, pulse_strength, force_highlight);
			
			table.insert(self.unhighlight_action_list, function() self:highlight_advisor(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_advisor_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_armies(value, target_faction, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	if value then
		if target_faction then
			self:highlight_all_generals_near_camera(true, 30, function(char) return char:faction():name() == target_faction end);
		else
			self:highlight_all_generals_near_camera(true, 30);
		end;
		table.insert(self.unhighlight_action_list, function() self:highlight_armies(false, pulse_strength, force_highlight) end);
	else
		self:highlight_all_generals_near_camera(false);
	end;
end;


function campaign_ui_manager:highlight_armies_at_sea(value, pulse_strength, force_highlight, target_faction)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	if value then
		if target_faction then
			self:highlight_all_generals_near_camera(true, 30, function(char) return char:is_at_sea() and char:faction():name() == target_faction end);
		else
			self:highlight_all_generals_near_camera(true, 30, function(char) return char:is_at_sea() end);
		end;
		table.insert(self.unhighlight_action_list, function() self:highlight_armies(false, pulse_strength, force_highlight) end);
	else
		self:highlight_all_generals_near_camera(false, pulse_strength, force_highlight);
	end;
end;


function campaign_ui_manager:highlight_army_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_panel = find_uicomponent(ui_root, "main_units_panel");
	
	if uic_panel and uic_panel:Visible(true) then
		-- if the building tab is visible and selected then highlight the army tab and exit
		local uic_tabgroup = find_uicomponent(uic_panel, "tabgroup");
		
		if uic_tabgroup then
			local uic_building_tab = find_uicomponent(uic_tabgroup, "tab_horde_buildings");
			if uic_building_tab and uic_building_tab:Visible(true) and uic_building_tab:CurrentState() == "selected" then
				local uic_army_tab = find_uicomponent(uic_tabgroup, "tab_army");
				if uic_army_tab then
					pulse_uicomponent(uic_army_tab, value, pulse_strength or self.button_pulse_strength);
					if value then
						table.insert(self.unhighlight_action_list, function() self:highlight_army_panel(false, pulse_strength, force_highlight) end);
					end;
					return true;
				end;			
			end;
		end;
	
		local panel_pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		pulse_uicomponent(uic_panel, value, panel_pulse_strength);
		
		local uic_header = find_uicomponent(uic_panel, "button_focus");
		pulse_uicomponent(uic_header, value, panel_pulse_strength);
		
		local uic_cycle_left = find_uicomponent(uic_panel, "button_cycle_left");
		pulse_uicomponent(uic_cycle_left, value, panel_pulse_strength);
		
		local uic_cycle_right = find_uicomponent(uic_panel, "button_cycle_right");
		pulse_uicomponent(uic_cycle_right, value, panel_pulse_strength);
			
		if value then
			self:highlight_army_panel_unit_cards(value, pulse_strength, force_highlight, true);
			self:highlight_winds_of_magic(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_army_panel(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	else
		return self:highlight_armies(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_army_panel_unit_cards(value, pulse_strength, force_highlight, do_not_highlight_upstream, highlight_unit_types, highlight_experience)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = self.cm;
	local uic_parent = find_uicomponent(core:get_ui_root(), "main_units_panel", "units");
		
	if uic_parent and uic_parent:Visible(true) then
	
		for i = 0, uic_parent:ChildCount() - 1 do
			local uic_child = UIComponent(uic_parent:Find(i));
			
			-- highlight the type indicator if we're supposed to
			if highlight_unit_types then
				-- unit type
				local uic_type = find_uicomponent(uic_child, "unit_cat_frame");
				if uic_type then
					pulse_uicomponent(uic_type, value, pulse_strength or self.button_pulse_strength);
				end;
			elseif highlight_experience then
				-- experience
				local uic_experience = find_uicomponent(uic_child, "experience");
				if uic_experience then
					pulse_uicomponent(uic_experience, value, pulse_strength or self.button_pulse_strength);
				end;
			else
				-- whole card
				pulse_uicomponent(uic_child, value, pulse_strength or self.panel_pulse_strength);
			end;
		end;

		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_army_panel_unit_cards(false, pulse_strength, force_highlight, do_not_highlight_upstream, highlight_unit_types, highlight_experience) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_army_panel(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_autoresolve_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_regular_deployment = find_uicomponent(core:get_ui_root(), "pre_battle_screen", "regular_deployment");
			
	if uic_regular_deployment and uic_regular_deployment:Visible(true) then	
		local uic_standard_autoresolve = find_uicomponent(uic_regular_deployment, "button_set_attack", "button_autoresolve");
		if uic_standard_autoresolve and uic_standard_autoresolve:Visible(true) then
			pulse_uicomponent(uic_standard_autoresolve, value, pulse_strength or self.button_pulse_strength);
		else
			local uic_siege_autoresolve = find_uicomponent(uic_regular_deployment, "button_set_siege", "button_autoresolve");
			if uic_siege_autoresolve and uic_siege_autoresolve:Visible(true) then
				pulse_uicomponent(uic_siege_autoresolve, value, pulse_strength or self.button_pulse_strength);
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_autoresolve_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_balance_of_power_bar(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "battle_deployment", "killometer");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or 8, true);
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_balance_of_power_bar(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_banners_and_marks(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	local component_highlighted = false;
	
	-- pre_battle_panel
	local uic_pre_battle_panel = find_uicomponent(ui_root, "pre_battle_screen");
	if uic_pre_battle_panel and uic_pre_battle_panel:Visible(true) then
		local uic_banners = find_uicomponent(uic_pre_battle_panel, "allies_combatants_panel", "army", "units_and_banners_parent", "ancillary_banners");
	
		if uic_banners then
			component_highlighted = true;
			pulse_uicomponent(uic_banners, value, pulse_strength or self.panel_pulse_strength, true);
			if value then
				self:highlight_pre_battle_panel_unit_cards(value, pulse_strength, force_highlight, false, false, false, true);
				table.insert(self.unhighlight_action_list, function() self:highlight_banners_and_marks(false, pulse_strength, force_highlight) end);
			end;
			return true;
		end;
	else
		-- post_battle_panel
		local uic_post_battle_panel = find_uicomponent(ui_root, "post_battle_screen");
		if uic_post_battle_panel and uic_post_battle_panel:Visible(true) then
			local uic_banners = find_uicomponent(uic_post_battle_panel, "allies_combatants_panel", "army", "units_and_banners_parent", "ancillary_banners");
		
			if uic_banners then
				component_highlighted = true;
				pulse_uicomponent(uic_banners, value, pulse_strength or self.panel_pulse_strength, true);
				if value then
					self:highlight_post_battle_panel_unit_cards(value, pulse_strength, force_highlight, false, false, true);
					table.insert(self.unhighlight_action_list, function() self:highlight_banners_and_marks(false, pulse_strength, force_highlight) end);
				end;
				return true;
			end;
		else
			-- character details pane
			local uic_char_details_pane = find_uicomponent(ui_root, "character_details_panel", "character_details_subpanel", "ancillary_general");
			
			if uic_char_details_pane and uic_char_details_pane:Visible(true) then
				pulse_uicomponent(uic_char_details_pane, value, pulse_strength or self.panel_pulse_strength, true);
				
				if value then
					table.insert(self.unhighlight_action_list, function() self:highlight_banners_and_marks(false, pulse_strength, force_highlight) end);
				end;
				return true;
			else
				self:highlight_character_details_button(value, pulse_strength, force_highlight);
			end;
		end;
	end;

	return false;
end;


function campaign_ui_manager:highlight_book_of_grudges_bar(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "book_of_grudges", "grudge_bar");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or 8, true);
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_book_of_grudges_bar(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_books_of_nagash(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_num_books = find_uicomponent(core:get_ui_root(), "resources_bar", "right_spacer_tomb_kings", "dy_num_books");
		
	if uic_num_books and uic_num_books:Visible(true) then
		pulse_uicomponent(uic_num_books, value, pulse_strength or self.button_pulse_strength, true);
		
		self:highlight_books_of_nagash_panel(value, pulse_strength, force_highlight, true);
		self:highlight_books_of_nagash_button(value, pulse_strength, force_highlight);
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_books_of_nagash(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_books_of_nagash_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_button = find_uicomponent(core:get_ui_root(), "resources_bar", "right_spacer_tomb_kings", "button_books_of_nagash");
		
	if uic_button and uic_button:Visible(true) then
		pulse_uicomponent(uic_button, value, pulse_strength or self.button_pulse_strength, true);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_books_of_nagash_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_books_of_nagash_panel(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_panel = find_child_uicomponent(core:get_ui_root(), "books_of_nagash");
			
	if uic_panel and uic_panel:Visible(true) then
		pulse_uicomponent(uic_panel, value, pulse_strength or self.panel_pulse_strength);
		
		local uic_title = find_uicomponent(uic_panel, "panel_title");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		local uic_watermark = find_uicomponent(uic_panel, "watermark");
		if uic_watermark then
			pulse_uicomponent(uic_watermark, value, pulse_strength or self.panel_pulse_strength);
			
			local uic_book_list = find_uicomponent(uic_watermark, "book_list");
			if uic_book_list then
				pulse_uicomponent(uic_book_list, value, pulse_strength or self.panel_pulse_strength, true);
			end;
		end;
		
		local uic_info = find_uicomponent(uic_panel, "info_panel");
		if uic_info then
			pulse_uicomponent(uic_info, value, pulse_strength or self.panel_pulse_strength);
			
			local uic_info_title = find_uicomponent(uic_info, "dy_title");
			if uic_info_title then
				pulse_uicomponent(uic_info_title, value, pulse_strength or self.panel_pulse_strength);
			end;
		end;
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_books_of_nagash(false, pulse_strength, force_highlight) end);
		end;
		return true;
		
	elseif not do_not_highlight_upstream then
		self:highlight_books_of_nagash_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;



function campaign_ui_manager:highlight_buildings(value, pulse_strength, force_highlight, panel_and_button)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	if value then
		self:highlight_building_browser_buildings(value, pulse_strength, force_highlight, true);
		self:highlight_horde_buildings(value, pulse_strength, force_highlight, true);
	end;

	local cm = get_cm();
	local uic_panel = find_uicomponent(core:get_ui_root(), "main_settlement_panel");
	
	if uic_panel and uic_panel:Visible(true) then
	
		-- define a function that can process all the buildings in a settlement
		local process_func = function(uic, value)		
			local slot_num = 1;
			
			while true do
				local uic_building = find_uicomponent(uic, "building_slot_" .. slot_num);
				
				if not uic_building then
					break;
				end;
				
				-- get the child, if it exists
				if uic_building:ChildCount() == 0 then
					break;
				end;
				
				uic_building = UIComponent(uic_building:Find(0));
				
				if string.find(uic_building:Id(), "Construction") then
					-- constuction site
					local uic_button = find_uicomponent(uic_building, "button_expand_slot");
					
					if uic_button then
						pulse_uicomponent(uic_button, value, pulse_strength or self.button_pulse_strength);
					end;
				else
					-- standard building
					pulse_uicomponent(uic_building, value, pulse_strength or self.button_pulse_strength);
				end;
				
				slot_num = slot_num + 1;
			end;
		end;
		
		-- loop through the capital and all settlements on the province overview panel and call the function above
		-- if first_settlement_only is set, only process the first settlement
		local loop_start = 0;
		local loop_end = uic_panel:ChildCount() - 1;
		
		if first_settlement_only then
			loop_end = 0;
		end;
		
		if all_but_first_settlement then
			loop_start = 1;
		end;
		
		for i = loop_start, loop_end do
			local uic_child = UIComponent(uic_panel:Find(i));
			
			process_func(uic_child, value);
			
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_buildings(false, pulse_strength, force_highlight, first_settlement_only) end);
		end;
		return true;
	else
		self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_building_browser_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = self.cm;
	local uic = find_uicomponent(core:get_ui_root(), "settlement_panel", "button_building_browser");

	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_building_browser_button(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	else
		self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
end;


function campaign_ui_manager:highlight_building_browser(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_browser = find_uicomponent(core:get_ui_root(), "building_browser");
	
	if uic_browser and uic_browser:Visible(true) then
		pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		-- frame, back and button
		local uic_panel_frame = find_uicomponent(uic_browser, "panel_frame");
		if uic_panel_frame then
			pulse_uicomponent(uic_panel_frame, value, pulse_strength);
			
			local uic_back = find_uicomponent(uic_panel_frame, "panel_back");
			if uic_back then
				pulse_uicomponent(uic_back, value, pulse_strength);
			end;
			
			local uic_button = find_uicomponent(uic_panel_frame, "button_ok");
			if uic_button then
				pulse_uicomponent(uic_button, value, pulse_strength);
			end;
		end;
		
		-- header
		local uic_header = find_uicomponent(uic_browser, "header_frame");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength, true);
		end;
		
		-- treasury
		local uic_treasury = find_uicomponent(uic_browser, "dy_treasury");
		if uic_treasury then
			pulse_uicomponent(uic_treasury, value, pulse_strength, true);
		end;
		
		-- top-left info
		local uic_frame_tl = find_uicomponent(uic_browser, "frame_TL");
		if uic_frame_tl then
			pulse_uicomponent(uic_frame_tl, value, pulse_strength);
			
			-- corruption
			local uic_frame_corruption = find_uicomponent(uic_frame_tl, "frame_corruption");
			if uic_frame_corruption then
				pulse_uicomponent(uic_frame_corruption, value, pulse_strength);
				
				-- header
				local uic_corruption_header = find_uicomponent(uic_frame_corruption, "header_frame");
				if uic_corruption_header then
					pulse_uicomponent(uic_corruption_header, value, pulse_strength);
				end;
			end;
			
			-- growth
			local uic_frame_growth = find_uicomponent(uic_frame_tl, "frame_growth");
			if uic_frame_growth then
				pulse_uicomponent(uic_frame_growth, value, pulse_strength);
				
				-- header
				local uic_growth_header = find_uicomponent(uic_frame_corruption, "header_frame");
				if uic_growth_header then
					pulse_uicomponent(uic_growth_header, value, pulse_strength);
				end;
			end;
		end;
		
		-- top-right info
		local uic_frame_tr = find_uicomponent(uic_browser, "frame_TR");
		if uic_frame_tr then
			pulse_uicomponent(uic_frame_tr, value, pulse_strength);
			
			-- income
			local uic_frame_income = find_uicomponent(uic_frame_tr, "frame_PO_income");
			if uic_frame_income then
				pulse_uicomponent(uic_frame_income, value, pulse_strength);
				
				-- tax frame
				local uic_tax_frame = find_uicomponent(uic_frame_income, "tax_frame");
				if uic_tax_frame then
					pulse_uicomponent(uic_tax_frame, value, pulse_strength);
				end;
			end;
			
			-- effects
			local uic_effects = find_uicomponent(uic_frame_tr, "effects");
			if uic_effects then
				pulse_uicomponent(uic_effects, value, pulse_strength);
				
				-- header
				local uic_effects_header = find_uicomponent(uic_effects, "header_frame");
				if uic_effects_header then
					pulse_uicomponent(uic_effects_header, value, pulse_strength);
				end;
			end;
		end;
		
		-- settlement buttons		
		local uic_settlements = find_uicomponent(uic_browser, "main_settlement_panel");
		if uic_settlements then
			for i = 0, uic_settlements:ChildCount() - 1 do
				local uic_button = find_uicomponent(UIComponent(uic_settlements:Find(i)), "button_zoom");
				if uic_button then
					pulse_uicomponent(uic_button, value, pulse_strength);
				end;				
			end;
		end;
		
		if value then
			self:highlight_building_browser_buildings(value, pulse_strength, force_highlight, true);
			table.insert(self.unhighlight_action_list, function() self:highlight_building_browser(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_building_browser_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_building_browser_buildings(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_browser = find_uicomponent(core:get_ui_root(), "building_browser");
	
	if uic_browser and uic_browser:Visible(true) then		
		local uic_slot_parent = find_uicomponent(uic_browser, "building_tree_clip", "building_tree",  "slot_parent");
		
		if uic_slot_parent then
			for i = 0, uic_slot_parent:ChildCount() - 1 do
				local uic_slot = UIComponent(uic_slot_parent:Find(i));
				
				-- should only be one building in each slot, but let's loop
				for j = 0, uic_slot:ChildCount() - 1 do
					local uic_building = UIComponent(uic_slot:Find(j));
					pulse_uicomponent(uic_building, value, pulse_strength or self.panel_pulse_strength);
				end;				
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_building_browser_buildings(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_building_browser_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_building_panel(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_tab = find_uicomponent(ui_root, "units_panel", "main_units_panel", "tabgroup", "tab_horde_buildings");
	
	if uic_tab and uic_tab:Visible(true) and uic_tab:CurrentState() == "selected" then
	
		pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		local uic_panel = find_uicomponent(ui_root, "units_panel", "main_units_panel");
		pulse_uicomponent(uic_panel, value, pulse_strength);
		
		-- frame
		local uic_frame = find_uicomponent(uic_panel, "frame");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength);
		end;
		
		-- header
		local uic_header = find_uicomponent(uic_panel, "header");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength, true);
		end;
		
		-- building frame
		local uic_building_frame = find_uicomponent(uic_panel, "horde_building_frame");
		if uic_building_frame then
			
			-- background
			local uic_background = find_uicomponent(uic_building_frame, "panorama");
			if uic_background then
				pulse_uicomponent(uic_background, value, pulse_strength);
			end;
			
			-- growth
			local uic_growth = find_uicomponent(uic_building_frame, "pop_surplus");
			if uic_growth then
				pulse_uicomponent(uic_growth, value, pulse_strength, true);
			end;
			
			-- income
			local uic_income = find_uicomponent(uic_building_frame, "dy_income");
			if uic_income then
				pulse_uicomponent(uic_income, value, pulse_strength, true);
			end;
		end;

		if value then
			self:highlight_horde_buildings(value,  pulse_strength, force_highlight, true);
			table.insert(self.unhighlight_action_list, function() self:highlight_building_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_building_panel_tab(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_building_panel_tab(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_tab = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "tabgroup", "tab_horde_buildings");
	
	if uic_tab and uic_tab:Visible(true) then
		pulse_uicomponent(uic_tab, value, pulse_strength or self.button_pulse_strength);
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_building_panel_tab(false, pulse_strength, force_highlight) end);
		end;
	else
		self:highlight_armies(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_canopic_jars(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	if value then
		table.insert(self.unhighlight_action_list, function() self:highlight_canopic_jars(false, pulse_strength, force_highlight) end);
	end;
	return highlight_visible_component(value, true, "layout", "resources_bar", "canopic_jars_holder");
end;


function campaign_ui_manager:highlight_character_available_skill_points(value, do_not_highlight_upstream, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "character_details_panel", "dy_pts");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength - 2);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_character_available_skill_points(false, false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_character_details_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_details(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_character_details = find_uicomponent(core:get_ui_root(), "character_details_panel", "character_details_subpanel");
	if uic_character_details and uic_character_details:Visible(true) then
		pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		-- info
		local uic_info = find_uicomponent(uic_character_details, "details");
		if uic_info then
			pulse_uicomponent(uic_info, value, pulse_strength);
			
			-- title
			local uic_title = find_uicomponent(uic_info, "parchment_divider_title");
			if uic_title then
				pulse_uicomponent(uic_title, value, pulse_strength, true);
			end;
		end;
		
		-- traits
		local uic_traits = find_uicomponent(uic_character_details, "traits_subpanel");
		if uic_traits then
			pulse_uicomponent(uic_traits, value, pulse_strength);
			
			-- title
			local uic_title = find_uicomponent(uic_traits, "parchment_divider_title");
			if uic_title then
				pulse_uicomponent(uic_title, value, pulse_strength, true);
			end;
		end;
		
		-- ancillaries
		local uic_ancillaries = find_uicomponent(uic_character_details, "ancillary_general");
		if uic_ancillaries then
			pulse_uicomponent(uic_ancillaries, value, pulse_strength, true);
		end;
		
		-- equipment
		local uic_equipment = find_uicomponent(uic_character_details, "ancillary_equipment");
		if uic_equipment then
			pulse_uicomponent(uic_equipment, value, pulse_strength, true);
		end;
		
		if value then
			self:highlight_banners_and_marks(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_character_details(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_character_details_panel_details_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_details_button(value, pulse_strength, force_highlight, do_not_highlight_armies)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = self.cm;
	local uic = find_uicomponent(core:get_ui_root(), "primary_info_panel_holder", "button_general");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_character_details_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_armies then
		self:highlight_armies(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_details_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_panel = find_uicomponent(core:get_ui_root(), "character_details_panel");
	
	if uic_panel and uic_panel:Visible(true) then
	
		local pulse_strength_to_use = pulse_strength or self.panel_pulse_strength;
	
		-- frame
		local uic_panel_frame = find_uicomponent(uic_panel, "panel_frame");
		if uic_panel_frame then
			pulse_uicomponent(uic_panel_frame, value, pulse_strength_to_use, true);
		end;
		
		-- title
		local uic_title = find_uicomponent(uic_panel, "character_name");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength_to_use, true);
		end;
		
		-- ok button
		local uic_button = find_uicomponent(uic_panel, "button_ok");
		if uic_button then
			pulse_uicomponent(uic_button, value, pulse_strength_to_use);
		end;
		
		-- bottom buttons
		local uic_bottom_buttons = find_uicomponent(uic_panel, "bottom_buttons");
		if uic_bottom_buttons then
			pulse_uicomponent(uic_bottom_buttons, value, pulse_strength_to_use, true);
		end;
		
		-- character stats
		local uic_char_stats = find_uicomponent(uic_panel, "stats_panel");
		if uic_char_stats then
			pulse_uicomponent(uic_char_stats, value, pulse_strength_to_use);
		
			-- header
			local uic_header = find_uicomponent(uic_char_stats, "stat_header");
			if uic_header then
				pulse_uicomponent(uic_header, value, pulse_strength_to_use, true);
			end;
			
			-- arrow
			local uic_arrow = find_uicomponent(uic_char_stats, "skill_arrow_stats");
			if uic_arrow then
				pulse_uicomponent(uic_arrow, value, pulse_strength_to_use);
			end;
		end;
		
		-- battle effects
		local uic_battle_effects = find_uicomponent(uic_panel, "battle_effects_window");
		if uic_battle_effects then
			pulse_uicomponent(uic_battle_effects, value, pulse_strength_to_use);
			
			-- header
			local uic_header = find_uicomponent(uic_battle_effects, "battle_header");
			if uic_header then
				pulse_uicomponent(uic_header, value, pulse_strength_to_use, true);
			end;
			
			-- arrow
			local uic_arrow = find_uicomponent(uic_battle_effects, "skill_arrow_battle");
			if uic_arrow then
				pulse_uicomponent(uic_arrow, value, pulse_strength_to_use);
			end;
		end;
		
		-- campaign effects
		local uic_campaign_effects = find_uicomponent(uic_panel, "campaign_effects_window");
		if uic_campaign_effects then
			pulse_uicomponent(uic_campaign_effects, value, pulse_strength_to_use);
			
			-- header
			local uic_header = find_uicomponent(uic_campaign_effects, "campaign_header");
			if uic_header then
				pulse_uicomponent(uic_header, value, pulse_strength_to_use, true);
			end;
			
			-- arrow
			local uic_arrow = find_uicomponent(uic_campaign_effects, "skill_arrow_campaign");
			if uic_arrow then
				pulse_uicomponent(uic_arrow, value, pulse_strength_to_use);
			end;
		end;
		
		-- character details
		local uic_character_details = find_uicomponent(uic_panel, "character_details_subpanel");
		if uic_character_details and uic_character_details:Visible(true) then
			-- info
			local uic_info = find_uicomponent(uic_character_details, "details");
			if uic_info then
				pulse_uicomponent(uic_info, value, pulse_strength_to_use);
				
				-- title
				local uic_title = find_uicomponent(uic_info, "parchment_divider_title");
				if uic_title then
					pulse_uicomponent(uic_title, value, pulse_strength_to_use, true);
				end;
			end;
			
			-- traits
			local uic_traits = find_uicomponent(uic_character_details, "traits_subpanel");
			if uic_traits then
				pulse_uicomponent(uic_traits, value, pulse_strength_to_use);
				
				-- title
				local uic_title = find_uicomponent(uic_traits, "parchment_divider_title");
				if uic_title then
					pulse_uicomponent(uic_title, value, pulse_strength_to_use, true);
				end;
			end;
			
			-- ancillaries
			local uic_ancillaries = find_uicomponent(uic_character_details, "ancillary_general");
			if uic_ancillaries then
				pulse_uicomponent(uic_ancillaries, value, pulse_strength_to_use, true);
			end;
			
			-- equipment
			local uic_equipment = find_uicomponent(uic_character_details, "ancillary_equipment");
			if uic_equipment then
				pulse_uicomponent(uic_equipment, value, pulse_strength_to_use, true);
			end;
		end;

		-- skills
		local uic_skills = find_uicomponent(uic_panel, "skills_subpanel");
		if uic_skills and uic_skills:Visible(true) then
			pulse_uicomponent(uic_skills, value, pulse_strength_to_use);
			
			-- reset button
			local uic_reset = find_uicomponent(uic_skills, "stats_reset_holder");
			if uic_reset then
				pulse_uicomponent(uic_reset, value, pulse_strength_to_use, true);
			end;
		end;
			
		if value then
			self:highlight_character_details_panel_rank_indicator(value, pulse_strength, force_highlight);
			self:highlight_character_available_skill_points(value, pulse_strength, force_highlight, true);
			self:highlight_character_details_panel_details_button(value, pulse_strength, force_highlight, true);
			self:highlight_character_details_panel_skills_button(value, pulse_strength, force_highlight, true);
			table.insert(self.unhighlight_action_list, function() self:highlight_character_details_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_character_details_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_details_panel_details_button(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "character_details_panel", "TabGroup", "details");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength - 2);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_character_details_panel_details_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_character_details_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_details_panel_rank_indicator(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_rank = find_uicomponent(core:get_ui_root(), "character_details_panel", "rank");
	if uic_rank and uic_rank:Visible(true) then
		pulse_uicomponent(uic_rank, value, pulse_strength or self.button_pulse_strength, true);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_character_details_panel_rank_indicator(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
end;


function campaign_ui_manager:highlight_character_details_panel_skills_button(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "character_details_panel", "TabGroup", "skills");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength - 2);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_character_details_panel_skills_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_character_skills_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_info_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = self.cm;
	local uic_character_info_panel = find_uicomponent(core:get_ui_root(), "CharacterInfoPopup");
	
	if uic_character_info_panel and uic_character_info_panel:Visible(true) then
		local panel_pulse_strength = pulse_strength or self.panel_pulse_strength;
		
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "porthole_mask"), value, panel_pulse_strength);
		-- pulse_uicomponent(find_uicomponent(uic_character_info_panel, "rank"), value, panel_pulse_strength, true);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "mount_icon"), value, panel_pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "effects_over"), value, panel_pulse_strength);
		
		-- highlight effects list
		local uic_effects = find_uicomponent(uic_character_info_panel, "effect_list");
		if uic_effects then
			pulse_uicomponent(uic_effects, value, panel_pulse_strength, true);
		end;
		
		-- highlight equipment list
		local uic_equipment_list = find_uicomponent(uic_character_info_panel, "equipment_list");
		if uic_equipment_list then
			pulse_uicomponent(uic_equipment_list, value, panel_pulse_strength, true);
		end;
		
		-- frame
		local uic_ap_frame = find_uicomponent(uic_character_info_panel, "ap_frame");
		if uic_ap_frame then
			pulse_uicomponent(uic_ap_frame, value, panel_pulse_strength);
		end;
		
		if value then
			self:highlight_character_details_button(value, pulse_strength, force_highlight, true);
			self:highlight_character_skills_button(value, pulse_strength, force_highlight, true);
			self:highlight_fightiness_bar(value, pulse_strength, force_highlight, true);
			self:highlight_stances(value, pulse_strength, force_highlight, true);
			self:highlight_movement_range(value, pulse_strength, force_highlight, true);
			table.insert(self.unhighlight_action_list, function() self:highlight_character_info_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_armies(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_magic_items(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_equipment = find_uicomponent(core:get_ui_root(), "character_details_panel", "character_details_subpanel", "ancillary_equipment");
	
	if uic_equipment and uic_equipment:Visible(true) then
		pulse_uicomponent(uic_equipment, value, pulse_strength or self.panel_pulse_strength, true);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_character_magic_items(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_character_details_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_skills(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_skills = find_uicomponent(ui_root, "character_details_panel", "skills_subpanel");
	
	if uic_skills and uic_skills:Visible(true) then
		-- character details panel is open
		pulse_uicomponent(uic_skills, value, pulse_strength or self.panel_pulse_strength);
			
		-- reset button
		local uic_reset = find_uicomponent(uic_skills, "stats_reset_holder");
		if uic_reset then
			pulse_uicomponent(uic_reset, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		if value then
			self:highlight_character_available_skill_points(value, pulse_strength, force_highlight, true);
			self:highlight_character_details_panel_rank_indicator(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_character_skills(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		if value then
			self:highlight_character_details_panel_rank_indicator(value, pulse_strength, force_highlight);
			self:highlight_character_available_skill_points(value, pulse_strength, force_highlight, true);
		end;
		self:highlight_character_details_panel_skills_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_skills_button(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "info_panel_holder", "primary_info_panel_holder", "CharacterInfoPopup", "skill_button");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_character_skills_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_armies(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_character_traits(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_traits = find_uicomponent(core:get_ui_root(), "character_details_panel", "character_details_subpanel", "traits_subpanel");
	
	if uic_traits and uic_traits:Visible(true) then			
		pulse_uicomponent(uic_traits, value, pulse_strength or self.panel_pulse_strength);
		
		-- title
		local uic_title = find_uicomponent(uic_traits, "parchment_divider_title");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_character_traits(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_character_details_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_chivalry(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_chivalry_bar = find_uicomponent(core:get_ui_root(), "chivalry_bar");
	
	if uic_chivalry_bar and uic_chivalry_bar:Visible(true) then
		-- player fill (positive)
		local uic_player_pos = find_uicomponent(uic_chivalry_bar, "positive_segment", "player");
		
		if uic_player_pos and uic_player_pos:Visible(true) then
			pulse_uicomponent(uic_player_pos, value, pulse_strength or self.button_pulse_strength);
		end;
		
		-- player fill (negative)
		local uic_player_neg = find_uicomponent(uic_chivalry_bar, "negative_segment", "player");
		
		if uic_player_neg and uic_player_neg:Visible(true) then
			pulse_uicomponent(uic_player_neg, value, pulse_strength or self.button_pulse_strength);
		end;
		
		-- bar background
		local uic_other = find_uicomponent(uic_chivalry_bar, "other");
		
		if uic_other and uic_other:Visible(true) then
			pulse_uicomponent(uic_other, value, pulse_strength or self.button_pulse_strength);
		end;
		
		-- bar frame
		local uic_frame = find_uicomponent(uic_chivalry_bar, "frame");
		
		if uic_frame and uic_frame:Visible(true) then
			pulse_uicomponent(uic_frame, value, pulse_strength or self.button_pulse_strength);
		end;
		
		-- number on frame
		local uic_current_frame = find_uicomponent(uic_chivalry_bar, "current_frame");
		
		if uic_current_frame and uic_current_frame:Visible(true) then
			pulse_uicomponent(uic_current_frame, value, pulse_strength or self.button_pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_chivalry(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_commandments(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic = find_uicomponent(core:get_ui_root(), "stack_incentives", "button_default");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_commandments(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		return self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_corruption(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "layout", "info_panel_holder", "primary_info_panel_holder", "info_panel_background", "ProvinceInfoPopup", "frame_corruption");
	
	if uic and uic:Visible(true) and is_fully_onscreen(uic) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		
		-- header
		local uic_header = find_uicomponent(uic, "header_frame");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_corruption(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_diplomacy_attitude_icons(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_list = find_uicomponent(core:get_ui_root(), "diplomacy_dropdown", "faction_panel", "sortable_list_factions", "list_clip", "list_box");
	
	if uic_list and uic_list:Visible(true) then
	
		for i = 0, uic_list:ChildCount() - 1 do
			local uic_row = UIComponent(uic_list:Find(i));
			local uic_attitude = find_uicomponent(uic_row, "attitude");
			
			if uic_attitude then
				pulse_uicomponent(uic_attitude, value, pulse_strength or self.button_pulse_strength);
			end;
		end;
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_diplomacy_attitude_icons(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_diplomacy_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_diplomacy_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "faction_buttons_docker", "button_diplomacy");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_diplomacy_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_diplomacy_centre_panel(value, pulse_strength, force_highlight, do_not_highlight_button)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_screen = find_uicomponent(core:get_ui_root(), "diplomacy_dropdown");
	
	if uic_screen and uic_screen:Visible(true) then
		-- see if faction_panel is visible
		local uic_faction_panel = find_uicomponent(uic_screen, "faction_panel");
		if uic_faction_panel and uic_faction_panel:Visible(true) then
			pulse_uicomponent(uic_faction_panel, value, pulse_strength or self.panel_pulse_strength, true);
		else
			-- otherwise, see if offers_panel is visible
			local uic_offers_panel = find_uicomponent(uic_screen, "offers_panel");
			if uic_offers_panel and uic_offers_panel:Visible(true) then
				pulse_uicomponent(uic_offers_panel, value, pulse_strength or self.panel_pulse_strength, true);
			else
				-- otherwise see if subpanel_group is visible
				local uic_subpanel_group = find_uicomponent(uic_screen, "offers_panel");
				if uic_subpanel_group and uic_subpanel_group:Visible(true) then
					pulse_uicomponent(uic_subpanel_group, value, pulse_strength or self.panel_pulse_strength, true);
				end;
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_diplomacy_centre_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_button then
		self:highlight_diplomacy_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_diplomacy_left_panel(value, pulse_strength, force_highlight, do_not_highlight_button)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_left_panel = find_uicomponent(core:get_ui_root(), "diplomacy_dropdown", "faction_left_status_panel");
	if uic_left_panel and uic_left_panel:Visible(true) then
		pulse_uicomponent(uic_left_panel, value, pulse_strength or self.panel_pulse_strength);
		
		local uic_porthole = find_uicomponent(uic_left_panel, "porthole");
		if uic_porthole then
			pulse_uicomponent(uic_porthole, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_diplomacy_left_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_button then
		self:highlight_diplomacy_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_diplomacy_right_panel(value, pulse_strength, force_highlight, do_not_highlight_button)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_left_panel = find_uicomponent(core:get_ui_root(), "diplomacy_dropdown", "faction_right_status_panel");
	if uic_left_panel and uic_left_panel:Visible(true) then
		pulse_uicomponent(uic_left_panel, value, pulse_strength or self.panel_pulse_strength);
		
		local uic_porthole = find_uicomponent(uic_left_panel, "porthole");
		if uic_porthole then
			pulse_uicomponent(uic_porthole, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_diplomacy_right_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_button then
		self:highlight_diplomacy_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_diplomacy_screen(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "diplomacy_dropdown");
	
	if uic and uic:Visible(true) then
		if value then
			self:highlight_diplomacy_centre_panel(value, pulse_strength, force_highlight, true);
			self:highlight_diplomacy_left_panel(value, pulse_strength, force_highlight, true);
			self:highlight_diplomacy_right_panel(value, pulse_strength, force_highlight, true);
			table.insert(self.unhighlight_action_list, function() self:highlight_diplomacy_screen(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_diplomacy_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_drop_down_list_buttons(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	self:highlight_list_button_factions(value, pulse_strength, force_highlight);
	self:highlight_list_button_provinces(value, pulse_strength, force_highlight);
	self:highlight_list_button_forces(value, pulse_strength, force_highlight);
	self:highlight_list_button_events(value, pulse_strength, force_highlight);
	self:highlight_list_button_missions(value, pulse_strength, force_highlight);
end;


function campaign_ui_manager:highlight_dynasties(value, pulse_strength, force_highlight)
	return self:highlight_technologies(value, pulse_strength, force_highlight);
end;


function campaign_ui_manager:highlight_dynasties_panel(value, pulse_strength, force_highlight)
	return self:highlight_technology_panel(value, pulse_strength, force_highlight);
end;


function campaign_ui_manager:highlight_end_turn_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_end_turn");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_end_turn_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_events_list(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "radar_things", "events_dropdown", "panel");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_events_list(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_list_button_events(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_factions_list(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "radar_things", "factions_dropdown", "panel");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_factions_list(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_list_button_factions(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_faction_summary_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "bar_small_top", "button_factions");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_faction_summary_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_faction_summary_records_tab(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_tab = find_uicomponent(ui_root, "clan", "main", "TabGroup", "Records");	

	if uic_tab and uic_tab:Visible(true) then
		pulse_uicomponent(uic_tab, value, pulse_strength or self.button_pulse_strength);
		
		-- event_feed
		local uic_event_feed = find_uicomponent(ui_root, "clan", "main", "tab_children_parent", "Records", "event_feed"); 
		if uic_event_feed and uic_event_feed:Visible(true) then
		
			pulse_strength = pulse_strength or self.panel_pulse_strength;

			-- filters
			local uic_filters_button = find_uicomponent(uic_event_feed, "filters_toggle");
			if uic_filters_button then
				pulse_uicomponent(uic_filters_button, value, pulse_strength);
				
				-- filters panel
				local uic_filters_panel = find_uicomponent(uic_filters_button, "filters");
				if uic_filters_panel and uic_filters_panel:Visible(true) then
					pulse_uicomponent(uic_filters_panel, value, pulse_strength);
					
					-- subpanel
					local uic_filters_subpanel = find_uicomponent(uic_filters_panel, "subpanel");
					if uic_filters_subpanel and uic_filters_subpanel:Visible(true) then
						pulse_uicomponent(uic_filters_subpanel, value, pulse_strength);
					end;
					
					-- subpanel header
					local uic_filters_subpanel_header = find_uicomponent(uic_filters_panel, "tx_header");
					if uic_filters_subpanel_header and uic_filters_subpanel_header:Visible(true) then
						-- root > clan > main > tab_children_parent > Records > event_feed > filters_toggle > filters > tx_header
						pulse_uicomponent(uic_filters_subpanel_header, value, pulse_strength);
					end;
					
					-- load filter
					local uic_load_filter = find_uicomponent(uic_filters_panel, "button_load_filter");
					if uic_load_filter then
						pulse_uicomponent(uic_load_filter, value, pulse_strength);
					end;
					
					-- save filter
					local uic_save_filter = find_uicomponent(uic_filters_panel, "button_save_filter");
					if uic_save_filter then
						pulse_uicomponent(uic_save_filter, value, pulse_strength);
					end;
				end;				
			end;
			
			-- feed
			local uic_feed = find_uicomponent(uic_event_feed, "feed");
			if uic_feed then
				pulse_uicomponent(uic_feed, value, pulse_strength);
				
				-- frame
				local uic_frame = find_uicomponent(uic_feed, "frame");
				if uic_frame then
					pulse_uicomponent(uic_frame, value, pulse_strength);
				end;
				
				-- header
				local uic_header = find_uicomponent(uic_feed, "tx_header");
				if uic_header then
					pulse_uicomponent(uic_header, value, pulse_strength);
				end;
			end;
			
			-- map controls
			local uic_controls = find_uicomponent(uic_event_feed, "map_controls");
			if uic_controls then
				pulse_uicomponent(uic_controls, value, pulse_strength, true);
			end;
			
			-- add filter button
			local uic_add_filter_button = find_uicomponent(uic_event_feed, "button_add_filter");
			if uic_add_filter_button then
				pulse_uicomponent(uic_add_filter_button, value, pulse_strength);
			end;
			
			-- view event button
			local uic_view_event_button = find_uicomponent(uic_event_feed, "button_open_message");
			if uic_view_event_button then
				pulse_uicomponent(uic_view_event_button, value, pulse_strength);
			end;
			
			-- clear context button
			local uic_clear_context_button = find_uicomponent(uic_event_feed, "button_clear_context");
			if uic_clear_context_button then
				pulse_uicomponent(uic_clear_context_button, value, pulse_strength);
			end;

			-- context subpanel
			local uic_context_subpanel = find_uicomponent(uic_event_feed, "context_subpanel");
			if uic_context_subpanel then
				pulse_uicomponent(uic_context_subpanel, value, pulse_strength);
				
				-- faction subpanel
				local uic_faction_subpanel = find_uicomponent(uic_context_subpanel, "faction_context_subpanel");
				if uic_faction_subpanel and uic_faction_subpanel:Visible(true) then
					pulse_uicomponent(uic_faction_subpanel, value, pulse_strength);
					
					local uic_header = find_uicomponent(uic_faction_subpanel, "header");
					if uic_header then
						pulse_uicomponent(uic_header, value, pulse_strength, true);
					end;
				end;
				
				-- character subpanel
				local uic_character_subpanel = find_uicomponent(uic_context_subpanel, "character_context_subpanel", "subpanel");
				if uic_character_subpanel and uic_character_subpanel:Visible(true) then
					pulse_uicomponent(uic_character_subpanel, value, pulse_strength);
					
					local uic_header = find_uicomponent(uic_character_subpanel, "header");
					if uic_header then
						pulse_uicomponent(uic_header, value, pulse_strength);
					end;
				end;
				
				-- force subpanel
				local uic_force_subpanel = find_uicomponent(uic_context_subpanel, "force_context_subpanel", "subpanel");
				if uic_force_subpanel and uic_force_subpanel:Visible(true) then
					pulse_uicomponent(uic_force_subpanel, value, pulse_strength);
					
					local uic_header = find_uicomponent(uic_force_subpanel, "header");
					if uic_header then
						pulse_uicomponent(uic_header, value, pulse_strength);
					end;
				end;
				
				-- province subpanel
				local uic_province_subpanel = find_uicomponent(uic_context_subpanel, "province_context_subpanel", "subpanel");
				if uic_province_subpanel and uic_province_subpanel:Visible(true) then
					pulse_uicomponent(uic_province_subpanel, value, pulse_strength);
					
					local uic_header = find_uicomponent(uic_province_subpanel, "header");
					if uic_header then
						pulse_uicomponent(uic_header, value, pulse_strength);
					end;
				end;
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_faction_summary_records_tab(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_faction_summary_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_faction_summary_screen(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	local uic_screen = find_uicomponent(ui_root, "clan");
	
	if uic_screen and uic_screen:Visible(true) then
		
		-- frame
		local uic_frame = find_uicomponent(uic_screen, "panel_frame");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		-- header
		local uic_header = find_uicomponent(uic_screen, "header_frame");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		if value then
			self:highlight_faction_summary_records_tab(value, pulse_strength, force_highlight, true);
			self:highlight_faction_summary_summary_tab(value, pulse_strength, force_highlight, true);
			self:highlight_faction_summary_statistics_tab(value, pulse_strength, force_highlight, true);
			table.insert(self.unhighlight_action_list, function() self:highlight_faction_summary_screen(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		return self:highlight_faction_summary_button(value, pulse_strength, force_highlight);
	end;
end;


function campaign_ui_manager:highlight_faction_summary_summary_tab(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_tab = find_uicomponent(ui_root, "clan", "main", "TabGroup", "Summary");	

	if uic_tab and uic_tab:Visible(true) then
		pulse_uicomponent(uic_tab, value, self.button_pulse_strength);
		
		pulse_strength = pulse_strength or self.panel_pulse_strength;
		
		-- left panel
		local uic_parchment_left = find_uicomponent(ui_root, "clan", "main", "tab_children_parent", "Summary", "parchment_L"); 
		if uic_parchment_left and uic_parchment_left:Visible(true) then
			pulse_uicomponent(uic_parchment_left, value, pulse_strength);
			
			-- details
			local uic_details = find_uicomponent(uic_parchment_left, "details");
			if uic_details then
				pulse_uicomponent(uic_details, value, pulse_strength);
			end;
			
			-- details header
			local uic_details_header = find_uicomponent(uic_details, "parchment_divider_title");
			if uic_details_header then
				pulse_uicomponent(uic_details_header, value, pulse_strength);
			end;
			
			-- effects
			local uic_effects = find_uicomponent(uic_parchment_left, "trait_panel");
			if uic_effects then
				pulse_uicomponent(uic_effects, value, pulse_strength);
			end;
			
			-- effects header
			local uic_effects_header = find_uicomponent(uic_effects, "parchment_divider_title");
			if uic_effects_header then
				pulse_uicomponent(uic_effects_header, value, pulse_strength);
			end;
		end;
		
		-- right panel
		local uic_parchment_right = find_uicomponent(ui_root, "clan", "main", "tab_children_parent", "Summary", "parchment_R"); 
		if uic_parchment_right and uic_parchment_right:Visible(true) then
			pulse_uicomponent(uic_parchment_right, value, pulse_strength);
			
			-- power
			local uic_power = find_uicomponent(uic_parchment_right, "imperium");
			if uic_power then
				pulse_uicomponent(uic_power, value, pulse_strength);
			end;
			
			-- details header
			local uic_power_header = find_uicomponent(uic_power, "parchment_divider_title");
			if uic_power_header then
				pulse_uicomponent(uic_power_header, value, pulse_strength);
			end;
			
			-- diplomacy
			local uic_diplomacy = find_uicomponent(uic_parchment_right, "diplomacy");
			if uic_diplomacy then
				pulse_uicomponent(uic_diplomacy, value, pulse_strength);
			end;
			
			-- diplomacy header
			local uic_diplomacy_header = find_uicomponent(uic_diplomacy, "parchment_divider_title");
			if uic_diplomacy_header then
				pulse_uicomponent(uic_diplomacy_header, value, pulse_strength);
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_faction_summary_summary_tab(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_faction_summary_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_faction_summary_statistics_tab(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_tab = find_uicomponent(ui_root, "clan", "main", "TabGroup", "Stats");	

	if uic_tab and uic_tab:Visible(true) then
		pulse_uicomponent(uic_tab, value, pulse_strength or self.button_pulse_strength);
		
		local uic_stats = find_uicomponent(ui_root, "clan", "main", "tab_children_parent", "Stats", "stats_panel"); 
		if uic_stats and uic_stats:Visible(true) then
			pulse_uicomponent(uic_stats, value, pulse_strength or self.panel_pulse_strength);
			
			-- header
			local uic_header = find_uicomponent(uic_stats, "parchment_divider_title");
			if uic_header then
				pulse_uicomponent(uic_header, value, pulse_strength or self.panel_pulse_strength);
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_faction_summary_statistics_tab(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_faction_summary_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_fightiness_bar(value, pulse_strength, force_highlight, do_not_highlight_armies)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = self.cm;
	local uic_character_info_panel = find_uicomponent(core:get_ui_root(), "CharacterInfoPopup");
	
	if uic_character_info_panel and uic_character_info_panel:Visible(true) then
		pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "morale_container"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "icon_waaargh"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "frame"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "icon_animosity"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "threshold_lowest"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "threshold_lower"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "threshold_upper"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "background_morale_bar"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_character_info_panel, "foreground_morale_bar"), value, pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_fightiness_bar(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_armies then
		self:highlight_armies(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_food_bar(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_food = find_uicomponent(core:get_ui_root(), "skv_food_holder", "visibility_holder");
	
	if uic_food and uic_food:Visible(true) then
		-- food icon
		local uic_icon = find_uicomponent(uic_food, "icon");
		
		if uic_icon and uic_icon:Visible(true) then
			pulse_uicomponent(uic_icon, value, pulse_strength or self.button_pulse_strength);
		end;
		
		-- frame
		local uic_frame = find_uicomponent(uic_food, "frame");
		
		if uic_frame and uic_frame:Visible(true) then
			pulse_uicomponent(uic_frame, value, pulse_strength or self.button_pulse_strength);
		end;
		
		-- current holder
		local uic_current_holder = find_uicomponent(uic_frame, "skv_food_current", "current_holder");
		
		if uic_current_holder and uic_current_holder:Visible(true) then
			pulse_uicomponent(uic_current_holder, value, pulse_strength or self.button_pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_food_bar(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_forces_list(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "radar_things", "units_dropdown", "panel");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength, true);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_forces_list(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_list_button_forces(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_garrison_armies(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_button = find_uicomponent(ui_root, "layout", "hud_center", "button_group_settlement", "button_show_garrison");
		
	if uic_button and uic_button:Visible(true) and (uic_button:CurrentState() == "selected" or uic_button:CurrentState() == "selected_down") then
		pulse_strength = self.panel_pulse_strength or self.panel_pulse_strength;
		
		local uic_panel = find_uicomponent(ui_root, "settlement_panel", "main_settlement_panel");
		if uic_panel then
			for i = 0, uic_panel:ChildCount() - 1 do
				local uic_settlement = UIComponent(uic_panel:Find(i));
				
				local uic_land_units_frame = find_uicomponent(uic_settlement, "garrison_list", "land_units_frame");
				if uic_land_units_frame then
					for j = 0, uic_land_units_frame:ChildCount() - 1 do
						pulse_uicomponent(UIComponent(uic_land_units_frame:Find(j)), value, pulse_strength);
					end;
				end;
			end;		
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_garrison_armies(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_garrison_details_button(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_garrison_details_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_settlement", "button_show_garrison");
		
	if uic and uic:Visible(true) and is_fully_onscreen(uic) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_garrison_details_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_geomantic_web_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_geomantic_web");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_geomantic_web_button(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;



function campaign_ui_manager:highlight_global_recruitment_pool(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_pool = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options", "recruitment_listbox", "global");
	if not (uic_pool and uic_pool:Visible(true)) then
		-- see if the minimised pool is visible
		uic_pool = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options", "recruitment_listbox", "global_min");
	end;
	
	if uic_pool and uic_pool:Visible(true) then
		pulse_uicomponent(uic_pool, value, pulse_strength or self.panel_pulse_strength);
		
		local uic_header = find_uicomponent(uic_pool, "tx_header");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		local uic_capacity = find_uicomponent(uic_pool, "capacity_listview");
		if uic_capacity then
			pulse_uicomponent(uic_capacity, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_global_recruitment_pool(false, pulse_strength, force_highlight) end);
		end;
		return true;	
	elseif not do_not_highlight_upstream then
		return self:highlight_recruitment_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_growth(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "layout", "info_panel_holder", "primary_info_panel_holder", "info_panel_background", "ProvinceInfoPopup", "frame_growth");
	
	if uic and uic:Visible(true) and is_fully_onscreen(uic) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		
		-- header
		local uic_header = find_uicomponent(uic, "header_frame");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_growth(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_grudges_bar(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "resources_bar", "grudge_bar");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or 8, true);
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_grudges_bar(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_grudges_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_grudges");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_grudges_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_help_pages_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "menu_bar", "buttongroup", "button_help_panel");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_help_pages_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
end;


function campaign_ui_manager:highlight_heroes(value, pulse_strength, force_highlight, target_faction)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	if value then
		if target_faction then
			self:highlight_all_heroes_near_camera(true, 30, function(char) return char:faction():name() == target_faction end);
		else
			self:highlight_all_heroes_near_camera(true, 30);
		end;
		table.insert(self.unhighlight_action_list, function() self:highlight_heroes(false, pulse_strength, force_highlight) end);
	else
		self:highlight_all_heroes_near_camera(false);
	end;
end;


function campaign_ui_manager:highlight_hero_deployment_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "small_bar", "button_deploy_agent");	

	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_hero_deployment_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_heroes(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_hero_recruitment_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	-- query the state of the recruit hero button to determine if the panel is visible
	local uic_recruit_hero_button = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_settlement", "button_agents");
	local uic_recruit_hero_button_horde = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_army_settled", "button_agents");
	
	local button_selected_test = function(uic)
		return uic and (uic:CurrentState() == "selected" or uic:CurrentState() == "selected_down");
	end;
	
	if button_selected_test(uic_recruit_hero_button) or button_selected_test(uic_recruit_hero_button_horde) then
		-- background panel
		local uic_character_panel = find_uicomponent(core:get_ui_root(), "character_panel");

		pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		if uic_character_panel then
			pulse_uicomponent(uic_character_panel, value, pulse_strength);
		end;
		
		-- title
		local uic_title = find_uicomponent(uic_character_panel, "title_plaque");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength, true);
		end;
		
		-- subframe
		local uic_frame = find_uicomponent(uic_character_panel, "subframe");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength);
		end;
		
		-- no candidates panel
		local uic_no_candidates_panel = find_uicomponent(uic_character_panel, "no_candidates_panel");
		if uic_no_candidates_panel then
			pulse_uicomponent(uic_no_candidates_panel, value, pulse_strength);
		end;
		
		-- province_cycle
		local uic_province_cycle = find_uicomponent(uic_character_panel, "province_cycle");
		if uic_province_cycle then
			pulse_uicomponent(uic_province_cycle, value, pulse_strength, true);
		end;
		
		-- recruit button
		local uic_recruit_button = find_uicomponent(uic_character_panel, "button_confirm");
		if uic_recruit_button then
			pulse_uicomponent(uic_recruit_button, value, pulse_strength);
		end;
		
		-- character list
		local uic_char_list = find_uicomponent(uic_character_panel, "general_selection_panel", "character_list");
		if uic_char_list then
			pulse_uicomponent(uic_char_list, value, pulse_strength, true);
		end;

		if value then
			self:highlight_hero_recruitment_panel_tab_buttons(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_hero_recruitment_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_recruit_hero_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_hero_recruitment_panel_tab_buttons(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "character_panel", "agent_parent", "button_group_agents");	

	if uic and uic:Visible(true) then
		for i = 0, uic:ChildCount() - 1 do
			local uic_child = UIComponent(uic:Find(i));
			pulse_uicomponent(uic_child, value, pulse_strength or self.button_pulse_strength - 2);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_hero_recruitment_panel_tab_buttons(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_recruit_hero_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_horde_growth(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_panel = find_uicomponent(ui_root, "horde_growth");
	
	if uic_panel and uic_panel:Visible(true) then	
		pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		pulse_uicomponent(uic_panel, value, pulse_strength);
		
		local uic_frame = find_uicomponent(uic_panel, "frame_growth");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength);
		end;
		
		local uic_header = find_uicomponent(uic_panel, "header_frame");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_horde_growth(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
end;


function campaign_ui_manager:highlight_horde_buildings(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic_tab = find_uicomponent(ui_root, "units_panel", "main_units_panel", "tabgroup", "tab_horde_buildings");
	
	if uic_tab and uic_tab:Visible(true) and uic_tab:CurrentState() == "selected" then
		local uic_settlements = find_uicomponent(ui_root, "units_panel", "main_units_panel", "horde_building_frame", "settlement_parent");
		
		pulse_uicomponent(uic_settlements, value, pulse_strength or self.button_pulse_strength, true);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_horde_buildings(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_building_panel_tab(value, pulse_strength, force_highlight);
	end;
end;


function campaign_ui_manager:highlight_legendary_knight_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_spawn_unique_agent");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_legendary_knight_button(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_list_button_events(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "bar_small_top", "tab_events");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_list_button_events(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_list_button_factions(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "bar_small_top", "tab_factions");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_list_button_factions(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_list_button_forces(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "bar_small_top", "tab_units");
			
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_list_button_forces(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_list_button_missions(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "bar_small_top", "tab_missions");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_list_button_missions(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_list_button_provinces(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "bar_small_top", "tab_regions");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_list_button_provinces(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_local_recruitment_pool(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_pool = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options", "recruitment_listbox", "local1");
	
	if uic_pool and uic_pool:Visible(true) then
		pulse_uicomponent(uic_pool, value, pulse_strength or self.panel_pulse_strength);
		
		local uic_header = find_uicomponent(uic_pool, "tx_header");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		local uic_capacity = find_uicomponent(uic_pool, "capacity_listview");
		if uic_capacity then
			pulse_uicomponent(uic_capacity, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_local_recruitment_pool(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	elseif not do_not_highlight_upstream then
		return self:highlight_recruitment_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_lords(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	self:highlight_lords_pre_battle_screen(value, pulse_strength, force_highlight);
end;


function campaign_ui_manager:highlight_lords_pre_battle_screen(value, pulse_strength, force_highlight, reinforcements_only)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local start_index = 0;
	
	if reinforcements_only then
		start_index = 1;	-- start iterating at 1, which is the second army
	end;
	
	pulse_strength = pulse_strength or self.button_pulse_strength;

	local ui_root = core:get_ui_root();
	local uic_allied_army_list = find_uicomponent(ui_root, "pre_battle_screen", "allies_combatants_panel", "army", "army_list");
	
	if uic_allied_army_list and uic_allied_army_list:Visible(true) then
		for i = start_index, uic_allied_army_list:ChildCount() - 1 do			
			local uic_army = UIComponent(uic_allied_army_list:Find(i));
			
			local uic_button = find_uicomponent(uic_army, "button_select");
			if uic_button then
				pulse_uicomponent(uic_button, value, pulse_strength);
			end;
		end;
	end;
	
	local uic_enemy_army_list = find_uicomponent(ui_root, "pre_battle_screen", "enemy_combatants_panel", "army", "army_list");
	
	if uic_enemy_army_list and uic_enemy_army_list:Visible(true) then
		for i = start_index, uic_enemy_army_list:ChildCount() - 1 do
			local uic_army = UIComponent(uic_enemy_army_list:Find(i));
			
			local uic_button = find_uicomponent(uic_army, "button_select");
			if uic_button then
				pulse_uicomponent(uic_button, value, pulse_strength);
			end;
		end;
	end;
	
	if value then
		table.insert(self.unhighlight_action_list, function() self:highlight_lords_pre_battle_screen(false, pulse_strength, force_highlight, reinforcements_only) end);
	end;
end;


function campaign_ui_manager:highlight_missions_list(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "radar_things", "missions_dropdown", "panel");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_missions_list(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_list_button_missions(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_mortuary_cult_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_button = find_uicomponent(core:get_ui_root(), "faction_buttons_docker", "button_mortuary_cult");
		
	if uic_button and uic_button:Visible(true) then
		pulse_uicomponent(uic_button, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_mortuary_cult_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_mortuary_cult_panel(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_panel = find_child_uicomponent(core:get_ui_root(), "mortuary_cult");
		
	if uic_panel and uic_panel:Visible(true) then	
		pulse_uicomponent(uic_panel, value, pulse_strength or self.panel_pulse_strength);
		
		local uic_title = find_uicomponent(uic_panel, "panel_title");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		local uic_resources_list = find_uicomponent(uic_panel, "list_resources");
		if uic_resources_list then
			pulse_uicomponent(uic_resources_list, value, pulse_strength or self.panel_pulse_strength);
			--[[
			for i = 0, uic_resources_list:ChildCount() - 1 do
				local uic_resource = UIComponent(uic_resources_list:Find(i));				
				pulse_uicomponent(uic_resource, value, pulse_strength or self.panel_pulse_strength, false, uic_resource:CurrentState());
			end;
			]]		
		end;
		
		local uic_header_list = find_uicomponent(uic_panel, "header_list");
		if uic_header_list then
			pulse_uicomponent(uic_header_list, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		local uic_crafting_list = find_uicomponent(uic_panel, "listview", "list_box");
		if uic_crafting_list then
			pulse_uicomponent(uic_crafting_list, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_mortuary_cult_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
	
										out("\tpanel is not visible, highlighting button instead")
		return self:highlight_mortuary_cult_button(value, pulse_strength, force_highlight);
	end;
	
										out("\tpanel is not visible and not highlighting upstream")
	
	return false;
end;


function campaign_ui_manager:highlight_movement_range(value, pulse_strength, force_highlight, do_not_highlight_armies)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic_character_info_panel = find_uicomponent(core:get_ui_root(), "CharacterInfoPopup");
	
	if uic_character_info_panel and uic_character_info_panel:Visible(true) then
		local panel_pulse_strength = self.panel_pulse_strength;
		
		local uic_ap_bar = find_uicomponent(uic_character_info_panel, "ap_bar");
		if uic_ap_bar then
			pulse_uicomponent(uic_ap_bar, value, pulse_strength or self.panel_pulse_strength);
		end;
			
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_movement_range(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_armies then
		self:highlight_armies(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_objectives_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_missions");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_objectives_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_objectives_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_screen = find_uicomponent(core:get_ui_root(), "objectives_screen");
	
	if uic_screen and uic_screen:Visible(true) then
		local pulse_strength_to_use = pulse_strength or self.panel_pulse_strength;
	
		pulse_uicomponent(uic_screen, value, pulse_strength_to_use);
		
		-- title
		local uic_title = find_uicomponent(uic_screen, "objectives_screen");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength_to_use, true);
		end;
		
		-- parchment
		local uic_parchment = find_uicomponent(uic_screen, "objectives_screen");
		if uic_parchment then
			pulse_uicomponent(uic_parchment, value, pulse_strength_to_use);
		end;
		
		if value then
			self:highlight_objectives_panel_chapter_missions(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_objectives_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_objectives_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_objectives_panel_chapter_missions(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	local uic = find_uicomponent(ui_root, "objectives_screen", "tab_chapters");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength, true);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_objectives_panel_chapter_missions(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_objectives_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_objectives_panel_victory_conditions(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local ui_root = core:get_ui_root();
	local uic = find_uicomponent(ui_root, "objectives_screen", "tab_victory_conditions");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength, true);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_objectives_panel_victory_conditions(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_objectives_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_offices(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = get_cm();
	local uic_screen = find_uicomponent(core:get_ui_root(), "offices");
	
	if uic_screen and uic_screen:Visible(true) then
		pulse_strength = pulse_strength or self.panel_pulse_strength - 2;
		
		-- offices panel
		local uic_offices_panel = find_uicomponent(uic_screen, "main", "offices_panel");
		if uic_offices_panel then
			pulse_uicomponent(uic_offices_panel, value, pulse_strength);
		end;
		
		-- offices header
		local uic_offices_header = find_uicomponent(uic_screen, "offices_panel", "title_holder");
		if uic_offices_header then			
			pulse_uicomponent(uic_offices_header, value, pulse_strength, true);
		end;
		
		-- backing
		local uic_panel_back = find_uicomponent(uic_screen, "panel_frame", "panel_back");
		if uic_panel_back then
			pulse_uicomponent(uic_panel_back, value, pulse_strength);
		end;
		
		-- lords section
		local uic_lords_panel = find_uicomponent(uic_screen, "lords_panel");
		if uic_lords_panel then			
			pulse_uicomponent(uic_lords_panel, value, pulse_strength);
		end;
		
		-- lords header
		local uic_lords_header = find_uicomponent(uic_screen, "lords_panel", "title_holder");
		if uic_lords_header then			
			pulse_uicomponent(uic_lords_header, value, pulse_strength, true);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_offices(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		return self:highlight_offices_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_offices_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_offices");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_offices_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_peasants(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	if value then
		table.insert(self.unhighlight_action_list, function() self:highlight_peasants(false, pulse_strength, force_highlight) end);
	end;
	return highlight_visible_component(value, true, "layout", "resources_bar", "dy_peasants");
end;


function campaign_ui_manager:highlight_per_turn_income(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	if value then
		table.insert(self.unhighlight_action_list, function() self:highlight_per_turn_income(false, pulse_strength, force_highlight) end);
	end;
	return highlight_visible_component(value, true, "layout", "resources_bar", "dy_income");
end;


function campaign_ui_manager:highlight_food(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	if value then
		table.insert(self.unhighlight_action_list, function() self:highlight_food(false, pulse_strength, force_highlight) end);
	end;
	return highlight_visible_component(value, true, "layout", "resources_bar", "dy_food");
end;


function campaign_ui_manager:highlight_influence(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	if value then
		table.insert(self.unhighlight_action_list, function() self:highlight_influence(false, pulse_strength, force_highlight) end);
	end;
	return highlight_visible_component(value, true, "layout", "resources_bar", "dy_intrigue");
end;


function campaign_ui_manager:highlight_interventions(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "toggle_interrupt_button");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_interventions(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_intrigue_at_the_court_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_intrigue");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_intrigue_at_the_court_button(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_intrigue_at_the_court_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "intrigue_panel");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_intrigue_at_the_court_panel(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	else
		self:highlight_intrigue_at_the_court_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_ports(value, target_faction, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	if value then
		if target_faction then
			self:highlight_all_settlements_near_camera(true, 30, function(settlement) return settlement:is_port() and settlement:faction():name() == target_faction end);
		else
			self:highlight_all_settlements_near_camera(true, 30, function(settlement) return settlement:is_port() end);
		end;
		table.insert(self.unhighlight_action_list, function() self:highlight_settlements(false, pulse_strength, force_highlight) end);
	else
		self:highlight_all_settlements_near_camera(false, pulse_strength, force_highlight);
	end;
end;


function campaign_ui_manager:highlight_post_battle_options(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = get_cm();
	local uic_panel = find_uicomponent(core:get_ui_root(), "post_battle_screen", "mid");
	
	pulse_strength = pulse_strength or self.button_pulse_strength;
	
	if uic_panel and uic_panel:Visible(true) then
		local uic_button_set_settlement_captured = find_uicomponent(uic_panel, "button_set_settlement_captured");
		if uic_button_set_settlement_captured then
			for i = 0, uic_button_set_settlement_captured:ChildCount() - 1 do
				local uic_child = UIComponent(uic_button_set_settlement_captured:Find(i));
				pulse_uicomponent(uic_child, value, pulse_strength, true);
			end;
		end;
			
		local uic_button_set_win = find_uicomponent(uic_panel, "button_set_win");
		if uic_button_set_win then
			for i = 0, uic_button_set_win:ChildCount() - 1 do
				local uic_child = UIComponent(uic_button_set_win:Find(i));
				pulse_uicomponent(uic_child, value, pulse_strength, true);
			end;
		end;
		
		local uic_button_dismiss = find_uicomponent(uic_panel, "battle_results", "button_dismiss_holder", "button_dismiss");
		if uic_button_dismiss then
			pulse_uicomponent(uic_button_dismiss, value, pulse_strength, true);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_post_battle_options(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	-- options on settlement captured panel
	local uic_settlement_captured_container = find_uicomponent(core:get_ui_root(), "settlement_captured", "button_parent");
	
	if uic_settlement_captured_container and uic_settlement_captured_container:Visible() then
		for i = 0, uic_settlement_captured_container:ChildCount() - 1 do
			local uic_button = find_uicomponent(UIComponent(uic_settlement_captured_container:Find(i)), "option_button");
			if uic_button then
				pulse_uicomponent(uic_button, value, pulse_strength, true);
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_post_battle_options(false, pulse_strength, force_highlight) end);
		end;
	end;
	
	return false;
end;


-- This is different from the surrounding functions, it highlights the post-battle options with a square highlight indicating that they should be clicked on
-- It also waits until the post_battle_panel is in position before activating the highlight
function campaign_ui_manager:highlight_post_battle_options_for_click(value)	
	if value then
		
		-- check that the component is on-screen and not animating		
		local uic_panel = find_uicomponent(core:get_ui_root(), "post_battle_screen", "mid");
	
		if not uic_panel or (not (uic_panel:Visible() and is_fully_onscreen(uic_panel) and uic_panel:CurrentAnimationId() == "")) then
		
			-- component has not come to rest on-screen, defer this call
			self.cm:callback(function() self:highlight_post_battle_options_for_click(value) end, 0.2, "highlight_post_battle_options_for_click");
			return;
		end;
		
		-- try and highlight the settlement captured button set
		local uic_button_set_settlement_captured = find_uicomponent(uic_panel, "button_set_settlement_captured");
		if uic_button_set_settlement_captured and uic_button_set_settlement_captured:Visible(true) then
			self:highlight_all_visible_children(uic_button_set_settlement_captured, 5);
		end;
		
		-- try and highlight the field battle victory button set
		local uic_button_set_win = find_uicomponent(uic_panel, "button_set_win");
		if uic_button_set_win and uic_button_set_win:Visible(true) then
			self:highlight_all_visible_children(uic_button_set_win, 5);
		end;
		
		-- try and highlight the dismiss button
		local uic_button_dismiss = find_uicomponent(uic_panel, "battle_results", "button_dismiss_holder", "button_dismiss");
		if uic_button_dismiss and uic_button_dismiss:Visible(true) then
			self:highlight_all_visible_children(UIComponent(uic_button_dismiss:Parent()), 5);
		end;		
	else
		self.cm:remove_callback("highlight_post_battle_options_for_click");
		uim:unhighlight_all_visible_children();
	end;
end;


function campaign_ui_manager:highlight_post_battle_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	
	local uic_panel = find_uicomponent(ui_root, "post_battle_screen", "mid", "battle_results");
	
	if uic_panel and uic_panel:Visible(true) then
		pulse_uicomponent(uic_panel, value, pulse_strength or self.panel_pulse_strength);
		
		-- title
		local uic_title = find_uicomponent(ui_root, "post_battle_screen", "mid", "battle_results", "title_plaque");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength or self.panel_pulse_strength, true);
		end;
				
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_post_battle_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_post_battle_panel_unit_cards(value, pulse_strength, force_highlight, highlight_unit_types, highlight_experience, highlight_banners)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	self:highlight_pre_battle_panel_unit_cards(value, pulse_strength, force_highlight, true, highlight_unit_types, highlight_experience, highlight_banners);
end;


function campaign_ui_manager:highlight_pre_battle_options(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic_deployment = find_uicomponent(core:get_ui_root(), "pre_battle_screen", "battle_deployment", "regular_deployment");
	
	if uic_deployment and uic_deployment:Visible(true) then
		pulse_strength = pulse_strength or self.button_pulse_strength;
	
		-- button_set_attack
		local uic_button_set_attack = find_uicomponent(uic_deployment, "button_set_attack");
		if uic_button_set_attack then
			for i = 0, uic_button_set_attack:ChildCount() - 1 do
				local uic_child = UIComponent(uic_button_set_attack:Find(i));
				pulse_uicomponent(uic_child, value, pulse_strength, true);
			end;
		end;
		
		-- button_set_siege
		local uic_button_set_siege = find_uicomponent(uic_deployment, "button_set_siege");
		if uic_button_set_siege then
			for i = 0, uic_button_set_siege:ChildCount() - 1 do
				local uic_child = UIComponent(uic_button_set_siege:Find(i));
				pulse_uicomponent(uic_child, value, pulse_strength, true);
			end;
		end;
		
		-- button_set_mp
		local uic_button_set_mp = find_uicomponent(uic_deployment, "button_set_mp");
		if uic_button_set_mp then
			for i = 0, uic_button_set_mp:ChildCount() - 1 do
				local uic_child = UIComponent(uic_button_set_mp:Find(i));
				pulse_uicomponent(uic_child, value, pulse_strength, true);
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_pre_battle_options(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_pre_battle_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	
	local uic_battle_deployment = find_uicomponent(ui_root, "pre_battle_screen", "mid", "battle_deployment");
	
	if uic_battle_deployment and uic_battle_deployment:Visible(true) then
		local uic_panel = find_uicomponent(uic_battle_deployment, "regular_deployment", "battle_information_panel");
		if uic_panel and uic_panel:Visible() then
			pulse_uicomponent(uic_panel, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		local uic_list = find_uicomponent(uic_battle_deployment, "list");
		if uic_list and uic_list:Visible() then
			pulse_uicomponent(uic_list, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		local uic_header = find_uicomponent(uic_battle_deployment, "common_ui_parent");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		local uic_title = find_uicomponent(uic_battle_deployment, "regular_deployment", "common_ui_parent", "panel_title");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		local uic_info_button = find_uicomponent(uic_battle_deployment, "regular_deployment", "battle_information_panel", "button_info");
		if uic_info_button and uic_info_button:Visible() then
			pulse_uicomponent(uic_info_button, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		if value then
			self:highlight_balance_of_power_bar(value, pulse_strength, force_highlight);
			self:highlight_winds_of_magic(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_pre_battle_panel(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	else
		self:highlight_siege_panel(value, pulse_strength, force_highlight);		
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_pre_battle_panel_unit_cards(value, pulse_strength, force_highlight, is_post_battle_panel, highlight_unit_types, highlight_experience, highlight_banner)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	
	local panel_name = "pre_battle_screen";
	
	if is_post_battle_panel then
		panel_name = "post_battle_screen";
	end;
	
	local uic_allied_unit_list = find_uicomponent(ui_root, panel_name, "allies_combatants_panel", "army", "units_and_banners_parent", "units_window");
	
	if uic_allied_unit_list and uic_allied_unit_list:Visible(true) then
		local button_pulse_strength = pulse_strength or self.button_pulse_strength;
		local panel_pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		for i = 0, uic_allied_unit_list:ChildCount() - 1 do			
			local uic_card = UIComponent(uic_allied_unit_list:Find(i));
			
			-- highlight the type indicator if we're supposed to
			if highlight_unit_types then
				-- unit type
				local uic_type = find_uicomponent(uic_card, "unit_cat_frame");
				if uic_type then
					pulse_uicomponent(uic_type, value, button_pulse_strength);
				end;
			elseif highlight_experience then
				-- experience
				local uic_experience = find_uicomponent(uic_card, "experience");
				if uic_experience then
					pulse_uicomponent(uic_experience, value, button_pulse_strength);
				end;
			elseif highlight_banner then
				-- banner
				local uic_banner = find_uicomponent(uic_card, "ancillary_banner_item");
				if uic_banner then
					pulse_uicomponent(uic_banner, value, button_pulse_strength);
				end;
			else
				-- whole card
				pulse_uicomponent(uic_card, value, panel_pulse_strength);
			end;
		end;
	end;
	
	local uic_enemy_unit_list = find_uicomponent(ui_root, panel_name, "enemy_combatants_panel", "army", "units_and_banners_parent", "units_window");
	
	if uic_enemy_unit_list and uic_enemy_unit_list:Visible(true) then
		local button_pulse_strength = pulse_strength or self.button_pulse_strength;
		local panel_pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		for i = 0, uic_enemy_unit_list:ChildCount() - 1 do			
			local uic_card = UIComponent(uic_enemy_unit_list:Find(i));
			
			-- highlight the type indicator if we're supposed to
			if highlight_unit_types then
				-- unit type
				local uic_type = find_uicomponent(uic_card, "unit_cat_frame");
				if uic_type then
					pulse_uicomponent(uic_type, value, button_pulse_strength);
				end;
			elseif highlight_experience then
				-- experience
				local uic_experience = find_uicomponent(uic_card, "experience");
				if uic_experience then
					pulse_uicomponent(uic_experience, value, button_pulse_strength);
				end;
			elseif highlight_banner then
				-- banner
				local uic_banner = find_uicomponent(uic_card, "ancillary_banner_item");
				if uic_banner then
					pulse_uicomponent(uic_banner, value, button_pulse_strength);
				end;
			else
				-- whole card
				pulse_uicomponent(uic_card, value, panel_pulse_strength);
			end;
		end;
	end;
	
	if value then
		table.insert(self.unhighlight_action_list, function() self:highlight_pre_battle_panel_unit_cards(false, pulse_strength, force_highlight, is_post_battle_panel, highlight_unit_types, highlight_experience, highlight_banner) end);
	end;
end;


function campaign_ui_manager:highlight_province_info_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "layout", "info_panel_holder", "primary_info_panel_holder", "info_panel_background", "ProvinceInfoPopup", "panel");
	
	if uic and uic:Visible(true) then
		pulse_strength = pulse_strength or self.panel_pulse_strength;
		
		pulse_uicomponent(uic, value, pulse_strength);
		
		-- province effects body
		local uic_effects = find_uicomponent(uic, "effects");
		if uic_effects then
			pulse_uicomponent(uic_effects, value, pulse_strength);
		end;
		
		-- province effects header
		local uic_province_effects_header = find_uicomponent(uic, "effects", "header_frame");
		if uic_province_effects_header then
			pulse_uicomponent(uic_province_effects_header, value, pulse_strength);
		end;
		
		if value then
			self:highlight_growth(value, pulse_strength, force_highlight);
			self:highlight_public_order(value, pulse_strength, force_highlight);
			self:highlight_corruption(value, pulse_strength, force_highlight);
			
			table.insert(self.unhighlight_action_list, function() self:highlight_province_info_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_provinces_list(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "radar_things", "regions_dropdown", "panel");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_provinces_list(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_list_button_provinces(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_province_overview_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic_panel = find_uicomponent(core:get_ui_root(), "settlement_panel");
	
	pulse_strength = pulse_strength or self.panel_pulse_strength;
	
	if uic_panel and uic_panel:Visible(true) then
		pulse_uicomponent(uic_panel, value, pulse_strength);
		
		pulse_uicomponent(find_uicomponent(uic_panel, "header", "button_focus"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_panel, "header", "button_cycle_left"), value, pulse_strength);
		pulse_uicomponent(find_uicomponent(uic_panel, "header", "button_cycle_right"), value, pulse_strength);
		
		local uic_settlement_list = find_uicomponent(uic_panel, "main_settlement_panel");
		
		for i = 0, uic_settlement_list:ChildCount() - 1 do
			local uic_settlement = UIComponent(uic_settlement_list:Find(i));
			
			local uic_zoom = find_uicomponent(uic_settlement, "button_zoom");
			
			if uic_zoom then
				pulse_uicomponent(uic_zoom, value, pulse_strength);
			end;
		end;

		if value then
			self:highlight_building_browser_button(value, pulse_strength, force_highlight);
			self:highlight_buildings(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_province_overview_panel(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	else	
		self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_province_overview_panel_settlement_headers(value, pulse_strength, force_highlight, first_settlement_only, all_but_first_settlement)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic_settlement_list = find_uicomponent(core:get_ui_root(), "settlement_panel", "main_settlement_panel");
	
	if uic_settlement_list and uic_settlement_list:Visible(true) then	
		local loop_start = 0;
		local loop_end = uic_settlement_list:ChildCount() - 1;
		
		if first_settlement_only then
			loop_end = 0;
		end;
		
		if all_but_first_settlement then
			loop_start = 1;
		end;
		
		for i = loop_start, loop_end do
			local uic_settlement = UIComponent(uic_settlement_list:Find(i));
			
			local uic_zoom = find_uicomponent(uic_settlement, "button_zoom");
			
			if uic_zoom then
				pulse_uicomponent(uic_zoom, value, pulse_strength);
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_province_overview_panel_settlement_headers(false, pulse_strength, force_highlight, first_settlement_only, all_but_first_settlement) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_public_order(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = get_cm();
	local uic = find_uicomponent(core:get_ui_root(), "layout", "info_panel_holder", "primary_info_panel_holder", "info_panel_background", "ProvinceInfoPopup", "frame_PO_income");
	
	if uic and uic:Visible(true) and is_fully_onscreen(uic) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		
		-- header
		local uic_header = find_uicomponent(uic, "header_taxes");
		if not uic_header then
			-- slaves header instead
			uic_header = find_uicomponent(uic, "header_slaves");
		end;
		
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength or self.panel_pulse_strength);
		end;
		
		if value then
			self:highlight_slaves_buttons(true, nil, force_highlight, true)
			table.insert(self.unhighlight_action_list, function() self:highlight_public_order(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_settlements(value, cm:get_local_faction());
		self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
		self:highlight_settlements(value, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_raise_dead_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic_panel = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options");
	
	if uic_panel and uic_panel:Visible(true) then
		-- if the dy_battle_sites component is not visible then this isn't the raise dead panel, so don't continue
		local uic_mercenary_display = find_uicomponent(uic_panel, "dy_battle_sites");
		if not uic_mercenary_display:Visible(true) then
			return self:highlight_raise_dead_button(value, pulse_strength, force_highlight);
		end;
		
		pulse_strength = pulse_strength or self.panel_pulse_strength;
		
		pulse_uicomponent(uic_mercenary_display, value, pulse_strength);		
		pulse_uicomponent(uic_panel, value, pulse_strength);
		
		-- frame
		local uic_frame = find_uicomponent(uic_panel, "mercenary_display", "frame");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength);
		end;
		
		-- button
		local uic_button = find_uicomponent(uic_panel, "button_raise_dead");
		if uic_button then
			pulse_uicomponent(uic_button, value, pulse_strength);
		end;
		
		if value then
			self:highlight_raise_dead_panel_unit_cards(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_raise_dead_panel(false) end);
		end;
		return true;
	else
		return self:highlight_raise_dead_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_raise_dead_panel_unit_cards(value, pulse_strength, force_highlight, highlight_unit_types, highlight_experience)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic_raise_dead = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options", "mercenary_display");
		
	if uic_raise_dead and uic_raise_dead:Visible(true) then	
		local uic_unit_list = find_uicomponent(uic_raise_dead, "listview", "list_clip", "list_box");
			
		if uic_unit_list then			
			for j = 0, uic_unit_list:ChildCount() - 1 do
				local uic_card = find_uicomponent(UIComponent(uic_unit_list:Find(j)), "unit_icon");
					
				-- highlight the type indicator if we're supposed to
				if highlight_unit_types then
					-- unit type
					local uic_type = find_uicomponent(uic_card, "unit_cat_frame");
					if uic_type then
						pulse_uicomponent(uic_type, value, pulse_strength or self.button_pulse_strength);
					end;
				elseif highlight_experience then
					-- experience
					local uic_experience = find_uicomponent(uic_child, "experience");
					if uic_experience then
						pulse_uicomponent(uic_experience, value, pulse_strength or self.button_pulse_strength);
					end;
				else
					-- whole card
					pulse_uicomponent(uic_card, value, pulse_strength or self.panel_pulse_strength);
				end;
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_raise_dead_panel_unit_cards(false, pulse_strength, force_highlight, highlight_unit_types, highlight_experience) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_raise_forces_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_settlement", "button_create_army");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_raise_forces_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		-- hordes
		uic = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_army_settled", "button_create_army");
		
		if uic and uic:Visible(true) then
			pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
			if value then
				table.insert(self.unhighlight_action_list, function() self:highlight_raise_forces_button(false, pulse_strength, force_highlight) end);
			end;
			return true;
		else
			self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
			self:highlight_building_panel_tab(value, pulse_strength, force_highlight, cm:get_local_faction(true));
		end;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_raise_forces_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	-- query the state of the raise forces button to determine if the panel is visible
	local uic_raise_forces_button = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_settlement", "button_create_army");
	local uic_raise_forces_button_horde = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_army_settled", "button_create_army");
	
	local button_selected_test = function(uic)
		return uic and (uic:CurrentState() == "selected" or uic:CurrentState() == "selected_down");
	end;
	
	if button_selected_test(uic_raise_forces_button) or button_selected_test(uic_raise_forces_button_horde) then
		-- background panel
		local uic_character_panel = find_uicomponent(core:get_ui_root(), "character_panel");
		pulse_strength = pulse_strength or self.panel_pulse_strength;
	
		if uic_character_panel then
			pulse_uicomponent(uic_character_panel, value, pulse_strength);
		end;
		
		-- title
		local uic_title = find_uicomponent(uic_character_panel, "title_plaque");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength, true);
		end;
		
		-- subframe
		local uic_frame = find_uicomponent(uic_character_panel, "subframe");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength);
		end;
		
		-- no candidates panel
		local uic_no_candidates_panel = find_uicomponent(uic_character_panel, "no_candidates_panel");
		if uic_no_candidates_panel then
			pulse_uicomponent(uic_no_candidates_panel, value, pulse_strength);
		end;
		
		-- province_cycle
		local uic_province_cycle = find_uicomponent(uic_character_panel, "province_cycle");
		if uic_province_cycle then
			pulse_uicomponent(uic_province_cycle, value, pulse_strength, true);
		end;
		
		-- recruit button
		local uic_recruit_button = find_uicomponent(uic_character_panel, "button_raise");
		if uic_recruit_button then
			pulse_uicomponent(uic_recruit_button, value, pulse_strength);
		end;
		
		-- character list
		local uic_char_list = find_uicomponent(uic_character_panel, "general_selection_panel", "character_list");
		if uic_char_list then
			pulse_uicomponent(uic_char_list, value, pulse_strength, true);
		end;

		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_raise_forces_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_raise_forces_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_recruit_hero_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_settlement", "button_agents");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_recruit_hero_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		-- horde
		uic = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_army_settled", "button_agents");
		if uic and uic:Visible(true) then
			pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
			if value then
				table.insert(self.unhighlight_action_list, function() self:highlight_recruit_hero_button(false, pulse_strength, force_highlight) end);
			end;
			return true;
		else
			self:highlight_settlements(value, pulse_strength, force_highlight, cm:get_local_faction(true));
			self:highlight_building_panel_tab(value, pulse_strength, force_highlight, cm:get_local_faction(true));
		end;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_recruitment_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic = find_uicomponent(core:get_ui_root(), "layout", "hud_center", "button_group_army", "button_recruitment");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_recruitment_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		return self:highlight_armies(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_recruitment_capacity(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;

	local cm = self.cm;
	local uic_panel = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options");
	
	if uic_panel and uic_panel:Visible(true) then		
		local uic_recruitment_lists = find_uicomponent(uic_panel, "recruitment_listbox");
		
		for i = 0, uic_recruitment_lists:ChildCount() - 1 do
			local uic_capacity = find_uicomponent(UIComponent(uic_recruitment_lists:Find(i)), "capacity_listview");
			
			if uic_capacity and uic_capacity:Visible(true) then
				pulse_uicomponent(uic_capacity, value, pulse_strength or self.panel_pulse_strength, true);
			end;
		end;
				
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_recruitment_capacity(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		return self:highlight_recruitment_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_recruitment_panel_unit_cards(value, pulse_strength, force_highlight, highlight_unit_types, highlight_experience)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic_recruitment_lists = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options", "recruitment_listbox");
		
	if uic_recruitment_lists and uic_recruitment_lists:Visible(true) then	
		for i = 0, uic_recruitment_lists:ChildCount() - 1 do
			local uic_recruitment_list = UIComponent(uic_recruitment_lists:Find(i));
			
			local uic_unit_list = find_uicomponent(uic_recruitment_list, "listview", "list_clip", "list_box");
			
			if uic_unit_list then			
				for j = 0, uic_unit_list:ChildCount() - 1 do
					local uic_card = find_uicomponent(UIComponent(uic_unit_list:Find(j)), "unit_icon");
					
					-- highlight the type indicator if we're supposed to
					if highlight_unit_types then
						-- unit type
						local uic_type = find_uicomponent(uic_card, "unit_cat_frame");
						if uic_type then
							pulse_uicomponent(uic_type, value, pulse_strength or self.button_pulse_strength);
						end;
					elseif highlight_experience then
						-- experience
						local uic_experience = find_uicomponent(uic_child, "experience");
						if uic_experience then
							pulse_uicomponent(uic_experience, value, pulse_strength or self.button_pulse_strength);
						end;
					else
						-- whole card
						pulse_uicomponent(uic_card, value, pulse_strength or self.panel_pulse_strength);
					end;
				end;
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_recruitment_panel_unit_cards(false, pulse_strength, force_highlight, highlight_unit_types, highlight_experience) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_reinforcements(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	self:highlight_lords_pre_battle_screen(value, pulse_strength, force_highlight, true);
end;


function campaign_ui_manager:highlight_rites_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_rituals");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_rites_button(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_rites_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "rituals_panel");
	
	if uic and uic:Visible(true) then
		local pulse_strength_to_use = pulse_strength or self.panel_pulse_strength;
		
		-- panel frame
		local uic_frame = find_uicomponent(uic, "panel_frame");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength_to_use);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_rites_panel(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	else
		self:highlight_rites_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_ritual_buttons(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ritual_bar = find_uicomponent(core:get_ui_root(), "vortex_ritual_bar");
	
	if ritual_bar and ritual_bar:Visible(true) then
		for i = 0, ritual_bar:ChildCount() - 1 do
			local ritual_bar_child = UIComponent(ritual_bar:Find(i));
			
			for j = 0, ritual_bar_child:ChildCount() - 1 do
				local ritual_button = find_uicomponent(ritual_bar_child, "ritual_rune");
				
				for k = 0, ritual_button:ChildCount() - 1 do
					pulse_uicomponent(UIComponent(ritual_button:Find(k)), value, pulse_strength or self.button_pulse_strength);
				end;
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_ritual_buttons(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_ritual_rival_icons(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ritual_holder = find_uicomponent(core:get_ui_root(), "vortex_ritual_holder", "bar_parent");
	
	if ritual_holder and ritual_holder:Visible(true) then
		for i = 0, ritual_holder:ChildCount() - 1 do
			pulse_uicomponent(find_uicomponent(UIComponent(ritual_holder:Find(i)), "icon"), value, pulse_strength or self.button_pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_ritual_rival_icons(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_rituals_bar(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ritual_holder = find_uicomponent(core:get_ui_root(), "vortex_ritual_holder", "bar_parent");
	
	if ritual_holder and ritual_holder:Visible(true) then
		pulse_uicomponent(ritual_holder, value, pulse_strength or self.button_pulse_strength);
		
		-- fill
		local uic_fill = find_uicomponent(ritual_holder, "vortex_ritual_bar", "bar_segment_template", "fill");
		
		if uic_fill and uic_fill:Visible(true) then
			pulse_uicomponent(uic_fill, value, pulse_strength or self.button_pulse_strength);
		end;		
		
		self:highlight_ritual_buttons(value, pulse_strength, force_highlight);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_rituals_bar(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_settlements(value, pulse_strength, force_highlight, target_faction)
	
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	if value then
		if target_faction then
			self:highlight_all_settlements_near_camera(true, 30, function(settlement) return settlement:faction():name() == target_faction end);
		else
			self:highlight_all_settlements_near_camera(true, 30);
		end;
		table.insert(self.unhighlight_action_list, function() self:highlight_settlements(false, pulse_strength, force_highlight) end);
	else
		self:highlight_all_settlements_near_camera(false);
	end;
end;


function campaign_ui_manager:highlight_siege_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	local uic_panel = find_uicomponent(ui_root, "pre_battle_screen", "battle_deployment", "regular_deployment", "siege_information_panel");
	
	if uic_panel and uic_panel:Visible(true) then
		pulse_uicomponent(uic_panel, value, pulse_strength or self.panel_pulse_strength);
		
		-- title
		local uic_title = find_uicomponent(ui_root, "pre_battle_screen", "mid", "battle_deployment", "regular_deployment", "common_ui_parent", "panel_title");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength or self.panel_pulse_strength, true);
		end;
		
		if value then
			self:highlight_balance_of_power_bar(value, pulse_strength, force_highlight);
			self:highlight_siege_weapons(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_pre_battle_panel(false, pulse_strength, force_highlight) end);
		end;
		
		return true;		
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_siege_weapons(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	local uic_panel = find_uicomponent(ui_root, "pre_battle_screen", "battle_deployment", "regular_deployment", "siege_information_panel", "attacker_recruitment_options");--, "equipment_frame", "construction_options");
	
	if uic_panel and uic_panel:Visible(true) then
		pulse_uicomponent(uic_panel, value, pulse_strength or self.panel_pulse_strength, true);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_siege_weapons(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_slaves_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_slaves");
	
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_slaves_button(false, pulse_strength, force_highlight) end);
		end;
		
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_stances(value, pulse_strength, force_highlight, do_not_highlight_armies)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic_character_info_panel = find_uicomponent(core:get_ui_root(), "CharacterInfoPopup");
	
	if uic_character_info_panel and uic_character_info_panel:Visible(true) then
		local button_stacks = {"land_stance_button_stack", "naval_stance_button_stack"};
		
		for i = 1, #button_stacks do
			local current_button_stack = button_stacks[i];
			
			local uic_button_stack = find_uicomponent(core:get_ui_root(), current_button_stack);
			if uic_button_stack then
				pulse_uicomponent(uic_button_stack, value, pulse_strength or self.button_pulse_strength, true);
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_stances(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_armies then
		self:highlight_armies(value, pulse_strength, force_highlight, cm:get_local_faction(true));
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_strategic_map_layer_buttons(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_toggles = find_uicomponent(core:get_ui_root(), "campaign_space_bar_options");	

	if uic_toggles and uic_toggles:Visible(true) then
		pulse_uicomponent(uic_toggles, value, pulse_strength or self.button_pulse_strength, true);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_strategic_map_layer_buttons(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_strat_map_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_strat_map_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "bar_small_top", "button_tactical_map");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_strat_map_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_tax(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	return self:highlight_public_order(value, pulse_strength, force_highlight);
end;


function campaign_ui_manager:highlight_technologies(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_panel = find_uicomponent(core:get_ui_root(), "technology_panel");
	pulse_strength = pulse_strength or self.panel_pulse_strength;
		
	if uic_panel and uic_panel:Visible(true) then
		
		local uic_list = find_uicomponent(uic_panel, "listview", "list_clip", "list_box");
		if uic_list then			
			for i = 0, uic_list:ChildCount() - 1 do
				local uic_slot_parent = find_uicomponent(UIComponent(uic_list:Find(i)), "slot_parent");
				
				if uic_slot_parent then
					for j = 0, uic_slot_parent:ChildCount() - 1 do
						pulse_uicomponent(UIComponent(uic_slot_parent:Find(j)), value, pulse_strength);
					end;
				end;
			end;
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_technologies(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_technology_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_technology_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "layout", "faction_buttons_docker", "button_technology");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_technology_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_technology_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_panel = find_uicomponent(core:get_ui_root(), "technology_panel");
		
	if uic_panel and uic_panel:Visible(true) then
		local pulse_strength_to_use = pulse_strength or self.panel_pulse_strength;
	
		-- panel back
		local uic_frame = find_uicomponent(uic_panel, "panel_back");
		if uic_frame then
			pulse_uicomponent(uic_frame, value, pulse_strength_to_use);
		end;
		
		-- parchment
		local uic_parchment = find_uicomponent(uic_panel, "parchment");
		if uic_parchment then
			pulse_uicomponent(uic_parchment, value, pulse_strength_to_use);
		end;
		
		-- header
		local uic_header = find_uicomponent(uic_panel, "header_frame");
		if uic_header then
			pulse_uicomponent(uic_header, value, pulse_strength_to_use, true);
		end;
		
		-- research rate
		local uic_research_rate = find_uicomponent(uic_panel, "label_research_rate");
		if uic_research_rate then
			pulse_uicomponent(uic_research_rate, value, pulse_strength_to_use, true);
		end;
		
		-- button
		local uic_button = find_uicomponent(uic_panel, "button_ok");
		if uic_button then
			pulse_uicomponent(uic_button, value, pulse_strength_to_use);
		end;
		
		if value then
			self:highlight_technologies(value, pulse_strength, force_highlight, true);
			table.insert(self.unhighlight_action_list, function() self:highlight_technology_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_technology_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_treasury(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	if value then
		table.insert(self.unhighlight_action_list, function() self:highlight_treasury(false, pulse_strength, force_highlight) end);
	end;
	return highlight_visible_component(value, true, "layout", "resources_bar", "dy_treasury");
end;


function campaign_ui_manager:highlight_treasury_button(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "resources_bar", "button_finance");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.button_pulse_strength);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_treasury_button(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_treasury_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "finance_screen");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength);
		
		local uic_title = find_uicomponent(uic, "panel_title");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength or self.panel_pulse_strength);
		end;
				
		if value then
			self:highlight_treasury_panel_details_tab(value, pulse_strength, force_highlight, true);
			self:highlight_treasury_panel_summary_tab(value, pulse_strength, force_highlight, true);
			self:highlight_treasury_panel_trade_tab(value, pulse_strength, force_highlight, true);
			table.insert(self.unhighlight_action_list, function() self:highlight_treasury_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_treasury_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_treasury_panel_details_tab(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "finance_screen");
		
	if uic and uic:Visible(true) then
		local uic_taxes = find_uicomponent(uic, "tab_summary");
		if uic_taxes then
			pulse_uicomponent(uic_taxes, value, pulse_strength or self.panel_pulse_strength);
		end;
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_treasury_panel_details_tab(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_treasury_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_treasury_panel_summary_tab(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "finance_screen");
		
	if uic and uic:Visible(true) then
		local uic_trade = find_uicomponent(uic, "tab_taxes");
		if uic_trade then
			pulse_uicomponent(uic_trade, value, pulse_strength or self.panel_pulse_strength);
		end;
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_treasury_panel_summary_tab(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_treasury_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_treasury_panel_trade_tab(value, pulse_strength, force_highlight, do_not_highlight_upstream)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "finance_screen");
		
	if uic and uic:Visible(true) then
		local uic_trade = find_uicomponent(uic, "tab_trade");
		if uic_trade then
			pulse_uicomponent(uic_trade, value, pulse_strength or self.panel_pulse_strength);
		end;
	
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_treasury_panel_trade_tab(false, pulse_strength, force_highlight) end);
		end;
		return true;
	elseif not do_not_highlight_upstream then
		self:highlight_treasury_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_unit_cards(value, pulse_strength, force_highlight, highlight_type, highlight_experience)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	self:highlight_pre_battle_panel_unit_cards(value, pulse_strength, force_highlight, false, highlight_type, highlight_experience);
	self:highlight_post_battle_panel_unit_cards(value, pulse_strength, force_highlight, highlight_type, highlight_experience);
	self:highlight_army_panel_unit_cards(value, pulse_strength, force_highlight, false, highlight_type, highlight_experience);
	self:highlight_recruitment_panel_unit_cards(value, pulse_strength, force_highlight, highlight_type, highlight_experience);
	self:highlight_raise_dead_panel_unit_cards(value, pulse_strength, force_highlight, highlight_type, highlight_experience);
end;


function campaign_ui_manager:highlight_unit_exchange_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic = find_uicomponent(core:get_ui_root(), "unit_exchange");
		
	if uic and uic:Visible(true) then
		pulse_uicomponent(uic, value, pulse_strength or self.panel_pulse_strength, true);
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_unit_exchange_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_unit_experience(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	self:highlight_unit_cards(value, pulse_strength, force_highlight, false, true);
end;


function campaign_ui_manager:highlight_unit_information_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local uic_panel = find_uicomponent(core:get_ui_root(), "info_panel_holder", "UnitInfoPopup");
	
	if uic_panel and uic_panel:Visible(true) then
		pulse_strength = pulse_strength or self.panel_pulse_strength;
		
		-- parchment
		local uic_parchment = find_uicomponent(uic_panel, "parchment");
		if uic_parchment then
			pulse_uicomponent(uic_parchment, value, pulse_strength);
		end;
		
		-- top section
		local uic_top = find_uicomponent(uic_panel, "top_section", "frame");
		if uic_top then
			pulse_uicomponent(uic_top, value, pulse_strength);
		end;
		
		-- mid
		local uic_mid = find_uicomponent(uic_panel, "details", "top_bar");
		if uic_mid then
			pulse_uicomponent(uic_mid, value, pulse_strength);
		end;
		
		-- bottom
		local uic_bottom = find_uicomponent(uic_panel, "details", "health_and_stats_parent");
		if uic_bottom then
			pulse_uicomponent(uic_bottom, value, pulse_strength);
		end;
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_unit_information_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		self:highlight_unit_cards(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_unit_recruitment_panel(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local cm = self.cm;
	local uic_panel = find_uicomponent(core:get_ui_root(), "main_units_panel", "recruitment_options");
	
	if uic_panel and uic_panel:Visible(true) then
		-- if the mercenary_display component is visible then this is the raise dead panel, so don't continue
		local uic_mercenary_display = find_uicomponent(uic_panel, "mercenary_display");
		if uic_mercenary_display:Visible(true) then
			return self:highlight_recruitment_button(value, pulse_strength, force_highlight);
		end;
		
		local pulse_strength_to_use = pulse_strength or self.panel_pulse_strength;
		
		pulse_uicomponent(uic_panel, value, pulse_strength_to_use);
		
		-- title
		local uic_title = find_uicomponent(uic_panel, "title_plaque");
		if uic_title then
			pulse_uicomponent(uic_title, value, pulse_strength_to_use);
		end;
		
		local uic_capacity = find_uicomponent(uic_panel, "capacity_listview");
		if uic_capacity then
			pulse_uicomponent(uic_capacity, value, pulse_strength_to_use);
		end;
		
		if value then
			self:highlight_local_recruitment_pool(value, pulse_strength, force_highlight, true);
			self:highlight_global_recruitment_pool(value, pulse_strength, force_highlight, true);
			self:highlight_recruitment_panel_unit_cards(value, pulse_strength, force_highlight);
			table.insert(self.unhighlight_action_list, function() self:highlight_unit_recruitment_panel(false, pulse_strength, force_highlight) end);
		end;
		return true;
	else
		return self:highlight_recruitment_button(value, pulse_strength, force_highlight);
	end;
	
	return false;
end;


function campaign_ui_manager:highlight_unit_types(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	self:highlight_unit_cards(value, pulse_strength, force_highlight, true);
end;


function campaign_ui_manager:highlight_winds_of_magic(value, pulse_strength, force_highlight)
	if not self.help_page_link_highlighting_permitted and not force_highlight then
		return;
	end;
	
	local ui_root = core:get_ui_root();
	
	-- army panel
	local uic_army_panel_wom = find_uicomponent(ui_root, "units_panel", "main_units_panel", "winds_of_magic");
	if uic_army_panel_wom and uic_army_panel_wom:Visible(true) then
		pulse_uicomponent(uic_army_panel_wom, value, pulse_strength or self.panel_pulse_strength, true);
		
		if value then
			table.insert(self.unhighlight_action_list, function() self:highlight_winds_of_magic(false, pulse_strength, force_highlight) end);
		end;
	else
		-- pre_battle_panel
		local uic_pre_battle_panel_wom = find_uicomponent(ui_root, "pre_battle_screen", "allies_combatants_panel", "winds_of_magic");
		if uic_pre_battle_panel_wom and uic_pre_battle_panel_wom:Visible(true) then
			pulse_uicomponent(uic_pre_battle_panel_wom, value, pulse_strength or self.panel_pulse_strength, true);
			
			if value then
				table.insert(self.unhighlight_action_list, function() self:highlight_winds_of_magic(false) end);
			end;
		end;
	end;
end;




