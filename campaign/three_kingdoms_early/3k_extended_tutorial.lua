-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Extended Tutorials -------------------------------
-------------------------------------------------------------------------------
------------------------- Created by Nic: 21/02/2019 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


out("3k_extended_tutorial.lua: Loading");

extended_tutorial = {};

--[VARIABLES]
extended_tutorial.required_advice_key = "3k_campaign_advice_diplomacy_role"

--[STATE MACHINE VALUES]
extended_tutorial.new_state = "ANY";
extended_tutorial.current_state = "NONE";

extended_tutorial.STATE_START = "STATE_START";
extended_tutorial.STATE_HIGHLIGHT_QUICK_DEAL_LIST = "STATE_HIGHLIGHT_QUICK_DEAL_LIST";
extended_tutorial.STATE_HIGHLIGHT_FACTION_LIST = "STATE_HIGHLIGHT_FACTION_LIST";
extended_tutorial.STATE_HIGHLIGHT_FACTION_NEGOTIATE = "STATE_HIGHLIGHT_FACTION_NEGOTIATE";
extended_tutorial.STATE_HIGHLIGHT_SIGN_NEGOTIATE = "STATE_HIGHLIGHT_SIGN_NEGOTIATE";
extended_tutorial.STATE_HIGHLIGHT_MAKE_THIS_DEAL_WORK = "STATE_HIGHLIGHT_MAKE_THIS_DEAL_WORK";
extended_tutorial.STATE_HIGHLIGHT_PROPOSE = "STATE_HIGHLIGHT_PROPOSE";
extended_tutorial.STATE_END = "STATE_END";

function extended_tutorial:setup()

	-- Only load IF the player hasn't seen the help mode advice before.
	if effect.get_advice_thread_score(self.required_advice_key) > 0 then
		out.design("3k_extended_tutorial: Advice has played, exiting.");
		return false;
    end;

    if effect.get_advice_level() == 0 then
		out.design("3k_extended_tutorial: Advice is disabled, exiting.");
		return false;
	end;
	
	core:add_listener(
        "extended_tutorial_clear_all",
		"PanelClosedCampaign",
        function(context)
            return context:component_id() == "diplomacy_panel"
        end,
		function()
			self:change_state(self.STATE_START);
		end,
		false
    );
    
    core:add_listener(
        "extended_tutorial_start_all",
        "PanelOpenedCampaign",
        function(context)
            return context:component_id() == "diplomacy_panel"
        end,
		function()
			self:change_state(self.STATE_START);
		end,
		false
    );

	self:debug_commands();

	-- Our actual loop.
	cm:repeat_callback(
		function()		
			-- Listen for the state being changed.		
			if self.new_state ~= self.current_state then
				out.design("EXTENDED TUTORIAL Changing state: " .. self.current_state .. " -> " .. self.new_state);
				self:exit_state();
				self:enter_state();
			end;
		end,
		1,
		"extended_tutorial_update_loop"
	);
end;

function extended_tutorial:destroy()

	-- Removing all values.
	self:remove_all_highlights();
	self:remove_all_listeners();

	out.design("EXTENDED TUTORIAL: Exiting script!");
end;

function extended_tutorial:change_state(state_key)

	-- Dont allow setting the same state!
	if state_key == self.current_state then
		script_error("Attempting to launch current state!");
		return false;
	end;

	self.new_state = state_key;
end;

function extended_tutorial:exit_state()

	self:remove_all_highlights();
	core:remove_listener( self.current_state );

	self.current_state = self.new_state;
end;

function extended_tutorial:enter_state()

	if self.STATE_START == self.current_state then

		self:change_state( self.STATE_HIGHLIGHT_QUICK_DEAL_LIST );
		
	elseif self.STATE_HIGHLIGHT_QUICK_DEAL_LIST == self.current_state then

        -- Highlight quick deal list
		self:highlight_quick_deal_list(1);

		-- Listen for click on quick deal list.
		core:add_listener(
            self.current_state,
			"ComponentLClickUp",
            function(context) 
                return context:is_child_of_component_id("quick_deals")
            end,
            function()
                self:change_state( self.STATE_HIGHLIGHT_FACTION_LIST );
                self:remove_quick_deal_list_highlight();
            end,
			true
		);

	elseif self.STATE_HIGHLIGHT_FACTION_LIST == self.current_state then
		
		-- Highlight faction list
		self:highlight_faction_list(1);

        core:add_listener(
            self.current_state,
			"ComponentLClickUp",
            function(context)
                return context:is_child_of_component_id("quick_deals")
            end,
			function()
				self:change_state( self.STATE_HIGHLIGHT_FACTION_LIST );
			end,
			true
        );

		-- Listen for click on faction list.
		core:add_listener(
            self.current_state,
			"ComponentLClickUp",
            function(context) 
                return context:is_child_of_component_id("quick_deal_factions")
            end,
			function()
                self:change_state( self.STATE_HIGHLIGHT_FACTION_NEGOTIATE );
                self:remove_faction_list_highlight();
			end,
			true
		);

    
	elseif self.STATE_HIGHLIGHT_FACTION_NEGOTIATE == self.current_state  then

        -- Highlight faction list
		self:highlighted_negotiate(1);

        core:add_listener(
            self.current_state,
			"ComponentLClickUp",
            function(context)
                return context:is_child_of_component_id("quick_deals")
            end,
			function()
				self:change_state( self.STATE_HIGHLIGHT_FACTION_LIST );
				self:remove_negotiate_highlight();
			end,
			true
        );

		-- Listen for click on quick deal faction list.
		core:add_listener(
			self.current_state,
			"ComponentLClickUp",
			function(context) 
				return context:is_child_of_component_id("quick_deal_factions")
			end,
			function()
				self:change_state( self.STATE_HIGHLIGHT_FACTION_NEGOTIATE );
			end,
			true
		);

		-- Listen for click on quick deal propose button.
		core:add_listener(
            self.current_state,
			"ComponentLClickUp",
            function(context) 
                return context.string == "square_large_text_button"
            end,
			function()
                self:change_state( self.STATE_HIGHLIGHT_SIGN_NEGOTIATE );
                self:remove_negotiate_highlight();
			end,
			true
		);

	elseif self.STATE_HIGHLIGHT_SIGN_NEGOTIATE == self.current_state then

        -- Highlight faction list
		self:highlighted_sign_negotiate(1);

        core:add_listener(
            self.current_state,
			"ComponentLClickUp",
            function(context)
                return context:is_child_of_component_id("quick_deals")
            end,
			function()
				self:change_state( self.STATE_HIGHLIGHT_FACTION_LIST );
				self:remove_sign_negotiate_highlight();
			end,
			true
        );

		-- Listen for click on quick deal faction list.
		core:add_listener(
			self.current_state,
			"ComponentLClickUp",
			function(context) 
				return context:is_child_of_component_id("quick_deal_factions")
			end,
			function()
				self:change_state( self.STATE_HIGHLIGHT_FACTION_NEGOTIATE );
				self:remove_sign_negotiate_highlight();
			end,
			true
		);

		-- Listen for click on faction list.
		core:add_listener(
            self.current_state,
			"ComponentLClickUp",
            function(context) 
                return context.string == "button_propose"  and context:is_child_of_component_id("quick_deal")
            end,
			function()
                self:change_state( self.STATE_START );
                self:remove_sign_negotiate_highlight();
			end,
			true
        );

        -- Listen for click on faction list.
		core:add_listener(
            self.current_state,
			"ComponentLClickUp",
            function(context) 
                return context.string == "button_negotiate"  and context:is_child_of_component_id("quick_deal")
            end,
			function()
                self:change_state( self.STATE_HIGHLIGHT_PROPOSE );
                self:remove_sign_negotiate_highlight();
			end,
			true
        );
	
	elseif self.STATE_HIGHLIGHT_PROPOSE == self.current_state then

        -- Highlight faction list
		self:highlighted_propose(1);
		self:highlighted_deals(1);

		-- Listen for click on faction list.
		core:add_listener(
            self.current_state,
			"ComponentLClickUp",
			true,
			function()
                self:change_state( self.STATE_END );
				self:remove_propose_highlight(1);
				self:remove_deals_highlight(1);
			end,
			true
        );
    
	elseif self.STATE_END == self.current_state then

		self:destroy();
		return;

	else

		script_error("Trying to load state " .. self.current_state .. ", which is not a valid state.");
        return;
    
    end;
end;

function extended_tutorial:debug_commands()
	----- DEBUG
	-- Example: trigger_cli_debug_event cdir_events.set_state_extended(state_key)
	core:add_cli_listener(
        "cdir_events.set_state_extended", 
	    function(key)
		    self:change_state(key);
	    end
	);

	-- Example: trigger_cli_debug_event cdir_events.remove_all_highlights_extended()
	core:add_cli_listener(
        "cdir_events.remove_all_highlights_extended", 
		function()
			self:remove_all_highlights();
			self:remove_all_listeners();
		end
	);
	
	-- Example: trigger_cli_debug_event cdir_events.intro_highlight_quick_deal_list
	core:add_cli_listener(
        "cdir_events.intro_highlight_quick_deal_list", 
		function()
            self:highlight_quick_deal_list(1);
            out.design("EXTENDED TUTORIAL CLI COMMAND: Highlight quick deal list")
		end
	);

	-- Example: trigger_cli_debug_event cdir_events.intro_highlight_faction_list
    core:add_cli_listener(
        "cdir_events.intro_highlight_faction_list", 
		function()
            self:highlight_faction_list(1);
            out.design("EXTENDED TUTORIAL CLI COMMAND: Highlight faction list")
		end
	);

end;

--[[
***********************************************************************************************************
***********************************************************************************************************
UTIL FUNCTIONS
***********************************************************************************************************
***********************************************************************************************************
]]--

-- Highlights the quick deal list in diplomacy
function extended_tutorial:highlight_quick_deal_list(state) 

	if not is_number(state) then
		output("[ERROR] Quick deal highlight state should be supplied as number.");
		return;
    end;

	effect.set_context_value("highlighted_diplomacy_quick_deal_list", state);
end;

-- Removes the quick deal list highlight, if it exists.
function extended_tutorial:remove_quick_deal_list_highlight()

	effect.set_context_value("highlighted_diplomacy_quick_deal_list", -1);
end;

-- Highlights the faction list in diplomacy
function extended_tutorial:highlight_faction_list(state) 
	
	if not is_number(state) then
		output("[ERROR] Faction list highlight state should be supplied as number.");
		return;
    end;

	effect.set_context_value("highlighted_diplomacy_faction_list", state);
end;

-- Removes the faction list highlight, if it exists
function extended_tutorial:remove_faction_list_highlight()

	effect.set_context_value("highlighted_diplomacy_faction_list", -1);
end;

-- Highlights the negoatiate button in diplomacy
function extended_tutorial:highlighted_negotiate(state)

    if not is_number(state) then
		output("[ERROR] Negotiate button state should be supplied as number.");
		return;
    end;

	effect.set_context_value("highlighted_diplomacy_negotiate", state);
end;

-- Removes the negotiate highlight, if it exists
function extended_tutorial:remove_negotiate_highlight()

	effect.set_context_value("highlighted_diplomacy_negotiate", -1);
end;

-- Highlights the sign and negotiate buttons in diplomacy
function extended_tutorial:highlighted_sign_negotiate(state)

    if not is_number(state) then
		output("[ERROR] Sign and Negotiate button state should be supplied as number.");
		return;
    end;

	effect.set_context_value("highlighted_sign_negotiate", state);
end;

-- Removes the sign negotiate highlight, if it exists
function extended_tutorial:remove_sign_negotiate_highlight()

	effect.set_context_value("highlighted_sign_negotiate", -1);
end;

-- Highlights the propose button in diplomacy
function extended_tutorial:highlighted_propose(state)

    if not is_number(state) then
		output("[ERROR] Propose button state should be supplied as number.");
		return;
    end;

	effect.set_context_value("highlighted_propose", state);
end;

-- Removes the propose highlight, if it exists
function extended_tutorial:remove_propose_highlight()

	effect.set_context_value("highlighted_propose", -1);
end;

-- Highlights the deals in diplomacy
function extended_tutorial:highlighted_deals(state)

    if not is_number(state) then
		output("[ERROR] Deals state should be supplied as number.");
		return;
    end;

	effect.set_context_value("highlighted_deals", state);
end;

-- Rmoves deals highlight, if it exists
function extended_tutorial:remove_deals_highlight()

	effect.set_context_value("highlighted_deals", -1);
end;

function extended_tutorial:remove_all_highlights()
	self:remove_quick_deal_list_highlight();
	self:remove_faction_list_highlight();
	self:remove_deals_highlight();
	self:remove_propose_highlight();
	self:remove_sign_negotiate_highlight();
	self:remove_negotiate_highlight();
end;

function extended_tutorial:remove_all_listeners()
	cm:remove_callback("extended_tutorial_update_loop");
	cm:remove_callback("toggle_highlight");

	core:remove_listener(self.STATE_START);
	core:remove_listener(self.STATE_HIGHLIGHT_QUICK_DEAL_LIST);
	core:remove_listener(self.STATE_HIGHLIGHT_FACTION_LIST);
	core:remove_listener(self.STATE_HIGHLIGHT_FACTION_NEGOTIATE);
	core:remove_listener(self.STATE_HIGHLIGHT_SIGN_NEGOTIATE);
	core:remove_listener(self.STATE_HIGHLIGHT_PROPOSE);
	core:remove_listener(self.STATE_END);
end;

-- Highlighting function

function trigger_highlighting_for_duration(context_key, enable_value, disable_value, duration)

	if not context_key or not is_string(context_key) then
		script_error("trigger_highlighting_for_duration(): Invalid context_key passed. Must be a string and not nil.");
		return;
	end;
		
	if cm:is_multiplayer() then
		out.interventions( "trigger_highlighting_for_duration: Not enabling ui context as we're in an MP Game. Key: " .. context_key );
		return;
	end;

	if not enable_value or ( not is_string(enable_value) and not is_number(enable_value) ) then
		script_error("trigger_highlighting_for_duration(): We do not have an enable_value. It must be a number or a string.");
		return;
	end;

	if not disable_value or ( not is_string(disable_value) and not is_number(disable_value) ) then
		script_error("trigger_highlighting_for_duration(): We do not have an disable_value. It must be a number or a string.");
		return;
	end;

	if not duration or not is_number(duration) then
		script_error("trigger_highlighting_for_duration(): No duration passed in. Must be a number.");
		return;
	end;

	if duration <= 0 then
		script_error("trigger_highlighting_for_duration(): Duration must be a positive value.");
		return;
	end;

	-- Let's make sure we have model access before we fire.
	cm:wait_for_model_sp(
		function()
			cm:callback(
				function()					
					effect.set_context_value(context_key, disable_value);
				end, 
				duration
			)
		end
	);
	
	effect.set_context_value(context_key, enable_value);
end;

-- Assignments highlighting
core:add_listener(
	"tutorial_assignments_mission_listener",
	"MissionIssued",
	function(context)
		return context:mission():mission_record_key():find("perform_assignment")
	end,
	function()
		cm:set_saved_value("assigment_mission_triggered", true)
	end,
	true
);

core:add_listener(
	"tutorial_assignments_highlighting_listener",
	"SettlementSelected",
	function(context)
		return cm:get_saved_value("assigment_mission_triggered")		
	end,
	function()
		cm:set_saved_value("assigment_mission_triggered", false)
		trigger_highlighting_for_duration("highlighted_assignments", 1, -1, 10);
		core:remove_listener("tutorial_assignments_mission_listener");
		core:remove_listener("tutorial_assignments_highlighting_listener");
	end,
	true
);

-- Faction Council highlighting
core:add_listener(
	"tutorial_faction_council_highlighting_listener",
	"ScriptEventFactionCouncil",
	true,
	function()
		trigger_highlighting_for_duration("highlighted_faction_council", 1, -1, 10);
		core:remove_listener("tutorial_faction_council_highlighting_listener");
	end,
	true
);



