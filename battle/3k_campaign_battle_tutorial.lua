gb = generated_battle:new(
	false,        	                              		-- screen starts black
	false,	                                      		-- prevent deployment for player
    false,                                      		-- prevent deployment for ai
	nil,												-- intro cutscene function
	true                                      			-- debug mode
);

-- forces the default unit selection to remain active throughout the battle and not activate/deactivate
bm:force_unit_selection_handler_active(true);

-------------------------------------------------------------------------------------------------
------------------------------------ ARMY SETUP -------------------------------------------------
-------------------------------------------------------------------------------------------------

ga_player_main_01 = gb:get_army(gb:get_player_alliance_num(), 1);
ga_ai_main_01 = gb:get_army(gb:get_non_player_alliance_num(), 1);


-------------------------------------------------------------------------------------------------
------------------------------------ VARIABLES --------------------------------------------------
-------------------------------------------------------------------------------------------------

local states = {}
	states.ENTRY_POINT = "int_deployment_entry_point";
	states.CONFIRM_CANCEL = "int_deployment_confirm_cancel";
	states.DEPLOYMENT_HIGHLIGHT_DEPLOYMENT = "int_deployment_highlight_deployment";
	states.CAMERA_HIGHLIGHT_ENEMY = "int_camera_highlight_enemy";
	states.CAMERA_HIGHLIGHT_SELF = "int_camera_highlight_self";
	states.CAMERA_RAISE_LOWER = "int_camera_raise_lower"
	states.CAMERA_ROTATE = "int_camera_rotate"
	states.PLACEMENT_MOVE_CAMERA = "int_placement_move_camera";
	states.PLACEMENT_SELECT_SINGLE_UNIT = "int_placement_select_single_unit";
	states.PLACEMENT_PLACE_SINGLE_UNIT = "int_placement_place_single_unit";
	states.PLACEMENT_DRAGOUT_SINGLE_UNIT = "int_placement_dragout_single_unit";
	states.PLACEMENT_DESELECT_SINGLE_UNIT = "int_placement_deselect_single_unit";
	states.PLACEMENT_SELECT_MULTIPLE = "int_placement_select_multiple";
	states.PLACEMENT_DRAGOUT_MULTIPLE = "int_placement_dragout_multi";
	states.BATTLE_START_BATTLE = "int_start_battle";
	states.BATTLE_SELECT_ALL_UNITS = "int_battle_start_select_all_units";
	states.BATTLE_MOVE_TOWARDS_ENEMY = "int_battle_start_move_towards_enemy";
	states.BATTLE_PAUSE = "int_battle_pause";
	states.BATTLE_PAUSED_CHECK_UNIT_SELECTED = "int_battle_paused_check_unit"
	states.BATTLE_SHOW_INFO_OVERLAY = "int_battle_info_overlay";
	states.BATTLE_EXPLAIN_INFO_OVERLAY = "int_battle_info_overlay_explain";
	states.BATTLE_CLOSE_INFO_OVERLAY = "int_battle_info_overlay_close";
	states.BATTLE_SHOW_THREAT = "int_battle_show_threat";
	states.BATTLE_DESELECT_UNIT = "int_battle_deselect_unit";
	states.BATTLE_SELECT_UNIT = "int_battle_select_unit";
	states.BATTLE_SELECT_UNIT_2 = "int_battle_select_unit_2";
	states.BATTLE_ISSUE_ATTACK_ORDER = "int_issue_atttack_order";
	states.BATTLE_UNPAUSE = "int_battle_unpause";
	states.BATTLE_SHOW_VICTORY_OBJECTIVE = "int_battle_show_victory_obj";
	states.BATTLE_WAIT_FOR_VICTORY = "int_battle_wait_for_victory";
	states.BATTLE_IS_ENDING = "int_battle_is_ending";
	states.END = "int_end";


local distance_for_wasd_state = 250; -- How far from the enemy to get before we end this state.
local distance_for_qe_state = 250; -- How far from the player to get before we end this state.
local distance_to_up_down = 1.5; -- How far up or down the player must move their camera.
local angle_for_look_state = 40; -- Angle the user has to be within from the look target.
local angle_for_rotate = 30; -- Angle the user has to turn to exit this state.
local times_to_hit_for_rotation = 2; -- The player must rotate more than this many times to trigger the next step.
local distance_to_pause_game = 200; -- How far from the enemy the player's troops need to be before we auto-pause.
local distance_for_placement = 13; -- How close to the marker does the player need to place the unit for success.
local ping_height_offset = 10;
local ping_default_radius = 10;

-- Battle
local battle_direction = 0;

-- UNITS
-- Enemy Commander
local su_enemy_commander = ga_ai_main_01:get_first_scriptunit();
local v_enemy_commander_start_pos = su_enemy_commander.unit:position();
local v_enemy_commander_start_rotation = su_enemy_commander.unit:bearing();


-- Player Commander
local su_player_commander = ga_player_main_01:get_first_scriptunit();
local v_player_commander_start_pos = su_player_commander.unit:position();
local v_player_commander_start_rotation = su_player_commander.unit:bearing();


-- Deployment Selection Unit
local su_deployment_selection_unit = nil;
-- Select our first unit based on the facing of the commander.
local v_angle = math.round_to_nearest(v_player_commander_start_rotation, 90);
if v_angle == 0 then
	su_deployment_selection_unit = ga_player_main_01:get_most_westerly_scriptunit();
elseif v_angle == 90 then
	su_deployment_selection_unit = ga_player_main_01:get_most_northerly_scriptunit();
elseif v_angle == 180 then
	su_deployment_selection_unit = ga_player_main_01:get_most_easterly_scriptunit();
else
	su_deployment_selection_unit = ga_player_main_01:get_most_southerly_scriptunit();
end;

local v_deployment_selection_unit_start_pos = su_deployment_selection_unit.unit:position();
local v_deployment_selection_unit_start_rotation = su_deployment_selection_unit.unit:bearing();



-- POSITIONS
-- Where we ask the player to place their first unit.
local v_deployment_placement_position = offset_vector_by_angle_xz( 
	v_deployment_selection_unit_start_pos, 
	v_deployment_selection_unit_start_rotation - 90, 
	25 );

-- Where we ask the player to click to deselect their first unit.
local v_deployment_deselection_location = offset_vector_by_angle_xz( 
	v_deployment_selection_unit_start_pos, 
	v_deployment_selection_unit_start_rotation, 
	50 );

-- Where we sent the camera to 'highlight' the initial unit.
local v_camera_move_to_pos = v_offset(
	offset_vector_by_angle_xz( 
		v_deployment_selection_unit_start_pos, 
		v_deployment_selection_unit_start_rotation, 
		-100 ),
	0, 50, 0);

-- Where the above camera looks at.
local v_camera_move_to_target = v_offset(
	offset_vector_by_angle_xz( 
		v_deployment_selection_unit_start_pos, 
		v_deployment_selection_unit_start_rotation, 
		0 ),
	0, 0, 0);

-- Where we ask the player to order their units to attack.
local v_battle_units_move_to_pos = offset_vector_by_angle_xz( 
	v_enemy_commander_start_pos, 
	v_player_commander_start_rotation, 
	-distance_to_pause_game + 50 ); -- Small magic number here so the player thinks they have to move closer than they already do.

local valid_icon_types = 
{
	["keys_w_a_s_d"] = true,
	["keys_q_e"] = true,
	["mouse_right_click"] = true,
	["mouse_left_click"] = true,
	["mouse_scroll"] = true,
	["mouse_left_click_drag"] = true,
	["mouse_right_click_drag"] = true,
	["keys_ctrl_a"] = true,
	["key_p"] = true,
	["key_f1"] = true,
	["key_esc"] = true,
	["icon_threat"] = true
}
-------------------------------------------------------------------------------------------------
------------------------------------ FUNCTIONS --------------------------------------------------
-------------------------------------------------------------------------------------------------
local function show_choice_window()
	output("Showing Choice Window");
	effect.set_context_value("battle_tutorial_choice", 1);
end;

local function hide_choice_window()
	output("Hiding Choice Window");
	effect.set_context_value("battle_tutorial_choice", 0);
end;

local function display_skip_button()
	output("Showing skip button");
	effect.set_context_value("battle_tutorial_skip_button_visibility", 1);
end;

local function hide_skip_button()
	output("Hiding skip button");
	effect.set_context_value("battle_tutorial_skip_button_visibility", 0);
end;

local function display_central_text( text_key, icon_key )
	if not is_string( text_key ) then
		script_error("ERROR: display_central_text() Invalid text_key");
		return;
	end;

	if icon_key and not is_string( icon_key ) then
		script_error("ERROR: display_central_text() Invalid icon_key");
		return;
	end;

	output("Showing text" .. text_key);
	effect.set_context_value("battle_tutorial_central_text", "scripted_objectives_localised_text_" .. text_key);

	if icon_key then
		if not valid_icon_types[ icon_key ] then
			script_error("ERROR: display_central_text() Invalid Icon Key." .. tostring( icon_key ));
			return;
		end;

		effect.set_context_value("battle_tutorial_icon_switch", icon_key);
	end;
end;

local function hide_central_text()
	output("Hiding text");
	effect.set_context_value("battle_tutorial_central_text", "");
	effect.set_context_value("battle_tutorial_icon_switch", "");
end;

local function highlight_start_battle()
	output("Highlight start battle");
	effect.set_context_value("highlight_start_battle", 1);
end;

local function remove_highlight_start_battle()
	output("Ending Highlight start battle");
	effect.set_context_value("highlight_start_battle", 0);
end;

local function highlight_info_overlay()
	output("highlight_info_overlay");
	effect.set_context_value("highlight_info_overlay_button", 1);
end;

local function remove_highlight_info_overlay()
	output("Ending highlight_info_overlay");
	effect.set_context_value("highlight_info_overlay_button", 0);
end;

local function disable_start_battle_button()
	local c = find_uicomponent(core:get_ui_root(), "finish_deployment", "button_battle_start")

	if c then
		c:SetState("inactive");
	end;
end;

local function enable_start_battle_button()
	local c = find_uicomponent(core:get_ui_root(), "finish_deployment", "button_battle_start")

	if c then
		c:SetState("active");
	end;
end;

local function callback_after_five_seconds( callback )
	local c = find_uicomponent(core:get_ui_root(), "battle_tutorial_objects", "hidden_animated_entity");

	c:TriggerAnimation("hidden_animated_five_seconds");

	core:add_listener(
		"tutorial_callback_after_five_seconds",
		"UIAnimationEnded",
		function(context) 
			return context.string == "hidden_animated_five_seconds";
		end,
		function(context)
			callback();
		end,
		false
	);
end;

local function remove_five_second_callback()
	core:remove_listener("tutorial_callback_after_five_seconds");
end;

local function callback_after_ten_seconds( callback )
	local c = find_uicomponent(core:get_ui_root(), "battle_tutorial_objects", "hidden_animated_entity_2");

	c:TriggerAnimation("hidden_animated_ten_seconds");

	core:add_listener(
		"tutorial_callback_after_ten_seconds",
		"UIAnimationEnded",
		function(context) 
			return context.string == "hidden_animated_ten_seconds";
		end,
		function(context)
			callback();
		end,
		false
	);
end;

local function remove_ten_second_callback()
	core:remove_listener("tutorial_callback_after_ten_seconds");
end;

local function toggle_shortcuts( enabled )
	local disabled_shortcuts = {
		"toggle_ui",
		"toggle_ui_with_borders",
		"help_mode",
		"open_academy",
		"show_tactical_map",
		"cycle_battle_speed",
		"toggle_pause"
	}

	for i = 1, #disabled_shortcuts do
		bm.battle:disable_shortcut( disabled_shortcuts[i], not enabled );
	end;
end;

local function is_camera_looking_at_target(target_position, threshold_distance, threshold_angle)
	local cam = bm:camera();

	local cam_pos = cam:position();
	local targ_pos = cam:target();
	local marker_pos = target_position;

	local cam_distance = cam_pos:distance(marker_pos);

	-- trigger if we're close enough to the marker position
	if cam_distance < threshold_distance then		
		
		if angle_between_vectors(marker_pos, targ_pos, cam_pos) < threshold_angle then
			output("Angle and distance match. Angle= " .. tostring(angle_between_vectors(marker_pos, targ_pos, cam_pos)));
			return true;
		end;
	end;

	return false;
end;

local function set_tutorial_battle_seen()
	effect.set_advice_history_string_seen("has_played_tutorial_battle"); -- Enable this to stop it firing each time!
end;

-------------------------------------------------------------------------------------------------
------------------------------------ EVENTS -----------------------------------------------------
-------------------------------------------------------------------------------------------------
require( "lib_state_machine" );

local root = core:get_ui_root(); -- Main battle hud.
root:CreateComponent("battle_tutorial_objects", "UI/Battle UI/battle_tutorial_messages")

-- Setup a new state machine for our tutorial.
local sm = state_machine:new( "battle_tutorial_state_machine", states.ENTRY_POINT, true );

-- Point the camera at the point of the first ping icon.
gb:add_listener(
	"deployment_started",
	function()
		bm:start_engagement_monitor(); -- Required for polling the distance between forces.

		-- Set up the initial camera position.
		local camera_pos = v_offset(
			offset_vector_by_angle_xz( 
				v_player_commander_start_pos, 
				v_player_commander_start_rotation, 
				-15 ),
			0, 10, 0);

		local camera_target = v_enemy_commander_start_pos;

		bm:camera():move_to(camera_pos, camera_target, 0, false, 0);
	end,
	false
)


-- Start our script once the loading screen is dismissed.
gb:add_listener(
    "loading_screen_dismissed", --"deployment_started",
	function()
		sm:start();
	end,
	false
);


-- Listen for the skip tutorial button being pressed.
core:add_listener(
	"skip_listener", -- Unique handle
	"ComponentLClickUp", -- Campaign Event to listen for
	function(context) -- Criteria
		return context.string == "button_skip_tutorial"
	end,
	function(context) -- What to do if listener fires.
		sm:change_to( states.BATTLE_ISSUE_ATTACK_ORDER );
	end,
	true --Is persistent
);

-- Listen the user ending the battle. And mark it as seen.
core:add_listener(
	"skip_listener", -- Unique handle
	"ComponentLClickUp", -- Campaign Event to listen for
	function(context) -- Criteria
		return context.string == "button_dismiss_results"
	end,
	function(context) -- What to do if listener fires.
		output("User ended the battle!");
		set_tutorial_battle_seen(); -- Enable this to stop it firing each time!
	end,
	true --Is persistent
);

--[[
****************************************************************************
-- DEPLOYMENT
****************************************************************************
]]--

sm:add_state( states.ENTRY_POINT, -- name
	function()
		output("LS dismissed");
		sm:change_to( states.CONFIRM_CANCEL );
	end, --on_enter_callback
	nil --on_exit_callback 
);


sm:add_state( states.CONFIRM_CANCEL, -- name
	function() 
		show_choice_window();

		-- State change

		-- User accepts
		sm:state_change_listener(states.DEPLOYMENT_HIGHLIGHT_DEPLOYMENT, "ComponentLClickUp", function(context) return context.string == "button_tick" end );

		-- User rejects
		sm:state_change_listener(states.BATTLE_IS_ENDING, "ComponentLClickUp", function(context) return context.string == "button_cancel" end );
	end, --on_enter_callback
	nil --on_exit_callback 
);


sm:add_state( states.DEPLOYMENT_HIGHLIGHT_DEPLOYMENT, -- name
	function()
		-- This is where the script actually starts!
		ga_player_main_01:change_behaviour_active_on_message("battle_started", "auto_reject_duels", true); -- Auto-reject duels
		disable_start_battle_button(); -- Don't allow the player to start the battle until we're done.
		ga_player_main_01.army:highlight_deployment_areas(true); -- Flash the deplotment areas.
		
		-- State change
		sm:state_change_callback(states.CAMERA_HIGHLIGHT_ENEMY, 500);
	end, --on_enter_callback
	function() 
		ga_player_main_01.army:highlight_deployment_areas(false);
	end --on_exit_callback 
);


--[[
****************************************************************************
-- CAMERA CONTROLS
****************************************************************************
]]--


sm:add_state( states.CAMERA_HIGHLIGHT_ENEMY, -- name
	function() 		
		bm:add_named_ping_icon("ping_01", v_enemy_commander_start_pos:get_x(), v_enemy_commander_start_pos:get_y() + ping_height_offset, v_enemy_commander_start_pos:get_z(), 6, false, 0, ping_default_radius);
		display_central_text("3k_main_battle_tutorial_camera_move_to_enemy", "keys_w_a_s_d");

		-- State change
		sm:state_change_watch( states.CAMERA_RAISE_LOWER, 
			function() return is_camera_looking_at_target(v_enemy_commander_start_pos, distance_for_wasd_state, angle_for_look_state) end );
	end, --on_enter_callback
	function() 
		bm:remove_named_ping_icon("ping_01");

		hide_central_text();
	end --on_exit_callback
);

sm:add_state( states.CAMERA_RAISE_LOWER,
	function()
		display_central_text("3k_main_battle_tutorial_camera_raise_lower", "mouse_scroll");

		local cached_camera_height = bm:camera():position():get_y();
		local has_gone_up = false;
		local has_gone_down = false;

		-- State Change
		sm:state_change_watch( states.CAMERA_ROTATE, 
			function() 
				if not has_gone_up and bm:camera():position():get_y() > cached_camera_height + distance_to_up_down then
					has_gone_up = true;
					cached_camera_height = bm:camera():position():get_y();
					output("Has gone up!");
				end

				if not has_gone_down and bm:camera():position():get_y() < cached_camera_height - distance_to_up_down then
					has_gone_down = true;
					cached_camera_height = bm:camera():position():get_y();
					output("Has gone down!");
				end;

				return has_gone_up and has_gone_down;
			end );
	end,
	function()
		hide_central_text();
	end

);

sm:add_state( states.CAMERA_ROTATE, -- name
	function()
		display_central_text("3k_main_battle_tutorial_camera_rotate", "keys_q_e");

		-- State Change
		sm:state_change_watch( states.CAMERA_HIGHLIGHT_SELF, 
			function() return is_camera_looking_at_target(v_player_commander_start_pos, 50000, angle_for_look_state) end ); -- Use infinite distance as we don't care about it.
		
	end, --on_enter_callback
	function()
		hide_central_text();
	end --on_exit_callback
);

sm:add_state( states.CAMERA_HIGHLIGHT_SELF, -- name
	function() 
		bm:add_named_ping_icon("ping_01", v_player_commander_start_pos:get_x(), v_player_commander_start_pos:get_y() + ping_height_offset, v_player_commander_start_pos:get_z(), 6, false, 0, ping_default_radius);
		display_central_text("3k_main_battle_tutorial_camera_move_to_own", "keys_w_a_s_d");

		-- State change
		sm:state_change_watch( states.PLACEMENT_MOVE_CAMERA, 
			function() return is_camera_looking_at_target(v_player_commander_start_pos, distance_for_qe_state, angle_for_look_state) end );
	end, --on_enter_callback
	function() 
		bm:remove_named_ping_icon("ping_01");
		hide_central_text();
	end --on_exit_callback
);


--[[
****************************************************************************
-- UNIT PLACEMENT
****************************************************************************
]]--


sm:add_state( states.PLACEMENT_MOVE_CAMERA, -- name
	function()
		local camera_move = cutscene:new(
			"cutscene_intro", 						-- unique string name for cutscene
			ga_player_main_01.sunits,				-- unitcontroller over player's army
			4000, 									-- duration of cutscene in ms
			function() sm:change_to( states.PLACEMENT_SELECT_SINGLE_UNIT ); end		-- what to call when cutscene is finished
		);

		-- Move the camera to a better position for the initial camera pan.
		camera_move:action(
			function() 
				bm:camera():move_to(v_camera_move_to_pos, v_camera_move_to_target, 4, false, 0);
			end, 
			1);
		camera_move:start();
		
	end, --on_enter_callback
	nil --on_exit_callback
);


sm:add_state( states.PLACEMENT_SELECT_SINGLE_UNIT, -- name
	function()
		display_central_text("3k_main_battle_tutorial_deployment_select_unit", "mouse_left_click");
		bm:add_named_ping_icon("ping_01", v_deployment_selection_unit_start_pos:get_x(), v_deployment_selection_unit_start_pos:get_y() + ping_height_offset, v_deployment_selection_unit_start_pos:get_z(), 8, false, 0, 0);
		su_deployment_selection_unit.uc:highlight(true);

		-- State Change
		su_deployment_selection_unit:monitor_sunit_selection( function() sm:change_to( states.PLACEMENT_PLACE_SINGLE_UNIT ) end, nil );
	end, --on_enter_callback
	function()
		hide_central_text();
		bm:remove_named_ping_icon("ping_01");
		su_deployment_selection_unit.uc:highlight(false);
		su_deployment_selection_unit:unregister_unit_selection_callback();
	end --on_exit_callback
);


sm:add_state( states.PLACEMENT_PLACE_SINGLE_UNIT, -- name
	function()
		display_central_text("3k_main_battle_tutorial_deployment_place_unit", "mouse_right_click");
		bm:add_named_terrain_offset_ping_icon("ping_01", v_deployment_placement_position:get_x(), ping_height_offset, v_deployment_placement_position:get_z(), 7, false, 0, distance_for_placement);
		-- State Change
		sm:state_change_watch( states.PLACEMENT_DRAGOUT_SINGLE_UNIT, 
			function() return su_deployment_selection_unit.unit:position():distance_xz( v_deployment_placement_position ) <= distance_for_placement end,
			100
		);
		su_deployment_selection_unit:monitor_sunit_selection( nil, function() sm:change_to( states.PLACEMENT_SELECT_SINGLE_UNIT ) end );
	end, --on_enter_callback
	function() 
		hide_central_text();
		bm:remove_named_ping_icon("ping_01");
		su_deployment_selection_unit:unregister_unit_selection_callback();
	end --on_exit_callback
);


sm:add_state( states.PLACEMENT_DRAGOUT_SINGLE_UNIT, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_deployment_dragout_unit", "mouse_right_click_drag");

		-- State Change
		bm:register_command_handler_callback(
			"Move Orientation Width",
			function(context)
				bm:out("* A unit at " .. v_to_s(context:get_unit()) .. " has been issued an attack order!!@!");
				sm:change_to( states.PLACEMENT_SELECT_MULTIPLE );
			end,
			sm:get_listener_name()
		);
	end, --on_enter_callback
	function() 
		hide_central_text();
		bm:unregister_command_handler_callback("Move Orientation Width", sm:get_listener_name());
	end --on_exit_callback
);


--[[
****************************************************************************
-- UNIT PLACEMENT 02
****************************************************************************
]]--


sm:add_state( states.PLACEMENT_SELECT_MULTIPLE, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_deployment_drag_select", "mouse_left_click_drag");
		
		-- State Change
		sm:state_change_watch( states.PLACEMENT_DRAGOUT_MULTIPLE, 
			function() return bm:num_units_selected() > 1 end );
	end, --on_enter_callback
	function() 
		hide_central_text();
	end --on_exit_callback
);


sm:add_state( states.PLACEMENT_DRAGOUT_MULTIPLE, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_deployment_drag_select_multiple", "mouse_right_click_drag");
		
		-- State Change
		bm:register_command_handler_callback(
			"Move Orientation Width",
			function(context)
				bm:out("* A unit at " .. v_to_s(context:get_unit()) .. " has been issued an attack order!!@!");
				sm:change_to( states.PLACEMENT_DESELECT_SINGLE_UNIT );
			end,
			sm:get_listener_name()
		);
	end, --on_enter_callback
	function() 
		bm:unregister_command_handler_callback("Move Orientation Width", sm:get_listener_name());
		hide_central_text();
	end --on_exit_callback
);



sm:add_state( states.PLACEMENT_DESELECT_SINGLE_UNIT, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_deployment_deselect_unit", "mouse_left_click");
		bm:add_named_terrain_offset_ping_icon("ping_01", v_deployment_deselection_location:get_x(), ping_height_offset, v_deployment_deselection_location:get_z(), 1, false, 0, ping_default_radius);

		-- State Change
		ga_player_main_01.sunits:monitor_sunit_selection( nil, function() sm:change_to( states.BATTLE_START_BATTLE ) end );
	end, --on_enter_callback
	function() 
		hide_central_text();
		bm:remove_named_ping_icon("ping_01");
		ga_player_main_01.sunits:unregister_unit_selection_callback();
	end --on_exit_callback
);

--[[
****************************************************************************
-- BEGIN BATTLE
****************************************************************************
]]--


sm:add_state( states.BATTLE_START_BATTLE, -- name
	function() 
		enable_start_battle_button();
		display_central_text("3k_main_battle_tutorial_battle_start_battle");
		highlight_start_battle();

		--State change
		gb:add_listener(
			"battle_started",
			function() sm:change_to( states.BATTLE_SELECT_ALL_UNITS ); end,
			false
		);
	end, --on_enter_callback
	function() 
		hide_central_text();
		remove_highlight_start_battle();
		gb:remove_listener( "battle_started" );
	end --on_exit_callback
);


sm:add_state( states.BATTLE_SELECT_ALL_UNITS, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_battle_select_all_units", "keys_ctrl_a");

		-- State Change
		sm:state_change_watch( states.BATTLE_MOVE_TOWARDS_ENEMY, 
			function() return bm:are_all_units_selected() end );
	end, --on_enter_callback
	function()
		hide_central_text();
	end --on_exit_callback
);


sm:add_state( states.BATTLE_MOVE_TOWARDS_ENEMY, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_battle_move_all_units", "mouse_right_click");

		local go_to_pos = position_along_line( su_enemy_commander.unit:position(), su_player_commander.unit:position(), distance_to_pause_game * 0.9 );
		local stored_commander_distance = su_enemy_commander.unit:position():distance_xz( su_player_commander.unit:position() );

		bm:add_named_terrain_offset_ping_icon("ping_01", go_to_pos:get_x(), ping_height_offset, go_to_pos:get_z(), 7, false, 0, distance_to_pause_game * 0.05);
			
		-- State Change
		sm:state_change_watch( states.BATTLE_PAUSE, 
			function() 
				local new_commander_distance = su_enemy_commander.unit:position():distance_xz( su_player_commander.unit:position() );
				-- Move the ping if the eenemy commander has moves more than a certain distance from their initial position.
				-- We won't move the ping if they're getting closer.
				if new_commander_distance - stored_commander_distance > 10 then
					bm:remove_named_ping_icon("ping_01");
					
					go_to_pos = position_along_line( su_enemy_commander.unit:position(), su_player_commander.unit:position(), distance_to_pause_game * 0.9 );
					stored_commander_distance = su_enemy_commander.unit:position():distance_xz( su_player_commander.unit:position() );

					bm:add_named_terrain_offset_ping_icon("ping_01", go_to_pos:get_x(), ping_height_offset, go_to_pos:get_z(), 7, false, 0, distance_to_pause_game * 0.05);
				end;

				return bm:get_distance_between_forces() < distance_to_pause_game end 
			);
	end, --on_enter_callback
	function() 
		bm:remove_named_ping_icon("ping_01");
		hide_central_text();
	end --on_exit_callback
);


--[[
****************************************************************************
-- PAUSE EXPLAIN
****************************************************************************
]]--


sm:add_state( states.BATTLE_PAUSE, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_battle_pause");
		bm:modify_battle_speed(0);

		-- State change
		callback_after_five_seconds( function() sm:change_to( states.BATTLE_PAUSED_CHECK_UNIT_SELECTED ) end );
	end, --on_enter_callback
	function()
		hide_central_text();
		remove_five_second_callback();
	end --on_exit_callback
);


sm:add_state( states.BATTLE_PAUSED_CHECK_UNIT_SELECTED,
	function()
		display_central_text("3k_main_battle_tutorial_battle_select_any_unit", "mouse_left_click");

		-- State Change
		if bm:is_any_unit_selected() then
			sm:change_to( states.BATTLE_SHOW_INFO_OVERLAY )
		else
			ga_player_main_01.sunits:monitor_sunit_selection( function() sm:change_to( states.BATTLE_SHOW_INFO_OVERLAY ) end, nil );
		end;
	end,
	function()
		hide_central_text();
		ga_player_main_01.sunits:unregister_unit_selection_callback();
	end
);


sm:add_state( states.BATTLE_SHOW_INFO_OVERLAY, -- name
	function() 
		highlight_info_overlay();
		display_central_text("3k_main_battle_tutorial_battle_info_overlay", "key_f1");

		-- State Change
		ga_player_main_01.sunits:monitor_sunit_selection( nil, function() sm:change_to( states.BATTLE_PAUSED_CHECK_UNIT_SELECTED ) end );

		sm:state_change_listener( states.BATTLE_EXPLAIN_INFO_OVERLAY, "ShortcutPressed", function(context) return context.string == "help_mode" end );
		sm:state_change_listener( states.BATTLE_EXPLAIN_INFO_OVERLAY, "ComponentLClickUp", function(context) return context.string == "button_help" end );
	end, --on_enter_callback
	function()
		remove_highlight_info_overlay();
		ga_player_main_01.sunits:unregister_unit_selection_callback();
		hide_central_text();
	end --on_exit_callback
);


sm:add_state( states.BATTLE_EXPLAIN_INFO_OVERLAY,
	function() 
		display_central_text("3k_main_battle_tutorial_battle_info_overlay_explain");

		-- State change
		callback_after_five_seconds( function() sm:change_to( states.BATTLE_CLOSE_INFO_OVERLAY ) end );
		sm:state_change_listener( states.BATTLE_DESELECT_UNIT, "ShortcutPressed", function(context) return true end );
		sm:state_change_listener( states.BATTLE_DESELECT_UNIT, "ComponentLClickUp", function(context) return context.string == "button_help" end );
	end,
	function() 
		hide_central_text();
		remove_five_second_callback();
	end
)


sm:add_state( states.BATTLE_CLOSE_INFO_OVERLAY, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_battle_info_overlay_close", "key_f1");

		-- State Change
		sm:state_change_listener( states.BATTLE_DESELECT_UNIT, "ShortcutPressed", function(context) return true end );
		sm:state_change_listener( states.BATTLE_DESELECT_UNIT, "ComponentLClickUp", function(context) return context.string == "button_help" end );
	end, --on_enter_callback
	function() 
		hide_central_text();
	end --on_exit_callback
);


sm:add_state( states.BATTLE_DESELECT_UNIT, -- name
	function(context)
		if not bm:is_any_unit_selected() or bm:num_units_selected() < 2 then
			sm:change_to( states.BATTLE_SELECT_UNIT );
		else
			display_central_text("3k_main_battle_tutorial_deployment_deselect_unit", "mouse_left_click");

			-- State Change
			ga_player_main_01.sunits:monitor_sunit_selection( nil, function() sm:change_to( states.BATTLE_SELECT_UNIT ) end );
		end;
		
	end, --on_enter_callback
	function(context)
		ga_player_main_01.sunits:unregister_unit_selection_callback();
	end --on_exit_callback
);

sm:add_state( states.BATTLE_SELECT_UNIT, -- name
	function()
		display_central_text("3k_main_battle_tutorial_battle_select_any_unit", "mouse_left_click");

		-- State Change
		if bm:is_any_unit_selected() then
			sm:change_to( states.BATTLE_SHOW_THREAT );
		else
			ga_player_main_01.sunits:monitor_sunit_selection( function() sm:change_to( states.BATTLE_SHOW_THREAT ) end, nil );
		end;
	end, --on_enter_callback
	function()
		hide_central_text();
		ga_player_main_01.sunits:unregister_unit_selection_callback();
	end --on_exit_callback
);


sm:add_state( states.BATTLE_SHOW_THREAT, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_battle_show_threat", "icon_threat");

		-- State Change
		ga_player_main_01.sunits:monitor_sunit_selection( nil, function() sm:change_to( states.BATTLE_SELECT_UNIT_2 ) end );
		callback_after_ten_seconds( function() sm:change_to( states.BATTLE_ISSUE_ATTACK_ORDER ) end );
	end, --on_enter_callback
	function()
		hide_central_text();
		ga_player_main_01.sunits:unregister_unit_selection_callback();
		remove_ten_second_callback();
	end --on_exit_callback
);


sm:add_state( states.BATTLE_SELECT_UNIT_2, -- name
	function()
		display_central_text("3k_main_battle_tutorial_battle_select_any_unit", "mouse_left_click");

		-- State Change
		if bm:is_any_unit_selected() then
			sm:change_to( states.BATTLE_ISSUE_ATTACK_ORDER );
		else
			ga_player_main_01.sunits:monitor_sunit_selection( function() sm:change_to( states.BATTLE_ISSUE_ATTACK_ORDER ) end, nil );
		end;
	end, --on_enter_callback
	function()
		hide_central_text();
		ga_player_main_01.sunits:unregister_unit_selection_callback();
	end --on_exit_callback
);


sm:add_state( states.BATTLE_ISSUE_ATTACK_ORDER, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_battle_attack_unit", "mouse_right_click");

		local commander_pos = su_enemy_commander.unit:position();
		bm:add_named_ping_icon("ping_01", commander_pos:get_x(), commander_pos:get_y() + ping_height_offset, commander_pos:get_z(), 3, false, 0, 40);
		
		-- State Change
		bm:register_command_handler_callback(
			"Attack Unit",
			function(context)
				bm:out("* A unit at " .. v_to_s(context:get_unit()) .. " has been issued an attack order");
				sm:change_to( states.BATTLE_UNPAUSE );
			end,
			sm:get_listener_name()
		);
	end, --on_enter_callback
	function()
		hide_central_text();
		bm:remove_named_ping_icon("ping_01");
		bm:unregister_command_handler_callback("Attack Unit", sm:get_listener_name());
	end --on_exit_callback
);


sm:add_state( states.BATTLE_UNPAUSE, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_battle_unpause", "key_p");
		-- TODO: flash pause button

		-- State Change
		sm:state_change_listener( states.BATTLE_SHOW_VICTORY_OBJECTIVE, "ShortcutPressed", function(context) return context.string == "toggle_pause" end );
		sm:state_change_listener( states.BATTLE_SHOW_VICTORY_OBJECTIVE, "ComponentLClickUp", function(context) return context.string == "button_toggle_pause" end );
	end, --on_enter_callback
	function()
		hide_central_text();
	end --on_exit_callback
);


--[[
****************************************************************************
-- BATTLE END
****************************************************************************	
]]--
sm:add_state( states.BATTLE_SHOW_VICTORY_OBJECTIVE, -- name
	function(context)
		display_central_text("3k_main_battle_objective_normal_kill_or_rout_enemy");

		-- State Change
		sm:state_change_callback( states.BATTLE_WAIT_FOR_VICTORY, 5000 );

	end, --on_enter_callback
	function(context)
		hide_central_text();
	end --on_exit_callback
);

sm:add_state( states.BATTLE_WAIT_FOR_VICTORY, -- name
	function()
		bm:set_objective("3k_main_battle_objective_normal_kill_or_rout_enemy");
		-- State Change
		gb:add_listener(
			"battle_ending",
			function() sm:change_to( states.BATTLE_IS_ENDING ); end,
			false
		);
	end, --on_enter_callback
	function()
		bm:complete_objective("3k_main_battle_objective_normal_kill_or_rout_enemy");
		bm:remove_objective("3k_main_battle_objective_normal_kill_or_rout_enemy");
	end --on_exit_callback
);


sm:add_state( states.BATTLE_IS_ENDING, -- name
	function() 
		display_central_text("3k_main_battle_tutorial_highlight_cheat_sheet", "key_esc");

		-- Mark the tutorial as seen here.
		set_tutorial_battle_seen(); -- Enable this to stop it firing each time!

		-- State Change
		sm:state_change_callback( states.END, 5000 );
	end, --on_enter_callback
	function()
		hide_central_text();
	end --on_exit_callback
);

--[[
****************************************************************************
-- END
****************************************************************************
]]--


sm:add_state( states.END, -- name
	function() 
		hide_skip_button();
		hide_central_text();
		hide_choice_window();
		remove_highlight_info_overlay();
		remove_highlight_start_battle();
		enable_start_battle_button();
		remove_five_second_callback();
		ga_player_main_01:change_behaviour_active_on_message("battle_started", "auto_reject_duels", false); -- Auto-reject duels
		set_tutorial_battle_seen(); -- Enable this to stop it firing each time!
	end, --on_enter_callback
	nil --on_exit_callback
);