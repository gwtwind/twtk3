---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			YT Traits
----- Author: 		Laura Kampis + Simon Mann
----- Description: 	Yellow Turban trait system script
----- Comments: 	N/A
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

output("3k_ytr_campaign_traits.lua: Loaded");


yt_traits = {
	learning_category_key = "3k_ytr_ceo_category_learning", -- The CEO category of ALL learning traits
	student_trait_key = "3k_ytr_ceo_learning_student", -- The key for a student
	teacher_trait_key = "3k_ytr_ceo_learning_teacher", -- The Key for a teacher
	emperor_trait_points_required = 9999; -- The number of points to unlock the 'emperor ceo node'
	teacher_trait_points_multiplier = 2, -- When applying relationship points, if one is a teacher multiply the gain by this.
	learning_gain_per_turn = 4, -- The passive growth per turn of learning.
	relationship_spread_amounts = { -- The amount of learning characters exchange when they have relationships.
		["3k_main_relationship_negative_03"] = 0,
		["3k_main_relationship_negative_02"] = 1,
		["3k_main_relationship_negative_01"] = 1,
		["3k_main_relationship_positive_01"] = 1,
		["3k_main_relationship_positive_02"] = 2,
		["3k_main_relationship_positive_03"] = 3
	}
}






------------------------------------------------------------------------
-- LISTENERS
------------------------------------------------------------------------


function yt_traits:initialise()
    output("yt_traits.lua:initialise()")
	self:setup_listeners() -- CharacterBecomesFactionLeader -> query_character()
end


function yt_traits:setup_listeners()

	-- When a character becomes the faction leader, we should convert their studentness to teacherness.
	core:add_listener(
        "yt_traits_faction_leader", 
        "CharacterBecomesFactionLeader",
        function (context) 
			if not self:character_can_have_learning_traits( context:query_character() ) then
				return false;
			end;

			return true;
		end, --Conditions for firing
		function(context) 
			self:convert_student_to_teacher( context:query_character(), context:modify_character() );
			self:convert_teacher_to_emperor( context:query_character(), context:modify_character() );
		end, -- function to fire: change teacher trait when new FL in a YT faction
        true -- Is Persistent?
    );


	-- Listens for YT factions and triggers learning trait updates on the characters.
	core:add_listener(
		"yt_traits_character_turn_start", -- Unique handle
		"CharacterTurnStart", -- Campaign Event to listen for
		function(context) -- Criteria
			if context:query_model():turn_number() < 2 then
				return false;
			end;

			if not self:character_can_have_learning_traits( context:query_character() ) then
				return false;
			end;
			
			return true;
		end,
		function(context) -- What to do if listener fires.
			if self:has_teacher_trait() and not context:query_character():is_faction_leader() then
				self:convert_teacher_to_student();
			end;

			self:turn_start_learning_growth( context:modify_character() );
		end,
		true --Is persistent
	);


	-- Listens for YT factions and triggers learning trait updates on the characters.
	core:add_listener(
        "yt_traits_relationship_changed", 
        "FactionRoundStart",
		function (context) 
			if context:query_model():turn_number() < 2 then
				return false;
			end;

			if context:faction():subculture() ~= "3k_main_subculture_yellow_turban" then
				return false;
			end;

			return true;
		end, --Conditions for firing
		function(context) 
			self:apply_learning_to_relationships( context:faction() ) 
		end, -- function to fire: this is the trigger for spreading student trait
        true -- Is Persistent?
	);
	
	
	-- Listens for faction leaders being removed from their posts.
	core:add_listener(
		"yt_traits_removed_from_post", -- Unique handle
		"CharacterUnassignedFromPost", -- Campaign Event to listen for
		function(context) -- Criteria
			if not context:query_character() or context:query_character():is_null_interface() then
				return false;
			end
			
			if not self:character_can_have_learning_traits( context:query_character() ) then
				return false;
			end;

			if not self:has_teacher_trait() then
				return false;
			end;

			return true;
		end,
		function(context) -- What to do if listener fires.
			self:convert_teacher_to_student( context:query_character(), context:modify_character() );
		end,
		true --Is persistent
	);
end




------------------------------------------------------------------------
-- METHODS
------------------------------------------------------------------------

-- Level up FL teacher trait more with certain events?
function yt_traits:apply_learning_to_relationships( query_faction )

	if not query_faction or query_faction:is_null_interface() then
		script_error("ERROR: ApplyTeacherLearningToStudents() Null faction passed in.");
		return false;
	end;

	local closed_list = {}; -- The list of character's we've tested and do not want to test again.
	local open_list = {}; -- Character's whose relationships haven't been tested yet. Format: {character, distance_from_leader}
	local max_distance_from_leader = 2; -- how many degrees of separation can we have from our faction leader.
	local distance_from_leader = 0
	
	-- Get the faction leader.
	if not query_faction:has_faction_leader() or not self:character_can_have_learning_traits( query_faction:faction_leader() ) then
		return false;
	end;

	-- Add them to the open_list
	table.insert( open_list, { query_faction:faction_leader(), 1 } );

	--while the open list isn't empty, and we've not hit our cap.
	while #open_list > 0 and distance_from_leader <= max_distance_from_leader do
		local character_A, character_B;

		-- Remove the character from the open list and add to the closed list.
		local char_data = table.remove( open_list, 1 );

		character_A = char_data[1]; -- query character
		distance_from_leader = char_data[2]; -- distance number

		-- break here if we've gone too far. Stops us going 1 too far due to the while loop.
		if distance_from_leader > max_distance_from_leader then
			break;
		end;

		table.insert( closed_list, character_A );

		-- Get their relationships.
		for i=0, character_A:relationships():num_items() - 1 do
			local relationship = character_A:relationships():item_at( i );

			-- get character b
			if character_A:command_queue_index() ~= relationship:get_relationship_characters():item_at(0):command_queue_index() then
				character_B = relationship:get_relationship_characters():item_at(0);
			else
				character_B = relationship:get_relationship_characters():item_at(1);
			end;

			-- If the character doesn't have YT learning traits, then ignore them and move to the next relationship.
			if not self:has_learning_trait( character_B ) then
				table.insert( closed_list, character_B );
				break;
			end;

			-- Check if the character isn't on the closed list.
			local is_on_closed_list = false;
			for i, v in ipairs(closed_list) do
				if v == character_B then
					is_on_closed_list = true;
					break;
				end;
			end;

			-- Move to the next relationship if the character is on the closed list.
			if is_on_closed_list then
				break;
			end;

			-- Based on the relationship work out how many points to add.
			local points_to_add = self.relationship_spread_amounts[relationship:relationship_record_key()];
			
			if points_to_add and points_to_add > 0 then
				-- Only add points for students.
				if self:has_student_trait( character_B ) then
					-- Teachers ALWAYS level up their students.
					if self:has_teacher_trait( character_A ) then
						points_to_add = points_to_add * self.teacher_trait_points_multiplier;
						cm:modify_model():get_modify_character(character_B):ceo_management():change_points_of_ceos(self.student_trait_key, points_to_add);

					-- If I'm not a teacher then I'll raise my relation's trait if I'm higher than them.
					elseif self:has_student_trait( character_A ) then
						local character_a_points = self:get_learning_trait( character_A, self.student_trait_key ):num_points_in_ceo();
						local character_b_points = self:get_learning_trait( character_B, self.student_trait_key ):num_points_in_ceo();

						if character_a_points > character_b_points then
							cm:modify_model():get_modify_character(character_B):ceo_management():change_points_of_ceos(self.student_trait_key, points_to_add);
						end;
					end;
				end;
			end;

			-- Add the character to the open list so they can be re-evaluated.
			table.insert( open_list, { character_B, distance_from_leader + 1 } );
		end;
	end;
end;


function yt_traits:turn_start_learning_growth( modify_character )
	if not modify_character or modify_character:is_null_interface() then
		script_error("ERROR: turn_start_learning_growth() Modify char is null!");
		return false;
	end;

	local equipped_learning_trait = self:get_learning_trait( modify_character:query_character() );

	if not equipped_learning_trait or equipped_learning_trait:is_null_interface() then
		script_error("ERROR: turn_start_learning_growth() No Learning trait found!");
		return false;
	end;
	
	modify_character:ceo_management():change_points_of_ceos( equipped_learning_trait:ceo_data_key(), self.learning_gain_per_turn );
	
end;





------------------------------------------------------------------------
-- UTILS
------------------------------------------------------------------------


-- fl gets teacher random or equivalent to student lvl
-- fl teacher lvl up with time
-- student lvl up when near teacher or high lvl student
-- student lvl decrease when not near fl (DB driven -1 per turn)
-- student lvl spread to enemy when high lvl teacher/student
-- physical traits random
-- physical traits changing

-- Change student to teacher
function yt_traits:convert_student_to_teacher( query_character, modify_character )

	if not self:has_student_trait( query_character ) then
		--script_error("yt_traits():convert_student_to_teacher: Trying to convert a teacher to a student, but the character doesn't have a student trait!" .. query_character:generation_template_key() );
		return false;
	end;
	
	local student_trait = self:get_learning_trait( query_character, self.student_trait_key );
	local student_trait_level = student_trait:num_points_in_ceo();

	modify_character:ceo_management():remove_ceos( self.student_trait_key );

	modify_character:ceo_management():add_ceo( self.teacher_trait_key );
	modify_character:ceo_management():change_points_of_ceos( self.teacher_trait_key, student_trait_level ); -- add teacher lvl equal to student lvl
	

end;


-- Change teacher to student.
function yt_traits:convert_teacher_to_student( query_character, modify_character )

	if not self:has_teacher_trait( query_character ) then
		return false;
	end;
	
	local teacher_trait = self:get_learning_trait( query_character, self.teacher_trait_key );
	local teacher_trait_level = teacher_trait:num_points_in_ceo();

	modify_character:ceo_management():remove_ceos( self.teacher_trait_key );
	
	modify_character:ceo_management():add_ceo( self.student_trait_key );
	modify_character:ceo_management():change_points_of_ceos( self.student_trait_key, teacher_trait_level ); -- add student lvl equal to teacher lvl

end;


-- Change a teacher to an ascended emperor. This is actually a teacher trait level which is unreachable through normal means.
function yt_traits:convert_teacher_to_emperor( query_character, modify_character )

	-- If we don't have the emperor ascention system or it's not fired, then ignore.
	if not yt_emperor_ascension and not yt_emperor_ascension:faction_leader_ascended( query_character:faction() ) then
		return false;
	end;
	
	if not self:has_teacher_trait( query_character ) then
		script_error("yt_traits():convert_teacher_to_emperor: Trying to convert a teacher to emperor, but the character doesn't have a teacher trait!" .. query_character:generation_template_key() );
		return false;
	end;
	
	modify_character:ceo_management():change_points_of_ceos( self.teacher_trait_key, self.emperor_trait_points_required );

end;


-- Generic tests for whether the character can even have traits. Can be a query
function yt_traits:character_can_have_learning_traits( query_character )

	-- Exit if character is null
	if not query_character or query_character:is_null_interface() then
		return false;
	end;

	-- Exit if not general
	if not char_is_general( query_character ) then
		return false;
	end;
		
	-- Exit if no CEO management
	if not query_character:ceo_management() or query_character:ceo_management():is_null_interface() then
		return false;
	end;

	if query_character:faction():subculture() ~= "3k_main_subculture_yellow_turban" then
		return false;
	end;

	return true;
end;


-- Test if the character has a query ceo management with the learning trait.
function yt_traits:has_learning_trait( query_character )
	return self:has_student_trait( query_character ) or self:has_teacher_trait( query_character );
end;


-- Tests if they have a student trait
function yt_traits:has_student_trait( query_character )
	
	if not self:character_can_have_learning_traits( query_character ) then
		return false;
	end;

	return query_character:ceo_management():has_ceo_equipped( self.student_trait_key );
end;


-- Tests if they have a teacher trait
function yt_traits:has_teacher_trait( query_character )
	
	if not self:character_can_have_learning_traits( query_character ) then
		return false;
	end;

	return query_character:ceo_management():has_ceo_equipped( self.teacher_trait_key );
end;


-- Returns the learning trait (if any exists). Please check with has_learning_trait() if you want to deal with this as a conditional before.
function yt_traits:get_learning_trait( query_character, optional_key )
	optional_key = optional_key or false;

	if not self:character_can_have_learning_traits( query_character ) then
		return nil;
	end;

	for i=0, query_character:ceo_management():all_ceos_for_category( self.learning_category_key ):num_items() - 1 do
		local ceo = query_character:ceo_management():all_ceos_for_category( self.learning_category_key ):item_at(i);

		if optional_key and ceo:ceo_data_key() == optional_key then
			return ceo;
		else
			return ceo;
		end;
	end;

	return nil;
end;


