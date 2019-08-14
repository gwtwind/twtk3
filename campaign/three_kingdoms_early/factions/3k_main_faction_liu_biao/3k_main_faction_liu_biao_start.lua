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
			261.697754,		-- camera x position 
			312.989563, 	-- camera y position
			13.77904, 		-- camera d position
			-0.510409, 		-- camera b position
			5.775581		-- camera h position
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
		73,
		function()
			start_campaign_from_intro_cutscene()
		end,
		true
	);
	
	-- cutscene_intro:set_debug(true);
	cutscene_intro:set_disable_shroud(true);
	
	cutscene_intro:action(
		function()
			cutscene_intro:cindy_playback("script/campaign/three_kingdoms_early/factions/campaign_intro_cutscenes/scenes/scene_01_liubiao.CindyScene", 0, 10);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_01");
			-- The capital, my lord, it is in ruins! [11 syllables ~ 4 seconds]
		end,
		4.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		8.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_02");
			-- So Dong Zhuo destroys the seat of the Han… there is no redemption for a tyrant. [21 syllables ~ 7 seconds]
		end,
		9
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		16
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_03");
			-- He absconds to the west - to Chang'an - with the emperor as his captive. [18 syllables ~ 6 seconds]
		end,
		16.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		22.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_04");
			-- He has my kin hostage? Such vile treachery… [11 syllables ~ 4 seconds]
		end,
		23
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		27
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_05");
			-- They say I lack the vitality of my cousin, Liu Bei, but I have my own talents. [22 syllables ~ 7 seconds]
		end,
		27.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		34.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_06");
			-- War is waged with coin, by solid governments. That is my strength; I govern. [18 syllables ~ 6 seconds]
		end,
		35
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		41
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_07");
			-- To the south, Sun Jian hoards the fertile plains, whilst Yuan Shu gathers strength in the north. [19 syllables ~ 6 seconds]
		end,
		41.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		47.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_08");
			-- They are avaricious and unworthy men. They cannot be allowed to grow. [21 syllables ~ 7 seconds]
		end,
		48
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		55
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_09");
			-- The blood of the Han runs in my veins. So long as that is so, I will defend my lineage against all threats! [27 syllables ~ 9 seconds]
		end,
		55.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		64.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_liu_biao_10");
			-- An imperial destiny awaits you, my lord; if you cannot defend the throne, seize it! [23 syllables ~ 8 seconds]
		end,
		65
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		73
	);

	cutscene_intro:start();
end;


function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	cm:show_advice("3k_campaign_faction_intro_liu_biao_01");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_02");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_03");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_04");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_05");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_06");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_07");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_08");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_09");
	cm:show_advice("3k_campaign_faction_intro_liu_biao_10");
	
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
--	Turn One Region Visibility: Liu Biao
---------------------------------------------------------------

function turn_one_region_visibility()

	-- Reveal a number of relevant regions (and their owning factions) at the start of turn one.

	local modify_faction = cm:modify_faction("3k_main_faction_liu_biao");

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

	-- Yuan Shu 
	--modify_faction:make_region_visible_in_shroud("3k_main_nanyang_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_nanyang_resource_1");
		
	-- Sun Jian
	modify_faction:make_region_seen_in_shroud("3k_main_changsha_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_changsha_capital");
	--modify_faction:make_region_seen_in_shroud("3k_main_changsha_resource_1");

	-- He Yi
	--modify_faction:make_region_visible_in_shroud("3k_main_runan_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_runan_resource_1");
	
end


---------------------------------------------------------------
--	Turn One Map Pins: Liu Biao -- [DS]
---------------------------------------------------------------0

function add_turn_one_character_map_pins()
	output("3k_main_faction_liu_biao_start.lua: Adding turn one character map pins for Liu Biao's faction.");

	-- Find pinned faction leader character cqis from their faction records
	local dong_zhuo = cm:query_faction("3k_main_faction_dong_zhuo"):faction_leader():cqi();
	local huang_zu = cm:query_faction("3k_main_faction_huang_zu"):faction_leader():cqi();
	local cai_mao = cm:query_faction("3k_main_faction_cai_mao"):faction_leader():cqi();
	local yuan_shu = cm:query_faction("3k_main_faction_yuan_shu"):faction_leader():cqi();
	local sun_jian = cm:query_faction("3k_main_faction_sun_jian"):faction_leader():cqi();
	local liu_biao = cm:query_faction("3k_main_faction_liu_biao"):faction_leader():cqi();
	local he_yi = cm:query_faction("3k_main_faction_yellow_turban_rebels"):faction_leader():cqi();
	local gong_du = cm:query_faction("3k_main_faction_yellow_turban_anding"):faction_leader():cqi();
	local huang_shao = cm:query_faction("3k_main_faction_yellow_turban_taishan"):faction_leader():cqi();
	

	-- Create a table connecting our map_pin records with our derived character CQIs
	local map_pin_characters = 
		{
			["3k_startpos_pin_liu_biao_dong_zhuo"] = dong_zhuo,
			["3k_startpos_pin_liu_biao_huang_zu"] = huang_zu,
			["3k_startpos_pin_liu_biao_cai_mao"] = cai_mao,
			["3k_startpos_pin_liu_biao_yuan_shu"] = yuan_shu,
			["3k_startpos_pin_liu_biao_sun_jian"] = sun_jian,
			["3k_startpos_pin_liu_biao_liu_biao"] = liu_biao,
			["3k_startpos_pin_liu_biao_yellow_turbans_he_yi"] = he_yi
		--	["3k_startpos_pin_liu_biao_yellow_turbans_gong_du"] = gong_du,
		--	["3k_startpos_pin_liu_biao_yellow_turbans_huang_shao"] = huang_shao
		}
		
	
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();
	

	for map_pin_record_key, character_cqi in pairs(map_pin_characters) do

		local modify_character = cm:modify_character(character_cqi);

		map_pins_handler:add_character_pin(modify_character, map_pin_record_key, is_visible);
	end

end

function add_turn_one_settlement_map_pins()
	output("3k_main_faction_liu_biao_start.lua: Adding turn one settlement map pins for Sun Jian's faction.");

	-- Create a table connecting our map_pin records with our region records /settlements
	local map_pin_settlements = 
		{
			["3k_startpos_pin_liu_biao_luoyang"] = "3k_main_luoyang_capital",
			["3k_startpos_pin_liu_biao_captive_emperor"] = "3k_main_changan_capital"
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
	output("3k_main_faction_liu_biao_start.lua: Adding End Turn Map Pin Removal Listener.");

	core:add_listener(
		"Turn One End Check",
		"FactionTurnEnd",
		
		-- Is it turn one? If so, when we end turn, carry on to the next function.
		function(context)
			output("3k_main_faction_liu_biao_start.lua: Turn one has ended.");
			return context:query_model():turn_number() == 1;
		end,

		-- Remove the scripted pins.
		function(context)
			output("3k_main_faction_liu_biao_start.lua: Removing guide map pins.");
			cm:modify_local_faction():get_map_pins_handler():remove_all_runtime_script_pins();
		end,
		false
	);
	
end;