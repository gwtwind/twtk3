---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Ancillaries Ambient Spawning
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to allow certain buildings to spawn ancillaries to give to their owner.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
----- Data
---------------------------------------------------------------------------------------------------------
ancillaries_ambient_spawning = {	
	first_turn_to_check = 2; -- So you don't get them straight away or we gate them in.
	turns_between_checks = 1; -- How long before we try and check again.
	chance_of_ancillary = 20; -- Base ancillary chance.
	additional_chance_per_round = 10; -- chance_of_ancillary + (additional_chance_per_round * (current_round - last_round_fired - turns_between_checks))

	-- SERIALISED
	last_round_fired = 1; -- Listen for when we last fired so we can delay and add chance.

	--[[ List of normal buildings annd how much 'weight' they add to different things.
		A building can add to multiple things if they choose to.
		NOT SERIALISED.
	]]--
	building_weights = {
		{ key = "3k_district_artisan_labour_1", category = "metal", weight = 10 },
		{ key = "3k_district_artisan_labour_2", category = "metal", weight = 12 },
		{ key = "3k_district_artisan_labour_3", category = "metal", weight = 14 },
		{ key = "3k_district_artisan_labour_4", category = "metal", weight = 16 },
		{ key = "3k_district_artisan_labour_5", category = "metal", weight = 18 },
		{ key = "3k_district_artisan_mines_4", category = "metal", weight = 16 },
		{ key = "3k_district_artisan_mines_5", category = "metal", weight = 18 },
		{ key = "3k_district_artisan_minting_3", category = "metal", weight = 14 },
		{ key = "3k_district_artisan_minting_4", category = "metal", weight = 16 },
		{ key = "3k_district_artisan_minting_5", category = "metal", weight = 18 },
		{ key = "3k_district_artisan_sun_jian_fealty_1", category = "metal", weight = 10 },
		{ key = "3k_district_artisan_sun_jian_fealty_2", category = "metal", weight = 12 },
		{ key = "3k_district_artisan_sun_jian_fealty_3", category = "metal", weight = 14 },
		{ key = "3k_district_artisan_sun_jian_fealty_4", category = "metal", weight = 16 },
		{ key = "3k_district_artisan_sun_jian_fealty_5", category = "metal", weight = 18 },
		{ key = "3k_district_artisan_workshop_lacquer_5", category = "metal", weight = 18 },
		{ key = "3k_district_artisan_workshop_private_1", category = "metal", weight = 10 },
		{ key = "3k_district_artisan_workshop_private_2", category = "metal", weight = 12 },
		{ key = "3k_district_artisan_workshop_private_3", category = "metal", weight = 14 },
		{ key = "3k_district_artisan_workshop_private_4", category = "metal", weight = 16 },
		{ key = "3k_district_artisan_workshop_private_5", category = "metal", weight = 18 },
		{ key = "3k_district_artisan_workshop_state_1", category = "metal", weight = 10 },
		{ key = "3k_district_artisan_workshop_state_2", category = "metal", weight = 12 },
		{ key = "3k_district_artisan_workshop_state_3", category = "metal", weight = 14 },
		{ key = "3k_district_artisan_workshop_state_4", category = "metal", weight = 16 },
		{ key = "3k_district_artisan_workshop_state_5", category = "metal", weight = 18 },
		{ key = "3k_district_government_administration_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_administration_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_administration_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_administration_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_administration_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_administration_black_mountain_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_administration_black_mountain_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_administration_black_mountain_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_administration_black_mountain_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_administration_black_mountain_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_administration_black_mountain_palace_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_administration_black_mountain_palace_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_administration_black_mountain_palace_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_administration_black_mountain_refuge_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_administration_black_mountain_refuge_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_administration_black_mountain_refuge_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_administration_decadence_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_administration_decadence_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_administration_decadence_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_administration_decadence_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_administration_decadence_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_administration_yuan_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_administration_yuan_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_administration_yuan_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_administration_yuan_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_administration_yuan_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_gongsun_zan_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_gongsun_zan_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_gongsun_zan_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_gongsun_zan_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_gongsun_zan_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_gongsun_zan_hq_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_gongsun_zan_hq_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_law_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_law_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_law_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_law_jade_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_religion_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_religion_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_religion_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_religion_taoist_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_religion_taoist_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_religion_taoist_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_rural_administration_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_rural_administration_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_rural_administration_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_rural_administration_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_rural_administration_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_rural_administration_han_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_rural_administration_han_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_rural_administration_han_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_rural_administration_han_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_rural_administration_han_5", category = "earth", weight = 18 },
		{ key = "3k_district_government_tribute_1", category = "earth", weight = 10 },
		{ key = "3k_district_government_tribute_2", category = "earth", weight = 12 },
		{ key = "3k_district_government_tribute_3", category = "earth", weight = 14 },
		{ key = "3k_district_government_tribute_4", category = "earth", weight = 16 },
		{ key = "3k_district_government_tribute_5", category = "earth", weight = 18 },
		{ key = "3k_district_market_harbour_fish_0", category = "water", weight = 10 },
		{ key = "3k_district_market_harbour_fish_1", category = "water", weight = 12 },
		{ key = "3k_district_market_harbour_fish_2", category = "water", weight = 14 },
		{ key = "3k_district_market_harbour_fish_3", category = "water", weight = 16 },
		{ key = "3k_district_market_harbour_fish_4", category = "water", weight = 18 },
		{ key = "3k_district_market_harbour_fish_5", category = "water", weight = 20 },
		{ key = "3k_district_market_harbour_spice_5", category = "water", weight = 20 },
		{ key = "3k_district_market_harbour_trade_3", category = "water", weight = 16 },
		{ key = "3k_district_market_harbour_trade_4", category = "water", weight = 18 },
		{ key = "3k_district_market_harbour_trade_5", category = "water", weight = 20 },
		{ key = "3k_district_market_inn_1", category = "water_inn", weight = 10 },
		{ key = "3k_district_market_inn_2", category = "water_inn", weight = 12 },
		{ key = "3k_district_market_inn_3", category = "water_inn", weight = 14 },
		{ key = "3k_district_market_inn_4", category = "water_inn", weight = 16 },
		{ key = "3k_district_market_inn_5", category = "water_inn", weight = 18 },
		{ key = "3k_district_market_inn_liu_biao_1", category = "water_inn", weight = 10 },
		{ key = "3k_district_market_inn_liu_biao_2", category = "water_inn", weight = 12 },
		{ key = "3k_district_market_inn_liu_biao_3", category = "water_inn", weight = 14 },
		{ key = "3k_district_market_inn_liu_biao_4", category = "water_inn", weight = 16 },
		{ key = "3k_district_market_inn_liu_biao_5", category = "water_inn", weight = 18 },
		{ key = "3k_district_market_inn_liu_biao_tea_3", category = "water_inn", weight = 14 },
		{ key = "3k_district_market_inn_liu_biao_tea_4", category = "water_inn", weight = 16 },
		{ key = "3k_district_market_inn_liu_biao_tea_5", category = "water_inn", weight = 18 },
		{ key = "3k_district_market_school_1", category = "water_school", weight = 10 },
		{ key = "3k_district_market_school_2", category = "water_school", weight = 12 },
		{ key = "3k_district_market_school_3", category = "water_school", weight = 14 },
		{ key = "3k_district_market_school_4", category = "water_school", weight = 16 },
		{ key = "3k_district_market_school_5", category = "water_school", weight = 18 },
		{ key = "3k_district_market_school_kong_rong_1", category = "water_school", weight = 10 },
		{ key = "3k_district_market_school_kong_rong_2", category = "water_school", weight = 12 },
		{ key = "3k_district_market_school_kong_rong_3", category = "water_school", weight = 14 },
		{ key = "3k_district_market_school_kong_rong_4", category = "water_school", weight = 16 },
		{ key = "3k_district_market_school_kong_rong_5", category = "water_school", weight = 18 },
		{ key = "3k_district_market_school_kong_rong_poetry_4", category = "water_school", weight = 16 },
		{ key = "3k_district_market_school_kong_rong_poetry_5", category = "water_school", weight = 18 },
		{ key = "3k_district_market_silk_trade_5", category = "water", weight = 18 },
		{ key = "3k_district_market_tea_3", category = "water_inn", weight = 14 },
		{ key = "3k_district_market_tea_4", category = "water_inn", weight = 16 },
		{ key = "3k_district_market_tea_5", category = "water_inn", weight = 18 },
		{ key = "3k_district_market_trade_1", category = "water", weight = 10 },
		{ key = "3k_district_market_trade_2", category = "water", weight = 12 },
		{ key = "3k_district_market_trade_3", category = "water", weight = 14 },
		{ key = "3k_district_market_trade_4", category = "water", weight = 16 },
		{ key = "3k_district_market_trade_5", category = "water", weight = 18 },
		{ key = "3k_district_market_trade_port_1", category = "water", weight = 10 },
		{ key = "3k_district_market_trade_port_2", category = "water", weight = 12 },
		{ key = "3k_district_market_trade_port_3", category = "water", weight = 14 },
		{ key = "3k_district_market_trade_port_4", category = "water", weight = 16 },
		{ key = "3k_district_market_trade_port_5", category = "water", weight = 18 },
		{ key = "3k_district_market_trade_security_4", category = "water", weight = 16 },
		{ key = "3k_district_market_trade_security_5", category = "water", weight = 18 },
		{ key = "3k_district_market_trade_security_port_4", category = "water", weight = 16 },
		{ key = "3k_district_market_trade_security_port_5", category = "water", weight = 18 },
		{ key = "3k_district_military_conscription_1", category = "fire", weight = 10 },
		{ key = "3k_district_military_conscription_2", category = "fire", weight = 12 },
		{ key = "3k_district_military_conscription_3", category = "fire", weight = 14 },
		{ key = "3k_district_military_conscription_cao_cao_1", category = "fire", weight = 10 },
		{ key = "3k_district_military_conscription_cao_cao_2", category = "fire", weight = 12 },
		{ key = "3k_district_military_conscription_cao_cao_3", category = "fire", weight = 14 },
		{ key = "3k_district_military_conscription_cao_cao_4", category = "fire", weight = 16 },
		{ key = "3k_district_military_conscription_cao_cao_5", category = "fire", weight = 18 },
		{ key = "3k_district_military_conscription_dong_zhuo_1", category = "fire", weight = 10 },
		{ key = "3k_district_military_conscription_dong_zhuo_2", category = "fire", weight = 12 },
		{ key = "3k_district_military_conscription_dong_zhuo_3", category = "fire", weight = 14 },
		{ key = "3k_district_military_conscription_dong_zhuo_4", category = "fire", weight = 16 },
		{ key = "3k_district_military_conscription_dong_zhuo_5", category = "fire", weight = 18 },
		{ key = "3k_district_military_equipment_1", category = "fire", weight = 10 },
		{ key = "3k_district_military_equipment_2", category = "fire", weight = 12 },
		{ key = "3k_district_military_equipment_armour_3", category = "fire_armours", weight = 14 },
		{ key = "3k_district_military_equipment_ranged_3", category = "fire", weight = 14 },
		{ key = "3k_district_military_equipment_weapons_3", category = "fire_weapons", weight = 14 },
		{ key = "3k_district_military_security_1", category = "fire", weight = 10 },
		{ key = "3k_district_military_security_2", category = "fire", weight = 12 },
		{ key = "3k_district_military_security_capital_3", category = "fire", weight = 14 },
		{ key = "3k_district_military_security_capital_4", category = "fire", weight = 16 },
		{ key = "3k_district_military_security_capital_5", category = "fire", weight = 18 },
		{ key = "3k_district_military_security_ma_teng_1", category = "fire", weight = 10 },
		{ key = "3k_district_military_security_ma_teng_2", category = "fire", weight = 12 },
		{ key = "3k_district_military_security_ma_teng_3", category = "fire", weight = 14 },
		{ key = "3k_district_military_security_ma_teng_4", category = "fire", weight = 16 },
		{ key = "3k_district_military_security_ma_teng_5", category = "fire", weight = 18 },
		{ key = "3k_district_military_security_province_3", category = "fire", weight = 14 },
		{ key = "3k_district_military_security_province_4", category = "fire", weight = 16 },
		{ key = "3k_district_military_security_province_5", category = "fire", weight = 18 },
		{ key = "3k_district_military_security_province_northern_horses_5", category = "fire", weight = 18 },
		{ key = "3k_district_residential_bandits_1", category = "wood", weight = 10 },
		{ key = "3k_district_residential_bandits_2", category = "wood", weight = 12 },
		{ key = "3k_district_residential_bandits_3", category = "wood", weight = 14 },
		{ key = "3k_district_residential_bandits_4", category = "wood", weight = 16 },
		{ key = "3k_district_residential_bandits_5", category = "wood", weight = 18 },
		{ key = "3k_district_residential_government_support_1", category = "wood", weight = 10 },
		{ key = "3k_district_residential_government_support_2", category = "wood", weight = 12 },
		{ key = "3k_district_residential_government_support_3", category = "wood", weight = 14 },
		{ key = "3k_district_residential_government_support_4", category = "wood", weight = 16 },
		{ key = "3k_district_residential_government_support_5", category = "wood", weight = 18 },
		{ key = "3k_district_residential_government_tools_3", category = "wood", weight = 14 },
		{ key = "3k_district_residential_government_tools_4", category = "wood", weight = 16 },
		{ key = "3k_district_residential_government_tools_5", category = "wood", weight = 18 },
		{ key = "3k_district_residential_landlords_1", category = "wood", weight = 10 },
		{ key = "3k_district_residential_landlords_2", category = "wood", weight = 12 },
		{ key = "3k_district_residential_landlords_3", category = "wood", weight = 14 },
		{ key = "3k_district_residential_landlords_4", category = "wood", weight = 16 },
		{ key = "3k_district_residential_landlords_5", category = "wood", weight = 18 },
		{ key = "3k_district_residential_livestock_market_5", category = "wood", weight = 18 },
		{ key = "3k_district_residential_logistics_1", category = "wood", weight = 10 },
		{ key = "3k_district_residential_logistics_2", category = "wood", weight = 12 },
		{ key = "3k_district_residential_logistics_3", category = "wood", weight = 14 },
		{ key = "3k_district_residential_logistics_4", category = "wood", weight = 16 },
		{ key = "3k_district_residential_logistics_5", category = "wood", weight = 18 },
		{ key = "3k_district_residential_market_3", category = "wood", weight = 14 },
		{ key = "3k_district_residential_market_4", category = "wood", weight = 16 },
		{ key = "3k_district_residential_market_5", category = "wood", weight = 18 },
		{ key = "3k_ytr_district_artisan_artisan_workshops_yellow_turban_1", category = "metal", weight = 10 },
		{ key = "3k_ytr_district_artisan_artisan_workshops_yellow_turban_2", category = "metal", weight = 12 },
		{ key = "3k_ytr_district_artisan_artisan_workshops_yellow_turban_3", category = "metal", weight = 14 },
		{ key = "3k_ytr_district_artisan_artisan_workshops_yellow_turban_4", category = "metal", weight = 16 },
		{ key = "3k_ytr_district_artisan_artisan_workshops_yellow_turban_5", category = "metal", weight = 18 },
		{ key = "3k_ytr_district_artisan_manufacturing_workshops_yellow_turban_1", category = "metal", weight = 10 },
		{ key = "3k_ytr_district_artisan_manufacturing_workshops_yellow_turban_2", category = "metal", weight = 12 },
		{ key = "3k_ytr_district_artisan_manufacturing_workshops_yellow_turban_3", category = "metal", weight = 14 },
		{ key = "3k_ytr_district_artisan_manufacturing_workshops_yellow_turban_4", category = "metal", weight = 16 },
		{ key = "3k_ytr_district_artisan_manufacturing_workshops_yellow_turban_5", category = "metal", weight = 18 },
		{ key = "3k_ytr_district_government_organisation_yellow_turban_1", category = "earth", weight = 10 },
		{ key = "3k_ytr_district_government_organisation_yellow_turban_2", category = "earth", weight = 12 },
		{ key = "3k_ytr_district_government_organisation_yellow_turban_3", category = "earth", weight = 14 },
		{ key = "3k_ytr_district_government_organisation_yellow_turban_4", category = "earth", weight = 16 },
		{ key = "3k_ytr_district_government_organisation_yellow_turban_5", category = "earth", weight = 18 },
		{ key = "3k_ytr_district_government_religion_yellow_turban_1", category = "earth", weight = 10 },
		{ key = "3k_ytr_district_government_religion_yellow_turban_2", category = "earth", weight = 12 },
		{ key = "3k_ytr_district_government_religion_yellow_turban_3", category = "earth", weight = 14 },
		{ key = "3k_ytr_district_government_rural_healers_1", category = "earth", weight = 10 },
		{ key = "3k_ytr_district_government_rural_healers_2", category = "earth", weight = 12 },
		{ key = "3k_ytr_district_government_rural_healers_3", category = "earth", weight = 14 },
		{ key = "3k_ytr_district_government_rural_healers_4", category = "earth", weight = 16 },
		{ key = "3k_ytr_district_government_rural_healers_5", category = "earth", weight = 18 },
		{ key = "3k_ytr_district_government_scholars_yellow_turban_1", category = "earth", weight = 10 },
		{ key = "3k_ytr_district_government_scholars_yellow_turban_2", category = "earth", weight = 12 },
		{ key = "3k_ytr_district_government_scholars_yellow_turban_3", category = "earth", weight = 14 },
		{ key = "3k_ytr_district_government_scholars_yellow_turban_4", category = "earth", weight = 16 },
		{ key = "3k_ytr_district_government_scholars_yellow_turban_5", category = "earth", weight = 18 },
		{ key = "3k_ytr_district_government_yellow_turban_gardens_1", category = "earth", weight = 10 },
		{ key = "3k_ytr_district_government_yellow_turban_gardens_2", category = "earth", weight = 12 },
		{ key = "3k_ytr_district_government_yellow_turban_gardens_3", category = "earth", weight = 14 },
		{ key = "3k_ytr_district_government_yellow_turban_gardens_4", category = "earth", weight = 16 },
		{ key = "3k_ytr_district_government_yellow_turban_gardens_5", category = "earth", weight = 18 },
		{ key = "3k_ytr_district_labour_housing_yellow_turban_1", category = "metal", weight = 10 },
		{ key = "3k_ytr_district_labour_housing_yellow_turban_2", category = "metal", weight = 12 },
		{ key = "3k_ytr_district_labour_housing_yellow_turban_3", category = "metal", weight = 14 },
		{ key = "3k_ytr_district_labour_housing_yellow_turban_4", category = "metal", weight = 16 },
		{ key = "3k_ytr_district_labour_housing_yellow_turban_5", category = "metal", weight = 18 },
		{ key = "3k_ytr_district_market_inn_yellow_turban_1", category = "water", weight = 10 },
		{ key = "3k_ytr_district_market_inn_yellow_turban_2", category = "water", weight = 12 },
		{ key = "3k_ytr_district_market_inn_yellow_turban_3", category = "water", weight = 14 },
		{ key = "3k_ytr_district_market_inn_yellow_turban_4", category = "water", weight = 16 },
		{ key = "3k_ytr_district_market_inn_yellow_turban_5", category = "water", weight = 18 },
		{ key = "3k_ytr_district_market_trade_port_yellow_turban_1", category = "water", weight = 10 },
		{ key = "3k_ytr_district_market_trade_port_yellow_turban_2", category = "water", weight = 12 },
		{ key = "3k_ytr_district_market_trade_port_yellow_turban_3", category = "water", weight = 14 },
		{ key = "3k_ytr_district_market_trade_port_yellow_turban_4", category = "water", weight = 16 },
		{ key = "3k_ytr_district_market_trade_port_yellow_turban_5", category = "water", weight = 18 },
		{ key = "3k_ytr_district_market_trade_security_yellow_turban_4", category = "water", weight = 16 },
		{ key = "3k_ytr_district_market_trade_security_yellow_turban_5", category = "water", weight = 18 },
		{ key = "3k_ytr_district_market_trade_yellow_turban_1", category = "water", weight = 10 },
		{ key = "3k_ytr_district_market_trade_yellow_turban_2", category = "water", weight = 12 },
		{ key = "3k_ytr_district_market_trade_yellow_turban_3", category = "water", weight = 14 },
		{ key = "3k_ytr_district_market_trade_yellow_turban_4", category = "water", weight = 16 },
		{ key = "3k_ytr_district_market_trade_yellow_turban_5", category = "water", weight = 18 },
		{ key = "3k_ytr_district_military_conscription_yellow_turban_1", category = "fire", weight = 10 },
		{ key = "3k_ytr_district_military_conscription_yellow_turban_2", category = "fire", weight = 12 },
		{ key = "3k_ytr_district_military_conscription_yellow_turban_3", category = "fire", weight = 14 },
		{ key = "3k_ytr_district_military_equipment_yellow_turban_1", category = "fire", weight = 10 },
		{ key = "3k_ytr_district_military_equipment_yellow_turban_2", category = "fire", weight = 12 },
		{ key = "3k_ytr_district_military_security_yellow_turban_1", category = "fire", weight = 10 },
		{ key = "3k_ytr_district_military_security_yellow_turban_2", category = "fire", weight = 12 },
		{ key = "3k_ytr_district_military_security_yellow_turban_3", category = "fire", weight = 14 },
		{ key = "3k_ytr_district_military_security_yellow_turban_4", category = "fire", weight = 16 },
		{ key = "3k_ytr_district_military_security_yellow_turban_5", category = "fire", weight = 18 },
		{ key = "3k_ytr_district_military_yellow_turban_caches_1", category = "fire", weight = 10 },
		{ key = "3k_ytr_district_military_yellow_turban_caches_2", category = "fire", weight = 12 },
		{ key = "3k_ytr_district_military_yellow_turban_caches_3", category = "fire", weight = 14 },
		{ key = "3k_ytr_district_military_yellow_turban_caches_4", category = "fire", weight = 16 },
		{ key = "3k_ytr_district_military_yellow_turban_caches_5", category = "fire", weight = 18 },
		{ key = "3k_ytr_district_residential_farming_yellow_turban_1", category = "wood", weight = 10 },
		{ key = "3k_ytr_district_residential_farming_yellow_turban_2", category = "wood", weight = 12 },
		{ key = "3k_ytr_district_residential_farming_yellow_turban_3", category = "wood", weight = 14 },
		{ key = "3k_ytr_district_residential_farming_yellow_turban_4", category = "wood", weight = 16 },
		{ key = "3k_ytr_district_residential_farming_yellow_turban_5", category = "wood", weight = 18 },
		{ key = "3k_ytr_district_residential_housing_yellow_turban_1", category = "wood", weight = 10 },
		{ key = "3k_ytr_district_residential_housing_yellow_turban_2", category = "wood", weight = 12 },
		{ key = "3k_ytr_district_residential_housing_yellow_turban_3", category = "wood", weight = 14 },
		{ key = "3k_ytr_district_residential_housing_yellow_turban_4", category = "wood", weight = 16 },
		{ key = "3k_ytr_district_residential_housing_yellow_turban_5", category = "wood", weight = 18 }			
	};
	
	--[[ List of categories.
		Categories are a link to a ceo trigger key.
	]]--
	categories = {
		["metal"] = "3k_main_ceo_trigger_faction_building_ancillaries_metal",
		["earth"] = "3k_main_ceo_trigger_faction_building_ancillaries_earth",
		["water"] = "3k_main_ceo_trigger_faction_building_ancillaries_water",
		["water_school"] = "3k_main_ceo_trigger_faction_building_ancillaries_water_school",
		["fire"] = "3k_main_ceo_trigger_faction_building_ancillaries_fire",
		["fire_weapons"] = "3k_main_ceo_trigger_faction_building_ancillaries_fire_weapons",
		["fire_armours"] = "3k_main_ceo_trigger_faction_building_ancillaries_fire_armours",
		["water_inn"] = "3k_main_ceo_trigger_faction_building_ancillaries_water_inn",
		["wood"] = "3k_main_ceo_trigger_faction_building_ancillaries_wood"
	};
};


---------------------------------------------------------------------------------------------------------
----- Initialisers
---------------------------------------------------------------------------------------------------------

--// initialise()
--// Sets up the system on game load.
function ancillaries_ambient_spawning:initialise()
	output("3k_campaign_ancillaries_ambient_spawning.lua: Initialise()" );

	self:add_listeners();

	dec_tab();
end;


--// add_listeners()
--// setup the listeners for the system. This needs to be done super early as LoadGame is called before FirstWorldTick.
function ancillaries_ambient_spawning:add_listeners()
	output("ancillaries_ambient_spawning:add_listeners(): Adding listeners" );

	-- Example: trigger_cli_debug_event ancillaries.force_update()
	core:add_cli_listener("ancillaries.force_update", 
		function(faction_key)
			ignore_timers = ignore_timers or false; 
			output("ancillaries_ambient_spawning: force_update");
			local query_faction = cm:query_faction(faction_key);
			if query_faction then
				self:update( query_faction, true );
			end;
		end
	);

	core:add_listener(
		"ambient_faction_round_start_listener", -- UID
		"FactionRoundStart", -- Event
		true, --Conditions for firing
		function(faction_round_start_event)
			self:update( faction_round_start_event:faction() );
		end, -- Function to fire.
		true -- Is Persistent?
	);
end;


--// ancillaries_ambient_spawning:update_ambient_spawning()
--// Works out if the slot has one of the buildings specified in the data.
function ancillaries_ambient_spawning:update( query_faction, force )
	force = force or false;
	local current_turn = cm:query_model():turn_number();

	local active_category_list = self:get_categories_and_weightings_for_faction( query_faction );

	if #active_category_list < 1 then
		return;
	end;

	--[[ DEBUG OUTPUT
	output( "ancillaries_ambient_spawning:update(): Updating for faction " .. query_faction:name() );
	inc_tab();

	output("category_values:");
	inc_tab();
	for cat_key, cat_value in ipairs( active_category_list ) do
		output(cat_value[1] .. " = " .. cat_value[2]);
	end;
	dec_tab();
	 ]]--
	 
	-- Check for things like num rounds passed, roll random chance of spawn etc.
	if self:can_spawn( current_turn, force ) then
		local sum_weights = 0;
		local modify_faction = cm:modify_faction( query_faction, true );

		-- get sum weighting
		for cat_key, cat_value in ipairs( active_category_list ) do
			sum_weights = sum_weights + cat_value[2];
		end;

		-- roll random
		local rolled_value = cm:random_number( sum_weights, 0 );
		local current_value = 0;

		-- Do a weighted random on all the categories we got.
		for cat_key, cat_value in ipairs( active_category_list ) do
			current_value = current_value + cat_value[2];
			if rolled_value <= current_value then
				local trigger = self.categories[cat_value[1]];
				-- SPAWN HERE
				output( "Selected: " .. tostring(cat_key) .. "." .. cat_value[1] .. " with weight " .. cat_value[2] .. " / " .. sum_weights .. "random no = " .. rolled_value );
				output( "Trigger: " .. trigger );
				
				modify_faction:ceo_management():apply_trigger( trigger );
				self.last_round_fired = current_turn; -- Make sure to increment the current turn.
				break;
			end;
		end;
	end;

	dec_tab();
end;



---------------------------------------------------------------------------------------------------------
----- Methods
---------------------------------------------------------------------------------------------------------


--// ancillaries_ambient_spawning:get_categories_and_weightings_for_faction( query_faction )
--// Get all categories which this faction has with their ratings.
function ancillaries_ambient_spawning:get_categories_and_weightings_for_faction( query_faction )
	-- Get categories by sum weighting.
	-- formed as an ipairs so it's mp safe.
	local active_category_list = {};

	-- go through all the regions and check for the buildings.
	local region_list = query_faction:region_list();
	if region_list:num_items() > 0 then -- Early exit if regionless
		for i = 0, region_list:num_items() - 1 do -- Go through all the faction's regions
			local region = region_list:item_at(i)
			
			-- go through all our buildings
			for k, v in ipairs( self.building_weights ) do

				if region:building_exists( v.key ) then -- Only progress if the building exists.
					local cat_exists = false;

					for cat_key, cat_value in ipairs( active_category_list ) do
						if v.category == cat_value[1] then
							--output("get_categories_and_weightings_for_faction(): Found existing cat " .. v.category);
							cat_value[2] = cat_value[2] + v.weight;
							cat_exists = true;
							break;
						end;
					end;

					if not cat_exists then
						--output("get_categories_and_weightings_for_faction(): Adding new cat " .. v.category);
						table.insert( active_category_list, { v.category, v.weight } );
					end;

				end;
			end;
		end;
	end;

	return active_category_list;
end;


--// ancillaries_ambient_spawning:can_spawn()
--// Check if the faction spawned an ancillary or not.
function ancillaries_ambient_spawning:can_spawn( current_turn, force )

	-- Force this
	if force then
		return true;
	end;

	-- Ignore till first turn.
	if current_turn < self.first_turn_to_check then
		return false;
	end;

	-- Check enough turns have elpased.
	if current_turn < self.last_round_fired + self.turns_between_checks then
		return false;
	end;

	-- Roll a random to work out if we spawn.
	local chance = self.chance_of_ancillary;
	chance = chance + ( ( current_turn - self.last_round_fired ) * self.additional_chance_per_round );
	if not cm:roll_random_chance( chance, true ) then
		return false;
	end;

	return true;
end;


---------------------------------------------------------------------------------------------------------
----- SAVE/LOAD
---------------------------------------------------------------------------------------------------------
function ancillaries_ambient_spawning:register_save_load_callbacks()
	cm:add_saving_game_callback(
		function(saving_game_event)
			cm:save_named_value("ancillaries_ambient_spawning_last_round_fired", self.last_round_fired);
		end
	);


	cm:add_loading_game_callback(
		function(loading_game_event)
			local load_tbl =  cm:load_named_value("ancillaries_ambient_spawning_last_round_fired", self.last_round_fired);

			self.last_round_fired = load_tbl;
		end
	);
end;

ancillaries_ambient_spawning:register_save_load_callbacks();