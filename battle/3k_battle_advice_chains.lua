---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Battle Advice Chains
----- Author: 		Leif Walter
----- Description: 	Three Kingdoms auxiliary system to help organise battle advice messages into chains.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- Core table
adviceChains = {};

---------------------------------------------------------------------------------------------------------
-- [[ Initialisation ]]
---------------------------------------------------------------------------------------------------------
function adviceChains:initialise(use_advice_history)

    adviceChains.chains = {};
    self.use_advice_history = use_advice_history;

    self:setupArmourAdviceChain();
    self:setupCommanderAdviceChains();
    self:setupDeploymentAdviceChains();
    self:setupUnitAdviceChains();

end

---------------------------------------------------------------------------------------------------------
-- [[ Auxiliary Functions ]]
---------------------------------------------------------------------------------------------------------

function adviceChains:setAdviceTriggeredInChain(chain, key) 
    for index in ipairs(chain) 
    do 
        if (chain[index].key == key) then chain[index].has_played = true; end
    end
end

function adviceChains:isAdvicePartOfChain(key) 
    for index in ipairs(adviceChains.chains) 
    do 
        local chain = adviceChains.chains[index];
        for index in ipairs(chain) 
        do 
            if (chain[index].key == key) then return true; end
        end
    end
    battleAdviceLogger:log("[WARNING] adviceChains:isAdvicePartOfChain(key) : Could not find chain for " .. key);
    return false;
end 

function adviceChains:setAdviceTriggered(key)
    if adviceChains:isAdvicePartOfChain(key) == true then 
        battleAdviceLogger:log("[INFO] adviceChains:setAdviceTriggered(key): Setting advice " .. key .. " to true.");
        adviceChains:setAdviceTriggeredInChain(adviceChains:getChainForAdviceKey(key), key);
    end
end

function adviceChains:getNextAdviceInChain(chain, key) 
    for index in ipairs(chain)
    do 
        if (chain[index].key == key and table_length(chain) > index) then return chain[index+1].key; end
    end
    script_error("Could not find next chain element for key: " .. key);
end

function adviceChains:getChainForAdviceKey(advice_key) 
    for index in ipairs(adviceChains.chains) 
    do 
        local chain = adviceChains.chains[index];
        for index in ipairs(chain) 
        do 
            if (chain[index].key == advice_key) then return chain; end
        end
    end
    script_error("Could not find key index for advice key: " .. advice_key);
    battleAdviceLogger:log("[ERROR] adviceChains:getChainForAdviceKey(advice_key): Could not find chain for key: " .. advice_key);
    return nil;
end

function adviceChains:haveAllPreviousChainElementsBeenTriggered(advice_key)
    local chain = adviceChains:getChainForAdviceKey(advice_key);
    local key_index = adviceChains:getIndexForAdviceKey(chain, advice_key);
    if (key_index == nil) then 
        script_error("Could not find key index for advice key: " .. advice_key);
        battleAdviceLogger:log("[ERROR] adviceChains:haveAllPreviousChainElementsBeenTriggered(advice_key): Could not find key index for advice key: " .. advice_key);
        return false;
    end
    for index=1,key_index-1 do 
        if chain[index].has_played == false then 
            battleAdviceLogger:log("[INFO] adviceChains:haveAllPreviousChainElementsBeenTriggered(advice_key): Advice " .. chain[index].key .. " has not been played, so returning false for key: " .. advice_key);
            return false;
        end
    end
    return true;
end

function adviceChains:getIndexForAdviceKey(chain, advice_key) 
    for index in ipairs(chain)
    do
        if (chain[index].key == advice_key) then return index;
        end 
    end 
    return nil;
end 

function adviceChains:isChainComplete(chain)
    for index in ipairs(chain)
    do
        if (chain[index].has_played == false) then return false;
        end 
    end 
    return true;
end 

function adviceChains:basicDeploymentChainComplete() 

    if adviceChain_deployment[1].has_played == true and adviceChain_deployment[2].has_played == true then 
        return true 
    else 
        return false 
    end

end 



---------------------------------------------------------------------------------------------------------
-- [[ Setting up Advice Chains ]]
---------------------------------------------------------------------------------------------------------
function adviceChains:setupArmourAdviceChain() 
    adviceChain_armour = {}
    adviceChain_armour[0] = { "key", "has_played"};
    adviceChain_armour[0].key = "3k_battle_advisor_advice_armour_types_armour_01";
    adviceChain_armour[0].has_played = false;

    adviceChain_armour[1] = { "key", "has_played"};
    adviceChain_armour[1].key = "3k_battle_advisor_advice_armour_types_armour_02";
    adviceChain_armour[1].has_played = false;

    adviceChain_armour[2] = { "key", "has_played"};
    adviceChain_armour[2].key = "3k_battle_advisor_advice_armour_types_armour_03";
    adviceChain_armour[2].has_played = false;

    adviceChain_armour[3] = { "key", "has_played"};
    adviceChain_armour[3].key = "3k_battle_advisor_advice_armour_types_armour_04";
    adviceChain_armour[3].has_played = false;

    adviceChain_armour[4] = { "key", "has_played"};
    adviceChain_armour[4].key = "3k_battle_advisor_advice_armour_types_armour_05";
    adviceChain_armour[4].has_played = false;

    adviceChains.chains[1] = adviceChain_armour;
end

---------------------------------------------------------------------------------------------------------
function adviceChains:setupCommanderAdviceChains()
    adviceChain_commanders = {}
    adviceChain_commanders[0] = { "key", "has_played"};
    adviceChain_commanders[0].key = "3k_battle_advisor_advice_commanders_attack_hero_01";
    adviceChain_commanders[0].has_played = false;

    adviceChain_commanders[1] = { "key", "has_played"};
    adviceChain_commanders[1].key = "3k_battle_advisor_advice_generals_general_01";
    adviceChain_commanders[1].has_played = false;

    adviceChains.chains[2] = adviceChain_commanders;
end

function adviceChains:setupDeploymentAdviceChains() 
    adviceChain_deployment = {}
    adviceChain_deployment[1] = { "key", "has_played"};
    adviceChain_deployment[1].key = "3k_battle_advice_deployment_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_1");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        adviceChain_deployment[1].has_played = true;
    else
        adviceChain_deployment[1].has_played = false;
    end


    adviceChain_deployment[2] = { "key", "has_played"};
    adviceChain_deployment[2].key = "3k_battle_advice_deployment_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_2");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        adviceChain_deployment[2].has_played = true;
    else
        adviceChain_deployment[2].has_played = false;
    end


    adviceChain_deployment[3] = { "key", "has_played"};
    adviceChain_deployment[3].key = "3k_battle_advice_deployment_3";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_3");
    if is_number(advice_score) and advice_score > 0 and self.use_advice_history == true then
        adviceChain_deployment[3].has_played = true;
    else
        adviceChain_deployment[3].has_played = false;
    end

    adviceChains.chains[3] = adviceChain_deployment;
end

function adviceChains:setupUnitAdviceChains() 

    adviceChain_units = {}
    adviceChain_units[1] = { "key", "has_played"};
    adviceChain_units[1].key = "3k_battle_advice_deployment_units_1";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_units_1");
    if is_number(advice_score) and advice_score > 0 then
        adviceChain_units[1].has_played = true;
    else
        adviceChain_units[1].has_played = false;
    end


    adviceChain_units[2] = { "key", "has_played"};
    adviceChain_units[2].key = "3k_battle_advice_deployment_units_2";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_units_2");
    if is_number(advice_score) and advice_score > 0 then
        adviceChain_units[2].has_played = true;
    else
        adviceChain_units[2].has_played = false;
    end


    adviceChain_units[3] = { "key", "has_played"};
    adviceChain_units[3].key = "3k_battle_advice_deployment_units_3";
    local advice_score = effect.get_advice_thread_score("3k_battle_advice_deployment_units_3");
    if is_number(advice_score) and advice_score > 0 then
        adviceChain_units[3].has_played = true;
    else
        adviceChain_units[3].has_played = false;
    end

    adviceChains.chains[4] = adviceChain_units;

end 