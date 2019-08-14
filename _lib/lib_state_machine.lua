----------------------------------------------------------------------------
--- @section State Manager
--- @desc This is an independent object which can be used in scripts where transitions between states are important (quests, tutorials, etc).
--- @desc Must be created using new() and then start() after registering some states via add_state().
----------------------------------------------------------------------------

__state_machine = nil;

state_machine = {
	name = "state_machine",
	is_battle = true,
	has_started = false, -- Saved.
	is_destroyed = false, -- Saved.
	current_state_name = ""; -- Saved.
	current_state_data = nil,
	previous_state_name = "", -- Saved.
	initial_state_string = nil,
	state_datas = {},
	on_start_callback = nil;
};




--[[
************************************************************************************************************
************************************************************************************************************
	Initialiser
************************************************************************************************************
************************************************************************************************************
]]--



--- @function new
--- @desc Create a new State Machine which must be held locally. This is required before any states can be added, etc.
--- @p string The unique id for the machine. Used to add/remove listeners.
--- @p string The initial state key of the machine.
--- @p bool Is this for battle?.
--- @p function a function to call when this state manager is started or restarted.
function state_machine:new(machine_name, initial_state_key, is_battle_script, on_start_callback)
	is_battle_script = is_battle_script or false;

	out.design( "STATE MACHINE: " .. tostring(self.name) .. ": Creating new state machine" );

	if not is_string( machine_name ) then
		script_error("ERROR: new() machine_name must be a string.");
		return false;
	end;

	if not is_string( initial_state_key ) then
		script_error("ERROR: new() Initial state key must be a string.");
		return false;
	end;

	if on_start_callback and not is_function(on_start_callback) then
		script_error("ERROR: new() on_start_callback must be a function or nil.");
		return false;
	end;

	local sm = {};

	setmetatable(sm, self);
	self.__tostring = function() return TYPE_STATE_MACHINE end;
	self.__index = self;

	sm.name = machine_name;
	sm.is_battle = is_battle_script;
	sm.has_started = false;
	sm.current_state_name = nil;
	sm.current_state_data = nil;
	sm.previous_state_name = nil;
	sm.initial_state_string = initial_state_key;
	sm.state_datas = {};
	sm.on_start_callback = on_start_callback;

	return sm;
end;



--[[
************************************************************************************************************
************************************************************************************************************
	Core functions
************************************************************************************************************
************************************************************************************************************
]]--



--- @function add_state
--- @desc Create a new State for the State Machine.
--- @p string The unique id for the state. Used to add/remove listeners.
--- @p function Called when entering the state.
--- @p function If an update is registered will call this at set intervals.
--- @p function A function to call when exiting the state.
--- @p string the state we should go to if we save/load at this point.
function state_machine:add_state( name, enter_callback, exit_callback, opt_load_state )

	if not is_string( name ) then 
		script_error("ERROR: add_state() Invalid string");
		return;
	end;

	--out.design( "STATE MACHINE: " .. tostring(self.name) .. ": adding state: " .. tostring(name) );

	if enter_callback and not is_function( enter_callback ) then 
		script_error("ERROR: add_state() Invalid enter_callback");
		return;
	end;

	if exit_callback and not is_function( exit_callback ) then 
		script_error("ERROR: add_state() Invalid on_exit_callback");
		return;
	end;

	if self:state_exists( name ) then
		script_error( "ERROR: add_state() Attempting to add a state which already exists " .. tostring(name) );
		return;
	end;

	opt_load_state = opt_load_state or name;

	table.insert(self.state_datas, 
		{
			name = name,
			on_enter_callback = enter_callback,
			on_exit_callback = exit_callback,
			load_state = opt_load_state
		}
	);
end;


--- @function start
--- @desc Kicks off the state machine.
function state_machine:start()

	if #self.state_datas < 1 then
		script_error("No states!");
		return;
	end;

	if self:get_state_data( self.initial_state_string ) and self.on_start_callback then
		self:on_start_callback();
	end;

	-- Trigger our initial state.
	if not self:change_to( self.initial_state_string ) then
		script_error("Initial state data key not registered. " .. tostring( self.initial_state_string) );
		return false;
	end;

	out.design( "STATE MACHINE: " .. tostring(self.name) .. ": Starting State Machine with state " .. tostring(self.current_state_data.name) .. " num states = " .. #self.state_datas);

	-- Register that we've started.
	self.has_started = true;
end;

function state_machine:restart()

	if #self.state_datas < 1 then
		script_error("No states!");
		return;
	end;

	if not self.current_state_name then
		script_error("ERROR: State Machine retarted with no current state. This shouldn't happen.");
		return;
	end;

	if self:get_state_data( self.current_state_name ) and self.on_start_callback then
		self:on_start_callback();
	end;

	-- Trigger our initial state.
	if not self:change_to( self.current_state_name ) then
		script_error("Initial state data key not registered. " .. tostring( self.current_state_name ) );
		return false;
	end;

	out.design( "STATE MACHINE: " .. tostring(self.name) .. ": Restarting State Machine in state " .. tostring(self.current_state_data.name) .. " num states = " .. #self.state_datas);
end;

--- @function change_to
--- @desc Move from one state to the next (if valid), calling the Exit and Entry functions of the states respectively.
--- @p string The key of the state to change to.
function state_machine:change_to( new_state_name )
	
	local new_state_data = self:get_state_data( new_state_name ); -- Try to get the data matching the state_name.

	if not new_state_data then
		script_error( "ERROR: change_to() New State Data is invalid or missing" );
		return false;
	end;

	if self.current_state_data then
		if new_state_data.name == self.current_state_data.name then
			script_error( "ERROR: change_to() Trying to change to the current state!" );
			return false;
		end;

		self.previous_state_name = self.current_state_name; -- Set the previous state, which is used for re-entrancy checking.

		-- If we have an exit callback on our current state, call it.
		if self.current_state_data.on_exit_callback then
			self.current_state_data.on_exit_callback();
		end;

		-- Exit state internal, which clears registered listeners/callbacks/etc.
		self:internal_exit_state();

		out.design( "STATE MACHINE: " .. tostring(self.name) .. ": Changing state from " .. tostring(self.current_state_data.name) .. " to " .. tostring(new_state_data.name) );
	else
		out.design( "STATE MACHINE: " .. tostring(self.name) .. ": Setting first state to " .. tostring(new_state_data.name) );
	end;

	-- Set up our new current state.
	self.current_state_data = new_state_data;
	self.current_state_name = self.current_state_data.name;
	
	-- Call the onenter callback
	if self.current_state_data.on_enter_callback then
		self.current_state_data.on_enter_callback();
	end;

	return true;
end;


-- @function internal_exit_state
-- @desc INTERNAL Fired whenever state exits, clears out anything the state machine has added.
function state_machine:internal_exit_state()

	local listener_name = self:get_listener_name()

	if not is_string(listener_name) then
		script_error("ERROR: lib_state_machine - Trying to change to a listener name without a string.")
	end;

	if self.is_battle then
		local bm = get_bm();
		core:remove_listener( listener_name );
		bm:remove_process( listener_name ); -- Removes watches AND callbacks
	else
		local cm = get_cm();
		core:remove_listener( listener_name );
		cm:wait_for_model_sp(
			function() cm:remove_callback( listener_name ) end
		);

	end;
end;


--- @function destroy
--- @desc Removes the state machine and clears all states and listeners.
function state_machine:destroy()
	-- Call the state's internal exit function.
	if self.current_state_data.on_exit_callback then
		self.current_state_data.on_exit_callback();
	end;

	-- Call our internal exit, which remove listeners.
	self:internal_exit_state();

	-- Remove any Global listeners we have.
	local global_listener_name = self.name;

	if self.is_battle then
		local bm = get_bm();
		core:remove_listener( global_listener_name );
	else
		local cm = get_cm();
		core:remove_listener( global_listener_name );
	end;


	-- Nil out data.
	self.state_datas = nil;
	self.current_state_data = nil;
	self.is_destroyed = true;
end;



--[[
************************************************************************************************************
************************************************************************************************************
	STATE CHANGE LISTENERS
************************************************************************************************************
************************************************************************************************************
]]--



-- @function state_change_callback
-- @desc Adds a callback which will transition to a specific state when hit.
-- @p string the next state to move to.
-- @p number How long in m/s till we fire our callback.
function state_machine:state_change_callback( next_state, duration )

	if not is_string(next_state) then
		script_error( "ERROR: state_change_callback() next_state isn't a string" );
		return false;
	end;

	if not is_number(duration) then
		script_error( "ERROR: state_change_callback() duration isn't a number" );
		return false;
	end;

	if not self:state_exists( next_state ) then
		script_error( "ERROR: state_change_callback() next state is invalid." .. tostring(next_state) );
		return false;
	end;

	local listener_name = self:get_listener_name()

	if self.is_battle then
		local bm = get_bm();
		bm:callback(
			function() self:change_to( next_state ) end,
			duration,
			listener_name
		);
	else
		local cm = get_cm();

		-- We need to wait for the model to be available.
		if cm:can_modify(true) then
			cm:callback(
				function() self:change_to( next_state ) end,
				duration,
				listener_name
			);
		else
			cm:wait_for_model_sp(function() 
				cm:callback(
					function() self:change_to( next_state ) end,
					duration,
					listener_name
				)
			end);
		end;
	end;
end;


-- @function global_state_change_listener
-- @desc Adds a listener which will transition to a specific state when hit. Will NEVER be removed.
-- @p string the next state to move to.
-- @p string The event we're listening for.
-- @p function The function to fire for the listener. Can take an optional context.
function state_machine:global_state_change_listener(next_state, listener_event, listener_condition, is_persistent )
	self:impl_state_change_listener(self.name, next_state, listener_event, listener_condition, is_persistent )
end;


-- @function state_change_listener
-- @desc Adds a listener which will transition to a specific state when hit. Will be removed when its current state is left (due to the name).
-- @p string the next state to move to.
-- @p string The event we're listening for.
-- @p function The function to fire for the listener. Can take an optional context.
function state_machine:state_change_listener( next_state, listener_event, listener_condition )
	self:impl_state_change_listener(self:get_listener_name(), next_state, listener_event, listener_condition, false )
end;


-- @function internal_state_change_listener
-- @desc Internal use only. Adds a listener which will transition to a specific state when hit.
-- @p string the name of the listener.
-- @p string the next state to move to.
-- @p string The event we're listening for.
-- @p function The function to fire for the listener. Can take an optional context.
function state_machine:impl_state_change_listener( listener_name, next_state, listener_event, listener_condition, is_persistent )
	if not is_string(listener_name) then
		script_error( "ERROR: state_change_listener() listener_name isn't a string" );
		return false;
	end;
	
	if not is_string(next_state) then
		script_error( "ERROR: state_change_listener() next_state isn't a string" );
		return false;
	end;

	if not is_string(listener_event) then
		script_error( "ERROR: state_change_listener() listener_event isn't a string" );
		return false;
	end;

	if not is_function(listener_condition) then
		script_error( "ERROR: state_change_listener() listener_condition isn't a function" );
		return false;
	end;

	if not self:state_exists( next_state ) then
		script_error( "ERROR: state_change_listener() next state is invalid." .. tostring(next_state) );
		return false;
	end;

	if self.is_battle then
		core:add_listener(
			listener_name,
			listener_event,
			listener_condition,
			function() self:change_to( next_state ) end,
			is_persistent
		);
	else
		core:add_listener(
			listener_name,
			listener_event,
			listener_condition,
			function() self:change_to( next_state ) end,
			is_persistent
		);
	end;
end;


-- @function state_change_watch
-- @desc Adds a watch which will transition to a specific state when hit.
-- @p string the next state to move to.
-- @p function The function to watch for.
function state_machine:state_change_watch( next_state, condition, opt_update_time )
	opt_update_time = opt_update_time or 500;

	if not is_string(next_state) then
		script_error( "ERROR: state_change_watch() next_state isn't a string" );
		return false;
	end;

	if not is_function(condition) then
		script_error( "ERROR: state_change_watch() condition isn't a function" );
		return false;
	end;

	if not self:state_exists( next_state ) then
		script_error( "ERROR: state_change_watch() next state is invalid." .. tostring(next_state) );
		return false;
	end;

	local listener_name = self:get_listener_name();

	if self.is_battle then
		local bm = get_bm();
		bm:watch(
			condition,
			opt_update_time,
			function() self:change_to( next_state ) end,
			listener_name
		);
	else
		script_error("ERROR: state_change_watch() Watches are not allowed in campaign.")
	end;
end;



--[[
************************************************************************************************************
************************************************************************************************************
	HELPERS
************************************************************************************************************
************************************************************************************************************
]]--



-- @function get_listener_name
-- @desc Generates the name for a listener, which can be safely used in in its current state.
function state_machine:get_listener_name()
	if not self.current_state_data or not self.name then
		script_error("ERROR: get_listener_name() called when we don't have a state!");
		return false;
	end;

	return self.name .. self.current_state_data.name;
end;


--- @function get_state_data
--- @desc Gets the state data for the specified state.
--- @p string The unique id for the state.
function state_machine:get_state_data( state_name )

	if not self.state_datas or #self.state_datas < 1 then
		script_error("ERROR: get_state_data() No state datas available");
		return false;
	end;

	for i, state_data in ipairs( self.state_datas ) do
		if state_data.name == state_name then
			return state_data;
		end;
	end;

	return false;
end;


-- @function get_state_index
-- @desc Gets where in the array the state is added. Relies somewhat on them being inserted in a set order.
-- @p string the name of the state
function state_machine:get_state_index(state_name)
	if not self.state_datas or #self.state_datas < 1 then
		script_error("ERROR: get_state_index() No state datas available");
		return false;
	end;

	for i, state_data in ipairs( self.state_datas ) do
		if state_data.name == state_name then
			return i;
		end;
	end;

	return -1;
end;


--- @function state_exists
--- @desc Gets whether or not a state with the specified name exists.
--- @p string The unique id for the state.
function state_machine:state_exists( state_name )

	if not self.state_datas or #self.state_datas < 1 then
		return false;
	end;

	for i, state_data in ipairs( self.state_datas ) do
		if state_data.name == state_name then
			return true;
		end;
	end;

	return false;
end;



--[[
************************************************************************************************************
************************************************************************************************************
	SAVE/LOAD
************************************************************************************************************
************************************************************************************************************
]]--


--- @function save
--- @desc Saves the statemachine states.
function state_machine:save()
	cm:set_saved_value("has_started", self.has_started, "state_machine", self.name);
	cm:set_saved_value("is_destroyed", self.is_destroyed, "state_machine", self.name);
	cm:set_saved_value("current_state_name", self.current_state_data.load_state, "state_machine", self.name);
	cm:set_saved_value("previous_state_name", self.previous_state_name, "state_machine", self.name);
end;

--- @function load
--- @desc Loads the state machine.
function state_machine:load()
	self.has_started = cm:get_saved_value("has_started", "state_machine", self.name);
	self.is_destroyed = cm:get_saved_value("is_destroyed", "state_machine", self.name);
	self.current_state_name = cm:get_saved_value("current_state_name", "state_machine", self.name);
	self.previous_state_name = cm:get_saved_value("previous_state_name", "state_machine", self.name);
end;

