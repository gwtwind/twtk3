



----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CAMPAIGN MISSION MANAGER
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------
--	Definition
----------------------------------------------------------------------------

mission_manager = {
	cm = "",
	faction_name = "",
	mission_key = "",
	started = false,
	completed = false,
	first_time_startup_callback = nil,
	each_time_startup_callback = nil,
	success_callback = nil,
	failure_callback = nil,
	cancellation_callback = nil,
	nearing_expiry_callback = nil,
	is_mission = true,
	is_incident = false,
	is_dilemma = false,
	should_whitelist = true,
	
	-- for triggering from string
	should_trigger_from_string = false,
	should_trigger_from_db = false,
	mission_issuer = "CLAN_ELDERS",
	turn_limit = false,			-- set to a number to activate
	objectives = {},
	mission_string = "",
	is_registered = false,
	should_cancel_before_issuing = true,
	chapter_mission = false, 	-- set to number to activate
	
	-- for scripted mission types
	scripted_objectives = {}
};



----------------------------------------------------------------------------
--	Declaration
----------------------------------------------------------------------------

function mission_manager:new(faction_name, mission_key, success_callback, failure_callback, cancellation_callback, nearing_expiry_callback)

	local cm = get_cm();
	
	if not is_string(faction_name) then
		script_error("ERROR: mission_manager:new() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;
	
	local query_faction = cm:query_faction(faction_name);
	
	if not query_faction then
		script_error("ERROR: mission_manager:new() called but couldn't find a faction with supplied name [" .. faction_name .. "]");
		return false;
	end;
	
	if not query_faction:is_human() then
		script_error("ERROR: mission_manager:new() called but faction with supplied name [" .. faction_name .. "] is not human");
		return false;
	end;

	if not is_string(mission_key) then
		script_error("ERROR: mission_manager:new() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string");
		return false;
	end;
	
	if not is_function(success_callback) and not is_nil(success_callback) then
		script_error("ERROR: mission_manager:new() called but supplied success callback [" .. tostring(success_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if not is_function(failure_callback) and not is_nil(failure_callback) then
		script_error("ERROR: mission_manager:new() called but supplied failure callback [" .. tostring(failure_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if not is_function(cancellation_callback) and not is_nil(cancellation_callback) then
		script_error("ERROR: mission_manager:new() called but supplied cancellation callback [" .. tostring(cancellation_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if not is_function(nearing_expiry_callback) and not is_nil(nearing_expiry_callback) then
		script_error("ERROR: mission_manager:new() called but supplied nearing-expiry callback [" .. tostring(nearing_expiry_callback) .. "] is not a function or nil");
		return false;
	end;
	
	local cm = get_cm();
	
	-- If false is passed in as the third parameter then set this mission manager to be not persistent.
	-- A not-persistent mission manager supports multiple missions of the same key being triggered, but doesn't support any
	-- success/failure callbacks as the script/code cannot tell the difference between two missions with the same key. Furthermore,
	-- the mission manager state doesn't get saved into the savegame (the mission itself does, however). In this case, the mission
	-- manager is still useful to allow the scripter easy set up of a mission string.
	-- If a mission manager is later set up with a scripted objective, this also sets the mission to be persistent/saved into the
	-- savegame, with the same restriction of not allowing multiple missions with the same key.
	local should_register = not not success_callback;
	
	
	local mm = {};
	
	setmetatable(mm, self);
	self.__tostring = function() return TYPE_MISSION_MANAGER end;
	self.__index = self;
	
	mm.cm = cm;
	mm.faction_name = faction_name;
	mm.mission_key = mission_key;
	mm.objectives = {};
	mm.scripted_objectives = {};
	
	mm.success_callback = success_callback;
	mm.failure_callback = failure_callback;
	mm.cancellation_callback = cancellation_callback;
	mm.nearing_expiry_callback = nearing_expiry_callback;

	if cm:query_model():difficulty_level() == 4 then
		mm.force_immediate_callback = true;
	end;
	
	if success_callback or failure_callback or cancellation_callback or nearing_expiry_callback then
		mm:register();
	end;
	
	return mm;
end;



----------------------------------------------------------------------------
--	Registration with campaign manager
--	(persistent mm's or mm's containing scripted objectives only)
----------------------------------------------------------------------------

function mission_manager:register()
	if not self.is_registered then
		local cm = self.cm;
	
		if cm:get_mission_manager(self.mission_key) then
			script_error("ERROR: mission_manager:register() was called but a mission with supplied key [" .. tostring(mission_key) .. "] has already been registered. You cannot register more than one persistent mission with the same mission key. Persistent missions are missions with some manner of completion callback, or a mission with a scripted objective.");
		else
			cm:register_mission_manager(self);
			self.is_registered = true;
		end;
	end;
end;


----------------------------------------------------------------------------
--	Setup
----------------------------------------------------------------------------

function mission_manager:set_first_time_startup_callback(first_time_startup_callback)
	if not is_function(first_time_startup_callback) then
		script_error("ERROR: set_first_time_startup_callback() called but supplied callback [" .. tostring(first_time_startup_callback) .. "] is not a function");
		return false;
	end;
	
	self.first_time_startup_callback = first_time_startup_callback;
end;


function mission_manager:set_each_time_startup_callback(each_time_startup_callback)
	if not is_function(each_time_startup_callback) then
		script_error("ERROR: set_each_time_startup_callback() called but supplied callback [" .. tostring(each_time_startup_callback) .. "] is not a function");
		return false;
	end;
	
	self.each_time_startup_callback = each_time_startup_callback;
end;


function mission_manager:set_should_trigger_from_db(value)
	if value == false then
		self.should_trigger_from_db = false;
	else
		self.should_trigger_from_db = true;
	end;
end;


function mission_manager:set_is_mission()
	self.is_mission = true;
	self.is_incident = false;
	self.is_dilemma = false;
end;


function mission_manager:set_is_incident()
	self.is_mission = false;
	self.is_incident = true;
	self.is_dilemma = false;
end;


function mission_manager:set_is_dilemma()
	self.is_mission = false;
	self.is_incident = false;
	self.is_dilemma = true;
end;


function mission_manager:set_should_whitelist(value)
	if value == false then
		self.should_whitelist = false;
	else
		self.should_whitelist = true;
	end;
end;



----------------------------------------------------------------------------
--	Setup functions for if constructing the mission at runtime
----------------------------------------------------------------------------

-- new objectives are set up here (for if the mission will be constructed and not added via missions.txt)
function mission_manager:add_new_objective(objective_type)
	if not is_string(objective_type) then
		script_error("ERROR: add_new_objective() called on mission manager for mission key [" .. self.mission_key .. "] but supplied objective type [" .. tostring(objective_type) .. "] is not a string");
		return false;
	end;
	
	local objective_record = {};
	objective_record.objective_type = objective_type;
	objective_record.conditions = {};
	objective_record.payloads = {};
	
	table.insert(self.objectives, objective_record);
	
	self.should_trigger_from_string = true;
end;


function mission_manager:add_condition(condition)
	if not is_string(condition) then
		script_error("ERROR: add_condition() called on mission manager for mission key [" .. self.mission_key .. "] but supplied objective condition [" .. tostring(condition) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_condition() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;
		
	table.insert(self.objectives[#self.objectives].conditions, condition);
end;


function mission_manager:add_payload(payload)
	if not is_string(payload) then
		script_error("ERROR: add_payload() called on mission manager for mission key [" .. self.mission_key .. "] but supplied payload [" .. tostring(payload) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_payload() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;
		
	table.insert(self.objectives[#self.objectives].payloads, payload);
end;


function mission_manager:add_heading(heading)
	if not is_string(heading) then
		script_error("ERROR: add_heading() called on mission manager for mission key [" .. self.mission_key .. "] but supplied heading key [" .. tostring(heading) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_heading() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;
		
	self.objectives[#self.objectives].heading = heading;
end;


function mission_manager:add_description(description)
	if not is_string(description) then
		script_error("ERROR: add_description() called on mission manager for mission key [" .. self.mission_key .. "] but supplied description key [" .. tostring(description) .. "] is not a string");
		return false;
	end;
	
	if #self.objectives == 0 then
		script_error("ERROR: add_description() called on mission manager for mission key [" .. self.mission_key .. "] but no objectives have been previously set up with add_new_objective(). Set one up before calling this.");
		return false;
	end;
		
	self.objectives[#self.objectives].description = description;
end;


function mission_manager:set_turn_limit(turn_limit)
	if not is_number(turn_limit) then
		script_error("ERROR: set_turn_limit() called on mission manager for mission key [" .. self.mission_key .. "] but supplied turn limit [" .. tostring(turn_limit) .. "] is not a number");
		return false;
	end;
	
	self.turn_limit = turn_limit;
end;


function mission_manager:set_chapter(chapter)
	if not is_number(chapter) then
		script_error("ERROR: set_chapter() called on mission manager for mission key [" .. self.mission_key .. "] but supplied chapter [" .. tostring(turn_limit) .. "] is not a number");
		return false;
	end;
	
	self.chapter_mission = chapter;
end;


function mission_manager:set_mission_issuer(issuer)
	if not is_string(issuer) then
		script_error("ERROR: set_mission_issuer() called on mission manager for mission key [" .. self.mission_key .. "] but supplied issuer [" .. tostring(issuer) .. "] is not a string");
		return false;
	end;
	
	self.mission_issuer = issuer;
end;


function mission_manager:set_should_cancel_before_issuing(value)
	if value == false then
		self.should_cancel_before_issuing = false;
	else
		self.should_cancel_before_issuing = true;
	end;
end;




----------------------------------------------------------------------------
--	Scripted mission type
--	Script is responsible for completing the mission
--	This also forces the mission manager to be persistent, which means
--  that it can't share a mission key with another
----------------------------------------------------------------------------

function mission_manager:add_new_scripted_objective(override_text, event, condition, script_key)

	if not is_string(override_text) then
		script_error("ERROR: add_scripted_mission_objective() called but supplied override text key [" .. tostring(override_text) .. "] is not a string");
		return false;
	end;
	
	if not is_string(event) then
		script_error("ERROR: add_scripted_mission_objective() called but supplied event name (" .. tostring(event) .. ") is not a string");
		return false;
	end;
	
	if not is_function(condition) and not is_boolean(condition) then
		script_error("ERROR: add_scripted_mission_objective() called but supplied condition (" .. tostring(condition) .. ") is not a string or a boolean");
		return false;
	end;
	
	script_key = script_key or (self.mission_key .. "_" .. tostring(core:get_unique_counter()));
		
	local objective_record = {
		["script_key"] = script_key,
		["is_completed"] = false,
		["success_conditions"] = {},
		["failure_conditions"] = {}
	};
	
	table.insert(self.scripted_objectives, objective_record);
	
	self:add_new_objective("SCRIPTED");
	self:add_condition("script_key " .. script_key);
	self:add_condition("override_text " .. override_text);
	
	self:add_scripted_objective_success_condition(event, condition, script_key);
	
	-- register this mission manager as persistent
	self:register();
end;



function mission_manager:add_scripted_objective_success_condition(event, condition, script_key)
	return self:add_scripted_objective_completion_condition(true, event, condition, script_key);
end;


function mission_manager:add_scripted_objective_failure_condition(event, condition, script_key)
	return self:add_scripted_objective_completion_condition(false, event, condition, script_key);
end;


function mission_manager:add_scripted_objective_completion_condition(is_success, event, condition, script_key)

	if not is_boolean(is_success) then
		script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called but supplied is_success flag [" .. tostring(is_success) .. "] is not a boolean value. Has this function been called directly?");
		return false;
	end;		
	
	if not is_string(event) then
		script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called but supplied event name [" .. tostring(event) .. "] is not a string");
		return false;
	end;
	
	if not is_function(condition) and condition ~= true then
		script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called but supplied condition [" .. tostring(event) .. "] is not a string or true");
		return false;
	end;
	
	if script_key and not is_string(script_key) then
		script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called but supplied script_key [" .. tostring(script_key) .. "] is not a string or nil");
		return false;
	end;
	
	local scripted_objectives = self.scripted_objectives;
	local scripted_objective_record = false;
	
	-- support the case that no script_key is supplied
	if not script_key then
	
		-- there must be exactly one scripted objective record registered in this case
		if #scripted_objectives ~= 1 then
			script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called with no script_key defined, and there is not exactly one scripted objective record (number of scripted objectives is [" .. #self.scripted_objectives .. "]");
			return false;
		end;
		
		-- take the script_key of the single existing scripted objective record 
		script_key = scripted_objectives[1].script_key;
		
		scripted_objective_record = scripted_objectives[1];
		
	else
		-- find the scripted objective record matching the script_key
		for i = 1, #scripted_objectives do
			if scripted_objectives[i].script_key == script_key then
				scripted_objective_record = scripted_objectives[i];
				break;
			end;
		end;
	
		if not scripted_objective_record then
			script_error(self.mission_key .. " ERROR: add_scripted_objective_completion_condition() called with script_key [" .. script_key .. "] but no scripted objective record with this key could be found");
			return false;
		end;
	end;
	
	-- create/add this completion condition record
	local completion_condition_record = {
		["event"] = event,
		["condition"] = condition
	};
	
	if is_success then
		table.insert(scripted_objective_record.success_conditions, completion_condition_record);
	else
		table.insert(scripted_objective_record.failure_conditions, completion_condition_record);
	end;
end;



----------------------------------------------------------------------------
--	Externally force success or failure of a scripted objective
----------------------------------------------------------------------------

function mission_manager:force_scripted_objective_success(script_key)
	return self:force_scripted_objective_completion(true, script_key);
end;


function mission_manager:force_scripted_objective_failure(script_key)
	return self:force_scripted_objective_completion(false, script_key);
end;


function mission_manager:force_scripted_objective_completion(is_success, script_key)

	script_error("ERROR: scripted missions not supported in 3K");
	return false;
	
	--[[
	-- support no script_key being supplied - we must have exactly one scripted_objectives record
	if not script_key then
	
		if #self.scripted_objectives ~= 1 then
			script_error(self.mission_key .. " ERROR: force_scripted_objective_completion() called with no script_key but the number of registered scripted objectives is not one (it is [" .. #self.scripted_objectives .. "])");
			return false;
		end;
		
		script_key = self.scripted_objectives[1].script_key;
	end;
	
	if is_success then
		self.cm:complete_scripted_mission_objective(self.mission_key, script_key, true);
		output("~~~ MissionManager :: " .. self.mission_key .. " is being externally forced to successfully complete scripted objective with script key [" .. script_key .. "]");
	else
		self.cm:complete_scripted_mission_objective(self.mission_key, script_key, false);
		output("~~~ MissionManager :: " .. self.mission_key .. " is being externally forced to fail scripted objective with script key [" .. script_key .. "]");
	end;
	
	core:remove_listener(self.mission_key .. script_key .. "_completion_listener");
	]]
end;



----------------------------------------------------------------------------
--	Querying
----------------------------------------------------------------------------

function mission_manager:is_started()
	return self.started;
end;


function mission_manager:is_completed()
	return self.completed;
end;






----------------------------------------------------------------------------
--	Starting
----------------------------------------------------------------------------


function mission_manager:trigger(dismiss_callback, delay)
	if self.started then
		script_error("ERROR: an attempt was made to trigger a mission manager with key [" .. self.mission_key .. "] which has already been triggered");
		return false;
	end;
	
	if dismiss_callback and not is_function(dismiss_callback) then
		script_error("trigger() called on mission but supplied dismiss callback [" .. tostring(dismiss_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if delay and not is_number(delay) then
		script_error("trigger() called on mission but supplied dismiss callback delay [" .. tostring(delay) .. "] is not a number or nil");
		return false;
	end;
	
	delay = delay or 0;
	
	if self.should_trigger_from_string then
		local mission_string = self:construct_mission_string();
		
		if not mission_string then
			script_error("ERROR: trigger() called on mission manager with key [" .. self.mission_key .. "] but failed to construct a mission string");
			return false;
		else
			self.mission_string = mission_string;
		end;
	end;

	self.started = true;

	if is_function(self.first_time_startup_callback) then
		self.first_time_startup_callback();
	end;
	
	if is_function(self.each_time_startup_callback) then
		self.each_time_startup_callback();
	end;
	
	self:start_listeners();
	
	if dismiss_callback then
		core:add_listener(
			self.mission_key,
			"PanelOpenedCampaign",
			function(context) return context.string == "events" end,
			function()
				self.cm:progress_on_events_dismissed(
					self.mission_key,
					dismiss_callback,
					delay
				);
			end,
			false
		);
	end;
	
	if self.should_trigger_from_string then
		self:trigger_from_string();
		return true;
	elseif self.should_trigger_from_db then
		if self.is_mission then
			return self.cm:trigger_mission(self.faction_name, self.mission_key, true, self.should_whitelist);
		elseif self.is_incident then
			return self.cm:trigger_incident(self.faction_name, self.mission_key, true, self.should_whitelist);
		elseif self.is_dilemma then
			return self.cm:trigger_dilemma(self.faction_name, self.mission_key, true, self.should_whitelist);
		else
			script_error(self.name .. " ERROR: trigger() called but cannot identify mission type, it doesn't seem to be a mission, incident or dilemma?");
			return false;
		end;
	else
		self.cm:trigger_custom_mission(self.faction_name, self.mission_key, not self.should_cancel_before_issuing, self.should_whitelist);
		return true;
	end;

	return false;
end;


function mission_manager:construct_mission_string()

	if #self.objectives == 0 then
		script_error("ERROR: construct_mission_string() called on mission manager with key [" .. self.mission_key .. "] but we have no objectives to add");
		return false;
	end;
	
	local is_primary_objective = true;
	local have_opened_secondary_objective_block = false;
	
	local mission_string = "mission{key " .. self.mission_key .. ";issuer " .. self.mission_issuer;
	
	if self.chapter_mission then
		mission_string = "mission{chapter " .. self.chapter_mission .. ";key " .. self.mission_key .. ";issuer " .. self.mission_issuer;
	end
	
	for i = 1, #self.objectives do
		local current_objective = self.objectives[i];
		
		-- data checking
		if not current_objective.objective_type then
			script_error("ERROR: construct_mission_string() called on mission manager with key [" .. self.mission_key .. "] but objective [" .. i .. "] has no type (how can this be?)");
			return false;
		end;
		
		if not is_table(current_objective.payloads) or #current_objective.payloads == 0 then
			script_error("ERROR: construct_mission_string() called on mission manager with key [" .. self.mission_key .. "] but objective [" .. i .. "] has no payload");
			return false;
		end;
		
		-- open the objective/payload block
		if is_primary_objective then
			mission_string = mission_string .. ";primary_objectives_and_payload{";
			is_primary_objective = false;
			
		elseif have_opened_secondary_objective_block then
			mission_string = mission_string .. "objectives_and_payload{";
			
		else
			mission_string = mission_string .. "secondary_objectives_and_payloads{objectives_and_payload{";
			have_opened_secondary_objective_block = true;
		end;
		
		-- optional heading/decription key overrides
		if current_objective.heading then
			mission_string = mission_string .. "heading " .. current_objective.heading .. ";";
		end;
		
		if current_objective.description then
			mission_string = mission_string .. "description " .. current_objective.description .. ";";
		end;
		
		mission_string = mission_string .. "objective{type " .. current_objective.objective_type .. ";";
		
		for j = 1, #current_objective.conditions do
			mission_string = mission_string .. current_objective.conditions[j] .. ";";
		end;
		
		-- payloads
		mission_string = mission_string .. "}payload{";
		
		for j = 1, #current_objective.payloads do
			local payload_string = current_objective.payloads[j];
			
			-- don't add a semicolon if the last character of the payload string is "}"
			if string.sub(payload_string, string.len(payload_string)) == "}" then
				mission_string = mission_string .. payload_string;
			else
				mission_string = mission_string .. payload_string .. ";";
			end;
		end;
		
		mission_string = mission_string .. "}}";
	end;
	
	if have_opened_secondary_objective_block then
		mission_string = mission_string .. "}}";
	else
		mission_string = mission_string .. "}";
	end;
	
	return mission_string;
end;



function mission_manager:trigger_from_string()
	local mission_string = self.mission_string;
	
	output("++ mission manager triggering mission from string:");
	
	if self.should_cancel_before_issuing then
		self.cm:cancel_custom_mission(self.faction_name, self.mission_key);
	end;
	self.cm:trigger_custom_mission_from_string(self.faction_name, mission_string, self.should_whitelist);
end;


function mission_manager:start_from_savegame(started, completed)
	self.started = started;
	self.completed = completed;

	if started and not completed then
		if is_function(self.each_time_startup_callback) then
			self.each_time_startup_callback();
		end;

		self:start_listeners();
	end;
end;


function mission_manager:start_listeners()
	local cm = self.cm;
	local mission_key = self.mission_key;
	
	-- success listener
	if is_function(self.success_callback) then
		core:add_listener(
			mission_key .. "_success_listener",
			"MissionSucceeded",
			function(context) return context:mission():mission_record_key() == mission_key end,
			function()
				output("~~~ MissionManager :: " .. mission_key .. " succeeded event received");
				self:complete();
				if is_function(self.success_callback) then
					if self.force_immediate_callback then
						self.success_callback();
					else
						cm:progress_on_battle_completed(
							"mm_" .. mission_key,
							function()
								self.success_callback();
							end
						);
					end;
				end;
			end,
			false
		);
	end;
	
	-- failure listener
	if is_function(self.failure_callback) then
		core:add_listener(
			mission_key .. "_failure_listener",
			"MissionFailed",
			function(context) return context:mission():mission_record_key() == mission_key end,
			function()
				output("~~~ MissionManager :: " .. mission_key .. " failed event received");
				self:complete();
				if is_function(self.failure_callback) then
					if self.force_immediate_callback then
						self.failure_callback();
					else
						cm:progress_on_battle_completed(
							"mm_" .. mission_key,
							function()
								self.failure_callback();
							end
						);
					end;
				end;
			end,
			false
		);	
	end;
	
	-- cancellation listener
	if is_function(self.cancellation_callback) then
		core:add_listener(
			mission_key .. "_cancellation_listener",
			"MissionCancelled",
			function(context) return context:mission():mission_record_key() == mission_key end,
			function()
				output("~~~ MissionManager :: " .. mission_key .. " cancelled event received");
				self:complete();
				if is_function(self.cancellation_callback) then
					if self.force_immediate_callback then
						self.cancellation_callback();
					else
						cm:progress_on_battle_completed(
							"mm_" .. mission_key,
							function()
								self.cancellation_callback();
							end
						);
					end;
				end;
			end,
			false
		);	
	end;
	
	-- nearing expiry listener
	if is_function(self.nearing_expiry_callback) then
		core:add_listener(
			mission_key .. "_nearing_expiry_listener",
			"MissionCancelled",
			function(context) return context:mission():mission_record_key() == mission_key end,
			function()
				output("~~~ MissionManager :: " .. mission_key .. " nearing expiry event received");
				if is_function(self.nearing_expiry_callback) then
					self.nearing_expiry_callback();
				end;
			end,
			true
		);	
	end;
	
	-- scripted objective listeners
	
	-- scripted objectives not currently supported in 3K
	--[[
	for i = 1, #self.scripted_objectives do
		local current_scripted_objective_record = self.scripted_objectives[i];
		local script_key = current_scripted_objective_record.script_key;
		
		for j = 1, #current_scripted_objective_record.success_conditions do
			local condition_record = current_scripted_objective_record.success_conditions[j];
			
			local listener_name = self.mission_key .. script_key .. "_completion_listener";
			
			core:add_listener(
				listener_name,
				condition_record.event,
				condition_record.condition,
				function(context)
					out("~~~ MissionManager :: " .. mission_key .. " has successfully completed scripted objective with script key [" .. script_key .. "]");
					
					core:remove_listener(listener_name);
					
					if self.cm:is_processing_battle() then
						out("\twill complete objective after battle sequence completes");
						self.cm:progress_on_battle_completed(
							listener_name,
							function()
								output("~~~ MissionManager :: " .. mission_key .. " is completing scripted objective with script key [" .. script_key .. "] now that battle sequence has completed");
								self.cm:complete_scripted_mission_objective(self.mission_key, script_key, true);
							end,
							0.5
						);
					else
						out("\tcompleting objective immediately");
						self.cm:complete_scripted_mission_objective(self.mission_key, script_key, true);
					end;
				end,
				false
			);
		end;
		
		for j = 1, #current_scripted_objective_record.failure_conditions do
			local condition_record = current_scripted_objective_record.failure_conditions[j];
			
			core:add_listener(
				self.mission_key .. script_key .. "_completion_listener",
				condition_record.event,
				condition_record.condition,
				function(context)
					output("~~~ MissionManager :: " .. mission_key .. " has failed scripted objective with script key [" .. script_key .. "]");
					self.cm:complete_scripted_mission_objective(self.mission_key, script_key, false);
					core:remove_listener(self.mission_key .. script_key .. "_completion_listener");
				end,
				false
			);
		end;
	end;
	]]
end;



----------------------------------------------------------------------------
--	Saving
----------------------------------------------------------------------------

function mission_manager:state_to_string()
	return self.mission_key .. "%" .. tostring(self.started) .. "%" .. tostring(self.completed) .. "%";
end;



--- @function has_been_triggered
--- @desc Returns <code>true</code> if the mission manager has been triggered in the past, <code>false</code> otherwise. If triggered it might not still be running, as the mission could have been completed.
--- @return boolean is started
function mission_manager:has_been_triggered()
	return self.started;
end;



----------------------------------------------------------------------------
--	Updating Scripted Objective Text
----------------------------------------------------------------------------


function mission_manager:update_scripted_objective_text(override_text, script_key)

	script_error("update_scripted_objective_text() called but scripted objectives are not currently supported in 3K");

	--[[
	if not is_string(override_text) then
		script_error(self.mission_key .. " ERROR: update_scripted_objective_text() called but supplied override text [" .. tostring(override_text) .. "] is not a string");
		return false;
	end;
	
	-- support not supplying a script key if we only have one scripted objective
	if not script_key then
		if #self.scripted_objectives ~= 1 then
			script_error(self.mission_key .. " ERROR: update_scripted_objective_text() called with no script_key, but more or less than one scripted objective has been registered (number of registered scripted objectives is [" .. tostring(#self.scripted_objectives) .. "]");
			return false;
		end;
	
		script_key = self.scripted_objectives[1].script_key;
	end;
	
	self.cm:set_scripted_mission_text(self.mission_key, script_key, override_text);
	]]
end;



----------------------------------------------------------------------------
--	Completing
----------------------------------------------------------------------------


function mission_manager:complete()
	local cm = self.cm;
	local mission_key = self.mission_key;
	
	self.completed = true;

	core:remove_listener(mission_key .. "_success_listener");
	core:remove_listener(mission_key .. "_failure_listener");
	core:remove_listener(mission_key .. "_cancellation_listener");
	core:remove_listener(mission_key .. "_nearing_expiry_listener");
	
	-- clean up any remaining scripted objective listeners
	for i = 1, #self.scripted_objectives do
		core:remove_listener(self.mission_key .. self.scripted_objectives[i].script_key .. "_completion_listener");
	end;
end;





















--
--	chapter missions
--


chapter_mission = {
	cm = false,
	chapter_number = 0,
	player_faction = false,
	objective_key = false,
	advice_key = false,
	intervention = false
};


function chapter_mission:new(chapter_number, player_faction, objective_key, advice_key, infotext)

	local cm = get_cm();
	
	if not is_number(chapter_number) then
		script_error("ERROR: chapter_mission:new() called but supplied chapter number [" .. tostring(chapter_number) .. "] is not a number");
		return false;
	end;
	
	if not is_string(player_faction) then
		script_error("ERROR: chapter_mission:new() called but supplied player faction key [" .. tostring(player_faction) .. "] is not a string");
		return false;
	end;

	if not cm:faction_exists(player_faction) then
		script_error("ERROR: chapter_mission:new() called but no faction with supplied key [" .. player_faction .. "] could be found");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("ERROR: chapter_mission:new() called but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(advice_key) and not is_nil(advice_key) then
		script_error("ERROR: chapter_mission:new() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string or nil");
		return false;
	end;
	
	if not is_nil(infotext) and not is_table(infotext) then
		script_error("ERROR: chapter_mission:new() called but supplied infotext [" .. tostring(infotext) .. "] is not a table or nil");
		return false;
	end;
	
	
	local ch = {};
	setmetatable(ch, self);
	self.__index = self;
	
	ch.cm = cm;
	ch.chapter_number = chapter_number;
	ch.player_faction = player_faction;
	ch.objective_key = objective_key;
	ch.advice_key = advice_key;
	ch.infotext = infotext;
	
	local chapter_mission_string = "chapter_mission_" .. tostring(chapter_number);
	local mission_issued = cm:get_saved_value("chapter_mission_" .. chapter_number .. "_issued");
	local mission_completed = cm:get_saved_value("chapter_mission_" .. chapter_number .. "_completed");
	
	local intervention = intervention:new(
		chapter_mission_string,														-- string name
		0,																			-- cost
		function() 																	-- trigger callback
			ch:issue_mission();
		end,
		BOOL_INTERVENTIONS_DEBUG,	 												-- show debug output
		BOOL_INTERVENTIONS_DISREGARD_HISTORY										-- disregard advice history (for debugging)
	);
	
	intervention:set_allow_when_advice_disabled(true);
	
	intervention:add_precondition(function() return not mission_issued and not mission_completed end);
	
	intervention:add_trigger_condition(
		"ScriptEventTriggerChapterMission", 
		function(context) return context.string == tostring(chapter_number) end
	);
	
	if cm:is_new_game() then
		intervention:start();
	end;
	
	ch.intervention = intervention;
	
	-- We register chapter missions with the cm now so that it can be asked when a chapter mission is completed whether a further chapter mission exists
	-- This means we can avoid locking the saving-game functionality in legendary mode when there is no further mission (which is responsible for unlocking it)
	cm:register_chapter_mission(ch);
	
	-- listen for this chapter mission being completed and fire an event that should set off the next
	if not mission_completed then
		core:add_listener(
			chapter_mission_string,
			"MissionSucceeded",
			function(context)
				return context:mission():mission_record_key() == ch.objective_key
			end,
			function()
				local next_chapter_number = chapter_number + 1;
				
				-- if this is a legendary game then disable saving, so the game doesn't save after one chapter objective has been completed but before the next has been issued
				-- only do this if another chapter mission exists!
				if cm:query_model():difficulty_level() == -3 and cm:chapter_mission_exists_with_number(next_chapter_number) then
					cm:modify_scripting():disable_saving_game(true);
				end;
				
				cm:set_saved_value("chapter_mission_" .. chapter_number .. "_completed", true);
				core:trigger_event("ScriptEventTriggerChapterMission", tostring(next_chapter_number))
			end,
			false
		);
	end;
	
	return ch;
end;


function chapter_mission:manual_start()
	core:trigger_event("ScriptEventTriggerChapterMission", tostring(self.chapter_number));
end;


function chapter_mission:start_on_event(event, condition)
	if not is_string(event) then
		script_error("ERROR: chapter_mission:start_on_event() called but supplied event [" .. tostring(event) .. "] is not a string");
		return false;
	end;
	
	if not is_function(condition) and condition ~= true then
		script_error("ERROR: chapter_mission:start_on_event() called but supplied condition [" .. tostring(condition) .. "] is not a function or true");
		return false;
	end;
	
	local cm = self.cm;
	local mission_str = "chapter_mission_" .. self.chapter_number;
	
	if not cm:get_saved_value(mission_str) then
		core:add_listener(
			mission_str .. "_startup_listener",
			event,
			condition,
			function()
				cm:set_saved_value(mission_str, true);
				self:manual_start() 
			end,
			false
		);
	end;
end;


function chapter_mission:issue_mission()
	local cm = self.cm;
	local intervention = self.intervention;
	
	-- On legendary difficulty, establish a listener for when the new mission is issued and then save the game.
	-- This is because on legendary difficulty the game autosaves at the start of turn, which can happen after
	-- the previous chapter mission is completed but before the next one is issued.
	local should_autosave_after_mission_issued = false;
	
	if cm:query_model():difficulty_level() == -3 then
		should_autosave_after_mission_issued = true;
	end;
	
	-- allow the chapter mission complete to be shown
	cm:whitelist_event_feed_event_type("faction_campaign_chapter_objective_completeevent_feed_target_mission_faction")
	
	core:trigger_event("ScriptEventChapterMissionTriggered");
	
	cm:set_saved_value("chapter_mission_" .. self.chapter_number .. "_issued", true);
	
	if self.advice_key and cm:is_advice_enabled() then
		if self.infotext and (not effect.get_advice_history_string_seen("prelude_victory_conditions_advice") or BOOL_INTERVENTIONS_DISREGARD_HISTORY) then
		
			effect.set_advice_history_string_seen("prelude_victory_conditions_advice")
	
			-- show victory conditions infotext if it's not been seen by the player before
			play_advice_for_intervention(intervention, self.advice_key, self.infotext);
		else
			play_advice_for_intervention(intervention, self.advice_key);
		end;
		
		cm:callback(
			function()
				cm:trigger_custom_mission(self.player_faction, self.objective_key);
				
				if should_autosave_after_mission_issued then
					local modify_scripting = cm:modify_scripting();
					modify_scripting:disable_saving_game(false);
					modify_scripting:autosave_at_next_opportunity();
				end;
			end,
			1
		);
	else
		cm:trigger_custom_mission(self.player_faction, self.objective_key);
		
		if should_autosave_after_mission_issued then
			local modify_scripting = cm:modify_scripting();
			modify_scripting:disable_saving_game(false);
			modify_scripting:autosave_at_next_opportunity();
		end;
		
		cm:callback(function() intervention:complete() end, 1);
	end;
end;



