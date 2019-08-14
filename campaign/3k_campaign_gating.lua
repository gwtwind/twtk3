-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	GATING SCRIPTS
--	Declare scripts for campaign gating (when a game feature is enabled for the player) here
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

output("3k_campaign_gating.lua: Loading");

---------------------------------------------------------------
--
--	Gating Trigger Condition variables
--
---------------------------------------------------------------

tax_advice_condition = 1;       -- Trigger tax advice when progression level
spy_progression_level = 1;          -- Trigger advice based on the progression level 2

---------------------------------------------------------------
--
--	Gating Conditions and UI Locking
--
---------------------------------------------------------------

function setup_gating()

    -- guard against being called in autoruns
	if not cm:get_local_faction(true) then
        output("*-* gating.lua: not starting gating as this is an autorun");
        return
    end;
    
    local faction = cm:query_local_faction():name();
    local subculture = cm:query_local_faction():subculture();

    output("*-* gating.lua: Initialise");
	output("*-* gating.lua: local faction is " .. faction);
    
    if core:is_tweaker_set("FORCE_DISABLE_GATING") then
        return
	end;
	


	-- Local test functions.
	local function has_unlocked_unit_recruitment()
		return cm:turn_number() >= 2;
	end;

	local function has_unlocked_tax_slider(query_faction)
		return query_faction:progression_level() >= tax_advice_condition and query_faction:is_human();
	end;

	local function has_unlocked_corruption(query_faction)
		local region_list = query_faction:faction_province_list();
		
		for i = 0, region_list:num_items() - 1 do
			local region = region_list:item_at(i);

			if region:tax_administration_cost() ~= 0 then
				return true
			end

			output("*-* gating.lua: Corruption check for provinces " .. region:tax_administration_cost());
		end

		return false;
	end;

	local function has_unlocked_spies(query_faction)
		local progression_level = query_faction:progression_level()

		output("*-* gating.lua: Current progression level is " .. progression_level)
		if query_faction:is_human() then
			return progression_level >= spy_progression_level 
				or query_faction:has_technology("3k_main_tech_water_tier1_masterful_disguise_techniques");
		end
		return false;
	end;

	local function has_unlocked_faction_council( query_faction )
		return query_faction:progression_level() >= 1 and query_faction:is_human();
	end;

	local function has_unlocked_retreat_from_battle( pending_battle )
		if pending_battle then
			if pending_battle:has_attacker() then
				return pending_battle:attacker():faction():is_human()
			end

			if pending_battle:has_defender() then
				return pending_battle:defender():faction():is_human()
			end
		else
			return cm:turn_number() >= 2;
		end;
	end;


	
	-- script to disable recruitment UI for first turn --
	if not cm:get_saved_value("recruit_units_unlocked") 
		and not has_unlocked_unit_recruitment() then 

        output("*-* gating.lua: recruit_units locked");
        uim:override("recruit_units"):set_allowed(false);
		cm:modify_scripting():add_event_restrict_all_units("");
	else
		output("*-* gating.lua: recruit_units unlocked");
		uim:override("recruit_units"):set_allowed(true);
		cm:modify_scripting():remove_event_restrict_all_units("");
    end;
    
    if faction ~= "3k_main_faction_dong_zhuo" then
        -- script to disable tax slider UI for first turn --
		if not cm:get_saved_value("gating_tax_unlocked") 
			and not has_unlocked_tax_slider( cm:query_local_faction() ) then 

            output("*-* gating.lua: tax_slider locked");
			uim:override("tax_slider"):set_allowed(false);
		else
			output("*-* gating.lua: tax_slider unlocked");
			uim:override("tax_slider"):set_allowed(true);
        end;
    end;

    if faction ~= "3k_main_faction_dong_zhuo" then
        -- script to disable corruption UI for first turn --
		if not cm:get_saved_value("gating_corruption_unlocked") 
			and not has_unlocked_corruption( cm:query_local_faction() ) then

            output("*-* gating.lua: corruption locked"); 
			uim:override("corruption"):set_allowed(false);
		else
			output("*-* gating.lua: corruption unlocked"); 
			uim:override("corruption"):set_allowed(true);
        end;
    end;
    
    if faction ~= "3k_main_faction_dong_zhuo" then
        -- script to disable spy UI for first turn --
		if not cm:get_saved_value("gating_spy_unlocked") 
			and not has_unlocked_spies( cm:query_local_faction() ) then 

            output("*-* gating.lua: undercover_network locked");
			uim:override("undercover_network"):set_allowed(false);
		else
			output("*-* gating.lua: undercover_network unlocked");
			uim:override("undercover_network"):set_allowed(true);
        end;
    end;

    if faction ~= "3k_main_faction_dong_zhuo" then
        -- script to disable faction council UI for first turn --
		if not cm:get_saved_value("gating_faction_council_unlocked") 
			and not has_unlocked_faction_council( cm:query_local_faction() ) then 

            output("*-* gating.lua: faction_council locked");
			uim:override("faction_council"):set_allowed(false);
		else
			output("*-* gating.lua: faction_council unlocked");
			uim:override("faction_council"):set_allowed(true);
        end;
    end;

    if faction ~= "3k_main_faction_dong_zhuo" then
        -- script to disable retreat button for first battle --
		if not cm:get_saved_value("retreat_unlocked")
			and not has_unlocked_retreat_from_battle() then

            output("*-* gating.lua: retreat locked");
			uim:override("retreat"):set_allowed(false);
		else
			output("*-* gating.lua: retreat unlocked");
			uim:override("retreat"):set_allowed(true);
        end;
    end;
 
    ---------------------------------------------------------------
    --
    --	Retreat disable
    --
    ---------------------------------------------------------------

    if not uim:override("retreat"):get_allowed() then
		output("*-* gating.lua: ### establishing retreat button listener")
        core:add_listener(
            "battle retreat button listener",
            "BattleCompleted", 
            function(context)
                return has_unlocked_retreat_from_battle( context:query_model():pending_battle() );
            end,
            function(context)
                cm:set_saved_value("retreat_unlocked", true);
                out.interventions("*-* gating.lua: ### retreat reenabled");
                uim:override("retreat"):set_allowed(true);
                core:remove_listener("battle retreat button listener");
            end,
            false
        )
    end;

    ---------------------------------------------------------------
    --
    --	Faction Council condition
    --
    ---------------------------------------------------------------

    if not uim:override("faction_council"):get_allowed() then
		output("*-* gating.lua: ### establishing faction council listener")
        core:add_listener(
            "faction council restriction",
            "FactionFameLevelUp", 
            function(context)
				return has_unlocked_faction_council( context:faction() );
            end,
            function(context)
                cm:set_saved_value("gating_faction_council_unlocked", true);
                output("*-* gating.lua: ### re-enabling faction council");
                uim:override("faction_council"):set_allowed(true);
                core:trigger_event("ScriptEventFactionCouncil")
            end,
            false
        )
    end;

    ---------------------------------------------------------------
    --
    --	Recruitment condition
    --
    ---------------------------------------------------------------

    if not uim:override("recruit_units"):get_allowed() then
		output("*-* gating.lua: ### establishing recruitment listener")
        core:add_listener(
            "unit recruitment restriction",
            "ScriptEventPlayerFactionTurnStart", 
            function(context)
                return has_unlocked_unit_recruitment();
            end,
            function(context)
                cm:set_saved_value("recruit_units_unlocked", true);
                output("*-* gating.lua: ### re-enabling unit recruitment");
				uim:override("recruit_units"):set_allowed(true);
				cm:modify_scripting():remove_event_restrict_all_units("");
            end,
            false
        )
    end;

    ---------------------------------------------------------------
    --
    --	Tax condition
    --
    ---------------------------------------------------------------

    if not uim:override("tax_slider"):get_allowed() then
        output("*-* gating.lua: ### establishing tax_slider listener")
        core:add_listener(
            "tax_slider restriction",
            "FactionFameLevelUp", 
			function(context)
				return has_unlocked_tax_slider( context:faction() );
            end,
            function(context)
                cm:set_saved_value("gating_tax_unlocked", true);
                -- Re-enabling tax slider --
                uim:override("tax_slider"):set_allowed(true);
                output("*-* gating.lua: ### re-enabling tax_slider");
            end,
            false
        )
    end;

    ---------------------------------------------------------------
    --
    --	Corruption condition
    --
    ---------------------------------------------------------------

    if not uim:override("corruption"):get_allowed() then
        output("*-* gating.lua: ### establishing corruption listener")
        core:add_listener(
            "corruption restriction",
            "ScriptEventPlayerFactionTurnStart", 
                function(context)
					return has_unlocked_corruption( context:faction() );
                end,
            function(context)
                cm:set_saved_value("gating_corruption_unlocked", true);
                -- Re-enabling corruption display --
                uim:override("corruption"):set_allowed(true);
                output("*-* gating.lua: ### re-enabling corruption");
            end,
            false
        )
    end;

    ---------------------------------------------------------------
    --
    --	Spy condition
    --
    ---------------------------------------------------------------

    if not uim:override("undercover_network"):get_allowed() then
        output("*-* gating.lua: ### establishing spy listener")
        core:add_listener(
            "spy restriction",
            "FactionFameLevelUp", 
			function(context)
				return has_unlocked_spies( context:faction() );
            end,
            function(context)
                core:trigger_event("ScriptEventSpyAdvice");
                cm:set_saved_value("gating_spy_unlocked", true);
                -- Re-enabling spy display --
                uim:override("undercover_network"):set_allowed(true);
                output("*-* gating.lua: ### re-enabling spies");
            end,
            false
        )

        output("*-* gating.lua: ### establishing spy listener 2")
        core:add_listener(
            "spy restriction 2",
            "ResearchStarted", 
            function(context)
                local technology = context:technology_record_key()
                output("######## Current technology completed is " .. technology)
                if technology == "3k_main_tech_water_tier1_masterful_disguise_techniques" then
                    return context:faction():is_human()
                end
            end,
            function(context)
                core:trigger_event("ScriptEventSpyAdvice");
                cm:set_saved_value("gating_spy_unlocked", true);
                -- Re-enabling spy display --
                uim:override("undercover_network"):set_allowed(true);
                output("*-* gating.lua: ### re-enabling spies");
            end,
            false
        )
    end;

end;

