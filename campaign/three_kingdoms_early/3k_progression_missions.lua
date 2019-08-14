-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Progression Missions -------------------------------
-------------------------------------------------------------------------------
------------------------- Created by Leif: 22/11/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

out("3k_progression_missions.lua: Loading");

function start_progression_mission_listener(faction_key, mission_key, objective, conditions, mission_rewards, trigger_event, completion_event, precondition, failure_event)
  
    if not is_string(faction_key) then
        script_error("ERROR: start_progression_mission_listener() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string")
        return false;
    end;

    if not is_string(mission_key) then
        script_error("ERROR: start_progression_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;

    if not is_string(objective) then
        script_error("ERROR: start_progression_mission_listener() called but supplied objective key [" .. tostring(objective) .. "] is not a string")
        return false;
    end;

	if conditions then
		if is_string(conditions) then
			conditions = {conditions};
		
		else
			if not is_table(conditions) then
				script_error("ERROR: start_progression_mission_listener() called but supplied conditions list [" .. tostring(conditions) .. "] is not a table")
				return false;
			end;

			if #conditions == 0 then
				script_error("ERROR: start_progression_mission_listener() called but supplied conditions list [" .. tostring(conditions) .. "] is empty")
				return false;
			end;
		
			for i = 1, #conditions do
				if not is_string(conditions[i]) then
					script_error("ERROR: start_progression_mission_listener() called but element [" .. i .. "] in supplied conditions list is [" .. tostring(conditions[i]) .. "] and not a string")
					return false;
				end;
			end;
		end;
	end;

    if not mission_rewards then
		mission_rewards = {"money 100"};
	end;
	
	if not is_table(mission_rewards) then
		script_error("ERROR: start_progression_mission_listener() called but supplied mission rewards [" .. mission_rewards .. "] is not a table");
		return false;
	end;
	
	if #mission_rewards == 0 then
		script_error("ERROR: start_progression_mission_listener() called but supplied mission rewards table is empty");
		return false;
	end;
	
	for i = 1, #mission_rewards do
		if not is_string(mission_rewards[i]) then
			script_error("ERROR: start_progression_mission_listener() called but supplied mission reward [" .. i .. "] is [" .. tostring(mission_rewards[i]) .. "] and not a string");
			return false;
		end;
    end;

    if not is_string(trigger_event) then
        script_error("ERROR: start_progression_mission_listener() called but supplied trigger event [" .. tostring(trigger_event) .. "] is not a string")
        return false;
    end;

    if not is_string(completion_event) then
        script_error("ERROR: start_progression_mission_listener() called but supplied success event [" .. tostring(completion_event) .. "] is not a string")
        return false;
    end;

    if precondition and not is_function(precondition) then
        script_error("ERROR: start_progression_mission_listener() called but supplied precondition [" .. tostring(precondition) .. "] is not a function or nil")
        return false;
    end;

    if failure_event and not is_string(failure_event) then
        script_error("ERROR: start_progression_mission_listener() called but supplied failure event [" .. tostring(failure_event) .. "] is not a string or nil")
        return false;
    end;

    -- function mission_manager:new(faction_name, mission_key, success_callback, failure_callback, cancellation_callback, nearing_expiry_callback)
    -- set up mission manager
    local mm = mission_manager:new(
        faction_key,
        mission_key,
        function()
            core:trigger_event(completion_event)
        end,
        function()
            core:trigger_event(completion_event) 
        end,
        function()
            core:trigger_event(completion_event)
        end
    )
    
    -- progression_missions:store_dong_zhuo_mission_cqi();

    -- core:trigger_event("ProgressionMissionIssued");
    
    mm:set_mission_issuer("3k_main_victory_objective_issuer");

    mm:add_new_objective(objective);

	if conditions then
		for i = 1, #conditions do
			mm:add_condition(conditions[i]);
		end;
	end;

    for i = 1, #mission_rewards do
		mm:add_payload(mission_rewards[i]);
    end;

    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then
        out("Starting progression mission listener for faction " .. faction_key .. ", mission_key is " .. mission_key .. " as the mission has not yet been triggered")

        -- master listener
        core:add_listener(
            "progression_mission_listener_" .. faction_key .. "_" .. mission_key,
            trigger_event,
            true,
            function()
                if not precondition or precondition() then
                    out("start_progression_mission_listener() has received event " .. trigger_event .. " and either no precondition specified or the precondition passes, so triggering mission " .. mission_key .. " for faction " .. faction_key);
                    mm:trigger();
                else
                    local event_to_trigger = failure_event;
                    if not event_to_trigger then
                        event_to_trigger = completion_event;
                    end;
                    out("start_progression_mission_listener() has received event " .. trigger_event .. " but the specified precondition failed - triggering event " .. event_to_trigger);
                    core:trigger_event(event_to_trigger);
                end;
            end,
            false
        )
    end;
   
end;


-- function progression_missions:store_dong_zhuo_mission_cqi()

--     core:add_listener(
--         "dong_zhuo_mission_cqi", -- UID
--         "ProgressionMissionIssued", -- Event
--         function()
--             if (string.find(mission_key,"3k_main_victory_objective_chain_0")) then 
--                 return true;
--             end        
--         end, --Conditions for firing
--         function(mission_issued_event)
--             progression_missions.cqi = mission_issued_event:mission():cqi();
--         end, -- Function to fire.
--         true -- Is Persistent?
--     );

-- end

-- function progression_missions:cancel_dong_zhuo_mission_and_trigger_failure()

--     core:add_listener(
--         "dong_zhuo_mission_cancel", -- UID
--         "ProgressionMissionCancellation", -- Event
--         true, --Conditions for firing
--         function(event)
--             local mission = event:get_modify_mission_by_cqi(cqi);
--             mission.cancel();
--         end, -- Function to fire.
--         true -- Is Persistent?
--     );

-- end


---------------------------------------------------------------------------------------------------------
----- SAVE/LOAD
---------------------------------------------------------------------------------------------------------
-- function progression_missions:register_save_load_callbacks()
--     cm:add_saving_game_callback(
--         function(saving_game_event)
--             cm:save_named_value("faction_council_last_trigger_turn", self.last_trigger_turn);
--             cm:save_named_value("faction_council_current_mission_cqi_list", self.current_mission_cqi_list);
--         end
--     );

--     cm:add_loading_game_callback(
--         function(loading_game_event)
--             local l_last_trigger_turn =  cm:load_named_value("faction_council_last_trigger_turn", self.last_trigger_turn);
--             local l_mission_cqi_list =  cm:load_named_value("faction_council_current_mission_cqi_list", self.current_mission_cqi_list);

--             self.last_trigger_turn = l_last_trigger_turn;
--             self.current_mission_cqi_list = l_mission_cqi_list;
--         end
--     );
-- end;

-- progression_missions:register_save_load_callbacks();