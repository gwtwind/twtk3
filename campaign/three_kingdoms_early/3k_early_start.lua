-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CAMPAIGN SCRIPT
--	This file gets loaded before any of the faction scripts
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


-- require a file in the factions subfolder that matches the name of our local faction. The model will be set up by the time
-- the ui is created, so we wait until this event to query who the local faction is. This is why we defer loading of our
-- faction scripts until this time.

-------------------------------------------------------
--	load in faction scripts when the game is created
-------------------------------------------------------
output("3k_early_start.lua :: Loaded");

-- remove this (speak to Steve V first)
cm:set_check_callback_frequency(true);

cm:add_pre_first_tick_callback(
	function()	
		local local_faction = cm:get_local_faction(true);
		
		-- only load faction scripts if we have a local faction
		if not local_faction then
			return;
		end;
		
		output("game_created_callback() called. Player is faction " .. local_faction);
			
		-- if the tweaker to force the campaign prelude is set, then set the sbool value as if the tickbox had been ticked on the frontend
		if effect.tweaker_value("FORCE_FULL_CAMPAIGN_PRELUDE") ~= "0" then
			core:svr_save_bool("sbool_campaign_includes_prelude_intro", true);
		end;
		
		-- if the tweaker to force the campaign prelude to the main section is set, then set the corresponding savegame value
		if effect.tweaker_value("FORCE_CAMPAIGN_PRELUDE_TO_SECOND_PART") ~= "0" then
			cm:set_saved_value("bool_first_turn_intro_completed", true);
		end;
		
		-- load the faction scripts
		-- loads the file in script/campaigns/<campaign_name>/factions/<faction_name>/<faction_name>_start.lua
		cm:load_local_faction_scripts("_start");
	end
);

-------------------------------------------------------
--	functions to call when the first tick occurs
-------------------------------------------------------

cm:add_first_tick_callback_new(function() start_new_game_all_factions() end);
cm:add_first_tick_callback(function() start_game_all_factions() end);


-- Called when a new campaign game is started.
-- Put things here that need to be initialised only once, at the start 
-- of the first turn, but for all factions
-- This is run before start_game_all_factions()
function start_new_game_all_factions()
	output("start_new_game_all_factions() called");
	
	inc_tab();
	
	setup_3k_campaign_new();

	-- Add the imperial seal to Sun Jian's faction IF no player is Sun Jian (Sun Jian's faction script adds this in an event).
	local modify_faction = cm:modify_faction("3k_main_faction_sun_jian");
	if not modify_faction:query_faction():is_human() then
		modify_faction:ceo_management():add_ceo( "3k_main_ancillary_accessory_imperial_jade_seal" );
	end;
	
	--Give random ancillaries to starting factions.
	ancillaries:new_game_faction_starting_ancillaries();

	
	-- applies default diplomatic restrictions (not related to gating)
	-- this function may be found in 3k_campaign_default_diplomacy.lua
	campaign_default_diplomacy_start_new_game();

	dec_tab();
end;


-- Called whenever the game starts over multiple sessions.
-- Useful for systems with listeners or which already hold their own states.
function start_game_all_factions()
	output("start_game_all_factions() called");
	
	inc_tab();
	
	setup_3k_campaign();

	campaign_default_diplomacy_start_any_game();

	-- Custom modules here!
	campaign_experience:setup_experience_triggers();
	faction_council:initialise();
	ancillaries:initialise();
	master_craftsmen:initialise();
	ancillaries_ambient_spawning:initialise();
	man_of_the_hour:initialise();
	traits:initialise();
	progression:initialise();
	endgame:initialise();
	yt_ancillaries:initialise();
	yt_traits:initialise();
	yellow_turban_assignments:initialise();
	yt_emperor_ascension:initialise();
	character_relationships:initialise();
	commentary_events:initialise();
	cdir_events_manager:initialise();
	campaign_tutorial:initialise();

	dec_tab();
end


---------------------------------------------------------------
--	Called by each faction script after intro cutscene
---------------------------------------------------------------

function start_campaign_from_intro_cutscene_shared(suppress_startup_missions)
	
	-- Took out "chapter_mission_key," of the function above because chapter objectives are disabled 
	--cm:trigger_custom_mission(cm:get_local_faction(), chapter_mission_key);

	-- trigger tutorial missions unless we've been told not to

	-- core:trigger_event("ScriptEventStartProgressionMissions");

	if not suppress_startup_missions then
		core:trigger_event("ScriptEventStartTutorialMissions");
	end;
	
	-- start advice interventions
	start_global_interventions();
end;
