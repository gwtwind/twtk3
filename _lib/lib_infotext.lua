





----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	INFOTEXT MANAGER
--
--	Provides a wrapper for setting and managing infotext. This is the bullet-pointed text
--	that can appear below the advisor panel.
--
--- @loaded_in_battle
--- @loaded_in_campaign
--- @class infotext_manager Infotext Manager
--- @desc The infotext manager provides an interface for setting and managing infotext. This is the text panel that appears below the advisor and hosts text breaking down the advisor string into game terms.
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

infotext_manager = {
	uic_infotext = false,
	initial_delay = 1,		-- must be > 0.1
	line_delay = 0.75,
	infotext_currently_being_added = false,
	infotext_queue = {},
	parser = nil,
	time_speed = 1,
	state_overrides = {}
};


----------------------------------------------------------------------------
---	@section Creation
----------------------------------------------------------------------------

__infotext_manager = nil;

--- @function new
--- @desc Creates an infotext manager. It should never be necessary for client scripts to call this directly, for an infotext manager is automatically set up whenever a @battle_manager or @campaign_manager is created.
--- @return infotext_manager
function infotext_manager:new()
	if __infotext_manager then
		return __infotext_manager;
	end;

	local i = {};

	setmetatable(i, self);
	self.__index = self;
	self.__tostring = function() return TYPE_INFOTEXT_MANAGER end;
	
	i.infotext_queue = {};
	i.state_overrides = {};
	i.parser = link_parser:new();
	
	core:add_listener(
		"infotext_manager_history_button_listeners",
		"AdviceNavigated",
		true,
		function() i:parse_history_page_for_tooltips() end,
		true	
	);	
	
	__infotext_manager = i;

	return i;
end;


--- @end_class
--- @section Infotext Manager

--- @function get_infotext_manager
--- @desc Gets an infotext manager, or creates one if one doesn't already exist.
--- @return infotext_manager
function get_infotext_manager()
	return infotext_manager:new();
end;

--- @class infotext_manager Infotext Manager


----------------------------------------------------------------------------
--	UI component creation. For internal use.
----------------------------------------------------------------------------

function infotext_manager:create_infotext_panel()
	if self.uic_infotext then
		return;
	end;
	
	-- listen for the UI being destroyed, and blank the existing uic_infotext handle
	core:add_listener(
		"infotext_manager_create_infotext_panel",
		"UIDestroyed",
		true,
		function() self.uic_infotext = false end,
		false
	);

	self.uic_infotext = find_uicomponent(core:get_ui_root(), "advice_interface");
end;


----------------------------------------------------------------------------
--	@section UI Component
----------------------------------------------------------------------------

--- @function get_uicomponent
--- @desc Gets a uicomponent handle to the infotext panel
--- @return uicomponent
function infotext_manager:get_uicomponent()
	self:create_infotext_panel();
	
	return self.uic_infotext;
end;




----------------------------------------------------------------------------
--	@section Modified Time
----------------------------------------------------------------------------

--- @function set_time_speed
--- @desc Sets the speed of time. To be called when modifying the speed of time in battle.
--- @p number time speed, Time speed, accepts the same values as <code>modify_battle_speed</code> or @battle_manager:slow_game_over_time (1 = normal speed, 0.5 = half speed etc)
function infotext_manager:set_time_speed(value)
	if not is_number(value) or value < 0 then
		script_error("ERROR: set_time_speed() called but supplied modifier [" .. tostring(value) .. "] is not a positive number");
		return false;
	end;
	
	self.time_speed = value;
end;







----------------------------------------------------------------------------
--- @section State Overrides
---	@desc State overrides allow calling scripts to map a given line of infotext to being shown in a different component state. This is to allow certain lines of infotext to be shown in a different configuration, or with images, such as an image of WASD keys along with text instructing the player how to move the camera.
----------------------------------------------------------------------------

--- @function set_state_override
--- @desc Maps a state override to a infotext key. When an infotext entry with this key is shown, the state of the infotext line component is overriden to that supplied here. This is generally called somewhere at the start of the calling script, with the actual infotext line being shown later.
--- @p string infotext key, Infotext key
--- @p string component state override, Component state override. This much match the name of a state on the infotext line component (editable in UIEd)
function infotext_manager:set_state_override(component_id, state_override)
	if not is_string(component_id) then
		script_error("ERROR: set_state_override() called but supplied component id [" .. tostring(component_id) .. "] is not a string");
		return false;
	end;
	
	if not is_string(state_override) then
		script_error("ERROR: set_state_override() called but supplied state override [" .. tostring(state_override) .. "] is not a string");
		return false;
	end;
	
	self.state_overrides[component_id] = state_override;
end;



----------------------------------------------------------------------------
--- @section Manipulation
----------------------------------------------------------------------------


--	adds one or more lines of infotext. Supply one or more string infotext keys. Optionally
--	allows specification of a delay in seconds, which should be supplied as the first
--	argument - this is useful for triggering infotext with advice, as it allows the advice to
--	animate on-screen first which looks more refined.
--- @function add_infotext

--- @desc Adds one or more lines of infotext to the infotext panel. Supply one or more string infotext keys. Upon calling <code>add_infotext</code>, the infotext box expands to the final required size, and then individual infotext lines are faded on sequentially. The first argument may optionally be an initial delay - this is useful when triggering infotext at the same time as advice, as it gives the advisor an amount of time to animate on-screen before infotext begins to display, which looks more refined.
--- @p object first param, Can be a string key from the advice_info_texts table, or a number specifying an initial delay (ms in battle, s in campaign) after the panel animates onscreen and the first infotext item is shown.
--- @p ... additional infotext strings, Additional infotext strings to be shown. <code>add_infotext</code> fades each of them on to the infotext panel in a visually-pleasing sequence.
function infotext_manager:add_infotext(param1, ...)
	local infotext_record = {};
	infotext_record.delay = 0;
	
	if is_string(param1) then
		-- first parameter was a string i.e. no delay was specified
		table.insert(infotext_record, param1);
	else
		infotext_record.delay = param1;
	end;
	
	-- make a table of the inputs
	for i = 1, arg.n do
		table.insert(infotext_record, arg[i]);
	end;
		
	self:create_infotext_panel();
	
	-- should only happen in autoruns
	if not self.uic_infotext then
		return;
	end;
	
	if self.infotext_currently_being_added then
		table.insert(self.infotext_queue, infotext_record);
	else
		self:show_infotext(infotext_record);
	end;
end;


--	Actually shows an infotext record - for internal use
function infotext_manager:show_infotext(infotext_record, end_callback)
	local delay = infotext_record.delay;
	local add_count = 0;
	local time_multiplier = 1;
	local callback = nil;
	local out_func = nil;
	local last_update = 0;
	local time_speed = self.time_speed;
	
	self.infotext_currently_being_added = true;
	
	-- set up some vars depending on whether we're in campaign or battle
	if __game_mode == __lib_type_battle then
		time_multiplier = 1000;
		callback = function(func, t, id) get_bm():callback(func, t, id) end;
		out_func = function(str) bm:out(str) end;
	else
		callback = function(func, t, id) get_cm():callback(func, t, id) end;
		out_func = function(str) output(str) end;
	end;

	for i = 1, #infotext_record do
		local current_infotext_record = infotext_record[i];
	
		-- if this record is a callback, then we call it after all the infotext has been shown
		if is_function(current_infotext_record) then
			end_callback = current_infotext_record;
	
		-- find any infotext lines that we have to remove, they must have a "-" character prepended to the string
		elseif string.sub(current_infotext_record, 1, 1) == "-" then
			local key = string.sub(current_infotext_record, 2);
			
			self:remove_infotext(key);
			out_func("\tRemoving infotext key " .. key);
		else
			-- otherwise add them
			local key = current_infotext_record;
			
			-- increase the size of the infotext box
			callback(
				function()
					local uic_infotext = self:get_uicomponent();
					-- out_func("\tAdding infotext key " .. key .. " to panel");
					-- uic_infotext:InterfaceFunction("add_info_text_entry", key, true);
					interface_function(uic_infotext, "add_info_text_entry", key, true);
					
					-- find the entry just added
					local uic_entry = find_uicomponent(uic_infotext, key);
					
					if uic_entry then
						
						-- see if we have an override state for it
						self:parse_component_for_state_overrides(uic_entry, out_func);
						
						-- parse the text in it for script links
						self.parser:parse_component_for_tooltips(uic_entry);
					else
						script_error("ERROR: could not find infotext entry just added with key " .. key .. ", is the key correct?");
					end;
				end, 
				(delay + ((i - 1) * 0.1 * time_speed)) * time_multiplier * time_speed,
				"add_infotext"
			);
			
			local t = (delay + self.initial_delay + (add_count * self.line_delay)) * time_multiplier * time_speed;

			-- actually show the infotext entry
			callback(
				function()
					out_func("\tShowing infotext key " .. key .. " in panel");
					-- self.uic_infotext:InterfaceFunction("show_text_entry", key);
					interface_function(self.uic_infotext, "show_text_entry", key);
				end, 
				t, 
				"add_infotext"
			);
			
			add_count = add_count + 1;
			last_update = t;
		end;
	end;
	
	-- see if any more infotext records have been queued up after we've finished
	callback(
		function()
			if #self.infotext_queue > 0 then
				local new_infotext_record = self.infotext_queue[1];
				table.remove(self.infotext_queue, 1);
				self:show_infotext(new_infotext_record, end_callback);
			else
				self:show_infotext_finish(end_callback);
			end;
		end,
		last_update + time_multiplier * time_speed, 
		"add_infotext"
	);
end;


--	for internal use
function infotext_manager:show_infotext_finish(end_callback)
	self.infotext_currently_being_added = false;
	
	if is_function(end_callback) then
		end_callback();
	end;
end;


-- called when the player clicks back/forward, parses the newly-displayed infotext page for script links and formats them
function infotext_manager:parse_history_page_for_tooltips()
	local parse_func = function()
		-- get the actual infotext list
		local uic_infotext = find_uicomponent(self:get_uicomponent(), "info_text");
		
		for i = 0, uic_infotext:ChildCount() - 1 do	
			local uic_entry = UIComponent(uic_infotext:Find(i));
			
			self:parse_component_for_state_overrides(uic_entry);
			
			-- uic_entry:SetCanResizeHeight(true);		
			self.parser:parse_component_for_tooltips(uic_entry);
			-- local w, h, d = uic_entry:TextDimensions();
			-- uic_entry:Resize(uic_entry:Width(), h + 5);
			-- uic_entry:SetCanResizeHeight(false);
		end;
	end;
	
	if __game_mode == __lib_type_battle then
		-- get_bm():callback(parse_func, 200);
		parse_func();
	else
		get_cm():callback(parse_func, 0.2);
	end;
end;


-- see if we have an override state for this component
function infotext_manager:parse_component_for_state_overrides(uic_entry, out_func)
	local state_override = self.state_overrides[uic_entry:Id()];
	if state_override then
		if is_function(out_func) then
			out_func("\tOverride state of infotext component corresponding to key " .. uic_entry:Id() .. " to " .. state_override);
		end;
		uic_entry:SetState(state_override);
	end;
end;


--- @function remove_infotext
--- @desc Removes a line of infotext from the infotext panel, by key.
--- @p string infotext key
function infotext_manager:remove_infotext(key)
	local uic_infotext = self:get_uicomponent();
	
	if uic_infotext then
		-- self.uic_infotext:InterfaceFunction("remove_info_text_entry", key);
		interface_function(uic_infotext, "remove_info_text_entry", key);
	end;
end;


--- @function clear_infotext
--- @desc Clears all infotext from the infotext panel.
function infotext_manager:clear_infotext()
	local uic_infotext = self:get_uicomponent();
	
	if uic_infotext then
		-- self.uic_infotext:InterfaceFunction("clear_all_info_text");
		interface_function(uic_infotext, "clear_all_info_text");
	end;
	
	self:cancel_add_infotext();
end;


--	cancels any pending infotext
function infotext_manager:cancel_add_infotext()	
	if __game_mode == __lib_type_battle then
		get_bm():remove_process("add_infotext");
	else
		get_cm():remove_callback("add_infotext");
	end;
	
	self.infotext_currently_being_added = false;
	self.infotext_queue = {};
end;







