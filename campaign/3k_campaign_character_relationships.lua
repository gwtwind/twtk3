---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Character Relationships
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to fire bespoke relationship triggers for characters.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

output("3k_campaign_character_relationships.lua: Loading");

character_relationships = {};
character_relationships.vassal_master_trigger = "3k_main_relationship_trigger_set_scripted_unique_vassal_master";

character_relationships.governor_assignee_trigger = "3k_main_relationship_trigger_set_scripted_round_start_same_region";

character_relationships.character_spawn_relationship_targets = {}; -- List of CQIs of characters we could have relationships with.
character_relationships.character_spawn_max_relationship_targets = 20;
character_relationships.character_spawn_relationship_chance = 75; -- chance of a relationship forming on spawn.
character_relationships.character_spawn_relationship_triggers = 
{
	"3k_main_relationship_trigger_set_scripted_battle_defeat_close",
	"3k_main_relationship_trigger_set_scripted_battle_defeat_crushing",
	"3k_main_relationship_trigger_set_scripted_battle_defeat_decisive",
	"3k_main_relationship_trigger_set_scripted_battle_defeat_pyrrhic",
	"3k_main_relationship_trigger_set_scripted_battle_duel",
	"3k_main_relationship_trigger_set_scripted_battle_opposing",
	"3k_main_relationship_trigger_set_scripted_battle_victory_close",
	"3k_main_relationship_trigger_set_scripted_battle_victory_decisive",
	"3k_main_relationship_trigger_set_scripted_battle_victory_heroic",
	"3k_main_relationship_trigger_set_scripted_battle_victory_pyrrhic",
	"3k_main_relationship_trigger_set_scripted_event_assaulted",
	"3k_main_relationship_trigger_set_scripted_event_childhood",
	"3k_main_relationship_trigger_set_scripted_event_generic_large",
	"3k_main_relationship_trigger_set_scripted_event_generic_small",
	"3k_main_relationship_trigger_set_scripted_event_insulted",
	"3k_main_relationship_trigger_set_scripted_event_joined",
	"3k_main_relationship_trigger_set_scripted_round_start_ministers",
	"3k_main_relationship_trigger_set_scripted_round_start_same_force",
	"3k_main_relationship_trigger_set_scripted_round_start_same_region"
};
character_relationships.character_spawn_max_spawn_relationships = 3;
character_relationships.character_spawn_max_target_relationships = 4;


--[[ character_relationships:initialise()
	Entry point.
]]--
function character_relationships:initialise()
    self:register_governor_assignee_listeners();
	self:register_vassal_master_listeners();
	self:register_character_spawn_relationship_listeners();
	self:register_come_of_age_family_relationships()
end;



---------------------------------------------------------------------------------------------------------
----- LISTENERS
---------------------------------------------------------------------------------------------------------

--[[ character_relationships:register_vassal_master_listeners()
    Fires a trigger on turn end 
    When a character's satisfaction is very high
    Makes them more friendly to the faction leader
]]--
function character_relationships:register_vassal_master_listeners()
    -- FACTION TURN START
    core:add_listener(
        "character_relationship_vassal_master_turn_end", -- UID
        "FactionTurnEnd", -- Campaign event
        true,
        function(event)
        end,
        true
    );
end;


--[[ character_relationships:register_governor_assignee_listeners()
    Fires a trigger on turn end 
    When a character's on assignment in a province.
    Makes them more friendly to the administrator.
]]--
function character_relationships:register_governor_assignee_listeners()
    -- FACTION TURN END
    core:add_listener(
        "character_relationship_governor_assignee_turn_end", -- UID
        "FactionTurnEnd", -- Campaign event
        true,
        function(event)
        end,
        true
    );
end;


--[[ character_relationships:register_new_character_relationship_listeners()
	Fires a trigger on character created.
	We store a list of created characters who are potential relationship targets. (to save going through each time)
	We then fire a trigger between them to make a friend/rivalry.
]]

function character_relationships:register_character_spawn_relationship_listeners()
	 -- FACTION TURN END
	 core:add_listener(
        "character_relationship_new_character_relationship", -- UID
        "ActiveCharacterCreated", -- Campaign event
		function(event) 
			if not event:query_character():character_type("general") then
				return false;
			end;

			return true;
		end,
		function(event)
			local query_character = event:query_character();

			-- Allow generating multiple relationships. We use their current to determine if we should add any more.
			-- This can break out early if they fail to generate, or roll under their random value.
			while query_character:relationships():num_items() < self.character_spawn_max_spawn_relationships do
				if #self.character_spawn_relationship_targets < 1 then -- If we have no chars, just exit.
					break;
				end;

				if not cm:roll_random_chance( self.character_spawn_relationship_chance / (query_character:relationships():num_items() + 1) ) then -- +1 to handle Div/0. Based on num_relationships already fired.
					break;
				end;

				if not self:character_spawn_form_relationship( query_character ) then -- Spawn a relationship here.
					break; -- Exit if we failed to make one, we likely won't succeed next time either.
				end;
			end;
			
			-- if the character still has some relationship slots available then they can be considered for more in the future.
			if query_character:relationships():num_items() < self.character_spawn_max_target_relationships then 
				self:character_spawn_add_to_targets( query_character );
			end
        end,
        true
    );
end;



function character_relationships:register_come_of_age_family_relationships()
	-- CHARACTER COMES OF AGE
	core:add_listener(
	   "character_relationship_come_of_age_family", -- UID
	   "CharacterComesOfAge", -- Campaign event
	   function(event) 
		   if not event:query_character():character_type("general") then
			   return false;
		   end;

		   return true;
	   end,

	   function(event)
			local query_character = event:query_character();
			local modify_character = event:modify_character();
			output("Character came of age: "..tostring(modify_character));

			modify_character:apply_relationship_trigger_set( query_character,  "3k_main_relationship_trigger_set_scripted_event_family_member");
		   
	   end,
	   true
   );
end;



---------------------------------------------------------------------------------------------------------
----- HELPERS
---------------------------------------------------------------------------------------------------------


--[[ character_relationships:character_spawn_form_relationship(query_character)
	Tries to form a relationship for the given character with a character in our CQI list.
	returns true is we managed to make a relationship, false if not.
]]--
function character_relationships:character_spawn_form_relationship(query_character) -- return bool.
	
	local target_character = self:character_spawn_get_target_character();

	if target_character then
		local modify_character = cm:modify_character( query_character );
		local trigger_id = math.round(cm:random_number(#self.character_spawn_relationship_triggers, 1), 0);
		local trigger = self.character_spawn_relationship_triggers[trigger_id];

		if not trigger then
			script_error("character_relationships:character_spawn_form_relationship(): Failed to find relationship trigger")
			return false;
		end;
		modify_character:apply_relationship_trigger_set( target_character,  trigger);

		-- Remove from the list once they've satisfied their num relationships.
		if target_character:relationships():num_items() >= self.character_spawn_max_target_relationships then
			self:character_spawn_remove_from_targets( target_character );
		end

		return true;
	end;

	return false;
end;


--[[ character_relationships:character_spawn_get_target_character()
	Go thorough our stored CQIs and find the characters.
	Remove invalid characters.
	Return a valid character
]]--
function character_relationships:character_spawn_get_target_character() -- return query_character interface
	-- Go through all our cqis and find valid characters
	local target_character = nil;

	-- shuffle our list.
	self:shuffle_relationships(self.character_spawn_relationship_targets);

	for i=1, #self.character_spawn_relationship_targets do
		local target_character = cm:query_character( self.character_spawn_relationship_targets[i] );
		
		-- Remove the character from the list of characters if they're no longer valid.
		if target_character:faction():is_human() or not target_character:character_type("general") or target_character:is_dead() then 
			self:character_spawn_remove_from_targets( target_character );
		end;

		return target_character;
	end;

	return nil;
end;


--[[ character_relationships:character_spawn_add_to_targets(query_character)
	Adds the character to the list of people looking for friends.
	If we're at the max pop the oldest.
]]--
function character_relationships:character_spawn_add_to_targets(query_character)
	local character_cqi = query_character:command_queue_index();

	if self:character_spawn_get_target_index(character_cqi) == -1 then -- only add if we didn't find them in the list.
		-- If we've reached our limit remove the top one as it'll be the oldest.
		if #self.character_spawn_relationship_targets == self.character_spawn_max_relationship_targets then
			table.remove( self.character_spawn_relationship_targets, 1 );
		end;

		table.insert( self.character_spawn_relationship_targets, character_cqi );
	end;
end;


--[[ character_relationships:character_spawn_remove_from_targets(query_character)
	remove the charactter from the list of people looking for friends.
]]--
function character_relationships:character_spawn_remove_from_targets(query_character)
	local character_cqi = query_character:command_queue_index();	

	if self:character_spawn_get_target_index(character_cqi) > 0 then -- only remove if we found them.
		table.remove( self.character_spawn_relationship_targets, index );
	end;
end;


--[[ character_relationships:character_spawn_get_target_index(cqi)
	Finds the index of the passed in character cqi in the list and returns its index.
	If it cannot find any, returns -1
]]--
function character_relationships:character_spawn_get_target_index(cqi)
	local index = -1;
	
	for i=1, #self.character_spawn_relationship_targets do
		if self.character_spawn_relationship_targets[i] == character_cqi then
			index = i;
			break;
		end;
	end;

	return index;
end;


function character_relationships:shuffle_relationships(tbl)
	local size = #tbl

	for i = size, 1, -1 do
	  local rand = math.round( cm:random_number(size, 1), 0 );
	  tbl[i], tbl[rand] = tbl[rand], tbl[i];
	end

	return tbl
  end;