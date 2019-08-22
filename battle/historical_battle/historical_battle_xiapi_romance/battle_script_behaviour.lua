-- Siege of Xia Pi. Cao Cao vs Liu Bei. 198.

-------------------------------------------------------------------------------------------------
------------------------------------------- KEY INFO --------------------------------------------
-------------------------------------------------------------------------------------------------

-- E3 2018
-- Siege of Xiapi. Cao Cao vs Lu Bu. 198.
-- Han City A Medium
-- Attacker

-------------------------------------------------------------------------------------------------
------------------------------------------- PRELOADS --------------------------------------------
-------------------------------------------------------------------------------------------------

bm:suppress_unit_voices(true);
bm:suppress_unit_musicians(true);

gb = generated_battle:new(
	true,        	                              		-- screen starts black
	true,	                                      		-- prevent deployment for player
    false,                                      		-- prevent deployment for ai
	function() play_intro_cutscene() end,				-- intro cutscene function
	true                                      			-- debug mode
);

gb:set_end_deployment_phase_after_loading_screen(true);

-------------------------------------------------------------------------------------------------
------------------------------------ LOCAL ------------------------------------------
-------------------------------------------------------------------------------------------------

local cam = bm:camera();

local intro_cinematic_file =            "script\\battle\\historical_battle\\historical_battle_xiapi\\cutscene\\managers\\intro_romance.CindySceneManager";


-- Scene lengths.
local intro_cindy_length = 81000;


local intro_cutscene_debug = false;


-------------------------------------------------------------------------------------------------
------------------------------------ PLAYER ARMY SETUP ------------------------------------------
-------------------------------------------------------------------------------------------------

ga_player_main_01 = gb:get_army(gb:get_player_alliance_num(), "player_01");
ga_player_reinforcements_01 = gb:get_army(gb:get_player_alliance_num(), "player_02");

-------------------------------------------------------------------------------------------------
------------------------------------ ENEMY ARMY SETUP -------------------------------------------
-------------------------------------------------------------------------------------------------

ga_ai_lu_bu = gb:get_army(gb:get_non_player_alliance_num(), "enemy_lu_bu");
ga_ai_main_01 = gb:get_army(gb:get_non_player_alliance_num(), "enemy_01");

sunit_ai_lu_bu = ga_ai_lu_bu.sunits:item(1);

ga_ai_main_01_sunits = ga_ai_main_01.sunits;

sunit_ai_lu_bu_cavalry_01 = ga_ai_main_01_sunits:item(1);
sunit_ai_lu_bu_cavalry_02 = ga_ai_main_01_sunits:item(2);
sunit_ai_lu_bu_cavalry_03 = ga_ai_main_01_sunits:item(3);
sunit_ai_lu_bu_archers_01 = ga_ai_main_01_sunits:item(4);
sunit_ai_lu_bu_halberdiers_01 = ga_ai_main_01_sunits:item(5);
sunit_ai_lu_bu_halberdiers_02 = ga_ai_main_01_sunits:item(6);

sunit_ai_zhang_lao = ga_ai_main_01_sunits:item(7);
sunit_ai_zhang_lao_halberdiers_01 = ga_ai_main_01_sunits:item(8);
sunit_ai_zhang_lao_halberdiers_02 = ga_ai_main_01_sunits:item(9);
sunit_ai_zhang_lao_halberdiers_03 = ga_ai_main_01_sunits:item(10);
sunit_ai_zhang_lao_halberdiers_04 = ga_ai_main_01_sunits:item(11);
sunit_ai_zhang_lao_halberdiers_05 = ga_ai_main_01_sunits:item(12);

sunit_ai_chen_gong = ga_ai_main_01_sunits:item(13);
sunit_ai_chen_gong_archers_01 = ga_ai_main_01_sunits:item(14);
sunit_ai_chen_gong_archers_02 = ga_ai_main_01_sunits:item(15);
sunit_ai_chen_gong_archers_03 = ga_ai_main_01_sunits:item(16);
sunit_ai_chen_gong_halberdiers_01 = ga_ai_main_01_sunits:item(17);
sunit_ai_chen_gong_halberdiers_02 = ga_ai_main_01_sunits:item(18);

sunits_central_plaza_cavalry = script_units:new("central_plaza_cavalry", sunit_ai_lu_bu_cavalry_01, sunit_ai_lu_bu_cavalry_02);

-- intro pan movements
sunit_ai_lu_bu_cavalry_01.intro_dest_pos = v(-12.0, -0.7);
sunit_ai_lu_bu_cavalry_01.intro_dest_orient = 180;
sunit_ai_lu_bu_cavalry_01.intro_dest_width = 21.0;

--
sunit_ai_lu_bu_cavalry_02.intro_dest_pos = v(12.4, -0.7);
sunit_ai_lu_bu_cavalry_02.intro_dest_orient = 180;
sunit_ai_lu_bu_cavalry_02.intro_dest_width = 21.0;

--
sunit_ai_lu_bu_cavalry_03.intro_dest_pos = v(0, -87);
sunit_ai_lu_bu_cavalry_03.intro_dest_orient = 180;
sunit_ai_lu_bu_cavalry_03.intro_dest_width = 25.0;

--
-- sunit_ai_lu_bu_archers_01.intro_pos = v(39, -373);
sunit_ai_lu_bu_archers_01.intro_pos = v(40, -383);
sunit_ai_lu_bu_archers_01.intro_orient = 180;
sunit_ai_lu_bu_archers_01.intro_width = 50;
sunit_ai_lu_bu_archers_01.intro_dest_delay = 0;

sunit_ai_lu_bu_archers_01.intro_dest_occupy_zone = v(30, -383);

--
sunit_ai_lu_bu_halberdiers_01.intro_dest_pos = v(-269.2, -377.8);
sunit_ai_lu_bu_halberdiers_01.intro_dest_orient = 180;
sunit_ai_lu_bu_halberdiers_01.intro_dest_width = 23.7;

--
sunit_ai_lu_bu_halberdiers_02.intro_pos = v(-205.5, -284.9);
sunit_ai_lu_bu_halberdiers_02.intro_orient = 180;
sunit_ai_lu_bu_halberdiers_02.intro_width = 19.5;

sunit_ai_lu_bu_halberdiers_02.intro_dest_pos = v(-237.7, -360.5);
sunit_ai_lu_bu_halberdiers_02.intro_dest_orient = 180;
sunit_ai_lu_bu_halberdiers_02.intro_dest_width = 35.0;
sunit_ai_lu_bu_halberdiers_02.intro_dest_delay = 35000;

--
sunit_ai_zhang_lao.intro_pos = v(-198, -263);
sunit_ai_zhang_lao.intro_orient = 180;
sunit_ai_zhang_lao.intro_width = 1.4;

sunit_ai_zhang_lao.intro_dest_pos = v(-201, -344);
sunit_ai_zhang_lao.intro_dest_delay = 35000;

--
sunit_ai_zhang_lao_halberdiers_01.intro_dest_pos = v(-317.2, -377.8);
sunit_ai_zhang_lao_halberdiers_01.intro_dest_orient = 180;
sunit_ai_zhang_lao_halberdiers_01.intro_dest_width = 23.7;

--
sunit_ai_zhang_lao_halberdiers_02.intro_pos = v(-0, -313.3);
sunit_ai_zhang_lao_halberdiers_02.intro_orient = 180;
sunit_ai_zhang_lao_halberdiers_02.intro_width = 25.1;
sunit_ai_zhang_lao_halberdiers_02.intro_dest_delay = 18000;

sunit_ai_zhang_lao_halberdiers_02.intro_dest_pos = v(0, -370);
sunit_ai_zhang_lao_halberdiers_02.intro_dest_orient = 180;
sunit_ai_zhang_lao_halberdiers_02.intro_dest_width = 42;

--
sunit_ai_zhang_lao_halberdiers_03.intro_pos = v(-233, -277.8);
sunit_ai_zhang_lao_halberdiers_03.intro_orient = 180;
sunit_ai_zhang_lao_halberdiers_03.intro_width = 19.5;
sunit_ai_zhang_lao_halberdiers_03.intro_dest_delay = 35000;

sunit_ai_zhang_lao_halberdiers_03.intro_dest_pos = v(-280, -360);
sunit_ai_zhang_lao_halberdiers_03.intro_dest_orient = 180;
sunit_ai_zhang_lao_halberdiers_03.intro_dest_width = 42;

--
sunit_ai_zhang_lao_halberdiers_04.intro_pos = v(-6.7, -280.8);
sunit_ai_zhang_lao_halberdiers_04.intro_orient = 180;
sunit_ai_zhang_lao_halberdiers_04.intro_width = 12.5;
sunit_ai_zhang_lao_halberdiers_04.intro_dest_delay = 19000;

sunit_ai_zhang_lao_halberdiers_04.intro_dest_pos = v(-10.7, -354.7);
sunit_ai_zhang_lao_halberdiers_04.intro_dest_orient = 180;
sunit_ai_zhang_lao_halberdiers_04.intro_dest_width = 19.5;

--
sunit_ai_zhang_lao_halberdiers_05.intro_pos = v(-229, -305.3);
sunit_ai_zhang_lao_halberdiers_05.intro_orient = 180;
sunit_ai_zhang_lao_halberdiers_05.intro_width = 18;
sunit_ai_zhang_lao_halberdiers_05.intro_dest_delay = 35000;

sunit_ai_zhang_lao_halberdiers_05.intro_dest_pos = v(-327, -360);
sunit_ai_zhang_lao_halberdiers_05.intro_dest_orient = 180;
sunit_ai_zhang_lao_halberdiers_05.intro_dest_width = 42;

--
sunit_ai_chen_gong.intro_dest_pos = v(-222.6, -345.6);
sunit_ai_chen_gong.intro_dest_orient = 180;
sunit_ai_chen_gong.intro_dest_width = 1.4;

--
sunit_ai_chen_gong_archers_01.intro_pos = v(-137, -373);
sunit_ai_chen_gong_archers_01.intro_orient = 180;
sunit_ai_chen_gong_archers_01.intro_width = 40;
sunit_ai_chen_gong_archers_01.intro_dest_delay = 70000;

sunit_ai_chen_gong_archers_01.intro_dest_occupy_zone = v(-137, -383);

--
sunit_ai_chen_gong_archers_02.intro_pos = v(-54, -373);
sunit_ai_chen_gong_archers_02.intro_orient = 180;
sunit_ai_chen_gong_archers_02.intro_width = 40;
sunit_ai_chen_gong_archers_02.intro_dest_delay = 0;

sunit_ai_chen_gong_archers_02.intro_dest_occupy_zone = v(-54, -383);

--
sunit_ai_chen_gong_archers_03.intro_pos = v(-222, -373);
sunit_ai_chen_gong_archers_03.intro_orient = 180;
sunit_ai_chen_gong_archers_03.intro_width = 40;
sunit_ai_chen_gong_archers_03.intro_dest_delay = 0;

sunit_ai_chen_gong_archers_03.intro_dest_occupy_zone = v(-222, -383);

--
sunit_ai_chen_gong_halberdiers_01.intro_pos = v(0, -240.6);
sunit_ai_chen_gong_halberdiers_01.intro_orient = 180;
sunit_ai_chen_gong_halberdiers_01.intro_width = 21;
sunit_ai_chen_gong_halberdiers_01.intro_dest_delay = 22000;

sunit_ai_chen_gong_halberdiers_01.intro_dest_pos = v(0, -320.6);
sunit_ai_chen_gong_halberdiers_01.intro_dest_orient = 180;
sunit_ai_chen_gong_halberdiers_01.intro_dest_width = 30;

--
sunit_ai_chen_gong_halberdiers_02.intro_pos = v(7, -292.7);
sunit_ai_chen_gong_halberdiers_02.intro_orient = 180;
sunit_ai_chen_gong_halberdiers_02.intro_width = 12.5;
sunit_ai_chen_gong_halberdiers_02.intro_dest_delay = 20000;

sunit_ai_chen_gong_halberdiers_02.intro_dest_pos = v(9.5, -354.7);
sunit_ai_chen_gong_halberdiers_02.intro_dest_orient = 180;
sunit_ai_chen_gong_halberdiers_02.intro_dest_width = 19.5;


-------------------------------------------------------------------------------------------------
-------------------------------------------- EVENTS ---------------------------------------------
-------------------------------------------------------------------------------------------------

-----------------
-- Intro Cutscene
-----------------
gb:add_listener(
    "deployment_started",
    function()	
		-- CS Initialisers
		setup_intro_cutscene();
    end
);

-----------------
-- Reinforcements
-----------------

gb:message_on_time_offset("send_reinforcements", 420000);
ga_player_main_01:message_on_casualties("send_reinforcements", 0.1);
ga_player_main_01:message_on_rout_proportion("send_reinforcements", 0.2);


-----------------
-- Battle End
-----------------

ga_ai_main_01:message_on_victory("player_defeat");


gb:add_listener(
    "player_defeat",
    function()
		bm:callback(function() bm:end_battle() end, 10000);
    end,
    false
);

-------------------------------------------------------------------------------------------------
------------------------------------------- CUTSCENE --------------------------------------------
-------------------------------------------------------------------------------------------------

-------------------------
-- INTRO 
-------------------------

function setup_intro_cutscene()
    bm:out("\t " .. debug.getinfo(1, "n").name .. "() called");

	-- declare cutscene
	intro_cutscene = cutscene:new(
		"xiapi_intro", 							-- unique string name for cutscene
		ga_player_main_01.sunits,				-- unitcontroller over player's army
		intro_cindy_length,						-- duration of cutscene in ms
        function() end_intro_cutscene() end		-- what to call when cutscene is finished
    );
    
    intro_cutscene:set_skippable(true, function() skip_intro_cutscene() end);
	
    if intro_cutscene_debug then
		intro_cutscene:set_debug(true);
		intro_cutscene:enable_debug_timestamps(true);
	end;
		
	-- set up subtitles
	local subtitles = intro_cutscene:subtitles();
	subtitles:set_alignment("bottom_centre");
	subtitles:clear();
	
	
	-- teleports at start of intro camera pan
	intro_cutscene:action(
		function()
			for i = 1, ga_ai_main_01_sunits:count() do
				local current_sunit = ga_ai_main_01_sunits:item(i);
				
				if current_sunit.intro_pos then
					current_sunit.uc:take_control();
					current_sunit.uc:teleport_to_location(current_sunit.intro_pos, current_sunit.intro_orient, current_sunit.intro_width);
					bm:out("Teleporting " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") to location " .. v_to_s(current_sunit.intro_pos) .. " with orientation " .. current_sunit.intro_orient .. " and width " .. current_sunit.intro_width .. "m");
				elseif current_sunit.intro_dest_occupy_zone then
					current_sunit.uc:take_control();
					current_sunit.uc:occupy_zone(current_sunit.intro_dest_occupy_zone, true);
					bm:out("Making " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") occupy zone at " .. v_to_s(current_sunit.intro_dest_occupy_zone));
				elseif current_sunit.intro_dest_pos and current_sunit.intro_dest_orient and current_sunit.intro_dest_width then
					current_sunit.uc:take_control();
					current_sunit.uc:teleport_to_location(current_sunit.intro_dest_pos, current_sunit.intro_dest_orient, current_sunit.intro_dest_width);
					bm:out("Teleporting " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") to destination location " .. v_to_s(current_sunit.intro_dest_pos) .. " with orientation " .. current_sunit.intro_dest_orient .. " and width " .. current_sunit.intro_dest_width .. "m");
				end;
			end;
		end,
		0
	)
	
	
	-- ai movements during intro camera pan
	for i = 1, ga_ai_main_01_sunits:count() do
		local current_sunit = ga_ai_main_01_sunits:item(i);
		
		if current_sunit.intro_dest_delay then
			local action = false;
			
			local should_run = true;
			if current_sunit.intro_dest_should_run == false then
				should_run = false;
			end;
			
			if current_sunit.intro_dest_pos then
				if current_sunit.intro_dest_orient and current_sunit.intro_dest_width then
					action = function()
						bm:out("Moving " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") to " .. v_to_s(current_sunit.intro_dest_pos) .. ", orientation " .. current_sunit.intro_dest_orient .. " and width " .. current_sunit.intro_dest_width .. "m, running: " .. tostring(should_run));
						current_sunit.uc:goto_location_angle_width(current_sunit.intro_dest_pos, current_sunit.intro_dest_orient, current_sunit.intro_dest_width, should_run);
						current_sunit.intro_dest_order_given = true;
					end;
				else
					action = function()
						bm:out("Moving " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") to " .. v_to_s(current_sunit.intro_dest_pos) .. ", running: " .. tostring(should_run));
						current_sunit.uc:goto_location(current_sunit.intro_dest_pos, should_run);
						current_sunit.intro_dest_order_given = true;
					end;
				end;
			elseif current_sunit.intro_dest_occupy_zone then
				action = function()
					bm:out("Moving " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") into zone at " .. v_to_s(current_sunit.intro_dest_occupy_zone));
					current_sunit.uc:occupy_zone(current_sunit.intro_dest_occupy_zone);
					current_sunit.intro_dest_order_given = true;
				end;
			end;
			
			if action then
				intro_cutscene:action(action, current_sunit.intro_dest_delay);
			end;
		end;
	end;
	
	-- cindy scene
	intro_cutscene:action(
		function()
			if not intro_cutscene_debug then
				bm:cindy_playback(intro_cinematic_file, 0, 2);
			end;
			cam:fade(false, 0.5);
		end, 
		500
	);
	
    intro_cutscene:action(function() cam:fade(false, 1) end, 750);
	

end;


function skip_intro_cutscene()
	cam:fade(true, 0);
	
	-- issue intro movement orders if they haven't already been issued
	for i = 1, ga_ai_main_01_sunits:count() do
		local current_sunit = ga_ai_main_01_sunits:item(i);
		
		if not current_sunit.intro_dest_order_given then
			current_sunit.intro_dest_order_given = true;
			
			local should_run = true;
			if current_sunit.intro_dest_should_run == false then
				should_run = false;
			end;
			
			if current_sunit.intro_dest_pos then
				if current_sunit.intro_dest_orient and current_sunit.intro_dest_width then
					bm:out("Moving " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") to " .. v_to_s(current_sunit.intro_dest_pos) .. ", orientation " .. current_sunit.intro_dest_orient .. " and width " .. current_sunit.intro_dest_width .. "m, running: " .. tostring(should_run) .. " as intro cutscene has been skipped");
					current_sunit.uc:goto_location_angle_width(current_sunit.intro_dest_pos, current_sunit.intro_dest_orient, current_sunit.intro_dest_width, should_run);
				else
					bm:out("Moving " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") to " .. v_to_s(current_sunit.intro_dest_pos) .. ", running: " .. tostring(should_run) .. " as intro cutscene has been skipped");
					current_sunit.uc:goto_location(current_sunit.intro_dest_pos, should_run);
				end;
			elseif current_sunit.intro_dest_occupy_zone then
				bm:out("Moving " .. current_sunit.name .. " (table index: " .. i .. ", unique ui id: " .. current_sunit.unit:unique_ui_id() .. ") into zone at " .. v_to_s(current_sunit.intro_dest_occupy_zone) .. " as intro cutscene has been skipped");
				current_sunit.uc:occupy_zone(current_sunit.intro_dest_occupy_zone);
			end;
		end;
	end;
	
	
	bm:stop_cindy_playback(true);
	cam:fade(false, 0.5);
end;


function end_intro_cutscene()
	bm:out("\t " .. debug.getinfo(1, "n").name .. "() called");
	
	-- make enemy missile units use flaming arrows by default, and release control of all units
	
	for i = 1, ga_ai_main_01_sunits:count() do
		local current_sunit = ga_ai_main_01_sunits:item(i);
		
		if current_sunit.unit:unit_class() == "inf_mis" then
			current_sunit.uc:change_shot_type("small_arm_flaming");
		end;
		current_sunit.uc:release_control();
		ga_ai_main_01:release();
		
	end;
	
	gb.sm:trigger_message("intro_cutscene_end");
end;


function play_intro_cutscene()
    bm:out("\t " .. debug.getinfo(1, "n").name .. "() called");

    bm:cindy_preload(intro_cinematic_file);

    intro_cutscene:start();
end;


-------------------------
-- REINFORCEMENT
-------------------------

ga_player_reinforcements_01:reinforce_on_message("send_reinforcements");


-------------------------
-- OBJECTIVES 
-------------------------

local ai_victory_point = v(0, 200, 16);  -- Ping location of victory point

-- Capture the victory point or defeat Lu Bu.
gb:set_objective_on_message("intro_cutscene_end", "3k_main_battle_historical_scripted_objective_xiapi_1", 3000);
gb:add_ping_icon_on_message("intro_cutscene_end", ai_victory_point, 3, 3000, 30000);