

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
--	PRELUDE BATTLES
--
--	Helper functions for prelude battle stuff
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------




function show_prelude_battle_ui(value, exclude_winds_of_magic, exclude_army_panel)

	local animation = "tut_hide";

	if value then
		animation = "tut_show";
	end;
	
	local bm = get_bm();
	
	-- trigger show/hide animations on user interface
	bm:ui_component("radar_holder"):TriggerAnimation(animation);
	bm:ui_component("BOP_frame"):TriggerAnimation(animation);
	
	if not exclude_army_panel then
		bm:ui_component("battle_orders"):TriggerAnimation(animation);
	end;
	
	if not exclude_winds_of_magic then
		bm:ui_component("winds_of_magic"):TriggerAnimation(animation);
	end;
	-- bm:ui_component("porthole_parent"):TriggerAnimation(animation);

end;


function show_prelude_winds_of_magic_panel(value)
	local animation = "tut_hide";

	if value then
		animation = "tut_show";
	end;
	
	local bm = get_bm();

	bm:ui_component("winds_of_magic"):TriggerAnimation(animation);
end;


function show_prelude_start_battle_button(value)
	local ui_root = core:get_ui_root();
	
	-- find_uicomponent(ui_root, "finish_deployment"):SetVisible(not not value);
	-- find_uicomponent(ui_root, "deployment_end_sp"):SetVisible(not not value);
	-- find_uicomponent(ui_root, "button_battle_start"):SetVisible(not not value);
	
	-- ScottB: Making a fade anim as visibility is set by cinematic UI which is being disabled before script ends deployment resulting in it flickering on screen which dont want
	local animation = "tut_hide"
	if value then
		animation = "tut_show"
	end;
	
	local uic =	find_uicomponent(ui_root, "finish_deployment");
	
	if uic then uic:TriggerAnimation(animation) end;
end;


path_to_unit_cards = {"layout", "battle_orders", "battle_orders_pane", "card_panel_docker", "cards_panel", "review_DY"};

function start_highlight_of_player_reinforcements(num_cards)
	-- cache all currently-visible unit cards
	local uic_unit_cards = find_uicomponent_from_table(core:get_ui_root(), path_to_unit_cards);
	
	if not uic_unit_cards then
		script_error("ERROR: start_highlight_of_player_reinforcements() couldn't find uic_unit_cards");
		return false;
	end;
	
	bm:out("start_highlight_of_player_reinforcements() called");
	local starting_cards = {};
	
	for i = 1, uic_unit_cards:ChildCount() - 1 do
		local uic_child = UIComponent(uic_unit_cards:Find(i));
		table.insert(starting_cards, uic_child);
	end;
	
	bm:callback(function() attempt_highlight_of_player_reinforcements(starting_cards, num_cards) end, 200);
end;

function attempt_highlight_of_player_reinforcements(starting_cards, num_cards)
	local uic_unit_cards = find_uicomponent_from_table(core:get_ui_root(), path_to_unit_cards);
	
	if not uic_unit_cards then
		script_error("ERROR: attempt_highlight_of_player_reinforcements() couldn't find uic_unit_cards");
		return false;
	end;
	
	unmatched_cards = {};
	
	for i = 1, uic_unit_cards:ChildCount() - 1 do
		local uic_child = UIComponent(uic_unit_cards:Find(i));
		local uic_matched = false;
		for j = 1, #starting_cards do
			if uic_child == starting_cards[j] then
				uic_matched = true;
				break;			
			end;
		end;
		
		if not uic_matched then
			table.insert(unmatched_cards, uic_child);
		end;
	end;
	
	-- highlight the reinforcements if we have all of them
	if #unmatched_cards == num_cards then
		for i = 1, #unmatched_cards do
			local uic = unmatched_cards[i];
			uic:ShaderTechniqueSet("glow_pulse_t0", true);
			uic:ShaderVarsSet(1, 10, 0.8, 0);
		end;
		
		bm:register_unit_selection_handler("reinforcement_selected");
	else
		bm:callback(function() attempt_highlight_of_player_reinforcements(starting_cards, num_cards) end, 200);
	end;
end;

-- stop highlighting the reinforcements once one of them is selected
function reinforcement_selected(unit, selected)
	if selected and (unit ~= sunit_player_01.unit) and (unit ~= sunit_player_02.unit) then
		bm:unregister_unit_selection_handler();
	
		for i = 1, #unmatched_cards do
			local uic = unmatched_cards[i];
			uic:ShaderTechniqueSet("normal_t0", true);
			uic:ShaderVarsSet(0, 0, 0, 0);
		end;
	end;
end;


prelude_battle_camera_advice = {
	bm = false,
	objectives = false,
	end_callback = false,
	player_sunits = false,
	progression_time = 55000,
	movement_time = 22000,
	altitude_time = 12000,
	-- Your forces begin their attack, my Lord! See for yourself!
	advice_key = "war.battle.prelude.intro.001",
	infotext = {"war.battle.prelude.intro.info_001", "war.battle.prelude.intro.info_002", "war.battle.prelude.intro.info_003", "war.battle.prelude.intro.info_004", "war.battle.prelude.intro.info_005"},
	objective_key = "war.battle.prelude.camera_advice.001",
	objective_shown = false,
	player_sunits_controlled = false
};


function prelude_battle_camera_advice:new(end_callback, player_sunits, advice_key_override, progression_time_override, movement_time_override, altitude_time_override)

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_camera_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if not is_scriptunits(player_sunits) then
		script_error("ERROR: prelude_battle_camera_advice:new() called but supplied player sunits [" .. tostring(player_sunits) .. "] is not a valid scriptunits collection");
		return false;	
	end;
	
	if advice_key_override and not is_string(advice_key_override) then
		script_error("ERROR: prelude_battle_camera_advice:new() called but supplied advice key override [" .. tostring(advice_key_override) .. "] is not a string or nil");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_camera_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	if movement_time_override and not is_number(movement_time_override) then
		script_error("ERROR: prelude_battle_camera_advice:new() called but supplied movement time override [" .. tostring(movement_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	if altitude_time_override and not is_number(altitude_time_override) then
		script_error("ERROR: prelude_battle_camera_advice:new() called but supplied altitude time override [" .. tostring(altitude_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local ca = {};
	setmetatable(ca, self);
	self.__index = self;
	
	ca.bm = bm;
	ca.objectives = get_objectives_manager();
	ca.player_sunits = player_sunits;
	ca.end_callback = end_callback;
	
	if advice_key_override then
		ca.advice_key = advice_key_override;
	end;
	
	ca.progression_time = progression_time_override or ca.progression_time;
	ca.movement_time = movement_time_override or ca.movement_time;
	ca.altitude_time = altitude_time_override or ca.altitude_time;
	
	return ca;
end;


function prelude_battle_camera_advice:start()

	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	table.insert(
		self.infotext, 
		function() 
			self.objectives:set_objective(self.objective_key);
			self.objective_shown = true;
		end
	);
	
	bm:queue_advisor(
		self.advice_key,
		6000,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	-- take control of player's sunits
	self.player_sunits:take_control();
	self.player_sunits_controlled = true;
	
	-- cache the time this advice was given
	local start_time = timestamp_tick;
	
	bm:start_camera_movement_tracker();
	
	-- watch for player changing camera altitude
	bm:watch(
		function()
			return bm:get_camera_altitude_change() > 15
		end,
		0,
		function()
			bm:out("<< player has changed camera altitude >>");
			self.progression_time = self.progression_time - self.altitude_time;
		end,
		"camera_advice"
	);
	
	-- watch for player moving camera position
	bm:watch(
		function()
			return bm:get_camera_distance_travelled() > 150
		end,
		0,
		function()
			bm:out("<< player has moved camera >>");
			self.progression_time = self.progression_time - self.movement_time;
		end,
		"camera_advice"
	);
	
	-- watch for the time elapsed passing the progression time
	bm:watch(
		function()
			return timestamp_tick > start_time + self.progression_time;
		end,
		0,
		function()
			self:stop();
			self.end_callback();
		end,
		"camera_advice"
	);
	
	core:add_listener(
		"prelude_battle_camera_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false	
	);
end;


function prelude_battle_camera_advice:stop()
	if self.player_sunits_controlled then
		-- release control of player's sunits
		self.player_sunits:release_control();
		self.player_sunits_controlled = false;
	end;
	
	if self.objective_shown then
		self.objectives:remove_objective(self.objective_key);
		self.objective_shown = false;
	end;

	local bm = self.bm;
	core:remove_listener("prelude_battle_camera_advice_listener");
	bm:remove_process("camera_advice");
end;






















prelude_battle_movement_advice = {
	bm = false,
	player_sunits = false,
	camera_start_pos = false,
	camera_start_targ = false,
	movement_target = false,
	end_callback = false,
	progression_time = 50000,
	movement_time = 15000,
	start_infotext = {"war.battle.prelude.intro.info_010", "war.battle.prelude.intro.info_011", "war.battle.prelude.intro.info_012", "war.battle.prelude.intro.info_013"},
	selection_infotext = {"war.battle.prelude.intro.info_014"},
	movement_infotext = {"war.battle.prelude.intro.info_015"},
	-- Be sure to join the fight yourself, my Lord! The troops will be greatly rallied by your presence.
	advice_key = "war.battle.prelude.intro.010",
	start_time = -1,
	is_showing_marker = false,
	player_sunit_marker_positions = {},
	objectives = false,
	selection_objective_key = "war.battle.prelude.movement_advice.001",
	selection_objective_shown = false,
	movement_objective_key = "war.battle.prelude.movement_advice.002",
	movement_objective_shown = false
};


function prelude_battle_movement_advice:new(player_sunits, camera_start_pos, camera_start_targ, movement_target, end_callback, advice_key_override, progression_time_override, movement_time_override)

	if not is_scriptunits(player_sunits) then
		script_error("ERROR: prelude_battle_movement_advice:new() called but supplied player scriptunits [" .. tostring(player_sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if camera_start_pos and not is_vector(camera_start_pos) then
		script_error("ERROR: prelude_battle_movement_advice:new() called but supplied camera start position [" .. tostring(camera_start_pos) .. "] is not a vector or nil");
		return false;
	end;
	
	if camera_start_targ and not is_vector(camera_start_targ) then
		script_error("ERROR: prelude_battle_movement_advice:new() called but supplied camera start target [" .. tostring(camera_start_targ) .. "] is not a vector or nil");
		return false;
	end;
	
	if not is_vector(movement_target) then
		script_error("ERROR: prelude_battle_movement_advice:new() called but supplied movement target [" .. tostring(movement_target) .. "] is not a vector");
		return false;
	end;
	
	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_movement_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if advice_key_override and not is_string(advice_key_override) then
		script_error("ERROR: prelude_battle_movement_advice:new() called but supplied advice key override [" .. tostring(advice_key_override) .. "] is not a string or nil");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_movement_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	if movement_time_override and not is_number(movement_time_override) then
		script_error("ERROR: prelude_battle_movement_advice:new() called but supplied movement time override [" .. tostring(movement_time_override) .. "] is not a number or nil");
		return false;
	end;

	local bm = get_bm();
	
	local ma = {};
	setmetatable(ma, self);
	self.__index = self;
	
	ma.bm = bm;
	ma.objectives = get_objectives_manager();
	ma.player_sunits = player_sunits;
	ma.camera_start_pos = camera_start_pos;
	ma.camera_start_targ = camera_start_targ;
	ma.movement_target = movement_target;
	ma.end_callback = end_callback;
	ma.player_sunit_marker_positions = {};
	
	if advice_key_override then
		ma.advice_key = advice_key_override;
	end;
	
	ma.progression_time = progression_time_override or ma.progression_time;
	ma.movement_time = movement_time_override or ma.movement_time;
	
	return ma;
end;


function prelude_battle_movement_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	table.insert(
		self.start_infotext, 
		function() 
			self.selection_objective_shown = true;	
			self.objectives:set_objective(self.selection_objective_key) 
		end
	);

	bm:callback(
		function()
			bm:queue_advisor(
				-- Be sure to join the fight yourself, my Lord! The troops will be greatly rallied by your presence.
				self.advice_key,
				6000,
				false,
				function() bm.infotext:add_infotext(unpack(self.start_infotext)); end
			);
		end,
		500
	);
	
	local player_sunits = self.player_sunits;
	
	-- cache player unit location
	self.player_sunits:cache_location();
	
	-- return the camera to the start position, if one were set
	if self.camera_start_pos and self.camera_start_targ then
		local cutscene_pan = cutscene:new(
			"cutscene_pan",
			player_sunits,
			2500,
			function() bm:callback(function() self:highlight_player_sunits(true) end, 1000) end
		);
		
		local cam = bm:camera();
		
		cutscene_pan:set_close_advisor_on_end(false);
		cutscene_pan:action(function() cam:move_to(self.camera_start_pos, self.camera_start_targ, 2.5, false, 0) end, 0);
		cutscene_pan:start();
	end;
	
	
	-- cache the time this advice was given
	local start_time = timestamp_tick;
	local movement_target = self.movement_target;
	
	-- watch for the player selecting a unit
	self:check_for_unit_selected();
	
	-- watch for the time elapsed passing the progression time
	bm:watch(
		function()
			return timestamp_tick > start_time + self.progression_time;
		end,
		0,
		function()
			self:stop();
			self.end_callback();
		end,
		"movement_advice"
	);
	
	core:add_listener(
		"prelude_battle_camera_movement_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false	
	);
end;


function prelude_battle_movement_advice:highlight_player_sunits(value)
	local bm = self.bm;
	
	if value == false then
		for i = 1, #self.player_sunit_marker_positions do
			local current_pos = self.player_sunit_marker_positions[i];
			bm:remove_ping_icon(current_pos:get_x(), current_pos:get_y() + 3, current_pos:get_z());
		end;
		
		self.player_sunit_marker_positions = {};
	else	
		local player_sunits = self.player_sunits;
		
		for i = 1, player_sunits:count() do
			local current_pos = player_sunits:item(i).unit:position();
			
			bm:add_ping_icon(current_pos:get_x(), current_pos:get_y() + 3, current_pos:get_z(), 10, false);
			table.insert(self.player_sunit_marker_positions, current_pos);
		end;
	end;
end;


function prelude_battle_movement_advice:check_for_unit_selected()
	local bm = self.bm;
	
	if bm:is_any_unit_selected() then
		self:unit_selected();
	else
		bm:callback(function() self:check_for_unit_selected() end, 200, "movement_advice");
	end;
end;



function prelude_battle_movement_advice:unit_selected()
	local bm = self.bm;
	
	self:remove_selection_objective();
	
	local movement_target = self.movement_target;
	
	self:highlight_player_sunits(false);
	
	table.insert(
		self.selection_infotext, 
		function() 
			self.movement_objective_shown = true;	
			self.objectives:set_objective(self.movement_objective_key) 
		end
	);

	-- show additional infotext
	bm.infotext:add_infotext(unpack(self.selection_infotext));
	
	-- mark movement position
	bm:add_ping_icon(movement_target:get_x(), movement_target:get_y(), movement_target:get_z(), 9, false);
	self.is_showing_marker = true;

	-- watch for player moving unit
	bm:watch(
		function()
			return self.player_sunits:have_all_moved()
		end,
		0,
		function()
			bm:out("<< player has moved unit >>");
			
			-- show additional infotext
			bm.infotext:add_infotext(unpack(self.movement_infotext));
			
			-- remove movement marker
			bm:remove_ping_icon(movement_target:get_x(), movement_target:get_y(), movement_target:get_z());
			
			self:remove_movement_objective();
			
			bm:callback(function() self.progression_time = self.progression_time - self.movement_time end, 5000, "movement_advice");
		end,
		"movement_advice"
	);
end;


function prelude_battle_movement_advice:remove_selection_objective()
	if self.selection_objective_shown then
		self.selection_objective_shown = false
		self.objectives:remove_objective(self.selection_objective_key);
	end;
end;


function prelude_battle_movement_advice:remove_movement_objective()
	if self.movement_objective_shown then
		self.movement_objective_shown = false
		self.objectives:remove_objective(self.movement_objective_key);
	end;
end;


function prelude_battle_movement_advice:stop()
	local bm = self.bm;
	
	if self.is_showing_marker then
		local movement_target = self.movement_target;
		bm:remove_ping_icon(movement_target:get_x(), movement_target:get_y(), movement_target:get_z());
		self.is_showing_marker = false;
	end;
	
	self:highlight_player_sunits(false);
	
	self:remove_selection_objective();
	self:remove_movement_objective();	
	
	core:remove_listener("prelude_battle_movement_advice_listener");
	bm:remove_process("movement_advice");
end;






	









	
	
prelude_battle_help_advice = {
	bm = false,
	progression_time = 30000,
	-- Remember as you fight that help and advice is available at your request, my Lord. Learn to rely upon it.
	advice_key = "war.battle.prelude.intro.020",
	infotext = {"war.battle.prelude.intro.info_020", "war.battle.prelude.intro.info_021", "war.battle.prelude.intro.info_022"},
	end_callback = false,
	player_force = false,
	enemy_force = false,
	min_distance = 90
};


function prelude_battle_help_advice:new(end_callback, player_force, enemy_force, min_distance, progression_time_override)
	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_help_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if player_force and not is_scriptunits(player_force) then
		script_error("ERROR: prelude_battle_help_advice:new() called but supplied player force [" .. tostring(player_force) .. "] is not a scriptunits collection or nil");
		return false;
	end;
	
	if enemy_force and not is_scriptunits(enemy_force) then
		script_error("ERROR: prelude_battle_help_advice:new() called but supplied enemy force [" .. tostring(enemy_force) .. "] is not a scriptunits collection or nil");
		return false;
	end;
	
	if min_distance and not (is_number(min_distance) and min_distance > 0) then
		script_error("ERROR: prelude_battle_help_advice:new() called but supplied minimum distance [" .. tostring(min_distance) .. "] is not a positive number or nil");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_help_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
		
	local bm = get_bm();
	
	local ha = {};
	setmetatable(ha, self);
	self.__index = self;
	
	ha.bm = bm;
	ha.player_force = player_force;
	ha.enemy_force = enemy_force;
	
	ha.min_distance = min_distance or ha.min_distance;
	
	ha.progression_time = progression_time_override or ha.progression_time;
	ha.end_callback = end_callback;
	
	return ha;
end;


function prelude_battle_help_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	-- trigger advice
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	-- wait for allotted time before progressing
	bm:callback(
		function()
			self:stop();
			self.end_callback() 
		end,
		self.progression_time,
		"help_advice"
	);
	
	-- if we have player and enemy forces specified, watch the distance between them and progress if it closes to below the min distance
	if self.player_force and self.enemy_force then
		bm:watch(
			function()
				return distance_between_forces(self.player_force, self.enemy_force) < self.min_distance;
			end,
			0,
			function()
				self:stop();
				self.end_callback();
			end,
			"help_advice"
		);
	end;
	
	core:add_listener(
		"prelude_battle_help_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_help_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_help_advice_listener");
	bm:remove_process("help_advice");
end;

















prelude_battle_attacking_advice = {
	bm = false,
	advice_key = "",
	player_sunits = false,
	enemy_alliance = false,
	end_callback = false,
	proximity = 20,
	max_time = 50000,
	infotext = {"war.battle.prelude.intro.info_030","war.battle.prelude.intro.info_031","war.battle.prelude.intro.info_032"},
	objectives = false,
	objective_key = "war.battle.prelude.attack_advice.001"
};


function prelude_battle_attacking_advice:new(advice_key, player_sunits, enemy_alliance, end_callback, proximity_override, max_time_override)

	if not is_string(advice_key) then
		script_error("ERROR: prelude_battle_attacking_advice:new() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;

	if not is_scriptunits(player_sunits) then
		script_error("ERROR: prelude_battle_attacking_advice:new() called but supplied scriptunits [" .. tostring(player_sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if not is_alliance(enemy_alliance) then
		script_error("ERROR: prelude_battle_attacking_advice:new() called but supplied enemy alliance [" .. tostring(enemy_alliance) .. "] is not a valid alliance");
		return false;
	end;

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_attacking_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if proximity_override and not is_number(proximity_override) then
		script_error("ERROR: prelude_battle_attacking_advice:new() called but supplied proximity override [" .. tostring(proximity_override) .. "] is not a number or nil");
		return false;
	end;
	
	if max_time_override and not is_number(max_time_override) then
		script_error("ERROR: prelude_battle_attacking_advice:new() called but supplied max time override [" .. tostring(max_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	aa = {};
	setmetatable(aa, self);
	self.__index = self;
	
	aa.bm = bm;
	aa.objectives = get_objectives_manager();
	aa.advice_key = advice_key;
	aa.player_sunits = player_sunits;
	aa.enemy_alliance = enemy_alliance;
	aa.end_callback = end_callback;
	aa.proximity = proximity_override or aa.proximity;
	aa.max_time = max_time_override or aa.max_time;
	
	return aa;
end;



function prelude_battle_attacking_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	table.insert(
		self.infotext, 
		function() 
			self.objective_shown = true;
			self.objectives:set_objective(self.objective_key) 
		end
	);
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);

	-- continue when the player's troops get close to the enemy
	bm:watch(
		function()
			return distance_between_forces(self.enemy_alliance, self.player_sunits) < self.proximity;
		end,
		10000,
		function()
			self:stop();
			self.end_callback();
		end,
		"attacking_advice"
	);
	
	bm:callback(
		function()
			self:stop();
			self.end_callback();
		end,
		self.max_time,
		"attacking_advice"
	);
	
	core:add_listener(
		"prelude_battle_attacking_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_attacking_advice:stop()
	local bm = self.bm;
	
	if self.objective_shown then
		self.objective_shown = false;
		self.objectives:remove_objective(self.objective_key);
	end;
	
	core:remove_listener("prelude_battle_attacking_advice_listener");
	bm:remove_process("attacking_advice");
end;












prelude_battle_flanking_advice = {
	bm = false,
	-- Attack the sides and the rear of the enemy where possible. Their courage will surely fade if surrounded.
	advice_key = "war.battle.prelude.intro.040",
	end_callback = false,
	progression_time = 30000,
	infotext = {"war.battle.prelude.intro.info_040","war.battle.prelude.intro.info_041","war.battle.prelude.intro.info_042"}
};


function prelude_battle_flanking_advice:new(end_callback, advice_key_override, progression_time_override)

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_flanking_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if advice_key_override and not is_string(advice_key_override) then
		script_error("ERROR: prelude_battle_flanking_advice:new() called but supplied advice key override [" .. tostring(advice_key_override) .. "] is not a string or nil");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_flanking_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local fa = {};
	setmetatable(fa, self);
	self.__index = self;
	
	fa.bm = bm;
	fa.end_callback = end_callback;
	fa.advice_key = advice_key_override or fa.advice_key;
	fa.progression_time = progression_time_override or fa.progression_time;
	
	return fa;
end;


function prelude_battle_flanking_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	bm:callback(
		function()
			self:stop();
			self.end_callback()
		end,
		self.progression_time,
		"flanking_advice"
	);
	
	core:add_listener(
		"prelude_battle_flanking_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_flanking_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_flanking_advice_listener");
	bm:remove_process("flanking_advice");
end;

















prelude_battle_routing_advice = {
	bm = false,
	enemy_sunits = false,
	is_crumbling_advice = false,
	max_time = 60000,
	progression_time = 30000,
	-- Haha! The enemy begin to crumble! They run from the battle!
	advice_key = "war.battle.prelude.intro.070",
	infotext = {"war.battle.prelude.intro.info_070","war.battle.prelude.intro.info_071","war.battle.prelude.intro.info_072"},
	-- The enemy begin to crumble! Press home your advantage! Grind them to dust!
	crumbling_advice_key = "war.battle.prelude.intro.071",
	crumbling_infotext = {"war.battle.prelude.intro.info_075","war.battle.prelude.intro.info_076","war.battle.prelude.intro.info_077"}
};


function prelude_battle_routing_advice:new(enemy_sunits, end_callback, is_crumbling_advice, advice_key_override, progression_time_override)

	if not is_scriptunits(enemy_sunits) then
		script_error("ERROR: prelude_battle_routing_advice:new() called but supplied enemy scriptunits [" .. tostring(enemy_sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_routing_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	is_crumbling_advice = not not is_crumbling_advice;
	
	if advice_key_override and not is_string(advice_key_override) then
		script_error("ERROR: prelude_battle_routing_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
		
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_routing_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local ra = {};
	setmetatable(ra, self);
	self.__index = self;
	
	ra.bm = bm;
	ra.enemy_sunits = enemy_sunits;
	ra.end_callback = end_callback;
	ra.is_crumbling_advice = is_crumbling_advice;
	
	if advice_key_override then
		ra.advice_key = advice_key_override;
		ra.crumbling_advice_key = advice_key_override;
	end;
	
	ra.progression_time = progression_time_override or ra.progression_time;
	
	return ra;
end;


function prelude_battle_routing_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	local enemy_sunits = self.enemy_sunits;
	
	if self.is_crumbling_advice then
		bm:watch(
			function()
				-- should implement num_units_wavering in the fullness of time
				local enemy_sunits = self.enemy_sunits;
				for i = 1, enemy_sunits:count() do
					if enemy_sunits:item(i).unit:is_wavering() then
						return true;
					end;					
				end;
				
				return false;
			end,
			2000,
			function()
				self:deliver_advice();
			end,
			"routing_advice"
		);
	else
		bm:watch(
			function()
				return num_units_routing(enemy_sunits) >= 1;
			end,
			2000,
			function()
				self:deliver_advice();
			end,
			"routing_advice"
		);
	end;
	
	core:add_listener(
		"prelude_battle_routing_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;



function prelude_battle_routing_advice:deliver_advice()
	local bm = get_bm();
	
	bm:remove_process("routing_advice");
	
	if self.is_crumbling_advice then
		bm:queue_advisor(
			self.crumbling_advice_key,
			0,
			false,
			function()
				bm.infotext:add_infotext(unpack(self.crumbling_infotext));
			end
		);
	else
		bm:queue_advisor(
			self.advice_key,
			0,
			false,
			function()
				bm.infotext:add_infotext(unpack(self.infotext));
			end
		);
	end;
	
	bm:callback(
		function()
			self:stop();
			self.end_callback();
		end, 
		self.progression_time, 
		"routing_advice"
	);
end;


function prelude_battle_routing_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_routing_advice_listener");
	bm:remove_process("routing_advice");
end;






























prelude_battle_defences_advice = {
	bm = false,
	-- The defences must fall, my Lord. Scale the walls, and take the fight to the enemy!
	advice_key = "war.battle.prelude.intro.090",
	infotext = {"war.battle.prelude.intro.info_090","war.battle.prelude.intro.info_091"},
	end_callback = false,
	progression_time = 40000,
	objectives = false,
	objective_key = "war.battle.prelude.enter_city_advice.001",
	objective_shown = false
};


function prelude_battle_defences_advice:new(end_callback, progression_time_override)
	
	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_defences_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_defences_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local da = {};
	setmetatable(da, self);
	self.__index = self;
	
	da.bm = bm;
	da.objectives = get_objectives_manager();
	da.end_callback = end_callback;
	da.progression_time = progression_time_override or da.progression_time;
	
	return da;
end;


function prelude_battle_defences_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	table.insert(
		self.infotext, 
		function() 
			self.objective_shown = true;
			self.objectives:set_objective(self.objective_key) 
		end
	);
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	bm:callback(
		function()
			self:stop();
			self.end_callback()
		end,
		self.progression_time,
		"defences_advice"
	);
	
	core:add_listener(
		"prelude_battle_defences_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_defences_advice:stop()
	local bm = self.bm;
	
	if self.objective_shown then
		self.objective_shown = false;
		self.objectives:remove_objective(self.objective_key);
	end;
	
	core:remove_listener("prelude_battle_defences_advice_listener");
	bm:remove_process("defences_advice");
end;
















prelude_battle_reinforcements_advice = {
	bm = false,
	end_callback = false,
	progression_time = 40000,
	-- My Lord, reinforcements! The forces under your command grow as fresh troops join the fight!
	advice_key = "war.battle.prelude.intro.050",
	infotext = {"war.battle.prelude.intro.info_050", "war.battle.prelude.intro.info_051", "war.battle.prelude.intro.info_052"}
};


function prelude_battle_reinforcements_advice:new(end_callback, progression_time_override)

	if not is_function(end_callback) then
		script_error("ERROR: start_battle_reinforcements_advice() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_reinforcements_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local ra = {};
	setmetatable(ra, self);
	self.__index = self;
	
	ra.bm = bm;
	ra.end_callback = end_callback;
	ra.progression_time = progression_time_override or ra.progression_time;
	
	return ra;
end;


function prelude_battle_reinforcements_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() 
			bm.infotext:add_infotext(unpack(self.infotext)) 
		end
	);
	
	bm:callback(
		function()
			self:stop();
			self.end_callback();
		end,
		self.progression_time,
		"reinforcements_advice"
	);
	
	core:add_listener(
		"prelude_battle_reinforcements_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_reinforcements_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_reinforcements_advice_listener");
	bm:remove_process("defences_advice");
end;

















prelude_battle_ordering_advice = {
	bm = false,
	end_callback = false,
	player_sunits = false,
	enemy_alliance = false,
	-- Be sure to take charge of the forces you control, Sire. Effective command of your army is a skill worth mastering.
	advice_key = "war.battle.prelude.intro.060",
	infotext = {"war.battle.prelude.intro.info_060", "war.battle.prelude.intro.info_061", "war.battle.prelude.intro.info_062"},
	progression_time = 40000,
	proximity = 40
};


function prelude_battle_ordering_advice:new(end_callback, player_sunits, enemy_alliance, progression_time_override)

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_ordering_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if player_sunits and not is_scriptunits(player_sunits) then
		script_error("ERROR: prelude_battle_ordering_advice:new() called but supplied scriptunits [" .. tostring(player_sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;
	
	if enemy_alliance and not is_alliance(enemy_alliance) then
		script_error("ERROR: prelude_battle_ordering_advice:new() called but supplied enemy alliance [" .. tostring(enemy_alliance) .. "] is not a valid alliance");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_ordering_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local oa = {};
	setmetatable(oa, self);
	self.__index = self;
	
	oa.bm = bm;
	oa.end_callback = end_callback;
	oa.player_sunits = player_sunits;
	oa.enemy_alliance = enemy_alliance;
	oa.progression_time = progression_time_override or oa.progression_time;
	
	return oa;
end;

function prelude_battle_ordering_advice:start()
	local bm = self.bm;
		
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	-- wait a bit before proceeding
	bm:callback(
		function()
			self:stop();
			self.end_callback()
		end,
		self.progression_time,
		"ordering_advice"
	);
	
	-- optionally proceed if the player's troops get close to the enemy
	if self.player_sunits and self.enemy_alliance then
		bm:watch(
			function()
				return distance_between_forces(self.enemy_alliance, self.player_sunits) < self.proximity;
			end,
			0,
			function()
				self:stop();
				self.end_callback();
			end,
			"ordering_advice"
		);
	end;
	
	core:add_listener(
		"prelude_battle_ordering_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_ordering_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_ordering_advice_listener");
	bm:remove_process("ordering_advice");
end;















prelude_battle_ranged_advice = {
	bm = false,
	end_callback = false,
	progression_time = 50000,
	-- Keep your missile units back from the enemy, my Lord. They will be most effective if allowed to shoot from a distance.
	advice_key = "war.battle.prelude.intro.080",
	infotext = {"war.battle.prelude.intro.info_080", "war.battle.prelude.intro.info_081", "war.battle.prelude.intro.info_082"}
};


function prelude_battle_ranged_advice:new(end_callback, progression_time_override)

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_ranged_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_ranged_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local ra = {};
	setmetatable(ra, self);
	self.__index = self;
	
	ra.bm = bm;
	ra.end_callback = end_callback;
	ra.progression_time = progression_time_override or ra.progression_time;
	
	return ra;
end;


function prelude_battle_ranged_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	-- wait a bit before proceeding
	bm:callback(
		function()
			self:stop()
			self.end_callback()
		end,
		self.progression_time,
		"ranged_advice"
	);
	
	core:add_listener(
		"prelude_battle_ranged_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_ranged_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_ranged_advice_listener");
	bm:remove_process("ranged_advice");
end;















prelude_battle_magic_advice = {
	bm = false,
	end_callback = false,
	progression_time = 50000,
	advice_key = false,
	infotext = {"war.battle.prelude.intro.info_140", "war.battle.prelude.intro.info_141", "war.battle.prelude.intro.info_142", "war.battle.prelude.intro.info_143"},
	objectives = nil,
	objective_key = "",
	objective_showing = false
};


function prelude_battle_magic_advice:new(advice_key, objective_key, end_callback, progression_time_override)

	if not is_string(advice_key) then
		script_error("ERROR: prelude_battle_magic_advice:new() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("ERROR: prelude_battle_magic_advice:new() called but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_magic_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_magic_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local ma = {};
	setmetatable(ma, self);
	self.__index = self;
	
	ma.bm = bm;
	ma.objectives = get_objectives_manager();
	ma.advice_key = advice_key;
	ma.objective_key = objective_key;
	ma.end_callback = end_callback;
	ma.progression_time = progression_time_override or ma.progression_time;
	
	return ma;
end;


function prelude_battle_magic_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	-- insert the showing of the objective key into the infotext
	table.insert(
		self.infotext, 
		function() 
			local uic_ability = find_uicomponent(core:get_ui_root(), "button_ability1");
			
			if uic_ability then
				-- show objective
				self.objectives:set_objective(self.objective_key);
				self.objective_showing = true;
			
				-- watch for a magic button becoming visible, then remove objective
				bm:watch(
					function()
						return uic_ability:Visible();
					end,
					0,
					function()
						self:complete_objective();
					end,
					"magic_advice"
				);
				
				-- failsafe
				bm:callback(function() self:complete_objective() end, 20000);
			else
				script_error("ERROR: prelude_battle_magic_advice() couldn't find uic_ability");
			end;
		end
	);
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	-- wait a bit before proceeding
	bm:callback(
		function()
			self:stop()
			self.end_callback()
		end,
		self.progression_time,
		"magic_advice"
	);
	
	core:add_listener(
		"prelude_battle_magic_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_magic_advice:complete_objective(immediate)	
	local remove_func = function()
		if self.objective_showing then
			self.objective_showing = false;
			self.objectives:remove_objective(self.objective_key);
		end;
	end;
	
	if immediate then
		remove_func();
	else
		bm:callback(function() remove_func() end, 2000, "magic_advice");
	end;
end;


function prelude_battle_magic_advice:stop()
	self:complete_objective(true);

	local bm = self.bm;
	core:remove_listener("prelude_battle_magic_advice_listener");
	bm:remove_process("magic_advice");
end;














prelude_battle_victory_point_advice = {
	bm = false,
	end_callback = false,
	progression_time = 45000,
	advice_key = "war.battle.advice.victory_points.003",
	infotext = {"war.battle.advice.victory_points.info_001", "war.battle.advice.victory_points.info_002", "war.battle.advice.victory_points.info_003", "war.battle.advice.victory_points.info_004"}
};


function prelude_battle_victory_point_advice:new(end_callback, progression_time_override)

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_victory_point_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_victory_point_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local va = {};
	setmetatable(va, self);
	self.__index = self;
	
	va.bm = bm;
	va.advice_key = advice_key;
	va.end_callback = end_callback;
	va.progression_time = progression_time_override or va.progression_time;
	
	return va;
end;


function prelude_battle_victory_point_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	-- wait a bit before proceeding
	bm:callback(
		function()
			self:stop()
			self.end_callback()
		end,
		self.progression_time,
		"victory_point_advice"
	);
	
	core:add_listener(
		"prelude_battle_victory_point_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_victory_point_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_victory_point_advice_listener");
	bm:remove_process("victory_point_advice");
end;


























prelude_battle_general_advice = {
	bm = false,
	end_callback = false,
	progression_time = 50000,
	-- Your presence can sway the battle, my Lord! Your words and actions can inspire the troops before you. Use your influence and abilities!
	advice_key = "war.battle.prelude.intro.100",
	infotext = {"war.battle.prelude.intro.info_100", "war.battle.prelude.intro.info_101", "war.battle.prelude.intro.info_102"}
};


function prelude_battle_general_advice:new(end_callback, progression_time_override)

	if not is_function(end_callback) then
		script_error("ERROR: prelude_battle_general_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_general_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local ga = {};
	setmetatable(ga, self);
	self.__index = self;
	
	ga.bm = bm;
	ga.end_callback = end_callback;
	ga.progression_time = progression_time_override or ga.progression_time;
	
	return ga;
end;


function prelude_battle_general_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	-- wait a bit before proceeding
	bm:callback(
		function()
			self:stop()
			self.end_callback()
		end,
		self.progression_time,
		"general_advice"
	);
	
	core:add_listener(
		"prelude_battle_general_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_general_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_general_advice_listener");
	bm:remove_process("general_advice");
end;













prelude_battle_enemy_general_advice = {
	bm = false,
	end_callback = false,
	progression_time = 50000,
	advice_key = false,
	infotext = {"war.battle.prelude.intro.info_110", "war.battle.prelude.intro.info_111", "war.battle.prelude.intro.info_112", "war.battle.prelude.intro.info_113"}
};


function prelude_battle_enemy_general_advice:new(advice_key, enemy_general_sunits, end_callback, progression_time_override)

	if not is_string(advice_key) then
		script_error("ERROR: prelude_battle_enemy_general_advice:new() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
	
	if not is_scriptunits(enemy_general_sunits) then
		script_error("ERROR: prelude_battle_enemy_general_advice:new() called but supplied enemy general sunits [" .. tostring(enemy_general_sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;

	if end_callback and not is_function(end_callback) then
		script_error("ERROR: prelude_battle_enemy_general_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_enemy_general_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local ga = {};
	setmetatable(ga, self);
	self.__index = self;
	
	ga.bm = bm;
	ga.enemy_general_sunits = enemy_general_sunits;
	ga.advice_key = advice_key;
	ga.end_callback = end_callback;
	ga.progression_time = progression_time_override or ga.progression_time;
	
	return ga;
end;


function prelude_battle_enemy_general_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	bm:queue_advisor(
		self.advice_key,
		0,
		false,
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	-- make enemy general visible
	self.enemy_general_sunits:set_always_visible(true);
	
	-- wait a bit before proceeding
	bm:callback(
		function()
			self:stop()
			if self.end_callback then
				self.end_callback();
			end;
		end,
		self.progression_time,
		"enemy_general_advice"
	);
	
	core:add_listener(
		"prelude_battle_enemy_general_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_enemy_general_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_enemy_general_advice_listener");
	bm:remove_process("enemy_general_advice");
end;














prelude_battle_enemy_general_fleeing_advice = {
	bm = false,
	end_callback = false,
	progression_time = 50000,
	advice_key = false,
	must_die = false
};


function prelude_battle_enemy_general_fleeing_advice:new(advice_key, enemy_general, enemy_sunits, must_die, end_callback, progression_time_override)

	if not is_string(advice_key) then
		script_error("ERROR: prelude_battle_enemy_general_fleeing_advice:new() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;
	
	if not is_scriptunit(enemy_general) then
		script_error("ERROR: prelude_battle_enemy_general_fleeing_advice:new() called but supplied enemy general scriptunit [" .. tostring(enemy_general) .. "] is not a valid scriptunit");
		return false;
	end;
	
	if not is_scriptunits(enemy_sunits) then
		script_error("ERROR: prelude_battle_enemy_general_fleeing_advice:new() called but supplied enemy sunits [" .. tostring(enemy_general_sunits) .. "] is not a valid scriptunits collection");
		return false;
	end;

	must_die = not not must_die;
	
	if end_callback and not is_function(end_callback) then
		script_error("ERROR: prelude_battle_enemy_general_fleeing_advice:new() called but supplied end callback [" .. tostring(end_callback) .. "] is not a function or nil");
		return false;
	end;
	
	if progression_time_override and not is_number(progression_time_override) then
		script_error("ERROR: prelude_battle_enemy_general_fleeing_advice:new() called but supplied progression time override [" .. tostring(progression_time_override) .. "] is not a number or nil");
		return false;
	end;
	
	local bm = get_bm();
	
	local ga = {};
	setmetatable(ga, self);
	self.__index = self;
	
	ga.bm = bm;
	ga.advice_key = advice_key;
	ga.enemy_general = enemy_general;
	ga.enemy_sunits = enemy_sunits;
	ga.end_callback = end_callback;
	ga.must_die = must_die;
	ga.progression_time = progression_time_override or ga.progression_time;
	
	return ga;
end;


function prelude_battle_enemy_general_fleeing_advice:start()
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");
	
	local test = function() return is_routing_or_dead(self.enemy_general) end;
	
	if self.must_die then
		test = function() return self.enemy_general.unit:number_of_men_alive() == 0 end
	end;
	
	bm:watch(
		function()
			return test()
		end,
		2000,
		function()
			bm:clear_infotext();
			bm:queue_advisor(
				self.advice_key,
				0,
				false
			);
			
			-- kill the general as the advice implies that he is dead
			self.enemy_general.uc:kill();
			
			-- rout all the enemy units as the enemy general has routed or died
			for i = 1, self.enemy_sunits:count() do
				bm:callback(
					function()
						local current_sunit = self.enemy_sunits:item(i);
						
						current_sunit.uc:morale_behavior_default();
						bm:callback(function() current_sunit.uc:morale_behavior_rout() end, 200);
					end,
					i * 3000,
					"enemy_general_fleeing_advice"
				);
			end;
			
			-- progress after a little bit
			bm:callback(
				function()
					self:stop();
					if is_function(self.end_callback) then
						self.end_callback();
					end;						
				end,
				self.progression_time,
				"enemy_general_fleeing_advice"
			);
		end,
		"enemy_general_fleeing_advice"
	);
	
	core:add_listener(
		"prelude_battle_enemy_general_fleeing_advice_listener",
		"ScriptEventStopPreludeBattleProcesses",
		true,
		function()
			self:stop()
		end,
		false
	);
end;


function prelude_battle_enemy_general_fleeing_advice:stop()
	local bm = self.bm;
	core:remove_listener("prelude_battle_enemy_general_fleeing_advice_listener");
	bm:remove_process("enemy_general_fleeing_advice");
end;

















prelude_battle_end = {
	bm = false,
	advice_key = false,
	enemy_sunits = false,
	infotext = {"war.battle.prelude.intro.info_120","war.battle.prelude.intro.info_121","war.battle.prelude.intro.info_122"}
};


function prelude_battle_end:new(advice_key, enemy_sunits)

	if not is_string(advice_key) then
		script_error("ERROR: start_prelude_battle_end() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		bm:end_battle();
		return false;
	end;
	
	if not is_scriptunits(enemy_sunits) then
		script_error("ERROR: start_prelude_battle_end() called but supplied enemy scriptunits collection [" .. tostring(enemy_sunits) .. "] is not a valid scriptunits collection");
		bm:end_battle();
		return false;
	end;
	
	local bm = get_bm();
	
	local be = {};
	setmetatable(be, self);
	self.__index = self;
	
	be.bm = bm;
	be.advice_key = advice_key;
	be.enemy_sunits = enemy_sunits;
	
	return be;
end;


function prelude_battle_end:start()
	
	local bm = self.bm;
	
	core:trigger_event("ScriptEventStopPreludeBattleProcesses");

	bm:stop_advisor_queue(true);
	bm:queue_advisor(
		self.advice_key,
		0,
		false,				
		function() bm.infotext:add_infotext(unpack(self.infotext)) end
	);
	
	bm:callback(
		function()
			bm:end_battle();
		end,
		10000
	);
	
	self.enemy_sunits:morale_behavior_rout();
end;











