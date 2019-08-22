-------------------------------------------------------------------------------------------
---------------------------------------- DYNASTY MODE -------------------------------------
-------------------------------------------------------------------------------------------

if bm:is_multiplayer() == false then
	bm:enable_cinematic_ui(true, true, true)
end

dynasty_mode = {};

dynasty_mode.max_waves = 30 -- max waves. The battle will automatically end if the player beats this many waves
dynasty_mode.current_wave = 0; -- current wave, defined by scripted functions.
dynasty_mode.wave_delay = 4000; -- The delay (in ms) after a wave ends before the next wave starts.
dynasty_mode.wave_timer = 0; -- Used for updating the wave countdown UI.

dynasty_mode.upgrade_points_starting = 0 -- points given on battle start
dynasty_mode.upgrade_points_per_wave = 1 -- points given per completion of normal wave
dynasty_mode.upgrade_points_per_boss_wave = 3 -- points given every third 'boss' wave

dynasty_mode.enemy_unit_rout_threshold = 0.15 -- at what proportion of entities remaining enemy units should be able to rout

-------------------------------------------------------------------------------------------------
------------------------------------------- BATTLE SETUP ----------------------------------------
-------------------------------------------------------------------------------------------------

dynasty_mode.gb = generated_battle:new(
	false,				-- disable black screen on start
	true,				-- prevent deployment for player
	false,				-- prevent deployment for ai
	function() play_intro_cutscene() end,	-- intro cutscene function 
	true				-- debug mode
);

dynasty_mode.gb:set_end_deployment_phase_after_loading_screen(true); -- Starts the game and cutscene when the user presses "Start Battle" in the loading screen

-- This creates the Dynasty mode score UI. Doesn't need any code as it's all setup with context objects!
local battle_hud_component = find_uicomponent(core:get_ui_root(), "ep_dynasty_character_details_parent");
local dynasty_character_details = battle_hud_component:CreateComponent("dynasty_mode_character_details", "ui/battle ui/dynasty_mode_character_details");

-------------------------------------------------------------------------------------------------
------------------------------------------ UPGRADE SETUP ----------------------------------------
-------------------------------------------------------------------------------------------------

function dynasty_mode:grant_upgrade_points(point_amount)
	effect.set_context_value("dynasty_upgrade_points_granted", point_amount);

	for i = 1, point_amount do
		for i = 1, dynasty_mode.player_army_sunits:count() do
			effect.call_context_command("CcoDynastyUnitUpgrades"..dynasty_mode.player_army_sunits:item(i).unit:unique_ui_id(), "GrantUpgradePoint");
		end;
	end;
end

-------------------------------------------------------------------------------------------------
-------------------------------------------- ARMY SETUP -----------------------------------------
-------------------------------------------------------------------------------------------------

dynasty_mode.player_army = dynasty_mode.gb:get_army(dynasty_mode.gb:get_player_alliance_num(), dynasty_mode.gb.bm:local_army());
dynasty_mode.player_army_sunits = dynasty_mode.gb:get_allied_force(dynasty_mode.gb:get_player_alliance_num(), -1);
dynasty_mode.player_army_sunits:set_always_visible(true); -- Gives visibility of all player units to the AI
dynasty_mode.player_army_sunits:set_invincible(false); -- Set to true to make the player's heroes invincible for debug purposes
dynasty_mode.player_army_sunits:release_control();

dynasty_mode.enemy_army = dynasty_mode.gb:get_army(dynasty_mode.gb:get_non_player_alliance_num(), 1);
dynasty_mode.enemy_army_sunits = dynasty_mode.enemy_army.sunits;
dynasty_mode.enemy_army_sunits:fearless_until_casualties(dynasty_mode.enemy_unit_rout_threshold); -- Makes all AI units unbreakable until they reach a certain HP threshold (set above)
dynasty_mode.enemy_army_sunits:set_always_visible(true); -- Gives visibility of all AI units to the player

dynasty_mode:grant_upgrade_points(dynasty_mode.upgrade_points_starting); --add initial upgrade points, if any

dynasty_mode.gb:add_listener(
    "start_behaviour",
	function() dynasty_mode:update_armies() end
);

-- Since we have units around at the beginning of the battle (The first 'wave' begins immediately) we need to begin the first time period when battle starts.
-- begin/end_scoring_time_period() takes an alliance index (0-based). This is because the scoring is tracked on the model, and therefore needs to be done
-- for all alliances, as the model has no knowledge of who the local player is (To make sure it's the same for all potential players)
dynasty_mode.gb:add_listener(
    "start_behaviour",
	function() bm:begin_scoring_time_period(0) end
);

--This function defines the armies for the AI after spawning, sets them fearless, then hijacks the AI with the patrol manager.
function dynasty_mode:update_armies()
	dynasty_mode.current_wave = dynasty_mode.current_wave + 1;
	
	--Update the on screen wave counter with the correct wave number
	effect.set_context_value("dynasty_wave_number", dynasty_mode.current_wave);
	
	--Add higher tier/more dangerous enemies to later waves
	if dynasty_mode.current_wave == 3 then
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_ytr_unit_wood_peasant_spearmen";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_ji_militia";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_peasant_band";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_ji_infantry";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_ytr_unit_wood_yellow_turban_spearmen";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "ep_dyn_unit_water_repeating_crossbowmen";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_metal_axe_band";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_metal_mercenary_infantry";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_metal_fists_of_the_bandit_queen";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_metal_black_mountain_marauders";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_metal_hidden_axes";
	elseif dynasty_mode.current_wave == 6 then
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_spear_warriors";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_spear_guards";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_heavy_ji_infantry";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_heavy_spear_guards";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_ytr_unit_wood_reclaimers";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_fire_xiliang_cavalry";
	elseif dynasty_mode.current_wave == 9 then
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_ytr_unit_wood_guardians_of_the_land";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_metal_pearl_dragons";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_protectors_of_heaven";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_wood_azure_dragons";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "ep_dyn_unit_water_onyx_dragons";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_fire_heavy_xiliang_cavalry";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_fire_jade_dragons";
		dynasty_mode.units[(#dynasty_mode.units + 1)] = "3k_main_unit_earth_yellow_dragons";
	end

	dynasty_mode.gb:build_armies()
	dynasty_mode.enemy_army = dynasty_mode.gb:get_army(dynasty_mode.gb:get_non_player_alliance_num(), 1);
	dynasty_mode.enemy_army_sunits = dynasty_mode.enemy_army.sunits;
	dynasty_mode.enemy_army_sunits:fearless_until_casualties(dynasty_mode.enemy_unit_rout_threshold);
	dynasty_mode.enemy_army_sunits:set_always_visible(true);

	if dynasty_mode.current_wave + 1 > dynasty_mode.max_waves then
		dynasty_mode.enemy_army:message_on_alliance_not_active_on_battlefield("victory");
	else
		-- The callback for the update_armies() function is important as dynasty_mode.gb:build_armies() does not recognise units on the same tick they spawn on.
		dynasty_mode.gb:add_listener(
			"spawn_wave_"..dynasty_mode.current_wave + 1,
			function()
				dynasty_mode:spawnwave((math.floor((dynasty_mode.current_wave / 3) + 3) * ((dynasty_mode.current_wave % 3) + 1)))
				bm:callback(function() dynasty_mode:update_armies() end, 2000);
			end
		);
		dynasty_mode.enemy_army:message_on_alliance_not_active_on_battlefield("wave_"..dynasty_mode.current_wave.."_over");

		-- Add another listener for when we kill all units for scoring purposes and updating the wave timer
		dynasty_mode.gb:add_listener(
			"wave_"..dynasty_mode.current_wave.."_over",
			function()
				dynasty_mode:on_wave_end()
				if dynasty_mode.gb.bm:local_army() == 1 then
					bm:end_scoring_time_period(0)
				end
			end
		);
	end

	--Hijack the AI to charge into the player's units, instead of messing around with formations or tactics
	local player_armies = bm:alliances():item(dynasty_mode.player_army.alliance_number):armies();
	for i = 1, dynasty_mode.enemy_army_sunits:count() do
		local current_sunit = dynasty_mode.enemy_army_sunits:item(i);
		local current_pm = patrol_manager:new("ai_attack_player_"..dynasty_mode.current_wave.."_"..i, current_sunit, player_armies, 40);
		current_pm:set_intercept_time(-1);
		current_pm:add_waypoint(dynasty_mode.player_army_sunits, true, 3000);
		current_pm:loop(true);
		current_pm:set_debug(true);
		current_pm:start();
	end;

end

-------------------------------------------------------------------------------------------------
-------------------------------------------- WAVES ----------------------------------------------
-------------------------------------------------------------------------------------------------

-- Adds a trigger to win once all the waves are clear
dynasty_mode.player_army:force_victory_on_message("victory");

function dynasty_mode:spawnwave(total_units)

	if dynasty_mode.gb.bm:local_army() == 1 then
		-- Create a temporary table of spawn locations so we can easily block off spawn locations once a group is spawned there
		local available_spawn_locations = {}
		for i = 1, #dynasty_mode.spawn_location do
			available_spawn_locations[i] = i;
		end
		
		-- Do the same again for the available units
		local available_units = {}
		for i = 1, #dynasty_mode.units do
			available_units[i] = i;
		end

		-- If it's a boss wave spawn some enemy heroes
		if ((dynasty_mode.current_wave + 1) % 3) == 0 then

			-- Create a temporary table for the heroes as well
			local available_heroes = {}
			for i = 1, #dynasty_mode.heroes do
				available_heroes[i] = i;
			end
			
			for i = 1, ((dynasty_mode.current_wave + 1) / 3) do
			
				--Choose a unit, and spawn location then block them from being reused this wave
				local current_spawn_location = table.remove(available_spawn_locations, bm:random_number(#available_spawn_locations))
				local current_unit = table.remove(available_heroes, bm:random_number(#available_heroes))
				
				--Spawn the chosen unit within the enemy army at the randomly chosen spawn location
				bm:request_spawn_unit(dynasty_mode.enemy_army.army, dynasty_mode.heroes[current_unit], dynasty_mode.spawn_location[current_spawn_location]["x"], dynasty_mode.spawn_location[current_spawn_location]["y"], dynasty_mode.spawn_location[current_spawn_location]["orientation"])
				
			end
		
		end
		
		-- Spawn regular units for the wave
		for i = 1, total_units do
		
			--Choose a unit, and spawn location then block them from being reused this wave
			local current_spawn_location = table.remove(available_spawn_locations, bm:random_number(#available_spawn_locations))
			local current_unit = table.remove(available_units, bm:random_number(#available_units))
			
			--Spawn the chosen unit within the enemy army at the randomly chosen spawn location
			bm:request_spawn_unit(dynasty_mode.enemy_army.army, dynasty_mode.units[current_unit], dynasty_mode.spawn_location[current_spawn_location]["x"], dynasty_mode.spawn_location[current_spawn_location]["y"], dynasty_mode.spawn_location[current_spawn_location]["orientation"])
		
		end

		bm:begin_scoring_time_period(0);
	end
end

-------------------------------------------------------------------------------------------------
------------------------------------------ WAVE TIMER -------------------------------------------
-------------------------------------------------------------------------------------------------

-- Used for setting up the waves and the timers
for i = 1, dynasty_mode.max_waves do
	dynasty_mode.gb:message_on_time_offset("spawn_wave_"..i+1, dynasty_mode.wave_delay, "wave_"..(i+1).."_start");
end

-- Add listener for end of wave break
bm:register_phase_change_callback(
	"DynastyWaveStart", 
	function() 
		dynasty_mode:on_next_wave_begin();
		dynasty_mode.gb.sm:trigger_message("wave_"..(dynasty_mode.current_wave+1).."_start");
	end
);

function dynasty_mode:on_wave_end()
	-- Kill off remaining routing units
	dynasty_mode.enemy_army_sunits:kill(false, 0)

	-- if this was a boss wave, grant boss wave upgrade points. 
	if (dynasty_mode.current_wave % 3) == 0 then
		dynasty_mode:grant_upgrade_points(dynasty_mode.upgrade_points_per_boss_wave);
	else
		dynasty_mode:grant_upgrade_points(dynasty_mode.upgrade_points_per_wave);
	end
end

function dynasty_mode:on_next_wave_begin()
	-- Begin wave timer
	dynasty_mode.wave_timer = dynasty_mode.wave_delay / 1000;
	dynasty_mode:update_wave_timer();
end

function dynasty_mode:update_wave_timer()
	effect.set_context_value("dynasty_wave_timer", dynasty_mode.wave_timer);
	if dynasty_mode.wave_timer > 0 then
		dynasty_mode.wave_timer = dynasty_mode.wave_timer - 1;
		bm:callback(function() dynasty_mode:update_wave_timer() end, 1000);
	end
end

-------------------------------------------------------------------------------------------------
---------------------------------------- INTRO CUTSCENE -----------------------------------------
-------------------------------------------------------------------------------------------------
cam = dynasty_mode.gb.bm:camera();
--ga_player_main_01 = dynasty_mode.gb:get_army(dynasty_mode.gb:get_player_alliance_num(), "player_01");
local intro_cinematic_file =  "script\\battle\\dynasty_battle\\_cutscene\\managers\\arid_dynasty.CindySceneManager";

dynasty_mode.gb:get_army(dynasty_mode.gb:get_player_alliance_num(), dynasty_mode.gb.bm:local_army()):halt();
dynasty_mode.gb:get_army(dynasty_mode.gb:get_non_player_alliance_num(), 1):halt();
dynasty_mode.gb:get_army(dynasty_mode.gb:get_player_alliance_num(), dynasty_mode.gb.bm:local_army()):hold_fire();
dynasty_mode.gb:get_army(dynasty_mode.gb:get_non_player_alliance_num(), 1):hold_fire();

dynasty_mode.gb:get_army(dynasty_mode.gb:get_player_alliance_num(), dynasty_mode.gb.bm:local_army()):change_behaviour_active_on_message("hold_fire","fire_at_will",false,false);
dynasty_mode.gb:get_army(dynasty_mode.gb:get_non_player_alliance_num(), 1):change_behaviour_active_on_message("hold_fire","fire_at_will",false,false);
dynasty_mode.gb:get_army(dynasty_mode.gb:get_player_alliance_num(), dynasty_mode.gb.bm:local_army()):change_behaviour_active_on_message("fire_at_will","fire_at_will",true,true);
dynasty_mode.gb:get_army(dynasty_mode.gb:get_non_player_alliance_num(), 1):change_behaviour_active_on_message("fire_at_will","fire_at_will",true,false);
dynasty_mode.gb:get_army(dynasty_mode.gb:get_player_alliance_num(), dynasty_mode.gb.bm:local_army()):release_on_message("start_behaviour",0);
dynasty_mode.gb:get_army(dynasty_mode.gb:get_non_player_alliance_num(), 1):release_on_message("start_behaviour",0);

function play_intro_cutscene()
	if bm:is_multiplayer() then
		dynasty_mode.gb.sm:trigger_message("start_behaviour");
		return
	end

	hold_fire(); -- Tell all units to hold fire during cutscene
	
	-- declare cutscene
	local intro_cutscene = cutscene:new(
		"dynasty_mode_arid_01", 			-- unique string name for cutscene
		dynasty_mode.player_army_sunits,		-- unitcontroller over player's army
		13000,									-- duration of cutscene in ms
        function()
			end_intro_cutscene();
		end										-- what to call when cutscene is finished
    );
		
	intro_cutscene:set_skippable(true, function() skip_intro_cutscene() end);
	
	-- Play the cindy scene
	intro_cutscene:cindy_action(intro_cinematic_file, 0, 0, 2);
	
	-- intro fade-in
	intro_cutscene:action(
		function() 
			cam:fade(false, 0.3);  
		end, 
		200
	);
	
	intro_cutscene:start();
end;

function hold_fire()
	dynasty_mode.gb.sm:trigger_message("hold_fire");
end;

function fire_at_will()
	dynasty_mode.gb.sm:trigger_message("fire_at_will");
end;

function start_behaviour()
	dynasty_mode.gb.sm:trigger_message("start_behaviour");
	dynasty_mode.gb:get_army(dynasty_mode.gb:get_non_player_alliance_num(), 1):play_sound_charge()
	fire_at_will(); -- Tells all armies to fire at will agian
end;

function skip_intro_cutscene()
	cam:fade(true, 0);
	
	start_behaviour();
	
	dynasty_mode.gb.bm:callback(
		function() 
			dynasty_mode.gb.bm:stop_cindy_playback(true)
			cam:fade(false, 0.3) 
		end, 
		200
	);
end;

function end_intro_cutscene()
	start_behaviour();
	dynasty_mode.gb.sm:trigger_message("intro_cutscene_end");
end;


-------------------------------------------------------------------------------------------------
-------------------------------------- RESPAWNED UNITS ------------------------------------------
-------------------------------------------------------------------------------------------------

-- These are the available units for the script to respawn. 
-- Each of these units can only spawn a maximum of once per wave
-- These do not have to be unique keys, but..
-- These need to be indvidually defined in the battle.xml as spawnable units
-- Duplicate units of a singular key can be defined easily in the xml by increasing the max_count value.
 
  
dynasty_mode.units = {
	[1] = "3k_ytr_unit_metal_scholar_warriors", 
	[2] = "3k_main_unit_metal_jian_swordguards", 
	[3] = "3k_main_unit_metal_sabre_infantry", 
	[4] = "3k_ytr_unit_metal_chanters", 
	[5] = "3k_ytr_unit_earth_white_wave_horsemen", 
	[6] = "3k_ytr_unit_metal_yellow_turban_warriors", 
	[7] = "3k_ytr_unit_metal_peoples_warband", 
	[8] = "3k_ytr_unit_metal_white_wave_veterans", 
	[9] = "3k_main_unit_fire_peasant_raiders", 
	[10] = "3k_main_unit_metal_sabre_militia", 
	[11] = "ep_dyn_unit_water_archer_militia", 
	[12] = "ep_dyn_unit_water_crossbowmen", 
	[13] = "ep_dyn_unit_water_archers", 
	[14] = "3k_ytr_unit_earth_yellow_turban_horsemen",
	[15] = "3k_main_unit_metal_rapid_tiger_infantry",
	[16] = "3k_main_unit_fire_raider_cavalry",
	[17] = "3k_main_unit_fire_lance_cavalry",
	[18] = "3k_main_unit_metal_warriors_of_the_left",
	[19] = "3k_main_unit_fire_mounted_lancer_militia",
	[20] = "3k_main_unit_earth_mounted_sabre_militia", 
	[21] = "3k_main_unit_earth_jian_swordguard_cavalry", 
	[22] = "3k_main_unit_earth_sabre_cavalry", 
	[23] = "3k_main_unit_fire_mercenary_cavalry",
}

dynasty_mode.heroes = {
	[1] = "ep_dyn_hero_earth_cao_cao", 
	[2] = "ep_dyn_hero_wood_dian_wei", 
	[3] = "ep_dyn_hero_fire_dong_zhuo", 
	[4] = "ep_dyn_hero_fire_gan_ning", 
	[5] = "ep_dyn_hero_fire_gongsun_zan", 
	[6] = "ep_dyn_hero_wood_guan_yu", 
	[7] = "ep_dyn_hero_metal_han_sui", 
	[8] = "ep_dyn_hero_metal_huang_zhong", 
	[9] = "ep_dyn_hero_water_kong_rong",
	[10] = "ep_dyn_hero_fire_lady_sun", 
	[11] = "ep_dyn_hero_wood_zheng_jiang", 
	[12] = "ep_dyn_hero_earth_liu_bei", 
	[13] = "ep_dyn_hero_earth_liu_biao", 
	[14] = "ep_dyn_hero_earth_liu_zhang", 
	[15] = "ep_dyn_hero_fire_lu_bu", 
	[16] = "ep_dyn_hero_fire_ma_chao", 
	[17] = "ep_dyn_hero_fire_ma_teng", 
	[18] = "ep_dyn_hero_water_sima_yi", 
	[19] = "ep_dyn_hero_fire_sun_ce", 
	[20] = "ep_dyn_hero_metal_sun_jian", 
	[21] = "ep_dyn_hero_earth_sun_quan", 
	[22] = "ep_dyn_hero_metal_taishi_ci", 
	[23] = "ep_dyn_hero_water_tao_qian", 
	[24] = "ep_dyn_hero_wood_xiahou_dun", 
	[25] = "ep_dyn_hero_fire_xiahou_yuan", 
	[26] = "ep_dyn_hero_wood_xu_chu", 
	[27] = "ep_dyn_hero_metal_xu_huang", 
	[28] = "ep_dyn_hero_earth_yuan_shao", 
	[29] = "ep_dyn_hero_earth_yuan_shu", 
	[30] = "ep_dyn_hero_metal_yue_jin",
	[31] = "ep_dyn_hero_fire_zhang_fei", 
	[32] = "ep_dyn_hero_metal_zhang_liao", 
	[33] = "ep_dyn_hero_wood_zhang_yan", 
	[34] = "ep_dyn_hero_metal_zhao_yun", 
	[35] = "ep_dyn_hero_water_zhou_yu", 
	[36] = "ep_dyn_hero_water_zhuge_liang", 
}

-------------------------------------------------------------------------------------------------
---------------------------------------- SPAWN LOCATIONS ----------------------------------------
-------------------------------------------------------------------------------------------------

-- These are used by the script as the locations for newly spawned units to (randomly) appear

dynasty_mode.spawn_location = {
	[1] = {
		["x"] = 252.37,
		["y"] = -287.74,
		["orientation"] = 5.58,
	},	
	[2] = {
		["x"] = 209.49,
		["y"] = -314.46,
		["orientation"] = 5.84,
	},		
	[3] = {
		["x"] = 185.68,
		["y"] = -284.45,
		["orientation"] = 5.85,
	},		
	[4] = {
		["x"] = 144.41,
		["y"] = -303.37,
		["orientation"] = 5.85,
	},		
	[5] = {
		["x"] = 166.37,
		["y"] = -332.89,
		["orientation"] = 5.75,
	},	
	[6] = {
		["x"] = 232.13,
		["y"] = -260.13,
		["orientation"] = 5.64,
	},
	[7] = {
		["x"] = 29.95,
		["y"] = -341.64,
		["orientation"] = 0.06,
	},	
	[8] = {
		["x"] = 72.95,
		["y"] = -313.85,
		["orientation"] = 0.05,
	},		
	[9] = {
		["x"] = -7.19,
		["y"] = -310.96,
		["orientation"] = 0.04,
	},		
	[10] = {
		["x"] = -8.57,
		["y"] = -341.24,
		["orientation"] = 0.04,
	},		
	[11] = {
		["x"] = 33.24,
		["y"] = -311.37,
		["orientation"] = 0.03,
	},	
	[12] = {
		["x"] = 70.09,
		["y"] = -343.15,
		["orientation"] = 0.05,
	},
	[13] = {
		["x"] = 323.83,
		["y"] = -203.39,
		["orientation"] = 5.32,
	},	
	[14] = {
		["x"] = 300.93,
		["y"] = -186.87,
		["orientation"] = 5.25,
	},		
	[15] = {
		["x"] = 272.08,
		["y"] = -226.43,
		["orientation"] = 5.50,
	},		
	[16] = {
		["x"] = 315.16,
		["y"] = -130.75,
		["orientation"] = 4.89,
	},		
	[17] = {
		["x"] = 341.73,
		["y"] = -151.30,
		["orientation"] = 5.04,
	},	
	[18] = {
		["x"] = 295.80,
		["y"] = -246.40,
		["orientation"] = 5.40,
	},
	[19] = {
		["x"] = 331.83,
		["y"] = -79.97,
		["orientation"] = 4.73,
	},	
	[20] = {
		["x"] = 304.86,
		["y"] = -18.69,
		["orientation"] = 4.70,
	},		
	[21] = {
		["x"] = 300.25,
		["y"] = 42.16,
		["orientation"] = 4.60,
	},		
	[22] = {
		["x"] = 305.66,
		["y"] = -76.50,
		["orientation"] = 4.74,
	},		
	[23] = {
		["x"] = 334.74,
		["y"] = 43.35,
		["orientation"] = 4.55,
	},	
	[24] = {
		["x"] = 334.88,
		["y"] = -19.11,
		["orientation"] = 4.67,
	},
	[25] = {
		["x"] = 212.37,
		["y"] = 288.08,
		["orientation"] = 3.76,
	},	
	[26] = {
		["x"] = 232.16,
		["y"] = 263.73,
		["orientation"] = 3.81,
	},		
	[27] = {
		["x"] = 245.07,
		["y"] = 216.50,
		["orientation"] = 3.95,
	},		
	[28] = {
		["x"] = 193.86,
		["y"] = 257.07,
		["orientation"] = 3.93,
	},		
	[29] = {
		["x"] = 270.93,
		["y"] = 236.11,
		["orientation"] = 3.78,
	},	
	[30] = {
		["x"] = 217.01,
		["y"] = 239.83,
		["orientation"] = 3.67,
	},
	[31] = {
		["x"] = 327.66,
		["y"] = 103.75,
		["orientation"] = 4.60,
	},	
	[32] = {
		["x"] = 297.75,
		["y"] = 98.91,
		["orientation"] = 4.57,
	},		
	[33] = {
		["x"] = 312.04,
		["y"] = 152.97,
		["orientation"] = 4.39,
	},		
	[34] = {
		["x"] = 282.32,
		["y"] = 146.80,
		["orientation"] = 4.28,
	},		
	[35] = {
		["x"] = 263.69,
		["y"] = 184.89,
		["orientation"] = 4.35,
	},	
	[36] = {
		["x"] = 290.23,
		["y"] = 200.19,
		["orientation"] = 4.23,
	},
	[37] = {
		["x"] = -216.14,
		["y"] = 237.28,
		["orientation"] = 2.37,
	},	
	[38] = {
		["x"] = -175.24,
		["y"] = 266.92,
		["orientation"] = 2.63,
	},		
	[39] = {
		["x"] = -149.39,
		["y"] = 238.64,
		["orientation"] = 2.64,
	},		
	[40] = {
		["x"] = -109.54,
		["y"] = 260.40,
		["orientation"] = 2.64,
	},	
	[41] = {
		["x"] = -133.51,
		["y"] = 288.32,
		["orientation"] = 2.53,
	},	
	[42] = {
		["x"] = -194.02,
		["y"] = 211.15,
		["orientation"] = 2.43,
	},
	[43] = {
		["x"] = -276.35,
		["y"] = 163.82,
		["orientation"] = 2.22,
	},	
	[44] = {
		["x"] = -276.88,
		["y"] = 112.62,
		["orientation"] = 2.21,
	},		
	[45] = {
		["x"] = -230.28,
		["y"] = 177.89,
		["orientation"] = 2.19,
	},		
	[46] = {
		["x"] = -254.78,
		["y"] = 195.74,
		["orientation"] = 2.19,
	},		
	[47] = {
		["x"] = -252.92,
		["y"] = 144.38,
		["orientation"] = 2.18,
	},	
	[48] = {
		["x"] = -299.74,
		["y"] = 131.16,
		["orientation"] = 2.20,
	},
	[49] = {
		["x"] = -0.23,
		["y"] = 320.13,
		["orientation"] = 3.28,
	},	
	[50] = {
		["x"] = -4.63,
		["y"] = 292.23,
		["orientation"] = 3.21,
	},		
	[51] = {
		["x"] = 43.69,
		["y"] = 284.35,
		["orientation"] = 3.46,
	},		
	[52] = {
		["x"] = -61.11,
		["y"] = 279.59,
		["orientation"] = 2.85,
	},		
	[53] = {
		["x"] = -54.77,
		["y"] = 312.58,
		["orientation"] = 3.00,
	},	
	[54] = {
		["x"] = 50.80,
		["y"] = 314.54,
		["orientation"] = 3.36,
	},
	[55] = {
		["x"] = -313.29,
		["y"] = 64.19,
		["orientation"] = 1.50,
	},	
	[56] = {
		["x"] = -280.83,
		["y"] = 5.64,
		["orientation"] = 1.46,
	},		
	[57] = {
		["x"] = -270.67,
		["y"] = -54.53,
		["orientation"] = 1.36,
	},		
	[58] = {
		["x"] = -286.91,
		["y"] = 63.13,
		["orientation"] = 1.50,
	},		
	[59] = {
		["x"] = -304.91,
		["y"] = -58.86,
		["orientation"] = 1.32,
	},	
	[60] = {
		["x"] = -310.76,
		["y"] = 3.31,
		["orientation"] = 1.44,
	},
	[61] = {
		["x"] = -91.97,
		["y"] = -327.76,
		["orientation"] = 0.36,
	},	
	[62] = {
		["x"] = -117.20,
		["y"] = -309.12,
		["orientation"] = 0.42,
	},		
	[63] = {
		["x"] = -141.50,
		["y"] = -266.61,
		["orientation"] = 0.56,
	},		
	[64] = {
		["x"] = -81.78,
		["y"] = -293.11,
		["orientation"] = 0.53,
	},		
	[65] = {
		["x"] = -161.65,
		["y"] = -292.05,
		["orientation"] = 0.39,
	},	
	[66] = {
		["x"] = -108.51,
		["y"] = -282.19,
		["orientation"] = 0.28,
	},
	[67] = {
		["x"] = -311.14,
		["y"] = -148.30,
		["orientation"] = 1.16,
	},	
	[68] = {
		["x"] = -283.94,
		["y"] = -134.94,
		["orientation"] = 1.13,
	},		
	[69] = {
		["x"] = -281.85,
		["y"] = -190.82,
		["orientation"] = 0.95,
	},		
	[70] = {
		["x"] = -255.23,
		["y"] = -176.25,
		["orientation"] = 0.84,
	},		
	[71] = {
		["x"] = -226.30,
		["y"] = -207.25,
		["orientation"] = 0.91,
	},	
	[72] = {
		["x"] = -247.23,
		["y"] = -229.62,
		["orientation"] = 0.80,
	},
}