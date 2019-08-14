---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Battle Advice Phases
----- Author: 		Leif Walter
----- Description: 	Three Kingdoms auxiliary system to help organise battle advice messages into phases.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- Core table
advicePhases = {};

advicePhases.use_advice_history = false;

---------------------------------------------------------------------------------------------------------
-- [[ Initialisation ]]
---------------------------------------------------------------------------------------------------------
function advicePhases:initialise(use_advice_history) 

    self.use_advice_history = use_advice_history;

    self:setupPreBasicAdvicePhase();
    self:setupBasicAdvicePhase();
    self:setupIntermediateAdvicePhase();

end

---------------------------------------------------------------------------------------------------------
-- [[ Helper functions ]]
---------------------------------------------------------------------------------------------------------

function advicePhases:haveBasicAdviceBeenTriggered() 

    if (effect.get_advice_thread_score("3k_battle_advice_deployment_1") < 1) then 
        return false;
    end 

    if (effect.get_advice_thread_score("3k_battle_advice_deployment_2") < 1) then 
        return false;
    end 

    if (effect.get_advice_thread_score("3k_battle_advice_deployment_3") < 1) then 
        return false;
    end 

    if (effect.get_advice_thread_score("3k_battle_advice_commanders_1") < 1) then 
        return false;
    end 

    if (effect.get_advice_thread_score("3k_battle_advice_retinues_1") < 1) then 
        return false;
    end 

    if (effect.get_advice_thread_score("3k_battle_advice_retinues_2") < 1) then 
        return false;
    end 

    return true;

end

function advicePhases:setAllAdviceTriggered(advice_phase)
    for key in ipairs(advice_phase) 
    do 
        advice_phase[key].has_played = true;
    end
end

function advicePhases:advicePhaseComplete(advice_phase)
    for key in ipairs(advice_phase)
    do
        if advice_phase[key].has_played == false then return false;
        end
    end
    return true;
end

function advicePhases:setAdviceTriggered(advice_key, trigger_status) 
    phase = advicePhases:getAdvicePhaseForAdvice(advice_key);
    if (phase == nil) then 
        script_error("[ERROR] advicePhases:setAdviceTriggered(advice_key, trigger_status) could not find phase for key: " .. advice_key);
        return false;
    end
    for index in ipairs(phase) 
    do
        if (phase[index].key == advice_key) then 
            phase[index].has_played = trigger_status;
            battleAdviceLogger:log("[INFO] 3k_battle_advice_phases.lua - advicePhases:setAdviceTriggered(key, trigger_status): Setting " .. advice_key .. " to " .. string.format(tostring(trigger_status)))
        end
    end

end

function advicePhases:getAdvicePhaseForAdvice(advice_key)
    for index in ipairs(advicePhase_preBasic)
    do
        if advicePhase_preBasic[index].key == advice_key then return advicePhase_preBasic end
    end
    for index in ipairs(advicePhase_basic)
    do
        if advicePhase_basic[index].key == advice_key then return advicePhase_basic end
    end
    for index in ipairs(advicePhase_intermediate)
    do
        if advicePhase_intermediate[index].key == advice_key then return advicePhase_intermediate end
    end
    battleAdviceLogger:log("[ERROR] 3k_battle_advice_phases.lua - advicePhases:getAdvicePhaseForAdvice(advice_key): Could not identify advice phase for key: " .. advice_key);
    return nil;
end

function advicePhases:hasAdviceTriggered(advice_key) 
    advicePhase = advicePhases:getAdvicePhaseForAdvice(advice_key);
    if (advicePhase == nil) then return false end
    for index in ipairs(advicePhase)
    do 
        if advicePhase[index].key == advice_key then return advicePhase[index].has_played;
        end
    end
    return false;
end

---------------------------------------------------------------------------------------------------------
-- [[ Setting up advice phases ]]
---------------------------------------------------------------------------------------------------------
function advicePhases:setupPreBasicAdvicePhase() 

    advicePhase_preBasic = {}
    advicePhase_preBasic[1] = { "key", "has_played"};
    advicePhase_preBasic[1].key = "3k_battle_advice_ambush_attack_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_ambush_attack_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[1].has_played = true;
    else
        advicePhase_preBasic[1].has_played = false;
    end


    advicePhase_preBasic[2] = { "key", "has_played"};
    advicePhase_preBasic[2].key = "3k_battle_advice_ambush_defence_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_ambush_defence_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[2].has_played = true;
    else
        advicePhase_preBasic[2].has_played = false;
    end


    advicePhase_preBasic[3] = { "key", "has_played"};
    advicePhase_preBasic[3].key = "3k_battle_advice_capture_point_attack_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_capture_point_attack_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[3].has_played = true;
    else
        advicePhase_preBasic[3].has_played = false;
    end


    advicePhase_preBasic[4] = { "key", "has_played"};
    advicePhase_preBasic[4].key = "3k_battle_advice_capture_point_attack_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_capture_point_attack_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[4].has_played = true;
    else
        advicePhase_preBasic[4].has_played = false;
    end


    advicePhase_preBasic[5] = { "key", "has_played"};
    advicePhase_preBasic[5].key = "3k_battle_advice_capture_point_defend_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_capture_point_defend_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[5].has_played = true;
    else
        advicePhase_preBasic[5].has_played = false;
    end


    advicePhase_preBasic[6] = { "key", "has_played"};
    advicePhase_preBasic[6].key = "3k_battle_advice_attacking_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_attacking_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[6].has_played = true;
    else
        advicePhase_preBasic[6].has_played = false;
    end


    advicePhase_preBasic[7] = { "key", "has_played"};
    advicePhase_preBasic[7].key = "3k_battle_advice_defending_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_defending_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[7].has_played = true;
    else
        advicePhase_preBasic[7].has_played = false;
    end


    advicePhase_preBasic[8] = { "key", "has_played"};
    advicePhase_preBasic[8].key = "3k_battle_advice_deployment_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[8].has_played = true;
    else
        advicePhase_preBasic[8].has_played = false;
    end


    advicePhase_preBasic[9] = { "key", "has_played"};
    advicePhase_preBasic[9].key = "3k_battle_advice_deployment_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[9].has_played = true;
    else
        advicePhase_preBasic[9].has_played = false;
    end


    advicePhase_preBasic[10] = { "key", "has_played"};
    advicePhase_preBasic[10].key = "3k_battle_advice_deployment_3";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_3");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[10].has_played = true;
    else
        advicePhase_preBasic[10].has_played = false;
    end


    advicePhase_preBasic[11] = { "key", "has_played"};
    advicePhase_preBasic[11].key = "3k_battle_advice_deployment_4";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_4");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[11].has_played = true;
    else
        advicePhase_preBasic[11].has_played = false;
    end


    advicePhase_preBasic[12] = { "key", "has_played"};
    advicePhase_preBasic[12].key = "3k_battle_advice_deployment_end_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_end_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[12].has_played = true;
    else
        advicePhase_preBasic[12].has_played = false;
    end


    advicePhase_preBasic[13] = { "key", "has_played"};
    advicePhase_preBasic[13].key = "3k_battle_advice_deployment_siege_attack_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_attack_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[13].has_played = true;
    else
        advicePhase_preBasic[13].has_played = false;
    end


    advicePhase_preBasic[14] = { "key", "has_played"};
    advicePhase_preBasic[14].key = "3k_battle_advice_deployment_siege_defence_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_defence_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[14].has_played = true;
    else
        advicePhase_preBasic[14].has_played = false;
    end


    advicePhase_preBasic[15] = { "key", "has_played"};
    advicePhase_preBasic[15].key = "3k_battle_advice_flanking_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_flanking_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[15].has_played = true;
    else
        advicePhase_preBasic[15].has_played = false;
    end


    advicePhase_preBasic[16] = { "key", "has_played"};
    advicePhase_preBasic[16].key = "3k_battle_advice_flanking_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_flanking_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[16].has_played = true;
    else
        advicePhase_preBasic[16].has_played = false;
    end


    advicePhase_preBasic[17] = { "key", "has_played"};
    advicePhase_preBasic[17].key = "3k_battle_advice_commanders_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[17].has_played = true;
    else
        advicePhase_preBasic[17].has_played = false;
    end


    advicePhase_preBasic[18] = { "key", "has_played"};
    advicePhase_preBasic[18].key = "3k_battle_advice_deployment_units_3";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_units_3");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[18].has_played = true;
    else
        advicePhase_preBasic[18].has_played = false;
    end


    advicePhase_preBasic[19] = { "key", "has_played"};
    advicePhase_preBasic[19].key = "3k_battle_advice_morale_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_morale_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[19].has_played = true;
    else
        advicePhase_preBasic[19].has_played = false;
    end


    advicePhase_preBasic[20] = { "key", "has_played"};
    advicePhase_preBasic[20].key = "3k_battle_advice_reinforcements_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_reinforcements_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[20].has_played = true;
    else
        advicePhase_preBasic[20].has_played = false;
    end


    advicePhase_preBasic[21] = { "key", "has_played"};
    advicePhase_preBasic[21].key = "3k_battle_advice_retinues_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_retinues_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[21].has_played = true;
    else
        advicePhase_preBasic[21].has_played = false;
    end


    advicePhase_preBasic[22] = { "key", "has_played"};
    advicePhase_preBasic[22].key = "3k_battle_advice_deployment_siege_attack_equipment_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_attack_equipment_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[22].has_played = true;
    else
        advicePhase_preBasic[22].has_played = false;
    end


    advicePhase_preBasic[23] = { "key", "has_played"};
    advicePhase_preBasic[23].key = "3k_battle_advice_deployment_sally_out_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_sally_out_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[23].has_played = true;
    else
        advicePhase_preBasic[23].has_played = false;
    end


    advicePhase_preBasic[24] = { "key", "has_played"};
    advicePhase_preBasic[24].key = "3k_battle_advice_units_archers_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_units_archers_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[24].has_played = true;
    else
        advicePhase_preBasic[24].has_played = false;
    end


    advicePhase_preBasic[25] = { "key", "has_played"};
    advicePhase_preBasic[25].key = "3k_battle_advice_victory_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_victory_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[25].has_played = true;
    else
        advicePhase_preBasic[25].has_played = false;
    end


    advicePhase_preBasic[26] = { "key", "has_played"};
    advicePhase_preBasic[26].key = "3k_battle_advice_defeat_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_defeat_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[26].has_played = true;
    else
        advicePhase_preBasic[26].has_played = false;
    end


    advicePhase_preBasic[27] = { "key", "has_played"};
    advicePhase_preBasic[27].key = "3k_battle_advice_sieges_minor_settlement_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_sieges_minor_settlement_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[27].has_played = true;
    else
        advicePhase_preBasic[27].has_played = false;
    end

    advicePhase_preBasic[28] = { "key", "has_played"};
    advicePhase_preBasic[28].key = "3k_battle_advice_ambush_defence_extraction_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_ambush_defence_extraction_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_preBasic[28].has_played = true;
    else
        advicePhase_preBasic[28].has_played = false;
    end

end

---------------------------------------------------------------------------------------------------------
function advicePhases:setupBasicAdvicePhase() 

    advicePhase_basic = {}
    advicePhase_basic[1] = { "key", "has_played"};
    advicePhase_basic[1].key = "3k_battle_advice_ancillaries_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_ancillaries_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[1].has_played = true;
    else
        advicePhase_basic[1].has_played = false;
    end


    advicePhase_basic[2] = { "key", "has_played"};
    advicePhase_basic[2].key = "3k_battle_advice_units_weights_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_units_weights_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[2].has_played = true;
    else
        advicePhase_basic[2].has_played = false;
    end


    advicePhase_basic[3] = { "key", "has_played"};
    advicePhase_basic[3].key = "3k_battle_advice_units_weights_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_units_weights_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[3].has_played = true;
    else
        advicePhase_basic[3].has_played = false;
    end


    advicePhase_basic[4] = { "key", "has_played"};
    advicePhase_basic[4].key = "3k_battle_advice_units_weights_3";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_units_weights_3");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[4].has_played = true;
    else
        advicePhase_basic[4].has_played = false;
    end


    advicePhase_basic[5] = { "key", "has_played"};
    advicePhase_basic[5].key = "3k_battle_advice_charging_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_charging_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[5].has_played = true;
    else
        advicePhase_basic[5].has_played = false;
    end


    advicePhase_basic[6] = { "key", "has_played"};
    advicePhase_basic[6].key = "3k_battle_advice_commanders_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_commanders_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[6].has_played = true;
    else
        advicePhase_basic[6].has_played = false;
    end


    advicePhase_basic[7] = { "key", "has_played"};
    advicePhase_basic[7].key = "3k_battle_advice_deployment_4";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_4");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[7].has_played = true;
    else
        advicePhase_basic[7].has_played = false;
    end


    advicePhase_basic[8] = { "key", "has_played"};
    advicePhase_basic[8].key = "3k_battle_advice_deployment_units_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_units_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[8].has_played = true;
    else
        advicePhase_basic[8].has_played = false;
    end


    advicePhase_basic[9] = { "key", "has_played"};
    advicePhase_basic[9].key = "3k_battle_advice_fatigue_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_fatigue_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[9].has_played = true;
    else
        advicePhase_basic[9].has_played = false;
    end


    advicePhase_basic[10] = { "key", "has_played"};
    advicePhase_basic[10].key = "3k_battle_advice_fatigue_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_fatigue_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[10].has_played = true;
    else
        advicePhase_basic[10].has_played = false;
    end


    advicePhase_basic[11] = { "key", "has_played"};
    advicePhase_basic[11].key = "3k_battle_advice_fire_at_will_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_fire_at_will_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[11].has_played = true;
    else
        advicePhase_basic[11].has_played = false;
    end


    advicePhase_basic[12] = { "key", "has_played"};
    advicePhase_basic[12].key = "3k_battle_advice_flanking_3";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_flanking_3");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[12].has_played = true;
    else
        advicePhase_basic[12].has_played = false;
    end


    advicePhase_basic[13] = { "key", "has_played"};
    advicePhase_basic[13].key = "3k_battle_advice_flanking_4";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_flanking_4");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[13].has_played = true;
    else
        advicePhase_basic[13].has_played = false;
    end


    advicePhase_basic[14] = { "key", "has_played"};
    advicePhase_basic[14].key = "3k_battle_advice_guard_mode_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_guard_mode_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[14].has_played = true;
    else
        advicePhase_basic[14].has_played = false;
    end


    advicePhase_basic[15] = { "key", "has_played"};
    advicePhase_basic[15].key = "3k_battle_advice_strategic_map_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_strategic_map_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[15].has_played = true;
    else
        advicePhase_basic[15].has_played = false;
    end


    advicePhase_basic[16] = { "key", "has_played"};
    advicePhase_basic[16].key = "3k_battle_advice_deployment_units_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_units_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[16].has_played = true;
    else
        advicePhase_basic[16].has_played = false;
    end


    advicePhase_basic[17] = { "key", "has_played"};
    advicePhase_basic[17].key = "3k_battle_advice_morale_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_morale_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[17].has_played = true;
    else
        advicePhase_basic[17].has_played = false;
    end


    advicePhase_basic[18] = { "key", "has_played"};
    advicePhase_basic[18].key = "3k_battle_advice_reinforcements_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_reinforcements_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[18].has_played = true;
    else
        advicePhase_basic[18].has_played = false;
    end


    advicePhase_basic[19] = { "key", "has_played"};
    advicePhase_basic[19].key = "3k_battle_advice_duels_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_duels_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[19].has_played = true;
    else
        advicePhase_basic[19].has_played = false;
    end


    advicePhase_basic[20] = { "key", "has_played"};
    advicePhase_basic[20].key = "3k_battle_advice_retinues_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_retinues_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[20].has_played = true;
    else
        advicePhase_basic[20].has_played = false;
    end


    advicePhase_basic[21] = { "key", "has_played"};
    advicePhase_basic[21].key = "3k_battle_advice_duels_2a";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_duels_2a");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[21].has_played = true;
    else
        advicePhase_basic[21].has_played = false;
    end


    advicePhase_basic[22] = { "key", "has_played"};
    advicePhase_basic[22].key = "3k_battle_advice_duels_2b";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_duels_2b");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[22].has_played = true;
    else
        advicePhase_basic[22].has_played = false;
    end


    advicePhase_basic[23] = { "key", "has_played"};
    advicePhase_basic[23].key = "3k_battle_advice_deployment_siege_defence_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_defence_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[23].has_played = true;
    else
        advicePhase_basic[23].has_played = false;
    end


    advicePhase_basic[24] = { "key", "has_played"};
    advicePhase_basic[24].key = "3k_battle_advice_skirmish_mode_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_skirmish_mode_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[24].has_played = true;
    else
        advicePhase_basic[24].has_played = false;
    end


    advicePhase_basic[25] = { "key", "has_played"};
    advicePhase_basic[25].key = "3k_battle_advice_terrain_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_terrain_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[25].has_played = true;
    else
        advicePhase_basic[25].has_played = false;
    end


    advicePhase_basic[26] = { "key", "has_played"};
    advicePhase_basic[26].key = "3k_battle_advice_controls_dragout_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_controls_dragout_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[26].has_played = true;
    else
        advicePhase_basic[26].has_played = false;
    end


    advicePhase_basic[27] = { "key", "has_played"};
    advicePhase_basic[27].key = "3k_battle_advice_controls_dragout_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_controls_dragout_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[27].has_played = true;
    else
        advicePhase_basic[27].has_played = false;
    end


    advicePhase_basic[28] = { "key", "has_played"};
    advicePhase_basic[28].key = "3k_battle_advice_unit_formations_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_unit_formations_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[28].has_played = true;
    else
        advicePhase_basic[28].has_played = false;
    end


    advicePhase_basic[29] = { "key", "has_played"};
    advicePhase_basic[29].key = "3k_battle_advice_unit_formations_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_unit_formations_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[29].has_played = true;
    else
        advicePhase_basic[29].has_played = false;
    end


    advicePhase_basic[30] = { "key", "has_played"};
    advicePhase_basic[30].key = "3k_battle_advice_visibility_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_visibility_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[30].has_played = true;
    else
        advicePhase_basic[30].has_played = false;
    end


    advicePhase_basic[31] = { "key", "has_played"};
    advicePhase_basic[31].key = "3k_battle_advice_units_repeating_crossbows_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_units_repeating_crossbows_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[31].has_played = true;
    else
        advicePhase_basic[31].has_played = false;
    end


    advicePhase_basic[32] = { "key", "has_played"};
    advicePhase_basic[32].key = "3k_battle_advice_control_groups_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_control_groups_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_basic[32].has_played = true;
    else
        advicePhase_basic[32].has_played = false;
    end

end

---------------------------------------------------------------------------------------------------------
function advicePhases:setupIntermediateAdvicePhase() 

    advicePhase_intermediate = {}
    advicePhase_intermediate[1] = { "key", "has_played"};
    advicePhase_intermediate[1].key = "3k_battle_advice_backwards_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_backwards_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_intermediate[1].has_played = true;
    else
        advicePhase_intermediate[1].has_played = false;
    end


    advicePhase_intermediate[2] = { "key", "has_played"};
    advicePhase_intermediate[2].key = "3k_battle_advice_controls_path_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_controls_path_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_intermediate[2].has_played = true;
    else
        advicePhase_intermediate[2].has_played = false;
    end


    advicePhase_intermediate[3] = { "key", "has_played"};
    advicePhase_intermediate[3].key = "3k_battle_advice_retinues_3";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_retinues_3");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_intermediate[3].has_played = true;
    else
        advicePhase_intermediate[3].has_played = false;
    end


    advicePhase_intermediate[4] = { "key", "has_played"};
    advicePhase_intermediate[4].key = "3k_battle_advice_deployment_siege_attack_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_siege_attack_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_intermediate[4].has_played = true;
    else
        advicePhase_intermediate[4].has_played = false;
    end


    advicePhase_intermediate[5] = { "key", "has_played"};
    advicePhase_intermediate[5].key = "3k_battle_advice_special_abilities_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_special_abilities_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        advicePhase_intermediate[5].has_played = true;
    else
        advicePhase_intermediate[5].has_played = false;
    end


end