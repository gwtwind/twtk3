-------------------------------------------------------------------------------------------------
------------------------------------------- KEY INFO --------------------------------------------
-------------------------------------------------------------------------------------------------

-- Battle of Red Cliff
-- Attacker

-------------------------------------------------------------------------------------------------
----------------------------------------- DECLARATIONS ------------------------------------------
-------------------------------------------------------------------------------------------------
load_script_libraries();
bm = battle_manager:new(empire_battle:new());
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
--------------------------------------- ARMY SETUP ----------------------------------------------
-------------------------------------------------------------------------------------------------

ga_player_main_01 = gb:get_army(gb:get_player_alliance_num(), "player_01");

ga_ai_cao_cao = gb:get_army(gb:get_non_player_alliance_num(), "enemy_cao_cao");
ga_ai_settlement = gb:get_army(gb:get_non_player_alliance_num(), "enemy_01");
ga_ai_ext_centre = gb:get_army(gb:get_non_player_alliance_num(), "enemy_02_centre");
ga_ai_ext_east = gb:get_army(gb:get_non_player_alliance_num(), "enemy_02_east");
ga_ai_ext_east_missile = gb:get_army(gb:get_non_player_alliance_num(), "enemy_02_east_missile");
ga_ai_ext_west = gb:get_army(gb:get_non_player_alliance_num(), "enemy_02_west");
ga_ai_ext_west_missile = gb:get_army(gb:get_non_player_alliance_num(), "enemy_02_west_missile");


-------------------------------------------------------------------------------------------------
--------------------------------------- LOCAL ---------------------------------------------------
-------------------------------------------------------------------------------------------------

local intro_cinematic_file =            "script\\battle\\historical_battle\\historical_battle_red_cliff\\redcliff_cutscene\\managers\\red_cliff.CindySceneManager";
local intro_cinematic_length = 90000;


-------------------------------------------------------------------------------------------------
---------------------------------------- COMPOSITES ---------------------------------------------
-------------------------------------------------------------------------------------------------

local intro_cutscene_composite_scenes = {
	"composite_scene/red_cliff/red_cliff_small_junk_no_sails_destroyed_01.csc",
	"composite_scene/red_cliff/red_cliff_small_junk_destroyed_side_01.csc",
	"composite_scene/red_cliff/red_cliff_small_junk_destroyed_front_02.csc",
	"composite_scene/red_cliff/red_cliff_small_junk_destroyed_front_01.csc",
	"composite_scene/red_cliff/red_cliff_small_junk_destroyed_back_02.csc",
	"composite_scene/red_cliff/red_cliff_small_junk_destroyed_back_01.csc",
	"composite_scene/red_cliff/red_cliff_small_junk_destroyed_01.csc",
	"composite_scene/red_cliff/red_cliff_small_junk_01.csc",
	"composite_scene/red_cliff/red_cliff_rowing_boat_burnt.csc",
	"composite_scene/red_cliff/red_cliff_rowing_boat.csc",
	"composite_scene/red_cliff/red_cliff_medium_junk_no_sails_destroyed_01.csc",
	"composite_scene/red_cliff/red_cliff_medium_junk_fire_destroyed_01.csc",
	"composite_scene/red_cliff/red_cliff_medium_junk_fire_01.csc",
	"composite_scene/red_cliff/red_cliff_medium_junk_destroyed_side_01.csc",
	"composite_scene/red_cliff/red_cliff_medium_junk_destroyed_01.csc",
	"composite_scene/red_cliff/red_cliff_medium_junk_01.csc"
};

function display_intro_cutscene_composite_scenes(value)
	if value then
		bm:out("* display_intro_cutscene_composite_scenes() is displaying composite scenes");
		for i = 1, #intro_cutscene_composite_scenes do
			bm:start_terrain_composite_scene(intro_cutscene_composite_scenes[i])
		end;
	else
		bm:out("* display_intro_cutscene_composite_scenes() is hiding composite scenes");
		for i = 1, #intro_cutscene_composite_scenes do
			bm:stop_terrain_composite_scene(intro_cutscene_composite_scenes[i])
		end;
	end;
end;



-------------------------------------------------------------------------------------------------
---------------------------------------- INTRO CUTSCENE -----------------------------------------
-------------------------------------------------------------------------------------------------

function play_intro_cutscene()
	
	-- make player army invisible
	ga_player_main_01:set_enabled(false);
	
	-- set up sfx files
	--[[
	local sfx_intro_01 = new_sfx("Play_Battle_Historical_Cao_Cao_Xia_Pi_01");		-- CHANGE ME
	local sfx_intro_02 = new_sfx("Play_Battle_Historical_Cao_Cao_Xia_Pi_02");		-- CHANGE ME
	local sfx_intro_03 = new_sfx("Play_Battle_Historical_Cao_Cao_Xia_Pi_03");		-- CHANGE ME
	]]
	-- etc
	
	display_intro_cutscene_composite_scenes(false);
	
	-- declare cutscene
	local intro_cutscene = cutscene:new(
		"cutscene_intro", 						-- unique string name for cutscene
		ga_player_main_01.sunits,				-- unitcontroller over player's army
		intro_cinematic_length,					-- duration of cutscene in ms
        function()
			end_intro_cutscene();
		end										-- what to call when cutscene is finished
    );
    
	intro_cutscene:set_skippable(true, function() skip_intro_cutscene() end);

	-- set camera end position when skipped
	local end_camera_pos = v(44.55, 43.97, -49.60);
    local base_pos = v(-44.67, 3.65, 177.55);

    intro_cutscene:set_skip_camera(end_camera_pos, base_pos);
	
	-- set camera end position when cutscene finishes
	intro_cutscene:set_restore_cam(0, end_camera_pos, base_pos);
	
	-- cindy scene
	intro_cutscene:cindy_action(intro_cinematic_file, 0, 0, 0);
	
	
	-- cinematic trigger listeners
	intro_cutscene:add_cinematic_trigger_listener(
		"change_me", 
		function()
			-- intro_cutscene:play_sound(sfx_intro_01);						-- CHANGE ME
			-- bm:show_subtitle("3k_hb_e3_cao_cao_xia_pi_01");
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
	
	intro_cutscene:add_cinematic_trigger_listener(
		"start_fade_in", 
		function()
			cam:fade(true, 0);
			cam:fade(false, 1);
		end
	);
	
	intro_cutscene:add_cinematic_trigger_listener(
		"start_fade_out", 
		function()
			cam:fade(false, 0);
			cam:fade(true, 1);
		end
	);
	
	intro_cutscene:action(
		function()
			start_enemy_behaviour()
		end,
		0
	);
	
	cam:fade(true, 0);
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
	cam:fade(false, 1);
	
	display_intro_cutscene_composite_scenes(true);
	
	-- make player army visible again
	ga_player_main_01:set_enabled(true);
	
	-- release script control
	ga_player_main_01:release();
	
	gb.sm:trigger_message("intro_cutscene_end");
	
end;


-------------------------------------------------------------------------------------------------
------------------------------------------ BEHAVIOUR --------------------------------------------
-------------------------------------------------------------------------------------------------

-- make Cao Cao invisible on the battlefield
ga_ai_cao_cao:set_enabled(false);

-- release the main settlement defenders at the outset of the battle
ga_ai_settlement:release_on_message("start_enemy_behaviour");

-- instruct the forward defenders to defend positions
ga_ai_ext_centre:defend_on_message("start_enemy_behaviour", 60, 340, 100);

ga_ai_ext_east:defend_on_message("start_enemy_behaviour", 317, 340, 60);
ga_ai_ext_east_missile:defend_on_message("start_enemy_behaviour", 220, 335, 30);

ga_ai_ext_west:defend_on_message("start_enemy_behaviour", -180, 350, 60);
ga_ai_ext_west_missile:defend_on_message("start_enemy_behaviour", -260, 335, 30);

-- trigger a message whenever any of the main positions takes a certain number of casualties, which causes each of them to attack
ga_ai_ext_centre:message_on_casualties("ext_attack", 0.7);
ga_ai_ext_east:message_on_casualties("ext_attack", 0.8);
ga_ai_ext_west:message_on_casualties("ext_attack", 0.8);

ga_ai_ext_west:attack_on_message("ext_attack");
ga_ai_ext_east:attack_on_message("ext_attack");
ga_ai_ext_centre:attack_on_message("ext_attack");

-- also trigger a further message some time after the above message is sent, which releases the exterior units to the full ai
gb:message_on_time_offset("ext_release", 120000, "ext_attack");

ga_ai_ext_west:release_on_message("ext_release");
ga_ai_ext_east:release_on_message("ext_release");
ga_ai_ext_centre:release_on_message("ext_release");

-- release control of the exterior missile defenders if they take too many casualties, so they AI can do sensible things with them
ga_ai_ext_east_missile:message_on_casualties("ext_release_east_missile", 0.7);
ga_ai_ext_east_missile:release_on_message("ext_release_east_missile");

ga_ai_ext_east_missile:message_on_casualties("ext_release_west_missile", 0.74);
ga_ai_ext_east_missile:release_on_message("ext_release_west_missile");


-------------------------------------------------------------------------------------------------
------------------------------------------ Objectives -------------------------------------------
-------------------------------------------------------------------------------------------------

-- Conquer the settlement.
gb:set_objective_on_message("intro_cutscene_end", "3k_main_battle_historical_scripted_objective_red_cliff_1", 1000);

-- discount hidden Cao Cao when victory point is captured
ga_ai_cao_cao:message_on_alliance_not_active_on_battlefield("player_wins");
ga_player_main_01:force_victory_on_message("player_wins");