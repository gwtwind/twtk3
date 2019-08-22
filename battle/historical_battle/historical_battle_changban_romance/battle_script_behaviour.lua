-------------------------------------------------------------------------------------------------
------------------------------------------- KEY INFO --------------------------------------------
-------------------------------------------------------------------------------------------------

-- Stand at Changban
-- Defender

-------------------------------------------------------------------------------------------------
----------------------------------------- DECLARATIONS ------------------------------------------
-------------------------------------------------------------------------------------------------

cam = bm:camera();

gb = generated_battle:new(
	true, 															-- screen starts black
	true, 															-- prevent deployment for player
	false, 															-- prevent deployment for ai
	function() play_intro_cutscene() end, 							-- intro cutscene function
	true															-- debug mode
);

gb:set_end_deployment_phase_after_loading_screen(true);


-------------------------------------------------------------------------------------------------
-------------------------------------------- ARMY SETUP -----------------------------------------
-------------------------------------------------------------------------------------------------

ga_player_main_01 = gb:get_army(gb:get_player_alliance_num(), "player_01");
ga_player_reinforcements_01 = gb:get_army(gb:get_player_alliance_num(), "player_02");
ga_player_reinforcements_02 = gb:get_army(gb:get_player_alliance_num(), "player_03");

ga_ai_main_01 = gb:get_army(gb:get_non_player_alliance_num(), "start_army_01");
ga_ai_reinforcements_01 = gb:get_army(gb:get_non_player_alliance_num(), "enemy_02");
ga_ai_reinforcements_02 = gb:get_army(gb:get_non_player_alliance_num(), "enemy_03");


-------------------------------------------------------------------------------------------------
--------------------------------------- LOCAL ---------------------------------------------------
-------------------------------------------------------------------------------------------------

local intro_cinematic_file =  "script\\battle\\historical_battle\\_cutscene\\managers\\changban01.CindySceneManager";
local intro_cindy_length = 90000;


-------------------------------------------------------------------------------------------------
---------------------------------------- INTRO CUTSCENE -----------------------------------------
-------------------------------------------------------------------------------------------------

function play_intro_cutscene()
	
	-- declare cutscene
	local intro_cutscene = cutscene:new(
		"changban_cutscene_intro", 				-- unique string name for cutscene
		ga_player_main_01.sunits,				-- unitcontroller over player's army
		intro_cindy_length,						-- duration of cutscene in ms
        function()
			end_intro_cutscene();
		end										-- what to call when cutscene is finished
    );
    
	intro_cutscene:set_skippable(true, function() skip_intro_cutscene() end);
	
	--local end_camera_pos = v(-145, 605.5, 10.7);
    --local base_pos = v(-148.4, 603.3, 25.8);

    --intro_cutscene:set_skip_camera(end_camera_pos, base_pos);
	
	-- set camera end position when cutscene finishes
	--intro_cutscene:set_restore_cam(0, end_camera_pos, base_pos);
	
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
	
	intro_cutscene:start();
end;


function start_enemy_behaviour()
	gb.sm:trigger_message("start_enemy_behaviour");
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



function end_intro_cutscene()
	start_enemy_behaviour();
	gb.sm:trigger_message("intro_cutscene_end");
end;



-------------------------------------------------------------------------------------------------
-------------------------------------------- EVENTS ---------------------------------------------
-------------------------------------------------------------------------------------------------
ga_ai_main_01:halt();

ga_ai_main_01:release_on_message("start_enemy_behaviour",0);


-- PLAYER REINFORCEMENTS 01
-- send message for player reinforcements 01 after 3.5 minutes
gb:message_on_time_offset("send_player_reinforcements_01", 210000, "intro_cutscene_end");

-- receive message for player reinforcements 01 and delay for x time
ga_player_reinforcements_01:reinforce_on_message("send_player_reinforcements_01", 0);



-- PLAYER REINFORCEMENTS 02
-- send message for player reinforcements 02 after 7 minutes
gb:message_on_time_offset("send_player_reinforcements_02", 420000, "intro_cutscene_end");

-- receive message for player reinforcements 02 and delay for x time
ga_player_reinforcements_02:reinforce_on_message("send_player_reinforcements_02", 0);



-- ENEMY REINFORCEMENTS

-- first wave attacks and sends message for reinforcements after x casualties sustained
ga_ai_main_01:message_on_casualties("first_wave", 0.1);


-- receive message for reinforcements and delay for x time
ga_ai_reinforcements_01:reinforce_on_message("first_wave", 0);


-- reinforcements_01 sends message for reinforcements_02 after x casualties sustained
ga_ai_main_01:message_on_rout_proportion("second_wave", 0.7);


-- receive message for reinforcements and delay for x time
ga_ai_reinforcements_02:reinforce_on_message("second_wave", 0);



-------------------------------------------------------------------------------------------------
-------------------------------------------- OBJECTIVES -----------------------------------------
-------------------------------------------------------------------------------------------------

gb:set_objective_on_message("intro_cutscene_end", "3k_main_battle_historical_scripted_objective_changban_1", 1000);

--update objectives--
gb:remove_objective_on_message("send_player_reinforcements_01", "3k_main_battle_historical_scripted_objective_changban_1", 1000);
gb:set_objective_on_message("send_player_reinforcements_01", "3k_main_battle_historical_scripted_objective_changban_2", 1000);

--update objectives--
gb:remove_objective_on_message("send_player_reinforcements_02", "3k_main_battle_historical_scripted_objective_changban_2", 1000);
gb:set_objective_on_message("send_player_reinforcements_02", "3k_main_battle_historical_scripted_objective_changban_3", 1000);

-- End of Battle Safeguards
--safeguard in case player is wiped, but there are still reinforcements waiting to come onto the battlefield, rout these so game ends properly--
ga_player_main_01:message_on_alliance_not_active_on_battlefield("player_loses");
ga_ai_main_01:force_victory_on_message("player_loses");