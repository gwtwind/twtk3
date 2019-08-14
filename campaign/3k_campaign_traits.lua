---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Traits
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to manage general ceo triggering. 
-----               !!!! N.B. The 3k_campaign_experience.lua also manages some of this in the form of protagonists, personality and physical traits. We should probably move it in here at some point. !!!!
-----               WEALTH IS HANDLED IN THE WEALTH.LUA
-----               
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

output("3k_campaign_traits.lua: Loaded");

traits = {};

---------------------------------------------------------------------------------------------------------
----- DATA
---------------------------------------------------------------------------------------------------------

-- Debugging
traits.debug_mode = false;

-- Personality
traits.personality_traits_max = 7;

-- Physical
traits.physical_wound_chance_per_rank = 10; -- % of 100. base_chance = this * rank
traits.physical_traits_max = 1;
traits.physical_chance_of_serious_wound = 20; -- % of 100
traits.trigger_key_trait_physical_negative_light = "3k_main_ceo_trigger_character_trait_physical_negative_light";
traits.trigger_key_trait_physical_negative_serious = "3k_main_ceo_trigger_character_trait_physical_negative_serious";

-- Misc
traits.ceo_key_protagonist = "3k_main_ceo_protagonist";
traits.chance_of_lovestruck_trait = 5;
traits.trigger_key_lovestruck = "3k_main_ceo_trigger_character_trait_physical_lovestruck_level_up";


-- Attribute Trigger Data
traits.ATTRIBUTES = {
	ATT_EARTH = "authority",
	ATT_FIRE = "instinct",
	ATT_METAL = "expertise",
	ATT_WATER = "cunning",
	ATT_WOOD = "resolve"
};
traits.MAX_ATTRIBUTE_VALUE = 150;
traits.MIN_ATTRIBUTE_VALUE = 20;
traits.HIGHEST_ATTRIBUTE_MULTIPLIER = 1.2;
traits.LOWEST_ATTRIBUTE_MULTIPLIER = 1.25;


-- Trigger Datas
traits.trigger_datas = {};
traits.pending_trigger_datas = {}; -- A list of all the triggers we want to fire at the moment.
traits.num_trigger_datas_to_fire = 3; -- How many times we fire triggers when we try to.
traits.priority_decay_per_trgger = 0.5; -- A multiplier on how much priority a trigger loses when it's fires in a single go.

traits.debug_output = {};

require("3k_campaign_traits_data");

---------------------------------------------------------------------------------------------------------
----- MAIN FUNCTIONS
---------------------------------------------------------------------------------------------------------

--// initialise()
--// Entry point.
function traits:initialise()
    out.traits("3k_campaign_traits.lua: Initialise()" );

	-- Attributes: In records mode, the Attribute names can be different, so do it here before we do anything else.
	local query_model = cm:query_model();
	if query_model:campaign_game_mode() == "historical" then
		self.ATTRIBUTES.ATT_WOOD = "resolve_records";
	end;

	self.trigger_datas = self:load_trigger_datas(); -- Done here because we need to parse AFTER we change the values based on game_mode, or it'll desync.
	
	-- Make sure all the data we're using is valid. Saves it going wrong later.
	if not self:validate_trigger_datas( self.trigger_datas ) then
		script_error("ERROR: traits:initialise() Data is invalid, exiting.");
		return false;
	end;

	-- DEFINED IN 3k_campaign_traits_data.lua
    self:setup_debug_listeners();
    self:setup_lovestruck_listeners();
    self:setup_personality_listeners();
	self:setup_physical_listeners();
	self:setup_legendary_listeners();

	if self.debug_mode then
		self:debug_output_listeners();
	end;
end;


---------------------------------------------------------------------------------------------------------
----- LISTENERS
---------------------------------------------------------------------------------------------------------
-- DEFINED IN 3k_campaign_traits_data.lua
function traits:debug_output_listeners()
	traits.debug_output = file_output:new("traits.txt", true);

	traits.debug_output:write_line("TRAITS DEBUG");

	core:add_listener(
		"traits_debug_turn_start", -- Unique handle
		"FactionTurnStart", -- Campaign Event to listen for
		true,
		function(context) -- What to do if listener fires.
			--Do Stuff Here
			local faction = context:faction():name();
			local turn_number = context:query_model():turn_number();

			traits.debug_output:write_line("Turn: " .. tostring(turn_number) .. " - Faction: " .. tostring(faction), 0);
		end,
		true --Is persistent
	);

	core:add_listener(
        "traits_character_ceo_added",
        "CharacterCeoAdded",
        true,
        function(context)
            local ceo_key = context:ceo():ceo_data_key();
            local ceo_category_key = context:ceo():category_key()
			local template = context:query_character():generation_template_key();
			local cqi = context:query_character():command_queue_index();

			if ceo_category_key == "3k_main_ceo_category_traits_personality" then
				traits.debug_output:write_line(tostring(cqi) .. ": Ceo Gained: " .. tostring(ceo_key) .. ", " .. tostring(ceo_category_key) .. " template: " .. tostring(template), 1);
			end;
        end,
        true
    );
end;


---------------------------------------------------------------------------------------------------------
----- METHODS
---------------------------------------------------------------------------------------------------------

--[[ traits:add_protagonist_points(character, xp_gained)
	Take a character and a situation and give them protagonist points.
]]--
function traits:add_protagonist_points(modify_character, xp_gained)
	local points = 0;
	    
    if modify_character:is_null_interface() then
        script_error("traits:add_protagonist_points() - Null Modify Character passed in.");
        return;
    end;

	if not modify_character:ceo_management() or modify_character:ceo_management():is_null_interface() then
		return false;
	end;

	points = math.floor( xp_gained * 0.01 )

	-- always try to give at least one point to the protagonist trait.
	if points == 0 then
		points = 1;
	end;

	out.traits("3k_campaign_experience.lua: add_protagonist_points(): Adding: " .. tostring(points) .. " points.");

	modify_character:ceo_management():change_points_of_ceos( self.ceo_key_protagonist, points );
end;


--[[ fire_character_ceo_trigger(modify_character, trigger_key)
    Fires the given trigger_key on the modify_character
]]--
function traits:fire_character_ceo_trigger(modify_character, trigger_key)
    
    if modify_character:is_null_interface() then
        script_error("traits:fire_character_ceo_trigger() - Null Modify Character passed in.");
        return;
    end;

    if not is_string(trigger_key) then
        script_error("traits:fire_character_ceo_trigger() - Trigger is not a string.");
        return;
	end;

	if not modify_character:ceo_management() or modify_character:ceo_management():is_null_interface() then
		return false;
	end;

	if self.debug_mode then 
		out.traits("Firing CEO Trigger - " .. tostring(modify_character:query_character():command_queue_index()) .. ": ".. tostring(trigger_key) .. " - " .. tostring(modify_character:query_character():generation_template_key()) );
	end;

    modify_character:ceo_management():apply_trigger( trigger_key );

end;


--[[ traits:can_unlock_personality_traits()
    Uses a character and rolls based on their rank if they should unlock a new trait.
]]--
function traits:can_unlock_personality_traits(query_character, modify_model)
    local num_personality_traits = 0;

    if not query_character or query_character:is_null_interface() then 
        script_error("traits:can_unlock_personality_traits(): Modify character is null") 
        return false;
    end;

    if not modify_model or modify_model:is_null_interface() then
        script_error("traits:can_unlock_personality_traits(): Modify Model is null") 
        return false;
	end;

	--Usually means it's a castellan.	
	if not query_character:character_type("general") then
		return false;
	end;

	if not query_character:ceo_management() or query_character:ceo_management():is_null_interface() then
		return false;
	end;

	if query_character:is_dead() then
		return false;
	end;

    num_personality_traits = query_character:ceo_management():number_of_ceos_equipped_for_category("3k_main_ceo_category_traits_personality");

	if num_personality_traits >= self.personality_traits_max then
		return false;
	end;

	return true;

end;


--[[ traits:should_unlock_physical_trait()
    Uses a character and rolls based on their rank if they should unlock a new trait.
]]--
function traits:should_unlock_physical_wound_trait(query_character, modify_model)
    local random_pct = 0;
    local chance_modifier = 1;
    local num_physical_traits = 0;

    if query_character:is_null_interface() then 
        script_error("traits:should_unlock_physical_wound_trait(): Modify character is null") 
        return false;
    end;
 
    if not modify_model or modify_model:is_null_interface() then
        script_error("traits:should_unlock_physical_wound_trait(): Modify Model is null") 
        return false;
	end;
	
	--Usually means it's a castellan.
	if not query_character:character_type("general") then
		return false;
	end;

	if not query_character:ceo_management() or query_character:ceo_management():is_null_interface() then
		return false;
	end;

	if query_character:is_dead() then
		return false;
	end;

    num_physical_traits = query_character:ceo_management():number_of_ceos_equipped_for_category("3k_main_ceo_category_traits_physical");

	return roll_trait_chance(modify_model, 1, num_physical_traits, self.physical_traits_max, query_character:rank(), self.physical_wound_chance_per_rank);

end;

--[[ traits:roll_trait_chance()
    Random rolls a trait chance based on values passed in.
]]--
function roll_trait_chance(modify_model, event_modifier, current_trait_num, max_trait_num, current_rank, rank_modifier) -- rerturn boolean
	-- Exit if we've already reached our maximum.
	if current_trait_num == max_trait_num then
		return false;
	end;

	local random_pct = modify_model:random_percentage();

	local rank_chance = current_rank * rank_modifier;
	local amount_modifier = 1 - (current_trait_num / max_trait_num);
	local final_chance =  rank_chance * amount_modifier * event_modifier;

	if final_chance >= random_pct then
        return true;
    end;

    return false;
end;



---------------------------------------------------------------------------------------------------------
----- ATTRIBUTE TRAIT SYSTEM
---------------------------------------------------------------------------------------------------------


--[[ get_highest_attribute_and_value( query_character )
	Gets the character's highest attribute
]]--
function traits:get_highest_attribute_and_value( query_character )
	local return_att_key = self.ATTRIBUTES.ATT_EARTH;
	local return_att_value = -1;

	for k, v in pairs(self.ATTRIBUTES) do
		local attribute_key = v;

		local attribute_value = query_character:get_current_attribute_value( attribute_key );
		
		if attribute_value > return_att_value then
			return_att_key = attribute_key;
			return_att_value = attribute_value;
		end;
	end;
	
	return return_att_key, return_att_value;

end;


--[[ get_lowest_attribute_and_value( query_character )
	Gets the character's lowest attribute
]]--
function traits:get_lowest_attribute_and_value( query_character )
	local return_att_key = self.ATTRIBUTES.ATT_EARTH;
	local return_att_value = 10000;

	for k, v in pairs(self.ATTRIBUTES) do
		local attribute_key = v;
		local attribute_value = query_character:get_current_attribute_value( attribute_key );
		
		if attribute_value < return_att_value then
			return_att_key = attribute_key;
			return_att_value = attribute_value;
		end;
	end;
	
	return return_att_key, return_att_value;

end;


--[[ get_total_attribute_value( query_character )
	Gets the sum of all the character's attributes.
]]--
function traits:get_total_attribute_value( query_character )
	local sum_value = 0;

	for k, v in pairs(self.ATTRIBUTES) do
		local attribute_key = v;
		local attribute_value = query_character:get_current_attribute_value( attribute_key );

		sum_value = sum_value + attribute_value;
	end;

	return sum_value;
end;


--[[ get_weighted_random_attribute_key( query_character, attribute_key_1, attribute_key_1_multiplier, attribute_key_2, attribute_key_2_multiplier )
	Takes a character, and optional attribute pairs.
	Uses those values to roll a weighted random using the character's stats.
	Returns an attribute key + a value for that attribute.
]]--
function traits:get_weighted_random_attribute_key( query_character, 
	attribute_key_1, attribute_key_1_multiplier, 
	attribute_key_2, attribute_key_2_multiplier )

	-- get and cache our attribute values in a table. This is so we can 'manipulate' them basec on weighting and value.
	local weighted_attributes = {};
	local total_weighting = 0;

	for k, v in pairs(self.ATTRIBUTES) do
		local attribute_key = v;
		local attribute_value_raw = query_character:get_current_attribute_value( attribute_key );
		local attribute_value_modified = attribute_value_raw;

		
		-- If we're less than the min positive value then clamp it to prevent 0s.
		attribute_value_modified = math.max( attribute_value_modified, self.MIN_ATTRIBUTE_VALUE );

		-- If we're above our max, then clamp to prevent an attribute 'running away with it'.
		attribute_value_modified = math.min( attribute_value_modified, self.MAX_ATTRIBUTE_VALUE );

		-- Multiply said attributes.
		if attribute_key_1 and attribute_key_1 == attribute_key then -- If we passed in an attribute_key_1 then add its value.
			attribute_value_modified = attribute_value_modified * attribute_key_1_multiplier;
		elseif attribute_key_2 and attribute_key_2 == attribute_key then -- If we passed in an attribute_key_2 then add its value.
			attribute_value_modified = attribute_value_modified * attribute_key_2_multiplier;
		end;

		-- Add it to our table for use below.
		table.insert( weighted_attributes, {attribute_key, attribute_value_raw, attribute_value_modified} );
		
		-- Get our total weighting here to save another iteration.
		total_weighting = total_weighting + attribute_value_modified;
	end;

	-- Roll a weighted random
	local r = cm:modify_model():random_number(0, total_weighting);

	-- Use our modified values from above to work out the weighting.
	for k, v in ipairs( weighted_attributes ) do
		local attribute_key = v[1];
		local attribute_value_raw = v[2];
		local attribute_value_modified = v[3];
		
		r = r - attribute_value_modified; -- Subtract the weighting from our random total above.

		if r <= 0 then -- If we're below 0 then we fall within that attribute's values.
			return attribute_key;
		end;
		
	end;

	script_error( "3k_traits:get_weighted_random_attribute_key() didn't return! this should be impossible. See Simon. " )
	return "";
end;


--[[ get_attribute_key_weighted_by_highest_and_lowest( query_character )
	Wrapper function to get the highest and lowest attributes then roll a weighting on them.
]]--
function traits:get_attribute_key_weighted_by_highest_and_lowest( query_character )
	local a1 = self:get_highest_attribute_and_value( query_character );
	local a2 = self:get_lowest_attribute_and_value( query_character );
	return self:get_weighted_random_attribute_key( query_character, a1, self.HIGHEST_ATTRIBUTE_MULTIPLIER, a2, self.LOWEST_ATTRIBUTE_MULTIPLIER );
end;



---------------------------------------------------------------------------------------------------------
----- TRIGGER DATA FUNCTIONALITY
---------------------------------------------------------------------------------------------------------


--[[ fire_from_pending_trigger_data_old( query_character )
	Wrapper function to get the highest and lowest attributes then roll a weighting on them.
]]--
function traits:fire_from_pending_trigger_data_old( modify_character, use_element )

	if #self.pending_trigger_datas < 1 then
		script_error("ERROR: fire_from_pending_trigger_data_old() No pending trigger datas!");
		return false;
	end;

	local weighted_trigger_datas = deepcopy(self.pending_trigger_datas); -- Create a local copy as we'll manipulate this.
	
	-- Get the total weighting so we can random roll.
	local total_weighting = 0;
	for i, v in ipairs(weighted_trigger_datas) do
		total_weighting = total_weighting + v.priority;
	end;

	-- We fire X times so that multiple traits can gain points (or multiple triggers be fired).
	for i = 1, self.num_trigger_datas_to_fire do

		-- Roll a weighted random
		local r = cm:modify_model():random_number(0, total_weighting);

		-- Go through all the trigger datas we want to try and fire.
		for j, trigger_data in ipairs( weighted_trigger_datas ) do
			local weight = trigger_data.priority;
			
			r = r - weight; -- Subtract the weighting from our random total above.

			if r <= 0 then -- If we're below 0 then we fall within that attribute's values.

				-- Pick the trigger by element, by doing this each time, we'll have some variance.
				local attribute_key = self:get_attribute_key_weighted_by_highest_and_lowest( modify_character:query_character() );

				-- Fire any triggers which match our selected element, from the trigger data.
				for k, v in ipairs(trigger_data.triggers) do
					if v.element == attribute_key then
						self:fire_character_ceo_trigger( modify_character, v.trigger_key );
					end;
				end;
				
				-- Lower the weighting of this trigger so it's less likely to fire again.
				total_weighting = total_weighting - (trigger_data.priority * self.priority_decay_per_trgger); -- Remove from our total weighting so it won't overflow.
				trigger_data.priority = trigger_data.priority * self.priority_decay_per_trgger;			

				break; -- Exit out of the loop so we don't fire all the triggers below this one in the list.
			end;
			
		end;
	end;

	self:clear_pending_trigger_data();
end;

--[[ fire_from_pending_trigger_data( query_character )
	Wrapper function to get the highest and lowest attributes then roll a weighting on them.
]]--
function traits:fire_from_pending_trigger_data( modify_character, use_element )

	if #self.pending_trigger_datas < 1 then
		script_error("ERROR: fire_from_pending_trigger_data() No pending trigger datas!");
		return false;
	end;

	local previous_triggers = {};

	-- We fire X times so that multiple traits can gain points (or multiple triggers be fired).
	-- Limit by the number of triggers so lower ranked characters don't benefit more.
	for i = 1, math.min(#self.pending_trigger_datas, self.num_trigger_datas_to_fire) do

		-- Pick the trigger by element, by doing this each time, we'll have some variance.
		local attribute_key = self:get_attribute_key_weighted_by_highest_and_lowest( modify_character:query_character() );

		local weighted_trigger_datas = deepcopy(self.pending_trigger_datas); -- Create a local copy as we'll manipulate this.

		-- Get the total weighting so we can random roll.
		local total_weighting = 0;
		for j, td in ipairs(weighted_trigger_datas) do
			for k, et in ipairs(td.triggers) do
				if et.element == attribute_key then

					-- Reduce the weighting for every time this has fired before.
					local times_fired_before = 0;
					for l, prev in ipairs(previous_triggers) do
						if prev == et.trigger_key then
							times_fired_before = times_fired_before + 1;
						end;
					end;

					if times_fired_before > 0 then
						total_weighting = total_weighting + ( (td.priority * et.num_ceos) * (self.priority_decay_per_trgger / times_fired_before) );
					else
						total_weighting = total_weighting + (td.priority * et.num_ceos);
					end;
				end;
			end;
		end;
		
		-- Roll a random against the weight
		local r = cm:modify_model():random_number(0, total_weighting);

		-- Go through all the trigger datas we want to try and fire.
		for j, td in ipairs( weighted_trigger_datas ) do
			local weight = 0;
			local trigger_key = nil;

			-- Get the weighting of this particular element trigger.
			for k, et in ipairs(td.triggers) do
				if et.element == attribute_key then

					-- Reduce the weighting for every time this has fired before.
					local times_fired_before = 0;
					for l, prev in ipairs(previous_triggers) do
						if prev == et.trigger_key then
							times_fired_before = times_fired_before + 1;
						end;
					end;

					if times_fired_before > 0 then
						weight = ( (td.priority * et.num_ceos) * (self.priority_decay_per_trgger / times_fired_before) );
					else
						weight = (td.priority * et.num_ceos);
					end;

					trigger_key = et.trigger_key;
					break;
				end;
			end;
			
			r = r - weight; -- Subtract the weighting from our random total above.

			if r <= 0 then -- If we're below 0 then we fall within that attribute's values.
				-- Fire any triggers which match our selected element, from the trigger data.
				self:fire_character_ceo_trigger( modify_character, trigger_key );

				-- Add to our list of previous triggers to we can make is less likely to fire in future.
				table.insert(previous_triggers, trigger_key);

				break; -- Exit out of the loop so we don't fire all the triggers below this one in the list.
			end;
			
		end;
	end;

	self:clear_pending_trigger_data();
end;


--[[ add_pending_trigger_data( trigger_data )
	Validates and add the trigger to the pending_trigger_datas.
]]--
function traits:add_pending_trigger_data( trigger_data )
	if not self:validate_trigger( trigger_data ) then
		script_error("ERROR: Badly formed trigger data added.");
		return false;
	end;

	table.insert(self.pending_trigger_datas, trigger_data);
end;


--[[ clear_pending_trigger_data()
	Clears out all the pending triggers.
]]--
function traits:clear_pending_trigger_data()
	self.pending_trigger_datas = {};
end;	


--[[ validate_trigger_datas( trigger_data_list )
	Goes through all the trigger data list and validates it.
]]--
function traits:validate_trigger_datas( trigger_data_list )
	local is_valid = true;

	if table_length(trigger_data_list) < 1 then
		script_error( "validate_trigger_datas() No trigger datas!" );
	end;

	for k, v in pairs( trigger_data_list ) do
		is_valid = self:validate_trigger( v );
	end;

	return is_valid;
end;


--[[ validate_trigger( trigger_data )
	Validates a single trigger.
]]--
function traits:validate_trigger( trigger_data )
	local is_valid = true;

	if not is_number(trigger_data.priority) then
		script_error( "validate_trigger_datas() " .. tostring(k) .. "badly formed trigger, PRIORITY should be a number." .. tostring(trigger_data.priority) );
		is_valid = false;
	end;
	
	if not is_table(trigger_data.triggers) then
		script_error( "validate_trigger_datas() " .. tostring(k) .. "badly formed trigger, TRIGGERS should be a table." .. tostring(trigger_data.triggers) );
		is_valid = false;
	end;

	if is_table(trigger_data.triggers) then
		if #trigger_data.triggers == 0 then
			script_error( "validate_trigger_datas() " .. tostring(k) .. "badly formed trigger, TRIGGERS has 0 elements." );
			is_valid = false;
		end;

		for i, trigger in ipairs( trigger_data.triggers ) do
			if not is_string(trigger.trigger_key) then
				script_error( "validate_trigger_datas() " .. tostring(k) .. "badly formed trigger, child trigger data 'trigger_key' must be a string." .. tostring(trigger.trigger_key) );
				is_valid = false;
			end;
		
			if not is_string(trigger.element) then
				script_error( "validate_trigger_datas() " .. tostring(k) .. "badly formed trigger, child trigger data 'element' must be a string." .. tostring(trigger.element)  );
				is_valid = false;
			end;
		
			if not is_number(trigger.num_ceos) then
				script_error( "validate_trigger_datas() " .. tostring(k) .. "badly formed trigger, child trigger data 'num_ceos' must be a number." .. tostring(trigger.num_ceos)  );
				is_valid = false;
			end;
		end;
	end;

	return is_valid;
end;