-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	FACTION SCRIPT
--
--	Custom script for this faction starts here. This script loads in additional
--	scripts depending on the mode the campaign is being started in (first turn vs
--	open), sets up the faction_start object and does some other things
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

if not cm:is_multiplayer() then
	cm:load_faction_script(cm:get_local_faction() .. "_tutorial", true);
	cm:load_faction_script(cm:get_local_faction() .. "_progression", true);
	cm:load_faction_script(cm:get_local_faction() .. "_historical", true);
	output("campaign script loaded for " .. cm:get_local_faction());
end

---------------------------------------------------------------
--	First-Tick callbacks
---------------------------------------------------------------

cm:add_first_tick_callback_sp_new(
	function() 
		-- put faction-specific calls that should only gets triggered in a new singleplayer game here
		output("New  SP Game Events Fired for " .. cm:get_local_faction());

		core:add_listener(
			"test",
			"CharacterFactionCompletesResearch",
			function(context)
				return context:query_character():faction():name() == local_faction; 
			end,
			function(context)
				script_error("Player faction has finished a research!!!!")
			end,
			false
		);
		
		
		cm:start_intro_cutscene_on_loading_screen_dismissed(
			function()
				cm:show_benchmark_if_required(
					function()						
						cutscene_intro_play()
					end,																					-- function to call if not in benchmark mode
					"script/benchmarks/campaign_benchmark/scenes/main.CindyScene",			                -- benchmark cindy scene
					92.83,																					-- duration of cindy scene
					100,																					-- cam position x at start of scene
					200,																					-- cam position y at start of scene
					6,																						-- cam position d at start of scene
					0,																						-- cam position b at start of scene
					4																						-- cam position h at start of scene
				);
			end
		);
		
		
	end
);



cm:add_first_tick_callback_sp_each(
	function() 
		-- put faction-specific calls that should get triggered each time a singleplayer game loads here
		output("Each SP Game Events Fired for " .. cm:get_local_faction());
	end
);

cm:add_first_tick_callback_mp_new(
	function() 
		-- put faction-specific calls that should only gets triggered in a new multiplayer game here
		-- output("New MP Game Events Fired for " .. cm:get_local_faction());
		
		-- Set starting camera
		cm:set_camera_position(
			162.822205,		-- camera x position 
			375.354889, 	-- camera y position
			13.779042, 		-- camera d position
			-0.973967, 		-- camera b position
			5.775582		-- camera h position
		);
	end
);

--[[
cm:add_first_tick_callback_mp_each(
	function()
		-- put faction-specific calls that should get triggered each time a multiplayer game loads here
		-- output("Each MP Game Events Fired for " .. cm:get_local_faction());
	end
);
]]--




---------------------------------------------------------------
--	Intro Cutscene
---------------------------------------------------------------

function cutscene_intro_play()

	output("cutscene_intro_play");
	
	local cutscene_intro = campaign_cutscene:new(
		"intro",
		65,
		function()
			start_campaign_from_intro_cutscene()
		end,
		true
	);
	
	-- cutscene_intro:set_debug(true);
	cutscene_intro:set_disable_shroud(true);
	
	cutscene_intro:action(
		function()
			cutscene_intro:cindy_playback("script/campaign/three_kingdoms_early/factions/campaign_intro_cutscenes/scenes/scene_01_mateng.CindyScene", 0, 10);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_01");
			-- The capital burns, Lord Ma Teng. [8 syllables ~ 3 seconds]
		end,
		4.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		7.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_02");
			-- The noblemen fight for the throne, but they ignore their empire; their responsibility. [22 syllables ~ 7 seconds]
		end,
		8
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		15
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_03");
			-- Dong Zhuo has taken the emperor west, to Chang'an. [14 syllables ~ 4 seconds]
		end,
		15.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		19.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_04");
			-- This is wise. Dong Zhuo has removed him from the chaos. Now the emperor can rule without those insidious eunuchs… [30 syllables ~ 10 seconds]
		end,
		20
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		30
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_05");
			-- Yet there is still civil unrest - the Yellow Turban insurrections persist. [20 syllables ~ 6 seconds]
		end,
		30.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		36.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_06");
			-- Ever am I called to destroy China's enemies. Very well. [16 syllables ~ 7 seconds]
		end,
		37
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		44
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_07");
			-- Han Sui may aid you, my lord, he has been a staunch friend. [15 syllables ~ 4 seconds]
		end,
		44.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		48.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_08");
			-- He has. Yet friends rise and fall; the empire must not. [12 syllables ~ 5 seconds]
		end,
		49
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		54
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_ma_teng_09");
			-- Long have you been the sword that holds back enemies without; now you must turn your blade on the enemies within! [27 syllables ~ 9 seconds]
		end,
		54.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		64.5
	);

	cutscene_intro:start();
end;


function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	cm:show_advice("3k_campaign_faction_intro_ma_teng_01");
	cm:show_advice("3k_campaign_faction_intro_ma_teng_02");
	cm:show_advice("3k_campaign_faction_intro_ma_teng_03");
	cm:show_advice("3k_campaign_faction_intro_ma_teng_04");
	cm:show_advice("3k_campaign_faction_intro_ma_teng_05");
	cm:show_advice("3k_campaign_faction_intro_ma_teng_06");
	cm:show_advice("3k_campaign_faction_intro_ma_teng_07");
	cm:show_advice("3k_campaign_faction_intro_ma_teng_08");
	cm:show_advice("3k_campaign_faction_intro_ma_teng_09");
	
	cm:callback(function() cm:override_ui("disable_advice_audio", false) end, 0.5);

end;








---------------------------------------------------------------
--	Start of Gameplay
---------------------------------------------------------------

function start_campaign_from_intro_cutscene()
	-- call shared startup function in 3k_early_start.lua
	start_campaign_from_intro_cutscene_shared();
	add_turn_one_character_map_pins();
	add_turn_one_settlement_map_pins();
	end_turn_map_pin_removal_listener();
	turn_one_region_visibility();
	core:trigger_event("ScriptEventStartFirstAdvice");

	extended_tutorial:setup();
end



---------------------------------------------------------------
--	Turn One Region Visibility: Ma Teng
---------------------------------------------------------------


function turn_one_region_visibility()

	-- Reveal a number of relevant regions (and their owning factions) at the start of turn one.

	local modify_faction = cm:modify_faction("3k_main_faction_ma_teng");

	if not modify_faction then
		script_error("Error no faction found");
		return;
	end;

	-- Chang'an
	modify_faction:make_region_seen_in_shroud("3k_main_changan_capital");
	
	--modify_faction:make_region_seen_in_shroud("3k_main_changan_resource_1");

	-- Luoyang
	modify_faction:make_region_seen_in_shroud("3k_main_luoyang_capital");
	
	--modify_faction:make_region_seen_in_shroud("3k_main_luoyang_resource_1");
	--modify_faction:make_region_seen_in_shroud("3k_main_chenjun_resource_3");

	-- Han Empire
	--modify_faction:make_region_visible_in_shroud("3k_main_hedong_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_hedong_resource_1");
	
	-- Yuan Shao 
	--modify_faction:make_region_visible_in_shroud("3k_main_weijun_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_weijun_resource_1");

	-- Han Sui 
	--modify_faction:make_region_visible_in_shroud("3k_main_jincheng_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_jincheng_resource_1");
	-- modify_faction:make_region_seen_in_shroud("3k_main_jincheng_resource_2");

	-- Gong Du
	--modify_faction:make_region_visible_in_shroud("3k_main_wudu_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_wudu_resource_1");
	--modify_faction:make_region_seen_in_shroud("3k_main_wudu_resource_2");
	
end

---------------------------------------------------------------
--	Turn One Map Pins: Ma Teng -- [DS]
---------------------------------------------------------------0

function add_turn_one_character_map_pins()
	output("3k_main_faction_ma_teng_start.lua: Adding turn one character map pins for Ma Teng's faction.");

	-- Find pinned faction leader character cqis from their faction records
	local dong_zhuo = cm:query_faction("3k_main_faction_dong_zhuo"):faction_leader():cqi();
	local coalition = cm:query_faction("3k_main_faction_yuan_shao"):faction_leader():cqi();
	local han_sui = cm:query_faction("3k_main_faction_han_sui"):faction_leader():cqi();
	local ma_teng = cm:query_faction("3k_main_faction_ma_teng"):faction_leader():cqi();
	local he_yi = cm:query_faction("3k_main_faction_yellow_turban_rebels"):faction_leader():cqi();
	local gong_du = cm:query_faction("3k_main_faction_yellow_turban_anding"):faction_leader():cqi();
	local huang_shao = cm:query_faction("3k_main_faction_yellow_turban_taishan"):faction_leader():cqi();
	

	-- Create a table connecting our map_pin records with our derived character CQIs
	local map_pin_characters = 
		{
			["3k_startpos_pin_ma_teng_dong_zhuo"] = dong_zhuo,
			["3k_startpos_pin_ma_teng_coalition"] = coalition,
			["3k_startpos_pin_ma_teng_han_sui"] = han_sui,
			["3k_startpos_pin_ma_teng_ma_teng"] = ma_teng,
		--	["3k_startpos_pin_dong_zhuo_yellow_turbans_he_yi"] = he_yi,
			["3k_startpos_pin_dong_zhuo_yellow_turbans_gong_du"] = gong_du
		--	["3k_startpos_pin_dong_zhuo_yellow_turbans_huang_shao"] = huang_shao
		}
		
	
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();
	

	for map_pin_record_key, character_cqi in pairs(map_pin_characters) do

		local modify_character = cm:modify_character(character_cqi);

		map_pins_handler:add_character_pin(modify_character, map_pin_record_key, is_visible);
	end

end

function add_turn_one_settlement_map_pins()
	output("3k_main_faction_ma_teng_start.lua: Adding turn one settlement map pins for Sun Jian's faction.");

	-- Create a table connecting our map_pin records with our region records /settlements
	local map_pin_settlements = 
		{
			["3k_startpos_pin_ma_teng_luoyang"] = "3k_main_luoyang_capital",
			["3k_startpos_pin_ma_teng_emperor"] = "3k_main_changan_capital"
		}
		
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();


	for map_pin_record_key, region in pairs(map_pin_settlements) do

		local modify_settlement = cm:modify_settlement(region);

		map_pins_handler:add_settlement_pin(modify_settlement, map_pin_record_key, is_visible);
	end

end


-- Clear Map Pins Listeners

function end_turn_map_pin_removal_listener()
	output("3k_main_faction_ma_teng_start.lua: Adding End Turn Map Pin Removal Listener.");

	core:add_listener(
		"Turn One End Check",
		"FactionTurnEnd",
		
		-- Is it turn one? If so, when we end turn, carry on to the next function.
		function(context)
			output("3k_main_faction_ma_teng_start.lua: Turn one has ended.");
			return context:query_model():turn_number() == 1;
		end,

		-- Remove the scripted pins.
		function(context)
			output("3k_main_faction_ma_teng_start.lua: Removing guide map pins.");
			cm:modify_local_faction():get_map_pins_handler():remove_all_runtime_script_pins();
		end,
		false
	);
	
end;