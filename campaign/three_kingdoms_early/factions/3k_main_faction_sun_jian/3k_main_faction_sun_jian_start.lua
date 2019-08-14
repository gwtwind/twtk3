

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

		-- Remove the Jade Seal from SJ if in single player, to be re-added with the bespoke event after.
		cm:modify_faction("3k_main_faction_sun_jian"):ceo_management():remove_ceos("3k_main_ancillary_accessory_imperial_jade_seal");		
		
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
			268.48996,		-- camera x position 
			275.940002, 	-- camera y position
			13.779046, 		-- camera d position
			0.268926, 		-- camera b position
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
		68,
		function()
			start_campaign_from_intro_cutscene()
		end,
		true
	);
	
	-- cutscene_intro:set_debug(true);
	cutscene_intro:set_disable_shroud(true);
	
	cutscene_intro:action(
		function()
			cutscene_intro:cindy_playback("script/campaign/three_kingdoms_early/factions/campaign_intro_cutscenes/scenes/scene_01_sunjian.CindyScene", 0, 10);
		end,
		0
	);

	local opening_advice = intervention:new(
		"opening_advice", 														-- string name
		60, 																	-- cost
		function() opening_advice_trigger() end,								-- trigger callback
		BOOL_INTERVENTIONS_DEBUG	 											-- show debug output
	);

	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_sun_jian_01");
			-- The fire rises, my lord, and Luoyang crumbles! [13 syllables ~ 5 seconds]
		end,
		4.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		9
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_sun_jian_02");
			-- Dong Zhuo, I vow you will see justice by my hand. [12 syllables ~ 5 seconds]
		end,
		9.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		14
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_sun_jian_03");
			-- He has moved west, with the young emperor in his charge - he will leverage all the remaining Han power against us. [ 29 syllables ~ 10 seconds]
		end,
		14.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		23.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_sun_jian_04");
			-- Let him try; I have never shied away from a fight! [13 syllables ~ 5 seconds]
		end,
		24
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		30
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_sun_jian_05");
			-- Such zeal is admirable, my lord, but may I caution patience if we are to have victory? [23 syllables ~ 8 seconds]
		end,
		34.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		38.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_sun_jian_06");
			-- Perhaps… Yuan Shu can be relied upon to aid us. He has qualms with his brother, but I will take any noble friend in these dire times… [34 syllables ~ 12 seconds]
		end,
		39
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		51
	);
		
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_sun_jian_07");
			-- As Master Sun says, "the expert must seek his victory!" - I cannot throw away my shot! [22 syllables ~ 8 seconds]
		end,
		51.5
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		59.5
	);
	
	cutscene_intro:action(
		function()
			cm:show_advice("3k_campaign_faction_intro_sun_jian_08");
			-- The Tiger of Jiandong must howl once more, my lord, so that all of China may hear the call! [21 syllables ~ 7 seconds]
		end,
		60
	);

	cutscene_intro:action(
		function()
			cutscene_intro:wait_for_advisor()
		end,
		67
	);

	cutscene_intro:start();
end;


function cutscene_intro_skipped(advice_to_play)
	cm:override_ui("disable_advice_audio", true);
	
	effect.clear_advice_session_history();
	
	cm:show_advice("3k_campaign_faction_intro_sun_jian_01");
	cm:show_advice("3k_campaign_faction_intro_sun_jian_02");
	cm:show_advice("3k_campaign_faction_intro_sun_jian_03");
	cm:show_advice("3k_campaign_faction_intro_sun_jian_04");
	cm:show_advice("3k_campaign_faction_intro_sun_jian_05");
	cm:show_advice("3k_campaign_faction_intro_sun_jian_06");
	cm:show_advice("3k_campaign_faction_intro_sun_jian_07");
	cm:show_advice("3k_campaign_faction_intro_sun_jian_08");
	
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

	-- Fire the imperial seal event straight away.
	cm:trigger_incident("3k_main_faction_sun_jian", "3k_main_faction_sun_jade_seal_incident_scripted", true, true);
end


---------------------------------------------------------------
--	Turn One Region Visibility: Sun Jian
---------------------------------------------------------------

function turn_one_region_visibility()
	-- Reveal a number of relevant regions (and their owning factions) at the start of turn one.

	local modify_faction = cm:modify_faction("3k_main_faction_sun_jian");

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
	--modify_faction:make_region_seen_in_shroud("3k_main_hedong_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_hedong_resource_1");

	-- Yuan Shu 
	modify_faction:make_region_seen_in_shroud("3k_main_nanyang_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_nanyang_resource_1");

	-- Liu Biao
	modify_faction:make_region_seen_in_shroud("3k_main_xiangyang_capital");

	-- Huang Zu
	modify_faction:make_region_seen_in_shroud("3k_main_jiangxia_capital");
	
	--modify_faction:make_region_seen_in_shroud("3k_main_xiangyang_resource_1");

	-- Sun Jian
	modify_faction:make_region_seen_in_shroud("3k_main_jingzhou_capital");

	modify_faction:make_region_seen_in_shroud("3k_main_jingzhou_resource_1");

	-- He Yi
	--modify_faction:make_region_seen_in_shroud("3k_main_runan_capital");

	--modify_faction:make_region_seen_in_shroud("3k_main_runan_resource_1");

end


---------------------------------------------------------------
--	Turn One Map Pins: Sun Jian -- [DS]
---------------------------------------------------------------0

function add_turn_one_character_map_pins()
	output("3k_main_faction_sun_jian_start.lua: Adding turn one character map pins for Sun Jian's faction.");
	

	-- Find pinned faction leader character cqis from their faction records
	local dong_zhuo = cm:query_faction("3k_main_faction_dong_zhuo"):faction_leader():cqi();
	local liu_biao = cm:query_faction("3k_main_faction_liu_biao"):faction_leader():cqi();
	local sun_jian = cm:query_faction("3k_main_faction_sun_jian"):faction_leader():cqi();
	local yuan_shu = cm:query_faction("3k_main_faction_yuan_shu"):faction_leader():cqi();
	local he_yi = cm:query_faction("3k_main_faction_yellow_turban_rebels"):faction_leader():cqi();
	local gong_du = cm:query_faction("3k_main_faction_yellow_turban_anding"):faction_leader():cqi();
	local huang_shao = cm:query_faction("3k_main_faction_yellow_turban_taishan"):faction_leader():cqi();


	-- Create a table connecting our map_pin records with our derived character CQIs
	local map_pin_characters = 
		{
			["3k_startpos_pin_sun_jian_dong_zhuo"] = dong_zhuo,
			["3k_startpos_pin_sun_jian_liu_biao"] = liu_biao,
			["3k_startpos_pin_sun_jian_sun_jian"] = sun_jian,
			["3k_startpos_pin_sun_jian_yuan_shu"] = yuan_shu,
			["3k_startpos_pin_sun_jian_yellow_turbans_he_yi"] = he_yi
		--	["3k_startpos_pin_sun_jian_yellow_turbans_gong_du"] = gong_du,
		--	["3k_startpos_pin_sun_jian_yellow_turbans_huang_shao"] = huang_shao
		}
		
	
	local is_visible = true;
	local map_pins_handler = cm:modify_local_faction():get_map_pins_handler();
	

	for map_pin_record_key, character_cqi in pairs(map_pin_characters) do

		local modify_character = cm:modify_character(character_cqi);

		map_pins_handler:add_character_pin(modify_character, map_pin_record_key, is_visible);
	end

end

function add_turn_one_settlement_map_pins()
	output("3k_main_faction_sun_jian_start.lua: Adding turn one settlement map pins for Sun Jian's faction.");

	-- Create a table connecting our map_pin records with our region records /settlements
	local map_pin_settlements = 
		{
			["3k_startpos_pin_sun_jian_luoyang"] = "3k_main_luoyang_capital",
			["3k_startpos_pin_sun_jian_captive_emperor"] = "3k_main_changan_capital"
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
	output("3k_main_faction_sun_jian_start.lua: Adding End Turn Map Pin Removal Listener.");

	core:add_listener(
		"Turn One End Check",
		"FactionTurnEnd",
		
		-- Is it turn one? If so, when we end turn, carry on to the next function.
		function(context)
			output("3k_main_faction_sun_jian_start.lua: Turn one has ended.");
			return context:query_model():turn_number() == 1;
		end,

		-- Remove the scripted pins.
		function(context)
			output("3k_main_faction_sun_jian_start.lua: Removing guide map pins.");
			cm:modify_local_faction():get_map_pins_handler():remove_all_runtime_script_pins();
		end,
		false
	);
	
end;



---------------------------------------------------------------
--	Sun Jian's Duel of Heroes -- [DS]
---------------------------------------------------------------

-- Listeners

function sun_jian_register_duel_heroism_listener()
	output("3k_main_faction_sun_jian_start.lua: Adding Duel Heroism Listener.");

	-- Did a duel take place in a battle?
	core:add_listener(
		"Post-battle Duel Check",
		"CampaignBattleLoggedEvent",
		true,
		function(context)
			output("3k_main_faction_sun_jian_start.lua: We've had a battle. Events were logged.");
			local duels = context:log_entry():duels();
			
			if not duels:is_empty() then -- Don't parse if empty.
				for i = 0, duels:num_items() - 1 do -- Always subtract 1 from the length when starting enumeration from 0 on a list.
					local duel = duels:item_at(i)
					output("3k_main_faction_sun_jian_start.lua: A duel happened...");
								
					if duel:has_winner() and duel:winner():is_faction_leader() and duel:winner():faction()=="3k_main_faction_sun_jian" then
						output("3k_main_faction_sun_jian_start.lua: ...and Sun Jian was the winner!");
						
						sun_jian_apply_duel_heroism_effect(context);
					end;
				end;
			end;	
		end,
		true
	);
	
end;


-- Effects

function sun_jian_apply_duel_heroism_effect(context)
	local heroism = 5;
	local query_faction = cm:query_faction("3k_main_faction_sun_jian");
	local query_resource_heroism = query_faction:pooled_resources():resource("3k_main_pooled_resource_heroism");
	
	if query_faction:is_null_interface() then
		script_error("3k_main_faction_sun_jian_start.lua: Cannot find faction.");
	end;

	if query_resource_heroism:is_null_interface() then
		script_error("3k_main_faction_sun_jian_start.lua: Cannot find heroism resource.");
	end;

	cm:modify_model():get_modify_pooled_resource(query_resource_heroism):apply_transaction_to_factor("3k_main_pooled_factor_heroism_from_military_feats", heroism);
	
	output("3k_main_faction_sun_jian_start.lua: Adding "..heroism.." Heroism Points to Sun Jian's faction.");

end

