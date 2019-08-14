

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	ADVICE SCRIPTS
--	Battle advice trigger declarations go here
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

out.advice("********************************************************************");
out.advice("*** loading advice scripts");
out.advice("********************************************************************");
out.advice("");

-----------------------------------------------------------------------------------
-- CONFIGURATION
-----------------------------------------------------------------------------------
local is_debug = true;
local ignore_advice_history = false;
local use_advice_history = true;

-- create an advice manager
am = advice_manager:new(is_debug, ignore_advice_history);

bm:out("### Starting 3K Battle advisor - see the Lua - Advice tab for more output ###");

require("3k_battle_advice_phases");
require("3k_battle_advice_chains");
require("3k_battle_advice_timing_manager");
require("3k_battle_advice_logger");
require("3k_battle_advice_unit_manager");

battleAdviceLogger:initialise(is_debug);
adviceChains:initialise(use_advice_history);
advicePhases:initialise(use_advice_history);

battle_advice_system = {
	conflict_phase_started = false,
	running_in_E3_mode = false,
	player_victory = false;
	player_defeat = false;
	battle_started = false;
	is_campaign_battle = false;
	intro_advice_complete = false;
};



-- [[ Listener Functions ]]
--------------------------------------------------------------------------------------------------------
function battle_advice_system:initialiseConflictPhaseListener()
	core:add_listener(
				"BattleAdvisor_ConflictPhaseListener",
				"ScriptEventConflictPhaseBeginsForAdvice",
				true,
				function() 
					battle_advice_system.conflict_phase_started = true

					-- adding timers for timed advice
					timing_manager:startTimer("3k_battle_advice_flanking_1");
					timing_manager:startTimer("3k_battle_advice_commanders_1");
				end,
				false
			);
end

battle_advice_system:initialiseConflictPhaseListener();

function battle_advice_system:initialiseResultCallbackFunctions() 

	bm:register_results_callbacks(
	-- victory callback	
	function()
		self.player_victory = true;
	end, 
	-- defeat callback
	function()
		self.player_defeat = true;	
	end);

end

battle_advice_system:initialiseResultCallbackFunctions();

function battle_advice_system:initialiseIntroductionAdviceListener()
	core:add_listener(
		"BattleAdvisor_IntroAdviceListener",
		"ScriptEventIntroAdviceComplete",
		true,
		function ()
			battle_advice_system.intro_advice_complete = true;
		end,
		false
	);
end

battle_advice_system:initialiseIntroductionAdviceListener();

-- [[ Auxiliary Functions ]]
--------------------------------------------------------------------------------------------------------

-- We use this function to determine whether or not the battle is a campaign battle. 
-- Reason is in these cases we need a separate triggering for when advice is allowed to start playing. 
function battle_advice_system:register_campaign_battle()

	battle_advice_system.is_campaign_battle = true;

	core:add_listener(
		"BattleAdvisor_LoadingScreenDismissedEvent",
		"ScriptEventLoadingScreenDismissedForAdvice",
		true,
		function() 
			battle_advice_system.battle_started = true;
			battleAdviceLogger:log("Loading screen dismissed event, setting battle started true.");
		end,
		false
	);

end

function battle_advice_system:advice_allowed_to_start()

	if (battle_advice_system.is_campaign_battle) then 
		return battle_advice_system.battle_started;
	else
		return true;
	end

end

function battle_advice_system:advice_allowed_to_start_and_never_triggered(key)

	if (not battle_advice_system:advice_allowed_to_start()) then 
		return false;
	end

	if advicePhases:hasAdviceTriggered(key) == true then 
		return false;
	end

	return true;

end


function battle_advice_system:stop_advice_queue_and_play_advice(advice_monitor)

	-- stop the advice monitor's trigger monitors
	advice_monitor:stop_trigger_listeners();

	-- stop advisor queue
	bm:stop_advisor_queue(true);

	-- play our advice

	bm:queue_advisor(
		advice_monitor.advice_key,  -- string
		5000, -- duration
		false,  -- is debug
		function() -- callback
			-- clear infotext
			local infotext_manager = get_infotext_manager();
			infotext_manager:clear_infotext();
			
			-- show infotext
			if advice_monitor.infotext then
				infotext_manager:add_infotext(unpack(advice_monitor.infotext));
			end;
		end, -- callback end
		0, -- callback offset
		0, -- advice offset
		0, -- condition
		advice_monitor.location,-- location
		advice_monitor.context_object -- context object
	);

end 

function battle_advice_system:setAdvicePlayed(advice_key, advice_is_part_of_chain) 
	battleAdviceLogger:log("[INFO] Setting advice " .. advice_key .. " to played.");
	advicePhases:setAdviceTriggered(advice_key, true);
	if (advice_is_part_of_chain) then 
		adviceChains:setAdviceTriggered(advice_key);
	end
end 

function battle_advice_system:highlight_unit_and_set_advice_context_object(advice_monitor, unit, objective_key, wait_time)
	
	if (unit == nil) then 
		script_error("[ERROR] >>> Tried to highlight a unit that was not found before. Not doing anything.");
		return 
	end

	local context_id_string = "CcoBattleUnit" .. unit:unique_ui_id();
	battleAdviceLogger:log("[INFO] Adding context to advice: " .. context_id_string);
	advice_monitor:add_context_object(context_id_string);
	local script_unit = unit_manager:getScriptUnitController(unit);
	script_unit.uc:highlight(true);
	script_unit:highlight_unit_card(true, 1, true);

	battle_advice_system:callback(
		function()
			script_unit.uc:highlight(false); 
			script_unit:highlight_unit_card(false, 1, false);
		end, 
		wait_time, new_entryname);

end 

function battle_advice_system:highlightAllInfantryUnits(wait_time) 

	local player_units = unit_manager:getAllUnits();
	for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_infantry() == true) then
            local script_unit = unit_manager:getScriptUnitController(current_unit);
			script_unit.uc:highlight(true);
			script_unit:highlight_unit_card(true, 1, true);
        end
    end

	battle_advice_system:callback(
		function()
			local player_units = unit_manager:getAllUnits();
			for i = 1, player_units:count() do
				local current_unit = player_units:item(i);
				local script_unit = unit_manager:getScriptUnitController(current_unit);
				script_unit.uc:highlight(false);
				script_unit:highlight_unit_card(false, 1, false);
    		end
		end, 
		wait_time, new_entryname);
end 

function battle_advice_system:add_victory_point_context_object(advice_monitor, wait_time) 

	if not bm:is_siege_battle() then
		battleAdviceLogger:log("[WARNING] battle_advice_system:add_victory_point_context_object(): Trying to get victory point context object in a non-siege battle.");
		return;
	end

	local object_id = effect.get_context_object_id("CcoBattleRoot", "VictoryCapturePointContext");

	if object_id then
		battleAdviceLogger:log("[INFO] battle_advice_system:add_victory_point_context_object(): Setting advice context object: " .. tostring(object_id));
		advice_monitor:add_context_object(object_id);
	else
		script_error("add_victory_point_context_object() Not adding as there is not VictoryCapturePointContext. Advice Monitor [" .. tostring(advice_monitor.name) .. "]");
	end;

end

function battle_advice_system:basicDeploymentChainSetComplete() 

    adviceChains:setAdviceTriggered("3k_battle_advice_deployment_1");
	adviceChains:setAdviceTriggered("3k_battle_advice_deployment_2");
	advicePhases:setAdviceTriggered("3k_battle_advice_deployment_1", true);
	advicePhases:setAdviceTriggered("3k_battle_advice_deployment_2", true);

end

function battle_advice_system:player_units_within_capture_point_proximity(distance) 

	local minimum_distance = unit_manager:get_minimum_distance_to_capture_point();
	battleAdviceLogger:log("[INFO] battle_advice_system:player_units_within_capture_point_proximity(distance): Current minimum distance = " .. minimum_distance);

	return unit_manager:get_minimum_distance_to_capture_point() < distance;

end

function battle_advice_system:hasBattleIntroductionPlayed() 

	local battle_introduction_played = false;

	if bm:is_siege_battle() then 
		-- check for siege introduction 
		battle_introduction_played = advicePhases:hasAdviceTriggered("3k_battle_advice_deployment_siege_attack_1");
	else 
		if bm:is_land_ambush() then 
			-- check for land ambush introduction
			battle_introduction_played = advicePhases:hasAdviceTriggered("3k_battle_advice_ambush_defence_extraction_1");
		else
			-- other cases
			battle_introduction_played = advicePhases:hasAdviceTriggered("3k_battle_advice_deployment_1");
		end
	end

end

function battle_advice_system:callback(callback, duration_ms) 
	local start_time_s = os.clock();
	local desired_end_time_s = start_time_s + (duration_ms / 1000);
	
	-- internal test to see if the desired duration has actually elapsed
	local function duration_elapsed()
		if os.clock() >= desired_end_time_s then
			return true;
		end;
		return false;
	end;
	
	-- set up a callback for the desired duration
	bm:callback(
		function()
			-- see if the duration has actually elapsed after the desired duration has passed in script time
			if duration_elapsed() then
				callback();
			else
				-- if the desired duration has not elapsed, poll the os clock every 200ms and call the callback when it has
				local function repeat_duration_elapsed_test()
					bm:callback(
						function()
							if duration_elapsed() then
								callback();
							else
								repeat_duration_elapsed_test()
							end;
						end,
						200
					);
				end;
				
				repeat_duration_elapsed_test()
			end;
		end,
		duration_ms
	);
end

-- [[ Advice List ]]
--------------------------------------------------------------------------------------------------------
-- DEPLOYMENTY 1
-- 3k_battle_advice_deployment_1
advice_deployment_1 = advice_monitor:new(
	"3k_battle_advice_deployment_1",
	100,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_1",
	{
		"3k_battle_advice_deployment_5_functional"
	},
	60000
);

advice_deployment_1:set_advice_level(2);

advice_deployment_1:add_halt_condition(true, "ScriptEventConflictPhaseBeginsForAdvice");

advice_deployment_1:set_halt_callback(
	function() 
		battle_advice_system:basicDeploymentChainSetComplete();
	end
);

advice_deployment_1:add_trigger_condition(
	function()
		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_1") then 
			return false;
		end

		if bm:is_land_ambush() then 
			return false;
		end

		return true;
	end
);

advice_deployment_1:set_trigger_callback(
	function() 
		battle_advice_system:setAdvicePlayed("3k_battle_advice_deployment_1", true);
		timing_manager:startTimer("3k_battle_advice_deployment_2");
		core:trigger_event("ScriptEventIntroAdviceComplete");
	end
); 

--------------------------------------------------------------------------------------------------------
-- DEPLOYMENT 2
-- 3k_battle_advice_deployment_2
advice_deployment_2 = advice_monitor:new(
	"3k_battle_advice_deployment_2",
	1,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_2",
	{
		"3k_battle_advice_deployment_6_functional"
	},
	60000
);

advice_deployment_2:set_advice_level(2);

advice_deployment_2:add_halt_condition(true, "ScriptEventConflictPhaseBeginsForAdvice");

advice_deployment_2:set_halt_callback(
	function() 
		battle_advice_system:basicDeploymentChainSetComplete();
	end
);

advice_deployment_2:add_trigger_condition(
	function(context)
		
		if context.string == "3k_battle_advice_deployment_1" then
			return true;
		else
			return false;
		end

	end,
	"ScriptEventAdviceDismissed"
);

advice_deployment_2:add_trigger_condition(
	function(context)
				
		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_2") then 
			return false;
		end

		if bm:is_land_ambush() then 
			return false;
 		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_1");
		if (advice_score >= 1) then 
			return true;
		end

	end
);

advice_deployment_2:set_trigger_callback(
	function() 
		battle_advice_system:setAdvicePlayed("3k_battle_advice_deployment_2", true);
	end
); 

--------------------------------------------------------------------------------------------------------
-- DEPLOYMENT 3
-- 3k_battle_advice_deployment_3
advice_deployment_3 = advice_monitor:new(
	"3k_battle_advice_deployment_3",
	1,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_3",
	{
		"3k_battle_advice_deployment_3_functional"
	},
	60000
);

advice_deployment_3:set_advice_level(2);

-- Only want to trigger this in a normal land battle
advice_deployment_3:add_trigger_condition(
	function (context)

		if context.string == "3k_battle_advice_deployment_2" then
			return true;
		else
			return false;
		end

	end,

	"ScriptEventAdviceDismissed"
);

advice_deployment_3:add_trigger_condition(
	function(context)
				
		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_3") then 
			return false;
		end

		if bm:is_land_ambush() then 
			return false;
 		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_2");
		if (advice_score >= 1) then 
			return true;
		end

	end
);


advice_deployment_3:set_trigger_callback(
	function() 
		battle_advice_system:setAdvicePlayed("3k_battle_advice_deployment_3", true);
	end
); 


--------------------------------------------------------------------------------------------------------
-- SIEGE ATTACK 1
-- 3k_battle_advice_deployment_siege_attack_1
advice_siege_attack_1 = advice_monitor:new(
	"3k_battle_advice_deployment_siege_attack_1",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_siege_attack_1",
	{
		"3k_battle_advice_deployment_siege_attack_1_functional"
	},
	30000
);

advice_siege_attack_1:set_advice_level(2);

advice_siege_attack_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_siege_attack_1") then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start() then 
			return false;
		end

		if bm:is_siege_battle() and bm:player_is_attacker() then
			local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_3");
			if (advice_score > 0) and not (battle_type == "settlement_unfortified") then 
				return true;
			end
		end

	end 
);

advice_siege_attack_1:add_trigger_condition(
	function(context)

		if not bm:is_siege_battle() then
			return false;
		end

		if not bm:player_is_attacker() then 
			return false;
		end
				
		if context.string == "3k_battle_advice_deployment_3" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

advice_siege_attack_1:set_trigger_callback(
	function()
		battle_advice_system:setAdvicePlayed("3k_battle_advice_deployment_siege_attack_1", false);
	end
);

--------------------------------------------------------------------------------------------------------
-- SIEGE DEFENCE 1
-- 3k_battle_advice_deployment_siege_attack_1
advice_siege_defence_1 = advice_monitor:new(
	"3k_battle_advice_deployment_siege_defence_1",
	100,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_siege_defence_1",
	{
		"3k_battle_advice_deployment_siege_defence_1_functional"
	},
	30000
);

advice_siege_defence_1:set_advice_level(2);

advice_siege_defence_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_siege_defence_1") then 
			return false;
		end

		if bm:is_siege_battle() and not bm:player_is_attacker() then
			local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_3");
			if (advice_score > 0) then 
				return true;
			end
		end

	end 
);

advice_siege_defence_1:add_trigger_condition(
	function(context)

		if not bm:is_siege_battle() then
			return false;
		end

		if bm:player_is_attacker() then 
			return false;
		end
		
		if context.string == "3k_battle_advice_deployment_3" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

advice_siege_defence_1:set_trigger_callback(
	function()
		battle_advice_system:setAdvicePlayed("3k_battle_advice_deployment_siege_defence_1", false);
	end
);

--------------------------------------------------------------------------------------------------------
-- CAPTURE POINT ATTACK 1
-- 3k_battle_advice_capture_point_attack_1
capture_point_attack_1 = advice_monitor:new(
	"3k_battle_advice_capture_point_attack_1",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_capture_point_attack_1",
	{
		"3k_battle_advice_capture_point_attack_1_functional"
	},
	30000
);

capture_point_attack_1:set_advice_level(2);

capture_point_attack_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_capture_point_attack_1") then 
			return false;
		end 

		if not bm:is_siege_battle() then
			return false;
		end

		if not bm:player_is_attacker() then
			return false;
		end

		if not battle_advice_system:player_units_within_capture_point_proximity(280) then 
			return false;
		end

		return true;

	end
);

capture_point_attack_1:set_trigger_callback(
	function()
		battle_advice_system:add_victory_point_context_object(capture_point_attack_1);
		battle_advice_system:stop_advice_queue_and_play_advice(capture_point_attack_1);
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- CAPTURE POINT ATTACK 2
-- 3k_battle_advice_capture_point_attack_2
capture_point_attack_2 = advice_monitor:new(
	"3k_battle_advice_capture_point_attack_2",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_capture_point_attack_2",
	{
		"3k_battle_advice_capture_point_attack_2_functional"
	},
	30000
);

capture_point_attack_2:set_advice_level(2);

capture_point_attack_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_capture_point_attack_2") then 
			return false;
		end 

		if not bm:is_siege_battle() then
			return false;
		end

		if (not bm:player_is_attacker()) then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_capture_point_attack_1");
		if (advice_score > 0) then 
			return true;
		end


	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

capture_point_attack_2:add_trigger_condition(
	function(context)
				
		if context.string == "3k_battle_advice_capture_point_attack_1" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

capture_point_attack_2:set_trigger_callback(
	function()
		battle_advice_system:add_victory_point_context_object(capture_point_attack_2);
		battle_advice_system:stop_advice_queue_and_play_advice(capture_point_attack_2);
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- CAPTURE POINT DEFEND 1
-- 3k_battle_advice_capture_point_defend_1
capture_point_defend_1 = advice_monitor:new(
	"3k_battle_advice_capture_point_defend_1",
	40,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_capture_point_defend_1",
	{
		"3k_battle_advice_capture_point_defend_1_functional"
	},
	30000
);

capture_point_defend_1:set_advice_level(2);

capture_point_defend_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_capture_point_defend_1") then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start() then 
			return false;
		end

		if bm:is_siege_battle() and not bm:player_is_attacker() then
			local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_defence_1");
			if (advice_score > 0) then 
				return true;
			end
		end

	end 
);

capture_point_defend_1:add_trigger_condition(
	function(context)

		if not bm:is_siege_battle() then
			return false;
		end

		if bm:player_is_attacker() then 
			return false;
		end
		
		if context.string == "3k_battle_advice_deployment_siege_defence_1" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

capture_point_defend_1:set_trigger_callback(
	function()
		battle_advice_system:add_victory_point_context_object(capture_point_defend_1);
		battle_advice_system:stop_advice_queue_and_play_advice(capture_point_defend_1);
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- DEPLOYMENT END General Advice: 
-- You can access previous advice messages on demand. Press Advice History in the ESC menu.
-- 3k_battle_advice_deployment_end_1
deployment_end_1 = advice_monitor:new(
	"3k_battle_advice_deployment_end_1",
	10,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_end_1",
	{
		"3k_battle_advice_deployment_7_functional"
	},
	30000
);

deployment_end_1:set_advice_level(1);

deployment_end_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_end_1") then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start() then 
			return false;
		end

		if bm:is_siege_battle() and not bm:player_is_attacker() then
			local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_2");
			if (advice_score > 0) then 
				return true;
			end
		end

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

deployment_end_1:set_trigger_callback(
	function()
		battle_advice_system:setAdvicePlayed("3k_battle_advice_deployment_end_1", false);
	end
);

--------------------------------------------------------------------------------------------------------
-- CHARGING 
-- 3k_battle_advice_charging_1
charging_1 = advice_monitor:new(
	"3k_battle_advice_charging_1",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_charging_1",
	{
		"3k_battle_advice_charging_1_functional"
	},
	30000
);

charging_1:set_advice_level(2);

charging_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_charging_1") then 
			return false;
		end 

		local charging_unit = unit_manager:getChargingUnit();
		local charged_unit = unit_manager:getChargedUnit();

		if (charged_unit == nil and charging_unit == nil) then 
			return false;
		else 
			return true;
		end

	end,
	"ScriptEventUnitCharged"
);

charging_1:set_trigger_callback(
	function()
		
		local charging_unit = unit_manager:getChargingUnit();
		local charged_unit = unit_manager:getChargedUnit();

		if (charged_unit == nil and charging_unit == nil) then 
			battleAdviceLogger:log("[ERROR] >>> Charged and charging unit null.");
			return;
		else 
			if (charged_unit == nil) then 
				battle_advice_system:highlight_unit_and_set_advice_context_object(charging_1, charging_unit, "3k_main_battle_scripted_objective_being_charged_1", 15000);
			else 
				battle_advice_system:highlight_unit_and_set_advice_context_object(charging_1, charged_unit, "3k_main_battle_scripted_objective_charging_1", 15000);
			end
		end
		battle_advice_system:stop_advice_queue_and_play_advice(charging_1);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- COMMANDERS 
-- 3k_battle_advice_commanders_1
commanders_1 = advice_monitor:new(
	"3k_battle_advice_commanders_1",
	700,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_commanders_1",
	{
		"3k_battle_advice_commanders_2_functional"
	},
	30000
);

commanders_1:set_advice_level(1);

commanders_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_commanders_1") then 
			return false;
		end 

		if (bm:is_siege_battle()) then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_3");
		if (advice_score > 0) then 
			return true;
		end

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

commanders_1:add_trigger_condition(
	function(context)

		if (bm:is_siege_battle()) then 
			return false;
		end

		if context.string == "3k_battle_advice_deployment_3" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

commanders_1:set_trigger_callback(
	function()
		local commander = unit_manager:getCommanderInAlliance();
		if (commander == nil) then 
			-- do nothing
		else 
			battle_advice_system:highlight_unit_and_set_advice_context_object(commanders_1, commander, "3k_main_battle_scripted_objective_commanders_1", 15000);
		end

		timing_manager:startTimer("3k_battle_advice_duels_1");
		battle_advice_system:setAdvicePlayed("3k_battle_advice_commanders_1", false);
		battle_advice_system:stop_advice_queue_and_play_advice(commanders_1);
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- DUELS 
-- 3k_battle_advice_duels_1
duels_1 = advice_monitor:new(
	"3k_battle_advice_duels_1",
	150,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_duels_1",
	{
		"3k_battle_advice_duels_1_functional"
	},
	30000
);

duels_1:set_advice_level(1);

duels_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_duels_1") then 
			return false;
		end 

		return true;

	end,
	"ScriptEventPendingDuel"
);

duels_1:set_trigger_callback(
	function()
		local duelist = unit_manager:getDuelist();
		if (duelist == nil) then 
			-- do nothing
		else 

			battle_advice_system:highlight_unit_and_set_advice_context_object(duels_1, duelist, "3k_main_battle_scripted_objective_duelist_1", 15000);
			battle_advice_system:stop_advice_queue_and_play_advice(duels_1);
		end
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- DUELS 
-- 3k_battle_advice_duels_2a
duels_2a = advice_monitor:new(
	"3k_battle_advice_duels_2a",
	150,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_duels_2a",
	{
		"3k_battle_advice_duels_2a_functional"
	},
	30000
);

duels_2a:set_advice_level(1);

duels_2a:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_duels_2a") then 
			return false;
		end 

		return true;

	end,
	"ScriptEventActiveDuel"
);

duels_2a:set_trigger_callback(
	function()
		local duelist = unit_manager:getActiveDuelist();
		
		if (duelist == nil) then 
			-- do nothing
		else 

			battle_advice_system:highlight_unit_and_set_advice_context_object(duels_2a, duelist, "3k_main_battle_scripted_objective_duelist_2a", 15000);
			battle_advice_system:stop_advice_queue_and_play_advice(duels_2a);
		end
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- DUELS 
-- 3k_battle_advice_duels_2b
duels_2b = advice_monitor:new(
	"3k_battle_advice_duels_2b",
	150,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_duels_2b",
	{
		"3k_battle_advice_duels_2b_functional"
	},
	30000
);

duels_2b:set_advice_level(1);

duels_2b:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_duels_2b") then 
			return false;
		end 

		-- TODO Listen for event
		return false;

	end,
	-- TODO Check different event
	"ScriptEventConflictPhaseBeginsForAdvice"
);

duels_2b:set_trigger_callback(
	function()
		local duelist = unit_manager:getCommanderInAlliance();
		-- TODO Check for hero who was challenged
		if (duelist == nil) then 
			-- do nothing
		else 
			battle_advice_system:highlight_unit_and_set_advice_context_object(duels_2b, duelist, "3k_main_battle_scripted_objective_duelist_2b", 15000);
			battle_advice_system:stop_advice_queue_and_play_advice(duels_2b);
		end
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- MORALE 
-- 3k_battle_advice_morale_1
morale_1 = advice_monitor:new(
	"3k_battle_advice_morale_1",
	100,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_morale_1",
	{
		"3k_battle_advice_morale_1_functional"
	},
	30000
);

morale_1:set_advice_level(2);

morale_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_morale_1") then 
			return false;
		end 


		return true;

	end,
	"ScriptEventPlayerUnitRouts"
);

morale_1:set_trigger_callback(
	function()
		battleAdviceLogger:log("[INFO] morale_1:set_trigger_callback(): Checking for wavering or routing unit.");
		local wavering_unit = unit_manager:getWaveringUnit();
		local routing_unit = unit_manager:getRoutingUnit();
		if (wavering_unit == nil and routing_unit == nil) then 
			battleAdviceLogger:log("[WARNING] morale_1:set_trigger_callback(): Could not find a wavering or routing unit.");
		else 
			if (routing_unit == nil) then 
				battle_advice_system:highlight_unit_and_set_advice_context_object(morale_1, wavering_unit, "3k_main_battle_scripted_objective_morale_1_wavering", 15000);
				battle_advice_system:stop_advice_queue_and_play_advice(morale_1);
			else
				battle_advice_system:highlight_unit_and_set_advice_context_object(morale_1, routing_unit, "3k_main_battle_scripted_objective_morale_1_routing", 15000);
				battle_advice_system:stop_advice_queue_and_play_advice(morale_1);
			end
			
		end
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- REINFORCEMENTS 
-- 3k_battle_advice_reinforcements_1
reinforcements_1 = advice_monitor:new(
	"3k_battle_advice_reinforcements_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_reinforcements_1",
	{
		"3k_battle_advice_reinforcements_1_functional"
	},
	30000
);

reinforcements_1:set_advice_level(2);

reinforcements_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_reinforcements_1") then 
			return false;
		end 

		-- TODO Check for reinforcements aide de camp

	end
);

reinforcements_1:set_trigger_callback(
	function()
		
		-- TODO get position of reinforcements and zoom there
		-- 3k_main_battle_scripted_objective_reinforcements_1
	end 
);

--------------------------------------------------------------------------------------------------------
-- RETINUES 
-- 3k_battle_advice_retinues_1
retinues_1 = advice_monitor:new(
	"3k_battle_advice_retinues_1",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_retinues_1",
	{
		"3k_battle_advice_retinues_1_functional"
	},
	30000
);

retinues_1:set_advice_level(1);

retinues_1:add_trigger_condition(
	function(context)
				
		if context.string == "3k_battle_advice_commanders_1" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

retinues_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_retinues_1") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_1");
		if (advice_score > 0) then 
			return true;
		else
			return false;
		end

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

retinues_1:set_trigger_callback(
	function()
		
		-- TODO get position of retinue commander?
		local uim = bm:get_battle_ui_manager();
		uim:highlight_retinue(true, 0);

		battle_advice_system:callback(
		function()
			local uim = bm:get_battle_ui_manager();
			uim:highlight_retinue(false, 0);
		end, 
		15000, new_entryname);

	end 
);

--------------------------------------------------------------------------------------------------------
-- SPECIAL ABILITIES 
-- 3k_battle_advice_special_abilities_1
special_abilities_1 = advice_monitor:new(
	"3k_battle_advice_special_abilities_1",
	500,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_special_abilities_1",
	{
		"3k_battle_advice_special_abilities_1_functional"
	},
	30000
);

special_abilities_1:set_advice_level(1);

special_abilities_1:add_trigger_condition(
	function(context)

		if bm:is_historical_mode() then 
			return false;
		end	
		
		local unit_with_special_ability = unit_manager:getUnitWithSpecialAbility();

		if (unit_with_special_ability == nil) then 
			return false;
		end 
		
		if context.string == "3k_battle_advice_commanders_1" then
			return true;
		else
			return false;
		end

	end,
	"ScriptEventAdviceDismissed"
);

special_abilities_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_special_abilities_1") then 
			return false;
		end 

		if bm:is_historical_mode() then 
			return false;
		end	
		
		local unit_with_special_ability = unit_manager:getUnitWithSpecialAbility();
		if (unit_with_special_ability == nil) then 
			return false;
		end 

		-- TODO Review this potentially
		local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_1");
		if (advice_score > 0) then 
			return false;
		end

		return true;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

special_abilities_1:set_trigger_callback(
	function()
		
		local general_with_special_ability = unit_manager:getUnitWithSpecialAbility();
		if (general_with_special_ability == nil) then 
			-- do nothing
		else 
			battle_advice_system:highlight_unit_and_set_advice_context_object(special_abilities_1, general_with_special_ability, "3k_main_battle_scripted_objective_special_abilities_1", 15000);
			battle_advice_system:stop_advice_queue_and_play_advice(special_abilities_1);
		end
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- UNIT FORMATIONS 
-- 3k_battle_advice_unit_formations_1
unit_formations_1 = advice_monitor:new(
	"3k_battle_advice_unit_formations_1",
	10,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_unit_formations_1",
	{
		"3k_battle_advice_unit_formations_3_functional"
	},
	30000
);

unit_formations_1:set_advice_level(2);

unit_formations_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_unit_formations_1") then 
			return false;
		end 

		-- TODO Check for unit with unit formations
		-- Check if unit is inside the settlement and has formation (E3 relevant), otherwise check for battle conflict phase ongoing
		unit_formations_1.formations = {"circle", "diamond", "hollowed_square", "pike_wall", "shield_wall", "spear_wall", "turtle", "wedge"};

		for index in ipairs(unit_formations_1.formations)
		do
			if (unit_manager:doesSomeUnitHaveAbility(unit_formations_1.formations[index]) == true) then 
				return true;
			end 
		end 

		return false;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice" 
);

unit_formations_1:set_trigger_callback(
	function()
		unit_formations_1.formations = {"circle", "diamond", "hollowed_square", "pike_wall", "shield_wall", "spear_wall", "turtle", "wedge"};

		for index in ipairs(formations)
		do
			local current_unit = unit_manager:getUnitWithAbility(unit_formations_1.formations[index]);
			if not (current_unit == nil) then 
				battle_advice_system:highlight_unit_and_set_advice_context_object(unit_formations_1, current_unit, "3k_main_battle_scripted_objective_unit_formations_1", 15000);
				battle_advice_system:stop_advice_queue_and_play_advice(unit_formations_1);
			end 
		end 
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- UNITS 1 - MELEE
-- 3k_battle_advice_deployment_units_1
units_melee_1 = advice_monitor:new(
	"3k_battle_advice_deployment_units_1",
	200,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_units_1",
	{
		"3k_campaign_advice_units_info_07"
	},
	30000
);

units_melee_1:set_advice_level(2);

units_melee_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_units_1") then 
			return false;
		end
		
		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_retinues_1");
		if (advice_score > 0) then 
			return true;
		end
		
	end 
);

units_melee_1:add_trigger_condition(
	function(context)
		
		if context.string == "3k_battle_advice_deployment_retinues_1" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

units_melee_1:set_trigger_callback(
	function()
		-- local melee_unit = unit_manager:get_melee_unit();
		-- if not melee_unit then 
		-- 	return 
		-- end

		-- battle_advice_system:highlight_unit_and_set_advice_context_object(units_melee_1, melee_unit, "3k_main_battle_scripted_objective_flanking_2", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(units_melee_1);
		battle_advice_system:setAdvicePlayed("3k_battle_advice_deployment_units_1");
	
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- UNITS 2 - RANGED
-- 3k_battle_advice_deployment_units_2
units_ranged_1 = advice_monitor:new(
	"3k_battle_advice_deployment_units_2",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_units_2",
	{
		"3k_battle_advice_deployment_units_2_functional"
	},
	0
);

units_ranged_1:set_advice_level(2);

units_ranged_1:add_trigger_condition(
	function(context)

		if context.string == "3k_battle_advice_deployment_units_1" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

units_ranged_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_units_2") then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start() then 
			return false;
		end
		
		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_units_1");
		if (advice_score > 0) then 
			return true;
		end
		
	end 
);

units_ranged_1:set_trigger_callback(
	function()
		local ranged_unit = unit_manager:getInfantryUnitWithAmmo();
		if not ranged_unit then 
			return 
		end

		battle_advice_system:highlight_unit_and_set_advice_context_object(units_ranged_1, ranged_unit, "3k_main_battle_scripted_objective_flanking_2", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(units_ranged_1);
		battle_advice_system:setAdvicePlayed("3k_battle_advice_deployment_units_2");
		timing_manager:startTimer("3k_battle_advice_deployment_units_3");
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- UNITS 3 - CAVALRY
-- 3k_battle_advice_deployment_units_3
units_cavalry_1 = advice_monitor:new(
	"3k_battle_advice_deployment_units_3",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_units_3",
	{
		"3k_battle_advice_deployment_units_3_functional"
	},
	30000
);

units_cavalry_1:set_advice_level(2);

units_ranged_1:add_trigger_condition(
	function(context)

		if context.string == "3k_battle_advice_deployment_units_2" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

units_cavalry_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_units_3") then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start() then 
			return false;
		end
		
		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_units_2");
		if (advice_score > 0) then 
			return true;
		end
		
	end 
);


units_cavalry_1:set_trigger_callback(
	function()
		-- local cavalry_unit = unit_manager:get_melee_cavalry_unit();
		-- if not cavalry_unit then 
		-- 	return 
		-- end

		-- battle_advice_system:highlight_unit_and_set_advice_context_object(units_cavalry_1, cavalry_unit, "3k_main_battle_scripted_objective_flanking_2", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(units_cavalry_1);
	end,
	true
);



-- [[ Release Advice ]]
--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_ambush_defence_extraction_1
ambush_defence_extraction_1 = advice_monitor:new(
	"3k_battle_advice_ambush_defence_extraction_1",
	200,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_ambush_defence_extraction_1",
	{
		"3k_battle_advice_ambush_defence_extraction_1_functional"
	},
	30000
);

ambush_defence_extraction_1:set_advice_level(1);

ambush_defence_extraction_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_ambush_defence_extraction_1") then 
			return false;
		end 

		if not battle_advice_system.conflict_phase_started then 
			return false;
		end

		if bm:is_land_ambush() and not bm:player_is_attacker() then 
			return true;
		end

		return false;

	end
);

ambush_defence_extraction_1:set_trigger_callback(
	function()
		battle_advice_system:setAdvicePlayed("3k_battle_advice_ambush_defence_extraction_1", false);
	end 
);


-- 3k_battle_advice_ambush_attack_1
ambush_attack_1 = advice_monitor:new(
	"3k_battle_advice_ambush_attack_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_ambush_attack_1",
	{
		"3k_battle_advice_ambush_attack_1_functional"
	},
	30000
);

ambush_attack_1:set_advice_level(2);

ambush_attack_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_ambush_attack_1") then 
			return false;
		end 

		if bm:is_land_ambush() and bm:player_is_attacker() then 
			return true;
		end

		return false;

	end
);

ambush_attack_1:set_trigger_callback(
	function()
		-- nothing to do here
	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_ambush_defence_1
ambush_defence_1 = advice_monitor:new(
	"3k_battle_advice_ambush_defence_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_ambush_defence_1",
	{
		"3k_battle_advice_ambush_defence_1_functional"
	},
	30000
);

ambush_defence_1:set_advice_level(2);

ambush_defence_1:add_trigger_condition(
	function ()
		if (battle_advice_system.running_in_E3_mode) then 
			return false;
		end

		-- returning false at all times because advice redundant at this point
		return false;

	end
);

ambush_defence_1:set_trigger_callback(
	function()
		--  nothing to do here
	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_ancillaries_1
ancillaries_1 = advice_monitor:new(
	"3k_battle_advice_ancillaries_1",
	250,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_ancillaries_1",
	{
		"3k_battle_advice_ancillaries_1_functional"
	},
	30000
);

ancillaries_1:set_advice_level(1);

ancillaries_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_ancillaries_1") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_1");
		if (advice_score < 1) then 
			return false;
		end 
		
		local unit_with_rare_CEO = unit_manager:getUnitWithCEORarity(4);
		if (unit_with_rare_CEO == nil) then 
			return false;
		end

		return true;		

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

ancillaries_1:set_trigger_callback(
	function()
		local unit_with_rare_CEO = unit_manager:getUnitWithCEORarity(4);
		if not unit_with_rare_CEO then 
			return 
		end 
		battle_advice_system:highlight_unit_and_set_advice_context_object(ancillaries_1, unit_with_rare_CEO, "3k_main_battle_scripted_objective_morale_1_routing", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(ancillaries_1);
		battle_advice_system:setAdvicePlayed("3k_battle_advice_ancillaries_1");
	end ,
	true
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_units_weights_1
unit_weight_1 = advice_monitor:new(
	"3k_battle_advice_units_weights_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_units_weights_1",
	{
		"3k_battle_advice_units_weights_1_functional"
	},
	30000
);

unit_weight_1:set_advice_level(2);

unit_weight_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_units_weights_1") then 
			return false;
		end 
		
		if not advicePhases:hasAdviceTriggered("3k_battle_advice_deployment_units_1") or 
		   not advicePhases:hasAdviceTriggered("3k_battle_advice_deployment_units_2") or 
		   not advicePhases:hasAdviceTriggered("3k_battle_advice_deployment_units_3") then 
			return false;
		end
		
		local light_unit = unit_manager:get_light_weight_unit();
		if light_unit then 
			return true;
		else
			return false;
		end

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

unit_weight_1:set_trigger_callback(
	function()
		local light_unit = unit_manager:get_light_weight_unit();
		if not light_unit then 
			return 
		end 
		battle_advice_system:highlight_unit_and_set_advice_context_object(unit_weight_1, light_unit, "3k_main_battle_scripted_objective_morale_1_routing", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(unit_weight_1);
		battle_advice_system:setAdvicePlayed("3k_battle_advice_units_weights_1");
		timing_manager:startTimer("3k_battle_advice_units_weights_2");
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_units_weights_2
unit_weight_2 = advice_monitor:new(
	"3k_battle_advice_units_weights_2",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_units_weights_2",
	{
		"3k_battle_advice_units_weights_2_functional"
	},
	30000
);

unit_weight_2:set_advice_level(2);

unit_weight_2:add_trigger_condition(
	function(context)
		if context.string == "3k_battle_advice_units_weights_1" then
			local unit = unit_manager:get_medium_weight_unit();
			if not unit then 
				return false;
			end
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

unit_weight_2:add_trigger_condition(
	function(context)
		
		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_units_weights_2") then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_units_weights_1");
		if (advice_score < 1) then 
			return false;
		end

		local unit = unit_manager:get_medium_weight_unit();
		if unit then 
			return true;
		else
			return false;
		end

		return true;

	end
);

unit_weight_2:set_trigger_callback(
	function()
		local medium_unit = unit_manager:get_medium_weight_unit();
		if not medium_unit then 
		 	return 
		end 
		battle_advice_system:highlight_unit_and_set_advice_context_object(unit_weight_2, medium_unit, "3k_main_battle_scripted_objective_morale_1_routing", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(unit_weight_2);
		battle_advice_system:setAdvicePlayed("3k_battle_advice_units_weights_2");
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_units_weights_3
unit_weight_3 = advice_monitor:new(
	"3k_battle_advice_units_weights_3",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_units_weights_3",
	{
		"3k_battle_advice_units_weights_3_functional"
	},
	30000
);

unit_weight_3:set_advice_level(2);

unit_weight_3:add_trigger_condition(
	function(context)
		if context.string == "3k_battle_advice_units_weights_2" then
			local unit = unit_manager:get_medium_weight_unit();
			if not unit then 
			 	return false;
			end
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

unit_weight_3:add_trigger_condition(
	function(context)
		
		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_units_weights_3") then 
			return false;
		end

		local unit = unit_manager:get_heavy_weight_unit();
		if unit then 

		else
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_units_weights_2");
		if (advice_score > 0) then 
			return true;
		end

	end
);

unit_weight_3:set_trigger_callback(
	function()
		local heavy_unit = unit_manager:get_heavy_weight_unit();
		if not heavy_unit then 
			return 
		end 
		battle_advice_system:highlight_unit_and_set_advice_context_object(unit_weight_3, heavy_unit, "3k_main_battle_scripted_objective_morale_1_routing", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(unit_weight_3);
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_deployment_4
deployment_4 = advice_monitor:new(
	"3k_battle_advice_deployment_4",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_4",
	{
		"3k_battle_advice_deployment_4_functional"
	},
	30000
);

deployment_4:set_advice_level(2);

deployment_4:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_4") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_3");
		if (advice_score > 0) then 
			return true;
		end
		
	end,
	"ScriptEventBattleArmiesEngaging"
);

deployment_4:set_trigger_callback(
	function()
		-- We don't have to do anything here really. 
	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_attacking_1
attacking_1 = advice_monitor:new(
	"3k_battle_advice_attacking_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_attacking_1",
	{
		"3k_battle_advice_unit_formations_3_functional"
	},
	30000
);

attacking_1:set_advice_level(2);

attacking_1:add_trigger_condition(
	function ()
		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_attacking_1") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_3");
		if (advice_score > 0) and bm:player_is_attacker() and not bm:is_land_ambush() and not bm:is_siege_battle() then 
			return true;
		end 
		
	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

attacking_1:set_trigger_callback(
	function()
		-- We don't have to do anything here really. 
	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_defending_1
defending_1 = advice_monitor:new(
	"3k_battle_advice_defending_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_defending_1",
	{
		"3k_battle_advice_defending_1_functional"
	},
	30000
);

defending_1:set_advice_level(2);

defending_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_defending_1") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_3");

		if not advicePhases:haveBasicAdviceBeenTriggered() then 
			return false;
		end

		if (not bm:player_is_attacker() and not bm:is_land_ambush()) then 
			return true;
		end 
		
	end
);

defending_1:set_trigger_callback(
	function()
		-- We don't have to do anything here really. 
	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_fatigue_1
fatigue_1 = advice_monitor:new(
	"3k_battle_advice_fatigue_1",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_fatigue_1",
	{
		"3k_battle_advice_fatigue_1_functional"
	},
	30000
);

fatigue_1:set_advice_level(1);

fatigue_1:add_trigger_condition(
	function ()

		local fatigued_unit = unit_manager:getUnitWithAnyFatigueState();
		if (fatigued_unit == nil) then 
			return false;
		end 

		return true;
		
	end
);

fatigue_1:set_trigger_callback(
	function()
		local fatigued_unit = unit_manager:getUnitWithAnyFatigueState();
		if (fatigued_unit == nil) then 
			battleAdviceLogger:log("[WARNING] fatigue_1:set_trigger_callback(): No longer finding a fatigued unit.");
			return;
		end
		battle_advice_system:highlight_unit_and_set_advice_context_object(fatigue_1, fatigued_unit, "3k_main_battle_scripted_objective_fatigue_1", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(fatigue_1);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_fatigue_2
fatigue_2 = advice_monitor:new(
	"3k_battle_advice_fatigue_2",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_fatigue_2",
	{
		"3k_battle_advice_fatigue_2_functional"
	},
	30000
);

fatigue_2:set_advice_level(1);

fatigue_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_fatigue_2") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_fatigue_1");
		if (advice_score < 10) then 
			return false;
		end

		local fatigued_unit = unit_manager:getUnitWithAnyFatigueState();
		if (fatigued_unit == nil) then 
			return false;
		end 

		return true;
		
	end
);

fatigue_2:set_trigger_callback(
	function()
		local fatigued_unit = unit_manager:getUnitWithAnyFatigueState();
		if (fatigued_unit == nil) then 
			battleAdviceLogger:log("[WARNING] fatigue_2:set_trigger_callback(): No longer finding a fatigued unit.");
			return;
		end
		battle_advice_system:highlight_unit_and_set_advice_context_object(fatigue_2, fatigued_unit, "3k_main_battle_scripted_objective_fatigue_2", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(fatigue_2);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_backwards_1
backwards_1 = advice_monitor:new(
	"3k_battle_advice_backwards_1",
	30,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_backwards_1",
	{
		"3k_battle_advice_backwards_1_functional"
	},
	30000
);

backwards_1:set_advice_level(2);

backwards_1:add_trigger_condition(
	function ()
		return false;
	end
);

backwards_1:set_trigger_callback(
	function()
		local unit_with_less_than_half_hp = unit_manager:getInfantryWithHitpointPercentageLeft(0.5);
		if (unit_with_less_than_half_hp == nil) then 
			battleAdviceLogger:log("[WARNING] backwards_1:set_trigger_callback(): No longer finding a damaged infantry unit.");
			return;
		end
		battle_advice_system:highlight_unit_and_set_advice_context_object(backwards_1, unit_with_less_than_half_hp, "3k_main_battle_scripted_objective_backwards_1", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(backwards_1);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_fire_at_will_1
fire_at_will_1 = advice_monitor:new(
	"3k_battle_advice_fire_at_will_1",
	40,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_fire_at_will_1",
	{
		"3k_battle_advice_fire_at_will_1_functional"
	},
	30000
);

fire_at_will_1:set_advice_level(2);

fire_at_will_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_fire_at_will_1") then 
			return false;
		end 

		local ranged_unit = unit_manager:getInfantryUnitWithAmmo();
		if (ranged_unit == nil) then 
			return false;
		end

	end,
	"ScriptEventBattleArmiesEngaging"
);

fire_at_will_1:set_trigger_callback(
	function()
		local ranged_unit = unit_manager:getInfantryUnitWithAmmo();
		if (ranged_unit == nil) then 
			battleAdviceLogger:log("[WARNING] fire_at_will_1:set_trigger_callback(): No longer finding a infantry unit with ammo.");
			return;
		end

		battle_advice_system:highlight_unit_and_set_advice_context_object(fire_at_will_1, ranged_unit, "3k_main_battle_scripted_objective_fire_at_will_1", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(fire_at_will_1);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_flanking_1
flanking_1 = advice_monitor:new(
	"3k_battle_advice_flanking_1",
	5000,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_flanking_1",
	{
		"3k_battle_advice_flanking_1_functional"
	},
	30000
);

flanking_1:set_advice_level(1);

flanking_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_flanking_1") then 
			return false;
		end 

		if bm:is_land_ambush() and not battle_advice_system.conflict_phase_started then 
			return false;
		end

		if bm:is_siege_battle() then 
			return false;
		end

		if (not battle_advice_system:hasBattleIntroductionPlayed()) then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_retinues_1");
		if (advice_score < 1) then 
			return false;
		end

		-- local flanking_unit = unit_manager:get_melee_cavalry_unit();
		-- if (flanking_unit == nil) then 
		-- 	return false 
		-- else 
			-- if timing_manager:checkTime("3k_battle_advice_flanking_1") > 25 then
			-- 	return true;
			-- else 
			-- 	return false;
			-- end
		-- end

		return true;

	end,
	"ScriptEventBattleArmiesEngaging"
);

flanking_1:add_trigger_condition(
	function(context)

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_flanking_1") then 
			return false;
		end 

		if bm:is_siege_battle() then 
			return false;
		end

		local flanking_unit = unit_manager:get_melee_cavalry_unit();
		if (flanking_unit == nil) then 
			return false 
		end
		
		if context.string == "3k_battle_advice_retinues_1" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

flanking_1:set_trigger_callback(
	function()
		-- local cavalry_unit = unit_manager:get_melee_cavalry_unit();
		-- if (cavalry_unit == nil) then 
		-- 	battleAdviceLogger:log("[WARNING] flanking_1:set_trigger_callback(): No longer finding a cavalry unit.");
		-- 	return;
		-- end

		-- battle_advice_system:highlight_unit_and_set_advice_context_object(flanking_1, cavalry_unit, "3k_main_battle_scripted_objective_flanking_1", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(flanking_1);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_flanking_2
flanking_2 = advice_monitor:new(
	"3k_battle_advice_flanking_2",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_flanking_2",
	{
		"3k_battle_advice_flanking_2_functional"
	},
	30000
);

flanking_2:set_advice_level(1);

flanking_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_flanking_2") then 
			return false;
		end 

		local flanked_unit = unit_manager:getFlankedUnit();
		if (flanked_unit == nil) then 
			return false;
		end
		return true;

	end,
	"ScriptEventUnitFlanked"
);

flanking_2:set_trigger_callback(
	function()
		
		-- TODO get the unit that is flanking
		local flanking_unit = nil;
		battle_advice_system:highlight_unit_and_set_advice_context_object(flanking_2, flanking_unit, "3k_main_battle_scripted_objective_flanking_2", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(flanking_2);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_flanking_3
flanking_3 = advice_monitor:new(
	"3k_battle_advice_flanking_3",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_flanking_3",
	{
		"3k_battle_advice_flanking_3_functional"
	},
	30000
);

flanking_3:set_advice_level(2);

flanking_3:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_flanking_3") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_flanking_2");
		if (advice_score < 1) then 
			return false;
		end

		local flanked_unit = unit_manager:getFlankedUnit();
		if (flanked_unit == nil) then 
			return false;
		end
		return true;

	end,
	"ScriptEventUnitFlanked"
);

flanking_3:set_trigger_callback(
	function()
		
		local flanked_unit = unit_manager:getFlankedUnit();
		if (flanked_unit == nil) then
			return;
		else 
			battle_advice_system:highlight_unit_and_set_advice_context_object(flanking_3, flanked_unit, "3k_main_battle_scripted_objective_flanking_3", 15000)
			battle_advice_system:stop_advice_queue_and_play_advice(flanking_3);
		end
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_flanking_4
flanking_4 = advice_monitor:new(
	"3k_battle_advice_flanking_4",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_flanking_4",
	{
		"3k_battle_advice_flanking_4_functional"
	},
	30000
);

flanking_4:set_advice_level(1);

flanking_4:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_flanking_4") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_flanking_3");
		if (advice_score < 1) then 
			return false;
		end

		local flanked_unit = unit_manager:getFlankedUnit();
		if (flanked_unit == nil) then 
			return false;
		end
		return true;

	end,
	"ScriptEventUnitFlanked"
);

flanking_4:set_trigger_callback(
	function()
		
		local flanked_unit = unit_manager:getFlankedUnit();
		if (flanked_unit == nil) then 
			return;
		else
			battle_advice_system:highlight_unit_and_set_advice_context_object(flanking_4, flanked_unit, "3k_main_battle_scripted_objective_flanking_4", 15000)
			battle_advice_system:stop_advice_queue_and_play_advice(flanking_4);
		end
		
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_commanders_2
commanders_2 = advice_monitor:new(
	"3k_battle_advice_commanders_2",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_commanders_2",
	{
		"3k_battle_advice_commanders_2_functional"
	},
	30000
);

commanders_2:set_advice_level(2);

commanders_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_commanders_2") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_1");
		if (advice_score < 1) then 
			return false;
		end

		local commander = unit_manager:getCommanderInAlliance();
		if (commander == nil) then 
			return false;
		end
		return true;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

commanders_2:set_trigger_callback(
	function()

		local commander = unit_manager:getCommanderInAlliance();
		if (commander == nil) then 
			battleAdviceLogger:log("[WARNING] commanders_2:set_trigger_callback(): No longer finding an alliance commander.");
			return;
		end
		
		battle_advice_system:highlight_unit_and_set_advice_context_object(commanders_2, commander, "3k_main_battle_scripted_objective_commanders_2", 15000)
		battle_advice_system:stop_advice_queue_and_play_advice(commanders_2);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_guard_mode_1
guard_mode_1 = advice_monitor:new(
	"3k_battle_advice_guard_mode_1",
	2,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_guard_mode_1",
	{
		"3k_battle_advice_guard_mode_1_functional"
	},
	30000
);

guard_mode_1:set_advice_level(2);

guard_mode_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_guard_mode_1") then 
			return false;
		end 

		if bm:player_is_attacker() then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_1");
		if (advice_score < 1) then 
			return false;
		end
		
		return true;

	end,
	"ScriptEventBattleArmiesEngaging"
);

guard_mode_1:set_trigger_callback(
	function()

		battle_advice_system:highlightAllInfantryUnits(3000);
		battle_advice_system:stop_advice_queue_and_play_advice(guard_mode_1);

	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_strategic_map_1
strategic_map_1 = advice_monitor:new(
	"3k_battle_advice_strategic_map_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_strategic_map_1",
	{
		"3k_battle_advice_strategic_map_1_functional"
	},
	30000
);

strategic_map_1:set_advice_level(2);

strategic_map_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_strategic_map_1") then 
			return false;
		end 

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_2");
		if (advice_score < 1) then 
			return false;
		end
		
		return true;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

strategic_map_1:set_trigger_callback(
	function()

		-- nothing to do here

	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_morale_2
morale_2 = advice_monitor:new(
	"3k_battle_advice_morale_2",
	40,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_morale_2",
	{
		"3k_battle_advice_morale_3_functional"
	},
	30000
);

morale_2:set_advice_level(2);

morale_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_morale_2") then 
			return false;
		end 
		
		local advice_score = effect.get_advice_thread_score("3k_battle_advice_morale_1");
		if (advice_score < 1) then 
			return false;
		end

	end,
	"ScriptEventPlayerUnitRouts"
);

morale_2:set_trigger_callback(
	function()

		battleAdviceLogger:log("[INFO] morale_2:set_trigger_callback(): Checking for wavering or routing unit.");
		local wavering_unit = unit_manager:getWaveringUnit();
		local routing_unit = unit_manager:getRoutingUnit();
		if (wavering_unit == nil and routing_unit == nil) then 
			battleAdviceLogger:log("[WARNING] morale_2:set_trigger_callback(): Could not find a wavering or routing unit.");
		else 
			if (routing_unit == nil) then 
				battle_advice_system:highlight_unit_and_set_advice_context_object(morale_2, wavering_unit, "3k_main_battle_scripted_objective_morale_1_wavering", 15000);
				battle_advice_system:stop_advice_queue_and_play_advice(morale_2);
			else
				battle_advice_system:highlight_unit_and_set_advice_context_object(morale_2, routing_unit, "3k_main_battle_scripted_objective_morale_1_routing", 15000);
				battle_advice_system:stop_advice_queue_and_play_advice(morale_2);
			end
			
		end

	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_deployment_siege_attack_2
siege_attack_2 = advice_monitor:new(
	"3k_battle_advice_deployment_siege_attack_2",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_siege_attack_2",
	{
		"3k_battle_advice_deployment_siege_attack_2_functional"
	},
	30000
);

siege_attack_2:set_advice_level(2);

siege_attack_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_siege_attack_2") then 
			return false;
		end 
		
		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_attack_1");
		if (advice_score < 1) then 
			return false;
		end

		if bm:is_siege_battle() and bm:player_is_attacker() then 
			return true;
		else 
			return false;
		end

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

siege_attack_2:add_trigger_condition(
	function(context)

		if bm:is_siege_battle() and bm:player_is_attacker() then 

		else 
			return false;
		end
		
		if context.string == "3k_battle_advice_deployment_siege_attack_1" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

siege_attack_2:set_trigger_callback(
	function()

		-- nothing to do here

	end 
);

-- 3k_battle_advice_deployment_siege_attack_equipment_1
siege_attack_equipment_1 = advice_monitor:new(
	"3k_battle_advice_deployment_siege_attack_equipment_1",
	200,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_siege_attack_equipment_1",
	{
		"3k_battle_advice_deployment_siege_attack_equipment_1_functional"
	},
	30000
);

siege_attack_equipment_1:set_advice_level(2);

siege_attack_equipment_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_siege_attack_equipment_1") then 
			return false;
		end 
		
		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_attack_1");
		if (advice_score < 1) then 
			return false;
		end

		if bm:is_siege_battle() and bm:player_is_attacker() then
			local siege_unit = unit_manager:unit_carrying_siege_equipment();
			if siege_unit then 
				return true;
			else
				return false;
			end
		else 
			return false;
		end

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

siege_attack_equipment_1:set_trigger_callback(
	function()
		local siege_unit = unit_manager:unit_carrying_siege_equipment();
		battle_advice_system:highlight_unit_and_set_advice_context_object(siege_attack_equipment_1, siege_unit, "3k_main_battle_scripted_objective_special_abilities_1", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(siege_attack_equipment_1);
	end,
	true
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_deployment_siege_defence_2
siege_defence_2 = advice_monitor:new(
	"3k_battle_advice_deployment_siege_defence_2",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_siege_defence_2",
	{
		"3k_battle_advice_deployment_siege_defence_2_functional"
	},
	30000
);

siege_defence_2:set_advice_level(2);

siege_defence_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_siege_defence_2") then 
			return false;
		end 
		
		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_defence_1");
		if (advice_score < 1) then 
			return false;
		end

		if bm:is_siege_battle() and not bm:player_is_attacker() then 
			return true;
		else 
			return false;
		end

	end
);

siege_defence_2:set_trigger_callback(
	function()

		-- nothing to do here

	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_skirmish_mode_1
skirmish_mode_1 = advice_monitor:new(
	"3k_battle_advice_skirmish_mode_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_skirmish_mode_1",
	{
		"3k_battle_advice_skirmish_mode_1_functional"
	},
	30000
);

skirmish_mode_1:set_advice_level(2);

skirmish_mode_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_skirmish_mode_1") then 
			return false;
		end 

		local ranged_unit = unit_manager:getInfantryUnitWithAmmo();
		if (ranged_unit == nil) then 
			return false;
		end

		if advicePhases:haveBasicAdviceBeenTriggered() then 
			return true;
		else
			return false;
		end		

	end
);

skirmish_mode_1:set_trigger_callback(
	function()
		local ranged_unit = unit_manager:getInfantryUnitWithAmmo();
		if (ranged_unit == nil) then 
			battleAdviceLogger:log("[WARNING] skirmish_mode_1:set_trigger_callback(): No longer finding a infantry unit with ammo.");
			return;
		end

		battle_advice_system:highlight_unit_and_set_advice_context_object(skirmish_mode_1, ranged_unit, "3k_main_battle_scripted_objective_skirmish_1", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(skirmish_mode_1);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_terrain_1
terrain_1 = advice_monitor:new(
	"3k_battle_advice_terrain_1",
	1,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_terrain_1",
	{
		"3k_battle_advice_terrain_1_functional"
	},
	30000
);

terrain_1:set_advice_level(2);

terrain_1:add_trigger_condition(
	function ()
		if (battle_advice_system.running_in_E3_mode) then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_terrain_1") then 
			return false;
		end 

		if (bm:is_siege_battle()) then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_1");
		if (advice_score > 10) and battle_advice_system.intro_advice_complete == true then 
			return true;
		end 

		return false;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice" 
);

terrain_1:set_trigger_callback(
	function()
		
		-- nothing to do here

	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_controls_dragout_1
dragout_1 = advice_monitor:new(
	"3k_battle_advice_controls_dragout_1",
	5,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_controls_dragout_1",
	{
		"3k_battle_advice_controls_dragout_1_functional"
	},
	30000
);

dragout_1:set_advice_level(2);

dragout_1:add_trigger_condition(
	function ()
		if (battle_advice_system.running_in_E3_mode) then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_controls_dragout_1") then 
			return false;
		end 

		if (bm:is_siege_battle()) then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_1");
		if (advice_score > 1) and battle_advice_system.intro_advice_complete == true then 
			return true;
		end 

	end,
	"ScriptEventConflictPhaseBeginsForAdvice" 
);

dragout_1:set_trigger_callback(
	function()
		
		-- nothing to do here
			
	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_controls_dragout_2
dragout_2 = advice_monitor:new(
	"3k_battle_advice_controls_dragout_2",
	5,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_controls_dragout_2",
	{
		"3k_battle_advice_controls_dragout_2_functional"
	},
	30000
);

dragout_2:set_advice_level(2);

dragout_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_controls_dragout_2") then 
			return false;
		end

		if (bm:is_siege_battle()) then 
			return false;
		end

		if not advicePhases:hasAdviceTriggered("3k_battle_advice_flanking_4") then 
			return false;
		end 

		-- local cav_unit = unit_manager:get_melee_cavalry_unit();
		-- if (cav_unit == nil) then 
		-- 	return false;
		-- end

		return true;
	end,
	"ScriptEventBattleArmiesEngaging"
);

dragout_2:set_trigger_callback(
	function()
		-- local cavalry_unit = unit_manager:get_melee_cavalry_unit();
		-- if (cavalry_unit == nil) then 
		-- 	battleAdviceLogger:log("[WARNING] sdragout_2:set_trigger_callback(): No longer finding a cavalry unit.");
		-- 	return;
		-- end

		-- battle_advice_system:highlight_unit_and_set_advice_context_object(dragout_2, cavalry_unit, "3k_main_battle_scripted_objective_dragout_2", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(dragout_2);
	end,
	true -- means that advice is not triggered automatically
);

-- 3k_battle_advice_unit_formations_2
unit_formations_2 = advice_monitor:new(
	"3k_battle_advice_unit_formations_2",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_unit_formations_2",
	{
		"3k_battle_advice_unit_formations_2_functional"
	},
	30000
);

unit_formations_2:set_advice_level(2);

unit_formations_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_unit_formations_2") then 
			return false;
		end

		unit_formations_2.formations = {"circle", "diamond", "hollowed_square", "pike_wall", "shield_wall", "spear_wall", "turtle", "wedge"};

		for index in ipairs(unit_formations_2.formations)
		do
			if (unit_manager:doesSomeUnitHaveAbility(unit_formations_2.formations[index]) == true) then 
				return true;
			end 
		end 

		return false;

	end,
	"ScriptEventBattleArmiesEngaging" 
);

unit_formations_2:set_trigger_callback(
	function()
		unit_formations_2.formations = {"circle", "diamond", "hollowed_square", "pike_wall", "shield_wall", "spear_wall", "turtle", "wedge"};

		for index in ipairs(unit_formations_2.formations)
		do
			local current_unit = unit_manager:getUnitWithAbility(unit_formations_2.formations[index]);
			if not (current_unit == nil) then 
				battle_advice_system:highlight_unit_and_set_advice_context_object(unit_formations_2, current_unit, "3k_main_battle_scripted_objective_unit_formations_1", 15000);
				battle_advice_system:stop_advice_queue_and_play_advice(unit_formations_2);
			end 
		end 
	end,
	true -- means that advice is not triggered automatically
);

-- 3k_battle_advice_units_archers_1
archers_1 = advice_monitor:new(
	"3k_battle_advice_units_archers_1",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_units_archers_1",
	{
		"3k_battle_advice_units_archers_1_functional"
	},
	30000
);

archers_1:set_advice_level(2);

archers_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_units_archers_1") then 
			return false;
		end

		if advicePhases:haveBasicAdviceBeenTriggered() then 
			return true;
		else
			return false;
		end	

		local archer_unit = unit_manager:getInfantryUnitWithAmmo();
		if (archer_unit == nil) then 
			return false;
		end

		return true;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice" 
);

archers_1:set_trigger_callback(
	function()
		local archer = unit_manager:getInfantryUnitWithAmmo();
		if (archer == nil) then 
			battleAdviceLogger:log("[WARNING] archers_1:set_trigger_callback(): No longer finding an infantry unit with ammo.");
			return;
		end

		battle_advice_system:highlight_unit_and_set_advice_context_object(archers_1, archer, "3k_main_battle_scripted_objective_archers_1", 15000)	
		battle_advice_system:stop_advice_queue_and_play_advice(archers_1);
	end,
	true -- means that advice is not triggered automatically
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_visibility_1
visibility_1 = advice_monitor:new(
	"3k_battle_advice_visibility_1",
	10,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_visibility_1",
	{
		"3k_battle_advice_visibility_1_functional"
	},
	30000
);

visibility_1:set_advice_level(1);

visibility_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_visibility_1") then 
			return false;
		end

		if (bm:is_siege_battle()) then 
			return false;
		end

		if advicePhases:haveBasicAdviceBeenTriggered() then 

		else
			return false;
		end	

		-- Taken from WH2
		local player_army = visibility_1.player_army;
		local enemy_alliance = visibility_1.enemy_alliance;
		
		-- cache alliances if we don't have them
		if not player_army then
			player_army = bm:get_player_army();
			visibility_1.player_army = player_army;
			enemy_alliance = bm:get_non_player_alliance();
			visibility_1.enemy_alliance = enemy_alliance;
		end;
		
		local num_invisible_player_units, num_player_units = num_units_passing_test(
			player_army,
			function(unit)
				return not unit:is_visible_to_alliance(enemy_alliance);
			end
		);
		
		if num_player_units == 0 then
			return false;
		end;

		battleAdviceLogger:log("Went through VISIBILITY check and might trigger advice now");
		
		-- try and trigger if more than two units and more than 25% of the player's army is invisible
		return num_invisible_player_units > 2 and num_invisible_player_units / num_player_units > 0.25;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

visibility_1:set_trigger_callback(
	function()
		
		-- nothing to do here

	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_victory_1
victory_1 = advice_monitor:new(
	"3k_battle_advice_victory_1",
	1,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_victory_1",
	{
		"3k_battle_advice_victory_1_functional"
	},
	30000
);

victory_1:set_advice_level(2);
victory_1:set_halt_on_battle_end(false);

victory_1:add_trigger_condition(
	function ()
		if (battle_advice_system.running_in_E3_mode) then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_victory_1") then 
			return false;
		end

		if unit_manager:get_unit_not_routing() then 
			return true;
		else 
			return false;
		end

	end,
	"ScriptEventVictoryCountdownPhaseBegins"
);

victory_1:set_trigger_callback(
	function()
		
		-- nothing to do here

	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_defeat_1
defeat_1 = advice_monitor:new(
	"3k_battle_advice_defeat_1",
	1,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_defeat_1",
	{
		"3k_battle_advice_defeat_1_functional"
	},
	30000
);

defeat_1:set_advice_level(2);
defeat_1:set_halt_on_battle_end(false);

defeat_1:add_trigger_condition(
	function ()
		if (battle_advice_system.running_in_E3_mode) then 
			return false;
		end

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_defeat_1") then 
			return false;
		end

		if unit_manager:get_unit_not_routing() then 
			return false;
		else 
			return true;
		end

	end,
	"ScriptEventVictoryCountdownPhaseBegins"
);

defeat_1:set_trigger_callback(
	function()
		
		-- nothing to do here

	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_sieges_minor_settlement_1
minor_settlement_1 = advice_monitor:new(
	"3k_battle_advice_sieges_minor_settlement_1",
	50,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_sieges_minor_settlement_1",
	{
		"3k_battle_advice_sieges_minor_settlement_1_functional"
	},
	30000
);

minor_settlement_1:set_advice_level(2);

minor_settlement_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_sieges_minor_settlement_1") then 
			return false;
		end

		local battle_type = effect.get_context_string_value("CcoBattleRoot", "BattleTypeState");
		if (battle_type == "settlement_unfortified") then 
			if advicePhases:haveBasicAdviceBeenTriggered() then 
				return true;
			else
				return false;
			end	
		end

		return false;

	end,
	"ScriptEventLoadingScreenDismissedForAdvice"
);

minor_settlement_1:set_trigger_callback(
	function()
		
		-- nothing to do here

	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_deployment_sally_out_1
sally_out_1 = advice_monitor:new(
	"3k_battle_advice_deployment_sally_out_1",
	10,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_deployment_sally_out_1",
	{
		"3k_battle_advice_deployment_sally_out_1_functional"
	},
	30000
);

sally_out_1:set_advice_level(2);

sally_out_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_deployment_sally_out_1") then 
			return false;
		end

		local battle_type = effect.get_context_string_value("CcoBattleRoot", "BattleTypeState");
		if (battle_type == "settlement_sally" or battle_type == "fort_sally") then 
			if (not bm:player_is_attacker()) then 
				return true;
			end
		end

		return false;

	end
);

sally_out_1:set_trigger_callback(
	function()
		
		-- nothing to do here

	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_units_repeating_crossbows_1
repeating_crossbow_1 = advice_monitor:new(
	"3k_battle_advice_units_repeating_crossbows_1",
	5,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_units_repeating_crossbows_1",
	{
		"3k_battle_advice_units_repeating_crossbows_1_functional"
	},
	30000
);

repeating_crossbow_1:set_advice_level(1);

repeating_crossbow_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_units_repeating_crossbows_1") then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_archers_1");
		if (advice_score < 1) then 
			return false;
		end

		local archer_unit = unit_manager:getInfantryUnitWithAmmo();
		if (archer_unit == nil) then 
			return false;
		end

		return true;

	end
);

repeating_crossbow_1:set_trigger_callback(
	function()
		-- TODO change to repeating crossbows
		local repeating_crossbows = unit_manager:getInfantryUnitWithAmmo();
		if (repeating_crossbows == nil) then 
			battleAdviceLogger:log("[WARNING] repeating_crossbow_1:set_trigger_callback(): No longer finding an infantry unit with ammo.");
			return;
		end

		battle_advice_system:highlight_unit_and_set_advice_context_object(repeating_crossbow_1, repeating_crossbows, "3k_main_battle_scripted_objective_repeating_crossbows_1", 15000);
		battle_advice_system:stop_advice_queue_and_play_advice(repeating_crossbow_1);
	end,
	true -- means that advice is not triggered automatically
);


--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_control_groups_1
control_groups_1 = advice_monitor:new(
	"3k_battle_advice_control_groups_1",
	5,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_control_groups_1",
	{
		"3k_battle_advice_control_groups_1_functional"
	},
	30000
);

control_groups_1:set_advice_level(2);

control_groups_1:add_trigger_condition(
	function ()
		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_control_groups_1") then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_2");
		if (advice_score < 5) then 
			return false;
		end

		return true;

	end
);

control_groups_1:set_trigger_callback(
	function()
		-- nothing to do here
	end 
);

--------------------------------------------------------------------------------------------------------
-- 3k_battle_advice_controls_path_1
control_path_1 = advice_monitor:new(
	"3k_battle_advice_controls_path_1",
	5,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_controls_path_1",
	{
		"3k_battle_advice_controls_path_1_functional"
	},
	30000
);

control_path_1:set_advice_level(2);

control_path_1:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_controls_path_1") then 
			return false;
		end

		if not advicePhases:hasAdviceTriggered("3k_battle_advice_control_groups_1") then 
			return false;
		end 

		if advicePhases:haveBasicAdviceBeenTriggered() then 
			return true;
		else
			return false;
		end	

	end
);

control_path_1:set_trigger_callback(
	function()
		-- TODO add cavalry unit and highlight, tailor message around it
	end 
);

-- 3k_battle_advice_reinforcements_2
reinforcements_2 = advice_monitor:new(
	"3k_battle_advice_reinforcements_2",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_reinforcements_2",
	{
		"3k_battle_advice_reinforcements_2_functional"
	},
	30000
);

reinforcements_2:set_advice_level(2);

reinforcements_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_reinforcements_2") then 
			return false;
		end

		-- TODO Check for reinforcements aide de camp, check for enemy reinforcements this time!

	end
);

reinforcements_2:set_trigger_callback(
	function()
		
		-- TODO get position of reinforcements and zoom there
		-- 3k_main_battle_scripted_objective_reinforcements_2
	end 
);

-- 3k_battle_advice_retinues_2
retinues_2 = advice_monitor:new(
	"3k_battle_advice_retinues_2",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_retinues_2",
	{
		"3k_battle_advice_retinues_2_functional"
	},
	30000
);

retinues_2:set_advice_level(1);

retinues_2:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_retinues_2") then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_retinues_1");
		if (advice_score < 1) then 
			return false;
		end

		return true;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

retinues_2:set_trigger_callback(
	function()
		
		-- Highlight units within one retinue
	end 
);

-- 3k_battle_advice_retinues_3
retinues_3 = advice_monitor:new(
	"3k_battle_advice_retinues_3",
	20,
	-- Your soldiers are ready to deploy for battle, my lord. They await your orders.
	"3k_battle_advice_retinues_3",
	{
		"3k_battle_advice_retinues_3_functional"
	},
	30000
);

retinues_3:set_advice_level(2);

retinues_3:add_trigger_condition(
	function ()

		if not battle_advice_system:advice_allowed_to_start_and_never_triggered("3k_battle_advice_retinues_3") then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_retinues_2");
		if (advice_score < 1) then 
			return false;
		end

		local advice_score = effect.get_advice_thread_score("3k_battle_advice_retinues_1");
		if (advice_score < 1) then 
			return false;
		end

		return true;

	end,
	"ScriptEventConflictPhaseBeginsForAdvice"
);

retinues_3:add_trigger_condition(
	function(context)
		
		if context.string == "3k_battle_advice_retinues_2" then
			return true;
		else
			return false;
		end
	end,
	"ScriptEventAdviceDismissed"
);

retinues_3:set_trigger_callback(
	function()
		
		-- Highlight units within one retinue
	end 
);

