faction_council.scripted_issue_list = {
	["issue_key"] = 
	{
		weighting = 90,	
        is_issue_valid = function(modify_faction, modify_model) return true; end,	
        office_priorities = {	
            fire = 1,
            water = 1,
            earth = 1,
            metal = 1,
            wood = 1
		},
		mission_keys = {
			fire = "3k_main_council_fire_character_unassigned_unique_item_earth_give_ancillary_to_earth_general_mission",
			water = "3k_main_council_water_character_unassigned_unique_item_earth_give_ancillary_to_earth_general_mission",
			earth = "3k_main_council_earth_character_unassigned_unique_item_earth_give_ancillary_to_earth_general_mission",
			metal = "3k_main_council_metal_character_unassigned_unique_item_earth_give_ancillary_to_earth_general_mission",
			wood = "3k_main_council_wood_character_unassigned_unique_item_earth_give_ancillary_to_earth_general_mission"
		},
		mission_constructor = function(mm, modify_faction, modify_model) 
				mm:add_new_objective( "ENGAGE_FORCE" );

				mm:add_condition( "faction " .. "3k_main_faction_cao_cao" );

				mm:add_payload( "effect_bundle{bundle_key 3k_main_historical_mission_payload_01;turns 5;}" );
			end;
	}
}