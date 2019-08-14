-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Introduction Missions -------------------------------
-------------------------------------------------------------------------------
------------------------- Created by Nic: 29/05/2018 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

output("3k_tutorial_missions.lua: Loading");


-- Returns true if we should be starting introduction missions (depending on tweaker settings/player choices), false otherwise

function should_start_tutorial_missions()
	return not core:is_tweaker_set("FORCE_DISABLE_TUTORIAL");
end;

function start_tutorial_mission_listener(faction_key, mission_key, objective, conditions, mission_rewards, trigger_event, completion_event, precondition, failure_event)
	start_historical_mission_listener(faction_key, mission_key, objective, conditions, mission_rewards, trigger_event, completion_event, precondition, failure_event, "CLAN_ELDERS");
end;

function start_tutorial_mission_cancel_listener(faction_key, mission_keys, failure_event)
	start_historical_mission_cancel_listener(faction_key, mission_keys, failure_event);
end;

-- Generate a chain of missions that serves as the introduction
-- Engage force, catpure region, capture province, reach progression rank
-- Civic construct building, recruit units

function start_tutorial_defeat_army_mission_listener(mission_key, enemy_faction, cqi, mission_rewards)
  
    if not is_string(mission_key) then
        script_error("ERROR: start_tutorial_defeat_army_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;

    if not is_string(enemy_faction) then
        script_error("ERROR: start_tutorial_defeat_army_mission_listener() called but supplied enemy faction key [" .. tostring(enemy_faction) .. "] is not a string")
        return false;
    end;

    if not is_number(cqi) then
        script_error("ERROR: start_tutorial_capture_province_mission_listener() called but supplied cqi [" .. tostring(cqi) .. "] is not a number")
        return false;
    end;    

    if not mission_rewards then
		mission_rewards = {"money 100"};
	end;
	
	if not is_table(mission_rewards) then
		script_error("ERROR: start_tutorial_defeat_army_mission_listener() called but supplied mission rewards [" .. mission_rewards .. "] is not a table");
		return false;
	end;
	
	if #mission_rewards == 0 then
		script_error("ERROR: start_tutorial_defeat_army_mission_listener() called but supplied mission rewards table is empty");
		return false;
	end;
	
	for i = 1, #mission_rewards do
		if not is_string(mission_rewards[i]) then
			script_error("ERROR: start_tutorial_defeat_army_mission_listener() called but supplied mission reward [" .. i .. "] is [" .. tostring(mission_rewards[i]) .. "] and not a string");
			return false;
		end;
    end;
    
    local local_faction = cm:get_local_faction();

    -- set up mission manager
    output("Mission completed triggering follow up missions, local faction is " .. local_faction .. " and mission_key is " .. mission_key)

    local mm = mission_manager:new(
        local_faction,
        mission_key,
        function()
            core:trigger_event("ScriptEventTutorialDefeatForceMissionSucceeded")
            --cm:add_turn_countdown_event(local_faction, 1,"ScriptEventTutorialDefeatForceMissionSucceededConstruction")
        end
    )

    mm:add_new_objective("ENGAGE_FORCE");
	mm:add_condition("faction " .. enemy_faction);
	if cqi then
		mm:add_condition("cqi " .. cqi);
	end;
    mm:add_condition("armies_only");

    for i = 1, #mission_rewards do
		mm:add_payload(mission_rewards[i]);
    end;

    local listener_name = "tutorial_defeat_force_mission_listener";
    local trigger_event_name = "ScriptEventTriggerTutorialDefeatForceMission"
    
    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then

        -- master listener
        core:add_listener(
            listener_name,
            trigger_event_name,
            true,
            function()
                core:remove_listener(listener_name);
                mm:trigger();
            end,
            false
        )
		
		if should_start_tutorial_missions() then
			core:add_listener(
				listener_name,
				"ScriptEventStartTutorialMissions",
				true,
				function()
					core:trigger_event(trigger_event_name)
				end,
				false
			)
		end;
    end;
end;

function start_tutorial_capture_settlement_mission_listener(mission_key, total, target_id, mission_rewards)

    if not is_string(mission_key) then
        script_error("ERROR: start_tutorial_capture_settlement_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;

    local bool_target_is_region = true;

	if is_string(target_id) then
		if not cm:region_exists(target_id) then
			script_error("ERROR: start_tutorial_capture_settlement_mission_listener() called but no region with supplied name [" .. target_id .. "] could be found");
			return false;
        end;

    if not is_number(total) then
        script_error("ERROR: start_tutorial_capture_province_mission_listener() called but supplied total [" .. total .. "] is not a number")
        return false;
    end;       

    elseif is_number(target_id) then	
        bool_target_is_region = false;
    else
        script_error("ERROR: start_tutorial_capture_settlement_mission_listener() called but supplied enemy target [" .. tostring(target_id) .. "] is not a string or a number");
        return false;
    end;

    if not mission_rewards then
		mission_rewards = {"money 100"};
	end;
	
	if not is_table(mission_rewards) then
		script_error("ERROR: start_tutorial_capture_settlement_mission_listener() called but supplied mission rewards [" .. mission_rewards .. "] is not a table");
		return false;
	end;
	
	if #mission_rewards == 0 then
		script_error("ERROR: start_tutorial_capture_settlement_mission_listener() called but supplied mission rewards table is empty");
		return false;
	end;
	
	for i = 1, #mission_rewards do
		if not is_string(mission_rewards[i]) then
			script_error("ERROR: start_tutorial_capture_settlement_mission_listener() called but supplied mission reward [" .. i .. "] is [" .. tostring(mission_rewards[i]) .. "] and not a string");
			return false;
		end;
	end;

    local local_faction = cm:get_local_faction();
    output("Capture settlement triggering follow up missions, local faction is " .. local_faction .. " and mission_key is " .. mission_key)

    -- set up mission manager
    local mm = mission_manager:new(
        cm:get_local_faction(),
        mission_key,
        function() core:trigger_event("ScriptEventTutorialCaptureSettlementMissionSucceeded") end
    )

    mm:add_new_objective("OWN_N_REGIONS_INCLUDING");
    mm:add_condition("total " .. total);
    mm:add_condition("region " .. target_id);

    for i = 1, #mission_rewards do
		mm:add_payload(mission_rewards[i]);
    end;

    local listener_name = "tutorial_capture_settlement_mission_listener";
    local trigger_event_name = "ScriptEventTriggerTutorialCaptureSettlementMission"
    
    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then

        -- master listener
        core:add_listener(
            listener_name,
            trigger_event_name,
            true,
            function()
                core:remove_listener(listener_name);
                cm:progress_on_battle_completed(
                    "start_next_intro_mission",
                    function()
                        mm:trigger()
                    end
                );
            end,
            false
        );

        core:add_listener(
            listener_name,
            "ScriptEventTutorialDefeatForceMissionSucceeded",
            true,
            function()
                core:trigger_event(trigger_event_name)
            end,
            false
        )
    end;
end;

function start_tutorial_capture_province_mission_listener(mission_key, total, mission_rewards)

    if not is_string(mission_key) then
        script_error("ERROR: start_tutorial_capture_province_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;

    if not is_number(total) then
        script_error("ERROR: start_tutorial_capture_province_mission_listener() called but supplied total [" .. total .. "] is not a number")
        return false;
    end;

    if not mission_rewards then
		mission_rewards = {"money 100"};
	end;
	
	if not is_table(mission_rewards) then
		script_error("ERROR: start_tutorial_capture_province_mission_listener() called but supplied mission rewards [" .. mission_rewards .. "] is not a table");
		return false;
	end;
	
	if #mission_rewards == 0 then
		script_error("ERROR: start_tutorial_capture_province_mission_listener() called but supplied mission rewards table is empty");
		return false;
	end;
	
	for i = 1, #mission_rewards do
		if not is_string(mission_rewards[i]) then
			script_error("ERROR: start_tutorial_capture_province_mission_listener() called but supplied mission reward [" .. i .. "] is [" .. tostring(mission_rewards[i]) .. "] and not a string");
			return false;
		end;
	end;


    -- set up mission manager
    local mm = mission_manager:new(
        cm:get_local_faction(),
        mission_key,
        function() core:trigger_event("ScriptEventTutorialCaptureProvinceMissionSucceeded") end
    )

    mm:add_new_objective("OWN_N_PROVINCES");
    mm:add_condition("total " .. total);

    for i = 1, #mission_rewards do
		mm:add_payload(mission_rewards[i]);
    end;

    local listener_name = "tutorial_capture_province_mission_listener";
    local trigger_event_name = "ScriptEventTriggerTutorialCaptureProvinceMission"
    
    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then

        -- master listener
        core:add_listener(
            listener_name,
            trigger_event_name,
            true,
            function()
                core:remove_listener(listener_name);
                mm:trigger();
            end,
            false
        )

        core:add_listener(
            listener_name,
            "ScriptEventTutorialCaptureSettlementMissionSucceeded",
            true,
            function()
                core:trigger_event(trigger_event_name)
            end,
            false
        )
    end;
end;


function start_tutorial_reach_progression_rank_mission_listener(mission_key, progression_level, mission_rewards)

    
    
    if not is_string(mission_key) then
        script_error("ERROR: start_tutorial_reach_progression_rank_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;

    if not is_number(progression_level) then
        script_error("ERROR: start_tutorial_reach_progression_rank_mission_listener() called but supplied progression level [" .. progression_level .. "] is not a number")
        return false;
    end;

    if not mission_rewards then
		mission_rewards = {"money 100"};
	end;
	
	if not is_table(mission_rewards) then
		script_error("ERROR: start_tutorial_reach_progression_rank_mission_listener() called but supplied mission rewards [" .. mission_rewards .. "] is not a table");
		return false;
	end;
	
	if #mission_rewards == 0 then
		script_error("ERROR: start_tutorial_reach_progression_rank_mission_listener() called but supplied mission rewards table is empty");
		return false;
	end;
	
	for i = 1, #mission_rewards do
		if not is_string(mission_rewards[i]) then
			script_error("ERROR: start_tutorial_reach_progression_rank_mission_listener() called but supplied mission reward [" .. i .. "] is [" .. tostring(mission_rewards[i]) .. "] and not a string");
			return false;
		end;
    end;
    
    local local_faction = cm:get_local_faction();

    -- set up mission manager
    local mm = mission_manager:new(
        local_faction,
        mission_key,
        function() core:trigger_event("ScriptEventTutorialProgressionRankMissionSucceeded") end
    )

    --mm:add_new_objective("ATTAIN_FACTION_PROGRESSION_LEVEL");
    mm:add_new_objective("ATTAIN_FACTION_PROGRESSION_LEVEL");
    mm:add_condition("total " .. progression_level);

    for i = 1, #mission_rewards do
		mm:add_payload(mission_rewards[i]);
    end;

    local listener_name = "tutorial_progression_rank_mission_listener";
    local trigger_event_name = "ScriptEventTriggerTutorialProgressionRankMission"
    
    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then

        -- master listener
        core:add_listener(
            listener_name,
            trigger_event_name,
            true,
            function()
                core:remove_listener(listener_name);
                mm:trigger();
            end,
            false
        )    
    
        core:add_listener(
            listener_name,
            "ScriptEventTutorialCaptureProvinceMissionSucceeded",
            function()
                local local_progression_level = cm:query_local_faction():progression_level();

                -- Stop mission triggering if progression level has already been reached
                if local_progression_level < progression_level then
                    return true
                end
            end,
            function()
                core:trigger_event(trigger_event_name)
            end,
            false
        )
    end;
end;


function start_tutorial_construct_building_mission_listener(mission_key, building_chain, mission_rewards)

    if not is_string(mission_key) then
        script_error("ERROR: start_tutorial_construct_building_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;

    if not is_string(building_chain) then
        script_error("ERROR: start_tutorial_construct_building_mission_listener() called but supplied building chain key [" .. tostring(building_chain) .. "] is not a string")
        return false;
    end;

    if not mission_rewards then
		mission_rewards = {"money 100"};
    end;
	
	if not is_table(mission_rewards) then
		script_error("ERROR: start_tutorial_construct_building_mission_listener() called but supplied mission rewards [" .. mission_rewards .. "] is not a table");
		return false;
	end;
	
	if #mission_rewards == 0 then
		script_error("ERROR: start_tutorial_construct_building_mission_listener() called but supplied mission rewards table is empty");
		return false;
	end;
	
	for i = 1, #mission_rewards do
		if not is_string(mission_rewards[i]) then
			script_error("ERROR: start_tutorial_construct_building_mission_listener() called but supplied mission reward [" .. i .. "] is [" .. tostring(mission_rewards[i]) .. "] and not a string");
			return false;
		end;
	end;

    local local_faction = cm:get_local_faction();

    -- set up mission manager
    local mm = mission_manager:new(
        cm:get_local_faction(),
        mission_key,
        function() core:trigger_event("ScriptEventTutorialConstructBuildingMissionSucceeded") end
    )

    mm:add_new_objective("CONSTRUCT_ANY_BUILDING");

--[[
    mm:add_new_objective("CONSTRUCT_BUILDINGS");
    mm:add_new_objective("CONSTRUCT_BUILDINGS");
    mm:add_condition("faction " .. local_faction);
    mm:add_condition("total " .. building_count);

    mm:add_new_objective("CONSTRUCT_BUILDINGS_INCLUDING");
    mm:add_condition("faction " .. local_faction);
    mm:add_condition("total 1");
    mm:add_condition("building_chain " .. building_chain);

    mm:add_new_objective("CONSTRUCT_N_OF_A_BUILDING");
    mm:add_condition("faction " .. local_faction);
    mm:add_condition("total " .. building_count);
]]--

    for i = 1, #mission_rewards do
		mm:add_payload(mission_rewards[i]);
    end;

    local listener_name = "tutorial_construct_building_mission_listener";
    local trigger_event_name = "ScriptEventTriggerTutorialConstructBuildingMission"
    
    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then

        -- master listener
        core:add_listener(
            listener_name,
            trigger_event_name,
            true,
            function()
                core:remove_listener(listener_name);
                mm:trigger();
            end,
            false
        )

        core:add_listener(
            listener_name,
            "ScriptEventStartTutorialMissions",
            true,
            function()
                core:trigger_event(trigger_event_name)
            end,
            false
        )
    end;
end;


function start_tutorial_recruit_units_mission_listener(mission_key, unit_count, mission_rewards)

    if not is_string(mission_key) then
        script_error("ERROR: start_tutorial_recruit_units_mission_listener() called but supplied mission key [" .. tostring(mission_key) .. "] is not a string")
        return false;
    end;

    if not is_number(unit_count) then
        script_error("ERROR: start_tutorial_reach_progression_rank_mission_listener() called but supplied unit count [" .. unit_count .. "] is not a number")
        return false;
    end;

    if not mission_rewards then
		mission_rewards = {"money 100"};
	end;
	
	if not is_table(mission_rewards) then
		script_error("ERROR: start_tutorial_recruit_units_mission_listener() called but supplied mission rewards [" .. mission_rewards .. "] is not a table");
		return false;
	end;
	
	if #mission_rewards == 0 then
		script_error("ERROR: start_tutorial_recruit_units_mission_listener() called but supplied mission rewards table is empty");
		return false;
	end;
	
	for i = 1, #mission_rewards do
		if not is_string(mission_rewards[i]) then
			script_error("ERROR: start_tutorial_recruit_units_mission_listener() called but supplied mission reward [" .. i .. "] is [" .. tostring(mission_rewards[i]) .. "] and not a string");
			return false;
		end;
	end;

    local local_faction = cm:get_local_faction();

    -- set up mission manager
    local mm = mission_manager:new(
        cm:get_local_faction(),
        mission_key,
        function() core:trigger_event("ScriptEventTutorialRecruitUnitsMissionSucceeded") end
    )

    --mm:add_new_objective("OWN_N_UNITS");
    mm:add_new_objective("OWN_N_UNITS");
    mm:add_condition("total " .. unit_count);

    for i = 1, #mission_rewards do
		mm:add_payload(mission_rewards[i]);
    end;

    local listener_name = "tutorial_recruit_units_mission_listener";
    local trigger_event_name = "ScriptEventTriggerTutorialRecruitUnitsMission"
    
    -- establish trigger listeners if this mission has not already been triggered
    if not mm:has_been_triggered() then

        -- master listener
        core:add_listener(
            listener_name,
            trigger_event_name,
            true,
            function()
                core:remove_listener(listener_name);
                mm:trigger();
            end,
            false
        )

        core:add_listener(
            listener_name,
            "ScriptEventTutorialConstructBuildingMissionSucceeded",
            true,
            function()
                core:trigger_event(trigger_event_name)
            end,
            false
        )
    end;
end;