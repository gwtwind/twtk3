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
			153.851227,		-- camera x position 
			354.25119, 	-- camera y position
			13.779031, 		-- camera d position
			0.146435, 		-- camera b position
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
		71,
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
			cutscene_intro:cindy_playback("script/campaign/three_kingdoms_early/factions/campaign_intro_cutscenes/scenes/scene_01_gong_du.CindyScene", 0, 10);
		end,
		0
	);

	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_01");
			-- Luoyang burns, my lord! Crumbling beneath Dong Zhuo's fist! - 13 / 4
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
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_02");
			-- And what a sight it is - the beginning of the end of the Han! - 16 / 6
		end,
		9
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		15
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_03");
			-- It was the work of the tyrant - the coalition has risen to oppose him. - 21 / 7
		end,
		15.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		22.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_04");
			-- Troubling, certainly, but as the Han rips itself apart, I sense our opportunity… - 24 / 8
		end,
		23
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		31
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_05");
			-- They have not forgotten you, my lord - 10 / 3
		end,
		31.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		34.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_06");
			-- Nor should they - our adversaries are many, but our resolve is unflinching. This war shall be won by our might! - 28 / 10
		end,
		36
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		46
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_07");
			-- We must consolidate if we are to survive - the south and west may provide useful strongholds. - 24 / 8
		end,
		46.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		54.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_08");
			-- They will all know our strength in time, once we have prepared. Then we shall not be stopped. 21 / 7
		end,
		55
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		62
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_09");
			-- The time to tear down the old dynasty approaches, Gong Du - raise the yellow banner and ride to war! - 26 / 8
		end,
		62.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor();
		end,
		70.5
	);

	cutscene_intro:start();
	
end;


function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	--fix me! intro text is not in DB yet--
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_01");
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_02");
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_03");
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_04");
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_05");
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_06");
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_07");
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_08");
	cm:show_advice("3k_campaign_faction_intro_Gong_Du_Yellow_Turbans_09");
	
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
	core:trigger_event("ScriptEventGongDuMissionInitialTrigger");
end



---------------------------------------------------------------
--	Turn One Map Pins: Gong Du -- [DS]
---------------------------------------------------------------0

function turn_one_region_visibility()

	-- Reveal a number of relevant regions (and their owning factions) at the start of turn one.

	local modify_faction = cm:modify_faction("3k_main_faction_yellow_turban_anding");

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
	output("3k_main_faction_yellow_turban_anding_start.lua: Adding turn one character map pins for Gong Du's faction.");

	-- Find pinned faction leader character cqis from their faction records
	local dong_zhuo = cm:query_faction("3k_main_faction_dong_zhuo"):faction_leader():cqi();
	local han_sui = cm:query_faction("3k_main_faction_han_sui"):faction_leader():cqi();
	local ma_teng = cm:query_faction("3k_main_faction_ma_teng"):faction_leader():cqi();
	local zhang_lu = cm:query_faction("3k_main_faction_zhang_lu"):faction_leader():cqi();
	local he_yi = cm:query_faction("3k_main_faction_yellow_turban_rebels"):faction_leader():cqi();
	local gong_du = cm:query_faction("3k_main_faction_yellow_turban_anding"):faction_leader():cqi();
	local huang_shao = cm:query_faction("3k_main_faction_yellow_turban_taishan"):faction_leader():cqi();
	

	-- Create a table connecting our map_pin records with our derived character CQIs
	local map_pin_characters = 
		{
			["3k_ytr_startpos_pin_gong_du_dong_zhuo"] = dong_zhuo,
			["3k_ytr_startpos_pin_gong_du_han_sui"] = han_sui,
			["3k_ytr_startpos_pin_gong_du_ma_teng"] = ma_teng,
			["3k_ytr_startpos_pin_gong_du_zhang_lu"] = zhang_lu,
			["3k_ytr_startpos_pin_gong_du_he_yi"] = he_yi,
			["3k_ytr_startpos_pin_gong_du_gong_du"] = gong_du,
			["3k_ytr_startpos_pin_gong_du_huang_shao"] = huang_shao
		}
		
	
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();
	

	for map_pin_record_key, character_cqi in pairs(map_pin_characters) do

		local modify_character = cm:modify_character(character_cqi);

		map_pins_handler:add_character_pin(modify_character, map_pin_record_key, is_visible);
	end

end

function add_turn_one_settlement_map_pins()
	output("3k_main_faction_yellow_turban_anding_start.lua: Adding turn one settlement map pins for Gong Du's faction.");

	-- Create a table connecting our map_pin records with our region records /settlements
	local map_pin_settlements = 
		{
			["3k_startpos_pin_zhang_yan_luoyang"] = "3k_main_luoyang_capital",
			["3k_startpos_pin_zhang_yan_captive_emperor"] = "3k_main_changan_capital"
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
	output("3k_main_faction_yellow_turban_anding_start.lua: Adding End Turn Map Pin Removal Listener.");

	core:add_listener(
		"Turn One End Check",
		"FactionTurnEnd",
		
		-- Is it turn one? If so, when we end turn, carry on to the next function.
		function(context)
			output("3k_main_faction_yellow_turban_anding_start.lua: Turn one has ended.");
			return context:query_model():turn_number() == 1;
		end,

		-- Remove the scripted pins.
		function(context)
			output("3k_main_faction_yellow_turban_anding_start.lua: Removing guide map pins.");
			cm:modify_local_faction():get_map_pins_handler():remove_all_runtime_script_pins();
		end,
		false
	);
	
end;