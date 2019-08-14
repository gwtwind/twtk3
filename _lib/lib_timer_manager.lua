

---------------------------------------------------------------
--
-- Timestamp maintenance
--
---------------------------------------------------------------

timestamp_tick = 0;

function tick_increment_counter()
	if core:is_battle() then
		timestamp_tick = timestamp_tick + get_bm():model_tick_time_ms();
	else
		timestamp_tick = timestamp_tick + 100;
	end;
end;





----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	TIMER MANAGER
--
--- @loaded_in_battle
--- @loaded_in_frontend
---	@class timer_manager Timer Manager
--- @desc The timer manager object provides library support for calling functions with a time offset i.e. waiting a period before calling a function. It is loaded in battle and the frontend.
--- @desc It is rare for battle scripts to need to talk directly to the timer manager as the battle manager automatically creates a timer manager and provides a pass-through interface for the most-commonly-used timer manager functionality.
--- @desc Direct access to the timer manager might be more useful for frontend scripts, but they are rarer in themselves.
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


__timer_manager = nil;

timer_manager = {
	timer_obj = nil,
	callback_list = {},
	timer_list = {},
	singleshot_timer = nil,
	repeat_timer = nil,
	unregister_timer = nil,
	callback_leeway = 50
};





----------------------------------------------------------------------------
--- @section Creation
----------------------------------------------------------------------------


--- @function new
--- @desc Creates a timer_manager object. It is unnecessary for battle scripts to call this as one is created automatically by the battle manager, and stored internally.
--- @return timer_manager
function timer_manager:new(tick_time_ms)
	if __timer_manager then
		return __timer_manager;
	end;
	
	tick_time_ms = tick_time_ms or 100;

	tm = {};
	
	setmetatable(tm, self);
	self.__tostring = function() return TYPE_TIMER_MANAGER end;
	self.__index = self;
	
	tm.callback_list = {};
	tm.timer_list = {};

	if __game_mode == __lib_type_battle then
		local bm = get_bm();
		
		tm.singleshot_timer = function(name, t) bm.battle:register_singleshot_timer(name, t) end;
		tm.repeat_timer = function(name, t) bm.battle:register_repeating_timer(name, t) end;
		tm.cancel_timer = function(name) bm.battle:unregister_timer(name) end;
	
	elseif __game_mode == __lib_type_frontend then
		if not Timers then
			script_error("ERROR: tried to create a timer_manager but Timers object does not exist");
			return false;
		end;
		
		-- don't know why this is different
		tm.callback_leeway = 250;
		
		tm.singleshot_timer = function(name, t) Timers.register_singleshot(name, t) end;
		tm.repeat_timer = function(name, t) Timers.register_repeating(name, t) end;
		tm.cancel_timer = function(name) Timers.unregister(name) end;
	
	else
		script_error("ERROR: timer_manager created in campaign, we don't support this!");
		return;
	end;
	
	tm:register_repeating_timer("tick_increment_counter", tick_time_ms);

	__timer_manager = tm;
		
	return tm;
end;






--- @end_class
--- @section Timer Manager

--- @function get_tm
--- @desc Gets or creates a @timer_manager.
--- @return timer manager
function get_tm()
	return timer_manager:new();
end;








----------------------------------------------------------------------------
--- @class timer_manager Timer Manager
--- @section Callbacks
----------------------------------------------------------------------------


--- @function callback
--- @desc Instructs the timer manager to call a supplied function after a supplied delay. A string name for the callback may also be supplied with which the callback may be later cancelled using @timer_manager:remove_callback (note that in battle it's much more common to use @battle_manager:remove_process).
--- @p function callback to call
--- @p number delay in ms
--- @p [opt=nil] string callback name
function timer_manager:callback(new_callback, new_time_offset, new_entryname)
	if not is_function(new_callback) then
		script_error("ERROR: timer_manager:callback() called but supplied callback " .. tostring(new_callback) .. " is not a function");
		return false;
	end;
	
	if not is_number(new_time_offset) or new_time_offset < 0 then
		script_error("ERROR: timer_manager:callback() called but offset " .. tostring(new_time_offset) .. " is not a positive number");
		return false;
	end;
	
	-- call the callback immediately if the supplied time offset is 0
	if new_time_offset == 0 then
		new_callback();
		return;
	end;
	
	local new_entryname = new_entryname or "";
	local new_calltime = new_time_offset + timestamp_tick;
		
	local new_callback_entry = {
		callback = new_callback, 
		calltime = new_calltime, 
		entryname = new_entryname
	};
	
	-- determine where to insert this callback in the list
	if #self.callback_list == 0 then
		-- callback list is empty, insert this new one at the start of the list and kick the mechanism off
		table.insert(self.callback_list, 1, new_callback_entry);
		
		self:unregister_timer("timer_manager_tick_callback");
		self:register_singleshot_timer("timer_manager_tick_callback", new_time_offset);
		
		return true;
	else
		-- go through the callback list in order and see where to put this new callback
		-- callback list is arranged in chronological order
		for i = 1, #self.callback_list do
			if self.callback_list[i].calltime > new_calltime then			
				table.insert(self.callback_list, i, new_callback_entry);
				
				-- if this new callback is the first in the list (i.e. the one that's going to happen next),
				-- then "repoint" the callback mechanism at it
				if i == 1 then
					self:unregister_timer("timer_manager_tick_callback");
					self:register_singleshot_timer("timer_manager_tick_callback", new_time_offset, true);
				end;
				
				return true;
			end;	
		end;
		
		-- we didn't find anywhere in the table to insert this callback, it must
		-- be later than all the others in the list. It shall go on the end
		table.insert(self.callback_list, #self.callback_list + 1, new_callback_entry);
		
		return true;
	end;
end;


--- @function repeat_callback
--- @desc Instructs the timer manager to call a supplied function after a supplied delay, and then repeatedly after the same delay. A string name for the callback may also be supplied with which the callback may be later cancelled using @timer_manager:remove_callback (note that in battle it's much more common to use @battle_manager:remove_process).
--- @p function callback to call
--- @p number delay in ms
--- @p [opt=nil] string callback name
function timer_manager:repeat_callback(new_callback, new_time_offset, new_entryname)
	self:callback(function() self:repeat_callback(new_callback, new_time_offset, new_entryname) end, new_time_offset, new_entryname);
	self:callback(new_callback, new_time_offset, new_entryname);
end;


--- @function remove_callback
--- @desc Instructs the timer manager to remove any active callback with the supplied name. This is the main method at the level of @timer_manager to remove callbacks, however on the @battle_manager it's more common to call @battle_manager:remove_process instead (which also removes matching @battle_manager:Watches).
--- @p string name name to remove
--- @return boolean any callbacks removed
function timer_manager:remove_callback(key)
	if #self.callback_list == 0 then
		return false;
	end;

	local have_removed_entry = false;
	local i = 1;
	local j = #self.callback_list;
			
	while i <= j do			
		if self.callback_list[i].entryname == key then			
			table.remove(self.callback_list, i);
			have_removed_entry = true;
			j = j - 1;
		else
			i = i + 1;
		end;
	end;
				
	return have_removed_entry;
end;


-- Global function to process the next callback (raw timers can't cope with calls to functions in tables)
function timer_manager_tick_callback()
	__timer_manager:tick_callback();
end;


-- Called internally
-- Process the next callback(s)
function timer_manager:tick_callback()
	while true do
		-- if the size of our list is zero for whatever reason then stop
		if #self.callback_list == 0 then
			break;
		end;
		
		-- if the next callback in our list is due to happen in the next 50ms (or 150ms in frontend)
		-- then process it and remove it, otherwise stop
		if self.callback_list[1].calltime < timestamp_tick + self.callback_leeway then
			local callback = self.callback_list[1].callback;
			local callback_name = self.callback_list[1].entryname;
			table.remove(self.callback_list, 1);
						
			-- try and use exception handling to catch any errors
			local success, err_code = pcall(function() callback() end);
			
			if not success then
				script_error("ERROR: an exception was received when attempting to call a timer manager callback with entryname [" .. tostring(callback_name) .. "], err_code is " .. tostring(err_code) .. " - will call the callback again after this to provoke any crash into happening (for autotesting)");
				callback();
			end;
		else		
			break;
		end;
	end;

	-- repoint the callback timer at whenever the next callback in the list is going to occur
	self:unregister_timer("timer_manager_tick_callback", true);
	if #self.callback_list > 0 then
		self:register_repeating_timer("timer_manager_tick_callback", self.callback_list[1].calltime - timestamp_tick, true);
	end;
end;










----------------------------------------------------------------------------
--- @section Legacy Timers
--- @desc Do not use the functions provided here! Do not remove this either, however, as the callback system is built on top of it.
----------------------------------------------------------------------------


--- @function register_singleshot_timer
--- @desc Registers a handler name (function name) to be called and a period in ms after which to call it. Do not use this unless strictly necessary - it's only provided for legacy support. Use @timer_manager:callback instead.
--- @p string function name
--- @p number time in ms
function timer_manager:register_singleshot_timer(name, t)
	if not self.timer_list[name] then
		self:callback(
			function() 
				self.timer_list[name] = false; 
			end, 
			t, 
			"remove_timer"
		);
		self.singleshot_timer(name, t);
		self.timer_list[name] = true;
	end;
end;


--- @function register_repeating_timer
--- @desc Registers a handler name (function name) to be called and a period in ms after which to repeatedly call it. Do not use this unless strictly necessary - it's only provided for legacy support. Use @timer_manager:repeat_callback instead.
--- @p string function name
--- @p number time in ms
function timer_manager:register_repeating_timer(name, t)
	if not self.timer_list[name] then
		self.repeat_timer(name, t);
		self.timer_list[name] = true;
	end;
end;


--- @function unregister_timer
--- @desc Cancels a timer registered with @timer_manager:register_singleshot_timer or @timer_manager:register_repeating_timer. As is the case with those functions, don't use this unless strictly necessary.
--- @p string function name
function timer_manager:unregister_timer(name, failsafe)
	failsafe = failsafe or false;
	
	if __game_mode == __lib_type_frontend then
		failsafe = true;	-- not sure why, but this system basically doesn't behave itself in the frontend and needs to be treated with kid gloves
	end;
	
	if self.timer_list[name] then
		if failsafe then
			if not pcall(function() self.cancel_timer(name) end) then
				script_error("Just failed to remove timer " .. name .. ", look out for strangeness");
			end;
		else
			self.cancel_timer(name);
		end;
		self.timer_list[name] = false;
	end;
end;













----------------------------------------------------------------------------
--- @section Debug
----------------------------------------------------------------------------

--- @function print_timer_list
--- @desc Writes the current timer list to the console, for debugging purposes.
function timer_manager:print_timer_list()
	local output_func = nil;

	if __game_mode == __lib_type_battle then
		output_func = function(str) get_bm():out(str) end;
	elseif __game_mode == __lib_type_frontend then
		output_func = function(str) print(str) end;
	end;
	
	local ast_line = "*****************************";
	
	output_func("");
	output_func(ast_line);
	output_func("Printing timer list:");
		
	for k, v in pairs(self.timer_list) do
		output_func("\t" .. k .. ":" .. tostring(v));
	end;
	
	output_func(ast_line);
	output_func("");
end;


--- @function print_callback_list
--- @desc Writes the current callback list to the console, for debugging purposes.
function timer_manager:print_callback_list()
	local output_func = nil;

	if __game_mode == __lib_type_battle then
		output_func = function(str) get_bm():out(str) end;
	elseif __game_mode == __lib_type_frontend then
		output_func = function(str) print(str) end;
	end;
	
	local ast_line = "*****************************";
	
	output_func("");
	output_func(ast_line);
	output_func("Printing callback list:");
	
	if #self.callback_list == 0 then
		output_func("\tcallback list is empty!");
		output_func(ast_line);
		output_func("");
		return;
	end;
		
	for i = 1, #self.callback_list do
		output_func("\t" .. i .. ":  " .. tostring(self.callback_list[i].entryname) .. " will be called at " .. self.callback_list[i].calltime .. "ms");
	end;
	
	output_func(ast_line);
	output_func("");
end;


--- @function clear_callback_list
--- @desc Clears all callbacks. This shouldn't really be used for client scripts, if you need to do this you're probably doing something wrong.
function timer_manager:clear_callback_list()
	-- if we have callbacks in our current list then we'll need to stop the timer
	if #self.callback_list > 0 then
		self:unregister_timer("timer_manager_tick_callback");
	end;

	self.callback_list = {};
end;









