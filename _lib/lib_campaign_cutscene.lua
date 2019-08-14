



-------------------------------------------------------
-------------------------------------------------------
--	CAMPAIGN CUTSCENE SCRIPT
-------------------------------------------------------
-------------------------------------------------------

__campaign_cutscene_debug = false;



campaign_cutscene = {
	cm = nil,
	name = "",
	cutscene_length = 0,
	action_list = {},
	cinematic_triggers = {},
	skip_callback = nil,
	is_debug = false,
	is_skippable = true,
	is_running = false,
	was_skipped = false,
	wait_offset = 0,
	skip_callback = nil,
	end_callback = nil,
	advisor_wait = false,
	skip_cam_x = false,
	skip_cam_y = false,
	skip_cam_d = false,
	skip_cam_b = false,
	skip_cam_h = false,
	restore_cam_time = -1,
	restore_cam_x = false,
	restore_cam_y = false,
	restore_cam_d = false,
	restore_cam_b = false,
	restore_cam_h = false,
	dismiss_advice_on_end = true,
	disable_settlement_labels = true,
	neighbouring_regions_visible = true,
	use_cinematic_borders = true,
	restore_ui = true,
	do_not_end = false,
	do_not_skip_on_next_advice_dismissal = false,
	disable_shroud = false,
	disable_region_borders = true,
	playing_cindy_camera = false,
	cindy_camera_specified = false,
	event_panels_enabled = true,
	restore_shroud = true,
	restore_shroud_time = 1,
	enable_ui_hiding_on_release = true,
	should_send_recieve_metrics_data = false
};





function campaign_cutscene:new(name, length, end_callback, send_metrics_data)

	send_metrics_data = send_metrics_data or false;

	-- type-check our parameters
	if not is_string(name) then
		script_error("ERROR: tried to create a campaign_cutscene but supplied name [" .. tostring(name) .."] is not a string");
		return false;
	end;
	
	local full_name = "Campaign_Cutscene_" .. name;
	
	if not is_number(length) then
		script_error(full_name .. " ERROR: tried to create a campaign_cutscene but supplied length [" .. tostring(length) .. "] is not a number");
		return false;
	end;
	
	if not is_function(end_callback) and not is_nil(end_callback) then
		script_error(full_name .. " ERROR: tried to create a campaign_cutscene but supplied end callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
		
	cc = {};
	
	setmetatable(cc, campaign_cutscene);
	self.__tostring = function() return TYPE_CAMPAIGN_CUTSCENE end;
	self.__index = self;
	
	local cm = get_cm();
	
	cc.cm = cm;
	cc.name = full_name;
	cc.cutscene_length = length;
	cc.end_callback = end_callback;
	cc.should_send_recieve_metrics_data = send_metrics_data;
	
	cc.action_list = {};
	cc.cinematic_triggers = {};
	
	cm:register_cutscene(cc);
	
	return cc;
end;


function campaign_cutscene:set_debug(is_debug)
	if is_debug == nil then
		self.is_debug = true;
	else
		self.is_debug = is_debug;
	end;
end;


function campaign_cutscene:set_debug_all(is_debug)
	if is_debug == nil then
		__campaign_cutscene_debug = true;
	else
		__campaign_cutscene_debug = is_debug;
	end;
end;


function campaign_cutscene:set_skippable(skippable, callback)
	if value == nil then
		self.is_skippable = true;
	else
		self.is_skippable = skippable;
	end;
	
	if is_function(callback) then
		self.skip_callback = callback;
	end;
end;


function campaign_cutscene:set_dismiss_advice_on_end(value)
	if value == false then
		self.dismiss_advice_on_end = false;
	else
		self.dismiss_advice_on_end = true;
	end;
end;


function campaign_cutscene:set_do_not_end(value)
	if value == false then
		self.do_not_end = false;
	else
		self.do_not_end = true;
	end;
end;


function campaign_cutscene:set_use_cinematic_borders(value)
	if value == false then
		self.use_cinematic_borders = false;
	else
		self.use_cinematic_borders = true;
	end;
end;


function campaign_cutscene:set_restore_ui(value)
	if value == false then
		self.restore_ui = false;
	else
		self.restore_ui = true;
	end;
end;


function campaign_cutscene:set_disable_settlement_labels(value)
	if value == false then
		self.disable_settlement_labels = false;
	else
		self.disable_settlement_labels = true;
	end;
end;


function campaign_cutscene:set_neighbouring_regions_visible(value)
	if value == false then
		self.neighbouring_regions_visible = false;
	else
		self.neighbouring_regions_visible = true;
		self.disable_shroud = false;
	end;
end;


function campaign_cutscene:set_disable_shroud(value)
	if value == false then
		self.disable_shroud = false;
	else
		self.disable_shroud = true;
		self.neighbouring_regions_visible = false;
	end;
end;


function campaign_cutscene:set_disable_region_borders(value)
	if value == false then
		self.disable_region_borders = false;
	else
		self.disable_region_borders = true;
	end;
end;


function campaign_cutscene:set_restore_shroud(value)
	if value == false then
		self.restore_shroud = false;
	else
		self.restore_shroud = true;
	end;
end;


function campaign_cutscene:set_end_callback(callback)
	if not is_function(callback) then
		script_error(self.name .. " ERROR: set_end_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	self.end_callback = callback;
end;


function campaign_cutscene:has_end_callback()
	return not not self.end_callback;
end;



function campaign_cutscene:set_skip_camera(x, y, d, b, h)
	local cm = self.cm;
	
	-- if we have been given no position then use current
	if not x then
		x, y, d, b, h = cm:get_camera_position();
	elseif is_table(x) then
		y = x[2];
		d = x[3];
		b = x[4];
		h = x[5];
		x = x[1];
	else
		if not is_number(x) then
			script_error(self.name .. " ERROR: set_skip_camera() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a number or nil");
			return false
		end;
		
		if not is_number(y) then
			script_error(self.name .. " ERROR: set_skip_camera() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a number");
			return false
		end;
		
		if not is_number(d) then
			script_error(self.name .. " ERROR: set_skip_camera() called but supplied distance [" .. tostring(d) .. "] is not a number");
			return false
		end;
		
		if not is_number(b) then
			script_error(self.name .. " ERROR: set_skip_camera() called but supplied bearing [" .. tostring(b) .. "] is not a number");
			return false
		end;
		
		if not is_number(h) then
			script_error(self.name .. " ERROR: set_skip_camera() called but supplied height [" .. tostring(h) .. "] is not a number");
			return false
		end;
	end;
	
	if self.is_debug or __campaign_cutscene_debug then
		output(self.name .. " setting skip camera to " .. cm:camera_position_to_string(x, y, d, b, h));
	end;
	
	self.skip_cam_x = x;
	self.skip_cam_y = y;
	self.skip_cam_d = d;
	self.skip_cam_b = b;
	self.skip_cam_h = h;
end;


function campaign_cutscene:set_restore_camera(t, x, y, d, b, h)
	local cm = self.cm;

	if not is_number(t) then
		script_error(self.name .. " ERROR: set_restore_camera() called but supplied time [" .. tostring(t) .. "] is not a number");
		return false;
	end;
	
	self.restore_cam_time = t;
	
	-- if we have been given no position then we will use the current position (later, when the cutscene is started)
	if not x then
		return;
	end;
	
	-- if we've been given a table then convert it
	if is_table(x) then
		y = x[2];
		d = x[3];
		b = x[4];
		h = x[5];
		x = x[1];
	end;
	
	if not is_number(x) then
		script_error(self.name .. " ERROR: set_restore_camera() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a number or nil");
		return false;
	end;
	
	if not is_number(y) then
		script_error(self.name .. " ERROR: set_restore_camera() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a number");
		return false;
	end;
	
	if not is_number(d) then
		script_error(self.name .. " ERROR: set_restore_camera() called but supplied distance [" .. tostring(d) .. "] is not a number");
		return false;
	end;
	
	if not is_number(b) then
		script_error(self.name .. " ERROR: set_restore_camera() called but supplied bearing [" .. tostring(b) .. "] is not a number");
		return false;
	end;
	
	if not is_number(h) then
		script_error(self.name .. " ERROR: set_restore_camera() called but supplied height [" .. tostring(h) .. "] is not a number");
		return false;
	end;
	
	if self.is_debug or __campaign_cutscene_debug then
		output(self.name .. " setting restore camera to " .. cm:camera_position_to_string(x, y, d, b, h));
	end;
	
	self.restore_cam_x = x;
	self.restore_cam_y = y;
	self.restore_cam_d = d;
	self.restore_cam_b = b;
	self.restore_cam_h = h;
end;


function campaign_cutscene:add_cinematic_trigger_listener(id, callback)
	if not is_string(id) then
		script_error(self.name .. " ERROR: add_cinematic_trigger_listener() called but supplied id " .. tostring(id) .. " is not a string");
		return false;
	end;
	
	if not is_function(callback) then
		script_error(self.name .. " ERROR: add_cinematic_trigger_listener() called but supplied callback " .. tostring(callback) .. " is not a function");
		return false;
	end;
	
	self.cinematic_triggers[id] = callback;
end;


function campaign_cutscene:is_active()
	return self.is_running;
end;


function campaign_cutscene:action(new_callback, new_delay)
	-- type-check parameters
	if not is_function(new_callback) then
		script_error(self.name .. " ERROR: trying to add an action but supplied action [" .. tostring(new_callback) .."] is not a function");
		return false;
	end;
	
	if not is_number(new_delay) then
		script_error(self.name .. " ERROR: trying to add an action but supplied action [" .. tostring(new_delay) .."] is not a number");
		return false;
	end;
	
	-- debug output
	if self.is_debug or __campaign_cutscene_debug then
		output(self.name .. " adding action " .. tostring(new_callback) .. " with delay " .. tostring(new_delay));
	end;
	
	-- add action to our list
	for i = 1, #self.action_list do
		if self.action_list[i].delay > new_delay then
			table.insert(self.action_list, i, {callback = new_callback, delay = new_delay});
			return true;
		end;
	end;
	
	table.insert(self.action_list, {callback = new_callback, delay = new_delay});
	return true;
end;


function campaign_cutscene:start()
	local cm = self.cm;
	local modify_scripting = cm:modify_scripting();
	local uim = cm:get_campaign_ui_manager();
	
	if cm:is_any_cutscene_running() then
		script_error(self.name .. " ERROR: cannot start, another cutscene is running!");
		return false;
	end;
	
	
	-- prevent player input
	if not (self.is_debug or __campaign_cutscene_debug) then
		cm:steal_user_input(true);
		
		if not cm:is_ui_hiding_enabled() then
			self.enable_ui_hiding_on_release = false;		-- ui hiding was disabled prior to the cutscene, so don't re-enable it
		end;
		
		cm:enable_ui_hiding(false);
	end;
	
	-- set up restore camera if we need to
	if self.restore_cam_time >= 0 and not self.restore_cam_x then
		self.restore_cam_x, self.restore_cam_y, self.restore_cam_d, self.restore_cam_b, self.restore_cam_h = cm:get_camera_position();
	end;
	
	-- turn off event panels
	self:enable_event_panels(false);
	
	
	-- shroud
	if self.restore_shroud then		
		modify_scripting:take_shroud_snapshot();
	end;
	
	if self.neighbouring_regions_visible then
		modify_scripting:make_neighbouring_regions_visible_in_shroud();
	end;
	
	if self.disable_shroud then		
		modify_scripting:show_shroud(false);

		-- fade out instantly (seconds, target alpha)
		modify_scripting:fade_shroud(0, 0);
	end;
	
	
	-- region border display
	if self.disable_region_borders then
		modify_scripting:show_borders(false);
	end;


	-- cinematic borders
	if self.use_cinematic_borders then
		CampaignUI.ToggleCinematicBorders(true);
	end;
	
	modify_scripting:override_ui("disable_advice_changes", true);	
	
	if self.disable_settlement_labels then
		modify_scripting:override_ui("disable_settlement_labels", true);
	else
		-- do this in case this cutscene is following another, and *that* cutscene had disabled settlement labels
		modify_scripting:override_ui("disable_settlement_labels", false);
	end;

	if self.should_send_recieve_metrics_data then
		-- start collection of performance metrics
		cm:modify_scripting():trigger_performance_metrics_start();
	end;


	-- start listening for advice dismissed if necessary
	if self.is_skippable then
		core:add_listener(
			self.name .. "_advice_closed",
			"AdviceDismissed",
			true,
			function() self:advice_is_dismissed() end,
			false
		);
		
		cm:steal_escape_key_and_space_bar_with_callback(self.name, function() self:skip() end);
	end;

	-- establish a listener for cinematic triggers from cindy scenes
	core:add_listener(
		self.name .. "_cinematic_trigger_listeners",
		"CinematicTrigger",
		true,
		function(context)
			local trigger_str = context.string;

			if self.cinematic_triggers[trigger_str] then					
				out("* CinematicTrigger event received with id " .. tostring(trigger_str) .. " - triggering callback");
				
				-- cm:wait_for_model_sp(function() self.cinematic_triggers[trigger_str]() end);
				self.cinematic_triggers[trigger_str]();
			else
				out("* CinematicTrigger event received with id " .. tostring(trigger_str) .. " - no callback registered for this id");
			end;
		end,
		true
	);
	
	if not self.do_not_end then
		self:action(function() self:finish() end, self.cutscene_length, self.name);
	end;
	
	-- set internal is_running flag
	self.is_running = true;
	
	-- debug output
	if self.is_debug or __campaign_cutscene_debug then
		output(self.name .. " is starting");
	end;
		
	-- start processing actions
	self:process_next_action(1);
	
	return true;
end;



-- performs the next action
function campaign_cutscene:process_next_action(action_ptr)
	if not self.is_running then
		script_error(self.name .. " WARNING:  tried to process an action while not active, the action didn't happen.");		
		return false;
	end;
		
	if action_ptr > #self.action_list then		
		return false;
	end;
	
	local cm = self.cm;
	
	-- see if we have to wait for advice to complete
	if self.advisor_wait then
		if effect.is_advice_audio_playing() then
		
			-- Advice is playing and we have been instructed to wait for it to complete.
			-- Let's try again in a bit and see if the advice has finished
			cm:callback(function() self:process_next_action(action_ptr) end, 0.5, self.name);
			self.wait_offset = self.wait_offset + 0.5;
			return false;
		else
			-- advisor_wait is true but there is no advice playing, so we can set it to false again
			self.advisor_wait = false;
		end;	
	end;
		
	local next_action = self.action_list[action_ptr];
	local further_action = nil;
	
	if action_ptr < #self.action_list then
		further_action = self.action_list[action_ptr + 1];
	end;
	
	-- debug output
	if self.is_debug or __campaign_cutscene_debug then
		output(self.name .. " : processing action " .. action_ptr .. " [" .. tostring(next_action.callback) .. "]");
	end;
		
	-- call the next_action callback
	next_action.callback();
	
	-- if the further_action (what we do after next_action) is due to happen at a later time
	-- as the next_action then queue that up, else run it now. If further_action doesn't exist
	-- then do nothing, we have got to the end of the cutscene
	if further_action then
		if further_action.delay > next_action.delay then
			cm:callback(function() self:process_next_action(action_ptr + 1) end, (further_action.delay - next_action.delay), self.name);
		else
			self:process_next_action(action_ptr + 1);
		end;
	end;
end;


-- called if we want the cutscene system to wait for the advisor to finish speaking
function campaign_cutscene:wait_for_advisor(delay)

	-- if this function is supplied with a delay, then enqueue it as an action
	if delay then
		if not is_number(delay) or delay < 0 then
			script_error(self.name .. " ERROR: wait_for_advisor() called but supplied delay [" .. tostring(delay) .. "] is not a positive number or nil");
			return false;
		end;
		
		self:action(function() self:wait_for_advisor() end, delay);
		return;
	end;
	
	self.advisor_wait = true;
end;



-- parameters: path to cindy scene file [, blend in duration, blend out duration]
-- uses default blend time if nothing is passed
function campaign_cutscene:cindy_playback(file, blend_in, blend_out)
	self.playing_cindy_camera = true;
	self.cindy_camera_specified = true;
	self.cm:modify_scripting():cinematic():cindy_playback(file, blend_in, blend_out);
end;



function campaign_cutscene:enable_event_panels(value)
	if self.event_panels_enabled == not value then
		self.cm:get_campaign_ui_manager():enable_event_panel_auto_open(value);
		self.event_panels_enabled = value;
	end;
end;




-- used to dismiss advice without triggering the end of the cutscene
function campaign_cutscene:dismiss_advice()
	self.do_not_skip_on_next_advice_dismissal = true;
	
	self.cm:dismiss_advice();
end;


function campaign_cutscene:advice_is_dismissed()
	output("advice_is_dismissed() called");

	if self.do_not_skip_on_next_advice_dismissal then
		self.do_not_skip_on_next_advice_dismissal = false;
		return;
	end;
	
	core:remove_listener(self.name .. "_advice_closed");
	self:skip(true);
end;





-- called when the campaign intro is skipped
function campaign_cutscene:skip(advice_being_dismissed)
	-- wait for the model before actually processing the skip
	cm:wait_for_model_sp(function() self:skip_action(advice_being_dismissed) end);
end;


function campaign_cutscene:skip_action(advice_being_dismissed)
	if not self.is_running then
		return false;
	end;
	
	local cm = get_cm();
	local modify_scripting = cm:modify_scripting();
	
	output(self.name .. " has been skipped");
	
	-- kill any running process
	cm:remove_callback(self.name);
	
	-- remove listener for advice being dismissed before we manually dismiss it
	core:remove_listener(self.name .. "_advice_closed");
	
	CampaignUI.StopCamera();

	-- stop any cinematic trigger listeners
	core:remove_listener(self.name .. "_cinematic_trigger_listeners");
	
	if self.dismiss_advice_on_end and not advice_being_dismissed then
		cm:dismiss_advice();
	end;
	
	self.was_skipped = true;
	
	-- stop the cindy camera if one is playing
	if self.playing_cindy_camera then
		self.playing_cindy_camera = false;
		cm:stop_cindy_playback();
		
		-- cut to black, then fade back in
		-- modify_scripting:fade_scene(0, 0);
		-- cm:callback(function() cm:modify_scripting():fade_scene(1, 0.5) end, 0.5);
	end;
	
	-- run the skip callback if we have one
	if is_function(self.skip_callback) then
		self.skip_callback();
	end;
	
	
	-- reposition camera if we have a skip camera (this is delayed in case the cindy scene is still running)
	if self.skip_cam_x then
		if self.cindy_camera_specified then
			cm:callback(function() cm:set_camera_position(self.skip_cam_x, self.skip_cam_y, self.skip_cam_d, self.skip_cam_b, self.skip_cam_h) end, 0.1);
		else
			cm:set_camera_position(self.skip_cam_x, self.skip_cam_y, self.skip_cam_d, self.skip_cam_b, self.skip_cam_h);
		end;
		
	elseif self.restore_cam_time >= 0 then
		self:restore_camera_and_release(true);
		return;
	end;
	
	self:release();
end




-- called when the campaign intro finishes without skipping
function campaign_cutscene:finish()
	if self.is_debug or __campaign_cutscene_debug then
		output(self.name .. " is finishing");
	end;
	
	-- stop the cindy camera if one is playing
	if self.playing_cindy_camera then
		self.playing_cindy_camera = false;
		cm:stop_cindy_playback(false);
	end;

	-- stop any cinematic trigger listeners
	core:remove_listener(self.name .. "_cinematic_trigger_listeners");
	
	if self.restore_cam_time >= 0 then
		self:restore_camera_and_release(false);
	else
		self:release();
	end;
end



-- called when we may have to restore the camera to its previous position
function campaign_cutscene:restore_camera_and_release(should_cut)
	local restore_time = self.restore_cam_time;
	local cm = self.cm;
	
	if should_cut then
		restore_time = 0;
	end;

	-- perform the camera movement
	if restore_time == 0 then
		cm:set_camera_position(self.restore_cam_x, self.restore_cam_y, self.restore_cam_d, self.restore_cam_b, self.restore_cam_h);
		self:release();
	else
		cm:scroll_camera_from_current(restore_time, true, {self.restore_cam_x, self.restore_cam_y, self.restore_cam_d, self.restore_cam_b, self.restore_cam_h});
		cm:callback(function() self:release() end, restore_time, self.name);
	end;
end;




-- cleans up the campaign_cutscene, called when it finishes for either reason
function campaign_cutscene:release()
	
	local cm = self.cm;
	local uim = cm:get_campaign_ui_manager();
	
	--
	-- RE-ACTIVATE UI (wait a little and check if no other cutscene is running)
	--
	local wait_time = 0.1;
	if self.restore_shroud then
		wait_time = self.restore_shroud_time + 0.5;
	end;

	cm:callback(
		function()
			-- allow event panels to be shown again
			-- always do this at this time, even if another cutscene is running - the lock the second cutscene will have already placed
			-- on event panels auto-opening will prevent this call from actually enabling the functionality
			self:enable_event_panels(true);
		
			if not cm:is_any_cutscene_running() then	
				-- allow ui hiding if we should
				if self.enable_ui_hiding_on_release then
					cm:enable_ui_hiding(true);
				end;
			
				-- allow player input
				if not (self.is_debug or __campaign_cutscene_debug) then
					cm:steal_user_input(false);
				end;

				-- cinematic borders
				if self.use_cinematic_borders and self.restore_ui then
					CampaignUI.ToggleCinematicBorders(false);
				end;
				
				cm:modify_scripting():override_ui("disable_advice_changes", false);	
				
				if self.disable_settlement_labels then
					cm:modify_scripting():override_ui("disable_settlement_labels", false);
				end;

			end;
		end,
		wait_time,
		self.name .. "_release"
	);
	
	-- shroud
	if self.restore_shroud then
		cm:modify_scripting():restore_shroud_from_snapshot();

		-- fade in (seconds, target alpha)
		cm:modify_scripting():fade_shroud(self.restore_shroud_time, 1.0);
	end;
	
	-- region border display
	if self.disable_region_borders then
		cm:modify_scripting():show_borders(true);
	end;

	-- stop listening for advice being dismissed
	if self.is_skippable then
		core:remove_listener(self.name .. "_advice_closed");
		cm:release_escape_key_and_space_bar_with_callback(self.name);
	end;
	
	-- set internal is_running flag
	self.is_running = false;
	
	if self.wait_offset > 0 then
		output(self.name .. " was " .. self.wait_offset .. "s longer than specified due to waiting for advice to complete.");
	end;
	
	-- restore the advisor controls post-pan
	cm:modify_advice(true);

	-- notify listeners that a cutscene has completed
	core:trigger_event("ScriptEventCampaignCutsceneCompleted", self.name);

	if is_function(self.end_callback) then
		self.end_callback();
	end;	

	if self.should_send_recieve_metrics_data then
		-- report collected performance metrics
		cm:modify_scripting():trigger_performance_metrics_stop();
	end;
end;








