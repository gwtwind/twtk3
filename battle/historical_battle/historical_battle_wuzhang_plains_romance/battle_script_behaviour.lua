
-------------------------------------------------------------------------------------------------
------------------------------------------- KEY INFO --------------------------------------------
-------------------------------------------------------------------------------------------------

-- Raid at Wuzhang Plains. Sima Yi vs Zhuge Liang. 234.
-- Han City C Small
-- Attacker

-------------------------------------------------------------------------------------------------
------------------------------------------- PRELOADS --------------------------------------------
-------------------------------------------------------------------------------------------------

cam = bm:camera();

gb = generated_battle:new(
	true,                                      		-- screen starts black
	true,                                      		-- prevent deployment for player
    false,                                      	-- prevent deployment for ai
	function() play_intro_cutscene() end,        	-- intro cutscene function
	true                                      		-- debug mode
);

gb:set_end_deployment_phase_after_loading_screen(true);

-------------------------------------------------------------------------------------------------
------------------------------------------- ARMY SETUP --------------------------------------------
-------------------------------------------------------------------------------------------------
ga_player_main_01 = gb:get_army(gb:get_player_alliance_num(), 1, "player_01");
ga_player_reinforcements_01 = gb:get_army(gb:get_player_alliance_num(), 1, "player_02");

ga_ai_main_01 = gb:get_army(gb:get_non_player_alliance_num(), 1, "enemy_01");
ga_ai_main_02 = gb:get_army(gb:get_non_player_alliance_num(), 2, "enemy_02");
ga_ai_main_03 = gb:get_army(gb:get_non_player_alliance_num(), 3, "enemy_03");

-------------------------------------------------------------------------------------------------
--------------------------------------- LOCAL ---------------------------------------------------
-------------------------------------------------------------------------------------------------

local ai_initial_army_position = v(127.4, 604.6, 709.3);  -- Ping location of army enroute
local ai_initial_cavalry_position = v(17, 607.2, 123);  -- Ping location of enemy cavalry

local intro_cinematic_file =  "script\\battle\\historical_battle\\_cutscene\\managers\\wuzhang_plains.CindySceneManager";
local intro_cindy_length = 40000;


-------------------------------------------------------------------------------------------------
---------------------------------------- INTRO CUTSCENE -----------------------------------------
-------------------------------------------------------------------------------------------------

function play_intro_cutscene()
	
	-- declare cutscene
	local intro_cutscene = cutscene:new(
		"wuzhang_cutscene_intro", 				-- unique string name for cutscene
		ga_player_main_01.sunits,				-- unitcontroller over player's army
		intro_cindy_length,						-- duration of cutscene in ms
        function()
			end_intro_cutscene();
		end										-- what to call when cutscene is finished
    );
    
	intro_cutscene:set_skippable(true, function() skip_intro_cutscene() end);
	
	local end_camera_pos = v(-276.9, 682.0, 742.0);
    local base_pos = v(-263.1, 675.0, 743.4);

    intro_cutscene:set_skip_camera(end_camera_pos, base_pos);
	
	-- set camera end position when cutscene finishes
	intro_cutscene:set_restore_cam(0, end_camera_pos, base_pos);
	
	-- Play the cindy scene
	intro_cutscene:cindy_action(intro_cinematic_file, 0, 0, 2);
	
	
	-- intro fade-in
	intro_cutscene:action(
		function() 
			cam:fade(false, 1); 
		end, 
		0
	);
	
	
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
-------------------------------------------- EVENTS ---------------------------------------------
-------------------------------------------------------------------------------------------------

-- Attack the enemy patrol to trick the enemy cavalry into leaving the settlement.
gb:set_objective_on_message("intro_cutscene_end", "3k_main_battle_historical_scripted_objective_wuzhang_plains_1", 1000);
gb:add_ping_icon_on_message("intro_cutscene_end", ai_initial_army_position, 3, 3000, 30000);

ga_ai_main_02:halt();
ga_ai_main_02:move_to_position_on_message("start_enemy_behaviour", v(-32.8,607.2,123.6)); 
ga_ai_main_01:halt();
ga_ai_main_03:halt();
ga_ai_main_02:message_on_casualties("deploycav", 0.01);
ga_ai_main_01:message_on_casualties("override", 0.01);

ga_ai_main_02:message_on_proximity_to_enemy("close0", 150);
ga_ai_main_02:release_on_message("close0", 2000);

ga_ai_main_03:advance_on_message("deploycav");
ga_ai_main_03:message_on_proximity_to_enemy("close1", 100);
ga_ai_main_03:attack_on_message("close1");

gb:remove_objective_on_message("deploycav", "3k_main_battle_historical_scripted_objective_wuzhang_plains_1", 1000);

--Lure the enemy cavalry away from the settlement until your reinforcements arrive.
gb:set_objective_on_message("deploycav", "3k_main_battle_historical_scripted_objective_wuzhang_plains_2", 3000);
gb:add_ping_icon_on_message("deploycav", ai_initial_cavalry_position, 3, 3000, 30000);

ga_ai_main_03:message_on_casualties("deploygarrison", 0.15);
ga_ai_main_03:release_on_message("deploygarrison", 2000);
ga_ai_main_02:release_on_message("deploygarrison", 2000);
ga_ai_main_01:release_on_message("deploygarrison", 2000);

ga_ai_main_01:release_on_message("override", 1000);
ga_ai_main_02:release_on_message("override", 1000);
ga_ai_main_03:release_on_message("override", 1000);

ga_player_reinforcements_01:reinforce_on_message("deploycav", 250000);

gb:remove_objective_on_message("deploycav", "3k_main_battle_historical_scripted_objective_wuzhang_plains_2", 250000);

--Defeat the enemy cavalry and conquer the settlement.
gb:set_objective_on_message("deploycav", "3k_main_battle_historical_scripted_objective_wuzhang_plains_3", 270000);

--safeguard in case player is wiped, but there are still reinforcements waiting to come onto the battlefield, rout these so game ends properly--
ga_player_main_01:message_on_alliance_not_active_on_battlefield("rout_reinforcements_01");
ga_player_reinforcements_01:rout_over_time_on_message("rout_reinforcements_01", 5000);
gb:block_message_on_message("deploycav", "rout_reinforcements_01");