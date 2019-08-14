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
			279.099304,		-- camera x position 
			335.394836, 	-- camera y position
			13.779058, 		-- camera d position
			0.399649, 		-- camera b position
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
		69,
		function()
			start_campaign_from_intro_cutscene()
		end,
		true
	);
	
	-- cutscene_intro:set_debug(true);
	cutscene_intro:set_disable_shroud(true);
	
	cutscene_intro:action(
		function()
			cutscene_intro:cindy_playback("script/campaign/three_kingdoms_early/factions/campaign_intro_cutscenes/scenes/scene_01_yuan_shu.CindyScene", 0, 10);
		end,
		0
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_01");
			-- The fires rise to claim Luoyang - Dong Zhuo burns the capital! [16 syllables ~ 7]
		end,
		4.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		11.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_02");
			-- He has gone too far; he must be stopped! [9 syllables ~ 4 seconds]
		end,
		12
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		16
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_03");
			-- With the emperor in his possession, he effectively rules the empire from his new capital in Chang'an. [28 syllables ~ 7 seconds]
		end,
		16.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		23.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_04");
			-- And elsewhere, rebellions still plague the land. [11 syllables ~ 5 seconds]
		end,
		24
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		29
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_05");
			-- We must crush the Yellow Turbans; they are as much a blight on China as the tyrant. [21 syllables ~ 7 seconds]
		end,
		29.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		36.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_06");
			-- If I may... your kin, Yuan Shao may be able to-- [13 syllables ~ 3 seconds]
		end,
		37
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		40
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_07");
			-- Bah. What of him? He commands this ineffective "coalition". They are done. [19 syllables ~ 6 seconds]
		end,
		40.1
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		46.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_08");
			-- The bandit queen is greater of spirit and strength than my indecisive cousin. [20 syllables ~ 5 seconds]
		end,
		47
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		52
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_09");
			-- An unlikely friend, my lord, but an option nontheless… [14 syllables ~ 5 seconds]
		end,
		52.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		57.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_yuan_shu_10");
			-- No matter how, the rebellions must be crushed, and Dong Zhuo defeated. Let the Tiger of the Yuan roar, my lord, and shake the very mountains!
			-- [35 syllables ~ 10 seconds]
		end,
		58
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
	
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_01");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_02");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_03");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_04");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_05");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_06");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_07");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_08");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_09");
	cm:show_advice("3k_campaign_faction_intro_yuan_shu_10");
	
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
--	Turn One Region Visibility: Yuan Shu
---------------------------------------------------------------

function turn_one_region_visibility()
	-- Reveal a number of relevant regions (and their owning factions) at the start of turn one.

	local modify_faction = cm:modify_faction("3k_main_faction_yuan_shu");

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

	-- Liu Biao
	--modify_faction:make_region_visible_in_shroud("3k_main_xiangyang_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_xiangyang_resource_1");

	-- Sun Jian
	modify_faction:make_region_seen_in_shroud("3k_main_changsha_capital");

	-- Cai Mao
	modify_faction:make_region_seen_in_shroud("3k_main_jingzhou_resource_1");

	-- Huang Zu
	modify_faction:make_region_seen_in_shroud("3k_main_jiangxia_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_jingzhou_resource_1");
	--modify_faction:make_region_seen_in_shroud("3k_main_changsha_capital");
	--modify_faction:make_region_seen_in_shroud("3k_main_changsha_resource_1");

	-- He Yi
	--modify_faction:make_region_visible_in_shroud("3k_main_runan_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_runan_resource_1");

end




---------------------------------------------------------------
--	Turn One Map Pins: Yuan Shu -- [DS]
---------------------------------------------------------------0

function add_turn_one_character_map_pins()
	output("3k_main_faction_yuan_shu_start.lua: Adding turn one character map pins for Yuan Shu's faction.");

	-- Find pinned faction leader character cqis from their faction records
	local dong_zhuo = cm:query_faction("3k_main_faction_dong_zhuo"):faction_leader():cqi();
	local zheng_jiang = cm:query_faction("3k_main_faction_zheng_jiang"):faction_leader():cqi();
	local yuan_shu = cm:query_faction("3k_main_faction_yuan_shu"):faction_leader():cqi();
	local yuan_shao = cm:query_faction("3k_main_faction_yuan_shao"):faction_leader():cqi();
	local liu_biao = cm:query_faction("3k_main_faction_liu_biao"):faction_leader():cqi();
	local sun_jian = cm:query_faction("3k_main_faction_sun_jian"):faction_leader():cqi();
	local he_yi = cm:query_faction("3k_main_faction_yellow_turban_rebels"):faction_leader():cqi();
	local gong_du = cm:query_faction("3k_main_faction_yellow_turban_anding"):faction_leader():cqi();
	local huang_shao = cm:query_faction("3k_main_faction_yellow_turban_taishan"):faction_leader():cqi();
	


	-- Create a table connecting our map_pin records with our derived character CQIs
	local map_pin_characters = 
		{
			["3k_startpos_pin_yuan_shu_dong_zhuo"] = dong_zhuo,
			["3k_startpos_pin_yuan_shu_zheng_jiang"] = zheng_jiang,
			["3k_startpos_pin_yuan_shu_yuan_shu"] = yuan_shu,
			["3k_startpos_pin_yuan_shu_yuan_shao"] = yuan_shao,
			["3k_startpos_pin_yuan_shu_liu_biao"] = liu_biao,
			["3k_startpos_pin_yuan_shu_sun_jian"] = sun_jian,
			["3k_startpos_pin_yuan_shu_yellow_turbans_he_yi"] = he_yi
		--	["3k_startpos_pin_yuan_shu_yellow_turbans_gong_du"] = gong_du,
		--	["3k_startpos_pin_yuan_shu_yellow_turbans_huang_shao"] = huang_shao
		}
		
	
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();
	

	for map_pin_record_key, character_cqi in pairs(map_pin_characters) do

		local modify_character = cm:modify_character(character_cqi);

		map_pins_handler:add_character_pin(modify_character, map_pin_record_key, is_visible);
	end

end

function add_turn_one_settlement_map_pins()
	output("3k_main_faction_yuan_shu_start.lua: Adding turn one settlement map pins for Sun Jian's faction.");

	-- Create a table connecting our map_pin records with our region records /settlements
	local map_pin_settlements = 
		{
			["3k_startpos_pin_yuan_shu_luoyang"] = "3k_main_luoyang_capital",
			["3k_startpos_pin_yuan_shu_captive_emperor"] = "3k_main_changan_capital"
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
	output("3k_main_faction_yuan_shu_start.lua: Adding End Turn Map Pin Removal Listener.");

	core:add_listener(
		"Turn One End Check",
		"FactionTurnEnd",
		
		-- Is it turn one? If so, when we end turn, carry on to the next function.
		function(context)
			output("3k_main_faction_yuan_shu_start.lua: Turn one has ended.");
			return context:query_model():turn_number() == 1;
		end,

		-- Remove the scripted pins.
		function(context)
			output("3k_main_faction_yuan_shu_start.lua: Removing guide map pins.");
			cm:modify_local_faction():get_map_pins_handler():remove_all_runtime_script_pins();
		end,
		false
	);
	
end;