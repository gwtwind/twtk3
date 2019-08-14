


--- @loaded_in_battle
--- @loaded_in_campaign
--- @loaded_in_frontend

--- @section Script Messager

--- @function get_messager
--- @desc Gets or creates a @script_messager object.
--- @return script_messager
function get_messager()
	return script_messager:new();
end;








----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	SCRIPT MESSAGER
--
---	@class script_messager Script Messager
--- @desc The script messager is a lightweight object designed to allow separate script systems to send and listen for string messages. It is very much like a cut-down event system, without the congestion of events that are naturally triggered by the game. Its main purpose is to underpin the mechanics of the @generated_battle system.
--- @desc Unlike the events system, the script messager supports the blocking of messages, so that one bit of script can prevent the transmission of a specific message by any other bit of script.
--- @desc It is rare to need to get a handle to a script messager object directly, as the @generated_battle system stores an internal reference to it and calls it automatically when necessary.
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


script_messager = {
	output = nil,
	listeners = {},
	blocked_messages = {},
	is_debug = false
};



-----------------------------------------------------------------------------
--- @section Creation
-----------------------------------------------------------------------------


--- @function new
--- @desc Gets or creates a @script_messager object.
--- @return script_messager
function script_messager:new()
	
	local sm = core:get_static_object("script_messager");

	if is_scriptmessager(sm) then
		return sm;
	end;
	
	sm = {};
	
	setmetatable(sm, self);
	self.__index = self;
	self.__tostring = function() return TYPE_SCRIPT_MESSAGER end;
	
	-- create an output function depending on what mode of game we're in
	if __game_mode == __lib_type_battle then
		sm.output = function(str) get_bm():out(str) end;
	elseif __game_mode == __lib_type_campaign then
		sm.output = function(str) out(str) end;
	else
		sm.output = function(str) print(str) end;
	end;
	
	sm.listeners = {};
	sm.blocked_messages = {};
	
	__script_messager = sm;
	
	core:add_static_object("script_messager", sm);
	
	return sm;
end;










-----------------------------------------------------------------------------
--- @section Debugging
-----------------------------------------------------------------------------


--- @function output
--- @desc Outputs the script_messager internal data for debug purposes.
function script_messager:out()
	self.out("script_messager:: dumping listeners");
	self.out("========================");
	for i = 1, #self.listeners do
		local current_listener = self.listeners[i];
		self.out("\t" .. i .. ":\t\tmessage: " .. current_listener.message .. "\t\tcallback: " .. tostring(current_listener.callback) .. "\t\talways_listen: " .. tostring(current_listener.always_listen));
	end;
	self.out("========================");
	self.out("script_messager:: dumping blocked messages");
	self.out("========================");
	for message in pairs(self.blocked_messages) do
		self.out("\t" .. i .. ":\t\tmessage: " .. message);
	end;
	self.out("========================");
end;


--- @function set_debug
--- @desc Sets the script_messager into debug mode for added output.
function script_messager:set_debug(value)
	if value == false then
		self.is_debug = false;
	else
		self.is_debug = true;
	end;
end;











-----------------------------------------------------------------------------
--- @section Messages
-----------------------------------------------------------------------------


--- @function add_listener
--- @desc Adds a listener for a message. If the specified message is received, the specified callback is called. If the third parameter is set to <code>true</code> then the listener will continue after it calls the callback and will listen indefinitely.
--- @p string message name
--- @p function callback to call
--- @p [opt=false] boolean persistent
function script_messager:add_listener(new_message, new_callback, new_always_listen)
	if not is_string(new_message) then
		script_error("script_messager ERROR: add_listener() called but supplied message [" .. tostring(new_message) .. "] is not a string");
		return false;
	end;
	
	if not is_function(new_callback) then
		script_error("script_messager ERROR: add_listener() called but supplied callback [" .. tostring(new_callback) .. "] is not a function");
		return false;
	end;
	
	new_always_listen = not not new_always_listen;		-- force this value to be boolean

	local new_listener = {
		message = new_message,
		callback = new_callback,
		always_listen = new_always_listen
	};
		
	if self.is_debug then
		self.out("script_messager: adding listener for message " .. tostring(new_message) .. " to call callback " .. tostring(new_callback) .. ", always listen is " .. tostring(new_always_listen));
	end;
	
	table.insert(self.listeners, new_listener);
end;


--- @function trigger_message
--- @desc Triggers a string message. Prompts the messager system to notify any listeners for the subject message and call the callback they registered.
--- @p string message name
function script_messager:trigger_message(message)
	if not is_string(message) then
		script_error("script_messager ERROR: add_listener() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if this message is in our blocked messages list then don't do anything
	if self.blocked_messages[message] then
		if self.is_debug then
			self.out("script_messager: message " .. tostring(message) .. " triggered but it is blocked");
		end;
		return false;
	end;
	
	if self.is_debug then
		self.out("script_messager: message triggered: " .. tostring(message));
	end;
	
	local callbacks_to_call = {};
	local found_result = false;
	
	for i = 1, #self.listeners do
		local current_listener = self.listeners[i];
		
		if current_listener.message == message then
			found_result = true;
			
			-- we have found a callback to call, add it to our list of callbacks and mark this 
			-- listener to expire if it's only to trigger once
			table.insert(callbacks_to_call, current_listener.callback);
					
			if not current_listener.always_listen then
				self.listeners[i].to_remove = true;
			end;
			
			if self.is_debug then
				self.out("\tscript_messager: found match, will call: " .. tostring(current_listener.callback));
			end;
		end;
	end;
	
	-- we've examined all our listeners and built a list of callbacks to call, now clean our list up of entries we've marked to remove
	if found_result then
		for i = #self.listeners, 1, -1 do
			if self.listeners[i].to_remove then
				table.remove(self.listeners, i);
			end;
		end;
	end;
	
	for i = 1, #callbacks_to_call do
		callbacks_to_call[i]();
	end;
	
	return found_result;
end;


--- @function remove_listener
--- @desc Removes any listener listening for a particular message.
--- @p string message name
function script_messager:remove_listener(message)
	if not is_string(message) then
		script_error("script_messager ERROR: remove_listener() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	for i = 1, #self.listeners do
		if self.listeners[i].message == message then
			table.remove(self.listeners, i);
			self:remove_listener(message);
			return;
		end;
	end;
end;


--- @function block_message
--- @desc Blocks or unblocks a message from being transmitted in the future. If a message is blocked, no listeners will be notified when @script_messager:trigger_message is called.
--- @p string message name
--- @p [opt=true] boolean should block
function script_messager:block_message(message, should_block)
	if not is_string(message) then
		script_error("script_messager ERROR: block_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if should_block ~= false then
		-- block
		self.blocked_messages[message] = true;
	else
		-- unblock
		self.blocked_messages[message] = nil;
	end;
end;

