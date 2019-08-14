---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Commentary Events
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to fire character driven events when certain events happen. This occurs for each faction.
-----               *The EVENTS themselves should be marked as unique so even over save games the listeners will just remove themselves.*
-----               These listeners should be triggered in each faction start script.
-----               This system is currently SP only.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

commentary_events = {};

function commentary_events:initialise()
	
	local human_factions = cm:get_human_factions();

	for i, faction_key in ipairs( human_factions ) do
		if faction_key == "3k_main_faction_cao_cao" then
			self:setup_first_victory_trigger("3k_main_commentary_cao_cao_first_victory_incident", faction_key);
			self:setup_first_city_capture_trigger("3k_main_commentary_cao_cao_first_conquest_incident", faction_key);
			self:setup_first_character_died_trigger("3k_main_commentary_cao_cao_first_character_died_incident", faction_key);
			self:setup_first_spy_sent_trigger("3k_main_commentary_cao_cao_first_spy_sent_incident", faction_key);
			self:setup_first_proxy_war_trigger("3k_main_commentary_cao_cao_first_proxy_war_caused_incident", faction_key);
		elseif faction_key == "3k_main_faction_dong_zhuo" then
			self:setup_first_victory_trigger("3k_main_commentary_dong_zhuo_first_victory_incident", faction_key);
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_dong_zhuo_first_faction_rank_incident", faction_key);
			self:setup_first_defeat_trigger("3k_main_commentary_dong_zhuo_first_defeat_incident", faction_key);
			self:setup_first_character_executed_trigger("3k_main_commentary_dong_zhuo_first_character_executed_incident", faction_key);
			self:setup_first_character_leaves_faction_trigger("3k_main_commentary_dong_zhuo_first_character_defection_incident", faction_key);
		elseif faction_key == "3k_main_faction_gongsun_zan" then
			self:setup_first_victory_trigger("3k_main_commentary_gongsun_zan_first_victory_incident", faction_key);
			self:setup_first_character_died_trigger("3k_main_commentary_gongsun_zan_first_character_died_incident", faction_key);
			self:setup_first_province_completed_trigger("3k_main_commentary_gongsun_zan_first_province_incident", faction_key);
			self:setup_first_defeat_trigger("3k_main_commentary_gongsun_zan_first_defeat_incident", faction_key);
			self:setup_first_character_leaves_faction_trigger("3k_main_commentary_gongsun_zan_first_character_defection_incident", faction_key);
		elseif faction_key == "3k_main_faction_kong_rong" then
			self:setup_first_city_capture_trigger("3k_main_commentary_kong_rong_first_conquest_incident", faction_key);
			self:setup_first_province_completed_trigger("3k_main_commentary_kong_rong_first_province_incident", faction_key);
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_kong_rong_first_faction_rank_incident", faction_key);
			self:setup_first_trade_agreement_trigger("3k_main_commentary_kong_rong_first_trade_agreement_incident", faction_key);
			self:setup_first_alliance_trigger("3k_main_commentary_kong_rong_new_alliance_members_incident", faction_key);
		elseif faction_key == "3k_main_faction_liu_bei" then
			self:setup_first_city_capture_trigger("3k_main_commentary_liu_bei_first_conquest_incident", faction_key);
			self:setup_first_character_died_trigger("3k_main_commentary_liu_bei_first_character_died_incident", faction_key);
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_liu_bei_first_faction_rank_incident", faction_key);
			self:setup_first_character_rank_up_trigger("3k_main_commentary_liu_bei_first_character_rank_incident", faction_key);
			self:setup_first_character_leaves_faction_trigger("3k_main_commentary_liu_bei_first_character_defection_incident", faction_key);
		elseif faction_key == "3k_main_faction_liu_biao" then
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_liu_biao_first_faction_rank_incident", faction_key);
			self:setup_first_trade_agreement_trigger("3k_main_commentary_liu_biao_first_trade_agreement_incident", faction_key);
			self:setup_first_alliance_trigger("3k_main_commentary_liu_biao_new_alliance_members_incident", faction_key);
			self:setup_first_character_rank_up_trigger("3k_main_commentary_liu_biao_first_character_rank_incident", faction_key);
			self:setup_first_building_completed_trigger("3k_main_commentary_liu_biao_first_building_completed_incident", faction_key);
			self:setup_first_character_leaves_faction_trigger("3k_main_commentary_liu_biao_first_character_defection", faction_key);
		elseif faction_key == "3k_main_faction_ma_teng" then
			self:setup_first_victory_trigger("3k_main_commentary_ma_teng_first_victory_incident", faction_key);
			self:setup_first_city_capture_trigger("3k_main_commentary_ma_teng_first_conquest_incident", faction_key);
			self:setup_first_province_completed_trigger("3k_main_commentary_ma_teng_first_province_incident", faction_key);
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_ma_teng_first_faction_rank_incident", faction_key);
			self:setup_first_defeat_trigger("3k_main_commentary_ma_teng_first_defeat_incident", faction_key);
		elseif faction_key == "3k_main_faction_sun_jian" then
			self:setup_first_victory_trigger("3k_main_commentary_sun_jian_first_victory_incident", faction_key);
			self:setup_first_city_capture_trigger("3k_main_commentary_sun_jian_first_conquest_incident", faction_key);
			self:setup_first_province_completed_trigger("3k_main_commentary_sun_jian_first_province_incident", faction_key);
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_sun_jian_first_faction_rank_incident", faction_key);
			self:setup_first_defeat_trigger("3k_main_commentary_sun_jian_first_defeat_incident", faction_key);
		elseif faction_key == "3k_main_faction_yellow_turban_anding" 
				or faction_key == "3k_main_faction_yellow_turban_rebels"
				or faction_key == "3k_main_faction_yellow_turban_taishan" then
			self:setup_first_victory_trigger("3k_ytr_commentary_yellow_turbans_first_victory_incident", faction_key);
			self:setup_first_city_capture_trigger("3k_ytr_commentary_yellow_turbans_first_conquest_incident", faction_key);
			self:setup_first_defeat_trigger("3k_ytr_commentary_yellow_turbans_first_defeat_incident", faction_key);
			self:setup_first_research_trigger("3k_ytr_commentary_yellow_turbans_first_technology_incident", faction_key);
			self:setup_first_faction_leader_died_trigger("3k_ytr_commentary_yellow_turbans_first_faction_leader_death_incident", faction_key);
		elseif faction_key == "3k_main_faction_yuan_shao" then
			self:setup_first_city_capture_trigger("3k_main_commentary_yuan_shao_first_conquest_incident", faction_key);
			self:setup_first_character_died_trigger("3k_main_commentary_yuan_shao_first_character_died_incident", faction_key);
			self:setup_first_province_completed_trigger("3k_main_commentary_yuan_shao_first_province_incident", faction_key);
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_yuan_shao_first_faction_rank_incident", faction_key);
			self:setup_first_alliance_trigger("3k_main_commentary_yuan_shao_new_alliance_members_incident", faction_key);
		elseif faction_key == "3k_main_faction_yuan_shu" then
			self:setup_first_city_capture_trigger("3k_main_commentary_yuan_shu_first_conquest_incident", faction_key);
			self:setup_first_spy_sent_trigger("3k_main_commentary_yuan_shu_first_spy_sent_incident", faction_key);
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_yuan_shu_first_faction_rank_incident", faction_key);
			self:setup_first_trade_agreement_trigger("3k_main_commentary_yuan_shu_first_trade_agreement_incident", faction_key);
			self:setup_first_character_leaves_faction_trigger("3k_main_commentary_yuan_shu_first_character_defection_incident", faction_key);
		elseif faction_key == "3k_main_faction_zhang_yan" then
			self:setup_first_victory_trigger("3k_main_commentary_zhang_yan_first_victory_incident", faction_key);
			self:setup_first_city_capture_trigger("3k_main_commentary_zhang_yan_first_conquest_incident", faction_key);
			self:setup_first_character_died_trigger("3k_main_commentary_zhang_yan_first_character_died_incident", faction_key);
			self:setup_first_province_completed_trigger("3k_main_commentary_zhang_yan_first_province_incident", faction_key);
			self:setup_first_defeat_trigger("3k_main_commentary_zhang_yan_first_defeat_incident", faction_key);
		elseif faction_key == "3k_main_faction_zheng_jiang" then
			self:setup_first_victory_trigger("3k_main_commentary_zheng_jiang_first_victory_incident", faction_key);
			self:setup_first_city_capture_trigger("3k_main_commentary_zheng_jiang_first_conquest_incident", faction_key);
			self:setup_first_province_completed_trigger("3k_main_commentary_zheng_jiang_first_province_incident", faction_key);
			self:setup_first_faction_rank_up_trigger("3k_main_commentary_zheng_jiang_first_faction_rank_incident", faction_key);
			self:setup_first_defeat_trigger("3k_main_commentary_zheng_jiang_first_defeat_incident", faction_key);
		end;
	end;
        
end;
---------------------------------------------------------------------------------------------------------
----- Listeners
---------------------------------------------------------------------------------------------------------

-- First Victory
function commentary_events:setup_first_victory_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "CampaignBattleLoggedEvent",
        function(context)
            local winning_factions = context:log_entry():winning_factions();

            for i=0, winning_factions:num_items() - 1 do
                if winning_factions:item_at(i):name() == faction_key then
                    return true;
                end
            end;

            return false;
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - First victory [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    )
end;

-- First City Capture
function commentary_events:setup_first_city_capture_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "GarrisonOccupiedEvent",
        function(context)
            return context:query_character():faction():name() == faction_key;
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - First city [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    )
end;

-- First Character Died
function commentary_events:setup_first_character_died_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "CharacterDied",
		function(context)
			
			if context:query_character():faction():name() ~= faction_key then
				return false;
			end;

			if not context:query_character():character_type("general") then
				return false;
			end;

			if not context:was_recruited_in_faction() then
				return false;
			end;

			if not context:query_character():family_member():come_of_age() then
				return false;
			end;

			return true;
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - First char died [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    )
end;

-- First Spy Sent
function commentary_events:setup_first_spy_sent_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "UndercoverCharacterAddedEvent",
        function(context)
            return context:source_faction():name() == faction_key;
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - First spy [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    )
end;

-- First Province Completed
-- Must input custom starting provinces so we don't have to store it.
function commentary_events:setup_first_province_completed_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "GarrisonOccupiedEvent",
		function(context)
			local faction = context:query_character():faction();
			local province_name = context:garrison_residence():region():province_name();

			if faction:name() ~= faction_key then
				return false;
			end;
			
			return faction_owns_entirety_of_province( faction, province_name, false );
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - First province [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    )
end;

-- First Faction Rank up - FactionFameLevelUp
function commentary_events:setup_first_faction_rank_up_trigger(event_key, starting_rank, faction_key)
    starting_rank = starting_rank or 1;

    core:add_listener(
        event_key,
        "FactionFameLevelUp",
        function(context)
            return context:faction():name() == faction_key;
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - First faction rank [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    )
end;

-- First Defeat
function commentary_events:setup_first_defeat_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "CampaignBattleLoggedEvent",
        function(context)
            local winning_factions = context:log_entry():losing_factions();

            for i=0, winning_factions:num_items() - 1 do
                if winning_factions:item_at(i):name() == faction_key then
                    return true;
                end
            end;

            return false;
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - First defeat [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    )
end;

-- First Trade Agreement
function commentary_events:setup_first_trade_agreement_trigger(event_key, faction_key)
	core:add_listener(
		event_key, -- Unique handle
		"DiplomacyDealNegotiated", -- Campaign Event to listen for
		function(context) -- Criteria
			return faction_signed_component_in_negotiated_deals(context:deals(), faction_key, "treaty_components_trade");
		end,
		function(context) -- What to do if listener fires.
			cdir_events_manager:print("COMMENTARY EVENT - First Trade [" .. faction_key .. "]");
			self:fire_incident(event_key, faction_key);
		end,
		true --Is persistent
	);
end;

-- New Alliance Members
function commentary_events:setup_first_alliance_trigger(event_key, faction_key)

	core:add_listener(
		event_key, -- Unique handle
		"DiplomacyDealNegotiated", -- Campaign Event to listen for
		function(context) -- Criteria
			return faction_signed_component_in_negotiated_deals(context:deals(), faction_key, "treaty_components_create_alliance")
			or faction_signed_component_in_negotiated_deals(context:deals(), faction_key, "treaty_components_create_alliance_yuan_shao")
			or faction_signed_component_in_negotiated_deals(context:deals(), faction_key, "treaty_components_create_alliance_yuan_shu")
			or faction_signed_component_in_negotiated_deals(context:deals(), faction_key, "treaty_components_join_alliance_proposers")
			or faction_signed_component_in_negotiated_deals(context:deals(), faction_key, "treaty_components_join_alliance_recipients")
		end,
		function(context) -- What to do if listener fires.
			cdir_events_manager:print("COMMENTARY EVENT - First Alliance [" .. faction_key .. "]");
			self:fire_incident(event_key, faction_key);
		end,
		false --Is persistent
	);
end;

-- First Character Rank Up
function commentary_events:setup_first_character_rank_up_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "CharacterRank",
        function(context)
            if context:query_character():faction():name() ~= faction_key then
				return false;
			end;

			if not context:query_character():character_type("general") then
				return false;
			end;

			return true;
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - Character Rank Up [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    );
end;

-- First Character Executed (Dong Zhuo)
function commentary_events:setup_first_character_executed_trigger(event_key, faction_key)
	core:add_listener(
		event_key, -- Unique handle
		"CharacterCaptiveOptionApplied", -- Campaign Event to listen for
		function(context) -- Criteria
			return context:capturing_force():faction():name() == faction_key and context:captive_option_outcome() == "EXECUTE";
		end,
		function(context) -- What to do if listener fires.
			cdir_events_manager:print("COMMENTARY EVENT - Character Executed [" .. faction_key .. "]");
			self:fire_incident(event_key, faction_key);
		end,
		true --Is persistent
	);
end;

-- First Proxy War (Cao Cao)
function commentary_events:setup_first_proxy_war_trigger(event_key, faction_key)
	core:add_listener(
		event_key, -- Unique handle
		"DiplomacyDealNegotiated", -- Campaign Event to listen for
		function(context) -- Criteria
			return faction_signed_component_in_negotiated_deals(context:deals(), faction_key, "treaty_components_instigate_proxy_war_proposer");
		end,
		function(context) -- What to do if listener fires.
			cdir_events_manager:print("COMMENTARY EVENT - Proxy War [" .. faction_key .. "]");
			self:fire_incident(event_key, faction_key);
		end,
		true --Is persistent
	);
end;

-- First Character Defection - CharacterLeavesFaction
function commentary_events:setup_first_character_leaves_faction_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "CharacterDefectedEvent",
		function(context)
			if not context:query_character():character_type("general") then
				return false;
			end;

			if context:query_character():is_spy() then
				return false;
			end;

			if context:query_character():is_character_is_faction_recruitment_pool() then
				return false;
			end;
			
			if not context:query_character():family_member():come_of_age() then
				return false;
			end;

			if context:from() and not context:from():is_null_interface() then
				return context:from():name() == faction_key;
			end;

			return false;
        end,
		function(context)
			cdir_events_manager:print("COMMENTARY EVENT - Character leaves [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    );
end;

-- First Tech Researched - ResearchCompleted
function commentary_events:setup_first_research_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "ResearchCompleted",
        function(context)
            return context:faction():name() == faction_key
                and context:technology_record_key() ~= "3k_main_tech_precursor";
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - Research completed [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    );
end;

-- First Building Completed - BuildingCompleted 
function commentary_events:setup_first_building_completed_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "BuildingCompleted",
        function(context)
            return context:building():faction():name() == faction_key;
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - Building completed [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    );
end;

-- Faction Leader Died - CharacterDied 
function commentary_events:setup_first_faction_leader_died_trigger(event_key, faction_key)
    core:add_listener(
        event_key,
        "CharacterDied",
        function(context)
            return context:query_character():faction():name() == faction_key
                and context:query_character():is_faction_leader();
        end,
		function()
			cdir_events_manager:print("COMMENTARY EVENT - faction leader died [" .. faction_key .. "]");
            self:fire_incident(event_key, faction_key);
        end,
        true
    );
end;

---------------------------------------------------------------------------------------------------------
----- Utils
---------------------------------------------------------------------------------------------------------

function commentary_events:fire_incident(incident_key, faction_key)
    local modify_model = cm:modify_model();

    if modify_model:is_null_interface() then
        script_error("commentary_events:fire_incident() - Modify Model interface is null.");
        return false;
    end;
	
	local faction = cm:query_faction( faction_key );
	cdir_events_manager:add_prioritised_incidents( faction:command_queue_index(), incident_key );
end;