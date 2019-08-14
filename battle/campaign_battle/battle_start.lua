-- CAMPAIGN BATTLE - DEFAULT_BATTLE

load_script_libraries();
bm = battle_manager:new(empire_battle:new());

local file_name, file_path = get_file_name_and_path();

package.path = file_path .. "/?.lua;" .. package.path;

bm:set_close_queue_advice(false);
bm:out("");
bm:out("********************************************************************");
bm:out("********************************************************************");
bm:out("*** Campaign battle script file loaded");
bm:out("********************************************************************");
bm:out("********************************************************************");
bm:out("");


-- Show battle objectives.
if effect.get_advice_level() >= 2 then
	require("default_battle_objectives");
end;

-- Campaign Battle Tutorial
local battle_type = effect.get_context_string_value("CcoBattleRoot", "BattleTypeState");

-- Check if the Tutorial battle will fire. Mirrors the 3k_campaign_tutorial.lua
if ( battle_type == "land_normal" -- Only for land battles
	and not effect.get_advice_history_string_seen("scripted_campaign_campaign_tutorial_completed") -- If we've completed the entire tutorial, then don't fire, to prevent possible leaks
	and effect.get_advice_history_string_seen("scripted_campaign_campaign_tutorial_should_fight_tutorial") -- Enabled if the campaign tutorial has allowed the battle
	and not effect.get_advice_history_string_seen("has_played_tutorial_battle") -- If we've played the tutorial battle ever, then don't fire
	and effect.get_advice_level() >= 2 -- Enabled if advice is >= 2
	and not bm:is_multiplayer() -- disabled in multiplayer
	) 
	or core:is_tweaker_set("enable_experimental_lua") 
	then
		

	bm:out("* Loading tutorial");

	require("3k_campaign_battle_tutorial");


else
	

	bm:out("* Not loading tutorial");

	-- We don't want advice in the tutorial battle.
	bm:out("Loading advisor for campaign battle.");
	require("3k_battle_advice");
	battle_advice_system:register_campaign_battle();


end;


require("3k_battle_mod_loader");