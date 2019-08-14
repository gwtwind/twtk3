output("3k_campaign_setup.lua :: Loaded");

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	Custom ui listeners
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- outputs click information to the Lua - UI Script tab
output_uicomponent_on_click();

-- create some campaign helper objects
infotext = get_infotext_manager();
objectives = get_objectives_manager();
uim = cm:get_campaign_ui_manager();

-- uim:set_should_save_override_state(false);

cm:set_use_cinematic_borders_for_automated_cutscenes(false);

-- only called at start of new campaign
function setup_3k_campaign_new()
	out("3k_campaign_setup.lua :: setup_3k_campaign_new() called");
end;


function setup_3k_campaign(exclude_battle_advice)
	
	output("3k_campaign_setup.lua :: setup_3k_campaign() called");
	
	-- Singleplayer only scripts.
	if not cm:is_multiplayer() then
		setup_gating();
		setup_historical_events();
			
		-- start custom listeners for player actions
		-- these listeners usually trigger further events to notify external scripts (e.g. advice interventions) of player actions
		start_custom_listeners();
	end;
	
	inc_tab();

	-- load battle script whenever a battle is launched from this campaign (this activates advice)
	if not exclude_battle_advice then
		add_battle_script_override();
	end;
	
	if not cm:is_multiplayer() then
		dismiss_advice_on_panel_closure_sp();
	end;
	
	dec_tab();
end;


-- establish a listener which dismisses the advisor when certain panels are dismissed. Singleplayer only. Panel names can be added to the list defined within the function
function dismiss_advice_on_panel_closure_sp()
	if cm:is_multiplayer() then
		script_error("ERROR: dismiss_advice_on_panel_closure_sp() called in multiplayer mode");
		return false;
	end;

	local panel_list = {
		pre_battle_screen = true,
		post_battle_screen = true
	};

	core:add_listener(
		"dismiss_advice_on_post_battle_screen_closure",
		"PanelClosedCampaign",
		true,
		function(context)
			local panel_name = context.string;
			if panel_list[panel_name] then
				out("* dismissing advice as panel " .. panel_name .. " is closing");
				cm:wait_for_model_sp(
					function()
						cm:dismiss_advice() 
					end
				);
			end;
		end,
		true
	);
end;



function start_custom_listeners()
	local local_faction = cm:get_local_faction();
	
	if not local_faction then
		script_error("WARNING: start_custom_listeners() is exiting as there is no local_faction - this should only happen in autoruns");
		return false;
	end;

	-- custom event generators
	-- these listen for events and conditions to occur and then fire custom script events when they do. Doing this greatly 
	-- reduces the amount of work that the intervention system has to do (and the amount of output it generates)	
	--e.g. cm:start_custom_event_generator("PanelOpenedCampaign", function(context) return context.string == "diplomacy_dropdown" end, "ScriptEventDiplomacyPanelOpened");
	
	cm:start_custom_event_generator(
		"CharacterFinishedMovingEvent", 
		function(context) return context:query_character():faction():name() == local_faction end, 
		"ScriptEventPlayerCharacterFinishedMovingEvent", 
		function(context) 
			return context:query_character();
		end
	);

	cm:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) return context.string == "button_missions_list" end, 
		"ScriptEventButtonMissionsClicked"
	);

	cm:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) return context.string == "button_assignee" end, 
		"ScriptEventButtonAssigneeClicked"
	);

	cm:start_custom_event_generator(
		"ComponentLClickUp", 
		function(context) return context.string == "button_recruit" end, 
		"ScriptEventButtonEnableRecruitmentClicked"
	);

	-- campaign interaction monitors
	-- these listen for the player interacting with the UI and store a flag of whether that interaction has occurred which other scripts can query
	-- e.g. uim:add_campaign_panel_closed_interaction_monitor("unit_exchange_panel_closed", "unit_exchange");
	
	-- has player closed unit exchange panel
	uim:add_campaign_panel_closed_interaction_monitor("unit_exchange_panel_closed", "unit_exchange");
		
	-- has player closed diplomacy panel
	uim:add_campaign_panel_closed_interaction_monitor("diplomacy_panel_closed", "dropdown_diplomacy");

	-- has player researched a technology
	uim:add_interaction_monitor("technology_researched", "ResearchStarted", function(context) return context:faction():name() == local_faction end);

	-- has player recruited a unit
	uim:add_interaction_monitor("unit_recruited", "RecruitmentItemIssuedByPlayer", function() return true end);

	-- has player constructed a building
	uim:add_interaction_monitor("building_constructed", "BuildingConstructionIssuedByPlayer", function() return true end);

	-- has player assigned a character to office
	uim:add_interaction_monitor("office_assigned", "CharacterAssignedToPost", function(context) return context:query_character():faction():name() == local_faction end);

	-- has player raised a force
	uim:add_interaction_monitor("force_raised", "ScriptEventRaiseForceButtonClicked");	

	-- has player autoresolved
	uim:add_interaction_monitor(
		"autoresolve_selected", 
		"ComponentLClickUp", 
		function(context) 
			local uic = UIComponent(context.component);
			return uic:Id() == "button_autoresolve" and uicomponent_descended_from(uic, "pre_battle_screen");
		end
	);
		
	-- monitor for player stances
	core:add_listener(
		"player_stance_monitor",
		"ForceAdoptsStance",
		true,
		function(context)
			local mf = context:military_force();
			local stance = tostring(context:stance_adopted());
			
			-- out("ForceAdoptsStance event triggered, stance is " .. tostring(stance) .. " [" .. mf:active_stance() .. "]");
			
			if mf:faction():name() == local_faction then				
				if stance == "1" then
					-- march
					effect.set_advice_history_string_seen("march_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				elseif stance == "2" then
					-- ambush
					effect.set_advice_history_string_seen("ambush_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				elseif stance == "3" then
					-- raiding
					effect.set_advice_history_string_seen("raiding_stance");
					effect.set_advice_history_string_seen("has_adopted_stance");
				end;
			
			else
				-- fire an event if the force is raiding the player's territory
				if stance == "3" or stance == "14" then				
					if mf:has_general() then
						local char = mf:general_character();
						if char:has_region() then
							local owning_faction = char:region():owning_faction();
							if not owning_faction:is_null_interface() and owning_faction:name() == local_faction then
								core:trigger_event("ForceRaidingPlayerTerritory", mf);
							end;
						end;
					end;
				end;
			end;
		end,
		true
	);

	-- instruct the campaign manager to fire an event informing listeners what the player's lowest public order region is on turn start
	cm:find_lowest_public_order_region_on_turn_start(local_faction);

	-- get the campaign manager to send out a ScriptEventRegionRebels event after the FactionTurnEnd event (the RegionRebels event is sent before)
	cm:generate_region_rebels_event_for_faction(local_faction);

end;



--	Battle script override
--	Automatically loads a script in any battle launched from campaign. This activates advice in the battle.
function add_battle_script_override()
	cm:modify_scripting():add_custom_battlefield(
		"generic",											-- string identifier
		0,													-- x co-ord
		0,													-- y co-ord
		5000,												-- radius around position
		false,												-- will campaign be dumped
		"",													-- loading override
		"script/battle/campaign_battle/battle_start.lua",	-- script override
		"",													-- entire battle override
		0,													-- human alliance when battle override
		false,												-- launch battle immediately
		true											-- is land battle (only for launch battle immediately)
	);
end;