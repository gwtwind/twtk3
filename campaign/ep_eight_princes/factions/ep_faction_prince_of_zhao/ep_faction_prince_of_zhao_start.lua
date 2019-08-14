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
	output("campaign script loaded for " .. cm:get_local_faction());
end
---------------------------------------------------------------
--	First-Tick callbacks
---------------------------------------------------------------

cm:add_first_tick_callback_sp_new(
	function() 
		-- put faction-specific calls that should only gets triggered in a new singleplayer game here
		output("New SP Game Events Fired for " .. cm:get_local_faction());
		
		cm:start_intro_cutscene_on_loading_screen_dismissed(
			function()

				cm:show_benchmark_if_required(
					function()						
						cutscene_intro_play()
					end,																					-- function to call if not in benchmark mode
					"script/benchmarks/campaign_benchmark/scenes/main.CindyScene", 							-- benchmark cindy scene
					90.00,																					-- duration of cindy scene
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
		66,
		function()
			start_campaign_from_intro_cutscene()
		end,
		true
	);
	
	--cutscene_intro:set_debug(true)
	cutscene_intro:set_disable_shroud(true);
	
	cutscene_intro:action(
		function()
			cutscene_intro:cindy_playback("script/campaign/ep_eight_princes/factions/campaign_intro_cutscenes/scenes/scene_01_sima_lun.CindyScene", 0, 10);
		end,
		0
	);
	
	cutscene_intro:add_cinematic_trigger_listener(
		"line_lun_01", 
		function()
			cm:show_advice("ep_campaign_faction_intro_sima_lun_01_advisor");
		end
	);
	
	cutscene_intro:add_cinematic_trigger_listener(
		"line_lun_02", 
		function()
			cm:show_advice("ep_campaign_faction_intro_sima_lun_02_sima_lun");
		end	
	);
	
	cutscene_intro:add_cinematic_trigger_listener(
		"line_lun_03", 
		function()
			cm:show_advice("ep_campaign_faction_intro_sima_lun_03_advisor");
		end	
	);
	
	cutscene_intro:add_cinematic_trigger_listener(
		"line_lun_04", 
		function()
			cm:show_advice("ep_campaign_faction_intro_sima_lun_04_sima_lun");
		end	
	);
	
	cutscene_intro:add_cinematic_trigger_listener(
		"line_lun_05", 
		function()
			cm:show_advice("ep_campaign_faction_intro_sima_lun_05_advisor");
		end	
	);
	
	cutscene_intro:add_cinematic_trigger_listener(
		"line_lun_06", 
		function()
			cm:show_advice("ep_campaign_faction_intro_sima_lun_06_advisor");
		end	
	);
	
	cutscene_intro:add_cinematic_trigger_listener(
		"line_lun_07", 
		function()
			cm:show_advice("ep_campaign_faction_intro_sima_lun_07_sima_lun");
		end	
	);
	
	cutscene_intro:add_cinematic_trigger_listener(
		"line_lun_08", 
		function()
			cm:show_advice("ep_campaign_faction_intro_sima_lun_08_advisor");
		end	
	);
	
	cutscene_intro:start();
end;

function cutscene_intro_skipped(advice_to_play)
end;

---------------------------------------------------------------
--	Start of Gameplay
---------------------------------------------------------------

function start_campaign_from_intro_cutscene()
	-- call shared startup function in 3k_early_start.lua
	add_turn_one_character_map_pins();
	add_turn_one_settlement_map_pins();
	end_turn_map_pin_removal_listener();
	turn_one_region_visibility();
end


---------------------------------------------------------------
--	Turn One Region Visibility: Sima Lun
---------------------------------------------------------------

function turn_one_region_visibility()

	-- Reveal a number of relevant regions (and their owning factions) at the start of turn one.

	local modify_faction = cm:modify_faction("ep_faction_prince_of_zhao");

	if not modify_faction then
		script_error("Error no faction found");
		return;
	end;

	-- Luoyang
	modify_faction:make_region_visible_in_shroud("3k_main_luoyang_capital");
  modify_faction:make_region_seen_in_shroud("3k_main_shangyong_capital");
  modify_faction:make_region_seen_in_shroud("3k_main_shangdang_capital");
  modify_faction:make_region_seen_in_shroud("3k_main_shangdang_resource_1");
  modify_faction:make_region_seen_in_shroud("3k_main_luoyang_resource_1");
  modify_faction:make_region_seen_in_shroud("3k_main_taiyuan_resource_2");
end



---------------------------------------------------------------
--	Turn One Map Pins: Sima Lun -- [DS]
---------------------------------------------------------------

function add_turn_one_character_map_pins()
	output("ep_faction_prince_of_zhao_start.lua: Adding turn one character map pins for Sima Lun's faction.");

	-- Find pinned faction leader character cqis from their faction records
	local sima_wei = cm:query_faction("ep_faction_prince_of_chu"):faction_leader():cqi();
	local sima_lun = cm:query_faction("ep_faction_prince_of_zhao"):faction_leader():cqi();
 
  
	-- Create a table connecting our map_pin records with our derived character CQIs
	local map_pin_characters = 
		{
			["ep_startpos_pin_sima_lun_sima_wei"] = sima_wei,
			["ep_startpos_pin_sima_lun_sima_lun"] = sima_lun
    }
		
	
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();
	

	for map_pin_record_key, character_cqi in pairs(map_pin_characters) do

		local modify_character = cm:modify_character(character_cqi);

		map_pins_handler:add_character_pin(modify_character, map_pin_record_key, is_visible);
	end

end

function add_turn_one_settlement_map_pins()
	output("ep_faction_prince_of_zhao.lua: Adding turn one settlement map pins for Sima Lun's faction.");

	-- Create a table connecting our map_pin records with our region records /settlements
	local map_pin_settlements = 
		{
			["ep_startpos_pin_sima_lun_jin_empire"] = "3k_main_luoyang_capital",
      ["ep_startpos_pin_sima_wei_wei_guan"] = "3k_main_shangdang_resource_1"
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
	output("ep_faction_prince_of_zhao_start.lua: Adding End Turn Map Pin Removal Listener.");

	core:add_listener(
		"Turn One End Check",
		"FactionTurnEnd",
		
		-- Is it turn one? If so, when we end turn, carry on to the next function.
		function(context)
			output("ep_faction_prince_of_zhao_start.lua: Turn one has ended.");
			return context:query_model():turn_number() == 1;
		end,

		-- Remove the scripted pins.
		function(context)
			output("ep_faction_prince_of_zhao_start.lua: Removing guide map pins.");
			cm:modify_local_faction():get_map_pins_handler():remove_all_runtime_script_pins();
		end,
		false
	);
	
end;