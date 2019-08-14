-------------------------------------------------------------------------------
------------------------- YELLOW TURBAN EMPEROR ASCENSION ---------------------
-------------------------------------------------------------------------------
------------------------- Created by Craig: 05/10/2018 ------------------------
-------------------------------------------------------------------------------

output("3k_ytr_emperor_ascension.lua: Loaded")

---------------------------------------------------------------------------------------------------------
----- SCRIPT INFORMATION
---------------------------------------------------------------------------------------------------------
-- This gives a yellow turban faction a big bonus when achieving a certain progression level
-- Once an elligible faction becomes world leader they get a dilemma to pick a bonus.
-- The bonus is themed around declaring a new Yellow Sky Emperor, and who that will be.
-- The third option notably causes your faction leader to leave your faction and become Emperor.
---------------------------------------------------------------------------------------------------------

yt_emperor_ascension = {};
yt_emperor_ascension.min_progression_level = 0;
yt_emperor_ascension.dilemma_key = "3k_ytr_emperor_ascension_dilemma_scripted";
yt_emperor_ascension.dilemma_choice_faction_leader_string = "THIRD";


function yt_emperor_ascension:initialise()
	output("yt_emperor_ascension:initialise()");

	core:add_listener(
        "FactionFameLevelUpYTEmperorAscension",
        "FactionBecomesWorldLeader",
		function(context)
			return self:has_met_ascension_conditions( context:faction() );
		end,
        function(context) 
			context:modify_model():get_modify_faction(context:faction()):trigger_dilemma( self.dilemma_key, true );
		end,
        true
	);
	
	core:add_listener(
        "FactionFameLevelUpYTEmperorAscension",
        "FactionBecomesWorldLeaderCaptureSettlement",
		function(context)
			return self:has_met_ascension_conditions( context:faction() );
		end,
		function(context)
			local faction_name = context:faction():name();

			-- We cannot fire events until after the battle, so we'll use a listener instead.
			core:add_listener(
				"FactionFameLevelUpYTEmperorAscension", -- Unique handle
				"BattleCompleted", -- Campaign Event to listen for
				true,
				function(context) -- What to do if listener fires.
					-- We don't get a faction handle here, so we find by key instead.
					cm:modify_faction(faction_name):trigger_dilemma( self.dilemma_key, true );
				end,
				false --Is persistent
			);
		end,
        true
	);
	
    core:add_listener(
        "DilemmaChoiceMadeEventYTEmperorAscension",
        "DilemmaChoiceMadeEvent",
		function(context) 
			return context:dilemma() == self.dilemma_key
		end,
		function(context) 
			self:dilemma(context) 
		end,
        true
	);

	-- Example: trigger_cli_debug_event test_emperor_event(3k_main_faction_yellow_turban_anding) ---gong du
	core:add_cli_listener("test_emperor_event", 
		function(faction_key)
			local query_faction = cm:query_faction(faction_key);
			if query_faction then
				cm:modify_model():get_modify_faction(query_faction):trigger_dilemma( self.dilemma_key, true );
			end;
		end
	);
end;


function yt_emperor_ascension:dilemma(context)
		if context:choice() == 0 then
			-- Peasant is chosen. Gain population, growth, construction bonuses.
		elseif context:choice() == 1 then
			-- Noble is chosen. Gain diplomacy and economy bonuses.
		elseif context:choice() == 2 then
			-- Faction leader is chosen. Gain military bonuses which are attached to the faction leader.
			if yt_traits then
				local query_character = context:faction():faction_leader();
				local modify_character = cm:modify_model():get_modify_character( query_character );

				yt_traits:ConvertTeacherToEmperor( query_character, modify_character );
			end;
 		end;
end


function yt_emperor_ascension:has_met_ascension_conditions( query_faction )
	return query_faction:subculture() == "3k_main_subculture_yellow_turban"
			and query_faction:is_human()
			and query_faction:progression_level() >= self.min_progression_level
			and query_faction:is_world_leader()
			and not self:has_ascended( query_faction )
end;


function yt_emperor_ascension:has_ascended( query_faction )
	return cm:query_model():event_generator_interface():have_any_of_dilemmas_been_generated( query_faction, self.dilemma_key );
end;