traits.HIGH_KILLS_AMOUNT = 250;
traits.MANY_BATTLES_FOUGHT_AMOUNT = 10;
traits.AGE_OLD = 65;
traits.AGE_YOUNG = 30;
traits.RANK_HIGH = 7;
traits.LOYALTY_HIGH = 70;
traits.LOYALTY_LOW = 15;
traits.MANY_FRIENDS = 4;
traits.MANY_RIVALS = 4;


--***********************************************************************************************************
--***********************************************************************************************************
-- TRIGGER_DATA
--***********************************************************************************************************
--***********************************************************************************************************


--[[ traits:setup_personality_listeners()
	If the num_ceos OR the priority is set to 0 these won't fire.
]]--
function traits:load_trigger_datas()
	local trigger_datas = {
		battle_captive_executed = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_executed_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_executed_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 4 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_executed_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_executed_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_executed_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 2 }
			}
		},
		battle_captive_hired = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_hired_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_hired_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_hired_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_hired_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_hired_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		battle_captive_released = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_released_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 4 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_released_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_released_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_released_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_captive_released_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 3 }
			}
		},
		battle_completed = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 4 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 2 }
			}
		},
		battle_completed_fled = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_fled_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_fled_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_fled_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_fled_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_fled_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		battle_completed_friend_rival_in_force = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_friend_rival_in_force_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_friend_rival_in_force_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_friend_rival_in_force_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_friend_rival_in_force_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_friend_rival_in_force_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		battle_completed_high_personal_kills = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_high_personal_kills_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_high_personal_kills_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 3 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_high_personal_kills_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_high_personal_kills_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_high_personal_kills_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 2 }
			}
		},
		battle_completed_was_ambushed = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_was_ambushed_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_was_ambushed_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_was_ambushed_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_was_ambushed_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_completed_was_ambushed_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		battle_lost = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 4 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		battle_lost_lost_many_battles = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_lost_many_battles_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_lost_many_battles_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_lost_many_battles_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_lost_many_battles_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_lost_lost_many_battles_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		battle_won = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		battle_won_secondary_general = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_secondary_general_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 3 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_secondary_general_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_secondary_general_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_secondary_general_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_secondary_general_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		battle_won_won_many_battles = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_won_many_battles_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_won_many_battles_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_won_many_battles_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_won_many_battles_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_battle_won_won_many_battles_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		captives_ransom = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_captives_ransom_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_ransom_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_ransom_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_ransom_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_ransom_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		captives_recruit = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_captives_recruit_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_recruit_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_recruit_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_recruit_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_recruit_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		captives_seize_supplies = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_captives_seize_supplies_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_seize_supplies_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_seize_supplies_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_seize_supplies_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_captives_seize_supplies_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},		
		round_start = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 3 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 5 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 11 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 6 }
			}
		},
		round_start_governor = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_governor_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 4 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_governor_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 3 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_governor_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_governor_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_governor_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		round_start_high_rank = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_rank_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_rank_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_rank_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_rank_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_rank_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		round_start_high_satisfaction = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_satisfaction_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_satisfaction_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_satisfaction_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 3 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_satisfaction_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_high_satisfaction_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 3 }
			}
		},
		round_start_is_idle = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_is_idle_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_is_idle_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_is_idle_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_is_idle_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_is_idle_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 2 }
			}
		},
		round_start_low_satisfaction = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_low_satisfaction_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_low_satisfaction_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 3 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_low_satisfaction_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_low_satisfaction_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_low_satisfaction_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 2 }
			}
		},
		round_start_many_friends = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_friends_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 4 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_friends_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_friends_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_friends_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_friends_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 2 }
			}
		},
		round_start_many_rivals = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_rivals_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_rivals_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_rivals_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_rivals_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_many_rivals_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		round_start_no_friends = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_no_friends_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_no_friends_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_no_friends_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_no_friends_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_no_friends_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		round_start_old = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_old_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_old_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_old_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_old_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 2 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_old_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		round_start_young = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_round_start_young_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_young_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_young_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_young_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_round_start_young_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		},
		wound_recieved = { 
			priority = 1,
			triggers = {
				{ trigger_key = "3k_ceo_trigger_traits_wound_recieved_earth", element = traits.ATTRIBUTES.ATT_EARTH, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_wound_recieved_fire", element = traits.ATTRIBUTES.ATT_FIRE, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_wound_recieved_metal", element = traits.ATTRIBUTES.ATT_METAL, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_wound_recieved_water", element = traits.ATTRIBUTES.ATT_WATER, num_ceos = 1 },
				{ trigger_key = "3k_ceo_trigger_traits_wound_recieved_wood", element = traits.ATTRIBUTES.ATT_WOOD, num_ceos = 1 }
			}
		}
	};

	return trigger_datas;
end;


--***********************************************************************************************************
--***********************************************************************************************************
-- LISTENERS
--***********************************************************************************************************
--***********************************************************************************************************


--[[ traits:setup_personality_listeners()
]]--
function traits:setup_personality_listeners()
-- BATTLE TRAITS
    core:add_listener(
        "traits_personality_campaign_battle_logged", -- UID
        "CampaignBattleLoggedEvent", -- CampaignEvent
        true, --Conditions for firing -- We get more than one character, so always fire.
		function(context)
			out.traits("3k_campaign_traits.lua: CampaignBattleLoggedEvent" );

			-- Battle Logged
			local log_entry = context:log_entry();
			local pb = context:query_model():pending_battle();

			if not log_entry or log_entry:is_null_interface() then
				script_error("traits:battlelogged(): Log Entry is null");
			end;

			if not pb or pb:is_null_interface() then
				script_error("traits:battlelogged(): Pending Battle is null");
			end;
		
			local winning_chars = log_entry:winning_characters();
			local losing_chars = log_entry:losing_characters();

			-- Attacker Result.
			local attacker_won = false;
			if pb:attacker_battle_result() == log_entry:winner_result() then
				attacker_won = true;
			end;

			-- Go through winning characters.
			for i=0, winning_chars:num_items() - 1 do
				if self:can_unlock_personality_traits( winning_chars:item_at(i):character(), context:modify_model() ) then
					self:on_battle_completed( winning_chars:item_at(i), pb, true, attacker_won );
				end;
			end;
		
			-- Go through losing characters.
			for i=0, losing_chars:num_items() - 1 do
				if self:can_unlock_personality_traits( losing_chars:item_at(i):character(), context:modify_model() ) then
					self:on_battle_completed( losing_chars:item_at(i), pb, false, not attacker_won );
				end;
			end;
        end, -- Function to fire.
        true -- Is Persistent?
	);

	core:add_listener(
		"traits_captive_option_applied", -- Unique handle
		"CharacterCaptiveOptionApplied", -- Campaign Event to listen for
		function(context) -- Criteria
			if not context:capturing_force():has_general() then
				return false;
			end;

			return self:can_unlock_personality_traits( context:capturing_force():general_character(), context:modify_model() );
		end,
		function(context) -- What to do if listener fires.
			out.traits("3k_campaign_traits.lua: CharacterCaptiveOptionApplied" );

			self:on_captive_option_applied( context:capturing_force():general_character(), context:modify_character(), context:captive_option_outcome() );
		end,
		true --Is persistent
	);

	core:add_listener(
		"traits_post_battle_enslave", -- Unique handle
		"CharacterPostBattleEnslave", -- Campaign Event to listen for
		function(context) -- Criteria
			return self:can_unlock_personality_traits( context:query_character(), context:modify_model() );
		end,
		function(context) -- What to do if listener fires.
			out.traits("3k_campaign_traits.lua: CharacterPostBattleEnslave" );
			self:on_post_battle_enslave( context:query_character(), context:modify_character() );
		end,
		true --Is persistent
	);

	core:add_listener(
		"traits_post_battle_release", -- Unique handle
		"CharacterPostBattleRelease", -- Campaign Event to listen for
		function(context) -- Criteria
			return self:can_unlock_personality_traits( context:query_character(), context:modify_model() );
		end,
		function(context) -- What to do if listener fires.
			out.traits("3k_campaign_traits.lua: CharacterPostBattleRelease" );
			self:on_post_battle_release( context:query_character(), context:modify_character() );
		end,
		true --Is persistent
	);

	core:add_listener(
		"traits_post_battle_slaughter", -- Unique handle
		"CharacterPostBattleSlaughter", -- Campaign Event to listen for
		function(context) -- Criteria
			return self:can_unlock_personality_traits( context:query_character(), context:modify_model() );
		end,
		function(context) -- What to do if listener fires.
			out.traits("3k_campaign_traits.lua: CharacterPostBattleSlaughter" );
			self:on_post_battle_slaughter( context:query_character(), context:modify_character() );
		end,
		true --Is persistent
	);


-- DOMESTIC TRAITS
	
	core:add_listener(
		"traits_personality_character_turn_start", -- Unique handle
		"CharacterTurnStart", -- Campaign Event to listen for
		function(context) -- Criteria
			if cm:query_model():turn_number() < 2 then
				return false;
			end;
			
			return self:can_unlock_personality_traits( context:query_character(), context:modify_model() );
		end,
		function(context) -- What to do if listener fires.
			--out.traits("3k_campaign_traits.lua: CharacterTurnStart" );
			self:on_turn_start( context:query_character(), context:modify_character(), context:current_assignment_key() );
		end,
		true --Is persistent
	);

    core:add_listener(
        "traits_personality_character_building_completed", -- UID
        "CharacterBuildingCompleted", -- CampaignEvent
        function(context)
            return self:can_unlock_personality_traits( context:character(), context:modify_model() );
        end, --Conditions for firing
        function(context)
			out.traits("3k_campaign_traits.lua: CharacterBuildingCompleted" );
			local query_character = context:character();
			local modify_character = cm:modify_character(query_character);
			
			self:on_building_constructed( query_character, modify_character )
        end, -- Function to fire.
        true -- Is Persistent?
	);
	
	--CharacterWoundReceivedEvent
	core:add_listener(
		"traits_personality_character_wound_recieved", -- UID
		"CharacterWoundReceivedEvent", -- CampaignEvent
		function(context)
			return self:can_unlock_personality_traits( context:query_character(), context:modify_model() );
		end, --Conditions for firing
		function(context)
			out.traits("3k_campaign_traits.lua: CharacterWoundReceivedEvent" );
			
			self:on_character_wounded( context:query_character(), context:modify_character() );
		end, -- Function to fire.
		true
	);
end;


--[[ traits:setup_physical_listeners()
	Triggers the wound traits of the character
]]--
function traits:setup_physical_listeners()
	-- TODO: Move the wounds system over to using the system for the personality traits!
	
	--CharacterWoundReceivedEvent
	core:add_listener(
		"traits_personality_character_wound_recieved", -- UID
		"CharacterWoundReceivedEvent", -- CampaignEvent
		function(context)
			return self:should_unlock_physical_wound_trait( context:query_character(), context:modify_model() );
		end, --Conditions for firing
		function(context)
			out.traits("3k_campaign_traits.lua: CharacterWoundReceivedEvent" );
			local random_pct = context:modify_model():random_percentage();

			-- Different wounds based on chance.
			if random_pct <= self.physical_chance_of_serious_wound then
				-- Serious
				self:fire_character_ceo_trigger(context:modify_character(), self.trigger_key_trait_physical_negative_serious);
			else
				--Light
				self:fire_character_ceo_trigger(context:modify_character(), self.trigger_key_trait_physical_negative_light);
			end;
		end, -- Function to fire.
		true -- Is Persistent?
	);

end;


--[[ traits:setup_lovestruck_listeners()
    Lovestruck - Used to make a character lovestruck with a commoner, allows a dilemma to fire afterwards.
]]--
function traits:setup_lovestruck_listeners()
    core:add_listener(
        "traits_lovestruck", -- UID
        "CharacterRank", -- CampaignEvent
        true, --Conditions for firing
        function(character_rank_event)
            out.traits("3k_campaign_traits.lua: Granting lovestruck trait" );

            -- Check if they're family members and unmarried
            local query_character = character_rank_event:query_character();
			
			-- Do not fire for yellow turbans
			if query_character:faction():subculture() == "3k_main_subculture_yellow_turban" then
				return false;
			end;

			-- Check they're of age
			if not query_character:family_member():come_of_age() then
				return false;
			end;

			-- Make sure they're not married
            if not query_character:family_member():has_spouse() then
				return false;
			end;
            
			-- Make sure they're a child of the faction leader.
			if query_character:family_member():has_father() and query_character:family_member():father() == query_character:faction():faction_leader():family_member() 
				or query_character:family_member():has_mother() and query_character:family_member():mother() == query_character:faction():faction_leader():family_member() then
					
					-- Do random chance here so it's not as frequent
					if not cm:roll_random_chance(self.chance_of_lovestruck_trait) then
						return false;
					end;

					self:fire_character_ceo_trigger( character_rank_event:modify_character(), self.trigger_key_lovestruck );
			end;

        end, -- Function to fire.
        false -- Is Persistent?
    );
end;


--[[ traits:setup_legendary_listeners()
]]--
function traits:setup_legendary_listeners()
	core:add_listener(
		"traits_legendary", -- Unique handle
		"CharacterTurnStart", -- Campaign Event to listen for
		function(context) -- Criteria
			local query_character = context:query_character();

			if not query_character:character_type("general") then
				return false;
			end;
		
			if not query_character:ceo_management() or query_character:ceo_management():is_null_interface() then
				return false;
			end;
		
			if query_character:is_dead() then
				return false;
			end;

			return true;
		end,
		function(context) -- What to do if listener fires.
			local query_character = context:query_character();
			local modify_character_ceos = context:modify_character():ceo_management();

			-- Get their highest attribute.
			local key, value = self:get_highest_attribute_and_value(query_character);

			-- Check if they have a legendary trait.
			local has_legendary_trait = query_character:ceo_management():number_of_ceos_equipped_for_category("3k_main_ceo_category_potential") > 0;

			-- add a legendary if they are > 100 and don't have it.
			if value >= 100 and not has_legendary_trait then

				local rnd = context:modify_model():random_number(0, 3);

				if rnd < 1 then
					modify_character_ceos:add_ceo("3k_main_ceo_potential_legendary_early");
				elseif rnd < 2 then
					modify_character_ceos:add_ceo("3k_main_ceo_potential_legendary_middle");
				else
					modify_character_ceos:add_ceo("3k_main_ceo_potential_legendary_late");
				end;
				
				out.traits( "traits.lua: Legendary Traits: Character gained legendary trait: " .. tostring( query_character:generation_template_key() ) .. " Attribute, Value:" .. tostring(key) .. ":" .. tostring(value) );

			-- remove the legendary if they're < 100 and have it.
			elseif value < 100 and has_legendary_trait then

				if query_character:ceo_management():has_ceo_equipped("3k_main_ceo_potential_legendary_early") then
					modify_character_ceos:remove_ceos("3k_main_ceo_potential_legendary_early");
				elseif query_character:ceo_management():has_ceo_equipped("3k_main_ceo_potential_legendary_middle") then
					modify_character_ceos:remove_ceos("3k_main_ceo_potential_legendary_middle");
				else
					modify_character_ceos:remove_ceos("3k_main_ceo_potential_legendary_late");
				end;

				out.traits( "traits.lua: Legendary Traits: Character lost legendary trait: " .. tostring( query_character:generation_template_key() ) );

			end;
		end,
		true --Is persistent
	);
end;



--[[ traits:setup_debug_listeners()
]]--
function traits:setup_debug_listeners()

	-- Example: trigger_cli_debug_event traits.give_trait(char_cqi,trait_key)
	core:add_cli_listener( "traits.give_trait", 
        function(character_cqi, trait_key)
            out.traits("traits.give_trait");
            local query_character = cm:query_character(character_cqi);
            local modify_character = cm:modify_character(query_character)

			if query_character and not query_character:is_null_interface() and modify_character and not modify_character:is_null_interface() then
				modify_character:ceo_management():add_ceo(trait_key);
            end;
        end
    );

	-- Example: trigger_cli_debug_event traits.give_physical_trait(char_cqi)
    core:add_cli_listener( "traits.give_physical_trait", 
        function(character_cqi)
            local query_character = cm:query_character(character_cqi);
            local modify_character = cm:modify_character(query_character)

            if query_character and not query_character:is_null_interface() and modify_character and not modify_character:is_null_interface() then
                local random_pct = cm:modify_model():random_percentage();

                out.traits("traits.give_physical_trait: rolled " .. random_pct .. "/" .. self.physical_chance_of_serious_wound);
                -- Different wounds based on chance.
                if random_pct <= self.physical_chance_of_serious_wound then
                else
                end;
            end;
        end
    );

    core:add_cli_listener( "traits.give_lovestruck_trait", 
        function(character_cqi)
            local query_character = cm:query_character(character_cqi);
            local modify_character = cm:modify_character(query_character)

            if query_character and not query_character:is_null_interface() and modify_character and not modify_character:is_null_interface() then
                out.traits("traits.give_physical_trait: fired trigger:" .. self.trigger_key_lovestruck);
                self:fire_character_ceo_trigger( modify_character, self.trigger_key_lovestruck );
            end;
        end
	);

end;



--***********************************************************************************************************
--***********************************************************************************************************
-- EVENTS
--***********************************************************************************************************
--***********************************************************************************************************



--"CharacterTurnStart"
function traits:on_turn_start( query_character, modify_character, current_assignment_key )

	if not query_character or query_character:is_null_interface() then
		script_error("Invalid query character passed in. Exiting.");
		return false;
	end;

	if not modify_character or modify_character:is_null_interface() then
		script_error("Invalid modify character passed in. Exiting.");
		return false;
	end;

	self:add_pending_trigger_data( self.trigger_datas.round_start );

	-- Old Age
	if query_character:age() >= self.AGE_OLD then 
		self:add_pending_trigger_data( self.trigger_datas.round_start_old ); 
	end;

	-- Young
	if query_character:age() <= self.AGE_YOUNG then 
		self:add_pending_trigger_data( self.trigger_datas.round_start_young ); 
	end;

	-- High rank
	if query_character:rank() >= self.RANK_HIGH then 
		self:add_pending_trigger_data( self.trigger_datas.round_start_high_rank ); 
	end;

	-- High Loyalty
	if query_character:loyalty() >= self.LOYALTY_HIGH then 
		self:add_pending_trigger_data( self.trigger_datas.round_start_high_satisfaction ); 
	end;
		
	-- Low Loyalty
	if query_character:loyalty() <= self.LOYALTY_LOW then
		self:add_pending_trigger_data( self.trigger_datas.round_start_low_satisfaction );
	end;

	-- Is Governor
	if query_character:character_post() and not query_character:character_post():is_null_interface() and query_character:character_post():ministerial_position_record_key() == "3k_main_court_offices_governor" then
		self:add_pending_trigger_data( self.trigger_datas.round_start_governor );
	end;

	-- Is idle court noble
	if ( not query_character:character_post() or query_character:character_post():is_null_interface() ) and query_character:active_assignment() and query_character:active_assignment():is_idle_assignment() then
		self:add_pending_trigger_data( self.trigger_datas.round_start_is_idle );
	end;

	-- Many Friends
	if self:get_num_friends( query_character ) >= self.MANY_FRIENDS then
		self:add_pending_trigger_data( self.trigger_datas.round_start_many_friends );
	end;
	
	-- Many Rivals
	if self:get_num_rivals( query_character ) >= self.MANY_RIVALS then
		self:add_pending_trigger_data( self.trigger_datas.round_start_many_rivals );
	end;

	-- No friends
	if query_character:relationships():num_items() < 1 then
		self:add_pending_trigger_data( self.trigger_datas.round_start_no_friends );
	end;

	self:fire_from_pending_trigger_data( modify_character, true );

end;

function traits:on_battle_completed( battle_log_character, pending_battle, won_battle, was_attacker )
	
-- VARIABLES
	local query_character = battle_log_character:character();
	local modify_character = cm:modify_character(query_character);

	local personal_kills = battle_log_character:personal_kills() / cm:query_model():unit_scale_multiplier();
	local was_commander = false;
	local was_secondary_general = false;

	-- We only want to reward people who made it to the end.
	if not query_character:has_military_force() then
		return false;
	end;

	-- Secondary General. Separated, because it may be that the character isn't in their force anymore, and we shouldn't trigger when it's ambiguous.
	if query_character:has_military_force() and query_character:military_force():has_general() then
		was_commander = query_character:military_force():general_character():command_queue_index() == query_character:command_queue_index();
		was_secondary_general = not was_commander;
	end;

-- TRIGGERS
	self:add_pending_trigger_data( self.trigger_datas.battle_completed );

	-- Won Battle
	if won_battle then
		self:add_pending_trigger_data( self.trigger_datas.battle_won );
	end;

	-- Lost Battle
	if not won_battle then
		self:add_pending_trigger_data( self.trigger_datas.battle_lost );
	end;

	-- Secondary general, won battle.
	if won_battle and was_secondary_general then
		self:add_pending_trigger_data( self.trigger_datas.battle_won_secondary_general );
	end;
	
	-- High Num Kills
	if personal_kills >= self.HIGH_KILLS_AMOUNT then
		self:add_pending_trigger_data( self.trigger_datas.battle_completed_high_personal_kills );
	end;

	-- Won many battles
	if query_character:battles_won() >= self.MANY_BATTLES_FOUGHT_AMOUNT then
		self:add_pending_trigger_data( self.trigger_datas.battle_won_won_many_battles );
	end;

	-- Lost many battles
	if query_character:battles_fought() - query_character:battles_won() >= self.MANY_BATTLES_FOUGHT_AMOUNT then
		self:add_pending_trigger_data( self.trigger_datas.battle_lost_lost_many_battles );
	end;

	-- Ran away
	if query_character:routed_in_battle() then
		self:add_pending_trigger_data( self.trigger_datas.battle_completed_fled );
	end;

	-- Was ambushed
	if pending_battle:ambush_battle() and not was_attacker then
		self:add_pending_trigger_data( self.trigger_datas.battle_completed_was_ambushed );
	end;

	-- Friend/Rival in force
	if self:has_friend_in_force( query_character ) or self:has_rival_in_force( query_character ) then
		self:add_pending_trigger_data( self.trigger_datas.battle_completed_friend_rival_in_force );
	end;

	self:fire_from_pending_trigger_data( modify_character, true );
end;

function traits:on_building_constructed( query_character, modify_character )
	out.traits("Building completed event fired. No events!")
end;


function traits:on_captive_option_applied( query_character, modify_character, captive_option_key )

	if captive_option_key == "EMPLOY" then
		self:add_pending_trigger_data( self.trigger_datas.battle_captive_hired );
	elseif captive_option_key == "EXECUTE" then
		self:add_pending_trigger_data( self.trigger_datas.battle_captive_executed );
	else--if captive_option_key == "RELEASE" then
		self:add_pending_trigger_data( self.trigger_datas.battle_captive_released );
	end;

	self:fire_from_pending_trigger_data( modify_character, true );

end;

-- ENSLAVE/RECRUIT
function traits:on_post_battle_enslave( query_character, modify_character )

	self:add_pending_trigger_data( self.trigger_datas.captives_recruit );

	self:fire_from_pending_trigger_data( modify_character, true );

end;

-- SLAUGHTER/SEIZE SUPPLIES
function traits:on_post_battle_slaughter( query_character, modify_character )

	self:add_pending_trigger_data( self.trigger_datas.captives_seize_supplies );

	self:fire_from_pending_trigger_data( modify_character, true );

end;

-- RELEASE/RANSOM
function traits:on_post_battle_release( query_character, modify_character )

	self:add_pending_trigger_data( self.trigger_datas.captives_ransom );

	self:fire_from_pending_trigger_data( modify_character, true );

end;

function traits:on_character_wounded( query_character, modify_character )

	self:add_pending_trigger_data( self.trigger_datas.wound_recieved );

	self:fire_from_pending_trigger_data( modify_character, true );

end;



--***********************************************************************************************************
--***********************************************************************************************************
--HELPERS
--***********************************************************************************************************
--***********************************************************************************************************



function traits:has_friend_in_force( query_character )
	local rels = query_character:relationships();

	if not query_character:has_military_force() then
		return false;
	end;

	for i=0, rels:num_items() - 1 do
		local rel = rels:item_at(i);

		if rel:relationship_record_key() == "3k_main_relationship_positive_02" or rel:relationship_record_key() == "3k_main_relationship_positive_03" then
			local chars = rel:get_relationship_characters();
			for j = 0, chars:num_items() - 1 do
				local other_char = chars:item_at(j);
				if other_char and not other_char:is_null_interface() and other_char:has_military_force() then
					if other_char:command_queue_index() ~= query_character:command_queue_index() then
						if other_char:military_force():command_queue_index() == query_character:military_force():command_queue_index() then
							return true;
						end;
					end;
				end;
			end;
		end;
	end;

	return false;
end;


function traits:has_rival_in_force( query_character )
	local rels = query_character:relationships();

	for i=0, rels:num_items() - 1 do
		local rel = rels:item_at(i);

		if rel:relationship_record_key() == "3k_main_relationship_negative_02" or rel:relationship_record_key() == "3k_main_relationship_negative_03" then
			local chars = rel:get_relationship_characters();
			for j = 0, chars:num_items() - 1 do
				local other_char = chars:item_at(j);
				if other_char and not other_char:is_null_interface() and other_char:has_military_force() then
					if other_char:command_queue_index() ~= query_character:command_queue_index() then
						if other_char:military_force():command_queue_index() == query_character:military_force():command_queue_index() then
							return true;
						end;
					end;
				end;
			end;
		end;
	end;

	return false;
end;

function traits:get_num_rivals( query_character )
	local rels = query_character:relationships();
	local count = 0;

	for i=0, rels:num_items() - 1 do
		local rel = rels:item_at(i);

		if rel:relationship_record_key() == "3k_main_relationship_negative_02" or rel:relationship_record_key() == "3k_main_relationship_negative_03" then
			count = count + 1
		end;
	end;

	return count;
end;


function traits:get_num_friends( query_character )
	local rels = query_character:relationships();
	local count = 0;

	for i=0, rels:num_items() - 1 do
		local rel = rels:item_at(i);

		if rel:relationship_record_key() == "3k_main_relationship_positive_02" or rel:relationship_record_key() == "3k_main_relationship_positive_03" then
			count = count + 1
		end;
	end;

	return count;
end;