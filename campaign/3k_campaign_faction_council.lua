---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Faction Council
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to trigger missions for the faction based on settings.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


--***********************************************************************************************************
--***********************************************************************************************************
-- VARIABLES
--***********************************************************************************************************
--***********************************************************************************************************


faction_council = {
	enabled = true,
	allow_cdir_missions = true,
	allow_scripted_missions = false,
    start_turn = 0,
    turns_between_councils = 0,
	last_trigger_turn = 0,
    ministerial_positions_to_element = {
        ["3k_main_court_offices_minister_earth"] = "earth",
        ["3k_main_court_offices_minister_fire"] = "fire",
        ["3k_main_court_offices_minister_metal"] = "metal",
        ["3k_main_court_offices_minister_water"] = "water",
        ["3k_main_court_offices_minister_wood"] = "wood"
    },
    agent_subtype_to_element = {
        ["3k_general_earth"] = "earth",
        ["3k_general_fire"] = "fire",
        ["3k_general_metal"] = "metal",
        ["3k_general_water"] = "water",
        ["3k_general_wood"] = "wood"
	},
	ministerial_element_to_mission_issuer = {
		["earth"] = "3k_main_court_offices_minister_earth",
		["fire"] = "3k_main_court_offices_minister_fire",
		["metal"] = "3k_main_court_offices_minister_metal",
		["water"] = "3k_main_court_offices_minister_water",
		["wood"] = "3k_main_court_offices_minister_wood"
	},
    current_mission_cqi_list = {},
    backup_mission_key = "3k_main_council_backup_mission_key";
};


--***********************************************************************************************************
--***********************************************************************************************************
-- INCLUDES
--***********************************************************************************************************
--***********************************************************************************************************


require("3k_campaign_faction_council_data"); -- All the issues fired by the cdir system.
require("3k_campaign_faction_council_missions"); -- Contains the missions for each issue in the cdir system.
require("3k_campaign_faction_council_scripted_missions"); -- Contains issues and missions fired from script.


--***********************************************************************************************************
--***********************************************************************************************************
-- LISTENERS
--***********************************************************************************************************
--***********************************************************************************************************


function faction_council:add_listeners()
	-- Debug command to trigger missions.
	-- Example: trigger_cli_debug_event invoke_council(faction_key)
	core:add_cli_listener("invoke_council", 
		function( faction_key )
			on_invoke_council( cm:modify_faction( faction_key ), cm:modify_model() );
		end
	);

	-- Debug command to disable cdir events.
	-- Example: trigger_cli_debug_event toggle_cdir_missions()
	core:add_cli_listener("toggle_cdir_missions", 
		function()
			self.allow_cdir_missions = not self.allow_cdir_missions;
			out.events( "Cdir Missions Enabled: " .. tostring(self.allow_cdir_missions) );
		end
	);

	-- Debug command toggle scripted events.
	-- Example: trigger_cli_debug_event toggle_scripted_missions()
	core:add_cli_listener("toggle_scripted_missions", 
		function()
			self.allow_scripted_missions = not self.allow_scripted_missions;
			out.events( "Cdir Missions Enabled: " .. tostring(self.allow_scripted_missions) );
		end
	);

	-- The UI sends a message to the system. Which will then fire missions.
    core:add_listener(
        "faction_council_invoke_council_listener", -- UID
        "ModelScriptNotificationEvent", -- Event
        function(model_script_notification_event) --"invoke_council"
            if model_script_notification_event:event_id() ~= "invoke_council" then
                return false;
            end

            return self:can_trigger_council(model_script_notification_event:faction());
        end, --Conditions for firing
		function(model_script_notification_event)
            self:on_invoke_council( model_script_notification_event:faction(), model_script_notification_event:modify_model() );
        end, -- Function to fire.
        true -- Is Persistent?
    );


	-- Listen for a council mission being generated and add it to the list of missions.
    core:add_listener(
        "faction_council_mission_issued_listener", -- UID
        "MissionIssued", -- Event
        function(mission_issued_event)
            return self:is_council_mission(mission_issued_event:mission());
        end, --Conditions for firing
        function(mission_issued_event)
			self:add_to_active_list(mission_issued_event:mission());
        end, -- Function to fire.
        true -- Is Persistent?
    );


	-- Listen for a council mission being cancelled and remove it from our list.
    core:add_listener(
        "faction_council_mission_cancelled_listener", -- UID
        "MissionCancelled", -- Event
        function(mission_cancelled_event)
            return self:is_council_mission(mission_cancelled_event:mission());
        end, --Conditions for firing
        function(mission_cancelled_event)
            self:remove_from_active_list(mission_cancelled_event:mission());
        end, -- Function to fire.
        true -- Is Persistent?
    );


	-- Listen for a council mission succeeding and remove it from our list.
    core:add_listener(
        "faction_council_mission_succeeded_listener", -- UID
        "MissionSucceeded", -- Event
        function(mission_succeeded_event)
            return self:is_council_mission(mission_succeeded_event:mission());
        end, --Conditions for firing
        function(mission_succeeded_event)
            self:remove_from_active_list(mission_succeeded_event:mission());
        end, -- Function to fire.
        true -- Is Persistent?
    );


	-- Listen for a council mission failing and remove it from our list.
    core:add_listener(
        "faction_council_mission_failed_listener", -- UID
        "MissionFailed", -- Event
        function(mission_failed_event)
            return self:is_council_mission(mission_failed_event:mission());
        end, --Conditions for firing
        function(mission_failed_event)
            self:remove_from_active_list(mission_failed_event:mission());
        end, -- Function to fire.
        true -- Is Persistent?
	);
end;


--***********************************************************************************************************
--***********************************************************************************************************
-- METHODS
--***********************************************************************************************************
--***********************************************************************************************************

--// initialise()
--// Sets up the system on game load.
function faction_council:initialise()
    out.events("faction_council:initialise(): Initialise" );

    --Get element count
    local issue_count = 0
	for _ in pairs(self.issue_list) do issue_count = issue_count + 1 end
	
	local scripted_issue_count = 0
	for _ in pairs(self.scripted_issue_list) do scripted_issue_count = scripted_issue_count + 1 end

    inc_tab();
    out.events("Is Enabled: " .. tostring(self.enabled) );
	out.events("Issue Count: " .. issue_count );
	out.events("Scripted Issue Count: " .. scripted_issue_count );
	dec_tab();
	
	-- Add the listeners.
	self:add_listeners();
end;


function faction_council:on_invoke_council(modify_faction, modify_model)
	out.events("faction_council: Invoking council.");

	-- Get a list of valid cdir issues.
	local valid_issue_keys = self:get_valid_issues( modify_faction, modify_model, self.issue_list );
	local valid_scripted_issue_keys = self:get_valid_issues( modify_faction, modify_model, self.scripted_issue_list );
	
	-- Clear out our existing missions.
	self:cancel_existing_missions(modify_faction:query_faction():command_queue_index());
	
	local faction_character_posts = modify_faction:query_faction():character_posts();
    for i=0, faction_character_posts:num_items() - 1 do
		local post = faction_character_posts:item_at(i);
		local post_element = self:get_ministerial_position_element( post:ministerial_position_record_key() );

		-- Check if the post is in our list and someone holds it.
        if post_element ~= nil and post:current_post_holders() > 0 then
			local post_holder = post:post_holders():item_at(0);
			local post_holder_element = self:get_character_element( post_holder );
			local mission_fired = false;

			-- Attempt trigger mission
			mission_fired = self:trigger_cdir_mission_for_post( post_element, post_holder_element, valid_issue_keys, modify_faction, modify_model );
	
			-- Attempt trigger scripted mission.
			if not mission_fired then
				mission_fired = self:trigger_scripted_mission_for_post( post_element, post_holder_element, valid_scripted_issue_keys, modify_faction, modify_model )
			end;
				
			if not mission_fired then
				-- Bad stuff!
				script_error("ERROR: on_invoke_council() NO MISSIONS AT ALL FIRED! THIS SHOULDN'T HAPPEN!");
			end;
		end;
	end;

	-- clean up.
end;

function faction_council:trigger_cdir_mission_for_post( post_element, character_element, issue_list, modify_faction, modify_model )
	if not self.allow_cdir_missions then
		return false;
	end;

	-- sort issues by priority.
	local sorted_issues = self:sort_issues_by_priority( issue_list, post_element, self.issue_list );

	-- attempt to trigger the missions in order. 
	for i, v in ipairs( sorted_issues ) do
		local mission_key = self.mission_list[v][post_element];

		if modify_faction:trigger_mission( mission_key, true ) then
			out.events("trigger_cdir_mission_for_post() Fired issue " .. tostring(v));
			return true;
		end;
	end;

	return false;
end;

function faction_council:trigger_scripted_mission_for_post( post_element, character_element, issue_list, modify_faction, modify_model )
	if not self.allow_scripted_missions then
		return false;
	end;

	-- sort issues by priority.
	local sorted_issues = self:sort_issues_by_priority( issue_list, post_element, self.scripted_issue_list );

	for i, v in ipairs( sorted_issues ) do
		local issue_data = self.scripted_issue_list[v];
		local mission_key = issue_data.mission_keys[post_element];

		-- trigger top mission.
		local mm = mission_manager:new(
			cm:get_local_faction(true),
			mission_key,
			nil, -- success
			nil, -- failure
			nil -- cancelled
		);

		mm:set_mission_issuer( self:get_element_mission_issuer(post_element) );
		issue_data.mission_constructor( mm, modify_faction, modify_model );

		mm:trigger();

		out.events("trigger_scripted_mission_for_post() Fired mission " .. tostring(mission_key));

		return true;
	end;
	

	return false;
end;

function faction_council:sort_issues_by_priority( issue_keys, office_key, issue_source_data )
	local l_issues_priority_sorted = issue_keys;

    -- Sort our table by l_issue_weighting
	table.sort(
		l_issues_priority_sorted, 
		function(a,b)
			local weighting_a = issue_source_data[a].weighting * issue_source_data[a].office_priorities[office_key]; 
			local weighting_b = issue_source_data[b].weighting * issue_source_data[b].office_priorities[office_key]; 
			return weighting_a > weighting_b;
		end
	);
	
	return l_issues_priority_sorted;
end;


--// get_valid_issues()
--// Gets all the currently valid issues for the council.
function faction_council:get_valid_issues(modify_faction, modify_model, raw_issue_list)
	-- Add new missions.
    local l_valid_issue_keys = {};

    -- Step 1 - Find which 'issues' can fire.
    for k, v in pairs(raw_issue_list) do
        if v.is_issue_valid(modify_faction, modify_model) then
            table.insert(l_valid_issue_keys, k);
        end;
    end;

    -- Step 2 - If we can fire ANY missions, clear out the old missions. Doing this here so we don't wipe the missions and then have none to give. 
    if l_valid_issue_keys == nil or #l_valid_issue_keys <= 0 then
        out.events("faction_council:get_valid_issues(): No Valid Issues Found.");
    else
        out.events("faction_council:get_valid_issues(): Valid Missions: " .. #l_valid_issue_keys);
	end;
	
	return l_valid_issue_keys;
end;


--// cancel_existing_missions(faction_cqi)
--// Cancels all missions currently available
function faction_council:cancel_existing_missions(faction_cqi)
	out.events("faction_council:trigger_faction_council(): Cancelling missions for faction " .. faction_cqi);

	for i = #self.current_mission_cqi_list, 1, -1 do -- Go in reverse as we'll be removing items.
		if is_number(self.current_mission_cqi_list[i]) then
			inc_tab();
			self:cancel_mission(cm:modify_model(), self.current_mission_cqi_list[i]);
			table.remove(self.current_mission_cqi_list, i); -- Also remove the mission from our tracker. We used to delete the table but mp needs to work with multiple factions.
			dec_tab();
		else
			if self.current_mission_cqi_list[i][1] == faction_cqi then
				inc_tab();
				self:cancel_mission(cm:modify_model(), self.current_mission_cqi_list[i][2]);
				table.remove(self.current_mission_cqi_list, i); -- Also remove the mission from our tracker. We used to delete the table but mp needs to work with multiple factions.
				dec_tab();
			end;
		end;
	end;
end;



--***********************************************************************************************************
--***********************************************************************************************************
-- HELPERS
--***********************************************************************************************************
--***********************************************************************************************************


--// is_council_mission()
--// Returns true if the mission is a council mission.
function faction_council:is_council_mission(mission_context)
    -- TODO: Use Issuer if it's data driven!
    --if string.match(mission_context:mission_issuer_record_key(), "_council_") then
    if string.match(mission_context:mission_record_key(), "_council_") == nil then
        return false;
    end;

    return true;
end;


--// add_to_active_list()
--// Adds the mission to the active list so it's tracked.
function faction_council:add_to_active_list(mission_context)
	local l_mission_cqi = mission_context:cqi();
	local l_faction_cqi = mission_context:faction():command_queue_index();
    local l_mission_key = mission_context:mission_record_key();

    for i = #self.current_mission_cqi_list, 1, -1 do
        if self.current_mission_cqi_list[i] == l_mission_cqi then
            script_error("ERROR: Trying to add mission to the active list when it already exists. Key=" .. l_mission_key );
            return false;
        end;
    end;

	table.insert(
		self.current_mission_cqi_list, 
		{
			l_faction_cqi,
			l_mission_cqi
		}
	);
    return true;
end;


--// remove_from_active_list()
--// Stop tracking this mission.
function faction_council:remove_from_active_list(mission_context)
	local l_mission_cqi = mission_context:cqi();
	local l_faction_cqi = mission_context:faction():command_queue_index();
    local l_mission_key = mission_context:mission_record_key();

	for i = #self.current_mission_cqi_list, 1, -1 do
		local mission_data = self.current_mission_cqi_list[i];
        if mission_data[1] == l_faction_cqi and mission_data[2] == l_mission_cqi then
            table.remove(self.current_mission_cqi_list, i);
            return true;
        end;
    end;

    script_error("ERROR: Trying to remove mission from active list when it doesn't exist. Key=" .. l_mission_key );
    return false;
end;


--// cancel_mission()
--// Cancel the mission with this cqi.
function faction_council:cancel_mission(modify_model, mission_cqi)
    local modify_mission = modify_model:get_modify_mission_by_cqi(mission_cqi);

    if not modify_mission or modify_mission:is_null_interface() then
        script_error("Unable to get mission with cqi " .. tostring(mission_cqi));
        return;
    end;

    out.events("Cancelling mission: " .. tostring(modify_mission:query_mission():mission_record_key()) .. ", issuer:" .. tostring(modify_mission:query_mission():mission_issuer_record_key()));
    modify_mission:cancel();
end;


--// can_trigger_council()
--// Returns false if the council cannot be invoked for any reason.
function faction_council:can_trigger_council(modify_faction)
    --Exit if disabled.
    if not self.enabled then
        out.events("faction_council:can_trigger_council(): Cannot trigger - System Disabled.");
        return false;
    end;

    --Exit if the faction isn't human.
    if not modify_faction:query_faction():is_human() then
        out.events("faction_council:can_trigger_council(): Cannot trigger - AI Faction.");
        return false;
    end;

    out.events("faction_council:can_trigger_council(): System can trigger.");
    return true;
end;


--// get_character_element()
--// Get the agent subtype
function faction_council:get_character_element(query_character)
	return self.agent_subtype_to_element[query_character:character_subtype_key()];
end;


--// get_ministerial_position_element()
--// Get the element for ministerial position.
function faction_council:get_ministerial_position_element(ministerial_position)
	return self.ministerial_positions_to_element[ministerial_position];
end;

--// get_ministerial_position_element()
--// Get the element for ministerial position.
function faction_council:get_element_mission_issuer(element)
	return self.ministerial_element_to_mission_issuer[element];
end;


--***********************************************************************************************************
--***********************************************************************************************************
-- SAVE/LOAD
--***********************************************************************************************************
--***********************************************************************************************************


function faction_council:register_save_load_callbacks()
    cm:add_saving_game_callback(
        function(saving_game_event)
            cm:save_named_value("faction_council_last_trigger_turn", self.last_trigger_turn);
            cm:save_named_value("faction_council_current_mission_cqi_list", self.current_mission_cqi_list);
        end
    );

    cm:add_loading_game_callback(
        function(loading_game_event)
            local l_last_trigger_turn =  cm:load_named_value("faction_council_last_trigger_turn", self.last_trigger_turn);
            local l_mission_cqi_list =  cm:load_named_value("faction_council_current_mission_cqi_list", self.current_mission_cqi_list);

            self.last_trigger_turn = l_last_trigger_turn;
            self.current_mission_cqi_list = l_mission_cqi_list;
        end
    );
end;

faction_council:register_save_load_callbacks();