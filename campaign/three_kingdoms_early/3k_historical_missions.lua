-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Historical Missions -------------------------------
-------------------------------------------------------------------------------
------------------------- Created by Nic: 04/09/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

out("3k_historical_missions.lua: Loading");

function start_historical_mission_listener(faction_key, mission_key, objective, conditions, mission_rewards, trigger_event, completion_event, precondition, failure_event, optional_mission_issuer)
	optional_mission_issuer = optional_mission_issuer or "SHOGUN";

    if not is_string(faction_key) then
        script_error("ERROR: start_historical_mission_listener() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string")
        return false;
    end;

    if not is_string(mission_key) then
        script_error("ERROR: start_historical_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;

    if not is_string(objective) then
        script_error("ERROR: start_historical_mission_listener() called but supplied objective key [" .. tostring(objective) .. "] is not a string")
        return false;
    end;

	if conditions then
		if is_string(conditions) then
			conditions = {conditions};
		
		else
			if not is_table(conditions) then
				script_error("ERROR: start_historical_mission_listener() called but supplied conditions list [" .. tostring(conditions) .. "] is not a table")
				return false;
			end;

			if #conditions == 0 then
				script_error("ERROR: start_historical_mission_listener() called but supplied conditions list [" .. tostring(conditions) .. "] is empty")
				return false;
			end;
		
			for i = 1, #conditions do
                if not is_string(conditions[i]) and not is_number(conditions[i]) then
					script_error("ERROR: start_historical_mission_listener() called but element [" .. i .. "] in supplied conditions list is [" .. tostring(conditions[i]) .. "] and not a string or a number")
                    return false;
				end;
			end;
		end;
	end;

    if not mission_rewards then
		mission_rewards = {"money 100"};
	end;
	
	if not is_table(mission_rewards) then
		script_error("ERROR: start_historical_mission_listener() called but supplied mission rewards [" .. mission_rewards .. "] is not a table");
		return false;
	end;
	
	if #mission_rewards == 0 then
		script_error("ERROR: start_historical_mission_listener() called but supplied mission rewards table is empty");
		return false;
	end;
	
	for i = 1, #mission_rewards do
		if not is_string(mission_rewards[i]) then
			script_error("ERROR: start_historical_mission_listener() called but supplied mission reward [" .. i .. "] is [" .. tostring(mission_rewards[i]) .. "] and not a string");
			return false;
		end;
    end;

    if not is_string(trigger_event) then
        script_error("ERROR: start_historical_mission_listener() called but supplied trigger event [" .. tostring(trigger_event) .. "] is not a string")
        return false;
    end;

	if completion_event and not is_string(completion_event) then
        script_error("ERROR: start_historical_mission_listener() called but supplied success event [" .. tostring(completion_event) .. "] is not a string")
        return false;
    end;

    if precondition and not is_function(precondition) then
        script_error("ERROR: start_historical_mission_listener() called but supplied precondition [" .. tostring(precondition) .. "] is not a function or nil")
        return false;
    end;

    if failure_event and not is_string(failure_event) then
        script_error("ERROR: start_historical_mission_listener() called but supplied failure event [" .. tostring(failure_event) .. "] is not a string or nil")
        return false;
    end;

    -- set up mission manager
    local mm = mission_manager:new(
        faction_key,
        mission_key,
        function()
			if completion_event then
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been successfully completed, triggering event [" .. completion_event .. "]")
				core:trigger_event(completion_event)
			else
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been successfully completed, no completion event specified")
			end;
        end,
        function()
			local event_to_use = failure_event;
			if not event_to_use then
				event_to_use = completion_event;
			end;
			
			if completion_event then
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been failed, triggering event [" .. event_to_use .. "]")
				core:trigger_event(event_to_use)
			else
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been failed, no completion or failure event specified")
			end;
        end,
        function()
			local event_to_use = failure_event;
			if not event_to_use then
				event_to_use = completion_event;
			end;
			
			if completion_event then
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been failed, triggering event [" .. event_to_use .. "]")
				core:trigger_event(event_to_use)
			else
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been failed, no completion or failure event specified")
			end;
        end
    );


	mm:set_mission_issuer(optional_mission_issuer);

    mm:add_new_objective(objective);

	if conditions and objective ~= "OWN_N_UNITS" then
		for i = 1, #conditions do
			mm:add_condition(conditions[i]);
		end;
	end;

    for i = 1, #mission_rewards do
		mm:add_payload(mission_rewards[i]);
    end;

    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then
        out("Starting historical mission listener for faction " .. faction_key .. ", mission_key is " .. mission_key .. " as the mission has not yet been triggered")

        -- master listener
        core:add_listener(
            "historical_mission_listener_" .. faction_key .. "_" .. mission_key,
            trigger_event,
            true,
            function()
                if not precondition or precondition() then
                    out("start_historical_mission_listener() has received event " .. trigger_event .. " and either no precondition specified or the precondition passes, so triggering mission " .. mission_key .. " for faction " .. faction_key);
                    
                    -- special case for own_n_units, calculate the condition at the point we trigger the mission
                    if objective == "OWN_N_UNITS" then
                        mm:add_condition("total " .. get_player_number_of_units() + conditions[1])
                    end;

                    -- special case for engage_force, get the cqi of the nearest military force at the point we trigger the mission
                    if objective == "ENGAGE_FORCE" then
                        mm:add_condition("cqi " .. get_cqi_of_nearest_enemy(conditions[1]))
                    end;

                    mm:trigger();
                else
                    local event_to_trigger = failure_event;
                    if not event_to_trigger then
                        event_to_trigger = completion_event;
                    end;
                    out("start_historical_mission_listener() has received event " .. trigger_event .. " but the specified precondition failed - triggering event " .. event_to_trigger);
                    core:trigger_event(event_to_trigger);
                end;
            end,
            false
        )
    end;
end;

function get_cqi_of_nearest_enemy(enemy_faction)
    local faction_leader = cm:query_local_faction():faction_leader();

    return cm:get_closest_general_to_position_from_faction(enemy_faction:gsub("faction ", ""), faction_leader:logical_position_x(), faction_leader:logical_position_y(), false):military_force():command_queue_index();
end;

function get_player_number_of_units()
    local forces = cm:query_model():local_faction():military_force_list()
    local unit_count = 0
    for i = 0, forces:num_items() - 1 do
        local current_mf = forces:item_at(i);

        if not current_mf:is_armed_citizenry() then
            local units = current_mf:unit_list():num_items()
            unit_count = unit_count + units
            output("~~~ Tutorial mission unit counter is now " .. unit_count)
        end;
    end

    return unit_count;
end;

-- start a historical mission listener to cancel missions
function start_historical_mission_cancel_listener(faction_key, mission_keys, failure_event)
    
    if not is_string(faction_key) then
        script_error("ERROR: start_historical_mission_cancel_listener() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string")
        return false;
    end;

    if mission_keys then
		if is_string(mission_keys) then
			mission_keys = {mission_keys};
		
		else
			if not is_table(mission_keys) then
				script_error("ERROR: start_historical_mission_cancel_listener() called but supplied conditions list [" .. tostring(mission_keys) .. "] is not a table")
				return false;
			end;

			if #mission_keys == 0 then
				script_error("ERROR: start_historical_mission_cancel_listener() called but supplied conditions list [" .. tostring(mission_keys) .. "] is empty")
				return false;
			end;
		
			for i = 1, #mission_keys do
                if not is_string(mission_keys[i]) and not is_number(mission_keys[i]) then
					script_error("ERROR: start_historical_mission_cancel_listener() called but element [" .. i .. "] in supplied conditions list is [" .. tostring(mission_keys[i]) .. "] and not a string or a number")
                    return false;
				end;
			end;
		end;
    end;
    
    if failure_event and not is_string(failure_event) then
        script_error("ERROR: start_historical_mission_cancel_listener() called but supplied failure event [" .. tostring(failure_event) .. "] is not a string or nil")
        return false;
    end;
    
    core:add_listener(
        "historical mission cancel listener",
        "FactionFameLevelUp",
        function(context)
            if context:faction():progression_level() >= 1 then
                return context:faction():is_human()
            end
        end,
        function()
            for i = 1, #mission_keys do
                cm:cancel_custom_mission(faction_key, mission_keys[i])
                core:remove_listener("historical_mission_listener_" .. faction_key .. "_" .. mission_keys[i])
                core:trigger_event(failure_event)
                out("Canceling intro mission " .. mission_keys[i] .. " as faction rank up has happened!")
            end;
        end
    )
end;


-- start a historical mission listener where the mission data is set up in the database
function start_historical_mission_db_listener(faction_key, mission_key, trigger_event, completion_event, precondition, failure_event)
  
    if not is_string(faction_key) then
        script_error("ERROR: start_historical_mission_listener() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string")
        return false;
    end;

    if not is_string(mission_key) then
        script_error("ERROR: start_historical_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;
	
    if not is_string(trigger_event) then
        script_error("ERROR: start_historical_mission_listener() called but supplied trigger event [" .. tostring(trigger_event) .. "] is not a string")
        return false;
    end;

    if completion_event and not is_string(completion_event) then
        script_error("ERROR: start_historical_mission_listener() called but supplied success event [" .. tostring(completion_event) .. "] is not a string")
        return false;
    end;

    if precondition and not is_function(precondition) then
        script_error("ERROR: start_historical_mission_listener() called but supplied precondition [" .. tostring(precondition) .. "] is not a function or nil")
        return false;
    end;

    if failure_event and not is_string(failure_event) then
        script_error("ERROR: start_historical_mission_listener() called but supplied failure event [" .. tostring(failure_event) .. "] is not a string or nil")
        return false;
    end;

    -- set up mission manager
    local mm = mission_manager:new(
        faction_key,
        mission_key,
        function()
			if completion_event then
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been successfully completed, triggering event [" .. completion_event .. "]")
				core:trigger_event(completion_event)
			else
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been successfully completed, no completion event specified")
			end;
        end,
        function()
			local event_to_use = failure_event;
			if not event_to_use then
				event_to_use = completion_event;
			end;
			
			if completion_event then
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been failed, triggering event [" .. event_to_use .. "]")
				core:trigger_event(event_to_use)
			else
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been failed, no completion or failure event specified")
			end;
        end,
        function()
			local event_to_use = failure_event;
			if not event_to_use then
				event_to_use = completion_event;
			end;
			
			if completion_event then
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been failed, triggering event [" .. event_to_use .. "]")
				core:trigger_event(event_to_use)
			else
				out("start_historical_mission_db_listener(): mission [" .. mission_key .. "] has been failed, no completion or failure event specified")
			end;
        end
    );
	
	-- set the mission manager to look in the db for the mission type/conditions/payloads etc
	mm:set_should_trigger_from_db(true);
	
    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then
        out("Starting historical mission listener for faction " .. faction_key .. ", mission_key is " .. mission_key .. " (from db) as the mission has not yet been triggered")

        -- master listener
        core:add_listener(
            "historical_mission_listener_" .. faction_key .. "_" .. mission_key,
            trigger_event,
            true,
            function()
                if not precondition or precondition() then
                    out("start_historical_mission_listener() has received event " .. trigger_event .. " and either no precondition specified or the precondition passes, so triggering mission " .. mission_key .. " for faction " .. faction_key);
                    mm:trigger();
                else
                    local event_to_trigger = failure_event;
                    if not event_to_trigger then
                        event_to_trigger = completion_event;
                    end;
                    out("start_historical_mission_listener() has received event " .. trigger_event .. " but the specified precondition failed - triggering event " .. event_to_trigger);
                    core:trigger_event(event_to_trigger);
                end;
            end,
            false
        )
    end;
end;