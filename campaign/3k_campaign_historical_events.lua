-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
------------------------- Historical Events -------------------------------
-------------------------------------------------------------------------------
------------------------- Created by Nic: 06/02/2019 --------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

out("3k_historical_events.lua: Loading");

-- Liu Bei AI confederation script
function setup_historical_events()
    
    -- Not proceeding if multiplayer
    if cm:is_multiplayer() then
        output("### Game is multiplayer not setting up Liu Bei AI confederation script ###")
        return;
    end;

    -- Setup Liu Biao's state in case game is loaded
    liu_biao_death = false
    if cm:get_saved_value("liu_biao_death") then
        liu_biao_death = true
    end;

    -- Start listeners if not triggered already
    if not cm:get_saved_value("liu_biao_confederation") then
        output("### Starting Liu Bei AI confederation listener for Liu Biao ###")
        liu_bei_ai_confederation_listener_liu_biao(liu_biao_death);
    end;

    if not cm:get_saved_value("liu_yan_confederation") then
        output("### Starting Liu Bei AI confederation listener for Liu Yan ###")
        liu_bei_ai_confederation_listener_liu_yan();
    end;
end;

function liu_bei_ai_confederation(my_faction, other_faction, actor_region_count, target_region_count)
	
	if not is_string(my_faction) then
        script_error("ERROR: liu_bei_ai_confederation() called but supplied faction key [" .. tostring(my_faction) .. "] is not a string")
        return false;
	end;
	
	if not is_string(other_faction) then
        script_error("ERROR: liu_bei_ai_confederation() called but supplied other_faction key [" .. tostring(other_faction) .. "] is not a string")
        return false;
	end;	

	if not is_number(actor_region_count) then
        script_error("ERROR: liu_bei_ai_confederation() called but supplied actor_region_count [" .. tostring(actor_region_count) .. "] is not a number")
        return false;
	end;   
	
	if not is_number(target_region_count) then
        script_error("ERROR: liu_bei_ai_confederation() called but supplied target_region_count [" .. tostring(target_region_count) .. "] is not a number")
        return false;
    end;   

	local local_faction = cm:query_faction(my_faction)
	local local_other_faction = cm:query_faction(other_faction)
		
	if not local_faction or local_faction:is_null_interface() or not local_other_faction or local_other_faction:is_null_interface() then
		return false;
	end;

	if local_faction:is_human() or local_other_faction:is_human() then
		output("### Not proceeding with confederation as local faction is either " .. my_faction .. " or " .. other_faction .. " ###")
		return false;
	end;

	if local_faction:is_dead() or local_other_faction:is_dead() then
		output("### Either " .. my_faction .. " or " .. other_faction .. " is dead ###")
		return false;
	end;

	if local_faction:region_list():num_items() < actor_region_count and local_other_faction:region_list():num_items() > target_region_count then
		output("### Attempting to trigger confederation with " .. my_faction .. " and " .. other_faction .. " ###")
		cm:modify_faction(my_faction):apply_automatic_diplomatic_deal("data_defined_situation_liu_bei_confederate_recipient", local_other_faction, ""); 
        --other_faction:apply_automatic_diplomatic_deal("3k_main_automatic_deal_confederate_recipient", my_faction);
        if local_other_faction:is_dead() then
            return true;
        end
	end;

	return false;
end;

function liu_bei_ai_confederation_listener_liu_biao(liu_biao_death)
	output("### Liu Bei AI confederation script is being loaded ###")
	output("### Liu Biao death: " .. tostring(liu_biao_death))

	core:add_listener(
		"liu_bei_ai_confederation_listener_liu_biao",
		"CharacterDied",
        function(context)
			if not context:query_model():is_player_turn() then
				return context:query_character():generation_template_key() == "3k_main_template_historical_liu_biao_hero_earth";
			end
		end,
		function()
			output("### Liu Bei AI confederation script is trying to trigger for Liu Biao! Reason: Liu Biao died ###")
			liu_biao_death = true
			cm:set_saved_value("liu_biao_death", true);
			output("### Liu Biao death: " .. tostring(liu_biao_death))
            if liu_bei_ai_confederation("3k_main_faction_liu_bei", "3k_main_faction_liu_biao",15,1) then
                core:remove_listener("liu_bei_ai_confederation_listener_liu_biao");
                core:remove_listener("liu_bei_ai_confederation_listener_liu_biao_2");
                output("### Removing Liu Bei AI confederation script listeners for Liu Biao!")
                cm:set_saved_value("liu_biao_confederation", true);
			end
		end,
		false
	)

	core:add_listener(
		"liu_bei_ai_confederation_listener_liu_biao_2",
		"FactionTurnStart",
		function(context)
			return context:query_model():turn_number() >= 100 --and liu_biao_death == true
		end,
		function()
			output("### Liu Bei AI confederation script is trying to trigger for Liu Biao! Reason: Turn > 150 ###")
            if liu_bei_ai_confederation("3k_main_faction_liu_bei", "3k_main_faction_liu_biao",10,2) then
                core:remove_listener("liu_bei_ai_confederation_listener_liu_biao");
                core:remove_listener("liu_bei_ai_confederation_listener_liu_biao_2");
                output("### Removing Liu Bei AI confederation script listeners for Liu Biao!")
                cm:set_saved_value("liu_biao_confederation", true);
			end
		end,
		true
    )
end

function liu_bei_ai_confederation_listener_liu_yan()
	core:add_listener(
		"liu_bei_ai_confederation_listener_liu_yan",
		"FactionTurnStart",
		function(context)
			return context:query_model():turn_number() >= 150
		end,
		function()
			output("### Liu Bei AI confederation script is trying to trigger for Liu Yan! Reason: Turn > 150 ###")
			if liu_bei_ai_confederation("3k_main_faction_liu_bei", "3k_main_faction_liu_yan",20,2) then
				core:remove_listener("liu_bei_ai_confederation_listener_liu_yan");
                output("### Removing Liu Bei AI confederation script listeners for Liu Yan!");
                cm:set_saved_value("liu_yan_confederation", true);
			end
		end,
		true
	)
end;