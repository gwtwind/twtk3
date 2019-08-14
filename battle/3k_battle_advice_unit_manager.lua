---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Battle Advice Unit Manager
----- Author: 		Leif Walter
----- Description: 	Three Kingdoms auxiliary system to get information about units in battles, such as
-----               if a unit is routing, fatigued, or if a unit is charging etc.
-----           
-----               Largely based on utility functions defined in:
-----               \\common\EmpireBattle\Source\BattleScript\BattleEditorScriptInterface.cpp
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- Core table
unit_manager = {
    script_unit_set = scriptunits_from_army("player_sunits", bm:get_player_army())
};

function unit_manager:getScriptUnitController(unit) 

    -- for index in ipairs(self.script_unit_set)
    -- do
    --     if self.script_unit_set[index].unit == unit then 
    --         return self.script_unit_set[index];
    --     end
    -- end

    if (self.script_unit_set == nil) then 
        self.script_unit_set = scriptunits_from_army("player_sunits", bm:get_player_army());
    end
    
	for i = 1, self.script_unit_set:count() do
		local current_sunit = self.script_unit_set:item(i);
        if current_sunit.unit == unit then 
			return current_sunit;
		end
	end

    script_error("[ERROR] >>> Could not find script unit for unit.");
    return nil;
end

function unit_manager:get_ranged_unit() 

    local player_units = unit_manager:getAllUnits();
    local ranged_indicator = "unit_water";

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local unit_key = current_unit:type();
        
        if string.find(unit_key, ranged_indicator) then
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:get_melee_unit() 

    local player_units = unit_manager:getAllUnits();
    local cav_indicator_metal = "unit_metal";
    local cav_indicator_wood = "unit_wood";

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local unit_key = current_unit:type();
        
        if string.find(unit_key, cav_indicator_metal) or string.find(unit_key, cav_indicator_wood) then
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:get_melee_cavalry_unit() 

    local player_units = unit_manager:getAllUnits();
    local cav_indicator_earth = "unit_earth";
    local cav_indicator_fire = "unit_fire";

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local unit_key = current_unit:type();
        
        if string.find(unit_key, cav_indicator_earth) or string.find(unit_key, cav_indicator_fire) then
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:unit_carrying_siege_equipment() 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local unit_id = current_unit:unique_ui_id();
        local context_id = "CcoBattleUnit" .. unit_id;
        local carrying_equipment = effect.get_context_bool_value(context_id, "VehicleContext");
        if carrying_equipment then 
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:get_heavy_weight_unit() 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local armour_key = unit_manager:get_armour_key(current_unit);
        
        local heavy_armour_keys = {"3k_main_unit_iron_full", "3k_main_unit_iron_lamellar", "3k_main_unit_iron_partial"};

		for index in ipairs(heavy_armour_keys)
		do
			if (heavy_armour_keys[index] == armour_key) then 
				return current_unit;
			end 
		end 
    end

    return nil;
end

function unit_manager:get_medium_weight_unit() 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local armour_key = unit_manager:get_armour_key(current_unit);
        
        local medium_armour_keys = {"3k_main_unit_leather_heavy", "3k_main_unit_leather_partial", "3k_main_unit_leather_reinforced"};

		for index in ipairs(medium_armour_keys)
		do
            if (medium_armour_keys[index] == armour_key) then 
				return current_unit;
			end 
		end 
    end

    return nil;
end

function unit_manager:get_light_weight_unit() 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local armour_key = unit_manager:get_armour_key(current_unit);
        
        local light_armour_keys = {"3k_main_unit_tunic"};

		for index in ipairs(light_armour_keys)
		do
			if (light_armour_keys[index] == armour_key) then 
				return current_unit;
			end 
		end 
    end

    return nil;
end

function unit_manager:get_armour_key(unit) 

    local object_id_no = unit:unique_ui_id();
    local object_id = "CcoBattleUnit" .. object_id_no;
    local armour_key = effect.get_context_string_value(object_id, "UnitRecordContext.ArmourRecordContext.Key");
    return armour_key;

end

function unit_manager:get_minimum_distance_to_capture_point() 

    local player_units = unit_manager:getAllUnits();

    local x,y,z,w = effect.get_context_vector4_value("CcoBattleRoot", "VictoryCapturePointContext.Position");
    local capture_point_location = battle_vector(x,y,z);
    
    local minimum_distance = 99999;

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local current_unit_position = current_unit:position();
        local current_distance = metric_distance(capture_point_location, current_unit_position);

        if (current_distance < minimum_distance) then
            minimum_distance = current_distance;
        end

    end

    battleAdviceLogger:log("[INFO] unit_manager:get_minimum_distance_to_capture_point(): Returning minimum distance = " .. minimum_distance);
    return minimum_distance;

end





---------------------------------------------------------------------------------------------------------
--- UNIT TYPES
---------------------------------------------------------------------------------------------------------
--- COMMANDER
function unit_manager:getCommanderInAlliance()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:unit_class() == "com") then
            battleAdviceLogger:log("[INFO] Alliance commander unit found.");
            return current_unit;
        end
    end

    return nil;
end

function unit_manager:getDuelist()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:can_duel() == true) then
            battleAdviceLogger:log("[INFO] Duelist unit found.");
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:getPendingChallengedDuelist()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local is_pending_duelist,is_challenged = current_unit:is_pending_duelist();

        if (is_pending_duelist == true and is_challenged == true) then
            battleAdviceLogger:log("[INFO] Pending challenged duelist unit found.");
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:getActiveDuelist()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_dueling() == true) then
            battleAdviceLogger:log("[INFO] Active duelist unit found.");
            return current_unit;
        end
    end

    return nil;

end


--- CAVALRY
function unit_manager:getCavalryUnit()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_cavalry() == true and not (current_unit:unit_class() == "com")) then
            
            return current_unit;
        end
    end

    return nil;
end

--- INFANTRY
function unit_manager:getInfantryUnit()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_infantry() == true and current_unit:starting_ammo() == 0) then
            
            return current_unit;
        end
    end

    return mil;
end

--- RANGED
function unit_manager:getInfantryUnitWithAmmo()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_infantry() == true and current_unit:starting_ammo() > 5) then
            
            return current_unit;
        end
    end

    return nil;
end
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------
--- UNIT ABILITIES
---------------------------------------------------------------------------------------------------------
--- HAS SPECIAL ABILITIES
function unit_manager:getUnitWithSpecialAbility()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:has_any_special_ability_with_any_ai_usage_flags() == 1) then
            battleAdviceLogger:log("[INFO] Unit with special ability with ai usage flag found.");
            return current_unit;
        end
    end

    return nil;
end

function unit_manager:getUnitWithAbility(ability_key) 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:can_perform_special_ability(ability_key) == true) then
            battleAdviceLogger:log("[INFO] Unit with special ability found.");
            return current_unit;
        end
    end

    return nil;

end 

function unit_manager:doesSomeUnitHaveAbility(ability_key) 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:can_perform_special_ability(ability_key) == true) then
            battleAdviceLogger:log("[INFO] Unit with special ability found.");
            return true;
        end
    end

    return nil;

end



---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------
--- MORALE STATES 
---------------------------------------------------------------------------------------------------------
--- WAVERING
function unit_manager:getWaveringUnit()

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_wavering() == true) then
            battleAdviceLogger:log("[INFO] unit_manager:getWaveringUnit(): Returning wavering unit.");
            return current_unit;
        else
            battleAdviceLogger:log("[INFO] unit_manager:getWaveringUnit(): No wavering unit found.");
        end
    end

    return nil;
end

--- ROUTING
function unit_manager:getRoutingUnit()

    local player_units = unit_manager:getAllUnits();

    battleAdviceLogger:log("[INFO] unit_manager:getRoutingUnit(): Checking for routing unit.");

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_routing() == true) then
            battleAdviceLogger:log("[INFO] unit_manager:getRoutingUnit(): Routing unit found.");
            return current_unit;
        else 
            battleAdviceLogger:log("[INFO] unit_manager:getRoutingUnit(): No routing unit found.");
        end
    end

    return nil;
end

--- FATIGUE
function unit_manager:getUnitWithAnyFatigueState() 
    local valid_fatigue_states = {"threshold_very_tired", "threshold_tired", "threshold_winded", "threshold_exhausted"};

    for index in ipairs(valid_fatigue_states)
    do
        local valid_unit = unit_manager:getUnitWithFatigueState(valid_fatigue_states[index]);
        if valid_unit then 
            return valid_unit;
        end
    end

    return nil;

end

function unit_manager:getUnitWithFatigueState(fatigue_state)

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        local fatigue_string = current_unit:fatigue_state();

        if (fatigue_string == fatigue_state) then
            return current_unit;
        end
    end

    return nil;
end

function unit_manager:get_unit_not_routing()

    local player_units = unit_manager:getAllUnits();

    battleAdviceLogger:log("[INFO] unit_manager:get_unit_not_routing(): Checking for first unit not routing.");

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_routing() == false) then
            battleAdviceLogger:log("[INFO] unit_manager:get_unit_not_routing(): Routing unit found.");
            return current_unit;
        else 
            battleAdviceLogger:log("[INFO] unit_manager:get_unit_not_routing(): No routing unit found.");
        end
    end

    return nil;

end

--- HITPOINTS
function unit_manager:getUnitWithHitpointPercentageLeft(hitpoint_percentage) 
    
    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        local hitpoint_unary = current_unit:unary_hitpoints();

        if (hitpoint_percentage > hitpoint_unary) then
            battleAdviceLogger:log("[INFO] unit_manager:getUnitWithHitpointPercentageLeft(hitpoint_percentage) : Unit found with HP% less than " .. hitpoint_percentage);
            return current_unit;
        end
    end
    return nil;
end 

function unit_manager:getInfantryWithHitpointPercentageLeft(hitpoint_percentage) 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_infantry()) then 
            local hitpoint_unary = current_unit:unary_hitpoints();

            if (hitpoint_percentage > hitpoint_unary) then
                battleAdviceLogger:log("[INFO] unit_manager:getUnitWithHitpointPercentageLeft(hitpoint_percentage) : Unit found with HP% less than " .. hitpoint_percentage);
                return current_unit;
            end 
        end

    end
    return nil;

end 

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

function unit_manager:getUnitWithCEORarity(rarity_value)

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);
        local unit_id = current_unit:unique_ui_id();
        local context_id = "CcoBattleUnit" .. unit_id;

        if (effect.get_context_numeric_value(context_id, "SetupUnitContext.CeoList.MaxValue(RarityValue)") == rarity_value) then 
            
            battleAdviceLogger:log("[INFO] unit_manager:getUnitWithCEORarity(rarity_value) : Unit found with CEO rarity of at least " .. rarity_value .. " - Unit ID: " .. unit_id);
            return current_unit;
        
        end

    end
    return nil;

end


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--- CHARGING
function unit_manager:getChargingUnit() 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_charging() == 1) then
            battleAdviceLogger:log("[INFO] Charging unit found.");
            return current_unit;
        end
    end

    return nil;

end 

function unit_manager:getChargedUnit() 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_being_charged() == 1) then
            battleAdviceLogger:log("[INFO] Unit that is charged found.");
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:getFlankingUnit() 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_flanking() == 1) then
            battleAdviceLogger:log("[INFO] Unit that is flanking found.");
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:getFlankedUnit() 

    local player_units = unit_manager:getAllUnits();

    for i = 1, player_units:count() do
        local current_unit = player_units:item(i);

        if (current_unit:is_being_flanked() == 1) then
            battleAdviceLogger:log("[INFO] Unit that is being flanked found.");
            return current_unit;
        end
    end

    return nil;

end

function unit_manager:getAllUnits()
    local army = bm:get_player_army();
    local units = army:units();
    return units;
end