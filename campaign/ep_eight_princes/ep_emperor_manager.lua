--Emperor Manager--
--Author: Will Wright--
--This script causes player dilemma choices to move, or remove, the Emperor World Power Token--

---------------------------------------------------------
--------------------VARIABLES----------------------------
---------------------------------------------------------


ep_emperor_manager = {
}

ep_emperor_manager.emperor_token_key = "ep_emperor";

ep_emperor_manager.turns_before_emperor_choice = 15;

--- contains the data mapping dilemma choices to emperor token outcomes. The script gets 0 for top left choice, 1 for top right, 2 for bottom left and 3 for bottom right
ep_emperor_manager.choice_to_outcome = { 
  ep_dilemma_protector_generic0 = "player_gets_emperor",
  ep_dilemma_protector_sima_ai0 = "player_gets_emperor",
  ep_dilemma_protector_heart_10 =  "player_gets_emperor",
  ep_dilemma_protector_heart_12 = "player_gets_emperor",
  ep_dilemma_protector_heart_20 = "player_gets_emperor",
  ep_dilemma_protector_heart_30 = "player_gets_emperor",
  ep_dilemma_protector_heart_40 = "player_gets_emperor",
  ep_dilemma_protector_money0 = "player_gets_emperor",
  ep_dilemma_protector_brain1 = "player_gets_emperor",
  ep_dilemma_welcomed_into_capital_betray_sima_ai2 ="emperor_flees",
  ep_dilemma_welcomed_into_capital_cruel_general0 = "emperor_flees",
  ep_dilemma_welcomed_into_capital_generic1 = "emperor_flees",
  ep_dilemma_welcomed_into_capital_lu_zhi2 = "emperor_flees",
  ep_dilemma_welcomed_into_capital_money1 = "emperor_flees",
  ep_dilemma_welcomed_into_capital_sun_xiu1 = "emperor_flees",
  ep_dilemma_contextual_emperor_captured0 = "emperor_retires",
  ep_dilemma_contextual_emperor_captured1 = "emperor_retires",
  ep_dilemma_emperor_flees_fist_high0 = "emperor_flees",
  ep_dilemma_emperor_flees_rank_too_low0 = "emperor_flees",
  ep_dilemma_contextual_continue_regency_or_become_emperor1 = "emperor_retires",
  ep_dilemma_contextual_continue_regency_or_become_emperor2 = "emperor_retires"
}

---------------------------------------------------------
--------------------LISTENERS----------------------------
---------------------------------------------------------

function ep_emperor_manager:initialise()
  output("ep_emperor_manager:initialise()");

  require("ep_storybook") -- the storybook already saves if the player is Emperor or not, so we can use that info here.


---listen for the dilemma choices that can influence the Emperor token, concat the dilemma key and choice and check against the list to see what to do
  core:add_listener(
    "DilemmaChoiceMadeEventEmperorChoiceMade",
    "DilemmaChoiceMadeEvent",
    function(context)
      local dilemma = context:dilemma()
      return dilemma == string.match(dilemma,"ep_dilemma_protector.*") or dilemma == string.match(dilemma, "ep_dilemma_emperor_flees.*") or dilemma == string.match(dilemma, "ep_dilemma_welcomed_into_capital.*") or dilemma == "ep_dilemma_contextual_emperor_captured" or dilemma == "ep_dilemma_contextual_continue_regency_or_become_emperor"
    end,
    function(context)
      local dilemma = context:dilemma()
      local outcome = self.choice_to_outcome[dilemma..context:choice()]
      if outcome == "player_gets_emperor" then
        local faction = context:faction()
        output("sending the emperor to "..faction:name())
        transfer_token_to_faction(faction) --- faction who received dilemma gets the Emperor.
      elseif outcome == "emperor_flees" then -- emperor gets handed to random faction (weighted towards powerful ones)
        local dilemma_faction = context:faction()
        local faction = find_opposing_faction(dilemma_faction)
        output("sending the emperor to"..faction:name())
        transfer_token_to_faction(faction)
      elseif outcome == "emperor_retires" then -- emperor gets removed from campaign
        local faction = context:faction()
        output("removing the emperor from"..faction:name())
        remove_token(faction)
      else 
        output("no Emperor outcome found for this dilemma choice - script will leave the Emperor alone")
      end
      if dilemma == string.match(dilemma, "ep_dilemma_welcomed_into_capital.*") or dilemma == "ep_dilemma_contextual_emperor_captured" or (dilemma == "ep_dilemma_contextual_continue_regency_or_become_emperor" and (context:choice() == 1 or context:choice() == 2))  then
        kill_the_empress()
      end
    end,
    true
  );

---if the emperor changes hands, decided what to do. If the player has captured him in battle, ask whether they're Emperor - if so, give them the Emperor Captured dilemma. If not, update the UI to show that they're now Regent and kill the Empress.
  core:add_listener(
    "WorldPowerTokenCapturedEventEmperorCaptured",
    "WorldPowerTokenCapturedEvent",
    function(context)
      return context:query_model():pending_battle():is_active()-- hacky, but the only way I can think of the check to see if the emperor move is due to the player capturing him.
    end,
    function(context)
      local attacking_faction_key = context:query_model():pending_battle():attacker():faction():name()
      core:add_listener( -- need to wait until the battle is over
        "BattleCompletedPlayerCapsEmperor", -- Unique handle
        "BattleCompleted", -- Campaign Event to listen for
        true,
        function(context) -- What to do if listener fires.
        if ep_storybook.storybook_event_generator[attacking_faction_key]["emperor_choice"] == 2 then -- check the saved variables to see if the player is Emperor
          output("triggering the emperor captured event!")
          cm:trigger_dilemma(attacking_faction_key, "ep_dilemma_contextual_emperor_captured", true) 
        else 
          ep_storybook.storybook_event_generator[attacking_faction_key]["emperor_choice"] = 1 -- update the UI as you're regent now
          ep_storybook:update_storybook_milestone_events(attacking_faction_key)
          kill_the_empress() -- kill her!
        end
        end,
        false --Is persistent
        );
      end,
    true)


---immediately trigger Emperor Captured event if you betray on the Sima Ai-unique or high heart capital captured variant.
  core:add_listener(
    "DilemmaChoiceMadeEventEmperorChoiceMade",
    "DilemmaChoiceMadeEvent",
    function(context)
      local dilemma = context:dilemma()
      local choice = context:choice()
      return (dilemma == "ep_dilemma_welcomed_into_capital_sima_ai" and choice == 1) or (dilemma == "ep_dilemma_welcomed_into_capital_heart" and choice == 1)
    end,
    function(context)
      local faction = context:faction():name()
      cm:trigger_dilemma(faction, "ep_dilemma_contextual_emperor_captured", true)   
    end,
    false
  );

--- Who has the Emperor token at turn start? If it's a human, update their UI and start the countdown until they get offered the choice to be Emperor. If it's not the Jin and it's not the player, kill the Empress. If it's somehow the player and they're also emperor (probably because a vassal has capped the Emperor and given it to him), give them the emperor captured dilemma.
  core:add_listener(
    "FactionTurnStartDoesPlayerHaveEmperor",
    "FactionTurnStart",
    function(context)
      local modify_model = cm:modify_model();
      local modify_world = modify_model:get_modify_world();
      local query_tokens = modify_world:query_world():world_power_tokens();
      local owning_faction = query_tokens:owning_faction("ep_emperor")
      local faction = context:faction()
      return owning_faction == faction
    end,
    function(context)
      local faction = context:faction()
      local faction_key = faction:name()
      if faction:is_human() then
        if ep_storybook.storybook_event_generator[faction_key]["emperor_choice"] == 2 then -- if the player is the emperor, trigger the emperor captured dilemma.
          cm:trigger_dilemma(faction_key, "ep_dilemma_contextual_emperor_captured", true)
        else
          ep_storybook.storybook_event_generator[faction_key]["emperor_choice"] = 1
          ep_storybook:update_storybook_milestone_events(faction_key)
          if ep_storybook.storybook_event_generator[faction_key]["turns_as_regent"] >= self.turns_before_emperor_choice then
            cm:trigger_dilemma(faction_key, "ep_dilemma_contextual_continue_regency_or_become_emperor", true)
          else ep_storybook.storybook_event_generator[faction_key]["turns_as_regent"] = ep_storybook.storybook_event_generator[faction_key]["turns_as_regent"] + 1
          end
        end
      elseif faction_key ~= "ep_faction_empire_of_jin" then
      kill_the_empress()
      end
    end,
    true
  );


end;
---------------------------------------------------------
--------------------FUNCTIONS----------------------------
---------------------------------------------------------
function transfer_token_to_faction(faction) -- simply transfer the token to the faction specified
  local modify_model = cm:modify_model();
  local modify_world = modify_model:get_modify_world();
  local query_tokens = modify_world:query_world():world_power_tokens();
  local modify_tokens = modify_world:get_modify_world_power_tokens(query_tokens);
  local modify_faction = cm:modify_faction(faction);
  modify_tokens:transfer(ep_emperor_manager.emperor_token_key, modify_faction)
end

function find_opposing_faction(dilemma_faction) -- returns a faction who is not the Jin Empire or the dilemma faction, weighted towards other player, factions with a higher progression level, playable factions, and factions at war with the player
  local transfer_q_faction = nil;
  local highest_score = 0;
  for i=0, cm:query_model():world():faction_list():num_items() - 1 do
    local qFaction = cm:query_model():world():faction_list():item_at(i);
    local qFactionScore = 0;
    if not qFaction:is_dead() and qFaction:subculture() == "3k_main_chinese" then
      if qFaction:is_human() then -- prefer human players
        qFactionScore = qFactionScore + 75
      end
      if qFaction:has_specified_diplomatic_deal_with("treaty_components_war", dilemma_faction) then --- prefer a faction the player is at war with
        qFactionScore = qFactionScore + 25
      end;  
      if qFaction:has_specified_diplomatic_deal_with_anybody("treaty_components_vassalage") then --- try to avoid sending him to vassals
        qFactionScore = qFactionScore - 25
      end;
      if qFaction:name() == "ep_faction_prince_of_chu" or qFaction:name() == "ep_faction_prince_of_donghai" or qFaction:name() == "ep_faction_prince_of_qi" or qFaction:name() == "ep_faction_prince_of_runan" or qFaction:name() == "ep_faction_prince_of_changsha" or qFaction:name() == "ep_faction_prince_of_chengdu" or qFaction:name() == "ep_faction_prince_of_hejian" then --- try to choose a major faction
        qFactionScore = qFactionScore + 50
      end;
      qFactionScore = qFactionScore + (qFaction:region_list():num_items()*5); -- prefer factions with lots of regions
      qFactionScore = qFactionScore + (qFaction:progression_level()*25); -- prefer factions with higher progression level
      qFactionScore = qFactionScore + cm:random_number(15);
      if qFaction == dilemma_faction then -- don't give him to the faction he's running away from!
        qFactionScore = -1
      end;
      if qFaction:name() == "ep_faction_empire_of_jin" then -- don't give him to the Jin
        qFactionScore = -1
      end;
      if qFactionScore > highest_score then
        transfer_q_faction = qFaction;
        highest_score = qFactionScore
      end;
    end;
  end;
  return transfer_q_faction
end

function remove_token(faction) -- remove the token from a faction (and thus from the campaign)
  local modify_model = cm:modify_model();
  local modify_world = modify_model:get_modify_world();
  local query_tokens = modify_world:query_world():world_power_tokens();
  local modify_tokens = modify_world:get_modify_world_power_tokens(query_tokens);
  local modify_faction = cm:modify_faction(faction);
  modify_tokens:remove(ep_emperor_manager.emperor_token_key, modify_faction)
end

function kill_the_empress() -- kill the empress for all players
  local humans = cm:get_human_factions();
  if ep_storybook.empress_dead ~= true then
    if #humans > 0 then
      for i = 1, #humans do
        local faction_key = cm:query_faction(humans[i]):name();
        cm:trigger_dilemma(faction_key, "ep_dilemma_contextual_empress_dies", false)
      end
    end
    ep_storybook.empress_dead = true
  end
end