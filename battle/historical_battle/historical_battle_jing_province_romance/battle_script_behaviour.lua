
-------------------------------------------------------------------------------------------------
------------------------------------------- KEY INFO --------------------------------------------
-------------------------------------------------------------------------------------------------

-- Ambush
-- Defender

-------------------------------------------------------------------------------------------------
------------------------------------------- PRELOADS --------------------------------------------
-------------------------------------------------------------------------------------------------

cam = bm:camera();

gb = generated_battle:new(
	true,											-- screen starts black
	true,											-- prevent deployment for player
	false,											-- prevent deployment for ai
	function() play_intro_cutscene() end,			-- intro cutscene function
	true											-- debug mode
);

gb:set_end_deployment_phase_after_loading_screen(true);

-------------------------------------------------------------------------------------------------
--------------------------------------- ENVIRONMENT SETUP ---------------------------------------
-------------------------------------------------------------------------------------------------
ga_player_main_01 = gb:get_army(gb:get_player_alliance_num(), "player_01");

ga_ai_main_01 = gb:get_army(gb:get_non_player_alliance_num(), 1, "enemy_01");
ga_ai_reinforcements_zhang_liao = gb:get_army(gb:get_non_player_alliance_num(), 1, "enemy_02");
ga_ai_reinforcements_xu_huang = gb:get_army(gb:get_non_player_alliance_num(), 1, "enemy_03");


-------------------------------------------------------------------------------------------------
--------------------------------------- LOCAL ---------------------------------------------------
-------------------------------------------------------------------------------------------------

local intro_cinematic_file =  "script\\battle\\historical_battle\\_cutscene\\managers\\jing_province.CindySceneManager";
local intro_cindy_length = 40000;


-------------------------------------------------------------------------------------------------
---------------------------------------- INTRO CUTSCENE -----------------------------------------
-------------------------------------------------------------------------------------------------

function play_intro_cutscene()
	
	-- declare cutscene
	local intro_cutscene = cutscene:new(
		"jing_province_cutscene_intro", 		-- unique string name for cutscene
		ga_player_main_01.sunits,				-- unitcontroller over player's army
		intro_cindy_length,						-- duration of cutscene in ms
        function()
			end_intro_cutscene();
		end										-- what to call when cutscene is finished
    );
    
	intro_cutscene:set_skippable(true, function() skip_intro_cutscene() end);
	intro_cutscene:set_is_ambush(false, true);
	
	--local end_camera_pos = v(497.1, 693.5, -38.3);
    --local ambush_pos = v(460, 624, 145);

    --intro_cutscene:set_skip_camera(end_camera_pos, ambush_pos);
	
	-- Play the cindy scene
	intro_cutscene:cindy_action(intro_cinematic_file, 0, 0, 2);

	
	-- cinematic trigger listeners
	intro_cutscene:add_cinematic_trigger_listener(
		"change_me", 
		function()
			-- intro_cutscene:play_sound(sfx_intro_01);						-- CHANGE ME
			-- bm:show_subtitle("");
		end
	);
	
	intro_cutscene:add_cinematic_trigger_listener(
		"hide_subtitles", 
		function()
			bm:hide_subtitles()
		end
	);
	
	intro_cutscene:add_cinematic_trigger_listener(
		"end_cinematic", 
		function()
			intro_cutscene:finish()
		end
	);
	
	intro_cutscene:action(
		function()
			start_enemy_behaviour()
		end,
		intro_cindy_length - 10000
	);
	
	intro_cutscene:start();
end;


function skip_intro_cutscene()
	cam:fade(true, 0);
	
	start_enemy_behaviour();
	
	bm:callback(
		function() 
			bm:stop_cindy_playback(true)
			cam:fade(false, 0.3) 
		end, 
		200
	);
end;


function start_enemy_behaviour()
	gb.sm:trigger_message("start_enemy_behaviour");
end;


function end_intro_cutscene()
	gb.sm:trigger_message("intro_cutscene_end");
end;

-------------------------------------------------------------------------------------------------
------------------------------------------- BEHAVIOUR -------------------------------------------
-------------------------------------------------------------------------------------------------

-- prevent the AI from moving before the playable battle starts
ga_ai_main_01:take_control_on_message("battle_started");
ga_ai_main_01:change_behaviour_active_on_message("battle_started", "fire_at_will", false);

-- allow fire-at-will when the battle starts
ga_ai_main_01:change_behaviour_active_on_message("intro_cutscene_end", "fire_at_will", start);

--local escape_position = v(131.8, 624.8, -753.1);	-- escape position
local trigger_range_to_escape_position = 50;   		-- range in m from unit to escape position at which escape is triggered
local ai_initial_army_position = v(450, 625, 150);  -- Ping location of ambushing force
local other_side_of_river = v(110, 620, -201)		-- Other side of river
local reinforce_north = v(-150, 625, 725);			-- Position of reinforcement
local reinforce_south = v(125, 625, -750);			-- Position of reinforcement

local player_sunits = ga_player_main_01.sunits;


-- TODO: We will see if this forced attack works or not
ga_ai_main_01:attack_on_message("start_enemy_behaviour");

-- reinforce_south failsafes to deploy after x time
gb:message_on_time_offset("reinforce_south", 240000, "intro_cutscene_end");
-- reinforce_south deploys if main force routed
ga_ai_main_01:message_on_rout_proportion("reinforce_south", 1);
-- reinforce_south deploys if main force suffered certain % of casulties
-- ga_ai_main_01:message_on_casualties("reinforce_south", 0.25);
-- reinforce_south deploys if player gets close to exit
--ga_player_main_01:message_on_proximity_to_position("reinforce_south", escape_position, 700);

-- reinforce_south arrives and as soon as deployed attacks
ga_ai_reinforcements_zhang_liao:reinforce_on_message("reinforce_south", 25000);
ga_ai_reinforcements_zhang_liao:message_on_deployed("deployed_reinforce_south");
--ga_ai_reinforcements_zhang_liao:attack_on_message("deployed_reinforce_south", 1000);

-- reinforce_north failsafes to deploy after x time
gb:message_on_time_offset("reinforce_north", 240000, "intro_cutscene_end");
-- reinforce_north deploys if main force routed
ga_ai_main_01:message_on_rout_proportion("reinforce_north", 1);
-- reinforce_north deploys if reinforce_north suffered certain % of casulties
-- ga_ai_main_01:message_on_casualties("reinforce_north", 0.25);
-- reinforce_north deploys if player gets close to exit
--ga_player_main_01:message_on_proximity_to_position("reinforce_north", escape_position, 500);

-- reinforce_north arrives and as soon as deployed attacks ---
ga_ai_reinforcements_xu_huang:reinforce_on_message("reinforce_north", 25000);
ga_ai_reinforcements_xu_huang:message_on_deployed("deployed_reinforce_north");
ga_ai_reinforcements_xu_huang:attack_on_message("deployed_reinforce_north", 1000);

-------------------------------------------------------------------------------------------------
------------------------------------------- OBJECTIVES ------------------------------------------
-------------------------------------------------------------------------------------------------

-- Initial ambush
-- Survive the ambush
gb:set_objective_on_message("intro_cutscene_end", "3k_main_battle_historical_scripted_objective_gamescom_1", 3000);
gb:set_locatable_objective_on_message("intro_cutscene_end", "3k_main_battle_historical_scripted_objective_gamescom_2", 3000, v(520, 648, 50), v(391, 582, 187), 3); 
-- marker for ambusher
gb:add_ping_icon_on_message("intro_cutscene_end", ai_initial_army_position, 3, 3000, 30000);

-- Manage objective 1
gb:message_on_time_offset("remove_initial_objective", 30000, "intro_cutscene_end")
gb:remove_objective_on_message("remove_initial_objective", "3k_main_battle_historical_scripted_objective_gamescom_1");

-- Cross the river
gb:remove_objective_on_message("reinforce_south", "3k_main_battle_historical_scripted_objective_gamescom_2");
gb:add_ping_icon_on_message("reinforce_south", other_side_of_river, 2, 3000, 30000);
gb:set_locatable_objective_on_message("reinforce_south", "3k_main_battle_historical_scripted_objective_gamescom_3", 1000, v(184, 650, -84), v(83, 603, -348), 4); 
--gb:play_sound_on_message("deployed_reinforce_south", sfx_vo_line_reinforcement_south_01)

-- Initial ambush disposed fight or escape
gb:remove_objective_on_message("deployed_reinforce_south", "3k_main_battle_historical_scripted_objective_gamescom_3");
--gb:add_ping_icon_on_message("deployed_reinforce_south", escape_position, 2, 3000, 3000000);
--gb:set_locatable_objective_on_message("deployed_reinforce_south", "3k_main_battle_historical_scripted_objective_gamescom_4", 1000, v(117, 636, -607), v(119, 631, -806), 2); 
--gb:set_locatable_objective_on_message("deployed_reinforce_south", "3k_main_battle_historical_scripted_objective_gamescom_4", 1000, v(177, 655, -740), v(82, 615, -569), 2); 
gb:set_objective_on_message("deployed_reinforce_south", "3k_main_battle_historical_scripted_objective_gamescom_4", 1000); 
--gb:set_locatable_objective_on_message("deployed_reinforce_south", "3k_main_battle_historical_scripted_objective_gamescom_5", 1000, v(144, 655, -680), v(121, 614, -873), 2);