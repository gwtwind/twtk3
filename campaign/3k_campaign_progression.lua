---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			progression
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to create an interesting endgame when needed. Written in an State Machine style since it's very much 'phase' based.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

output("3k_campaign_progression.lua: Loaded");

---------------------------------------------------------------------------------------------------------
----- DATA
---------------------------------------------------------------------------------------------------------

progression = {};

progression.disable_progression = false;
-- Intro, Game Won and Game Lost handled in the DB.
progression.movie_key_fall_of_dong_zhuo = "3k_main_fall_of_dong_zhuo";
progression.movie_key_warlords = "3k_main_warlords";
progression.movie_key_three_kingdoms = "3k_main_three_kingdoms";
progression.max_emperor_seats = 3;

progression.has_played_movie_fall_of_dong_zhuo = false;
progression.has_played_movie_warlords = false;
progression.has_played_movie_three_kingdoms = false;

---------------------------------------------------------------------------------------------------------
----- MAIN FUNCTIONS
---------------------------------------------------------------------------------------------------------

--[[
    initialise()
        Entry point.
]]--
function progression:initialise()
    output("3k_campaign_progression.lua: Initialise()" );

    self:add_progression_listener_dong_zhuo(); -- Character Death: Dong Zhuo.
    self:add_progression_listener_fame_level_up(); -- Faction rank increase.
    self:add_progression_listener_emperor(); -- Faction Becomes World Leader & 3Kingdoms.
    self:add_progression_listener_no_longer_emperor(); -- Faction no longer world leader.
    self:add_progression_listener_new_faction_leader(); -- Faction no longer world leader.
	self:add_progression_listener_world_power_token_removed(); -- Emperor removed.

    self:add_progression_listener_debug_movie(); -- Debug Movie, Faction Turn
	
end;


---------------------------------------------------------------------------------------------------------
----- LISTENERS
---------------------------------------------------------------------------------------------------------

--// Intro
--// Start of game.
--// Handled in the DB frontend_faction_leaders table loading_screen_intro_video field

--[[
    add_progression_listener_debug_movie()
        When Turn Start, if the flag it set to true.
]]--

function progression:add_progression_listener_debug_movie()
    -- Example: trigger_cli_debug_event progression.play_debug_movie(3k_main_fall_of_dong_zhuo)
    core:add_cli_listener("progression.play_debug_movie", 
		function(movie_key)
            output("-*- progression(): Playing Debug Movie");

            self:play_movie(cm:modify_model(), movie_key);
		end
    );
end;

--[[
    add_progression_listener_dong_zhuo()
        When DZ dies.
        Play Movie
]]--
function progression:add_progression_listener_dong_zhuo()
    core:add_listener(
        "progression_dong_zhuo", -- UID
        "CharacterDied", -- CampaignEvent
        function(event)
            if event:query_character():is_null_interface() then
                output("-*- progression(): Null character interface " .. tostring(event:query_character():is_null_interface()) .. tostring(event:query_character():ceo_management():is_null_interface()) );
                return false;
            end;
            
            return event:query_character():generation_template_key() == "3k_main_template_historical_dong_zhuo_general_fire" or event:query_character():generation_template_key() == "3k_main_template_historical_dong_zhuo_hero_fire";
        end, --Conditions for firing
        function(event)
            output("-*- progression(): Dong Zhuo Has Died!");

            if not self.has_played_movie_fall_of_dong_zhuo then
                self:play_movie(cm:modify_model(), self.movie_key_fall_of_dong_zhuo);
                self.has_played_movie_fall_of_dong_zhuo = true
				
				-- AI SCRIPT to trigger global personality change
				--out.ai("AI SCRIPT: global personality change after Dong Zhuo's death");
				--self:global_personality_change();
				-- AI SCRIPT END
            end;
        end, -- Function to fire.
        false -- Is Persistent?
    );
end;

--[[
    add_progression_listener_fame_level_up()
        When player becomes warlord
        Play Movie
    
        Progression Levels:
            0 = Noble (starting)
            1 = Second Marquis
            2 = Marquis
            3 = Duke
            4 = King
]]--
function progression:add_progression_listener_fame_level_up()
    core:add_listener(
        "progression_duke", -- UID
        "FactionFameLevelUp", -- CampaignEvent
        true, --Conditions for firing
        function(event)
            local query_faction = event:faction();
            local progression_level = query_faction:progression_level();
            
            if progression_level == 1 then -- Second Marquis
                output("-*- progression(): Rank reached: 1 Second Marquis");

            elseif progression_level == 2 then -- Marquis
                output("-*- progression(): Rank reached: 2 Marquis");

            elseif progression_level == 3 then -- Duke
                output("-*- progression(): Rank reached: 3 Duke");

                if query_faction:is_human() and not self.has_played_movie_warlords then
                    self:play_movie(cm:modify_model(), self.movie_key_warlords);
                    self.has_played_movie_warlords = true
                end;

            elseif progression_level == 4 then -- King
                output("-*- progression(): Rank reached: 4 King");

            else
                script_error("add_progression_listener_fame_level_up(): Unsupported progression level passed in. Please check the data as we don't currently support this level.")
            end;
        end, -- Function to fire.
        true -- Is Persistent?
    );
end;


--[[
    add_progression_listener_emperor()
        When any faction becomes emperor.
        Apply permenant effect bundle to their capital region.
        If we have Three Kingdoms (AKA Emperor Seats) then fire the movie!
]]
function progression:add_progression_listener_emperor()
    core:add_listener(
        "progression_emperor", -- UID
        "WorldLeaderRegionAdded", -- CampaignEvent
        true, --Conditions for firing
        function(event)
            local query_faction = event:region():owning_faction();
            local modify_faction = cm:modify_model():get_modify_faction(query_faction);
            local query_capital_region = modify_faction:query_faction():capital_region();

			output("-*- progression(): Emperor Seat Established in " .. query_capital_region:name());
			
			-- AI SCRIPT to change the personality of the newly become emperor
			--		out.ai("AI SCRIPT: changing the personality of a newly become emperor faction: " ..query_faction:name());
			--		self:change_personality_of_faction(query_faction,true);
			-- AI SCRIPT END
					
            -- THREE KINGDOMS
			output("-*- progression(): Total number of Emperor Seats in the world: " .. self:get_total_number_of_emperor_seats());
            if self:get_total_number_of_emperor_seats() >= self.max_emperor_seats then
                output("-*- progression(): We Have Three Kingdoms!");

                if not self.has_played_movie_three_kingdoms then
                    self:play_movie(cm:modify_model(), self.movie_key_three_kingdoms);
                    self.has_played_movie_three_kingdoms = true
					
					-- AI SCRIPT to trigger global personality change (late game)
					out.ai("AI SCRIPT: global personality change after establishing 3 Emperor seats");
					self:global_personality_change();
					-- AI SCRIPT END
                end;
            end;
        end, -- Function to fire.
        true -- Is Persistent?
    );
end;

--[[
    add_progression_listener_no_longer_emperor()
        When faction no longer emperor.
]]--
function progression:add_progression_listener_no_longer_emperor()
    core:add_listener(
        "progression_emperor_no_more", -- UID
        "FactionNoLongerWorldLeader", -- Campaign event
        true,
        function(event)
            output("-*- progression(): Faction no longer emperor");
			local query_faction = event:faction();
			
			-- AI SCRIPT to change the personality of the faction that has just lost its emperor status
			--		out.ai("AI SCRIPT: changing the personality of a faction that's just lost emperor status: " ..query_faction:name());
			--		self:change_personality_of_faction(query_faction,true);
			-- AI SCRIPT END
        end,
        true
    );
end;
 
--// WorldPowerTokenRemovedEvent
--// When emperor is no more.
function progression:add_progression_listener_world_power_token_removed()
    core:add_listener(
        "progression_campaign_wp_token_removed", -- UID
        "WorldPowerTokenRemovedEvent", -- Campaign event
        true,
        function(event)
            output("-*- progression(): World Power Token Removed");
			-- Spawn the Emperor as a character in the game.
			-- Get a faction to spawn them in.
			local spawn_q_faction = nil;
			-- Try the Han Empire first
			spawn_q_faction = cm:query_faction("3k_main_faction_han_empire");

			-- If they're dead pick another (player?) faction.
			if spawn_q_faction:is_dead() then
				spawn_q_faction = nil;
				local highest_score = 0;
				for i=0, event:query_model():world():faction_list():num_items() - 1 do
					local qFaction = event:query_model():world():faction_list():item_at(i);
					local qFactionScore = 0;

					if not qFaction:is_dead() and qFaction:subculture() == "3k_main_chinese" then
						if qFaction:is_world_leader() then
							qFactionScore = qFactionScore + ( 10 * qFaction:number_of_world_leader_regions() );
						end;

						if qFaction:is_human() then
							qFactionScore = qFactionScore + 5;
						end;

						qFactionScore = qFactionScore + cm:random_number(15);

						if qFactionScore > highest_score then
							spawn_q_faction = qFaction;
							highest_score = qFactionScore
						end;
					end;

				end
			end;

			-- Spawn the character in the faction if we got one.
			if not spawn_q_faction then
				script_error("-*- progression():No faction found for the emperor, this shouldn't happen!");
				return false;
			end;

			-- Spawn them in the faction.
			output( "-*- progression(): Spawning Han Emperor in faction: " .. spawn_q_faction:name() );
			local spawn_m_faction = cm:modify_faction( spawn_q_faction );
			spawn_m_faction:create_character_from_template( "general", "3k_general_earth", "3k_main_template_historical_liu_xie_hero_earth" );
        end,
        false
    );
end



--[[ ************** AI SCRIPT ************** 
    add_progression_listener_new_faction_leader()
        A faction gets a new faction leader.
]]--
function progression:add_progression_listener_new_faction_leader()
    core:add_listener(
        "progression_new_faction_leader", -- UID
        "CharacterBecomesFactionLeader", -- CampaignEvent
        true,
        function(context)
            output("-*- progression(): Faction has new faction leader");
			local character = context:query_character();
			local faction = character:faction();
            -- AI SCRIPT to trigger personality change for this faction
			out.ai("AI SCRIPT: changing the personality of faction: " .. faction:name());
			self:change_personality_of_faction(faction,false);
			-- AI SCRIPT END
        end, -- Function to fire.
        true -- Is Persistent?
    );
end;


---------------------------------------------------------------------------------------------------------
----- METHODS
---------------------------------------------------------------------------------------------------------

--[[
    play_movie()
        Plays the given movie string.
        Path is relative to the 'working_data/movies' folder. e.g. cm:register_instant_movie("Warhammer/chs_rises");
]]--
function progression:play_movie(modify_model, movie_db_record)
    if self.disable_progression then
        output("progression:play_movie(): progression Disabled. Tried to play: " .. movie_db_record);    
        return;
    end;

    output("progression:play_movie(): Playing Movie: " .. movie_db_record);

    modify_model:get_modify_episodic_scripting():register_instant_movie_by_record(movie_db_record);
end;

--[[ ************** AI SCRIPT ************** 
    global_personality_change()
        Used when the game enters a new phase; 
		Shifts the personality of all non-emperors;
]]--
function progression:global_personality_change()
	output("progression:global_personality_change(): AI SCRIPT is triggering global personality change");
	local faction_list = cm:query_model():world():faction_list();
		
		for i = 0, faction_list:num_items() - 1 do
			local faction = faction_list:item_at(i);
			--if not faction:is_human() and not faction:is_world_leader() then
			self:change_personality_of_faction(faction,true);
			--end;
		end;
	return;
end;

--[[ ************** AI SCRIPT ************** 
    change_personality_of_faction()
        Triggers the personality change or shift of the specified faction;
		If shift == true then we make sure the new personality is similar to the old, otherwise it's a complete random roll;
]]--
function progression:change_personality_of_faction(faction,similar)	
	local weight = 0;
	if similar == true then
		weight = 10;
	end;
	local faction_phase = self:determine_phase_value_of_faction(faction);
	out.ai("progression:change_personality_of_faction(): AI SCRIPT is changing the personality of faction: " .. faction:name() .. " Phase number: " .. faction_phase .. " Bias towards old personality: " ..weight);
	cm:modify_campaign_ai():cai_force_personality_change(faction:name(),faction_phase,weight);
	return;
end;

--[[ ************** AI SCRIPT ************** 
    determine_phase_value_of_faction()
        Determines and returns the phase value of this specific faction. This is what we use as a turn number when triggering the personality change.
]]--
function progression:determine_phase_value_of_faction(faction)	
	--query if faction is world leader; if yes, return 3; if no, continue
	if self.has_played_movie_three_kingdoms then
		return 2;
	--elseif self.has_played_movie_fall_of_dong_zhuo then
	--	return 1;
	else
		return 0;
	end;
end;

--[[
    get_total_number_of_emperor_seats()
        Gets the total number of emperor seats in the game. Requires model access.        
]]--
function progression:get_total_number_of_emperor_seats()
    local faction_list = cm:query_model():world():faction_list();
    local seat_count = 0;

    for i = 0, faction_list:num_items() - 1 do
        local faction = faction_list:item_at(i);
        seat_count = seat_count + faction:number_of_world_leader_regions();
    end;

    return seat_count;
end;

---------------------------------------------------------------------------------------------------------
----- SAVE/LOAD
---------------------------------------------------------------------------------------------------------
function progression:register_save_load_callbacks()
    cm:add_saving_game_callback(
        function(saving_game_event)
            cm:save_named_value("progression_has_played_movie_fall_of_dong_zhuo", self.has_played_movie_fall_of_dong_zhuo);
            cm:save_named_value("progression_has_played_movie_warlords", self.has_played_movie_warlords);
            cm:save_named_value("progression_has_played_movie_three_kingdoms", self.has_played_movie_three_kingdoms);
        end
    );

    cm:add_loading_game_callback(
        function(loading_game_event)
            local l_has_played_movie_fall_of_dong_zhuo = cm:load_named_value("progression_has_played_movie_fall_of_dong_zhuo", self.has_played_movie_fall_of_dong_zhuo);
            local l_has_played_movie_warlords = cm:load_named_value("progression_has_played_movie_warlords", self.has_played_movie_warlords);
            local l_has_played_movie_three_kingdoms = cm:load_named_value("progression_has_played_movie_three_kingdoms", self.has_played_movie_three_kingdoms);

            self.has_played_movie_fall_of_dong_zhuo = l_has_played_movie_fall_of_dong_zhuo;
            self.has_played_movie_warlords = l_has_played_movie_warlords;
            self.has_played_movie_three_kingdoms = l_has_played_movie_three_kingdoms;
        end
    );
end;

progression:register_save_load_callbacks();