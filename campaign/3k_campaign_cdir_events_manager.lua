---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			CDir Events Manager
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to trigger events for player factions, especially when they're out of turn.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------



--***********************************************************************************************************
--***********************************************************************************************************
-- VARIABLES
--***********************************************************************************************************
--***********************************************************************************************************



cdir_events_manager = {};
cdir_events_manager.debug_mode = false;
cdir_events_manager.output_events_to_file = false;
cdir_events_manager.debug_ignore_event_conditions = false;

--[[ stores a list of events in the following format.
	{
		cqi,
		{keys}
	}
]]--

cdir_events_manager.queued_prioritised_incidents = {};
cdir_events_manager.queued_important_incidents = {};
cdir_events_manager.queued_standard_incidents = {};

cdir_events_manager.queued_prioritised_dilemmas = {};
cdir_events_manager.queued_important_dilemmas = {};
cdir_events_manager.queued_standard_dilemmas = {};

-- Generation chance. Clone of the campagin_vars which control general event generation.
-- An 'action' in this event is any time we try to fire an event.
cdir_events_manager.event_generation_standard_start_round = 5; -- First round where they can trigger.
cdir_events_manager.event_generation_min_turns_between_events = 2; -- Min turns which have to occur before we can fire.
cdir_events_manager.event_generation_min_actions_between_events = 3; -- Min actions which have to occur before we can fire.

cdir_events_manager.event_generation_min_turns_between_important_events = 0; -- Min turns which have to occur before we can fire important events.
cdir_events_manager.event_generation_min_actions_between_important_events = 2; -- Min actions which have to occur before we can fire important events.

cdir_events_manager.event_generation_base_chance = 20; -- base chance of event firing. % value out of 100.
cdir_events_manager.event_generation_chance_per_action = 5; -- Added chance for each time we've tried to trigger. % value out of 100.
cdir_events_manager.event_generation_actions_since_last_event = 2; -- How many triggers we've tried. Default high so important events can fire earlier. SAVED VALUE

require("3k_campaign_cdir_events_data");



--***********************************************************************************************************
--***********************************************************************************************************
-- METHODS
--***********************************************************************************************************
--***********************************************************************************************************


--- @function initialse
--- @desc Entry point for the CDir System, sets up the listeners the system needs to run.
function cdir_events_manager:initialise()
	core:add_listener(
		"cdir_events_manager_application_listener", -- Unique handle
		"ScriptEventPreDeleteModelInterface", -- Campaign Event to listen for
		function()
			return self:has_queued_events() and self:can_apply_events();
		end,
		function() -- What to do if listener fires.
			self:apply_events();
		end,
		true --Is persistent
	);


	-- Debug command to debug events.
	-- Example: trigger_cli_debug_event enable_events_debug()
	core:add_cli_listener("enable_events_debug", 
		function()
			self.debug_mode = true;
		end
	);

	self:add_core_listeners();	
	self:multiplayer_event_listeners();
	self:post_generation_listeners()
end;

--- @function add_prioritised_incidents
--- @desc Adds the specified event(s) to that faction's event list.
--- @p faction_cqi number The CQI of the faction who recieved the events.
--- @p keys string/table A string representing a single event key OR an array of strings.
function cdir_events_manager:add_prioritised_incidents(faction_cqi, keys)
	if not is_number( faction_cqi) then
		script_error("cdir_events_manager:add_prioritised_incidents(): Invalid CQI passed in, must be a number.");
		return;
	end;

	self:enque_events_for_faction( self.queued_prioritised_incidents, faction_cqi, keys );
end;

--- @function add_important_incidents
--- @desc Adds the specified event(s) to that faction's event list.
--- @p faction_cqi number The CQI of the faction who recieved the events.
--- @p keys string/table A string representing a single event key OR an array of strings.
function cdir_events_manager:add_important_incidents(faction_cqi, keys)
	if not is_number( faction_cqi) then
		script_error("cdir_events_manager:add_important_incidents(): Invalid CQI passed in, must be a number.");
		return;
	end;
	
	self:enque_events_for_faction( self.queued_important_incidents, faction_cqi, keys );
end;

--- @function add_standard_incidents
--- @desc Adds the specified event(s) to that faction's event list.
--- @p faction_cqi number The CQI of the faction who recieved the events.
--- @p keys string/table A string representing a single event key OR an array of strings.
function cdir_events_manager:add_standard_incidents(faction_cqi, keys)
	if not is_number( faction_cqi) then
		script_error("cdir_events_manager:add_standard_incidents(): Invalid CQI passed in, must be a number.");
		return;
	end;
	
	self:enque_events_for_faction( self.queued_standard_incidents, faction_cqi, keys );
end;

--- @function add_prioritised_dilemmas
--- @desc Adds the specified event(s) to that faction's event list.
--- @p faction_cqi number The CQI of the faction who recieved the events.
--- @p keys string/table A string representing a single event key OR an array of strings.
function cdir_events_manager:add_prioritised_dilemmas(faction_cqi, keys)
	if not is_number( faction_cqi) then
		script_error("cdir_events_manager:add_prioritised_dilemmas(): Invalid CQI passed in, must be a number.");
		return;
	end;
	
	self:enque_events_for_faction( self.queued_prioritised_dilemmas, faction_cqi, keys );
end;

--- @function add_important_dilemmas
--- @desc Adds the specified event(s) to that faction's event list.
--- @p faction_cqi number The CQI of the faction who recieved the events.
--- @p keys string/table A string representing a single event key OR an array of strings.
function cdir_events_manager:add_important_dilemmas(faction_cqi, keys)
	if not is_number( faction_cqi) then
		script_error("cdir_events_manager:add_important_dilemmas(): Invalid CQI passed in, must be a number.");
		return;
	end;
	
	self:enque_events_for_faction( self.queued_important_dilemmas, faction_cqi, keys );
end;

--- @function add_standard_dilemmas
--- @desc Adds the specified event(s) to that faction's event list.
--- @p faction_cqi number The CQI of the faction who recieved the events.
--- @p keys string/table A string representing a single event key OR an array of strings.
function cdir_events_manager:add_standard_dilemmas(faction_cqi, keys)
	if not is_number( faction_cqi) then
		script_error("cdir_events_manager:add_standard_dilemmas(): Invalid CQI passed in, must be a number.");
		return;
	end;
	
	self:enque_events_for_faction( self.queued_standard_dilemmas, faction_cqi, keys );
end;


--- @function enque_events_for_faction
--- @desc Internal manager use only! Takes a specific data table, a faction annd some events, and adds them to the lists.
--- @p event_data_table object
--- @p faction_cqi object
--- @p new_keys object
function cdir_events_manager:enque_events_for_faction(event_data_table, faction_cqi, new_keys)

	-- Check if we already have event_data for the passed in faction_cqi.
	local faction_exists = false;
	for i, faction_data in ipairs( event_data_table ) do
		if faction_data.cqi == faction_cqi then
			faction_exists = true;
			break;
		end;
	end;

	-- If not, let's construct our data around it.
	if not faction_exists then
		table.insert( event_data_table, { cqi = faction_cqi, keys = {} } );
	end;

	-- Now we definitely have a faction, we can add the keys into that faction's list.
	for i, faction_data in ipairs( event_data_table ) do
		if faction_data.cqi == faction_cqi then

			if is_string( new_keys ) then

				table.insert( faction_data.keys, new_keys );

			elseif is_table( new_keys ) then

				for i, key_to_add in ipairs( new_keys ) do
					table.insert( faction_data.keys, key_to_add );
				end;

			else

				script_error( "cdir_events_manager:enque_events_for_faction(): Invalid keys passed in! Must be a string or a table of strings." );
			end;

			return;
		end;
	end;

end;

--- @function get_num_events_for_faction_from_queue
--- @desc Get all the events for the specified faction cqi, from the passed in queues. Basically strips out all the other data and gives two lists of event keys.
--- @p cqi number the CQI of the faction
--- @p queue The special table stored internally for the events
function cdir_events_manager:get_num_events_for_faction_from_queue(cqi, queue)
	for i, v in ipairs( queue ) do
		if v.cqi == cqi then
			return #v.keys;
		end;
	end;

	return 0;
end;


--- @function get_enqueued_events_for_faction_from_queues
--- @desc Get all the events for the specified faction cqi, from the passed in queues. Basically strips out all the other data and gives two lists of event keys.
--- @p cqi number the CQI of the faction
--- @p incident_queue queue The special table stored internally for the incidents.
--- @p incident_queue queue The special table stored internally for the dilemmas.
function cdir_events_manager:get_enqueued_events_for_faction_from_queues(cqi, incident_queue, dilemma_queue)
	local incident_keys = {};
	local dilemma_keys = {};

	for i, v in ipairs( incident_queue ) do
		if v.cqi == cqi then
			incident_keys = v.keys;
		end;
	end;

	for i, v in ipairs( dilemma_queue ) do
		if v.cqi == cqi then
			dilemma_keys = v.keys;
		end;
	end;

	return incident_keys, dilemma_keys;
end;


--- @function can_apply_events
--- @desc Checks whether it's valid to fire events at this point.
function cdir_events_manager:can_apply_events()
	if not cm:can_modify(true) then
		return false;
	end;

	local query_model = cm:query_model();
	local modify_model = cm:modify_model();

	if not query_model or query_model:is_null_interface() then
		return false;
	end;

	if not modify_model or modify_model:is_null_interface() then
		return false;
	end;

	if query_model:pending_battle() and not query_model:pending_battle():is_null_interface() then
		if query_model:pending_battle():is_active() then
			return false;
		end;
	end;

	return true;
end;

--- @function apply_events
--- @desc Tries to select which sets of events to fire, based on priority order. Also clears out the queued events, at the end.
function cdir_events_manager:apply_events()
	local event_fired = false;
	local human_factions = cm:get_human_factions();
	local incidents = {};
	local dilemmas = {};

	for i, faction_key in ipairs( human_factions ) do
		local query_faction = cm:query_faction(faction_key);	

		if not query_faction or query_faction:is_null_interface() then
			script_error("cdir_events_manager:apply_events(): Query faction is null!")
			return false;
		end;

		local cqi = query_faction:command_queue_index();
		
		self:print("*****   Firing events for " .. faction_key, true);

		-- PRIORITISED EVENTS
		if self:get_num_events_for_faction_from_queue(cqi, self.queued_prioritised_incidents) > 0 or self:get_num_events_for_faction_from_queue(cqi, self.queued_prioritised_dilemmas) > 0 then
			self:print("Has Prioritised", true);
			incidents, dilemmas = self:get_enqueued_events_for_faction_from_queues(cqi, self.queued_prioritised_incidents, self.queued_prioritised_dilemmas);
			event_fired = self:fire_random_event_from_lists(cm:modify_faction( query_faction ), incidents, dilemmas);
		end;

		-- IMPORTANT EVENTS
		if not event_fired and (self:get_num_events_for_faction_from_queue(cqi, self.queued_important_incidents) > 0 or self:get_num_events_for_faction_from_queue(cqi, self.queued_important_dilemmas) > 0) then
			self:print("Has Important", true);
			if self:can_fire_important_events( query_faction ) then
				self:print("Can Fire Important", true);
				incidents, dilemmas = self:get_enqueued_events_for_faction_from_queues(cqi, self.queued_important_incidents, self.queued_important_dilemmas);
				event_fired = self:fire_random_event_from_lists(cm:modify_faction( query_faction ), incidents, dilemmas);
			end;
		end;
		
		-- NORMAL EVENTS
		if not event_fired and (self:get_num_events_for_faction_from_queue(cqi, self.queued_standard_incidents) > 0 or self:get_num_events_for_faction_from_queue(cqi, self.queued_standard_dilemmas) > 0) then
			self:print("Has Normal", true);
			if self:can_fire_events( query_faction ) then -- Checks if we should fire an event using chance and settings.	
				self:print("Can fire normal", true);
				incidents, dilemmas = self:get_enqueued_events_for_faction_from_queues(cqi, self.queued_standard_incidents, self.queued_standard_dilemmas);
				event_fired = self:fire_random_event_from_lists(cm:modify_faction( query_faction ), incidents, dilemmas);
			end;
		end;

		if event_fired then
			self:print("*****   YES Event Fired " .. faction_key, true);
		else
			self:print("*****   NO Event Fired " .. faction_key, true);
		end;
	end;

	-- If we didn't fire an event, consider this an 'action'.
	if not event_fired then
        -- Add an 'action'.
        self:increment_actions_since_last_event();
	else
	-- If we fired an event reset. NB - This also gets fired when an incident or dilemma occurs.
	-- We moved this here are some events share the same trigger and therefore would 'double fire' before the Dilemma/Incident listener would fire.
		self:reset_actions_since_last_event();
    end;

	-- Always clear our keys after were done.
    self:clear_event_queues();

    dec_tab();

    return event_fired;
end;


--- @function clear_event_queues
--- @desc Clears all the queued events for all factions.
function cdir_events_manager:clear_event_queues(faction_cqi)
	self:print("Purging event queues", true);

	-- If we don't get a faction cqi, then clear the whole lot.
	if not faction_cqi then
		self.queued_prioritised_incidents = {};
		self.queued_important_incidents = {};
		self.queued_standard_incidents = {};
		self.queued_prioritised_dilemmas = {};
		self.queued_important_dilemmas = {};
		self.queued_standard_dilemmas = {};

	-- Otherwise, we'll just clear the specified faction's events.
	else
		for i, v in ipairs(self.queued_prioritised_incidents) do
			if v.cqi == faction_cqi then
				v.keys = {};
			end
		end;

		for i, v in ipairs(self.queued_important_incidents) do
			if v.cqi == faction_cqi then
				v.keys = {};
			end
		end;

		for i, v in ipairs(self.queued_standard_incidents) do
			if v.cqi == faction_cqi then
				v.keys = {};
			end
		end;

		for i, v in ipairs(self.queued_prioritised_dilemmas) do
			if v.cqi == faction_cqi then
				v.keys = {};
			end
		end;

		for i, v in ipairs(self.queued_important_dilemmas) do
			if v.cqi == faction_cqi then
				v.keys = {};
			end
		end;

		for i, v in ipairs(self.queued_standard_dilemmas) do
			if v.cqi == faction_cqi then
				v.keys = {};
			end
		end;
	end
end;


function cdir_events_manager:increment_actions_since_last_event()
    self.event_generation_actions_since_last_event = self.event_generation_actions_since_last_event + 1;
end;

function cdir_events_manager:reset_actions_since_last_event()
	self.event_generation_actions_since_last_event = 0;
end;



function cdir_events_manager:can_fire_events( query_faction )
    -- Exit if we cannot fire yet.
	local current_turn = cm:query_model():turn_number();
	
	if self.debug_ignore_event_conditions then
		self:print("Ignoring event conditions", true);
		return true;
	end;

	if current_turn < self.event_generation_standard_start_round then
		self:print("Not reached start round", true);
        return false;
	end;
	
	-- If not enough turns have elapsed, exit.
	if self:rounds_since_last_event( query_faction ) < self.event_generation_min_turns_between_events then
		self:print("Not enough rounds elapsed [" .. tostring(self:rounds_since_last_event( query_faction )) .. " < " .. tostring(self.event_generation_min_turns_between_events) .. "]", true);
        return false;
    end;

    -- If we've not performed enough events yet, then exit.
	if self.event_generation_actions_since_last_event < self.event_generation_min_actions_between_events then
		self:print("Not enough actions elapsed [" .. tostring(self.event_generation_actions_since_last_event) .. " < " .. tostring(self.event_generation_min_actions_between_events) .. "]", true);
        return false;
    end;

    -- Roll a chance based on the min/max for how many actions we should perform.
    local num_actions_over_min_chance = self.event_generation_actions_since_last_event - self.event_generation_min_actions_between_events;
    local chance = self.event_generation_base_chance + ( self.event_generation_chance_per_action * num_actions_over_min_chance );
    chance = math.min( math.max( chance, 0 ), 100); -- Clamp chance between 0 and 100.
    local random_pct = cm:modify_model():random_percentage();

	if random_pct > chance then
		self:print("Random chance failed. chance [" .. tostring(chance) .. "]", true);
        return false;
    end;

    return true;
end;

function cdir_events_manager:can_fire_important_events( query_faction )
	local current_turn = cm:query_model():turn_number();
	
	if self.debug_ignore_event_conditions then
		self:print("Ignoring event conditions", true);
		return true;
	end;

    -- If we've not performed enough events yet, then exit.
	if self:rounds_since_last_event( query_faction ) < self.event_generation_min_turns_between_important_events then
		self:print("Not enough rounds elapsed [" .. tostring(self:rounds_since_last_event( query_faction )) .. " < " .. tostring(self.event_generation_min_turns_between_important_events) .. "]", true);
        return false;
	end;
	
	-- If we've not performed enough events yet, then exit.
	if self.event_generation_actions_since_last_event < self.event_generation_min_actions_between_important_events then
		self:print("Not enough actions elapsed [" .. tostring(self.event_generation_actions_since_last_event) .. " < " .. tostring(self.event_generation_min_actions_between_important_events) .. "]", true);
		return false;
	end;

    return true;
end;



function cdir_events_manager:fire_random_event_from_lists(modify_faction, incident_keys, dilemma_keys)

	if not modify_faction or modify_faction:is_null_interface() then
		script_error("cdir_events_manager:fire_random_event_from_lists() - Modify faction is null!");
		return false;
	end;

	local event_fired = false;
	local incident_fired = false;
	local dilemma_fired = false;
    local fire_immediately = true;
    
    local total_events = #incident_keys + #dilemma_keys;

    if total_events == 0 then
        script_error("cdir_events_manager:fire_random_event_from_lists() - Attmpting to fire a dilemma/incident when we don't have any!");
        return false;
    end;

    local incident_chance = 100 * (#incident_keys / total_events);

    local random_chance = cm:modify_model():random_percentage();

    -- Use a random to decide if we fire an incident or not.
    if incident_chance > 0 and incident_chance >= random_chance then

        incident_fired = modify_faction:trigger_incident( table.concat( incident_keys, "," ), fire_immediately);

        if not incident_fired then -- We want to try to fire something if we can, so attempt the other list.
            dilemma_fired = modify_faction:trigger_dilemma( table.concat( dilemma_keys, "," ), fire_immediately);
        end;
    -- If we didn't fire an incident then we need to trigger a dilemma.
    else

        dilemma_fired = modify_faction:trigger_dilemma( table.concat( dilemma_keys, "," ), fire_immediately);

        if not dilemma_fired and incident_chance > 0 then -- We want to try to fire something if we can, so attempt the other list.
            incident_fired = modify_faction:trigger_incident( table.concat( incident_keys, "," ), fire_immediately);
        end;
    end;

	if incident_fired then
		self:print("Triggered Incident for faction [" .. modify_faction:query_faction():name() .. "]");
		event_fired = true;
	elseif dilemma_fired then
		self:print("Triggered Dilemma for faction [" .. modify_faction:query_faction():name() .. "]");
		event_fired = true;
	end

    return event_fired;
end;


function cdir_events_manager:multiplayer_event_listeners()

	if not cm:is_multiplayer() then
		self:print("CDIR_EVENTS: Not enabling MP mirrors as this is a single player game.");
		return false;
	end;

	core:add_listener(
		"mp_mirror_events", -- Unique handle
		"DilemmaChoiceMadeEvent", -- Campaign Event to listen for
		function(context)
			return not is_nil(self.mp_mirror_events[context:dilemma()]);
		end,
		function(context) -- What to do if listener fires.
			self:trigger_mp_mirror_events( context:faction(), context:dilemma() );
		end,
		true --Is persistent
	);

	core:add_listener(
		"mp_mirror_events", -- Unique handle
		"IncidentOccuredEvent", -- Campaign Event to listen for
		function(context)
			return not is_nil(self.mp_mirror_events[context:incident()]);
		end,
		function(context) -- What to do if listener fires.
			self:trigger_mp_mirror_events( context:faction(), context:incident() );
		end,
		true --Is persistent
	);
end;



function cdir_events_manager:post_generation_listeners()

	core:add_listener(
		"post_trigger_events", -- Unique handle
		"DilemmaChoiceMadeEvent", -- Campaign Event to listen for
		function(context)
			if is_nil(self.post_trigger_actions[context:dilemma()]) then
				return false;
			end;
			
			if self.post_trigger_actions[context:dilemma()][2] ~= nil and self.post_trigger_actions[context:dilemma()][2] ~= context:choice() then
				return false;
			end;

			return true;
		end,
		function(context) -- What to do if listener fires.
			self:trigger_post_generation_events( context:faction(), context:dilemma() );
		end,
		true --Is persistent
	);

	core:add_listener(
		"post_trigger_events", -- Unique handle
		"IncidentOccuredEvent", -- Campaign Event to listen for
		function(context)
			return not is_nil(self.post_trigger_actions[context:incident()]);
		end,
		function(context) -- What to do if listener fires.
			self:trigger_post_generation_events( context:faction(), context:incident() );
		end,
		true --Is persistent
	);
end;


function cdir_events_manager:trigger_mp_mirror_events(triggering_faction, key)
	local humans = cm:get_human_factions();

	for i, faction_key in ipairs(humans) do
		if faction_key ~= triggering_faction:name() then
			self:print("trigger_post_generation_events() Firing mp mirror event for [" .. tostring(key) .. "] for faction [" .. tostring(faction_key) .. "]" );

			local modify_faction = cm:modify_faction( faction_key );
			local mirror_event = self.mp_mirror_events[key];

			if modify_faction and not modify_faction:is_null_interface() then
				local faction_cqi = modify_faction:query_faction():command_queue_index();
				if mirror_event[2] then
					self:add_prioritised_incidents(faction_cqi, mirror_event[1]);
				else
					self:add_prioritised_dilemmas(faction_cqi, mirror_event[1]);
				end;

				self:fire_cdir_event(modify_faction, true, "MP mirror event");
			end;	
		end;
	end;
end;


function cdir_events_manager:trigger_post_generation_events(triggering_faction, key)
	self:print("trigger_post_generation_events() Firing post generation event for [" .. tostring(key) .. "] for faction [" .. tostring(triggering_faction:name()) .. "]" );

	local post_function = self.post_trigger_actions[key][1];

	post_function();
end;



--***********************************************************************************************************
--***********************************************************************************************************
-- HELPERS
--***********************************************************************************************************
--***********************************************************************************************************

function cdir_events_manager:print(string, opt_debug_only)
	if opt_debug_only and not self.debug_mode then
		return;
	end;

	out.events("[101] Events Manager: " .. string);
end;

function cdir_events_manager:get_event_generator_interface()
	return cm:query_model():event_generator_interface();
end;

function cdir_events_manager:get_last_event_round( query_faction )
	local v1 = self:get_last_incident_round( query_faction );
	local v2 = self:get_last_incident_round( query_faction );

	if v2 > v1 then
		return v2;
	end;

	return v1;
end;

function cdir_events_manager:get_last_incident_round( query_faction )
	if not query_faction or query_faction:is_null_interface() then
		script_error("cdir_events_manager: get_last_dilemma_round(): Query Faction is nil, this is not suppported, returning 0");
		return 0;
	end;

	return self:get_event_generator_interface():round_last_valid_incident_was_generated( query_faction );
end;

function cdir_events_manager:get_last_dilemma_round( query_faction )
	if not query_faction or query_faction:is_null_interface() then
		script_error("cdir_events_manager: get_last_dilemma_round(): Query Faction is nil, this is not suppported, returning 0.");
		return 0;
	end;

	return self:get_event_generator_interface():round_last_valid_dilemma_was_generated( query_faction );
end;

function cdir_events_manager:rounds_since_last_event( query_faction )
	local v1 = self:rounds_since_last_incident( query_faction );
	local v2 = self:rounds_since_last_dilemma( query_faction );
	
	if v2 < v1 then
		return v2;
	end;

	return v1;
end;

function cdir_events_manager:rounds_since_last_incident( query_faction )
	return cm:query_model():turn_number() - self:get_last_incident_round( query_faction );
end;

function cdir_events_manager:rounds_since_last_dilemma( query_faction )
	return cm:query_model():turn_number() - self:get_last_dilemma_round( query_faction );
end;

function cdir_events_manager:has_queued_events()
	local num_events = 0;

	for i, v in ipairs(self.queued_prioritised_incidents) do
		num_events = num_events + #v.keys;
	end;

	for i, v in ipairs(self.queued_prioritised_dilemmas) do
		num_events = num_events + #v.keys;
	end;

	for i, v in ipairs(self.queued_important_incidents) do
		num_events = num_events + #v.keys;
	end;

	for i, v in ipairs(self.queued_important_dilemmas) do
		num_events = num_events + #v.keys;
	end;

	for i, v in ipairs(self.queued_standard_incidents) do
		num_events = num_events + #v.keys;
	end;

	for i, v in ipairs(self.queued_standard_dilemmas) do
		num_events = num_events + #v.keys;
	end;

	if num_events > 0 then
		return true;
	end;

	return false;
end;



--***********************************************************************************************************
--***********************************************************************************************************
-- EVENT OUTPUT
--***********************************************************************************************************
--***********************************************************************************************************

cdir_events_manager.event_output_project_path = "\\The Creative Assembly\\ThreeKingdoms\\logs\\"
cdir_events_manager.event_output_filename = "events_output.txt";

function cdir_events_manager:event_output_setup()
	-- Exit if...
	if cm:is_multiplayer() then
		return;
	end;

	if not self.output_events_to_file then
		return;
	end;

	self:print("cdir_events_manager: OUTPUTTING EVENTS TO FILE. REMOVE FOR RELEASE.");

	local output_file = nil;
	
	if self:event_output_file_exists() then
		output_file = io.open(self:event_output_get_output_path(), "a") -- a = append.
		-- Add some extra spacing.
		output_file:write("\n\n");
		output_file:write("---------------------------------------------------------------------------");
		output_file:write("\n\n");
	else
		output_file = io.open(self:event_output_get_output_path(), "w") -- w = write over.
	end;

	if not output_file then
		script_error("Unable to open or create output file.");
		return;
	end;

	output_file:write(os.date());
    output_file:write("\n");
    if cm:get_local_faction() then
        output_file:write("FACTION: " .. cm:get_local_faction());
    end;
	output_file:write("\n");
	output_file:write("\n");

	output_file:close();

	-- Setup listeners
    core:add_listener(
        "cdir_events_event_output_i", -- UID
        "IncidentOccuredEvent", -- Campaign event
        true,
        function(event)
            self:event_output_write_event(
				event:query_model(),
				event:incident(),
				"incident",
				event:faction():name()
			);
        end,
        true
    );

    core:add_listener(
        "cdir_events_event_output_d", -- UID
        "DilemmaIssuedEvent", -- Campaign event
        true,
        function(event)
            self:event_output_write_event(
				event:query_model(),
				event:dilemma(),
				"dilemma",
				event:faction():name()
			);
        end,
        true
	);

	core:add_listener(
        "cdir_events_event_output_m", -- UID
        "MissionIssued", -- Campaign event
        true,
        function(event)
            self:event_output_write_event(
				event:query_model(),
				event:mission():mission_record_key() .. "\t" .. event:mission():mission_issuer_record_key(),
				"mission",
				event:faction():name()
			);
        end,
        true
	);

end;

function cdir_events_manager:event_output_write_event(query_model, event_key, type, faction_name)
	local output_file = io.open(self:event_output_get_output_path(), "a") -- a = append.
	
	if not output_file then
		script_error("Unable to open or create output file.");
		return;
	end;

	output_file:write( query_model:turn_number() .. "\t" .. faction_name .. "\t" .. type .. "\t" .. event_key );
	output_file:write("\n");

	output_file:close();
end;

function cdir_events_manager:event_output_get_output_path()
	local app_data_path = os.getenv('APPDATA');

	return app_data_path .. self.event_output_project_path .. self.event_output_filename;
end;

function cdir_events_manager:event_output_file_exists()
	local name = self:event_output_get_output_path();
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
 end



--***********************************************************************************************************
--***********************************************************************************************************
-- SAVE LOAD
--***********************************************************************************************************
--***********************************************************************************************************


function cdir_events_manager:register_save_load_callbacks()
	cm:add_saving_game_callback(
		function(saving_game_event)
			cm:save_named_value("event_generation_actions_since_last_event", self.event_generation_actions_since_last_event);
		end
	);


	cm:add_loading_game_callback(
		function(loading_game_event)
			local load_tbl =  cm:load_named_value("event_generation_actions_since_last_event", self.event_generation_actions_since_last_event);

			self.event_generation_actions_since_last_event = load_tbl;
		end
	);
end;

cdir_events_manager:register_save_load_callbacks();