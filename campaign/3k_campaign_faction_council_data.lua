-- Issue Data is broken down as - issue + priority + mission keys (one per character element who could be in the post).
faction_council.issue_list = {
    ["character_low_satisfaction"] = {		
        weighting = 80,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.5,
            earth = 0.8,
            metal = 0.5,
            wood = 0.5
        }
	},		
	--[[  Commented out as we cannot support this issue type, hopefully it'll come back one day
    ["character_unassigned_unique_item"] = {		
        weighting = 100,	
        is_issue_valid = 
			function(modify_faction, modify_model)
				local is_unique_ceo = function(ceo_key) 
					return not string.match(ceo_key, "common") and not string.match(ceo_key, "exceptional") and not string.match(ceo_key, "refined");
				end;

				for i=0, modify_faction:query_faction():ceo_management():all_ceos():num_items() - 1 do
					local ceo = modify_faction:query_faction():ceo_management():all_ceos():item_at(i);
					local ceo_key = ceo:ceo_data_key();
					
                    if not ceo:is_equipped_in_slot() and is_unique_ceo(ceo_key) then
                        return true;
                    end;
                end;
                return false;
            end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.5,
            earth = 0.5,
            metal = 1,
            wood = 0.5
        }
	},	
	]]--	
    ["corruption_high"] = {		
        weighting = 80,	
        is_issue_valid = 
            function(modify_faction, modify_model)
                if not modify_faction:query_faction():faction_province_list():is_empty() then 
                    return modify_faction:query_faction():faction_province_list():item_at(0):tax_administration_cost() > 50;
                end;
            end,	
        office_priorities = {	
            fire = 0.2,
            water = 0.5,
            earth = 1,
            metal = 0.2,
            wood = 0.5
        }	
    },		
    ["corruption_new"] = {		
        weighting = 100,	
        is_issue_valid = 
            function(modify_faction, modify_model)
                if not modify_faction:query_faction():faction_province_list():is_empty() then 
                    return modify_faction:query_faction():faction_province_list():item_at(0):tax_administration_cost() > 0;
                end;
            end,	
        office_priorities = {	
            fire = 0.8,
            water = 0.5,
            earth = 1,
            metal = 1,
            wood = 0.5
        }
    },		
    ["diplomacy_at_peace"] = {		
        weighting = 50,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.5,
            earth = 0.8,
            metal = 0.5,
            wood = 1
        }
    },		
    ["diplomacy_enemies_x1"] = {		
        weighting = 30,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.5,
            earth = 0.5,
            metal = 0.5,
            wood = 0.2
        }	
    },		
    ["diplomacy_enemies_x2"] = {		
        weighting = 60,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.5,
            earth = 0.5,
            metal = 0.5,
            wood = 0.5
        }	
    },		
    ["diplomacy_enemies_x3"] = {		
        weighting = 80,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.2,
            earth = 0.5,
            metal = 0.2,
            wood = 0.8
        }
    },		
    ["diplomacy_enemy_army_trespassing"] = {		
        weighting = 60,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.5,
            earth = 0.8,
            metal = 0.5,
            wood = 0.5
        }
    },		
    ["diplomacy_friendly_faction_not_allies"] = {		
        weighting = 60,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.2,
            water = 1,
            earth = 0.5,
            metal = 0.8,
            wood = 0.8
        }
    },		
    ["diplomacy_has_free_trade_slot"] = {		
        weighting = 40,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.2,
            water = 1,
            earth = 0.5,
            metal = 1,
            wood = 0.5
        }
    },		
    ["diplomacy_neutral_army_trespassing"] = {		
        weighting = 40,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.5,
            earth = 0.8,
            metal = 0.5,
            wood = 0.2
        }
    },		
    ["diplomacy_vassal_high_opinion"] = {		
        weighting = 50,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.8,
            water = 0.8,
            earth = 1,
            metal = 0.2,
            wood = 0.2
        }
    },		
    ["economy_bankrupt"] = {		
        weighting = 100,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 1,
            earth = 1,
            metal = 1,
            wood = 1
        }
    },		
    ["economy_income_high"] = {		
        weighting = 80,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.8,
            water = 0.5,
            earth = 0.8,
            metal = 1,
            wood = 0.5
        }
    },		
    ["economy_income_low"] = {		
        weighting = 80,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 1,
            earth = 0.5,
            metal = 1,
            wood = 1
        }
    },		
    ["economy_income_medium"] = {		
        weighting = 50,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 1,
            earth = 0.5,
            metal = 1,
            wood = 1
        }
    },		
    ["faction_caps_army_cap_free"] = {		
        weighting = 40,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.5,
            earth = 0.5,
            metal = 0.5,
            wood = 0.5
        }
    },		
    ["faction_caps_governor_cap_free"] = {		
        weighting = 50,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.5,
            earth = 1,
            metal = 0.5,
            wood = 0.5
        }	
    },		
    ["faction_caps_spy_cap_free"] = {		
        weighting = 60,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 1,
            earth = 0.5,
            metal = 0.5,
            wood = 0.5
        }
	},		
	--[[ Commented out as we cannot support this issue type, hopefully it'll come back one day
    ["faction_does_not_own_capital"] = {		
        weighting = 95,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.8,
            water = 0.5,
            earth = 1,
            metal = 0.6,
            wood = 0.2
        }
	},		
	]]--
    ["faction_rebellion"] = {		
        weighting = 90,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.8,
            water = 0.2,
            earth = 1,
            metal = 0.5,
            wood = 0.2
        }
    },		
    ["food_low_food_in_faction"] = {		
        weighting = 70,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.8,
            water = 0.2,
            earth = 0.5,
            metal = 0.5,
            wood = 1
        }
    },		
    ["food_low_food_in_region"] = {		
        weighting = 90,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.5,
            earth = 0.5,
            metal = 0.5,
            wood = 1
        }
    },		
    ["military_need_units"] = {		
        weighting = 40,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.5,
            earth = 4,
            metal = 0.5,
            wood = 0.5
        }
    },		
    ["neighbouring_region_abandoned"] = {		
        weighting = 40,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.2,
            water = 0.5,
            earth = 0.5,
            metal = 0.2,
            wood = 1
        }
    },		
    ["offices_free_court_noble_slots"] = {		
        weighting = 50,	
		is_issue_valid = function(modify_faction, modify_model)-- Check if there are recuitable characters.
			return modify_faction:query_faction():number_of_characters_in_recruitment_pool() > 0;
		end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.8,
            earth = 1,
            metal = 0.5,
            wood = 0.2
        }
    },		
    ["offices_free_general_slots"] = {		
        weighting = 50,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 0.5,
            earth = 0.5,
            metal = 0.5,
            wood = 0.2
        }	
    },		
    ["offices_free_ministerial_positions"] = {		
        weighting = 90,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 1,
            water = 1,
            earth = 1,
            metal = 1,
            wood = 1
        }	
    },		
    ["offices_idle_court_nobles"] = {		
        weighting = 70,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.8,
            earth = 1,
            metal = 0.3,
            wood = 0.2
        }
    },		
    ["population_capacity_reached"] = {		
        weighting = 80,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.5,
            earth = 1,
            metal = 1,
            wood = 0.5
        }
    },		
    ["population_low_in_province"] = {		
        weighting = 50,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.8,
            earth = 0.5,
            metal = 1,
            wood = 1
        }
    },		
    ["provinces_free_building_slot"] = {		
        weighting = 60,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.5,
            water = 0.5,
            earth = 0.5,
            metal = 1,
            wood = 0.5
        }
    },		
    ["public_order_decreasing_in_province"] = {		
        weighting = 40,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.8,
            water = 0.2,
            earth = 1,
            metal = 0.5,
            wood = 1
        }	
    },		
    ["public_order_negative_in_province"] = {		
        weighting = 80,	
        is_issue_valid = function(modify_faction, modify_model)return true; end,	
        office_priorities = {	
            fire = 0.8,
            water = 0.2,
            earth = 1,
            metal = 0.5,
            wood = 0.8
        }
    }		    
};