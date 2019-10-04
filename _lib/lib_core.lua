


----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CORE MANAGER
--
--- @loaded_in_battle
--- @loaded_in_campaign
--- @loaded_in_frontend
--- @class core_object Core
--- @desc The core object provides a varied suite of functionality that is sensible to provide in all the various game modes (campaign/battle/frontend). When the script libraries are loaded, a core_object is automatically created. It is called 'core' and the functions it provides can be called with a double colon e.g. <code>core:get_ui_root()</code>
--- @desc Examples of the kind of functionality provided by the core object are event listening and triggering, ui access, and saving and loading values to the scripted value registry.
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------






----------------------------------------------------------------------------
--	Definition
----------------------------------------------------------------------------

core_object = {

	svr = false,

	-- ui creation and destruction
	ui_root = false,
	ui_is_created = false,
	ui_created_callbacks = {},
	ui_destroyed_callbacks = {},
	
	-- game mode
	game_mode = 0,
	
	path_to_dummy_component = "UI/Campaign UI/script_dummy",
	
	-- cached advisor priority
	cached_advisor_priority = -1,
	cached_objectives_priority = -1,
	cached_advisor_topmost = false,
	
	-- event handler
	add_func = nil,
	attached_events = {},
	event_listeners = {},
	debug_counter = 0,
	env = false,

	-- loaded mods
	loaded_mods = {},
	
	-- unique counter, for use across script
	unique_counter = 0,
	
	-- ui hiding
	enable_ui_hiding_on_hide_fullscreen_highlight = true,
	
	-- text pointer names
	registered_text_pointer_names = {},
	advice_history_reset_listener_established_for_text_pointer_names = false,
	
	-- caching tooltips for component states
	cached_tooltips_for_component_states = {},
	
	-- static objects
	static_objects = {},

	-- debug listeners
	cli_listeners = {}
};







----------------------------------------------------------------------------
--- @section Creation
----------------------------------------------------------------------------

--- @function new
--- @desc Creates a core object. There is no need for client scripts to call this, as a core object is created automatically by the script libraries when they are loaded.
--- @return core_object
function core_object:new()

	local c = {};
	setmetatable(c, self);
	self.__index = self;
	self.__tostring = function() return TYPE_CORE end;
	
	
	----------------------------------------------------------
	-- event handling functionality
	-- determine what game mode we're running in and choose an appropriate add
	----------------------------------------------------------
	local add_func = false;
	if __game_mode == __lib_type_battle then
		c.add_func = add_battle_event_callback;
	elseif __game_mode == __lib_type_campaign then
		c.add_func = add_campaign_event_callback;
	elseif __game_mode == __lib_type_frontend then
		c.add_func = add_frontend_event_callback;
	else
		script_error("ERROR: attempt was made to create core object but couldn't determine the game mode - how can this be?");
		return false;
	end;
	
	c.attached_events = {};
	c.event_listeners = {};	
	
	----------------------------------------------------------
	----------------------------------------------------------
	
	c.env = getfenv(1);	

	c.registered_text_pointer_names = {};
	c.cached_tooltips_for_component_states = {};
	
	----------------------------------------------------------
	-- UI Creation and destruction listeners
	----------------------------------------------------------
		
	-- listen for the UICreated event, unless we're in battle 
	-- (the script is loaded after the UI is created, the battle manager will give us a handle to the ui root)
	if __game_mode ~= __lib_type_battle then
		c:add_listener(
			"core_ui_created_listener",
			"UICreated",
			true,
			function(context)
				c:ui_created(context);
			end,
			true
		);
	end;
	
	c:add_listener(
		"core_ui_destroyed_listener",
		"UIDestroyed",
		true,
		function(context)
			c:ui_destroyed(context);
		end,
		true
	);
		
	c.ui_created_callbacks = {};
	c.ui_destroyed_callbacks = {};


	----------------------------------------------------------
	-- CLI Event Listeners
	----------------------------------------------------------
	c:initialise_cli_listeners();

	----------------------------------------------------------
	----------------------------------------------------------
	
	-- automatically create a scripted value registry, used for passing messages between environments
	c.svr = ScriptedValueRegistry:new();
	
	
	-- overwrite this function so that another core_object cannot be created this session (hack?!)
	function core_object:new()
		script_error("ERROR: core_object:new() called but core_object has already been created");
		return false;
	end;
	
	return c;
end;









----------------------------------------------------------------------------
--- @section UI Root
--- @desc Functions concerning the UI root.
----------------------------------------------------------------------------

--- @function get_ui_root
--- @desc Gets a handle to the ui root object. A script_error is thrown if this is called before the ui has been created.
--- @return uicomponent ui root
function core_object:get_ui_root()
	if not self.ui_root then
		script_error("ERROR: get_ui_root() called on the core object but the ui has not been created yet");
		return false;
	end;
	
	return self.ui_root;
end;


--- @function set_ui_root
--- @p uicomponent ui root
--- @desc sets the ui root object that the core stores. Not to be called outside of the script libraries.
function core_object:set_ui_root(ui_root)
	if not is_uicomponent(ui_root) then
		script_error("ERROR: set_ui_root() called but supplied object [" .. tostring(ui_root) .. "] is not a uicomponent");
		return false;
	end;
	
	self.ui_is_created = true;
	self.ui_root = ui_root;
end;


--- @function is_ui_created
--- @desc Returns whether the ui has been created or not. Useful if clients scripts are running so early in the load sequence that the ui may not have been set up yet.
--- @desc Once this function returns true, client scripts should be okay to start asking questions of the game and model.
--- @return boolean is ui created
function core_object:is_ui_created()
	return self.ui_is_created;
end;








----------------------------------------------------------------------------
--- @section UI Creation and Destruction
--- @desc The core object listens for the UI being created and destroyed. Client scripts can register callbacks with the core object to get notified when the UI is set up or destroyed. 
--- @desc It is strongly advised that client scripts use this functionality rather than listen for the UICreated and UIDestroyed events directly, because the core object sets up the UI root before sending out notifications about the ui being created.
----------------------------------------------------------------------------

--- @function add_ui_created_callback
--- @desc Adds a callback to be called when the UI is created.
--- @p function callback
function core_object:add_ui_created_callback(callback)
	if not is_function(callback) then
		script_error("ERROR: add_ui_created_callback called but supplied callback [" .. tostring(callback) .. "] is not a function");
	end;
	
	table.insert(self.ui_created_callbacks, callback);
end;


-- called when ui is created
function core_object:ui_created(context)
	cache_tab();
	out("");
	out("********************************************************************************");
	out("event has occurred:: UICreated, environment is " .. context.string);
	out("********************************************************************************");
	inc_tab();
	
	-- get a handle to the ui root
	self.ui_root = UIComponent(context.component);
	self.ui_is_created = true;
	
	for i = 1, #self.ui_created_callbacks do
		self.ui_created_callbacks[i](context);
	end;
	
	dec_tab();
	out("********************************************************************************");
	out("");
	restore_tab();
	
	-- get the game script environment and transmit it in an event, which autotest scripts can listen for
	if context.string == "Campaign UI" then
		self:trigger_event("ScriptEventCampaignUICreated", getfenv(2));
	end;
end;


--- @function add_ui_destroyed_callback
--- @desc Adds a callback to be called when the UI is destroyed.
--- @p function callback
function core_object:add_ui_destroyed_callback(callback)
	if not is_function(callback) then
		script_error("ERROR: add_ui_destroyed_callback called but supplied callback [" .. tostring(callback) .. "] is not a function");
	end;
	
	table.insert(self.ui_destroyed_callbacks, callback);
end;


-- called when ui is destroyed
function core_object:ui_destroyed(context)
	
	cache_tab();
	out("");
	out("********************************************************************************");
	out("event has occurred:: UIDestroyed");
	out("********************************************************************************");
	inc_tab();
	
	for i = 1, #self.ui_destroyed_callbacks do
		self.ui_destroyed_callbacks[i](context);
	end;
	
	if context.string == "Campaign UI" then
		self:trigger_event("ScriptEventPreUIDestroyedCallbacksProcessedCampaign", context);
	end;
	
	self.ui_is_created = false;
	self.ui_root = false;
	
	dec_tab();
	out("********************************************************************************");
	out("");
	restore_tab();
end;





----------------------------------------------------------------------------
--- @section Game Configuration
--- @desc Functions that return information about the game.
----------------------------------------------------------------------------

--- @function is_debug_config
--- @desc Returns true if the game is not running in final release or intel configurations, false if the game is running in debug or profile configuration
--- @return boolean is debug config
function core_object:is_debug_config()
	return defined and not (defined.final_release or defined.intel);
end;


--- @function is_tweaker_set
--- @desc Returns whether a tweaker with the supplied name is set
--- @p string tweaker name
--- @return boolean tweaker is set
function core_object:is_tweaker_set(tweaker_name)
	return (effect.tweaker_value(tweaker_name) == "1");
end;


--- @function get_screen_resolution
--- @desc Returns the current screen resolution
--- @return integer screen x dimension
--- @return integer screen y dimension
function core_object:get_screen_resolution()
	return self.ui_root:Dimensions();
end;





----------------------------------------------------------------------------
--- @section Game Mode
--- @desc Functions that return the mode the game is currently running in.
----------------------------------------------------------------------------

--- @function is_campaign
--- @desc Returns whether the game is currently in campaign mode
--- @return boolean is campaign
function core_object:is_campaign()
	return __game_mode == __lib_type_campaign;
end;


--- @function is_battle
--- @desc Returns whether the game is currently in battle mode
--- @return boolean is battle
function core_object:is_battle()
	return __game_mode == __lib_type_battle;
end;


--- @function is_frontend
--- @desc Returns whether the game is currently in the frontend
--- @return boolean is battle
function core_object:is_frontend()
	return __game_mode == __lib_type_frontend;
end;











----------------------------------------------------------------------------
--- @section Script Environment
----------------------------------------------------------------------------

--- @function get_env
--- @desc Returns the current global lua function environment. This can be used to force other functions to have global scope.
--- @return @table environment
function core_object:get_env()
	return self.env;
end;









----------------------------------------------------------------------------
--- @section Mod Loading
--- @desc Functions for loading and, in campaign, executing mod scripts. Note that @global:ModLog can be used by mods for output.
----------------------------------------------------------------------------


--- @function load_mods
--- @desc Loads all mod scripts found on each of the supplied paths, setting the environment of every loaded mod to the global environment.
--- @p ... paths, List of string paths from which to load mods from. The terminating <code>/</code> character must be included.
--- @return @boolean All mods loaded correctly
--- @example core:load_mods("/script/_lib/mod/", "/script/battle/mod/");
function core_object:load_mods(...)

	ModLog("");
	ModLog("****************************");
	ModLog("Loading Mods");
	out.inc_tab();

	local all_ok = true;
	local out_str = false;

	for i = 1, arg.n do
		local path = arg[i];

		if not is_string(path) then
			script_error("ERROR: load_mods() called but supplied path [" .. tostring(path) .. "] is not a string");
			out.dec_tab();
			ModLog("****************************");
			ModLog("");
			return false;
		end;

		package.path = path .. "?.lua;" .. package.path;

		local file_str = effect.filesystem_lookup(path, "*.lua");

		for filename in string.gmatch(file_str, '([^,]+)') do
			local ok, err = pcall(function(filename) self:load_mod_script(filename) end, filename);
			
			if ok then
				ModLog("Mod [" .. tostring(filename) .. "] loaded successfully");
			else
				ModLog("Failed to load mod: [" .. tostring(filename) .. "], error is: " .. tostring(err));
				all_ok = false;
			end;
		end;
	end;

	out.dec_tab();
	ModLog("****************************");
	ModLog("");

	return all_ok;
end;


-- internal function to load an individual mod script
function core_object:load_mod_script(filename)
	local pointer = 1;

	local filename_for_out = filename;
	
	while true do
		local next_separator = string.find(filename, "\\", pointer) or string.find(filename, "/", pointer);
		
		if next_separator then
			pointer = next_separator + 1;
		else
			if pointer > 1 then
				filename = string.sub(filename, pointer);
			end;
			break;
		end;
	end;
	
	local suffix = string.sub(filename, string.len(filename) - 3);
	
	if string.lower(suffix) == ".lua" then
		filename = string.sub(filename, 1, string.len(filename) - 4);
	end;

	-- Avoid loading more than once
	if package.loaded[filename] then
		return false;
	end
	
	-- Loads a Lua chunk from the file
	local loaded_file, err = loadfile(filename);
	
	-- Make sure something was loaded from the file
	if loaded_file then
		-- output
		local out_str = "Loading mod file [" .. filename_for_out .. "]";
		ModLog(out_str);
		
		-- Set the environment of the Lua chunk to the global environment
		setfenv(loaded_file, self:get_env());
		-- Make sure the file is set as loaded
		package.loaded[filename] = true;
		-- Execute the loaded Lua chunk so the functions within are registered
		out.inc_tab();
		loaded_file();
		out.dec_tab();

		table.insert(self.loaded_mods, filename);

		return true;
	else
		-- output
		local out_str = "Failed to load mod file [" .. filename_for_out .. "], error is: " .. tostring(err);
		ModLog(out_str);
		return false;
	end;
end;


--- @function execute_mods
--- @desc Attempts to execute a function of the same name as the filename of each mod that has previously been loaded by @core_object:load_mods. For example, if mods have been loaded from <code>mod_a.lua</code>, <code>mod_b.lua</code> and <code>mod_c.lua</code>, the functions <code>mod_a()</code>, <code>mod_b()</code> and <code>mod_c()</code> will be called, if they exist. This can be used to start the execution of mod scripts at an appropriate time, particularly during campaign script startup.
--- @desc One or more arguments can be passed to <code>execute_mods</code>, which are in-turn passed to the mod functions being executed.
--- @p ... arguments, Arguments to be passed to mod function(s).
--- @return @boolean No errors reported
function core_object:execute_mods(...)

	ModLog("");
	ModLog("****************************");
	ModLog("Executing Mods");
	out.inc_tab();

	local env = self:get_env();

	for i = 1, #self.loaded_mods do
		local current_mod_name = self.loaded_mods[i];

		-- proceed if there's a function with the same name as the mod file
		if is_function(env[current_mod_name]) then
			ModLog("Executing mod function " .. current_mod_name .. "()");
			out.inc_tab();

			-- call the function
			local ok, result = pcall(env[current_mod_name], unpack(arg));

			out.dec_tab();

			if ok then
				ModLog(current_mod_name .. "() executed successfully");
			else
				ModLog("ERROR: " .. current_mod_name .. "() failed while executing with error: " .. result);
			end;
		else
			ModLog(current_mod_name .. "() not found, continuing");
		end;
	end;

	out.dec_tab();
	ModLog("****************************");
	ModLog("");
end;


--- @function is_mod_loaded
--- @desc Returns whether a mod with the supplied name is loaded. The path may be omitted.
--- @p @string mod name
--- @return @boolean mod is loaded
function core_object:is_mod_loaded(mod_name)
	local loaded_mods = self.loaded_mods;

	for i = 1, #loaded_mods do
		if loaded_mods[i] == mod_name then
			return true;
		end;
	end;

	return false;
end;










----------------------------------------------------------------------------
--- @section Advice Level
--- @desc Functions concerning the advice level setting, which defaults to 'high' but can be changed by the player.
----------------------------------------------------------------------------

--- @function get_advice_level
--- @desc Returns the current advice level value. A returned value of 0 corresponds to 'minimal', 1 corresponds to 'low', and 2 corresponds to 'high'.
--- @return integer advice level
function core_object:get_advice_level()
	return effect.get_advice_level();
end;


--- @function is_advice_level_minimal
--- @desc Returns whether the advice level is currently set to minimal.
--- @return boolean is advice level minimal
function core_object:is_advice_level_minimal()
	return (effect.get_advice_level() == 0);
end;


--- @function is_advice_level_low
--- @desc Returns whether the advice level is currently set to low.
--- @return boolean is advice level low
function core_object:is_advice_level_low()
	return (effect.get_advice_level() == 1);
end;


--- @function is_advice_level_high
--- @desc Returns whether the advice level is currently set to high.
--- @return boolean is advice level high
function core_object:is_advice_level_high()
	return (effect.get_advice_level() == 2);
end;






----------------------------------------------------------------------------
--- @section Scripted Value Registry
--- @desc The scripted value registry is an object supplied by the game to script which can be used to set values that persist over lua sessions. As lua sessions are destroyed/recreated when the game loads from one mode to another (campaign to battle, frontend to campaign etc) the svr makes it possible for scripts to store information for scripts in future sessions to retrieve.
--- @desc This information is cleared when the game as a whole is closed and re-opened, but the scripted value registry also allows boolean values to be saved in the registry. Such values will persist, even between reloads of the game client.
--- @desc The core object automatically creates a handle to the scripted value registry and an interface to it. The following functions can be called to interact with the scripted value registry.
----------------------------------------------------------------------------


--- @function get_svr
--- @desc Returns a handle to the scripted value registry object. It shouldn't be necessary to call this, as the core object provides access to all its functionality through its wrapper functions.
--- @return scripted_value_registry svr
function core_object:get_svr()
	return self.svr;
end;


--- @function svr_save_bool
--- @desc Saves a boolean value to the svr. This will persist as the game loads between modes (campaign/battle/frontend) but will be destroyed if the game is restarted.
--- @p string value name
--- @p boolean value
function core_object:svr_save_bool(name, value)
	if not is_string(name) then
		script_error("ERROR: svr_save_bool() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_boolean(value) then
		script_error("ERROR: svr_save_bool() called but supplied value [" .. tostring(value) .. "] is not boolean");
		return false;
	end;
	
	return self.svr:SaveBool(name, value);
end;


--- @function svr_load_bool
--- @desc Retrieves a boolean value from the svr.
--- @p string value name
--- @return boolean value
function core_object:svr_load_bool(name)
	return self.svr:LoadBool(name);
end;


--- @function svr_save_string
--- @desc Saves a string value to the svr. This will persist as the game loads between modes (campaign/battle/frontend) but will be destroyed if the game is restarted.
--- @p string value name
--- @p string value
function core_object:svr_save_string(name, value)
	if not is_string(name) then
		script_error("ERROR: svr_save_string() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(value) then
		script_error("ERROR: svr_save_string() called but supplied value [" .. tostring(value) .. "] is not string");
		return false;
	end;

	return self.svr:SaveString(name, value);
end;


--- @function svr_load_string
--- @desc Retrieves a string value from the svr.
--- @p string value name
--- @return string value
function core_object:svr_load_string(name)
	return self.svr:LoadString(name);
end;


--- @function svr_save_registry_bool
--- @desc Saves a boolean value to the registry. This will persist, even if the game is reloaded.
--- @p string value name
--- @p boolean value
function core_object:svr_save_registry_bool(name, value)
	if not is_string(name) then
		script_error("ERROR: svr_save_registry_bool() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_boolean(value) then
		script_error("ERROR: svr_save_registry_bool() called but supplied value [" .. tostring(value) .. "] is not boolean");
		return false;
	end;

	return self.svr:SaveRegistryBool(name, value);
end;


--- @function svr_load_registry_bool
--- @desc Loads a boolean value from the registry.
--- @p string value name
--- @return boolean value
function core_object:svr_load_registry_bool(name)
	return self.svr:LoadRegistryBool(name);
end;







----------------------------------------------------------------------------
--- @section Fullscreen Highlighting
--- @desc A fullscreen highlight is an effect where the screen is masked out with a semi-opaque layer on top, save for a window cut out through which the game interface can be seen. This can be used by tutorial scripts to draw the player's attention to a particular part of the screen. The fullscreen highlight prevents the player from clicking on those portions of the screen that are masked off.
--- @desc A fullscreen highlight effect may be established around a supplied set of components with <code>show_fullscreen_highlight_around_components()</code>. Once established, a fullscreen highlight effect must be destroyed with <code>hide_fullscreen_highlight()</code>.
--- @desc This fullscreen highlight functionality wraps the FullscreenHighlight functionality provided by the underlying UI code. It's recommended to use this wrapper rather than calling the code functions directly.
----------------------------------------------------------------------------

--- @function show_fullscreen_highlight_around_components
--- @desc Shows a fullscreen highlight around a supplied component list. Once established, this highlight must later be destroyed with <code>hide_fullscreen_highlight()</code>.
--- @desc An integer padding value must be supplied, which specifies how much visual padding to give the components. The higher the supplied value, the more space is given around the supplied components visually.
--- @desc The underlying FullscreenHighlight functionality supports showing text on the fullscreen highlight itself. If you wish to specify some text to be shown, it may be supplied using the second parameter in the common localised text format <code>[table]_[field_of_text]_[key_from_table]</code>.
--- @p number padding, Padding value, must be 0 or greater
--- @p [opt=nil] string highlight text key Highlight text key, may be nil
--- @p ... uicomponent list
function core_object:show_fullscreen_highlight_around_components(padding, highlight_text, ...)

	if not is_number(padding) or padding < 0 then
		script_error("ERROR: show_fullscreen_highlight_around_components() called but supplied padding value [" .. tostring(padding) .. "] is not a positive number");
		return false;
	end;
	
	if highlight_text and not is_string(highlight_text) then
		script_error("ERROR: show_fullscreen_highlight_around_components() called but supplied highlight text key [" .. tostring(highlight_text) .. "] is not a string or nil/false");
		return false;
	end;
		
	local min_x = 10000000;
	local min_y = 10000000;
	local max_x = 0;
	local max_y = 0;
	
	for i = 1, arg.n do
		local current_component = arg[i];
		
		if not is_uicomponent(current_component) then
			script_error("ERROR: show_fullscreen_highlight_around_components() called but parameter " .. i .. " in supplied list is a [" .. tostring(current_component) .. "] and not a uicomponent");
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
		ui_root:CreateComponent("highlight_dummy", self.path_to_dummy_component);
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
		
	if not highlight_text or highlight_text == "" then
		uic_dummy:FullScreenHighlight("", false);
	else
		uic_dummy:FullScreenHighlight(highlight_text, false);
	end;
	
	-- fullscreen highlights should be non-interactive by default
	self:set_fullscreen_highlight_interactive(false);
		
	-- stop help page highlighting and disable UI toggling
	if self:is_campaign() then
		local cm = get_cm();
		
		if cm:is_ui_hiding_enabled() then
			cm:enable_ui_hiding(false);
			self.enable_ui_hiding_on_hide_fullscreen_highlight = true;
		else
			self.enable_ui_hiding_on_hide_fullscreen_highlight = false;
		end;		
		
		cm:get_campaign_ui_manager():override("help_page_link_highlighting"):set_allowed(false);
	elseif self:is_battle() then
		local bm = get_bm();
		
		if bm:is_ui_hiding_enabled() then
			bm:enable_ui_hiding(false);
			self.enable_ui_hiding_on_hide_fullscreen_highlight = true;
		else
			self.enable_ui_hiding_on_hide_fullscreen_highlight = false;
		end;
		
		bm:get_battle_ui_manager():set_help_page_link_highlighting_permitted(false);
	end;
end;


--- @function hide_fullscreen_highlight
--- @desc Hides/destroys the active fullscreen highlight.
function core_object:hide_fullscreen_highlight()
	local uic_fh = find_uicomponent(self:get_ui_root(), "fullscreen_highlight");
	
	if uic_fh then
		uic_fh:TriggerAnimation("destroy");
	end;
	
	-- allow help page highlighting and UI toggling to work again
	if self:is_campaign() then
		local cm = get_cm();
		cm:get_campaign_ui_manager():override("help_page_link_highlighting"):set_allowed(true);
		
		if self.enable_ui_hiding_on_hide_fullscreen_highlight then
			cm:enable_ui_hiding(true);
		end;
	elseif self:is_battle() then
		local bm = get_bm();
		bm:get_battle_ui_manager():set_help_page_link_highlighting_permitted(true);
		
		if self.enable_ui_hiding_on_hide_fullscreen_highlight then
			bm:enable_ui_hiding(true);
		end;
	end;
end;


--- @function set_fullscreen_highlight_interactive
--- @desc Sets the active fullscreen highlight to be interactive. An interactive fullscreen highlight will respond to clicks. By default fullscreen highlights are non-interactive, but the functionality to make them interactive is provided here in case it's needed.
--- @p [opt=true] boolean value
function core_object:set_fullscreen_highlight_interactive(value)

	if value == nil then
		value = true;
	else
		value = not not value;
	end;

	local uic_fh = find_uicomponent(self:get_ui_root(), "fullscreen_highlight");
	
	if uic_fh then
		uic_fh:SetInteractive(value);
	end;
end;














----------------------------------------------------------------------------
--- @section Advisor Priority Cache
--- @desc Functionality to set and reset the advisor UI priority, which determines at what level the advisor is displayed (i.e. on top of/underneath other components). This is useful during tutorial scripting when the ui priority of other elements on the screen (particularly fullscreen highlighting) has been modified, or is otherwise interfering with the visibility of the advisor.
----------------------------------------------------------------------------

--- @function cache_and_set_advisor_priority
--- @desc Sets the advisor priority to the supplied value, and caches the value previously set. The advisor priority can later be restored with <code>restore_advisor_priority</code>.
--- @desc The register_topmost flag can also be set to force the advisor to topmost.
function core_object:cache_and_set_advisor_priority(new_priority, register_topmost)
	if not is_number(new_priority) then
		script_error("ERROR: cache_and_set_advisor_priority() called but supplied priority [" .. tostring(new_priority) .."] is not a number");
		return false;
	end;

	local ui_root = self.ui_root;
		
	-- cache the current advisor priority and set it to its new value
	local uic_advisor = find_uicomponent(ui_root, "advice_interface");
	if uic_advisor then
		self.cached_advisor_priority = uic_advisor:Priority();
		uic_advisor:PropagatePriority(new_priority);
		ui_root:Adopt(uic_advisor:Address());
		
		if register_topmost then
			uic_advisor:RegisterTopMost();
			self.cached_advisor_topmost = true;
		end;
	end;
	
	-- ditto objectives panel
	local uic_objectives = find_uicomponent(ui_root, "scripted_objectives_panel");
	if uic_objectives then
		self.cached_objectives_priority = uic_objectives:Priority();
		uic_objectives:PropagatePriority(new_priority);
		ui_root:Adopt(uic_objectives:Address());
	end;
end;


--- @function restore_advisor_priority
--- @desc Restores the advisor priority to a value previously cached with <code>cache_and_set_advisor_priority</code>.
function core_object:restore_advisor_priority()
	if self.cached_advisor_priority == -1 then
		script_error("WARNING: restore_advisor_priority() called but advisor priority hasn't been previously cached with cache_and_set_advisor_priority() - be sure to call that first");
		return false;
	end;
	
	local ui_root = core:get_ui_root();
	
	local uic_advisor = find_uicomponent(ui_root, "advice_interface");
	if uic_advisor then
		
		if self.cached_advisor_topmost then
			self.cached_advisor_topmost = false;
			uic_advisor:RemoveTopMost();
		end;
	
		uic_advisor:PropagatePriority(self.cached_advisor_priority);
		ui_root:Adopt(uic_advisor:Address());
	end;
	
	local uic_objectives = find_uicomponent(ui_root, "scripted_objectives_panel");
	if uic_objectives then
		uic_objectives:PropagatePriority(self.cached_objectives_priority);
		ui_root:Adopt(uic_objectives:Address());
	end;
end;





----------------------------------------------------------------------------
--- @section UIComponent Creation
----------------------------------------------------------------------------

--- @function get_or_create_component
--- @desc Creates a UI component with the supplied name, or retrieves it if it's already been created.
--- @p string uicomponent name
--- @p string file path, File path to uicomponent layout
--- @p [opt=ui_root] uicomponent parent uicomponent
--- @return uicomponent created or retrieved uicomponent
function core_object:get_or_create_component(name, path, uic_parent)
	uic_parent = uic_parent or core:get_ui_root();
	
	for i = 0, uic_parent:ChildCount() - 1 do
		local uic_child = UIComponent(uic_parent:Find(i));
		
		if uic_child:Id() == name then
			return uic_child, false;
		end;
	end;
	
	return UIComponent(uic_parent:CreateComponent(name, path)), true;
end;







----------------------------------------------------------------------------
---	@section Event Handling
--- @desc The core object provides a wrapper interface for client scripts to listen for events triggered by the game code, which is the main mechanism by which the game sends messages to script.
----------------------------------------------------------------------------

--- @function add_listener
--- @desc Adds a listener for an event. When the code triggers this event, and should the optional supplied conditional test pass, the core object will call the supplied target callback with the event context as a single argument.
--- @desc A name must be specified for the listener which may be used to cancel it at any time. Names do not have to be unique between listeners.
--- @desc The conditional test should be a function that returns a boolean value. This conditional test callback is called when the event is triggered, and the listener only goes on to trigger the supplied target callback if the conditional test returns true. Alternatively, a boolean <code>true</code> value may be given in place of a conditional callback, in which case the listener will always go on to call the target callback if the event is triggered.
--- @desc Once a listener has called its callback it then shuts down unless the persistent flag is set to true, in which case it may only be stopped by being cancelled by name.
--- @p string listener name
--- @p string event name
--- @p function conditional test, Conditional test, or <code>true</code> to always pass
--- @p function target callback
--- @p boolean listener persists after target callback called
function core_object:add_listener(new_name, new_event, new_condition, new_callback, new_persistent)
	if not is_string(new_name) then
		script_error("ERROR: event_handler:add_listener() called but name given [" .. tostring(new_name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(new_event) then
		script_error("ERROR: event_handler:add_listener() called but event given [" .. tostring(new_event) .. "] is not a string");
		return false;
	end;
	
	if not is_function(new_condition) and not (is_boolean(new_condition) and new_condition == true) then
		script_error("ERROR: event_handler:add_listener() called but condition given [" .. tostring(new_condition) .. "] is not a function or true");
		return false;
	end;
	
	if not is_function(new_callback) then
		script_error("ERROR: event_handler:add_listener() called but callback given [" .. tostring(new_callback) .. "] is not a function");
		return false;
	end;
	
	local new_persistent = new_persistent or false;
	
	-- attach to the event if we're not already
	self:attach_to_event(new_event);
	
	local new_listener = {
		name = new_name,
		event = new_event,
		condition = new_condition,
		callback = new_callback,
		persistent = new_persistent,
		to_remove = false
	};
		
	table.insert(self.event_listeners, new_listener);	
end;


-- attach a listener to an event we're not already listening for
function core_object:attach_to_event(event_name)

	for i = 1, #self.attached_events do
		if self.attached_events[i].name == event_name then
			-- we're already attached
			return;
		end;
	end;
	
	-- we're not attached
	local event_to_attach = {
		name = event_name,
		callback = function(context) self:event_callback(event_name, context) end
	};
	
	-- create a table for this event if one is not already established
	if not events[event_name] then
		events[event_name] = {};
	end;
	
	if not event_to_attach.callback then
		script_error("No callback for " .. tostring(event_name) .. tostring(event_to_attach) )
	end;
	self.add_func(event_name, function(context) event_to_attach.callback(context) end);
	
	table.insert(self.attached_events, event_to_attach);
end;


-- event callback
-- an event has occured, work out who to notify
function core_object:event_callback(event_name, context)
	-- out.events("Event Fired: " .. event_name);
	
	-- if the context seems to be from a code-generated event, and we are running in campaign, then attempt to register context and model/query interfaces with the campaign manager
	local is_code_context = false;
	
	if __game_mode == __lib_type_campaign and is_eventcontext(context) then
		is_code_context = true;
		cm:register_model_interface(event_name, context);
	end;

	-- make a list of callbacks to fire and listeners to remove. We can't call the callbacks whilst
	-- processing the list because the callbacks may alter the list length, and we can't rescan because
	-- this will continually hit persistent callbacks
	local callbacks_to_call = {};
	
	for i = 1, #self.event_listeners do
		local current_listener = self.event_listeners[i];
		
		if current_listener.event == event_name and (is_boolean(current_listener.condition) or current_listener.condition(context)) then
			table.insert(callbacks_to_call, current_listener.callback);
			
			if not current_listener.persistent then
				-- store this listener to be removed post-list
				current_listener.to_remove = true;
			end;
		end;
	end;
	
	-- clean out all the listeners that have been marked for removal
	self:clean_listeners();
	
	for i = 1, #callbacks_to_call do
		callbacks_to_call[i](context);
	end;
	
	-- notify the campaign manager that it needs to delete its context
	if __game_mode == __lib_type_campaign and is_code_context then
		cm:delete_model_interface();
	end;
end;


-- go through all the listeners and remove those with the to_remove flag set
function core_object:clean_listeners()
	for i = 1, #self.event_listeners do
		if self.event_listeners[i].to_remove then
			table.remove(self.event_listeners, i);
			-- restart
			self:clean_listeners();
			return;
		end;
	end;
end;


--- @function remove_listener
--- @desc Removes and stops any event listeners with the specified name.
--- @p string listener name
function core_object:remove_listener(name_to_remove, start_point)
	local start_point = start_point or 1;
	
	-- print("remove_listener(" .. tostring(name_to_remove) .. ", " .. tostring(start_point) .. ") called. #self.listeners is " .. tostring(#self.listeners));

	for i = start_point, #self.event_listeners do
		-- print("\tchecking listener " .. i);
		-- print("\t\tlistener name is " .. self.listeners[i].name);
		if self.event_listeners[i].name == name_to_remove then
			table.remove(self.event_listeners, i);
			--rescan
			self:remove_listener(name_to_remove, i);
			return;
		end;
	end;
end;


-- list current event listeners, for debug purposes
function core_object:list_events()
	print("**************************************");
	print("**************************************");
	print("**************************************");
	print("Event Handler attached events");
	print("**************************************");
	
	local attached_events = self.attached_events;
	for i = 1, #attached_events do
		print(i .. "\tname:\t\t" .. attached_events[i].name .. "\tcallback:" .. tostring(attached_events[i].callback));
	end;
	print("**************************************");
	print("Event Handler listeners");
	print("**************************************");
	
	local listeners = self.event_listeners;
	for i = 1, #listeners do
		local l = listeners[i];
		print(i .. ":\tname:" .. tostring(l.name) .. "\tevent:" .. tostring(l.event) .. "\tcondition:" .. tostring(l.condition) .. "\tcallback:" .. tostring(l.callback) .. "\tpersistent:" .. tostring(l.persistent));
	end;
	print("**************************************");
end;


--- @function trigger_event
--- @desc Triggers an event from script, to which event listeners will respond. An event name must be specified, as well as zero or more items of data to package up in a custom event context. See custom_context documentation for information about what types of data may be supplied with a custom context. A limitation of the implementation means that only one data item of each supported type may be specified.
--- @desc By convention, the names of events triggered from script are prepended with "ScriptEvent" e.g. "ScriptEventPlayerFactionTurnStart".
--- @p string event name
--- @p ... context data items
function core_object:trigger_event(event, ...)
	
	-- build an event context
	local context = custom_context:new();
	
	for i = 1, arg.n do
		local current_obj = arg[i];
	
		-- if this is a proper context object, pass it through directly
		if is_eventcontext(current_obj) then
		
			if arg.n > 1 then
				script_error("WARNING: trigger_event() was called with multiple objects to pass through on the event context, yet one of them was a proper event context - the rest will be discarded");
			end;
			
			context = current_obj;
			break;
		end;
	
		context:add_data(current_obj);
	end;
	
	-- trigger the event with the context
	local event_table = events[event];
	
	if event_table then
		for i = 1, #event_table do
			event_table[i](context);
		end;
	end;
end;



----------------------------------------------------------------------------
--- @section Performance Monitoring
----------------------------------------------------------------------------

--- @function monitor_performance
--- @desc Immediately calls a supplied function, and monitors how long it takes to complete. If this duration is longer than a supplied time limit a script error is thrown. A string name must also be specified for the function, for output purposes.
--- @p function function to call
--- @p number time limit in s
--- @p string name
function core_object:monitor_performance(callback, time_limit, name)
	local start_timestamp = os.clock();
	
	callback();
	
	local calltime = os.clock() - start_timestamp;
	
	if calltime > time_limit then
		script_error("PERFORMANCE WARNING: function with the following name or callstack took [" .. tostring(calltime) .. "]s to execute, exceeding its allowed time of [" .. tostring(time_limit) .. "]s:\n%%%%%%%%%%%%%%%%%%%%\n" .. tostring(name) .. "\n%%%%%%%%%%%%%%%%%%%%\n");
	end;
end;








----------------------------------------------------------------------------
---	@section Text Pointers
--- @desc Functionality to help prevent text pointers with duplicate names.
----------------------------------------------------------------------------

--- @function is_text_pointer_name_registered
--- @desc Returns true if a text pointer with the supplied name has already been registered, false otherwise.
--- @p string text pointer name
--- @return boolean has been registered
function core_object:is_text_pointer_name_registered(name)
	if self.registered_text_pointer_names[name] then
		return true;
	end;
	
	return false;
end;


--- @function register_text_pointer_name
--- @desc Registers a text pointer with the supplied name.
--- @p string text pointer name
function core_object:register_text_pointer_name(name)
	self.registered_text_pointer_names[name] = true;
	
	if not self.advice_history_reset_listener_established_for_text_pointer_names then
		self.advice_history_reset_listener_established_for_text_pointer_names = true;		
		self:add_listener(
			"advice_history_reset_listener_for_text_pointer_names",
			"AdviceCleared",
			true,
			function()
				self.registered_text_pointer_names = {};
			end,
			true		
		);
	end;
end;


--- @function hide_all_text_pointers
--- @desc Hide any @text_pointer's current visible.
--- @p string text pointer name
function core_object:hide_all_text_pointers()
	self:trigger_event("ScriptEventHideTextPointers");
end;





----------------------------------------------------------------------------
---	@section Autonumbers
----------------------------------------------------------------------------

--- @function get_unique_counter
--- @desc Retrieves a unique integer number. Each number is 1 higher than the previous unique number. Useful for scripts that need to generate unique identifiers.
--- @return integer unique number
function core_object:get_unique_counter()
	self.unique_counter = self.unique_counter + 1;
	return self.unique_counter;
end;





----------------------------------------------------------------------------
---	@section Loading Screens/UI Event Progression
----------------------------------------------------------------------------


--- @function get_loading_screen
--- @desc Returns the name and uicomponent of any detected loading screen, or <code>false</code> if one is not currently resident in the ui hierarchy (which would indicate that loading has finished).
--- @return string loading screen name
--- @return uicomponent loading screen uicomponent
function core_object:get_loading_screen()
	local ui_root = self:get_ui_root();
		
	local all_loading_screen_names = {
		"battle",
		"campaign",
		"common",
		"custom_loading_screen",
		"demo",
		"demo_postbattle",
		"demo_prebattle",
		"frontend",
		"generals_speech_battle",
		"historic_battle",
		"postbattle",
		"postbattle_campaign",
		"dynasty_mode_loading",
		"dynasty_postbattle"
	};
	
	for i = 1, #all_loading_screen_names do
		local uic = find_child_uicomponent(ui_root, all_loading_screen_names[i]);

		if uic then
			return uic:Id(), uic;
		end;
	end;

	return false;
end;


--- @function is_loading_screen_visible
--- @desc Returns the name and uicomponent of any visible loading screen, or <code>false</code> otherwise.
--- @return string loading screen name
--- @return uicomponent loading screen uicomponent
function core_object:is_loading_screen_visible()
	local uic_name, uic = self:get_loading_screen();

	if uic and uic:Visible(true) then
		return uic_name, uic;
	end;

	return false, false;
end;


--- @function progress_on_loading_screen_dismissed
--- @desc Calls the supplied callback once the loading screen has been dismissed. If no loading screen is currently visible the function throws a script error and calls the callback immediately.
--- @p function callback, Callback to call.
--- @p [opt=false] boolean suppress wait, Suppress wait for loading screen to animate offscreen.
function core_object:progress_on_loading_screen_dismissed(callback, suppress_wait_for_animation)
	
	if not is_function(callback) then
		script_error("ERROR: progress_on_loading_screen_dismissed() called but supplied callback [" .. tostring(callback) .."] is not a function");
		return false;
	end;
	
	local ui_root = self:get_ui_root();
	local loading_screen_name, uic_loading_screen = self:get_loading_screen();

	-- If we're in campaign, and the game is not yet created, then we force a wait for the LoadingScreenDismissed event.
	-- Sometimes the loading screen uicomponent cannot be found in this circumstance so we have to wait for the event instead.
	local force_wait_for_loading_screen_dismissed_in_campaign = core:is_campaign() and not cm.game_is_created;

	-- progress immediately if no loading screen was found and we're being forced to wait
	if not uic_loading_screen and not force_wait_for_loading_screen_dismissed_in_campaign then
		out("=== progress_on_loading_screen_dismissed() called but no loading screen could be found and we're not being forced to wait - progressing immediately");
		callback();
		return;
	end;
	
	-- if the loading screen is visible then wait for it to hide, otherwise progress immediately
	if force_wait_for_loading_screen_dismissed_in_campaign or uic_loading_screen:Visible(true) then
		if not force_wait_for_loading_screen_dismissed_in_campaign and uic_loading_screen:CurrentAnimationId() ~= "" then
			if suppress_wait_for_animation then
				out("=== progress_on_loading_screen_dismissed() called, loading screen with name [" .. loading_screen_name .. "] is currently animating but we're not to wait for it, proceeding immediately");
				callback();
				return;
			end;
			out("=== progress_on_loading_screen_dismissed() called, loading screen with name [" .. loading_screen_name .. "] is currently playing animation [" .. uic_loading_screen:CurrentAnimationId() .. "] - waiting for it to finish");
		
			-- loading screen is animating to hide
			self:progress_on_uicomponent_animation_finished(
				uic_loading_screen,
				function()
					out("=== progress_on_loading_screen_dismissed() - loading screen with name [" .. loading_screen_name .. "] has finished animating - trying to progress again");
					self:progress_on_loading_screen_dismissed(callback);
				end,
				true
			);
		else
			if force_wait_for_loading_screen_dismissed_in_campaign then
				out("=== progress_on_loading_screen_dismissed() called and we're being forced to wait as we're in campaign and the game is not yet created - waiting for the LoadingScreenDismissed event");
			else
				out("=== progress_on_loading_screen_dismissed() called, loading screen with name [" .. loading_screen_name .. "] is visible - waiting for it to be dismissed");
			end;
			
			core:add_listener(
				"loading_screen_dismissed",
				"LoadingScreenDismissed",
				true,
				function()
					-- re-fetch the loading screen (there's a chance we've never found it before now)
					local loading_screen_name, uic_loading_screen = self:get_loading_screen();

					if suppress_wait_for_animation then
						out("=== progress_on_loading_screen_dismissed() called, loading screen with name [" .. loading_screen_name .. "] has been dismissed and we're not to wait for it to finish animating, proceeding immediately");
						callback();
						return;
					end;
					out("=== progress_on_loading_screen_dismissed() - loading screen with name [" .. loading_screen_name .. "] has been dismissed, waiting for it to finish animating");
					
					-- loading screen is animating to hide	
					self:progress_on_uicomponent_animation_finished(
						uic_loading_screen,
						function()
							out("=== progress_on_loading_screen_dismissed() - loading screen with name [" .. loading_screen_name .. "] has finished animating, proceeding");
							callback();
						end,
						true
					)
				end,
				false
			);
		end;
	else
		out("=== progress_on_loading_screen_dismissed() called, loading screen with name [" .. loading_screen_name .. "] doesn't seem to be visible - continuing immediately");
		callback();
	end;
end;


--- @function progress_on_uicomponent_animation_finished
--- @desc Calls the supplied callback once the supplied component has finished animating. This function polls the animation state every 1/10th of a second, so there may be a slight unavoidable delay between the animation finishing and the supplied callback being called.
--- @p uicomponent uicomponent, UIComponent.
--- @p function callback, Callback to call.
--- @p boolean force wait, Force an initial wait period.
function core_object:progress_on_uicomponent_animation_finished(uicomponent, callback, force_initial_wait)	
	if not force_initial_wait and uicomponent:CurrentAnimationId() == "" then
		if self:is_campaign() then -- Wait for model access for the campaign.
			if cm:is_multiplayer() then
				callback();
			else
				cm:wait_for_model_sp(callback);
			end;
		else
			callback();
		end;
	else
		if self:is_campaign() then
			cm:wait_for_model_sp(function() cm:callback(function() self:progress_on_uicomponent_animation_finished(uicomponent, callback) end, 0.1) end);
		else
			get_tm():callback(function() self:progress_on_uicomponent_animation_finished(uicomponent, callback) end, 100, "progress_on_uicomponent_animation_finished");
		end;
	end;
end;







----------------------------------------------------------------------------
---	@section Caching/Restoring UIComponent Tooltips
----------------------------------------------------------------------------

--- @function cache_and_set_tooltip_for_component_state
--- @desc Caches and sets the tooltip for a particular state of a component. Once cached, the tooltip may be restored with <code>restore_tooltip_for_component_state</code>. This is used by tutorial scripts that overwrite the tooltip state of certain UIComponents.
--- @desc The tooltip text key should be supplied in the common localised text format <code>[table]_[field_of_text]_[key_from_table]</code>.
--- @p uicomponent subject uicomponent
--- @p string state name
--- @p string text key
function core_object:cache_and_set_tooltip_for_component_state(uic, state, new_tooltip)
	
	if not is_uicomponent(uic) then
		script_error("ERROR: cache_and_set_tooltip_for_component_state() called but supplied uicomponent [" .. tostring(uic) .. "] is not a uicomponent");
		return false;
	end;
	
	if not is_string(state) then
		script_error("ERROR: cache_and_set_tooltip_for_component_state() called but supplied state [" .. tostring(state) .. "] is not a string");
		return false;
	end;
	
	if not is_string(new_tooltip) then
		script_error("ERROR: cache_and_set_tooltip_for_component_state() called but supplied new tooltip [" .. tostring(new_tooltip) .. "] is not a string");
		return false;
	end;
	
	local uic_str = uicomponent_to_str(uic);
	
	-- out("** cache_and_set_tooltip_for_component_state() called, uic_str is " .. uic_str .. ", state is " .. state);	
	
	-- create a table for this uic if we don't already have one
	if not self.cached_tooltips_for_component_states[uic_str] then
		self.cached_tooltips_for_component_states[uic_str] = {};
	end;
	
	-- cache the current uic state, and set it into the target state
	local cached_state = uic:CurrentState();
	uic:SetState(state);
	
	-- cache the target state tooltip
	self.cached_tooltips_for_component_states[uic_str][state] = uic:GetTooltipText();
	
	-- set the tooltip of the target state
	uic:SetTooltipText(effect.get_localised_string(new_tooltip), false);
	
	-- set the uic back to the state it was in
	uic:SetState(cached_state);
end;


--- @function restore_tooltip_for_component_state
--- @desc Restores a tooltip for a uicomponent state that's been previously modified with <code>cache_and_set_tooltip_for_component_state</code>.
--- @p uicomponent subject uicomponent
--- @p string state name
function core_object:restore_tooltip_for_component_state(uic, state)

	if not is_uicomponent(uic) then
		script_error("ERROR: restore_tooltip_for_component_state() called but supplied uicomponent [" .. tostring(uic) .. "] is not a uicomponent");
		return false;
	end;
	
	if not is_string(state) then
		script_error("ERROR: restore_tooltip_for_component_state() called but supplied state [" .. tostring(state) .. "] is not a string");
		return false;
	end;
	
	local uic_str = uicomponent_to_str(uic);
	
	-- out("** restore_tooltip_for_component_state() called, uic_str is " .. uic_str .. ", state is " .. state);

	local cached_tooltips_for_component = self.cached_tooltips_for_component_states[uic_str];
	if not cached_tooltips_for_component then
		out("\tcached_tooltips_for_component doesn't exist, exiting");
		return false;
	end;
	
	local cached_state_text = cached_tooltips_for_component[state];
	if not is_string(cached_state_text) then
		out("\tcached_state_text is [" .. tostring(cached_state_text) .. "], exiting");
		return false;
	end;
	
	-- cache the current uic state, and set it into the target state
	local cached_state = uic:CurrentState();
	uic:SetState(state);
	
	-- set the state tooltip back to its cached value
	uic:SetTooltipText(cached_state_text, false);
	
	-- set the component back to its cached state
	uic:SetState(cached_state);
end;









----------------------------------------------------------------------------
---	@section Localised Text Tags
----------------------------------------------------------------------------

core_object.localised_text_tags = {
	{
		start_tag = "[[",
		end_tag = "]]"
	},
	{
		start_tag = "{{",
		end_tag = "}}"
	}
};


--- @function strip_tags_from_localised_text
--- @desc Strips any tags out of a localised text string. Tags stripped are "[[ .. ]]" and "{{ .. }}".
--- @p string text
--- @return string stripped text
function core_object:strip_tags_from_localised_text(localised_text)
	
	local localised_text_tags = self.localised_text_tags;
	
	for i = 1, #localised_text_tags do
		start_tag = selocalised_text_tags[i].start_tag;
		end_tag = localised_text_tags[i].end_tag;

		local still_searching = true;

		while still_searching do
			local start_pos = string.find(localised_text, start_tag, 1);
			-- local start_pos = string.find(localised_text, start_tag, 1, true);	-- uncomment if we move to a later version of lua
			
			if start_pos then
			
				local junk, end_pos = string.find(localised_text, end_tag, start_pos);
				-- local junk, end_pos = string.find(localised_text, end_tag, start_pos, true);		-- uncomment if we move to a later version of lua

				if end_pos then
					localised_text = string.sub(localised_text, 1, start_pos - 1) .. string.sub(localised_text, end_pos + 1);
				else
					still_searching = false;
				end;
			else
				still_searching = false;
			end;
		end;
	end;

	return localised_text;
end;









----------------------------------------------------------------------------
---	@section Bit Checking
----------------------------------------------------------------------------


--- @function check_bit
--- @desc Takes a number value and a numeric bit position. Returns true if the bit at the numeric bit position would be a '1' were the number value converted to binary, false otherwise.
--- @p number subject value
--- @p integer bit position
--- @return boolean bit value
function check_bit(test_value, bit_position)

	if not is_number(test_value) or test_value < 0 then
		script_error("ERROR: check_bit() called but supplied test value [" .. tostring(test_value) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(bit_position) or bit_position < 0 then
		script_error("ERROR: check_bit() called but supplied bit position [" .. tostring(bit_position) .. "] is not a positive number");
		return false;
	end;

	-- work out how many bits are in our supplied test value
	local num_bits = 0;
	while true do
		if num_bits ^ 2 > test_value then
			break;
		end;
		num_bits = num_bits + 1;
	end;
	
	
	-- if the bit position is greater than the number of bits needed to represent our number, return false
	if bit_position > num_bits then
		return false;
	end;
	
	-- determine whether the value at the given bit position would be a 1 or 0 by working backwards through test value
	local working_value = test_value;
	
	for i = num_bits, 0, -1 do
		local current_bit_dec_value = 2 ^ (i - 1);
	
		if working_value >= current_bit_dec_value then
		
			if bit_position == i then
				return true;
			end;
			
			working_value = working_value - current_bit_dec_value;
		else
			if bit_position == i then
				return false;
			end;
		end;
	end;
	
	return false;
end;









----------------------------------------------------------------------------
---	@section Static Object Registry
----------------------------------------------------------------------------


--- @function add_static_object
--- @desc Registers a static object by a string name, which can be retrieved later with @core_object:get_static_object. This is intended for use as a registry of global static objects (objects of which there should only be one copy) such as @battle_manager, @campaign_manager, @timer_manager, @script_messager, @generated_battle and so-on. Scripts that intended to create one of these objects can query the static object registry to see if they've been created before and, if not, can register it.
--- @p string object name
--- @p object object to register
--- @p [opt=false] boolean overwrite
function core_object:add_static_object(name, object, overwrite)

	if not is_string(name) then
		script_error("ERROR: add_static_object() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;

	if not overwrite and self:get_static_object(name) then
		script_error("ERROR: add_static_object() called but static object with supplied name [" .. name .. "] is already registered, and overwrite flag is not set");
		return false;
	end;

	self.static_objects[name] = object;
end;



--- @function get_static_object
--- @desc Returns the static object registered with the supplied string name using @core_object:add_static_object, if any such object has been registered, otherwise it returns nil.
function core_object:get_static_object(name)
	return self.static_objects[name];
end;




















----------------------------------------------------------------------------
----------------------------------------------------------------------------
--- @class custom_context Custom Context
--- @page core_object
--- @desc A custom context is created when the core object is compelled to trigger an event with <code>trigger_event</code>. Data items supplied to <code>trigger_event</code> are added to the custom context, which is then sent to any script listening for the event being triggered.
--- @desc The receiving script should then be able to interrogate the custom context it receives as if it were a context issued from the game code.
--- @desc No script outside of <code>trigger_event</code> should need to create a custom context, but it's documented here in order to list the data types it supports.
----------------------------------------------------------------------------
----------------------------------------------------------------------------

custom_context = {};

--- @function new
--- @desc Creates a custom context object.
--- @return custom_context
function custom_context:new()
	local cc = {};
	setmetatable(cc, self);
	self.__index = self;	
	
	return cc;
end;


--- @function add_data
--- @desc adds data to the custom context object. Supported data types:
--- @desc &emsp;string: will be accessible to the receiving script as <code>context.string</code>
--- @desc &emsp;region: will be accessible to the receiving script using <code>context:region()</code>
--- @desc &emsp;character: will be accessible to the receiving script using <code>context:character()</code>
--- @desc &emsp;faction: will be accessible to the receiving script using <code>context:faction()</code>
--- @desc &emsp;component: will be accessible to the receiving script using <code>context:component()</code>
--- @desc &emsp;military_force: will be accessible to the receiving script using <code>context:military_force()</code>
--- @desc &emsp;pending_battle: will be accessible to the receiving script using <code>context:pending_battle()</code>
--- @desc &emsp;garrison_residence: will be accessible to the receiving script using <code>context:garrison_residence()</code>
--- @desc &emsp;building: will be accessible to the receiving script using <code>context:building()</code>
--- @desc A limitation of the implementation is that only one object of each type may be placed on the custom context.
--- @p object context data, Data object to add
function custom_context:add_data(obj)
	if is_string(obj) then
		self.string = obj;
	elseif is_query_region(obj) then
		self.region_data = obj;
	elseif is_query_character(obj) then
		self.character_data = obj;
	elseif is_query_faction(obj) then
		self.faction_data = obj;
	elseif is_component(obj) then
		self.component_data = obj;
	elseif is_query_military_force(obj) then
		self.military_force_data = obj;
	elseif is_query_pending_battle(obj) then
		self.pending_battle_data = obj;
	elseif is_query_garrison_residence(obj) then
		self.garrison_residence_data = obj;
	elseif is_building(obj) then
		self.building_data = obj;
	elseif is_table(obj) then
		self.environment_data = obj;
	else
		script_error("ERROR: adding data to custom context but couldn't recognise data [" .. tostring(obj) .. "] of type [" .. type(obj) .. "]");
	end;	
end;


--- @function region
--- @desc Called by the receiving script to retrieve the region object placed on the custom context, were one specified by the script that created it.
--- @return region region object
function custom_context:region()
	return self.region_data;
end;


--- @function character
--- @desc Called by the receiving script to retrieve the character object placed on the custom context, were one specified by the script that created it.
--- @return character character object
function custom_context:character()
	return self.character_data;
end;


--- @function faction
--- @desc Called by the receiving script to retrieve the faction object placed on the custom context, were one specified by the script that created it.
--- @return faction faction object
function custom_context:faction()
	return self.faction_data;
end;


--- @function component
--- @desc Called by the receiving script to retrieve the component object placed on the custom context, were one specified by the script that created it.
--- @return component component object
function custom_context:component()
	return self.component_data;
end;


--- @function military_force
--- @desc Called by the receiving script to retrieve the military force object placed on the custom context, were one specified by the script that created it.
--- @return military_force military force object
function custom_context:military_force()
	return self.military_force_data;
end;


--- @function pending_battle
--- @desc Called by the receiving script to retrieve the pending battle object placed on the custom context, were one specified by the script that created it.
--- @return pending_battle pending battle object
function custom_context:pending_battle()
	return self.pending_battle_data;
end;


--- @function garrison_residence
--- @desc Called by the receiving script to retrieve the garrison residence object placed on the custom context, were one specified by the script that created it.
--- @return garrison_residence garrison residence object
function custom_context:garrison_residence()
	return self.garrison_residence_data;
end;


--- @function building
--- @desc Called by the receiving script to retrieve the building object placed on the custom context, were one specified by the script that created it.
--- @return building building object
function custom_context:building()
	return self.building_data;
end;


--- @function environment
--- @desc Called by the receiving script to retrieve the game environment object placed on the custom context, were one specified by the script that created it.
--- @return table game environment
function custom_context:environment()
	return self.environment_data;
end;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
--- @class cli_listeners CLI Listeners
--- @page core_object
--- @desc A CLI Listener is a wrapper around the campign CLIDebugEvent which allows scripters to pass and take arguments into debug functions.
--- @desc They register a unique 'message' string and a callback function which can take a number of args. Should be formed as 'function_name(...)', accessed as 'arg[i]'
----------------------------------------------------------------------------
----------------------------------------------------------------------------

--- @function add_cli_listener
--- @desc Called by scripts to register a listener.
function core_object:add_cli_listener(event_key, callback)
	output("cli_listener(): Adding Listener " .. event_key);

    if not is_string(event_key) then
        script_error("ERROR: add_cli_listener() Tried to create debug listener, but [" .. tostring(event_key) .. "] is not a string.");
		return false;
    end;
    
    if self:cli_listener_exists(event_key) then
        script_error(" ERROR: add_cli_listener() called but supplied message [" .. tostring(event_key) .. "] is already registered.");
        return false;
	end;
	
    if not is_function(callback) then
		script_error(" ERROR: add_cli_listener() called but supplied callback [" .. tostring(callback) .. "] is not a function.");
		return false;
    end;

    table.insert(self.cli_listeners, {event_key, callback});
end;

--- @function initialise_cli_listeners
--- @desc setup script which contains the core listener and passed out the callbacks as args.
--- @desc This system expects a CLI format of event_key(param,param,param) with NO SPACES.
function core_object:initialise_cli_listeners()
    output("cli_listener(): initialise()");
	
    self:add_listener(
        "debug_manager", -- UID
        "CliDebugEvent", -- CampaignEvent
        true, --Conditions for firing
        function(event)
			--CliDebugEvent
			local event_parameter = event:parameter();

			local event_key = "";
			local args_list = {};

			-- Check if we have arguments.
			if string.match(event_parameter, "%(") then -- Check if there is an opening parenthesis in the string.
				if not string.match(event_parameter, "%)") then -- If there is not a closing parenthesis, then error.
					script_error(" ERROR: cli_listener() an opening parenthesis was passed in, but no closing one. Did you forget it or add a space (unsupported)?" )
					return;
				end;

				-- Get the message.
				event_key = string.match(event_parameter, "(.+)%(") -- Look only for letters, when we hit an opening parenthesis, stop looking.
				
				-- Get the parameters.
				local remaining_params = string.match(event_parameter, "%((.-)%)");
				for value in string.gmatch(remaining_params, "[^,%s]+") do -- A Comma
					table.insert(args_list, value);
				end;

			else
				-- We don't have arguments, can just pass the string.
				event_key = event_parameter;
			end;
		
			-- Check if event exists
			if not self:cli_listener_exists(event_key) then
				script_error(" ERROR: cli_listener() called but supplied message [" .. tostring(event_key) .. "] does not exist.");
        		return false;
			end;

			-- Go through all our messages and add the parameters.
			local callback = self:get_cli_listener_callback(event_key);
			
			if not is_function(callback) then
				script_error(" ERROR: cli_listener() called but supplied callback [" .. tostring(callback) .. "] is not a function.");
        		return false;
			end; 
			output("cli_listener: Calling " .. event_key .. " with " .. #args_list .. " argument(s) " .. table.concat(args_list, ", ") );

			-- Pass through our args if we had any left.
			if #args_list > 0 then
				if #args_list == 1 then
					callback(args_list[1]);
				elseif #args_list == 2 then
					callback(args_list[1], args_list[2]);
				elseif #args_list == 3 then
					callback(args_list[1], args_list[2], args_list[3]);
				elseif #args_list == 4 then
					callback(args_list[1], args_list[2], args_list[3], args_list[4]);
				elseif #args_list == 5 then
					callback(args_list[1], args_list[2], args_list[3], args_list[4], args_list[5]);
				end;
			else
				callback();
			end;
        end, -- Function to fire.
        true -- Is Persistent?
	);
	
	-- GENERIC DEBUG EVENTS.
	self:add_cli_listener("cli_test_event", function(param1, param2, param3) output("Event Fired" .. tostring(param1), tostring(param2), tostring(param3)) end );
	self:add_cli_listener("help", 
		function()  
			output("cli_listener: Outputting all listeners:");
			output("*********");
			inc_tab();
			for i, v in ipairs(self.cli_listeners) do
				output( tostring( v[1] ) ); -- Output the name of the event.
			end;
			dec_tab();
			output("*********");
		end
	)
end;

--- @function cli_listener_exists
--- @desc Checks if we've registered that cli listener name already.
function core_object:cli_listener_exists(listener_name)
	if not is_string(listener_name) then
        script_error("ERROR: cli_listener_exists() [" .. tostring(listener_name) .. "] is not a string.");
		return true;
	end;

	if #self.cli_listeners < 1 then
		return false;
	end;

    for i, listener in ipairs(self.cli_listeners) do
        if listener[1] == listener_name then
            return true;
        end;
    end;

    return false;
end;

--- @function get_cli_listener_callback
--- @desc Returns the cli callback for the specified message
function core_object:get_cli_listener_callback(listener_name)
	if #self.cli_listeners < 1 then
		script_error("ERROR: get_cli_listener_callback() [" .. tostring(listener_name) .. "] We have no listeners.");
		return false;
	end;

    for i, listener in ipairs(self.cli_listeners) do
        if listener[1] == listener_name then
            return listener[2];
        end;
    end;

    return false;
end;