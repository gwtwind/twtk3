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
	cm:load_faction_script(cm:get_local_faction() .. "_historical", true);
	--cm:load_faction_script(cm:get_local_faction() .. "_progression", true);
	--cm:load_faction_script(cm:get_local_faction() .. "_tutorial", true);
	output("campaign script loaded for " .. cm:get_local_faction());
end

---------------------------------------------------------------
--	First-Tick callbacks
---------------------------------------------------------------

cm:add_first_tick_callback_sp_new(
	function() 
		-- put faction-specific calls that should only gets triggered in a new singleplayer game here
		output("New  SP Game Events Fired for " .. cm:get_local_faction());
		
		cm:start_intro_cutscene_on_loading_screen_dismissed(
			function()
				cm:show_benchmark_if_required(
					function()						
						cutscene_intro_play()
					end,																					-- function to call if not in benchmark mode
					"script/benchmarks/campaign_benchmark/scenes/main.CindyScene",			                -- benchmark cindy scene
					36.00,																					-- duration of cindy scene
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

		-- Disable faction council for the Yellow Turbans
		uim:override("hide_faction_council"):set_allowed(false);
	end
);

cm:add_first_tick_callback_mp_new(
	function() 
		-- put faction-specific calls that should only gets triggered in a new multiplayer game here
		-- output("New MP Game Events Fired for " .. cm:get_local_faction());
		
		-- Set starting camera
		cm:set_camera_position(
			343.498871,		-- camera x position 
			397.137299, 	-- camera y position
			13.779046, 		-- camera d position
			0.64084, 		-- camera b position
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
		63,
		function()
			start_campaign_from_intro_cutscene()
		end,
		true
	);
	
	--cutscene_intro:set_debug(true)
	cutscene_intro:set_disable_shroud(true);
	
	--fix me! needs all the cutscenes altered and timing set right--
	cutscene_intro:action(
		function()
			cutscene_intro:cindy_playback("script/campaign/three_kingdoms_early/factions/campaign_intro_cutscenes/scenes/scene_01_huang_shao.CindyScene", 0, 10);
		end,
		0
	);

	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_01");
			-- The capital is cinders, my lord - burned by Dong Zhuo! - 15 / 5
		end,
		4.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		9.5
	);
	

	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_02");
			-- The tyrant acts out of greed and ambition - he attempts to manipulate fate for his own ends...  - 25 / 8
		end,
		10
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		18
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_03");
			-- The land weeps - famine, floods… they are a sign of heaven's displeasure. - 17 / 7
		end,
		18.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		25.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_04");
			-- A coalition of warlords has risen against the tyrant… 17 / 5
		end,
		26
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		31
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_05");
			-- They are my enemies, too! Every abusive, corrupt Han official must be opposed! - 23 / 7
		end,
		31.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		38.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_06");
			-- The Han lands in the southeast may be vulnerable, my lord - we could start there? - 21 / 7
		end,
		39
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		46
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_07");
			-- The people suffer, and must be liberated from their oppressive yoke. - 20 / 7
		end,
		46.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		53.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_08");
			-- It is time for the yellow sky to rise, Lord Huang Shao - you must carry China to a new future! - 25 / 8
		end,
		54
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		62
	);
		

	cutscene_intro:start();
	
end;


function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	--fix me! intro text is not in DB yet--
	cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_01");
	cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_02");
	cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_03");
	cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_04");
	cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_05");
	cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_06");
	cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_07");
	cm:show_advice("3k_campaign_faction_intro_Huang_Shao_Yellow_Turbans_08");
	
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
	core:trigger_event("ScriptEventHuangShaoMissionInitialTrigger");
end



---------------------------------------------------------------
--	Turn One Map Pins: Huang Shao -- [DS]
---------------------------------------------------------------0

function turn_one_region_visibility()

	-- Reveal a number of relevant regions (and their owning factions) at the start of turn one.

	local modify_faction = cm:modify_faction("3k_main_faction_yellow_turban_taishan");

	if not modify_faction then
		script_error("Error no faction found");
		return;
	end;

	-- Chang'an
	modify_faction:make_region_seen_in_shroud("3k_main_changan_capital");
		
	-- Luoyang
	modify_faction:make_region_seen_in_shroud("3k_main_luoyang_capital");
	
end

function add_turn_one_character_map_pins()
	output("3k_main_faction_yellow_turban_taishan_start.lua: Adding turn one character map pins for Huang Shao's faction.");

	-- Find pinned faction leader character cqis from their faction records
	local dong_zhuo = cm:query_faction("3k_main_faction_dong_zhuo"):faction_leader():cqi();
	local coalition = cm:query_faction("3k_main_faction_yuan_shao"):faction_leader():cqi();
	local liu_bei = cm:query_faction("3k_main_faction_liu_bei"):faction_leader():cqi();
	local liu_dai = cm:query_faction("3k_main_faction_liu_dai"):faction_leader():cqi();
	local kong_rong = cm:query_faction("3k_main_faction_kong_rong"):faction_leader():cqi();
	local he_yi = cm:query_faction("3k_main_faction_yellow_turban_rebels"):faction_leader():cqi();
	local gong_du = cm:query_faction("3k_main_faction_yellow_turban_anding"):faction_leader():cqi();
	local huang_shao = cm:query_faction("3k_main_faction_yellow_turban_taishan"):faction_leader():cqi();
	

	-- Create a table connecting our map_pin records with our derived character CQIs
	local map_pin_characters = 
		{
			["3k_ytr_startpos_pin_huang_shao_dong_zhuo"] = dong_zhuo,
			["3k_ytr_startpos_pin_huang_shao_yuan_shao"] = coalition,
			["3k_ytr_startpos_pin_huang_shao_liu_bei"] = liu_bei,
			["3k_ytr_startpos_pin_huang_shao_liu_dai"] = liu_dai,
			["3k_ytr_startpos_pin_huang_shao_kong_rong"] = kong_rong,
			["3k_ytr_startpos_pin_huang_shao_he_yi"] = he_yi,
			["3k_ytr_startpos_pin_huang_shao_gong_du"] = gong_du,
			["3k_ytr_startpos_pin_huang_shao_huang_shao"] = huang_shao
		}
		
	
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();
	

	for map_pin_record_key, character_cqi in pairs(map_pin_characters) do

		local modify_character = cm:modify_character(character_cqi);

		map_pins_handler:add_character_pin(modify_character, map_pin_record_key, is_visible);
	end

end

function add_turn_one_settlement_map_pins()
	output("3k_main_faction_yellow_turban_taishan_start.lua: Adding turn one settlement map pins for Huang Shao's faction.");

	-- Create a table connecting our map_pin records with our region records /settlements
	local map_pin_settlements = 
		{
			["3k_startpos_pin_ma_teng_luoyang"] = "3k_main_luoyang_capital",
			["3k_startpos_pin_zheng_jiang_captive_emperor"] = "3k_main_changan_capital"
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
	output("3k_main_faction_yellow_turban_taishan_start.lua: Adding End Turn Map Pin Removal Listener.");

	core:add_listener(
		"Turn One End Check",
		"FactionTurnEnd",
		
		-- Is it turn one? If so, when we end turn, carry on to the next function.
		function(context)
			output("3k_main_faction_yellow_turban_taishan_start.lua: Turn one has ended.");
			return context:query_model():turn_number() == 1;
		end,

		-- Remove the scripted pins.
		function(context)
			output("3k_main_faction_yellow_turban_taishan_start.lua: Removing guide map pins.");
			cm:modify_local_faction():get_map_pins_handler():remove_all_runtime_script_pins();
		end,
		false
	);
	
end;