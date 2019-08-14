

-------------------------------------------------------
-------------------------------------------------------
--	UI Override
--	Allows creation of a set of functions that
--	allows/disallows access to certain ui features.
--	Also allows these features to be locked/unlocked -
--	this is useful for sections of modal script that
--	turn off the whole ui to direct the player's
--	attention 
-------------------------------------------------------
-------------------------------------------------------


ui_override = {
	name = "",
	cm = nil,
	currently_locked = true,
	is_allowed = true,
	lock_func = nil,
	unlock_func = nil
};


function ui_override:new(name, lock_func, unlock_func, lock_with_lock_ui)
	if not is_string(name) then
		script_error("ERROR: trying to create ui_override but name [" .. tostring(k_func) .. "] is not a function");
		return;
	end;
	
	if not is_function(lock_func) then
		script_error(name .. " ERROR: trying to create ui_override but supplied lock function [" .. tostring(lock_func) .. "] is not a function");
		return;
	end;
	if not is_function(unlock_func) then
		script_error(name .. " ERROR: trying to create ui_override but supplied unlock function [" .. tostring(unlock_func) .. "] is not a function");
		return;
	end;
		
	if lock_with_lock_ui ~= false then
		lock_with_lock_ui = true;
	end;
	
	local ui = {};

	setmetatable(ui, self);
	self.__index = self;
	self.__tostring = function() return TYPE_UI_OVERRIDE end;
	
	ui.name = name;
	ui.cm = get_cm();
	ui.lock_func = lock_func;
	ui.unlock_func = unlock_func;
	ui.lock_with_lock_ui = lock_with_lock_ui;

	return ui;
end;


-- sets whether a ui override is allowed or not. It can still be locked, which temporarily disables it.
function ui_override:set_allowed(value, silent)
	self.is_allowed = value;
		
	if value then
		if core:is_ui_created() then
			if not silent then
				out.ui("\t++ Allowing UI override [" .. self.name .. "]");
			end;
			self:unlock(true, silent);
		elseif not silent then
			out.ui("\t++ Allowing UI override [" .. self.name .. "] but not unlocking as ui is not yet initialised");
		end;
	else
		if core:is_ui_created() then
			if not silent then
				out.ui("\t++ Disallowing UI override [" .. self.name .. "]");
			end;
			self:lock(true, silent);
		elseif not silent then
			out.ui("\t++ Disallowing UI override [" .. self.name .. "] but not locking as ui is not yet initialised");
		end;
	end;
end;


function ui_override:get_allowed()
	return self.is_allowed;
end;


-- locks a ui override, turning it off. It will be turned on again if unlocked, assuming that it's allowed.
function ui_override:lock(force, silent, from_lock_ui)
	if not force then
		if self.currently_locked then
			return;
		end;
	end;
	
	-- don't lock if we're locking the whole ui and this override is marked to not lock at this time
	if from_lock_ui and not self.lock_with_lock_ui then
		return;
	end;
	
	self.currently_locked = true;
	
	if not silent then
		out.ui("\t++ Locking UI override [" .. self.name .. "]");
	end;
	
	self.lock_func();
end;


-- unlocks a ui override, turning it on - assuming it's allowed
function ui_override:unlock(force, silent)
	if not force then
		if not self.currently_locked or not self.is_allowed then
			out.ui("\t++ NOT Unlocking UI override: " .. self.name .. ", currently_locked: " .. tostring(self.currently_locked) .. ", is_allowed: " .. tostring(self.is_allowed));
			return;
		end;
	end;
	
	self.currently_locked = false;
	
	if not silent then
		out.ui("\t++ Unlocking UI override [" .. self.name .. "]");
	end;
	
	self.unlock_func();
end;


function ui_override:is_locked()
	return self.currently_locked;
end;







function campaign_ui_manager:load_ui_overrides()
	local cm = self.cm;
	
	-- !!! ui root doesn't exist here !!!

	local ui_overrides = {};

	-- list of all ui_overrides:
		-- toggle_movement_speed
		-- toggle_movement_speed
		-- saving
		-- radar_rollout_buttons
		-- incentives
		-- stances
		-- province_details
		-- character_details
		-- force_details
		-- raise_army
		-- replace_general
		-- recruit_units
		-- enlist_agent
		-- recruit_mercenaries
		-- faction_button
		-- missions
		-- finance
		-- technology
		-- rituals
		-- diplomacy
		-- tactical_map
		-- enlist_navy
		-- events_rollout
		-- events_panel
		-- end_turn
		-- tax_exemption
		-- autoresolve
		-- autoresolve_for_advice
		-- maintain_siege
		-- prebattle_attack
		-- prebattle_attack_for_advice
		-- cancel_siege_weapons
		-- retreat
		-- dismantle_building
		-- disband_unit
		-- repair_building
		-- cancel_construction
		-- cancel_recruitment
		-- construction_site
		-- cost_display
		-- dismiss_advice_end_turn
		-- campaign_values
		-- toggle_move_speed
		-- end_of_turn_warnings
		-- windowed_movies
		-- upgrade_unit
		-- sally_forth_button
		-- subjugation_button
		-- occupy_button
		-- raze_button
		-- loot_button
		-- sack_button
		-- settlement_renaming
		-- food_display		
		-- abandon_settlements
		-- building_upgrades
		-- non_city_building_upgrades
		-- convert_religion
		-- public_order_display
		-- intrigue_actions
		-- seek_wife
		-- large_info_panels
		-- building_browser
		-- migration
		-- migration_cancel
		-- prebattle_save
		-- resettle
		-- diplomacy_audio
		-- book_of_grudges
		-- offices
		-- grudges
		-- diplomacy_double_click
		-- giving_orders
		-- ping_clicks
		-- spell_browser
		-- advice_settings_button
		-- selection_change
		-- camera_settings
		-- army_panel_help_button
		-- province_overview_panel_help_button
		-- help_page_link_highlighting
		-- intrigue_at_the_court
		-- slaves
		-- geomantic_web
		-- skaven_corruption
		-- garrison_details
		-- end_turn_options
		-- esc_menu
		-- help_panel_button
		-- mortuary_cult
		-- books_of_nagash
		-- regiments_of_renown
		-- tax_slider
		-- corruption
		-- character_skill_upgrade
		-- character_loyalty
		
		
	-------------------------------
	-- toggle_movement_speed
	-------------------------------
	ui_overrides.toggle_movement_speed = ui_override:new(
		"toggle_movement_speed",
		function()
			cm:modify_scripting():disable_shortcut("root", "toggle_movement_speed", true);
		end,
		function()
			cm:modify_scripting():disable_shortcut("root", "toggle_movement_speed", false);
		end
	);

	-------------------------------
	-- saving
	-------------------------------
	ui_overrides.saving = ui_override:new(
		"saving",
		function()
			cm:modify_scripting():disable_saving_game(true);
		end,
		function()
			cm:modify_scripting():disable_saving_game(false);
		end
	);
	
	-------------------------------
	-- radar_rollout_buttons
	-------------------------------
	ui_overrides.radar_rollout_buttons = ui_override:new(
		"radar_rollout_buttons",
		function()
			local ui_root = core:get_ui_root();
			local uic_parent = find_uicomponent(ui_root, "bar_small_top", "TabGroup");
			if uic_parent then
				set_component_active_with_parent(false, uic_parent, "tab_units");
				set_component_active_with_parent(false, uic_parent, "tab_regions");
				set_component_active_with_parent(false, uic_parent, "tab_factions");
			end;
			cm:modify_scripting():override_ui("disable_events_dropdown_button", true);
			cm:modify_scripting():override_ui("disable_missions_dropdown_button", true);
		end,
		function()
			local ui_root = core:get_ui_root();
			local uic_parent = find_uicomponent(ui_root, "bar_small_top", "TabGroup");
			if uic_parent then
				set_component_active_with_parent(true, uic_parent, "tab_units");
				set_component_active_with_parent(true, uic_parent, "tab_regions");
				set_component_active_with_parent(true, uic_parent, "tab_factions");
			end
			cm:modify_scripting():override_ui("disable_events_dropdown_button", false);
			cm:modify_scripting():override_ui("disable_missions_dropdown_button", false);
		end
	);
	
	-------------------------------
	-- incentives
	-------------------------------
	ui_overrides.incentives = ui_override:new(
		"incentives",
		function()
			cm:modify_scripting():override_ui("disable_incentives_stack", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_incentives_stack", false);
		end
	);
	
	-------------------------------
	-- stances
	-------------------------------
	ui_overrides.stances = ui_override:new(
		"stances",
		function()
			cm:modify_scripting():override_ui("disable_stances_stack", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_stances_stack", false);
		end
	);
	
	-------------------------------
	-- province_details
	-------------------------------
	ui_overrides.province_details = ui_override:new(
		"province_details",
		function()
			cm:modify_scripting():override_ui("disable_province_details", true);
			local ui_root = core:get_ui_root();
			cm:modify_scripting():override_ui("disable_province_details", true);
			set_component_active_with_parent(false, ui_root, "info_panel_holder", "button_province_details");
		end,
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(true, ui_root, "info_panel_holder", "button_province_details");
			cm:modify_scripting():override_ui("disable_province_details", false);
		end
	);
	
	-------------------------------
	-- character_details
	-------------------------------
	ui_overrides.character_details = ui_override:new(
		"character_details",
		function()
			cm:modify_scripting():override_ui("disable_character_details_panel", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_character_details_panel", false);
		end
	);
	
	-------------------------------
	-- force_details
	-------------------------------
	ui_overrides.force_details = ui_override:new(
		"force_details",
		function()
			cm:modify_scripting():override_ui("disable_force_details_panel", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_force_details_panel", false);
		end
	);

	-------------------------------
	-- raise_army
	-------------------------------
	ui_overrides.raise_army = ui_override:new(
		"raise_army",
		function()
			cm:modify_scripting():override_ui("disable_enlist_general", true);
			local ui_root = core:get_ui_root();
			cm:modify_scripting():override_ui("disable_enlist_general", true);
			set_component_active_with_parent(false, ui_root, "button_group_settlement", "button_create_army");
		end,
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(true, ui_root, "button_group_settlement", "button_create_army");
			cm:modify_scripting():override_ui("disable_enlist_general", false);
		end
	);
	
	-------------------------------
	-- replace_general
	-------------------------------
	ui_overrides.replace_general = ui_override:new(
		"replace_general",
		function()
			cm:modify_scripting():override_ui("disable_replace_general", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_replace_general", false);
		end
	);
	
	-------------------------------
	-- recruit_units
	-------------------------------
	ui_overrides.recruit_units = ui_override:new(
		"recruit_units",
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(false, ui_root, "button_group_army", "button_recruitment");
			cm:modify_scripting():override_ui("disable_recruit_units", true);
		end,
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(true, ui_root, "button_group_army", "button_recruitment");
			cm:modify_scripting():override_ui("disable_recruit_units", false);
		end
	);
	
	-------------------------------
	-- enlist_agent
	-------------------------------
	ui_overrides.enlist_agent = ui_override:new(
		"enlist_agent",
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(false, ui_root, "button_group_settlement", "button_agents");
			cm:modify_scripting():override_ui("disable_enlist_agent", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_enlist_agent", false);
			local ui_root = core:get_ui_root();
			cm:modify_scripting():override_ui("disable_enlist_agent", false);
			set_component_active_with_parent(true, ui_root, "button_group_settlement", "button_agents");
		end
	);
	
	-------------------------------
	-- recruit_mercenaries
	-------------------------------
	ui_overrides.recruit_mercenaries = ui_override:new(
		"recruit_mercenaries",
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(false, ui_root, "button_group_army", "button_mercenaries");
			cm:modify_scripting():override_ui("disable_recruit_mercenaries", true);
		end,
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(true, ui_root, "button_group_army", "button_mercenaries");
			cm:modify_scripting():override_ui("disable_recruit_mercenaries", false);
		end
	);
	
	-------------------------------
	-- faction_button
	-------------------------------
	ui_overrides.faction_button = ui_override:new(
		"faction_button",
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(false, ui_root, "button_group_management", "button_factions");
			cm:modify_scripting():override_ui("disable_clan_button", true);
		end,
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(true, ui_root, "button_group_management", "button_factions");
			cm:modify_scripting():override_ui("disable_clan_button", false);
		end
	);
	
	-------------------------------
	-- missions
	-------------------------------
	ui_overrides.missions = ui_override:new(
		"missions",
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("button_missions", "show_objectives", true);
			cm:modify_scripting():override_ui("disable_missions_button", true);
			set_component_active_with_parent(false, ui_root, "button_missions");
		end,
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("button_missions", "show_objectives", false);
			cm:modify_scripting():override_ui("disable_missions_button", false);
			set_component_active_with_parent(true, ui_root, "button_missions");
		end
	);
	
	-------------------------------
	-- finance
	-------------------------------
	ui_overrides.finance = ui_override:new(
		"finance",
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("button_finance", "show_finance", true);
			cm:modify_scripting():override_ui("disable_finance_button", true);
			set_component_active_with_parent(false, ui_root, "button_finance");
		end,
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("button_finance", "show_finance", false)
			cm:modify_scripting():override_ui("disable_finance_button", false);
			set_component_active_with_parent(true, ui_root, "button_finance");
		end
	);

	-------------------------------
	-- technology
	-------------------------------

	ui_overrides.technology = ui_override:new(
		"technology",
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("button_technology", "show_technologies", true)
			cm:modify_scripting():override_ui("disable_tech_button", true);
			set_component_active_with_parent(false, ui_root, "button_technology");
			set_component_visible_with_parent(false, ui_root, "faction_buttons_docker", "button_technology", "alert_icon");
		end,
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("button_technology", "show_technologies", false)
			cm:modify_scripting():override_ui("disable_tech_button", false);
			set_component_active_with_parent(true, ui_root, "button_technology");
			
			if core:is_ui_created() then
				-- CampaignUI.UpdateTechButton();
			end;
		end
	);
	
	-------------------------------
	-- diplomacy
	-------------------------------
	ui_overrides.diplomacy = ui_override:new(
		"diplomacy",
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("button_diplomacy", "show_diplomacy", true);
			cm:modify_scripting():override_ui("disable_diplomacy", true);
			set_component_active_with_parent(false, ui_root, "button_diplomacy");
		end,
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("button_diplomacy", "show_diplomacy", false);
			cm:modify_scripting():override_ui("disable_diplomacy", false);
			set_component_active_with_parent(true, ui_root, "button_diplomacy");
		end
	);
	
	-------------------------------
	-- tactical_map
	-------------------------------
	ui_overrides.tactical_map = ui_override:new(
		"tactical_map",
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("camera", "show_tactical_map", true);
			cm:modify_scripting():override_ui("disable_campaign_tactical_map", true);
			set_component_active_with_parent(false, ui_root, "bar_small_top", "button_tactical_map");
		end,
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():disable_shortcut("camera", "show_tactical_map", false);
			cm:modify_scripting():override_ui("disable_campaign_tactical_map", false);
			set_component_active_with_parent(true, ui_root, "bar_small_top", "button_tactical_map");
		end
	);
	
	-------------------------------
	-- enlist_navy
	-------------------------------
	ui_overrides.enlist_navy = ui_override:new(
		"enlist_navy",
		function()
			cm:modify_scripting():override_ui("disable_enlist_navy", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_enlist_navy", false);
		end
	);
	
	-------------------------------
	-- events_rollout
	-------------------------------
	ui_overrides.events_rollout = ui_override:new(
		"events_rollout",
		function()
			--[[
			local ui_root = core:get_ui_root();
			local uic_events_rollout = find_uicomponent(ui_root, "events_dropdown", "panel");
			if uic_events_rollout then
				if uic_events_rollout:Visible() or uic_events_rollout:CurrentAnimationId() == "show" then
					uic_events_rollout:TriggerAnimation("hide");
				end;
			else
				script_error("Couldn't find uic_events_rollout");
			end;
			]]
			
			--cm:modify_scripting():override_ui("disable_campaign_dropdowns", true);
			cm:modify_scripting():override_ui("disable_events_dropdown_button", true);
		end,
		function()
			-- cm:modify_scripting():override_ui("disable_campaign_dropdowns", false);
			cm:modify_scripting():override_ui("disable_events_dropdown_button", false);
		end
	);
	
	-------------------------------
	-- events_panel
	-------------------------------

	ui_overrides.events_panel = ui_override:new(
		"events_panel",
		function()
			cm:modify_scripting():override_ui("disable_event_panel_auto_open", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_event_panel_auto_open", false);
		end
	);

	
	-------------------------------
	-- end_turn
	-------------------------------
	ui_overrides.end_turn = ui_override:new(
		"end_turn",
		function()
			cm:modify_scripting():disable_shortcut("button_end_turn", "end_turn", true);
			cm:modify_scripting():override_ui("disable_end_turn", true);
		end,
		function()
			cm:modify_scripting():disable_shortcut("button_end_turn", "end_turn", false);
			cm:modify_scripting():override_ui("disable_end_turn", false);
		end
	);
	
	-------------------------------
	-- tax_exemption
	-------------------------------
	ui_overrides.tax_exemption = ui_override:new(
		"tax_exemption",
		function()
			set_component_active(false, "province_details_panel", "checkbox_tax_exempt");
			cm:modify_scripting():override_ui("disable_tax_exempt", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_tax_exempt", false);
			set_component_active(true, "province_details_panel", "checkbox_tax_exempt");
		end
	);
	
	-------------------------------
	-- autoresolve
	-------------------------------
	ui_overrides.autoresolve = ui_override:new(
		"autoresolve",
		function()
			cm:modify_scripting():override_ui("disable_prebattle_autoresolve", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_prebattle_autoresolve", false);
		end
	);
	
	-------------------------------
	-- autoresolve_for_advice
	-------------------------------
	ui_overrides.autoresolve_for_advice = ui_override:new(
		"autoresolve_for_advice",
		function()
			cm:modify_scripting():override_ui("disable_prebattle_autoresolve", true);
			
			-- set up a callback to set the tooltip on autoresolve buttons
			local function set_autoresolve_button_tooltip()
				local ui_root = core:get_ui_root();
				
				-- button_set_siege
				local uic_button = find_uicomponent(ui_root, "pre_battle_screen", "mid", "regular_deployment", "button_set_siege", "button_autoresolve");
				if uic_button then
					core:cache_and_set_tooltip_for_component_state(uic_button, "inactive", "campaign_localised_strings_string_attack_button_locked_for_advice");
				end;
				
				-- button_set_attack
				uic_button = find_uicomponent(ui_root, "pre_battle_screen", "mid", "regular_deployment", "button_set_attack", "button_autoresolve");
				if uic_button then
					core:cache_and_set_tooltip_for_component_state(uic_button, "inactive", "campaign_localised_strings_string_attack_button_locked_for_advice");
				end;
			end;
			
			-- call callback immediately
			set_autoresolve_button_tooltip();
			
			-- call callback again if pre-battle panel opened
			core:add_listener(
				"autoresolve_for_advice_ui_override",
				"PanelOpenedCampaign",
				function(context) 
					return context.string == "pre_battle_screen" 
				end,
				function()
					set_autoresolve_button_tooltip();
				end,
				true			
			);
			
		end,
		function()
			cm:modify_scripting():override_ui("disable_prebattle_autoresolve", false);
			
			-- restore the tooltips on the buttons
			local ui_root = core:get_ui_root();
			
			-- button_set_siege
			local uic_button = find_uicomponent(ui_root, "pre_battle_screen", "mid", "regular_deployment", "button_set_siege", "button_autoresolve");
			if uic_button then
				core:restore_tooltip_for_component_state(uic_button, "inactive", "campaign_localised_strings_string_attack_button_locked_for_advice");
			end;
			
			-- button_set_attack
			uic_button = find_uicomponent(ui_root, "pre_battle_screen", "mid", "regular_deployment", "button_set_attack", "button_autoresolve");
			if uic_button then
				core:restore_tooltip_for_component_state(uic_button, "inactive", "campaign_localised_strings_string_attack_button_locked_for_advice");
			end;
			
			core:remove_listener("autoresolve_for_advice_ui_override");
		end
	);
	
	-------------------------------
	-- maintain_siege
	-------------------------------
	ui_overrides.maintain_siege = ui_override:new(
		"maintain_siege",
		function()
			cm:modify_scripting():override_ui("disable_prebattle_continue", true);
			
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(false, ui_root, "button_set_siege", "button_continue_siege");
			set_component_active_with_parent(false, ui_root, "button_set_attack", "button_maintain_blockade");
		end,
		function()
			local ui_root = core:get_ui_root();
			set_component_active_with_parent(true, ui_root, "button_set_attack", "button_maintain_blockade");
			set_component_active_with_parent(true, ui_root, "button_set_siege", "button_continue_siege");
			
			cm:modify_scripting():override_ui("disable_prebattle_continue", false);
		end
	);
	
	-------------------------------
	-- prebattle_attack
	-------------------------------
	ui_overrides.prebattle_attack = ui_override:new(
		"prebattle_attack",
		function()
			cm:modify_scripting():override_ui("disable_prebattle_attack", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_prebattle_attack", false);
		end
	);
	
	-------------------------------
	-- prebattle_attack_for_advice
	-------------------------------
	ui_overrides.prebattle_attack_for_advice = ui_override:new(
		"prebattle_attack_for_advice",
		function()
			cm:modify_scripting():override_ui("disable_prebattle_attack", true);
			
			-- set up a callback to set the tooltip on autoresolve buttons
			local function set_attack_button_tooltip()
				local ui_root = core:get_ui_root();
				
				-- button_set_siege
				local uic_button = find_uicomponent(ui_root, "pre_battle_screen", "mid", "regular_deployment", "button_set_siege", "button_attack");
				if uic_button then
					core:cache_and_set_tooltip_for_component_state(uic_button, "inactive", "campaign_localised_strings_string_attack_button_locked_for_advice");
				end;
				
				-- button_set_attack
				uic_button = find_uicomponent(ui_root, "pre_battle_screen", "mid", "regular_deployment", "button_set_attack", "button_attack");
				if uic_button then
					core:cache_and_set_tooltip_for_component_state(uic_button, "inactive", "campaign_localised_strings_string_attack_button_locked_for_advice");
				end;
			end;
			
			-- call callback immediately
			set_attack_button_tooltip();
			
			-- call callback again if pre-battle panel opened
			core:add_listener(
				"attack_for_advice_ui_override",
				"PanelOpenedCampaign",
				function(context) 
					return context.string == "pre_battle_screen" 
				end,
				function()
					set_attack_button_tooltip();
				end,
				true			
			);
		end,
		function()
			cm:modify_scripting():override_ui("disable_prebattle_attack", false);
			
			-- restore the tooltips on the buttons
			local ui_root = core:get_ui_root();
			
			-- button_set_siege
			local uic_button = find_uicomponent(ui_root, "pre_battle_screen", "mid", "regular_deployment", "button_set_siege", "button_attack");
			if uic_button then
				core:restore_tooltip_for_component_state(uic_button, "inactive", "campaign_localised_strings_string_attack_button_locked_for_advice");
			end;
			
			-- button_set_attack
			uic_button = find_uicomponent(ui_root, "pre_battle_screen", "mid", "regular_deployment", "button_set_attack", "button_attack");
			if uic_button then
				core:restore_tooltip_for_component_state(uic_button, "inactive", "campaign_localised_strings_string_attack_button_locked_for_advice");
			end;
			
			core:remove_listener("attack_for_advice_ui_override");
		end
	);
	
	-------------------------------
	-- cancel_siege_weapons
	-------------------------------
	ui_overrides.cancel_siege_weapons = ui_override:new(
		"cancel_siege_weapons",
		function()
			cm:modify_scripting():override_ui("disable_cancel_siege_equipment", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_cancel_siege_equipment", false);
		end
	);
	
	-------------------------------
	-- retreat
	-------------------------------
	ui_overrides.retreat = ui_override:new(
		"retreat",
		function()
			-- override disabled - if uncommenting for future projects, have the UI guys add a listener for when the override gets switched so they can
			-- recalculate the state of the retreat button rather than us setting it directly (script calls that previously did this have been removed)
			cm:modify_scripting():override_ui("disable_prebattle_retreat", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_prebattle_retreat", false);
		end
	);
	
	-------------------------------
	-- dismantle_building
	-------------------------------
	ui_overrides.dismantle_building = ui_override:new(
		"dismantle_building",
		function()
			cm:modify_scripting():override_ui("disable_dismantle_building", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_dismantle_building", false);
		end
	);
	
	-------------------------------
	-- disband_unit
	-------------------------------
	ui_overrides.disband_unit = ui_override:new(
		"disband_unit",
		function()
			cm:modify_scripting():override_ui("disable_disband_unit", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_disband_unit", false);
		end
	);
	
	-------------------------------
	-- repair_building
	-------------------------------
	ui_overrides.repair_building = ui_override:new(
		"repair_building",
		function()
			cm:modify_scripting():override_ui("disable_repair_building", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_repair_building", false);
		end
	);
	
	-------------------------------
	-- cancel_construction
	-------------------------------
	ui_overrides.cancel_construction = ui_override:new(
		"cancel_construction",
		function()
			cm:modify_scripting():override_ui("disable_cancel_construction", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_cancel_construction", false);
		end
	);
	
	-------------------------------
	-- cancel_recruitment
	-------------------------------
	ui_overrides.cancel_recruitment = ui_override:new(
		"cancel_recruitment",
		function()
			cm:modify_scripting():override_ui("disable_cancel_recruitment", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_cancel_recruitment", false);
		end
	);
	
	-------------------------------
	-- construction_site
	-------------------------------
	ui_overrides.construction_site = ui_override:new(
		"construction_site",
		function()
			cm:modify_scripting():override_ui("disable_construction_site", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_construction_site", false);
		end
	);
	
	-------------------------------
	-- cost_display
	-------------------------------
	ui_overrides.cost_display = ui_override:new(
		"cost_display",
		function()
			cm:modify_scripting():override_ui("disable_cost_display", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_cost_display", false);
		end,
		false
	);
	
	-------------------------------
	-- dismiss_advice_end_turn
	-------------------------------
	ui_overrides.dismiss_advice_end_turn = ui_override:new(
		"dismiss_advice_end_turn",
		function()
			cm:modify_scripting():override_ui("disable_dismiss_advice_end_turn", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_dismiss_advice_end_turn", false);
		end,
		false
	);
	
	-------------------------------
	-- campaign_values
	-------------------------------

	ui_overrides.campaign_values = ui_override:new(
		"campaign_values",
		function()
			set_component_visible(false, "resources_bar", "treasury");
			set_component_visible(false, "resources_bar", "income");
			set_component_visible(false, "resources_bar", "food");
			set_component_visible(false, "resources_bar", "end_turn_date");
		end,
		function()
			set_component_visible(true, "resources_bar", "end_turn_date");
			set_component_visible(true, "resources_bar", "food");
			set_component_visible(true, "resources_bar", "income");
			set_component_visible(true, "resources_bar", "treasury");
		end,
		false
	);

	
	-------------------------------
	-- toggle_move_speed
	-------------------------------
	ui_overrides.toggle_move_speed = ui_override:new(
		"toggle_move_speed",
		function()
			cm:modify_scripting():disable_shortcut("root", "toggle_move_speed", true);
		end,
		function()
			cm:modify_scripting():disable_shortcut("root", "toggle_move_speed", false);
		end
	);
		
	-------------------------------
	-- end_of_turn_warnings
	-------------------------------
	ui_overrides.end_of_turn_warnings = ui_override:new(
		"end_of_turn_warnings",
		function()
			cm:modify_scripting():override_ui("disable_end_of_turn_warnings", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_end_of_turn_warnings", false);
		end
	);
	

	-------------------------------
	-- bankruptcy_warning
	-------------------------------
	ui_overrides.bankruptcy_warning = ui_override:new(
		"bankruptcy_warning",
		function()
			self:suppress_end_of_turn_warning("bankrupt", true);
		end,
		function()
			self:suppress_end_of_turn_warning("bankrupt", false);
		end
	);
	
	-------------------------------
	-- technology_warning
	-------------------------------
	ui_overrides.technology_warning = ui_override:new(
		"technology_warning",
		function()
			self:suppress_end_of_turn_warning("tech", true);
		end,
		function()
			self:suppress_end_of_turn_warning("tech", false);
		end
	);
	
	-------------------------------
	-- edicts_warning
	-------------------------------
	ui_overrides.edicts_warning = ui_override:new(
		"edicts_warning",
		function()
			self:suppress_end_of_turn_warning("edict", true);
		end,
		function()
			self:suppress_end_of_turn_warning("edict", false);
		end
	);
	
	-------------------------------
	-- character_skills_warning
	-------------------------------
	ui_overrides.character_skills_warning = ui_override:new(
		"character_skills_warning",
		function()
			self:suppress_end_of_turn_warning("character", true);
		end,
		function()
			self:suppress_end_of_turn_warning("character", false);
		end
	);
	
	-------------------------------
	-- force_skills_warning
	-------------------------------
	ui_overrides.force_skills_warning = ui_override:new(
		"force_skills_warning",
		function()
			self:suppress_end_of_turn_warning("army", true);
		end,
		function()
			self:suppress_end_of_turn_warning("army", false);
		end
	);
	
	-------------------------------
	-- governor_warning
	-------------------------------
	ui_overrides.governor_warning = ui_override:new(
		"governor_warning",
		function()
			self:suppress_end_of_turn_warning("politics", true);
		end,
		function()
			self:suppress_end_of_turn_warning("politics", false);
		end
	);
	
	-------------------------------
	-- siege_equipment_warning
	-------------------------------
	ui_overrides.siege_equipment_warning = ui_override:new(
		"siege_equipment_warning",
		function()
			self:suppress_end_of_turn_warning("siege", true);
		end,
		function()
			self:suppress_end_of_turn_warning("siege", false);
		end
	);
	
	-------------------------------
	-- army_morale_warning
	-------------------------------
	ui_overrides.army_morale_warning = ui_override:new(
		"army_morale_warning",
		function()
			self:suppress_end_of_turn_warning("morale", true);
		end,
		function()
			self:suppress_end_of_turn_warning("morale", false);
		end
	);

	-------------------------------
	-- windowed_movies
	-------------------------------
	ui_overrides.windowed_movies = ui_override:new(
		"windowed_movies",
		function()
			cm:modify_scripting():override_ui("disable_windowed_movies", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_windowed_movies", false);
		end
	);
	
	-------------------------------
	-- upgrade_unit
	-------------------------------
	ui_overrides.upgrade_unit = ui_override:new(
		"upgrade_unit",
		function()
			cm:modify_scripting():override_ui("disable_upgrade_unit", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_upgrade_unit", false);
		end
	);
	
	-------------------------------
	-- sally_forth_button
	-------------------------------
	ui_overrides.sally_forth_button = ui_override:new(
		"sally_forth_button",
		function()
			cm:modify_scripting():override_ui("disable_sally_forth_button", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_sally_forth_button", false);
		end
	);
	
	-------------------------------
	-- settlement_renaming
	-------------------------------
	ui_overrides.settlement_renaming = ui_override:new(
		"settlement_renaming",
		function()
			cm:modify_scripting():override_ui("disable_settlement_renaming", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_settlement_renaming", false);
		end
	);
	
	-------------------------------
	-- food_display
	-------------------------------
	ui_overrides.food_display = ui_override:new(
		"food_display",
		function()
			cm:modify_scripting():override_ui("disable_food_display", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_food_display", false);
		end,
		false
	);
	
	-------------------------------
	-- abandon_settlements
	-------------------------------
	ui_overrides.abandon_settlements = ui_override:new(
		"abandon_settlements",
		function()
			cm:modify_scripting():override_ui("disable_abandon_settlements", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_abandon_settlements", false);
		end
	);
	
	-------------------------------
	-- non_city_building_upgrades
	-------------------------------
	ui_overrides.non_city_building_upgrades = ui_override:new(
		"non_city_building_upgrades",
		function()
			cm:modify_scripting():override_ui("disable_non_city_building_upgrades", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_non_city_building_upgrades", false);
		end
	);
	
	-------------------------------
	-- convert_religion
	-------------------------------
	ui_overrides.convert_religion = ui_override:new(
		"convert_religion",
		function()
			cm:modify_scripting():override_ui("disable_convert_religion", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_convert_religion", false);
		end
	);
	
	-------------------------------
	-- public_order_display
	-------------------------------
	ui_overrides.public_order_display = ui_override:new(
		"public_order_display",
		function()
			cm:modify_scripting():override_ui("disable_public_order_display", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_public_order_display", false);
		end,
		false
	);
	
	-------------------------------
	-- intrigue_actions
	-------------------------------
	ui_overrides.intrigue_actions = ui_override:new(
		"intrigue_actions",
		function()
			cm:modify_scripting():override_ui("disable_intrigue_actions", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_intrigue_actions", false);
		end
	);
	
	-------------------------------
	-- seek_wife
	-------------------------------
	ui_overrides.seek_wife = ui_override:new(
		"seek_wife",
		function()
			cm:modify_scripting():override_ui("disable_seek_wife", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_seek_wife", false);
		end
	);
	
	-------------------------------
	-- large_info_panels
	-------------------------------
	ui_overrides.large_info_panels = ui_override:new(
		"large_info_panels",
		function()
			cm:modify_scripting():override_ui("disable_large_info_panels", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_large_info_panels", false);
		end,
		false
	);
	
	-------------------------------
	-- building_browser
	-------------------------------
	ui_overrides.building_browser = ui_override:new(
		"building_browser",
		function()
			cm:modify_scripting():override_ui("disable_building_browser", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_building_browser", false);
		end
	);
	
	-------------------------------
	-- migration
	-------------------------------
	ui_overrides.migration = ui_override:new(
		"migration",
		function()
			cm:modify_scripting():override_ui("disable_migrate_button", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_migrate_button", false);
		end
	);
	
	-------------------------------
	-- migration_cancel
	-------------------------------
	ui_overrides.migration_cancel = ui_override:new(
		"migration_cancel",
		function()
			cm:modify_scripting():override_ui("disable_cancel_migration", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_cancel_migration", false);
		end
	);
	
	-------------------------------
	-- prebattle_save
	-------------------------------
	ui_overrides.prebattle_save = ui_override:new(
		"prebattle_save",
		function()
			cm:modify_scripting():override_ui("disable_prebattle_save", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_prebattle_save", false);
		end
	);
	
	-------------------------------
	-- resettle
	-------------------------------
	ui_overrides.resettle = ui_override:new(
		"resettle",
		function()
			cm:modify_scripting():override_ui("disable_resettle", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_resettle", false);
		end
	);
	
	-------------------------------
	-- diplomacy_audio
	-------------------------------
	ui_overrides.diplomacy_audio = ui_override:new(
		"diplomacy_audio",
		function()
			cm:modify_scripting():override_ui("disable_diplomacy_audio", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_diplomacy_audio", false);
		end
	);
	
	-------------------------------
	-- book_of_grudges
	-------------------------------
	ui_overrides.book_of_grudges = ui_override:new(
		"book_of_grudges",
		function()
			set_component_active(false, "faction_buttons_docker", "button_grudges");
		end,
		function()
			set_component_active(true, "faction_buttons_docker", "button_grudges");
		end
	);
	
	-------------------------------
	-- offices
	-------------------------------
	ui_overrides.offices = ui_override:new(
		"offices",
		function()
			set_component_active(false, "faction_buttons_docker", "button_offices");
			cm:modify_scripting():override_ui("disable_office_button", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_office_button", false);
			set_component_active(true, "faction_buttons_docker", "button_offices");
		end
	);
	
	-------------------------------
	-- grudges
	-------------------------------
	ui_overrides.grudges = ui_override:new(
		"grudges",
		function()
			set_component_active(false, "faction_buttons_docker", "button_grudges");
			cm:modify_scripting():override_ui("disable_grudge_button", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_grudge_button", false);
			set_component_active(true, "faction_buttons_docker", "button_grudges");
		end
	);
	
	-------------------------------
	-- diplomacy_double_click
	-------------------------------
	ui_overrides.diplomacy_double_click = ui_override:new(
		"diplomacy_double_click",
		function()
			cm:modify_scripting():override_ui("disable_diplomacy_double_click", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_diplomacy_double_click", false);
		end
	);
	
	-------------------------------
	-- giving_orders
	-------------------------------
	ui_overrides.giving_orders = ui_override:new(
		"giving_orders",
		function()
			cm:modify_scripting():override_ui("disable_giving_orders", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_giving_orders", false);
		end
	);
	
	-------------------------------
	-- ping_clicks
	-------------------------------
	ui_overrides.ping_clicks = ui_override:new(
		"ping_clicks",
		function()
			cm:modify_scripting():override_ui("disable_ping_clicks", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_ping_clicks", false);
		end
	);
	
	-------------------------------
	-- spell_browser
	-------------------------------
	ui_overrides.spell_browser = ui_override:new(
		"spell_browser",
		function()
			set_component_active_with_parent(false, core:get_ui_root(), "menu_bar", "button_spell_browser");
		end,
		function()
			set_component_active_with_parent(true, core:get_ui_root(), "menu_bar", "button_spell_browser");
		end
	);
	
	-------------------------------
	-- advice_settings_button
	-------------------------------
	ui_overrides.advice_settings_button = ui_override:new(
		"advice_settings_button",
		function()
			set_component_active_with_parent(false, core:get_ui_root(), "advice_interface", "button_toggle_options");
		end,
		function()
			set_component_active_with_parent(true, core:get_ui_root(), "advice_interface", "button_toggle_options");
		end
	);
	
	-------------------------------
	-- tax_slider
	-------------------------------
	ui_overrides.tax_slider = ui_override:new(
		"tax_slider",
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():override_ui("disable_tax_slider", true);
			set_component_active_with_parent(false, ui_root, "tax_information_box");
		end,
		function()
			local ui_root = core:get_ui_root();
			cm:modify_scripting():override_ui("disable_tax_slider", false);
			set_component_active_with_parent(true, ui_root, "tax_information_box");
		end
	);
	
	-------------------------------
	-- corruption
	-------------------------------
	ui_overrides.corruption = ui_override:new(
		"corruption",
		function()
			cm:modify_scripting():override_ui("disable_corruption", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_corruption", false);
		end
	);

	-------------------------------
	-- character_skill_upgrade
	-------------------------------
	ui_overrides.character_skill_upgrade = ui_override:new(
		"character_skill_upgrade",
		function()
			cm:modify_scripting():override_ui("disable_character_skill_upgrades", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_character_skill_upgrades", false);
		end
	);

	-------------------------------
	-- undercover_network
	-------------------------------
	ui_overrides.undercover_network = ui_override:new(
		"undercover_network",
		function()
			cm:modify_scripting():override_ui("disable_undercover_network", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_undercover_network", false);
		end
	);
	
	-------------------------------
	-- faction_council
	-------------------------------
	ui_overrides.faction_council = ui_override:new(
		"faction_council",
		function()
			cm:modify_scripting():override_ui("disable_faction_council", true);
		end,
		function()
			cm:modify_scripting():override_ui("disable_faction_council", false);
		end
	);

	ui_overrides.hide_faction_council = ui_override:new(
		"hide_faction_council",
		function()
			cm:modify_scripting():override_ui("hide_faction_council", true);
		end,
		function()
			cm:modify_scripting():override_ui("hide_faction_council", false);
		end
	);

	-- load in the contents of the ui_overrides table that we've just declared
	for override_name, override in pairs(ui_overrides) do
		self:register_override(override_name, override);
	end;
end;


function campaign_ui_manager:register_override(override_name, override)
	if not is_string(override_name) then
		script_error("ERROR: register_override() called but supplied override name [" .. tostring(override_name) .. "] is not a string");
		return false;
	end;
	
	if not is_uioverride(override) then
		script_error("ERROR: register_override() called but supplied override [" .. tostring(override) .. "] is not a ui override");
		return false;
	end;

	-- check that we don't already have this override
	if self.override_list[override_name] then
		script_error("WARNING: register_override() called but supplied override [" .. tostring(override_name) .. "] is already registered");
		return false;
	end;
	
	self.override_list[override_name] = override;
end;


function campaign_ui_manager:override(override_name)
	local retval = self.override_list[override_name];
	
	if not retval then
		script_error("ERROR: override() called but supplied override name [" .. tostring(override_name) .. "] could not be found");
	end;
	
	return retval;
end;


function campaign_ui_manager:print_override_list()
	local override_list = self.override_list;
	
	out.ui("***********************");
	out.ui("Printing override list:");
	out.ui("***********************");
	
	local count = 0;
	
	for override_name, override in pairs(override_list) do
		count = count + 1;
		out.ui("\t" .. override_name);
	end;
	
	out.ui("***********************");
	if count == 1 then
		out.ui("Printed 1 override");
	else
		out.ui("Printed " .. count .. " overrides");
	end;
	out.ui("***********************");
end;

