---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Endgame
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to create an interesting endgame when needed. Written in an State Machine style since it's very much 'phase' based.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

output("3k_campaign_experience.lua: Loaded");

---------------------------------------------------------------------------------------------------------
----- DATA
---------------------------------------------------------------------------------------------------------

endgame = {};

endgame.phases = {"WAITING", "SPAWNING", "EXPANSION", "SUCCESSION", "BATTLE"};
endgame.current_phase = endgame.phases[1]; -- Change this to alter the start phase.

-- SAVED VALUES
endgame.primary_trigger_faction = nil; -- Used to 'switch' the variables back on.
endgame.has_fired_this_turn = false; -- Used to prevent this firing too often.
endgame.has_updated_this_turn = false; -- Used for MP to allow things to happen, buit prevent double-dipping.

---------------------------------------------------------------------------------------------------------
----- MAIN FUNCTIONS
---------------------------------------------------------------------------------------------------------

--// initialise()
--// Entry point.
function endgame:initialise()
    output("3k_campaign_endgame.lua: Initialise()" );

    output("endgame:initialise(): TODO!" );

    --[[
    -- Set-up core values.
    --TODO.

    -- Triggers the update command which runs the entire system.
    core:add_listener(
		"endgame_faction_round_start_listener", -- UID
		"FactionRoundStart", -- Event
        function(faction_round_start_event)
            -- Only fire for local faction.
            if faction_round_start_event:faction():name() ~= cm:get_local_faction() then
                return false;
            end;

            return true;
		end, --Conditions for firing
        function(faction_round_start_event)
            -- The first faction we fire for will set this, always the player.
            -- This has the potential to BREAK COOP/CO-OP, 
            if not self.primary_trigger_faction then
                self.primary_trigger_faction = faction_round_start_event:faction():name();
            end;
            
            -- Reset our trigger states if we're the 'primary_trigger_faction'.
            if self.primary_trigger_faction == faction_round_start_event:faction():name() then
                self.has_updated_this_turn = true;
                self.has_fired_this_turn = true;
            end;

            self:update(faction_round_start_event);
            
		end, -- Function to fire.
		true -- Is Persistent?
    );
    ]]--
end;


--// update()
--// Main update loop.
function endgame:update(faction_round_start_event)
    if self:system_should_exit() then
        output("endgame:update(): System Exiting" );

        core:remove_listener("endgame_faction_round_start_listener");
        core:remove_listener("endgame_faction_turn_end_listener");

        return;
    end;

    if self.has_fired_this_turn then
        return;
    end;

    output("endgame:update(): Running Update Loop" );   

    self:check_should_enter_next_phase();
    self:process_phase();

    -- Set variables here to track what's happened.
    self.has_updated_this_turn = true;
    self.has_fired_this_turn = true;
end;


---------------------------------------------------------------------------------------------------------
----- METHODS
---------------------------------------------------------------------------------------------------------

--// check_should_enter_next_phase()
--// Check if the system should fire.
function endgame:check_should_enter_next_phase(faction_round_start_event)
    if self:get_phase() == "WAITING" then -- Waiting
        
    elseif self:get_phase() == "SPAWNING" then -- Spawning

    elseif self:get_phase() == "EXPANSION" then -- Expansion

    elseif self:get_phase() == "SUCCESSION" then -- Succession

    elseif self:get_phase() == "BATTLE" then -- battle

    end;
end;

--// process_phase()
--// Update for the current phase.
function endgame:process_phase()
    if self:get_phase() == "WAITING" then -- Waiting
    
    elseif self:get_phase() == "SPAWNING" then -- Spawning

    elseif self:get_phase() == "EXPANSION" then -- Expansion

    elseif self:get_phase() == "SUCCESSION" then -- Succession

    elseif self:get_phase() == "BATTLE" then -- battle

    end;
end;

--// system_should_exit()
--// Check if we should just kill the entire system.
function endgame:system_should_exit()
    if false then
        return true;
    end;

    return false;
end;


--// set_phase()
--// Set the current phase and test against our enum.
function endgame:set_phase(phase_id)
    if self.phases[phase_id] then
        endgame.current_phase = phase_id;
    else
        script_error("Trying to call unsupported phase " .. phase_id);
    end;
end;

--// get_phase()
--// Get the current phase.
function endgame:get_phase()
    return endgame.current_phase;
end;



---------------------------------------------------------------------------------------------------------
----- SAVE/LOAD
---------------------------------------------------------------------------------------------------------
function endgame:register_save_load_callbacks()
    cm:add_saving_game_callback(
        function(saving_game_event)
            return true;
        end
    );

    cm:add_loading_game_callback(
        function(loading_game_event)
            return false;
        end
    );
end;

--endgame:register_save_load_callbacks();