---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			3k_campaign_man_of_the_hour.lua, 
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to spawn an ancillary on a character when they spawn.

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

out.design("3k_campaign_man_of_the_hour.lua: Loading");

man_of_the_hour = {
	is_debug = true,
	debug_ignore_chance = false;
	dilemma_choice_spawn_id = 0;
	first_trigger_round = 0;
	first_trigger_round_ambient = 2;
    min_rounds_between_triggers = 3;
    min_rounds_between_triggers_yt = 0;
    min_rounds_between_triggers_sima_yong = 1;
	last_trigger_turn = 0;
	garrison_occuped = false;
};

--[[

EMERGENCE CHANCES

Done by Faction -> Subculture -> Culture. Must have some valid data to fall back to.

]]-- 
man_of_the_hour.faction_overrides = -- HIGHEST PRIORITY, WILL USE THIS IF IT FINDS IT
{
    ["3k_main_faction_zheng_jiang"] = {
        min_emergence_chance = 0, -- Min chance, as a fraction, of a character emerging.
        max_emergence_chance = 0.08, -- Max chance, as fraction, of a character emerging.
        min_positions_per_progression_level = 1, -- The estimates max characters in a faction * progression level.
        coefficient = 0.8, -- Affects steepness of the chance curve (lower = less steep)
    };

    -- Eight Princes: Sima Yong, Discoverer of Rare Talent, with higher MoH chance
    ["ep_faction_prince_of_hejian"] = {
        min_emergence_chance = 0, -- Min chance, as a fraction, of a character emerging.
        max_emergence_chance = 0.75, -- Max chance, as fraction, of a character emerging.
        min_positions_per_progression_level = 20, -- The estimates max characters in a faction * progression level.
        coefficient = 0.1, -- Affects steepness of the chance curve (lower = less steep)
    }
};

man_of_the_hour.subculture_overrides = -- SECOND HIGHEST PRIORITY
{
    ["3k_main_subculture_yellow_turban"] = {
        min_emergence_chance = 0, -- Min chance, as a fraction, of a character emerging.
        max_emergence_chance = 0.75, -- Max chance, as fraction, of a character emerging.
        min_positions_per_progression_level = 10, -- The estimates max characters in a faction * progression level.
		coefficient = 0.25, -- Affects steepness of the chance curve (lower = less steep)
		ambient_spawning_enabled = true, -- Can spawn characters on_turn_start
        ambient_spawning_min_positions_per_progression_level = 6,  -- The estimates max characters in a faction * progression level.
        dilemma_land_attack = 
        {
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_01_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_02_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_03_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_04_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_05_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_06_dilemma"
        },
        dilemma_land_defence = 
        {
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_01_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_02_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_03_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_04_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_05_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_06_dilemma"
        },
        dilemma_ambush_attack = 
        {
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_01_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_02_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_03_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_04_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_05_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_06_dilemma"
        },
        dilemma_ambush_defence = 
        {
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_01_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_02_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_03_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_04_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_05_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_06_dilemma"
        },
        dilemma_siege_attack = 
        {
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_01_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_02_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_03_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_04_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_05_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_06_dilemma"
        },
        dilemma_siege_defence = 
        {
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_01_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_02_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_03_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_04_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_05_dilemma",
            "3k_ytr_man_of_the_hour_battle_won_yellow_turban_06_dilemma"
        },
        dilemma_occupation =
        {
            "3k_ytr_man_of_the_hour_occupation_yellow_turban_01_dilemma",
            "3k_ytr_man_of_the_hour_occupation_yellow_turban_02_dilemma"
        },
		dilemma_ambient = 
		{}
    }
};

man_of_the_hour.culture_overrides = -- LOWEST PRIORITY
{
    ["3k_main_chinese"] = {
        min_emergence_chance = 0, -- Min chance, as a fraction, of a character emerging.
        max_emergence_chance = 0.08, -- Max chance, as fraction, of a character emerging.
        min_positions_per_progression_level = 5, -- The estimates max characters in a faction * progression level.
		coefficient = 0.8, -- Affects steepness of the chance curve (lower = less steep)
		ambient_spawning_enabled = false, -- Can spawn characters on_turn_start
        ambient_spawning_min_positions_per_progression_level = 2,  -- The estimates max characters in a faction * progression level.
        dilemma_occupation =
        {
            "3k_main_man_of_the_hour_occupation_generic_aggressive_dilemma",
            "3k_main_man_of_the_hour_occupation_generic_passive_dilemma"
        },
        dilemma_land_attack = 
        {
            "3k_main_man_of_the_hour_battle_won_generic_land_attack_dilemma"
        },
        dilemma_land_defence = 
        {
            "3k_main_man_of_the_hour_battle_won_generic_land_defence_dilemma"
        },
        dilemma_ambush_attack = 
        {
            "3k_main_man_of_the_hour_battle_won_generic_ambush_attack_dilemma"
        },
        dilemma_ambush_defence = 
        {
            "3k_main_man_of_the_hour_battle_won_generic_ambush_defence_dilemma"
        },
        dilemma_siege_attack = 
        {
            "3k_main_man_of_the_hour_battle_won_generic_siege_attack_dilemma"
        },
        dilemma_siege_defence = 
        {
            "3k_main_man_of_the_hour_battle_won_generic_siege_defence_dilemma"
		},
		dilemma_ambient = 
		{}
    }
};



---------------------------------------------------------------------------------------------------------
----- Initialise
---------------------------------------------------------------------------------------------------------



--[[ man_of_the_hour:initialise()
	    Add listeners and other methods.
]]--
function man_of_the_hour:initialise()

    out.design("3k_campaign_man_of_the_hour.lua: Initialise");

    -- Fires dilemmas for the player
    core:add_listener(
        "man_of_the_hour_battle_completed", -- UID
        "CampaignBattleLoggedEvent", -- CampaignEvent
        true, --Conditions for firing
        function(event)
			local modify_model = event:modify_model();
			local winner_result = event:log_entry():winner_result();
			local winning_factions = event:log_entry():winning_factions();

			if winner_result == "draw" then
				output("We got a draw.");
				return false;
			end; 

			for i=0, winning_factions:num_items() - 1 do
				local faction_key = winning_factions:item_at( i ):name();

				core:add_listener(
					"moh_dilemma_trigger_events", -- Unique handle
					"BattleCompleted", -- Campaign Event to listen for
					true,
					function(context) -- What to do if listener fires.
						local faction = cm:query_faction(faction_key);
						local pb = context:query_model():pending_battle(); -- Pending battle just so we can see if the attacker won.

						if faction_key == "rebels" then
							return false;
						end;

						--Do Stuff Here
						if not faction or faction:is_null_interface() then
							script_error("ERROR: Tried to fire Man of the Hour for faction [" .. tostring(faction_key) .. "] but this is not a valid faction." );
							return false;
						end;

						self:spawn_man_of_the_hour( faction, self:get_battle_dilemma_keys( faction, winner_result, pb ) );
						
					end,
					false --Is persistent
				);
				
			end
        end, -- Function to fire.
        true -- Is Persistent?
    );

    -- Triggers event on garrison occupied.
    core:add_listener(
		"man_of_the_hour_garrison_occupied_event", -- UID
		"GarrisonOccupiedEvent", -- Event
        true, --Conditions for firing
        function(garrison_occupied_event)
            if self.is_debug then
                out.design("man_of_the_hour:GarrisonOccupiedEvent(): Garrison Occupied, Spawn Character.");
			end;
			
			local faction_key = garrison_occupied_event:query_character():faction():name();

			if not faction_key then
				return;
			end;

			core:add_listener(
				"moh_dilemma_trigger_events_garrison_occupied", -- Unique handle
				"BattleCompleted", -- Campaign Event to listen for
				true,
				function(context) -- What to do if listener fires.
					local faction = cm:query_faction(faction_key);
					--Do Stuff Here
					self:spawn_man_of_the_hour( faction, self:get_occupation_dilemma_keys( faction ), false );
				end,
				false --Is persistent
			);

		end, -- Function to fire.
		true -- Is Persistent?
	);

	-- If the faction can, this will spawn characters on turn start to stop them getting too weak.
	core:add_listener(
		"man_of_the_hour_turn_start_event", -- Unique handle
		"FactionTurnStart", -- Campaign Event to listen for
		function(context) -- Criteria
			-- Only allow this if ambient spawning is enabled.
			return context:faction():name() ~= "rebels" and self:get_overridden_variable( "ambient_spawning_enabled", context:faction() );
		end,
		function(context) -- What to do if listener fires.
			--Do Stuff Here
            self:spawn_man_of_the_hour( context:faction(), self:get_turn_start_dilemma_keys( context:faction() ), true );
		end,
		true --Is persistent
	);
	

	-- DEBUG
	-- Example: trigger_cli_debug_event moh.toggle_debug_mode()
	core:add_cli_listener("moh.toggle_debug_mode", 
		function()
			self.debug_ignore_chance = not self.debug_ignore_chance;
			out.design( "man_of_the_hour:toggle_debug_mode(): Ignore Chance = " .. tostring(self.debug_ignore_chance) );
		end
	);

	-- Example: trigger_cli_debug_event moh.trigger_man_of_the_hour(3k_main_faction_cao_cao)
	core:add_cli_listener("moh.trigger_man_of_the_hour", 
		function( faction_key, is_battle )
			local faction = cm:query_faction( faction_key );
			local pb = cm:query_model():pending_battle();
			if not is_battle then
				self:spawn_man_of_the_hour( faction, self:get_occupation_dilemma_keys( faction ) );
			else
				self:spawn_man_of_the_hour( faction, self:get_battle_dilemma_keys( faction, "decisive_victory", pb ) );
			end;
			out.design( "man_of_the_hour:toggle_debug_mode(): Triggering MOH" );
		end
	);
end;


---------------------------------------------------------------------------------------------------------
----- Methods
---------------------------------------------------------------------------------------------------------


--[[ man_of_the_hour:spawn_man_of_the_hour()
	    Attempts to spawn a man of the hour.
]]--
function man_of_the_hour:spawn_man_of_the_hour( query_faction, dilemma_keys, is_ambient )
	is_ambient = is_ambient or false;

	if not query_faction or query_faction:is_null_interface() then -- Exit if we didn't get a commander.
		script_error("ERROR: man_of_the_hour:spawn_man_of_the_hour() Invalid faction passed in.")
		return;
	end;

	local modify_faction = cm:modify_faction( query_faction );
	local modify_model = cm:modify_model();
    local current_turn_number = cm:query_model():turn_number();
    local progression_level = query_faction:progression_level() + 1; -- Progression level is 0 indexed, so breaks maths.
    local ambient_moh_spawn_count = cm:random_number(1, progression_level);

	if query_faction:name() == "rebels" then -- Don't fire for rebels.
		return;
	end;

		
    -- Debug system for testing.
	if self.debug_ignore_chance then
		script_error("man_of_the_hour:spawn_man_of_the_hour(): being forced to ignore chance. DISABLE ME!");
	else
		-- Check we've reached our start turn.
		if is_ambient and current_turn_number < self.first_trigger_round_ambient then
			out.design("man_of_the_hour:spawn_man_of_the_hour(): Ambient spawning is waiting for first round.");
			return;
		elseif current_turn_number < self.first_trigger_round then
			out.design("man_of_the_hour:spawn_man_of_the_hour(): Waiting for first round.");
			return;
		else
			-- Make sure enough turns have elapsed between triggers.
			local last_trigger_turn = 0;
			if cm:saved_value_exists("last_trigger_turn", "man_of_the_hour", query_faction:name()) then
				last_trigger_turn = cm:get_saved_value("last_trigger_turn", "man_of_the_hour", query_faction:name());
			end;

            -- Is the faction Yellow Turban? Use a special round timer.
            if query_faction:subculture() == "3k_main_subculture_yellow_turban" then
                out.design( "Faction is Yellow Turban." );
                if current_turn_number < last_trigger_turn + self.min_rounds_between_triggers_yt then
                    out.design( "Faction: " .. query_faction:name() .. ", not enough rounds have elapsed.");
                    return;
                end;
            
            -- Is the faction Sima Yong, Prince of Hejian? Use a special round timer.
            elseif query_faction:name() == "ep_faction_prince_of_hejian" then
                out.design( "Faction is Sima Yong, Prince of Hejian." );
                if current_turn_number < last_trigger_turn + self.min_rounds_between_triggers_sima_yong then
                    out.design( "Faction: " .. query_faction:name() .. ", not enough rounds have elapsed.");
                    return;
                end;
            
            -- Is the faction anyone else? Then use the default round timer.
            else
                if current_turn_number < last_trigger_turn + self.min_rounds_between_triggers then
                    out.design( "Faction: " .. query_faction:name() .. ", not enough rounds have elapsed.");
                    return;
                end;
            end;
		end;

		if not self:roll_emergence_chance( query_faction, modify_model, is_ambient ) then -- Check our chance.
			return;
		end;
    end;

	out.design("man_of_the_hour:spawn_man_of_the_hour(): Spawning Man of the Hour.");

	-- Store the last fired turn
	cm:set_saved_value("last_trigger_turn", cm:query_model():turn_number(), "man_of_the_hour", query_faction:name() );

	inc_tab();
	if query_faction:is_human() then
		if dilemma_keys then -- HUMAN factions
			self:fire_choice_dilemma(modify_faction, false, dilemma_keys); -- Spawns character based on listener from dilemma.
		else
			if progression_level <=3 then
                out.design("man_of_the_hour:spawn_man_of_the_hour(): Faction rank 1-3: spawning 1 man of the hour.");
                local random_moh = cm:random_number(0,1);

                for i = random_moh, 0, -1 do
                    self:spawn_character(modify_faction, false);
                end;
                out.design("man_of_the_hour:spawn_man_of_the_hour(): Number: "..tostring(math.ceil(random_moh)));

            elseif progression_level == 4 or progression_level == 5 then
                out.design("man_of_the_hour:spawn_man_of_the_hour(): Faction rank 4-5: spawning 1 man of the hour.");
                local random_moh = cm:random_number(0,1);

                for i = random_moh, 0, -1 do
                    self:spawn_character(modify_faction, false);
                end;
                out.design("man_of_the_hour:spawn_man_of_the_hour(): Number: "..tostring(math.ceil(random_moh)));

            else   
                out.design("man_of_the_hour:spawn_man_of_the_hour(): Faction rank 6+: spawning 1-2 men of the hour.");
                local random_moh = cm:random_number(0,2);

                for i = random_moh, 0, -1 do
                    self:spawn_character(modify_faction, false);
                end;
                out.design("man_of_the_hour:spawn_man_of_the_hour(): Number: "..tostring(math.ceil(random_moh)));
          end;
		end;
	else -- AI Factions, or when we didn't have any dilemma keys.
        self:spawn_character(modify_faction, true);
	end;
	dec_tab();
end;


--[[ man_of_the_hour:roll_emergence_chance()
	    Do a random check to see if we should spawn a MOH.
]]--
function man_of_the_hour:roll_emergence_chance( query_faction, modify_model, is_ambient )
	local progression_level = query_faction:progression_level() + 1; -- Progression level is 0 indexed, so breaks maths.
	local is_world_leader = query_faction:is_world_leader();
    local filled_positions = query_faction:number_of_employed_characters();
    local filled_pool_slots = query_faction:number_of_characters_in_recruitment_pool();
    local max_pool_slots = query_faction:maximum_characters_in_recruitment_pool();

	if is_world_leader then -- emperor isn't a real rank so let's just pretend it is
		progression_level = progression_level + 1 
	end;

    -- Get the overridden data sets.
	local min_emerge_chance = self:get_overridden_variable("min_emergence_chance", query_faction);
	local max_emerge_chance = self:get_overridden_variable("max_emergence_chance", query_faction);
	
	-- Min positions is the lower threshold at which we ALWAYS spawn a character.
	local min_positions = self:get_overridden_variable("min_positions_per_progression_level", query_faction);

	-- Ambient spawning has a different minumum.
	if is_ambient and self:get_overridden_variable("ambient_spawning_min_positions_per_progression_level", query_faction) then
		min_positions = self:get_overridden_variable("ambient_spawning_min_positions_per_progression_level", query_faction);
	end;

	min_positions = min_positions * progression_level;

    local coefficient = self:get_overridden_variable("coefficient", query_faction);
	
	
    -- Check for null values.
    if not min_emerge_chance then
        script_error("We have a missing value! min_emerge_chance");
        return false;
    end;

    if not max_emerge_chance then
        script_error("We have a missing value! max_emerge_chance");
        return false;
    end;

    if not min_positions then
        script_error("We have a missing value! min_positions");
        return false;
    end;

    if not coefficient then
        script_error("We have a missing value! coefficient");
        return false;
    end;


	local total_num_characters = filled_pool_slots + filled_positions;
	
	-- MIN( EXP( -coeficcient*( num_chars - offset ) * 100 ), 100)
	-- coefficient = steepness of curve.
	-- min_positions = the lower threshold at which we want to garuantee characters. (i.e. max chance)
	-- allowed_max/allowed_min = a clamp!
	local exp = math.exp( -coefficient * ( total_num_characters - min_positions ) ) * 100;
	local chance = math.max( math.min( exp, max_emerge_chance * 100 ), min_emerge_chance * 100);

	if self.is_debug then
        out.design( "Faction: " .. query_faction:name() .. ", Chars: " .. tostring(total_num_characters) .. ", required: " .. tostring(min_positions) .. ", chance: " .. chance);
	end;
	
	-- We rolled under our emergence chance, so allow spawning.
	-- Factions with LOADS of characters were succeeding when random rolled 0...
    if chance > 5 and cm:roll_random_chance( chance, true ) then 
        return true; 
    end;

    if self.is_debug then
        out.design("man_of_the_hour:roll_emergence_chance(): Failed Roll.");
    end;

    return false;
end;


--[[ man_of_the_hour:fire_choice_dilemma()
        Trigger a dilemma for the player.
]]--
function man_of_the_hour:fire_choice_dilemma(modify_faction, is_recruitable, dilemma_keys)
	modify_faction:trigger_dilemma(dilemma_keys, true)
end;



---------------------------------------------------------------------------------------------------------
----- Helpers
---------------------------------------------------------------------------------------------------------



--[[ man_of_the_hour:spawn_character()
        Spawn the MOH for the faction based on the unit.
]]--
function man_of_the_hour:spawn_character(modify_faction, is_recruitable)
    local is_male = true;

	-- Subtype is selected from valid subtypes for the faction.
	if is_recruitable then
		modify_faction:create_recruitable_character_with_gender( "general", is_male ) -- true = is_male
	else
		modify_faction:create_character_with_gender( "general", is_male ) -- true = is_male
	end;
end;


--[[ man_of_the_hour:get_battle_dilemma_keys()
        Get the dilemmas based on what happened.
]]--
function man_of_the_hour:get_battle_dilemma_keys(query_faction, battle_result, pending_battle)
    local was_attacker = false;
    local selected_key = "dilemma_land_attack";
    local dilemma_keys = {};

	if not query_faction or query_faction:is_null_interface() then
		script_error("man_of_the_hour:get_battle_dilemma_keys(): Faction is null.");
		return nil;
	end;

	if not query_faction:is_human() then -- Only fire dilemmas for humans.
		return nil;
	end;

	if battle_result == pending_battle:attacker_battle_result() then
        was_attacker = true;
    end;

    if was_attacker and pending_battle:seige_battle() then -- SIEGE, ATTACKER
        selected_key = "dilemma_siege_attack";
    elseif not was_attacker and pending_battle:seige_battle() then -- SIEGE, DEFENDER
        selected_key = "dilemma_siege_defence";
    elseif was_attacker and pending_battle:ambush_battle() then -- AMBUSH, ATTACKER
        selected_key = "dilemma_ambush_attack";
    elseif not was_attacker and pending_battle:ambush_battle() then -- AMBUSH, DEFENDER
        selected_key = "dilemma_ambush_defence";
    elseif was_attacker then -- LAND, ATTACKER
        selected_key = "dilemma_land_attack";
    elseif not was_attacker then -- LAND, DEFENDER
        selected_key = "dilemma_land_defence";
    end;

    dilemma_keys = self:get_overridden_variable(selected_key, query_faction);

    if self.is_debug then
        out.design("man_of_the_hour:get_battle_dilemma_keys(): Returning Keys: " .. selected_key);
    end;

    if dilemma_keys and #dilemma_keys > 0 then
        return table.concat(dilemma_keys, ",");
    else
        script_error("man_of_the_hour:get_battle_dilemma_keys(): No keys found for " .. selected_key);
        return nil;
    end;
end;


--[[ man_of_the_hour:get_occupation_dilemma_keys()
        Get the dilemmas based on what happened.
]]--
function man_of_the_hour:get_occupation_dilemma_keys(query_faction)
	if not query_faction or query_faction:is_null_interface() then
		script_error("man_of_the_hour:get_occupation_dilemma_keys(): Faction is null.");
		return nil;
	end;

	if not query_faction:is_human() then  -- Only fire dilemmas for humans.
		return nil;
	end;

    dilemma_keys = self:get_overridden_variable("dilemma_occupation", query_faction);

    if dilemma_keys and #dilemma_keys > 0 then
        return table.concat(dilemma_keys, ",");
    else
        script_error("man_of_the_hour:get_occupation_dilemma_keys(): No keys found for dilemma_occupation");
        return nil;
    end;
end;


--[[ man_of_the_hour:get_turn_start_dilemma_keys()
        Get the dilemmas based on what happened.
]]--
function man_of_the_hour:get_turn_start_dilemma_keys(query_faction)

	if not query_faction or query_faction:is_null_interface() then
		script_error("man_of_the_hour:get_turn_start_dilemma_keys(): Faction is null.");
		return nil;
	end;

	if not query_faction:is_human() then  -- Only fire dilemmas for humans.
		return nil;
	end;

    dilemma_keys = self:get_overridden_variable("dilemma_ambient", query_faction);

    if dilemma_keys and #dilemma_keys > 0 then
        return table.concat(dilemma_keys, ",");
    else
        out.design("man_of_the_hour:get_turn_start_dilemma_keys(): No keys found for dilemma_ambient. This is expected.");
        return nil;
    end;
end


--[[ man_of_the_hour:get_overridden_variable()
        Get the faction/subculture/culture variable 
]]--
function man_of_the_hour:get_overridden_variable(var_name, query_faction)

    if not query_faction then
        script_error("man_of_the_hour:get_overridden_variable(): Query Faction is null");
    end;
    
    opt_check_faction = opt_check_faction or true;
    opt_check_subculture = opt_check_subculture or true;
    opt_check_culture = opt_check_culture or true;

    local faction_key = query_faction:name();
    local subculture_key = query_faction:subculture();
    local culture_key = query_faction:culture();
    local return_val = nil;

    -- Check culture first.
    if self.culture_overrides[culture_key] then
        if not is_nil(self.culture_overrides[culture_key][var_name]) then
            return_val = self.culture_overrides[culture_key][var_name];
            --out.design("MOH: Culture Val: " .. var_name .. "=" .. tostring(return_val) );
        end;
    end;

    -- Then subculture.
    if self.subculture_overrides[subculture_key] then
        if not is_nil(self.subculture_overrides[subculture_key][var_name]) then
            return_val = self.subculture_overrides[subculture_key][var_name];
            --out.design( "MOH: Subculture Val: " .. var_name .. "=" .. tostring(return_val) );
        end;
    end;

    -- Then faction.
    if self.faction_overrides[faction_key] then
        if not is_nil(self.faction_overrides[faction_key][var_name]) then
            return_val = self.faction_overrides[faction_key][var_name];
            --out.design("MOH: Faction Val: " .. var_name .. "=" .. tostring(return_val) );
        end;
    end;

    if is_nil(return_val) then
        script_error("man_of_the_hour:get_overridden_variable(): Variable '" .. var_name .. "' not found! For Faction Name " .. faction_key .. ". Does it exist?");
    end;

    return return_val;
end;