-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	GATING SCRIPTS
--	Declare scripts for campaign gating (when a game feature is enabled for the player) here
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

output("ep_campaign_gating.lua: Loading");

---------------------------------------------------------------
--
--	Gating Trigger Condition variables
--
---------------------------------------------------------------

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
	


	local function has_unlocked_spies(query_faction)
		local progression_level = query_faction:progression_level()

		output("*-* gating.lua: Current progression level is " .. progression_level)
		if query_faction:is_human() then
			return progression_level >= spy_progression_level 
		end
		return false;
	end;

	local function has_unlocked_faction_council( query_faction )
		return query_faction:progression_level() >= 1 and query_faction:is_human();
	end;

	
    if faction ~= "ep_faction_prince_of_zhao" then
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
    end;

end;

