


----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	CAMPAIGN UI MANAGER
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------



----------------------------------------------------------------------------
--	Debug output of campaign objects
----------------------------------------------------------------------------

output_campaign_obj_separator = "==============================================================";

-- single line object to string
function output_campaign_obj(input, verbosity)
	-- possible values of verbosity: 0 = full version, 1 = abridged, 2 = one line summary
	verbosity = verbosity or 0;
	
	if verbosity == 2 then
		out(campaign_obj_to_string(input));
		return;
	end;
		
	-- CHARACTER
	if is_query_character(input) then
		if verbosity == 0 then
			out("");
			out("CHARACTER:");
			out(output_campaign_obj_separator);
		end;
		inc_tab();
		out("cqi:\t\t\t" .. tostring(input:cqi()));
		out("faction:\t\t\t" .. input:faction():name());
		out("forename:\t\t" .. input:get_forename());
		out("surname:\t\t" .. input:get_surname());
		if input:has_region() then
			if verbosity == 0 then
				out("region:");
				inc_tab();
				output_campaign_obj(input:region(), 1);
				dec_tab();
			else
				out("region:\t" .. campaign_obj_to_string(input:region()));
			end;
		else
			out("region:\t<no region>");
		end;
		out("logical position:\t[" .. tostring(input:logical_position_x()) .. ", " .. tostring(input:logical_position_y()) .."]");
		out("display position:\t[" .. tostring(input:display_position_x()) .. ", " .. tostring(input:display_position_y()) .."]");
		
		if input:has_military_force() then
			if verbosity == 0 then
				out("military force:");
				inc_tab();
				output_campaign_obj(input:military_force(), 1);
				dec_tab();
			else
				out("military force:\t<commanding> " .. campaign_obj_to_string(input:military_force()));
			end;
		else
			out("military force:\t<not commanding>");
		end;
		
		out("has residence:\t" .. tostring(input:has_garrison_residence()));
		
		if verbosity ~= 0 then
			out("is male:\t" .. tostring(input:is_male()));
			out("age:\t" .. tostring(input:age()));
			out("loyalty:\t" .. tostring(input:loyalty()));
			out("gravitas:\t" .. tostring(input:gravitas()));
			out("is embedded:\t" .. tostring(input:is_embedded_in_military_force()));
		end;
		
		dec_tab();
		
		if verbosity == 0 then
			out(output_campaign_obj_separator);
			out("");
		end;
	
	
	-- REGION
	elseif is_query_region(input) then	
		if verbosity == 0 then
			out("");
			out("REGION:");
			out(output_campaign_obj_separator);
		end;
		inc_tab();
		out("name:\t\t\t" .. input:name());
		
		
		if verbosity == 0 then
			out("owning faction:");
			inc_tab();
			output_campaign_obj(input:owning_faction(), 1);
			dec_tab();
		else
			out("owning faction:\t" .. campaign_obj_to_string(input:owning_faction()));
		end;
		
		if input:has_governor() then
			if verbosity == 0 then
				out("governor:");
				inc_tab();
				output_campaign_obj(input:governor(), 1);
				dec_tab();
			else
				out("governor:\t\t " .. campaign_obj_to_string(input:governor()));
			end;
		else
			out("governor:\t\t<no governor>");
		end;
		
		if input:garrison_residence():has_army() then
			if verbosity == 0 then
				out("garrisoned army:");
				inc_tab();
				output_campaign_obj(input:garrison_residence():army(), 1);
				dec_tab();
			else
				out("garrisoned army: " .. campaign_obj_to_string(input:garrison_residence():army()));
			end;
		else
			out("garrisoned army:\t<no army>");
		end;
			
		if input:garrison_residence():has_navy() then
			if verbosity == 0 then
				out("garrisoned navy:");
				inc_tab();
				output_campaign_obj(input:garrison_residence():navy(), 1);
				dec_tab();
			else
				out("garrisoned navy: " .. campaign_obj_to_string(input:garrison_residence():navy()));
			end;
		else
			out("garrisoned navy:\t<no navy>");
		end;
		
		out("under siege:\t\t" .. tostring(input:garrison_residence():is_under_siege()));
		
		if verbosity == 0 then
			out("num buildings:\t" .. tostring(input:num_buildings()));
			out("public order:\t\t" .. tostring(input:public_order()));
			out("majority religion:\t" .. input:majority_religion());
		end;
		
		dec_tab();
		
		if verbosity == 0 then
			out(output_campaign_obj_separator);
			out("");
		end;
	
	
	-- FACTION
	elseif is_query_faction(input) then
		if verbosity == 0 then
			out("");
			out("FACTION:");
			out(output_campaign_obj_separator);
		end;
		inc_tab();
		out("name:\t\t" .. input:name());
		out("human:\t" .. tostring(input:is_human()));
		out("regions:\t" .. tostring(input:region_list():num_items()));
		
		if verbosity == 0 then
			local region_list = input:region_list();
			inc_tab();
			for i = 0, region_list:num_items() - 1 do
				out(i .. ":\t" .. campaign_obj_to_string(region_list:item_at(i)));
			end;
			dec_tab();
		end;
		
		if input:has_faction_leader() then
			if verbosity == 0 then
				out("faction leader:");
				inc_tab();
				output_campaign_obj(input:faction_leader(), 1);
				dec_tab();
			else
				out("faction leader: " .. campaign_obj_to_string(input:faction_leader()));
			end;
		else
			out("faction leader:\t<none>");
		end;
		
		out("characters:\t" .. tostring(input:character_list():num_items()));
		
		if verbosity == 0 then
			local character_list = input:character_list();
			inc_tab();
			for i = 0, character_list:num_items() - 1 do
				out(i .. ":\t" .. campaign_obj_to_string(character_list:item_at(i)));
			end;
			dec_tab();
		end;

		out("mil forces:\t" .. tostring(input:military_force_list():num_items()));
		
		if verbosity == 0 then
			local military_force_list = input:military_force_list();
			inc_tab();
			for i = 0, military_force_list:num_items() - 1 do
				out(i .. ":\t" .. campaign_obj_to_string(military_force_list:item_at(i)));
			end;
			dec_tab();
		end;
				
		if verbosity == 0 then
			out("state religion:\t" .. tostring(input:state_religion()));
			out("culture:\t" .. tostring(input:culture()));
			out("subculture:\t" .. tostring(input:subculture()));
			out("treasury:\t" .. tostring(input:treasury()));
			out("tax level:\t" .. tostring(input:tax_level()));
			out("losing money:\t" .. tostring(input:losing_money()));
			out("food short.:\t" .. tostring(input:has_food_shortage()));
			out("horde:\t" .. tostring(faction_is_horde(input)));
			out("imperium:\t" .. tostring(input:imperium_level()));
		end;
		
		dec_tab();
		
		if verbosity == 0 then
			out(output_campaign_obj_separator);
			out("");
		end;
	
	
	-- MILITARY FORCE
	elseif is_query_military_force(input) then
		if verbosity == 0 then
			out("");
			out("MILITARY FORCE:");
			out(output_campaign_obj_separator);
		end;
		inc_tab();
		if input:has_general() then
			if verbosity == 0 then
				out("general:");
				inc_tab();
				output_campaign_obj(input:general_character(), 1);
				dec_tab();
			else
				out("general:\t" .. campaign_obj_to_string(input:general_character()));
			end;
		else
			out("general:\t<none>");
		end;
		
		out("is army:\t" .. tostring(input:is_army()));
		out("is navy:\t" .. tostring(input:is_navy()));
		out("faction:\t\t" .. campaign_obj_to_string(input:faction()));
		out("units:\t\t" .. tostring(input:unit_list():num_items()));
		
		if verbosity == 0 then
			local unit_list = input:unit_list();
			inc_tab();
			for i = 0, unit_list:num_items() - 1 do
				out(i .. ":\t" .. campaign_obj_to_string(unit_list:item_at(i)));
			end;
			dec_tab();
		end;
		
		out("characters:\t" .. tostring(input:character_list():num_items()));
		
		if verbosity == 0 then
			local char_list = input:character_list();
			inc_tab();
			for i = 1, char_list:num_items() - 1 do
				out(i .. ":\t" .. campaign_obj_to_string(char_list:item_at(i)));
			end;
			dec_tab();
		end;
		
		out("residence:\t" .. tostring(input:has_garrison_residence()));
		
		if verbosity == 0 then
			out("mercenaries:\t" .. tostring(input:contains_mercenaries()));
			out("upkeep:\t" .. tostring(input:upkeep()));
			out("is_armed_citizenry:\t" .. tostring(input:is_armed_citizenry()));
		end;
		
		dec_tab();
		
		if verbosity == 0 then
			out(output_campaign_obj_separator);
			out("");
		end;
	
	else
		script_error("WARNING: output_campaign_obj() did not recognise input " .. tostring(input));
	end;
end;



-- returns a one-line summary of the object as a string
function campaign_obj_to_string(input)
	if is_query_character(input) then
		return ("CHARACTER cqi[" .. tostring(input:cqi()) .. "], faction[" .. input:faction():name() .. "], forename[" .. input:get_forename() .. "], surname[" .. input:get_surname() .. "], logical pos[" .. input:logical_position_x() .. ", " .. input:logical_position_y() .. "]");
	
	elseif is_query_region(input) then
		return ("REGION name[" .. input:name() .. "], owning faction[" .. input:owning_faction():name() .. "]");
		
	elseif is_query_faction(input) then
		return ("FACTION name[" .. input:name() .. "], num regions[" .. tostring(input:region_list():num_items()) .. "]");
	
	elseif is_query_military_force(input) then
		local gen_details = "" 
				
		if input:has_general() then
			local char = input:general_character();
			gen_details = "general cqi[" .. tostring(char:cqi()) .. "], logical pos [" .. char:logical_position_x() .. ", " .. char:logical_position_y() .. "]";
		else
			gen_details = "general: [none], logical pos[unknown]";
		end;
			
		return ("MILITARY_FORCE faction[" .. input:faction():name() .. "] units[" .. tostring(input:unit_list():num_items()) .. "], " .. gen_details .. "], upkeep[" .. tostring(input:upkeep()) .. "]");
	
	elseif is_unit(input) then
		return ("UNIT key[" .. input:unit_key() .. "], strength[" .. tostring(input:percentage_proportion_of_full_strength()) .. "]");
	
	else
		return "<campaign object [" .. tostring(input) .. "] not recognised>";
	end;
end;










----------------------------------------------------------------------------
--	Distance test
----------------------------------------------------------------------------

function distance_squared(a_x, a_y, b_x, b_y)
	return (b_x - a_x) ^ 2 + (b_y - a_y) ^ 2;
end;














----------------------------------------------------------------------------
--	UI tests
--	helper functions for help page howto's (and anything else in need)
----------------------------------------------------------------------------

function num_queued_unit_cards_visible()
	local uic_units = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "units");
	
	local count = 0;
	
	if not uic_units then
		return 0;
	end;
	
	for i = 0, uic_units:ChildCount() - 1 do
		local uic_child = UIComponent(uic_units:Find(i));
		
		if string.sub(uic_child:Id(), 1, 14) == "QueuedLandUnit" then
			count = count + 1;
		end;
	end;
	
	return count;
end;
















----------------------------------------------------------------------------
--	get_cached_cqi()
--	Takes a value name and a callback that returns a cqi (usually a char
--	or mf). If a saved cqi of this name exists in the savegame then this
--	is returned, otherwise the returned value of the supplied identifier
--	callback is retrieved and returned. If this is value is a valid cqi,
--	it is saved into the savegame with the supplied name.
----------------------------------------------------------------------------
function get_cached_cqi(saved_value_name, identifier_callback)
	if not is_string(saved_value_name) then
		script_error("ERROR: get_cached_char_cqi() called but supplied saved value name [" .. tostring(saved_value_name) .. "] is not a string");
		return false;
	end;
	
	if not is_function(identifier_callback) then
		script_error("ERROR: get_cached_char_cqi() called but supplied identifier callback [" .. tostring(identifier_callback) .. "] is not a function");
		return false;
	end;
	
	local cm = get_cm();		
	local cqi = cm:get_saved_value(saved_value_name);

	if is_number(cqi) and cqi > 0 then
		return cqi;
	end;
	
	local cqi = identifier_callback();
	
	if is_number(cqi) and cqi > 0 then
		cm:set_saved_value(saved_value_name, cqi);
	else
		script_error("ERROR: get_cached_cqi() identifier callback did not return a valid cqi, returned value is [" .. tostring(cqi) .. "]. Alternatively the saved value corresponding to supplied name [" .. saved_value_name .. "] (" .. tostring(cm:get_saved_value(saved_value_name)) .. "] may not be valid.");
	end;
	
	return cqi;
end;

















-- 	The rest of this file is for helper functions to do with characters/military forces/regions etc
--	The sections are listed alphabetically so if you're looking at the *P*ending_battle section and
--	you want to find a function that deals with *G*arrisons, you need to scroll up.


----------------------------------------------------------------------------
--	Building
----------------------------------------------------------------------------

function building_exists_in_province(building_key, province_key)
	script_error("ERROR: building_exists_in_province() called but needs fixing up to support new query interface");
	return false;
	--[[
	if not is_string(building_key) then
		script_error("ERROR: building_exists_in_province() called but supplied building key [" .. tostring(building_key) .. "] is not a string");
		return false;
	end;
	
	if not is_string(province_key) then
		script_error("ERROR: building_exists_in_province() called but supplied province key [" .. tostring(province_key) .. "] is not a string");
		return false;
	end;

	local region_list = get_cm():query_model():world():region_manager():region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		if current_region:province_name() == province_key and current_region:building_exists(building_key) then
			return true;
		end;
	end;
	
	return false;
	]]
end;








----------------------------------------------------------------------------
--	Character
----------------------------------------------------------------------------


function get_garrison_commander_of_region(region)
	if not is_query_region(region) then
		script_error("ERROR: get_garrison_commander_of_region() called but supplied object [" .. tostring(region) .. "] is not a valid region");
		return false;
	end
	
	if region:is_abandoned() then
		return false;
	end;
	
	local faction = region:owning_faction();
	
	if not is_query_faction(faction) then
		return false;
	end;
	
	local character_list = faction:character_list();
	
	inc_tab();
	for i = 0, character_list:num_items() - 1 do
		local character = character_list:item_at(i);
		
		if character:has_military_force() and character:military_force():is_armed_citizenry() and character:has_region() and character:region() == region then		
			dec_tab();
			return character;
		end;
	end;
	dec_tab();
end;


function get_closest_commander_to_position_from_faction(faction, x, y, consider_garrison_commanders)
	return get_closest_character_to_position_from_faction(faction, x, y, true, consider_garrison_commanders);
end;


function get_closest_character_to_position_from_faction(faction, x, y, generals_only, consider_garrison_commanders)
	generals_only = not not generals_only;
	consider_garrison_commanders = not not consider_garrison_commanders;
	
	if not generals_only then
		consider_garrison_commanders = true;
	end;

	if not is_query_faction(faction) then
		local faction_found = false;
		
		if is_string(faction) then	
			faction = cm:query_faction(faction);
			if faction then
				faction_found = true;
			end;
		end;
		
		if not faction_found then
			script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied faction [" .. tostring(faction) .. "] is not a valid query_faction, or a string name of a faction");
			return false;
		end;
	end;
	
	if not is_number(x) or x < 0 then
		script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(y) or y < 0 then
		script_error("ERROR: get_closest_character_to_position_from_faction() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a positive number");
		return false;
	end;
	
	local char_list = faction:character_list();
	local closest_char = false;
	local closest_distance_squared = 100000000;
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		-- if we aren't only looking for generals OR if we are and this is a general AND if we are considering garrison commanders OR if we aren't and it is a general proceed
		if not generals_only or (char_is_general(current_char) and current_char:has_military_force() and (consider_garrison_commanders or not current_char:military_force():is_armed_citizenry())) then			
			local current_char_x, current_char_y = char_logical_pos(current_char);
			local current_distance_squared = distance_squared(x, y, current_char_x, current_char_y);
			if current_distance_squared < closest_distance_squared then
				closest_char = current_char;
				closest_distance_squared = current_distance_squared;
			end;
		end;
	end;
	
	return closest_char, closest_distance_squared ^ 0.5;
end;


function get_commander_at_position_all_factions(x, y)
	local faction_list = cm:query_model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
			
		local military_force_list = faction:military_force_list();
		
		for j = 0, military_force_list:num_items() - 1 do
			local mf = military_force_list:item_at(j);
			
			if military_force_is_mobile(mf) and mf:has_general() then
				local char = mf:general_character();
				
				if char:logical_position_x() == x and char:logical_position_y() == y then
					return char;
				end;
			end;
		end;
	end;
	
	return false;
end;


function char_display_pos(character)
	if not is_query_character(character) then
		script_error("ERROR: char_display_pos() called but supplied object [" .. tostring(character) .. "] is not a character");
		return 0, 0;
	end;
	
	return character:display_position_x(), character:display_position_y();
end;


function char_logical_pos(character)
	if not is_query_character(character) then
		script_error("ERROR: char_logical_pos() called but supplied object [" .. tostring(character) .. "] is not a character");
		return 0, 0;
	end;

	return character:logical_position_x(), character:logical_position_y();
end;


function char_is_army_commander(char)
	if not is_query_character(char) then
		script_error("ERROR: char_is_army_commander() called but supplied object [" .. tostring(character) .. "] is not a character");
		return false;
	end;
	
	if not char:has_military_force() then
		return false;
	end;
	
	local military_force = char:military_force();
	
	return military_force:has_general() and military_force:general_character() == char and military_force:upkeep() > 0;
end;


function char_lookup_str(obj)
	if is_nil(obj) then
		script_error("ERROR: char_lookup_str() called but supplied object is nil");
		return false;
	end

	if is_number(obj) or is_string(obj) then
		return "character_cqi:" .. obj;
	end;
	
	if is_query_character(obj) then
		return "character_cqi:" .. obj:cqi();
	elseif is_modify_character(obj) then
		return "character_cqi:" .. obj:query_faction():cqi()
	else
		script_error("ERROR: char_lookup_str() called but could not recognise supplied object [" .. tostring(obj) .. "]");
	end;
end;


function char_in_owned_region(char)
	return char:has_region() and (char:region():owning_faction():name() == char:faction():name());
end;


function char_is_agent(char)
	return char:character_type("champion") or 
		char:character_type("spy") or 
		char:character_type("dignitary") or 
		char:character_type("engineer") or 
		char:character_type("runesmith") or 
		char:character_type("wizard") or 
		char:character_type("minister")
end;


function char_is_general(char)
	return char:character_type("general");
end;


function char_is_victorious_general(char)
	return char:character_type("general") and char:won_battle();
end;


function char_is_defeated_general(char)
	return char:character_type("general") and not char:won_battle();
end;


-- Returns true if the character is the governor of a region.
function char_is_governor(char)
	return char:has_region() and char:region():has_governor() and char:region():governor() == char;
end


function char_is_general_with_army(char)
	return char_is_general(char) and char_has_army(char);
end;


function char_is_mobile_general_with_army(char)
	return char_is_general_with_army(char) and military_force_is_mobile(char:military_force());
end;


function char_is_general_with_navy(char)
	return char_is_general(char) and char_has_navy(char);
end;


function char_has_army(char)
	return char:has_military_force() and char:military_force():is_army();
end;


function char_has_navy(char)
	return char:has_military_force() and char:military_force():is_navy();
end;


function char_rank_between(char, min, max)
	return char:rank() >= min and char:rank() <= max;
end;


function char_is_in_region_list(char, region_list)
	return table_contains(region_list, char:region():name());
end;


function char_is_attacker(char)
	local pb = char:model():pending_battle();
	return pb:has_attacker() and pb:attacker() == char;
end;


function char_is_defender(char)
	local pb = char:model():pending_battle();
	return pb:has_defender() and pb:defender() == char;
end;


-- logical positions
function get_closest_character_from_faction(faction, x, y)
	local closest_distance = 1000000000;
	local closest_character = false;
	
	local char_list = faction:character_list();
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		local current_distance = distance_squared(x, y, current_char:logical_position_x(), current_char:logical_position_y());
		if current_distance < closest_distance then
			closest_distance = current_distance;
			closest_character = current_character;
		end;
	end;
	
	return closest_character, closest_distance;	
end;


-- character_can_reach_character() test on the model returns false-positives if the source character has no action points, so this wrapper function performs that test too
function character_can_reach_character(source_char, target_char)
	if not is_query_character(source_char) then
		script_error("ERROR: character_can_reach_character() called but supplied source character [" .. tostring(source_char) .. "] is not a character");
		return false;
	end;
	
	if not is_query_character(target_char) then
		script_error("ERROR: character_can_reach_character() called but supplied target character [" .. tostring(target_char) .. "] is not a character");
		return false;
	end;
	
	return source_char:action_points_remaining_percent() > 0 and get_cm():query_model():character_can_reach_character(source_char, target_char);
end;


-- character_can_reach_settlement() wrapper, assume it returns the same false-positives as character_can_reach_character() above
-- not supported in 3K currently
--[[
function character_can_reach_settlement(source_char, target_settlement)
	if not is_character(source_char) then
		script_error("ERROR: character_can_reach_settlement() called but supplied source character [" .. tostring(source_char) .. "] is not a character");
		return false;
	end;
	
	if not is_settlement(target_settlement) then
		script_error("ERROR: character_can_reach_settlement() called but supplied target settlement [" .. tostring(target_settlement) .. "] is not a settlement");
		return false;
	end;
	
	return source_char:action_points_remaining_percent() > 0 and get_cm():query_model():character_can_reach_settlement(source_char, target_settlement);
end;
]]



function get_highest_ranked_general_for_faction(faction)
	if not is_query_faction(faction) then
		script_error("ERROR: get_highest_ranked_general_for_faction() called but supplied object [" .. tostring(faction) .. "] is not a faction");
		return false;
	end;
	
	local char_list = faction:character_list();
	
	local current_rank = 0;
	local chosen_char = nil;
	local char_x = 0;
	local char_y = 0;
	
	for i = 0, char_list:num_items() - 1 do
		local current_char = char_list:item_at(i);
		
		if char_is_general_with_army(current_char) then
			local rank = current_char:rank();
			
			if rank > current_rank then
				chosen_char = current_char;
				current_rank = rank;
			end;
		end;
	end;

	if chosen_char then
		return chosen_char;
	else
		return false;
	end;
end;












----------------------------------------------------------------------------
--	Faction
----------------------------------------------------------------------------

-- returns a table containing the keys of all human factions
-- don't call this unless absolutely necessary - call the version on campaign manager instead as it gets cached there
function get_human_factions()
	local faction_list = get_cm():query_model():world():faction_list();
	local human_factions = {};
	
	for i = 0, faction_list:num_items() - 1 do
		if faction_list:item_at(i):is_human() then
			table.insert(human_factions, faction_list:item_at(i):name());
		end;
	end;
	
	return human_factions;
end;


function faction_contains_building(faction, key)
	local region_list = faction:region_list();
	
	for i = 0, region_list:num_items() - 1 do
		local region = region_list:item_at(i);
		
		if region:building_exists(key) then
			return true;
		end;
	end;
	
	return false;
end;


-- Returns number of supplied agent types in the target faction
function num_agents_in_faction(faction, agent_type)
	if faction:character_list():num_items() == 0 then
		return 0;
	end;
	
	local num_found = 0;
	for i = 0, faction:character_list():num_items() - 1 do
		if faction:character_list():item_at(i):character_type(agent_type) then
			num_found = num_found + 1;
		end;
	end;

	return num_found;
end;


--	kills all generals/armies belonging to the supplied faction by name
function kill_all_armies_for_faction(faction_key)

	if not is_string(faction_key) then
		script_error("ERROR: kill_all_armies_for_faction() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;

	local cm = get_cm();
	
	if not cm:can_modify() then
		return;
	end;
	
	local modify_faction = cm:modify_faction(faction_key);
	
	if not modify_faction then
		script_error("ERROR: kill_all_armies_for_faction() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;
	
	local military_force_list = modify_faction:query_faction():military_force_list();
	local count = 0;
			
	for i = 0, military_force_list:num_items() - 1 do
		local mf = military_force_list:item_at(i);
		
		if mf:has_general() then
			cm:modify_character(mf:general_character():cqi()):kill_character(true);

			count = count + 1;
		end;
	end;
	
	if count == 0 then
		return;
	elseif count == 1 then
		out("### kill_all_armies_for_faction() just killed 1 force for faction " .. modify_faction .. " ###");
	else
		out("### kill_all_armies_for_faction() just killed " .. tostring(count) .. " forces for faction " .. modify_faction .. " ###");
	end;
end;


--	kills all spies/champions/dignitaries belonging to the supplied faction by name
function kill_all_agents_for_faction(faction_key)

	if not is_string(faction_key) then
		script_error("ERROR: kill_all_armies_for_faction() called but supplied faction key [" .. tostring(faction_key) .. "] is not a string");
		return false;
	end;

	local cm = get_cm();
	
	if not cm:can_modify() then
		return;
	end;
	
	local modify_faction = cm:modify_faction(faction_key);
	
	if not modify_faction then
		script_error("ERROR: kill_all_armies_for_faction() called but no faction with supplied key [" .. faction_key .. "] could be found");
		return false;
	end;

	
	local character_list = modify_faction:query_faction():character_list();
	local count = 0;
	
	for i = 0, character_list:num_items() - 1 do
		local current_char = character_list:item_at(i);
		
		if not current_char:character_type("general") then
			cm:modify_character(current_char):kill_character(true);
			count = count + 1;
		end;
	end;
	
	if count == 0 then
		return;
	elseif count == 1 then
		out("### kill_all_agents_for_faction() just killed " .. tostring(count) .. " agent for faction " .. faction_key .. " ###");
	else
		out("### kill_all_agents_for_faction() just killed " .. tostring(count) .. " agents for faction " .. faction_key .. " ###");
	end;
end;


--	Specify a faction.
--	returns a table of character cqi and faction names of characters that are both at war
--	with the specified faction and also trespassing on the specified faction's territory.
--	Access the "cqi" and "faction_name" of each trespasser-entry subtable.
function get_trespasser_list_for_faction(faction)
	if not is_query_faction(faction) then
		script_error("ERROR: get_trespasser_list_for_faction() called but supplied object [" .. tostring(faction) .. "] is not a faction");
		return false;
	end;

	local retval = {};
	local faction_name = faction:name();
	
	-- go through all factions. If the current faction is at war with the specified faction, go through the
	-- current faction's military force leaders. If the character is in the subject faction's territory, note
	-- that character's cqi and faction in the table to return.
	local faction_list = faction:query_model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		
		if faction:at_war_with(current_faction) then
			local military_force_list = current_faction:military_force_list();

			for j = 0, military_force_list:num_items() - 1 do
				local military_force = military_force_list:item_at(j);
				
				if military_force:has_general() then
					local char = military_force:general_character();
					
					if char:has_region() and char:region():owning_faction():name() == faction_name then
						local table_entry = {cqi = char:cqi(), faction_name = char:faction():name()};
						table.insert(retval, table_entry);
					end;
				end;
			end;		
		end;
	end;

	return retval;
end;


--	Takes a faction object and returns the number of units it contains. Optional mobile_only flag restricts
--	the result to only mobile forces (armies and navies, not garrisons) if true.
function number_of_units_in_faction(faction, mobile_only)
	if not is_query_faction(faction) then
		script_error("ERROR: Number_Of_Units_For_Faction() called but supplied object [" .. tostring(faction) .. "] is not a faction");
		return false;
	end;
	
	local military_force_list = faction:military_force_list();
	local num_units = 0;
	
	for i = 0, military_force_list:num_items() - 1 do
		local mf = military_force_list:item_at(i);
		
		if not mobile_only or (mobile_only and military_force_is_mobile(mf)) then
			num_units = num_units + mf:unit_list():num_items();
		end;
	end;
	
	return num_units;
end;



-- check if faction is alive belonging to a key specified subculture - checks for regions and military force
function faction_of_subculture_lives(subculture_key)
	if not is_string(subculture_key) then
		script_error("ERROR: faction_of_subculture_lives() called but supplied subculture key [" .. tostring(subculture_key) .. "] is not a string!");
		return false;
	end;

	local faction_list = cm:query_model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		
		if faction:subculture() == subculture_key then
			if faction_is_alive(faction) then
				return true;
			end;
		end;
	end;
	
	return false;
end;


function faction_is_alive(faction)
	return faction:has_capital_region() or faction:military_force_list():num_items() > 0;
end;



function faction_has_armies_in_enemy_territory(faction)
	local mf_list = faction:military_force_list();
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		if current_mf:has_general() and not current_mf:is_armed_citizenry() then
			local char = current_mf:general_character();
			if char:has_region() then			
				local region = char:region();
				if not region:is_abandoned() then
					local owning_faction = region:owning_faction();
					if not owning_faction:is_null_interface() and owning_faction:at_war_with(faction) then
						return char;
					end;
				end;
			end;
		end;
	end;
	
	return false;
end;


function faction_has_armies_in_region(faction, region)
	local mf_list = faction:military_force_list();
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		if current_mf:has_general() and not current_mf:is_armed_citizenry() then
			local char = current_mf:general_character();
			if char:has_region() and char:region() == region then
				return char;
			end;
		end;
	end;
	
	return false;
end;


function faction_has_nap_with_faction(faction_a, faction_b)
	local nap_list = faction_a:factions_non_aggression_pact_with();
	for i = 0, nap_list:num_items() - 1 do
		if nap_list:item_at(i) == faction_b then
			return true;
		end;
	end;
	return false;
end;


function faction_has_trade_agreement_with_faction(faction_a, faction_b)
	local trade_list = faction_a:factions_trading_with();
	for i = 0, trade_list:num_items() - 1 do
		if trade_list:item_at(i) == faction_b then
			return true;
		end;
	end;
	return false;
end;


function faction_is_horde(faction)
	return faction:is_horde() and faction:subculture() ~= "wh2_main_sc_def_dark_elves";
end;


function faction_owns_entirety_of_province(faction, province_name, include_vassals)
	return faction:holds_entire_province( province_name, include_vassals );
end;


function faction_num_owned_provinces(faction, partial_ownership, include_vassals)
	local province_count = 0

	for i=0, faction:faction_province_list():num_items() - 1 do
		local province_name = faction:faction_province_list():item_at(i):region_list():item_at(0):province_name();

		if partial_ownership or faction_owns_entirety_of_province( faction, province_name, include_vassals ) then
			province_count = province_count + 1;
		end;
	end;

	return province_count;
end;











----------------------------------------------------------------------------
--	Garrison
----------------------------------------------------------------------------

function garrison_has_building(garrison, building_key)
	for i = 0, garrison:region():slot_list():num_items() - 1 do
		local slot = garrison:region():slot_list():item_at(i);

		if slot:has_building() and slot:building():name() == building_key then
			return true;
		end;
	end;

	return false;
end;


function garrison_has_building_superchain(garrison, superchain_key)
	for i = 0, garrison:region():slot_list():num_items() - 1 do
		local slot = garrison:region():slot_list():item_at(i);
	
		if slot:has_building() and slot:building():superchain() == superchain_key then
			return true;
		end;	
	end;
	
	return false;
end;


function get_armed_citizenry_from_garrison(garrison, naval_force_only)
	-- return land force or naval force, depending on what the value of this flag is
	naval_force_only = not not naval_force_only;
	
	local mf_list = garrison:faction():military_force_list();
	
	for i = 0, mf_list:num_items() - 1 do
		local current_mf = mf_list:item_at(i);
		
		if current_mf:is_armed_citizenry() and current_mf:garrison_residence() == garrison then
			if naval_force_only then
				if current_mf:is_navy() then
					return current_mf;
				end;
			else
				if current_mf:is_army() then
					return current_mf;
				end;
			end;
		end;
	end;
	
	return false;
end;












----------------------------------------------------------------------------
--	Military Force
----------------------------------------------------------------------------

function military_force_average_casualties(military_force)
	local unit_list = military_force:unit_list();
	local num_units = unit_list:num_items();
	
	if num_units == 0 then
		return 0;
	end;
	
	local cumulative_health = 0;
	
	for i = 0, num_units - 1 do	
		cumulative_health = cumulative_health + unit_list:item_at(i):percentage_proportion_of_full_strength();
	end;
	
	return (cumulative_health / num_units);
end;


function num_mobile_forces_in_force_list(military_force_list)
	local count = 0;
	
	for i = 0, military_force_list:num_items() - 1 do
		if not military_force_list:item_at(i):is_armed_citizenry() then
			count = count + 1;
		end;
	end;
	
	return count;
end;


function military_force_is_mobile(military_force)
	return not military_force:is_armed_citizenry();
end;


-- Takes a military force and a unit class, and returns the percentage of them in the force as a fraction (i.e. 50% = 0.5)
function proportion_of_unit_class_in_military_force(military_force, unit_class)
	local unit_list = military_force:unit_list();
	
	local num_items = unit_list:num_items();
	
	if num_items == 0 then
		return 0;
	end;
	
	local num_found = 0;
	for i = 0, num_items - 1 do
		if unit_list:item_at(i):unit_class() == unit_class then
			num_found = num_found + 1;
		end;
	end;
	
	return (num_found / num_items);
end;

function military_force_contains_unit_key_from_list(military_force, unit_list)
	if not military_force or not is_query_military_force(military_force) then
		script_error("Null military force passed in.");
		return false;
	end;

	if military_force:is_null_interface() then
		script_error("Null military force passed in.");
		return false;
	end;

	for i = 1, #unit_list do
		if military_force_contains_unit_key( military_force, unit_list[i] ) then
			return true;
		end;
	end;
	return false;
end;

function military_force_contains_unit_key(military_force, unit_key)
	if not military_force or not is_query_military_force(military_force) then
		script_error("Null military force passed in.");
		return false;
	end;

	if military_force:is_null_interface() then
		script_error("Null military force passed in.");
		return false;
	end;
	
	if military_force:unit_list():has_unit( unit_key ) then
		return true;
	end;

	return false;
end;















----------------------------------------------------------------------------
--	Pending Battle
----------------------------------------------------------------------------

--	takes a pending_battle obj and a faction name
--	returns true if the faction was the primary attacker or defender in the pending battle, false otherwise
function faction_involved_in_battle(pb, faction_name)
	return faction_attacker_in_battle(pb, faction_name) or faction_defender_in_battle(pb, faction_name);
end;


--	takes a pending_battle obj and a faction name
--	returns true if the faction was the primary attacker in the pending battle, false otherwise
function faction_attacker_in_battle(pb, faction_name)
	return pb:has_attacker() and pb:attacker():faction():name() == faction_name;
end;


--	takes a pending_battle obj and a faction name
--	returns true if the faction was the primary defender in the pending battle, false otherwise
function faction_defender_in_battle(pb, faction_name)
	return pb:has_defender() and pb:defender():faction():name() == faction_name;
end;


--	takes a pending_battle obj
--	returns true if a human was primary attacker or defender in the pending battle
function player_involved_in_battle(pb)
	return player_attacker_in_battle(pb) or player_defender_in_battle(pb);
end;


--	takes a pending_battle obj
--	returns true if a human was the primary attacker in the pending battle
function player_attacker_in_battle(pb)
	return pb:has_attacker() and pb:attacker():faction():is_human();
end;


--	takes a pending_battle obj
--	returns true if a human was the primary defender in the pending battle
function player_defender_in_battle(pb)
	return pb:has_defender() and pb:defender():faction():is_human();
end;


--	takes a pending_battle obj and a region name
--	returns true if the pending battle is in the given region, false otherwise
function pending_battle_in_region(pb, region_name)
	if pb:has_defender() then
		local char = pb:defender();
		if char:has_region() then
			if char:region():name() == region_name then
				return true;
			else
				return false;
			end;
		end;
	end;
	
	if pb:has_attacker() then
		local char = pb:attacker();
		if char:has_region() and char:region():name() == region_name then
			return true;
		end
	end;
	
	return false;
end;


--	takes a pending_battle obj
--	returns the attacker culture string if it can be determined
function attacker_culture(pb)
	if pb:has_attacker() then
		return pb:attacker():faction():culture();
	end;
	
	return "";
end;


--	takes a pending_battle obj
--	returns the defender culture string if it can be determined
function defender_culture(pb)
	if pb:has_defender() then
		return pb:defender():faction():culture();
	end;
	
	return "";
end;


--	takes a pending_battle obj
--	returns the attacking faction name if it can be determined
function attacker_faction_name(pb)
	if pb:has_attacker() then
		return pb:attacker():faction():name();
	end;
	
	return "";
end;


--	takes a pending_battle obj
--	returns the defending faction name if it can be determined
function defender_faction_name(pb)
	if pb:has_defender() then
		return pb:defender():faction():name();
	end;
	
	return "";
end;


--	takes a pending_battle obj
--	returns the attacker subculture str if it can be determined
function attacker_subculture(pb)
	if pb:has_attacker() then
		return pb:attacker():faction():subculture();
	end;
	
	return "";
end;


--	takes a pending_battle obj
--	returns the defender subculture str if it can be determined
function defender_subculture(pb)
	if pb:has_defender() then
		return pb:defender():faction():subculture();
	end;
	
	return "";
end;


--	takes a character, a pending_battle object and a culture name
--	returns true if the character fought against the culture in the pending battle, false otherwise
function fought_culture(char, pb, culture_name)
	if char_is_attacker(char) and defender_culture(pb) == culture_name then
		return true;
	elseif char_is_defender(char) and attacker_culture(pb) == culture_name then
		return true;
	end
	
	return false;
end;



--	takes pending battle object, returns name of settlement battle is over if one exists, false otherwise
function pending_battle_at_settlement(pb)
	if not pb:has_contested_garrison() then
		return false;
	end;
	
	return pb:contested_garrison():region():name();
end;



-- returns true if any of the primary participants in the pending battle are a quest battle faction - this should be reliable, assuming the quest battle factions are being used properly
function is_pending_quest_battle(pb)
	return (pb:has_attacker() and pb:attacker():faction():is_quest_battle_faction()) or (pb:has_defender() and pb:defender():faction():is_quest_battle_faction());
end;



function pending_battle_victory(pb, query_attacker)
	local result_str = false;
	
	if query_attacker then
		result_str = pb:attacker_battle_result();
	else
		result_str = pb:defender_battle_result();
	end;
	
	return result_str == "close_victory" or result_str == "decisive_victory" or result_str == "heroic_victory" or result_str == "pyrrhic_victory";
end;


function pending_battle_attacker_victory(pb)
	return pending_battle_victory(pb, true);
end;


function pending_battle_defender_victory(pb)
	return pending_battle_victory(pb, true);
end;


function pending_battle_defeat(pb, query_attacker)
	local result_str = false;
	
	if query_attacker then
		result_str = pb:attacker_battle_result();
	else
		result_str = pb:defender_battle_result();
	end;
	
	return result_str == "close_defeat" or result_str == "decisive_defeat" or result_str == "crushing_defeat" or result_str == "valiant_defeat";
end;


function pending_battle_attacker_defeat(pb)
	return pending_battle_defeat(pb, true);
end;


function pending_battle_defender_defeat(pb)
	return pending_battle_defeat(pb, true);
end;












----------------------------------------------------------------------------
--	Region
----------------------------------------------------------------------------

function is_region_owned_by_faction(region_name, faction_name)
	if not is_string(region_name) then
		script_error("ERROR: is_region_owned_by_faction() called but supplied region name [" .. tostring(region_name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(faction_name) then
		script_error("ERROR: is_region_owned_by_faction() called but supplied faction name [" .. tostring(faction_name) .. "] is not a string");
		return false;
	end;

	local region = cm:query_model():world():region_manager():region_by_key(region_name);
	
	if not region then
		script_error("ERROR: is_region_owned_by_faction() called but couldn't find a region with supplied name [" .. tostring(region_name) .. "]");
		return false;
	end;
	
	return (region:owning_faction():name() == faction_name);
end;


-- Tests if any of the neighbour regions to the supplied one are different religion.
function region_has_neighbours_of_other_religion(region)
	local majority_religion = region:majority_religion();

	for i = 0, region:adjacent_region_list():num_items() - 1 do
		if majority_religion ~= region:adjacent_region_list():item_at(i):majority_religion() then
			return true;
		end;
	end;
	
	return false;
end;


-- returns the region and the proportion that has the highest proportion of the supplied religion for the supplied faction
function get_region_of_highest_religion_for_faction(faction, religion_key)
	local region_list = faction:region_list();
	
	local highest_religion_region = false;
	local highest_religion_amount = 0;
	
	for i = 0, region_list:num_items() - 1 do
		local current_region = region_list:item_at(i);
		local current_region_religion_amount = current_region:religion_proportion(religion_key);
		
		if current_region_religion_amount > highest_religion_amount then
			highest_religion_region = current_region;
			highest_religion_amount = current_region_religion_amount;
		end;
	end;

	return highest_religion_region, highest_religion_amount;
end;













----------------------------------------------------------------------------
--	Settlement
----------------------------------------------------------------------------

--	returns display or logical position of a settlement - for internal use, call
--	settlement_display_pos() or settlement_logical_pos() externally
function settlement_pos(settlement_name, display)
	if not is_string(settlement_name) then
		script_error("ERROR: settlement_pos() called but supplied name [" .. tostring(settlement_name) .. "] is not a string");
		return false;
	end;

	local cm = get_cm();
	
	local settlement = cm:query_model():world():region_manager():settlement_by_key(settlement_name);
	
	if not settlement then
		script_error("ERROR: settlement_pos() called but no settlement found with supplied name [" .. settlement_name .. "]");
		return false;
	end;
	
	if display then
		return settlement:display_position_x(), settlement:display_position_y();
	else
		return settlement:logical_position_x(), settlement:logical_position_y();
	end;
end;


function settlement_display_pos(settlement_name)
	return settlement_pos(settlement_name, true);
end;


function settlement_logical_pos(settlement_name)
	return settlement_pos(settlement_name, false);
end;





----------------------------------------------------------------------------
--	Diplomacy
----------------------------------------------------------------------------

function faction_proposer_in_deal(deal, faction_key)

	if not is_query_diplomacy_negotiated_deal(deal) and not is_query_diplomacy_deal(deal) then
		script_error("Expected deal or negotiated_deal, got " .. tostring(deal));
	end;

	local faction_cqi = cm:query_faction(faction_key):command_queue_index();

	for i=0, deal:proposers():num_items() - 1 do
		local participants = deal:proposers():item_at(i);

		if participants:primary_faction():command_queue_index() == faction_cqi then
			return true;
		end;

		for j=0, participants:other_factions():num_items() - 1 do
			if participants:other_factions():item_at(j):command_queue_index() == faction_cqi then
				return true;
			end;
		end;
	end;

	return false;
end;

function faction_recipient_in_deal(deal, faction_key)
	
	if not is_query_diplomacy_negotiated_deal(deal) and not is_query_diplomacy_deal(deal) then
		script_error("Expected deal or negotiated_deal, got " .. tostring(deal));
	end;

	local faction_cqi = cm:query_faction(faction_key):command_queue_index();

	for i=0, deal:recipients():num_items() - 1 do
		local participants = deal:recipients():item_at(i);

		if participants:primary_faction():command_queue_index() == faction_cqi then
			return true;
		end;

		for j=0, participants:other_factions():num_items() - 1 do
			if participants:other_factions():item_at(j):command_queue_index() == faction_cqi then
				return true;
			end;
		end;
	end;

	return false;
end;

function player_proposer_in_deal(deal)
	if not is_query_diplomacy_negotiated_deal(deal) and not is_query_diplomacy_deal(deal) then
		script_error("Expected deal or negotiated_deal, got " .. tostring(deal));
	end;

	for i=0, deal:proposers():num_items() - 1 do
		local participants = deal:proposers():item_at(i);

		if participants:primary_faction():is_human() then
			return true;
		end;

		for j=0, participants:other_factions():num_items() - 1 do
			if participants:other_factions():item_at(j):is_human() then
				return true;
			end;
		end;
	end;

	return false;
end;

function player_recipient_in_deal(deal)

	if not is_query_diplomacy_negotiated_deal(deal) and not is_query_diplomacy_deal(deal) then
		script_error("Expected deal or negotiated_deal, got " .. tostring(deal));
	end;

	for i=0, deal:recipients():num_items() - 1 do
		local participants = deal:recipients():item_at(i);

		if participants:primary_faction():is_human() then
			return true;
		end;

		for j=0, participants:other_factions():num_items() - 1 do
			if participants:other_factions():item_at(j):is_human() then
				return true;
			end;
		end;
	end;

	return false;
end;

function faction_involved_in_deal(deal, faction_key)

	return faction_proposer_in_deal(deal, faction_key) or faction_recipient_in_deal(deal, faction_key);
end;


function player_involved_in_deal(deal)

	return player_proposer_in_deal(deal) or player_recipient_in_deal(deal);
end;


function faction_signed_specific_component_in_deal(deal, faction_key, treaty_component_key)
	
	if not is_query_diplomacy_negotiated_deal(deal) and not is_query_diplomacy_deal(deal) then
		script_error("Expected deal or negotiated_deal, got " .. tostring(deal));
	end;

	local faction_cqi = cm:query_faction(faction_key):command_queue_index();

	for i=0, deal:components():num_items() - 1 do
		local component = deal:components():item_at(i);

		if component:treaty_component_key() == treaty_component_key then
			if component:proposer():command_queue_index() == faction_cqi or component:recipient():command_queue_index() == faction_cqi then
				return true;
			end;
		end;
	end;

	return false;
end;

function factions_signed_specific_component_in_deal(deal, faction_1_key, faction_2_key, treaty_component_key)

	if not is_query_diplomacy_negotiated_deal(deal) and not is_query_diplomacy_deal(deal) then
		script_error("Expected deal or negotiated_deal, got " .. tostring(deal));
	end;

	local faction_1_cqi = cm:query_faction(faction_1_key):command_queue_index();
	local faction_2_cqi = cm:query_faction(faction_2_key):command_queue_index();

	for i=0, deal:components():num_items() - 1 do
		local component = deal:components():item_at(i);

		if component:treaty_component_key() == treaty_component_key then
			if component:proposer():command_queue_index() == faction_1_cqi and component:recipient():command_queue_index() == faction_2_cqi then
				return true;
			end;

			if component:proposer():command_queue_index() == faction_2_cqi and component:recipient():command_queue_index() == faction_1_cqi then
				return true;
			end;
		end;
	end;

	return false;
end;

function faction_signed_component_in_negotiated_deals(deals, faction_key, treaty_component_key)

	if not is_query_diplomacy_negotiated_deals(deals) then
		script_error("Expected negotiated_deals, got " .. tostring(deal));
	end;

	for i = 0, deals:deals():num_items() - 1 do
		if faction_signed_specific_component_in_deal(deals:deals():item_at(i), faction_key, treaty_component_key) then
			return true;
		end;
	end;

	return false;
end;

function factions_signed_component_in_negotiated_deals(deals, faction_1_key, faction_2_key, treaty_component_key)
	
	if not is_query_diplomacy_negotiated_deals(deals) then
		script_error("Expected negotiated_deals, got " .. tostring(deal));
	end;

	for i = 0, deals:deals():num_items() - 1 do
		if factions_signed_specific_component_in_deal(deals:deals():item_at(i), faction_1_key, faction_2_key, treaty_component_key) then
			return true;
		end;
	end;

	return false;
end;