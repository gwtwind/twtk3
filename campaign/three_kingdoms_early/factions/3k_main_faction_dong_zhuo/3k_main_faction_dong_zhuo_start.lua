

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
			205.94928,		-- camera x position 
			366.712555, 	-- camera y position
			15.073277, 		-- camera d position
			-0.266915, 		-- camera b position
			7.010412		-- camera h position
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
		71,
		function()
			start_campaign_from_intro_cutscene()
		end,
		true
	);
	
	-- cutscene_intro:set_debug(true)
	cutscene_intro:set_disable_shroud(true);
	
	cutscene_intro:action(
		function()
			cutscene_intro:cindy_playback("script/campaign/three_kingdoms_early/factions/campaign_intro_cutscenes/scenes/scene_01_dongzhuo.CindyScene", 0, 10);
		end,
		0
	);

	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_01");
			-- Luoyang burns, my Lord, by your command. [9 syllables ~ 4 seconds]
		end,
		3.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		7.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_02");
			-- It was unavoidable. It was the beating heart of treason! [16 syllables ~ 5 seconds]
		end,
		9
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		14
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_03");
			-- Those traitors still rise against you, and they have convinced the people of your guilt. [19 syllables ~ 6 seconds]
		end,
		14.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		20.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_04");
			-- There can be no mercy for traitors. Cao Cao is most capable, but his ambition will destroy him. [25 syllables ~ 10 seconds]
		end,
		21
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		31
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_05");
			-- Yuan Shao may lead this coalition, but he lacks the resolve to oppose me. I will utterly crush him. [26 syllables ~ 8 seconds]
		end,
		31.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		39.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_06");
			-- Tao Qian remains an ally, but he speaks in vagaries… [15 syllables ~ 4 seconds]
		end,
		40
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		44
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_07");
			-- He is weak-willed. I do not trust him, or any of them, to honour any oaths to me. [26 syllables ~ 9 seconds]
		end,
		44.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		53.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_08");
			-- I will burn them all as I burned their precious capital! [15 syllables ~ 7 seconds]
		end,
		54
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		61
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_dong_zhuo_09");
			-- You act in defence of the emperor my lord, let none stand against your fury! [20 syllables ~ 6 seconds]
		end,
		61.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		68
	);

	cutscene_intro:start();
end;


function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_01");
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_02");
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_03");
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_04");
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_05");
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_06");
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_07");
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_08");
	cm:show_advice("3k_campaign_faction_intro_dong_zhuo_09");
	
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
end


---------------------------------------------------------------
--	Turn One Region Visibility: Dong Zhuo
---------------------------------------------------------------


function turn_one_region_visibility()

	-- Reveal a number of relevant regions (and their owning factions) at the start of turn one.

	local modify_faction = cm:modify_faction("3k_main_faction_dong_zhuo");

	if not modify_faction then
		script_error("Error no faction found");
		return;
	end;

	-- Luoyang
	modify_faction:make_region_visible_in_shroud("3k_main_luoyang_capital");
	
	modify_faction:make_region_seen_in_shroud("3k_main_luoyang_resource_1");
	modify_faction:make_region_seen_in_shroud("3k_main_chenjun_resource_3");

	-- Han Empire
	modify_faction:make_region_visible_in_shroud("3k_main_hedong_capital");

	modify_faction:make_region_seen_in_shroud("3k_main_hedong_resource_1");
		
	-- Yuan Shao 
	modify_faction:make_region_visible_in_shroud("3k_main_weijun_capital");

	modify_faction:make_region_seen_in_shroud("3k_main_weijun_resource_1");
	
	-- Cao Cao
	modify_faction:make_region_visible_in_shroud("3k_main_chenjun_capital");

	modify_faction:make_region_seen_in_shroud("3k_main_chenjun_resource_1");
	modify_faction:make_region_seen_in_shroud("3k_main_chenjun_resource_2");

	-- Tao Qian
	modify_faction:make_region_visible_in_shroud("3k_main_donghai_capital");

	modify_faction:make_region_seen_in_shroud("3k_main_donghai_resource_1");

	-- Huang Shao
	modify_faction:make_region_visible_in_shroud("3k_main_dongjun_capital");

	modify_faction:make_region_seen_in_shroud("3k_main_dongjun_resource_1");
		
	-- He Yi
	modify_faction:make_region_visible_in_shroud("3k_main_runan_capital");

	modify_faction:make_region_seen_in_shroud("3k_main_runan_resource_1");

	-- Gong Du
	modify_faction:make_region_visible_in_shroud("3k_main_wudu_capital");

	modify_faction:make_region_seen_in_shroud("3k_main_wudu_resource_1");
	modify_faction:make_region_seen_in_shroud("3k_main_wudu_resource_2");
	
end


---------------------------------------------------------------
--	Turn One Map Pins: Dong Zhuo -- [DS]
---------------------------------------------------------------0

function add_turn_one_character_map_pins()
	output("3k_main_faction_dong_zhuo_start.lua: Adding turn one character map pins for Dong Zhuo's faction.");

	-- Find pinned faction leader character cqis from their faction records
	local dong_zhuo = cm:query_faction("3k_main_faction_dong_zhuo"):faction_leader():cqi();
	local coalition = cm:query_faction("3k_main_faction_yuan_shao"):faction_leader():cqi();
	local cao_cao = cm:query_faction("3k_main_faction_cao_cao"):faction_leader():cqi();
	local tao_qian = cm:query_faction("3k_main_faction_tao_qian"):faction_leader():cqi();
	local he_yi = cm:query_faction("3k_main_faction_yellow_turban_rebels"):faction_leader():cqi();
	local gong_du = cm:query_faction("3k_main_faction_yellow_turban_anding"):faction_leader():cqi();
	local huang_shao = cm:query_faction("3k_main_faction_yellow_turban_taishan"):faction_leader():cqi();
	

	-- Create a table connecting our map_pin records with our derived character CQIs
	local map_pin_characters = 
		{
			["3k_startpos_pin_dong_zhuo_dong_zhuo"] = dong_zhuo,
			["3k_startpos_pin_dong_zhuo_coalition"] = coalition,
			["3k_startpos_pin_dong_zhuo_cao_cao"] = cao_cao,
			["3k_startpos_pin_dong_zhuo_tao_qian"] = tao_qian,
			["3k_startpos_pin_dong_zhuo_yellow_turbans_he_yi"] = he_yi,
			["3k_startpos_pin_dong_zhuo_yellow_turbans_gong_du"] = gong_du,
			["3k_startpos_pin_dong_zhuo_yellow_turbans_huang_shao"] = huang_shao
		}
		
	
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();
	

	for map_pin_record_key, character_cqi in pairs(map_pin_characters) do

		local modify_character = cm:modify_character(character_cqi);

		map_pins_handler:add_character_pin(modify_character, map_pin_record_key, is_visible);
	end

end


function add_turn_one_settlement_map_pins()
	output("3k_main_faction_dong_zhuo_start.lua: Adding turn one settlement map pins for Dong Zhuo's faction.");

	-- Create a table connecting our map_pin records with our region records /settlements
	local map_pin_settlements = 
		{
			["3k_startpos_pin_dong_zhuo_luoyang"] = "3k_main_luoyang_capital",
			["3k_startpos_pin_dong_zhuo_emperor"] = "3k_main_changan_capital"
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
	output("3k_main_faction_dong_zhuo_start.lua: Adding End Turn Map Pin Removal Listener.");

	core:add_listener(
		"Turn One End Check",
		"FactionTurnEnd",
		
		-- Is it turn one? If so, when we end turn, carry on to the next function.
		function(context)
			output("3k_main_faction_dong_zhuo_start.lua: Turn one has ended.");
			return context:query_model():turn_number() == 1;
		end,

		-- Remove the scripted pins.
		function(context)
			output("3k_main_faction_dong_zhuo_start.lua: Removing guide map pins.");
			cm:modify_local_faction():get_map_pins_handler():remove_all_runtime_script_pins();
		end,
		false
	);
	
end;