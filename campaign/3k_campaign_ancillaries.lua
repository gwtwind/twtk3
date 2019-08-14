---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			3k_campaign_ancillaries.lua, 
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to spawn an ancillary on a character when they spawn.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

output("3k_campaign_ancillaries.lua: Loading");

ancillaries = {};

ancillaries.event_battle_won_chance = 5;
ancillaries.event_battle_won_trigger = "3k_main_ceo_trigger_faction_post_battle_ancillaries";
ancillaries.event_settlement_occupied_chance = 10;
ancillaries.event_settlement_occupied_trigger = "3k_main_ceo_trigger_faction_post_battle_ancillaries";

ancillaries.faction_start_min_ancillaries = 2;
ancillaries.faction_start_max_ancillaries = 4;
ancillaries.faction_start_default_trigger = "3k_main_ceo_trigger_faction_starting_ancillaries";
ancillaries.faction_start_trigger_overrides = -- YT have different spawned ancillaries.
{
    ["3k_main_faction_yellow_turban_generic"] = "3k_ytr_ceo_trigger_faction_starting_ancillaries",
    ["3k_main_faction_yellow_turban_anding"] = "3k_ytr_ceo_trigger_faction_starting_ancillaries",
	["3k_main_faction_yellow_turban_rebels"] = "3k_ytr_ceo_trigger_faction_starting_ancillaries",
	["3k_main_faction_yellow_turban_taishan"] = "3k_ytr_ceo_trigger_faction_starting_ancillaries"
}

ancillaries.char_start_ancillaries_default_min = 0;
ancillaries.char_start_ancillaries_default_max = 3;
ancillaries.char_start_ancillaries_ceo_node_to_min_max = -- Only supports wealth atm.
{
    ["3k_main_ceo_node_wealth_01"] = { min = 0, max = 0 },
    ["3k_main_ceo_node_wealth_02"] = { min = 0, max = 0 },
    ["3k_main_ceo_node_wealth_03"] = { min = 0, max = 1 },
    ["3k_main_ceo_node_wealth_04"] = { min = 0, max = 1 },
    ["3k_main_ceo_node_wealth_05"] = { min = 0, max = 1 },
    ["3k_main_ceo_node_wealth_06"] = { min = 1, max = 1 },
    ["3k_main_ceo_node_wealth_07"] = { min = 1, max = 1 },
    ["3k_main_ceo_node_wealth_08"] = { min = 1, max = 2 },
    ["3k_main_ceo_node_wealth_09"] = { min = 1, max = 2 }
};
ancillaries.char_start_ancillaries_class_to_ceo_trigger = -- Change the given item based on the character's class.
{
    ["3k_main_ceo_class_earth"] = "3k_main_ceo_trigger_initial_data_ancillary_starting_equipment_faction_earth_random",
    ["3k_main_ceo_class_fire"] = "3k_main_ceo_trigger_initial_data_ancillary_starting_equipment_faction_fire_random",
    ["3k_main_ceo_class_metal"] = "3k_main_ceo_trigger_initial_data_ancillary_starting_equipment_faction_metal_random",
    ["3k_main_ceo_class_water"] = "3k_main_ceo_trigger_initial_data_ancillary_starting_equipment_faction_water_random",
    ["3k_main_ceo_class_wood"] = "3k_main_ceo_trigger_initial_data_ancillary_starting_equipment_faction_wood_random",
    ["3k_ytr_ceo_class_heaven"] = "3k_ytr_ceo_trigger_initial_data_ancillary_starting_equipment_faction_metal_random",
    ["3k_ytr_ceo_class_land"] = "3k_ytr_ceo_trigger_initial_data_ancillary_starting_equipment_faction_wood_random",
    ["3k_ytr_ceo_class_people"] = "3k_ytr_ceo_trigger_initial_data_ancillary_starting_equipment_faction_water_random";
}
ancillaries.char_start_ancillaries_banned_character_templates = -- Some characters spawn with their own ancillaries already. don't give them anything else!
{
    "3k_main_template_historical_cai_mao_hero_fire",
    "3k_main_template_historical_cao_ang_hero_wood",
    "3k_main_template_historical_cao_cao_hero_earth",
    "3k_main_template_historical_cao_pi_hero_earth",
    "3k_main_template_historical_cao_ren_hero_earth",
    "3k_main_template_historical_chen_gong_hero_water",
    "3k_main_template_historical_cheng_pu_hero_metal",
    "3k_main_template_historical_dian_wei_hero_wood",
    "3k_main_template_historical_dong_zhuo_hero_fire",
    "3k_main_template_historical_gan_ning_hero_fire",
    "3k_main_template_historical_gao_gan_hero_metal",
    "3k_main_template_historical_gongsun_du_hero_metal",
    "3k_main_template_historical_gongsun_zan_hero_fire",
    "3k_main_template_historical_guan_yu_hero_wood",
    "3k_main_template_historical_guo_jia_hero_water",
    "3k_main_template_historical_han_fu_hero_earth",
    "3k_main_template_historical_han_sui_hero_metal",
    "3k_main_template_historical_hua_xiong_hero_fire",
    "3k_main_template_historical_huang_gai_hero_wood",
    "3k_main_template_historical_huang_zhong_hero_metal",
    "3k_main_template_historical_huang_zu_hero_wood",
    "3k_main_template_historical_huangfu_song_hero_metal",
    "3k_main_template_historical_jia_long_hero_metal",
    "3k_main_template_historical_jiang_wei_hero_fire",
    "3k_main_template_historical_kong_rong_hero_water",
    "3k_main_template_historical_kong_zhou_hero_water",
    "3k_main_template_historical_lady_sun_shangxiang_hero_fire",
    "3k_main_template_historical_lady_zheng_jiang_hero_wood",
    "3k_main_template_historical_li_ru_hero_water",
    "3k_main_template_historical_ling_tong_hero_wood",
    "3k_main_template_historical_liu_bei_hero_earth",
    "3k_main_template_historical_liu_biao_hero_earth",
    "3k_main_template_historical_liu_dai_hero_water",
    "3k_main_template_historical_liu_yan_hero_water",
    "3k_main_template_historical_liu_yao_hero_earth",
    "3k_main_template_historical_liu_yu_hero_earth",
    "3k_main_template_historical_liu_zhang_hero_earth",
    "3k_main_template_historical_lu_bu_hero_fire",
    "3k_main_template_historical_lu_fan_hero_water",
    "3k_main_template_historical_lu_meng_hero_metal",
    "3k_main_template_historical_lu_su_hero_water",
    "3k_main_template_historical_lu_xun_hero_water",
    "3k_main_template_historical_ma_chao_hero_fire",
    "3k_main_template_historical_ma_dai_hero_fire",
    "3k_main_template_historical_ma_teng_hero_fire",
    "3k_main_template_historical_mi_zhu_hero_water",
    "3k_main_template_historical_pang_de_hero_wood",
    "3k_main_template_historical_pang_tong_hero_water",
    "3k_main_template_historical_shi_xie_hero_water",
    "3k_main_template_historical_sima_yi_hero_water",
    "3k_main_template_historical_sun_ce_hero_fire",
    "3k_main_template_historical_sun_jian_hero_metal",
    "3k_main_template_historical_sun_qian_hero_water",
    "3k_main_template_historical_sun_quan_hero_earth",
    "3k_main_template_historical_taishi_ci_hero_metal",
    "3k_main_template_historical_tao_qian_hero_water",
    "3k_main_template_historical_wang_lang_hero_earth",
    "3k_main_template_historical_wang_xiu_hero_earth",
    "3k_main_template_historical_wei_yan_hero_fire",
    "3k_main_template_historical_wen_chou_hero_wood",
    "3k_main_template_historical_xiahou_dun_hero_wood",
    "3k_main_template_historical_xiahou_yuan_hero_fire",
    "3k_main_template_historical_xu_chu_hero_wood",
    "3k_main_template_historical_xu_huang_hero_metal",
    "3k_main_template_historical_xu_shu_hero_water",
    "3k_main_template_historical_xun_you_hero_earth",
    "3k_main_template_historical_xun_yu_hero_water",
    "3k_main_template_historical_yan_liang_hero_fire",
    "3k_main_template_historical_yu_jin_hero_metal",
    "3k_main_template_historical_yuan_shao_hero_earth",
    "3k_main_template_historical_yuan_shu_hero_earth",
    "3k_main_template_historical_yue_jin_hero_metal",
    "3k_main_template_historical_zhang_chao_hero_water",
    "3k_main_template_historical_zhang_fei_hero_fire",
    "3k_main_template_historical_zhang_he_hero_fire",
    "3k_main_template_historical_zhang_liao_hero_metal",
    "3k_main_template_historical_zhang_lu_hero_wood",
    "3k_main_template_historical_zhang_yan_hero_wood",
    "3k_main_template_historical_zhang_yang_hero_earth",
    "3k_main_template_historical_zhao_yun_hero_metal",
    "3k_main_template_historical_zhou_tai_hero_fire",
    "3k_main_template_historical_zhou_yu_hero_water",
    "3k_main_template_historical_zhuge_jin_hero_water",
    "3k_main_template_historical_zhuge_liang_hero_water",
    "3k_ytr_template_historical_gong_du_hero_wood",
    "3k_ytr_template_historical_he_man_hero_metal",
    "3k_ytr_template_historical_he_yi_hero_water",
    "3k_ytr_template_historical_huang_shao_hero_metal"
}











---------------------------------------------------------------------------------------------------------
----- Initialise
---------------------------------------------------------------------------------------------------------



function ancillaries:initialise()
    output("3k_campaign_ancillaries.lua: Initialise");

	self:setup_listener_character_starting_ancillaries();

	self:setup_listener_battle_won();
	self:setup_listener_settlement_occupied();
end;


---------------------------------------------------------------------------------------------------------
----- Methods - Faction Starting Ancillaries
---------------------------------------------------------------------------------------------------------

function ancillaries:new_game_faction_starting_ancillaries()
	local all_factions = cm:query_model():world():faction_list();
	
	output("ancillaries:setup_listener_faction_starting_ancillaries(): Giving faction ancillaries.");
	inc_tab();
	
	for i=0, all_factions:num_items() - 1 do
        local query_faction = all_factions:item_at(i);

        if not query_faction or query_faction:is_null_interface() then
            script_error( "ancillaries:new_game_faction_starting_ancillaries() No faction!" );
		elseif not query_faction:is_dead() and query_faction:name() ~= "rebels" then
			
            local modify_faction = cm:modify_faction( query_faction );
            local trigger = self.faction_start_trigger_overrides[query_faction:name()] or self.faction_start_default_trigger; -- use override if we have it, or just use the default.
			local num_ancillaries = math.round(cm:random_number( self.faction_start_max_ancillaries, self.faction_start_min_ancillaries ), 0);
			
            output(query_faction:name() .. " Trigger: " .. trigger .. " Num: " .. num_ancillaries);
            
            if num_ancillaries > 0 then
                for i=1, num_ancillaries do
                	modify_faction:ceo_management():apply_trigger( trigger );
                end;
            end;
        end;
	end;
	
	dec_tab();
end;





--***********************************************************************************************************
--***********************************************************************************************************
-- LISTENERS
--***********************************************************************************************************
--***********************************************************************************************************





--[[ ancillaries:setup_listener_character_starting_ancillaries()
	    Sets up a listener waiting for each character to be created.
]]--
function ancillaries:setup_listener_character_starting_ancillaries()
    output("ancillaries:setup_listener_character_starting_ancillaries(): Adding char created listener.");
    
    core:add_listener(
		"ancillaries_character_created",
		"ActiveCharacterCreated",
		function(context)
			local query_character = context:query_character();

            if not self:is_template_valid_for_starting_ancillaries( query_character:generation_template_key() ) then -- Check they're not on our banned list.
                return false;
            end;

            if not self:is_query_character_able_to_equip_ceos( query_character ) then -- Check that they are valid for ceos.
                return false;
			end;
			
			return true;
		end,
        function(context)
            local query_character = context:query_character();
            local starting_ancillaries = self:get_num_starting_ancillaries( query_character );
			
			if starting_ancillaries then
				output( "ancillaries:setup_listener_character_starting_ancillaries():" .. query_character:generation_template_key() .. " - Num Ancillaries: " .. starting_ancillaries );
				inc_tab();
				for i=1, starting_ancillaries do
					self:create_and_equip_ceo_for_character_starting_ancillaries( query_character );
				end;
				dec_tab();
			end;
        end,
        true
    );
end;


function ancillaries:setup_listener_battle_won()
	core:add_listener(
		"ancillaries_battle_won", -- Unique handle
		"CampaignBattleLoggedEvent", -- Campaign Event to listen for
		function(context) -- Criteria
			return true;
		end,
		function(context) -- What to do if listener fires.
			--Do Stuff Here
			for i = 0, context:log_entry():winning_factions():num_items() - 1 do

				local query_faction = context:log_entry():winning_factions():item_at(i);

				if self:is_query_faction_able_to_have_ceos(query_faction) then

					if cm:roll_random_chance( self.event_battle_won_chance, true ) then						
						cm:modify_model():get_modify_faction( query_faction ):ceo_management():apply_trigger(self.event_battle_won_trigger);
					end;

				end;

			end;
		end,
		true --Is persistent
	);
end;


function ancillaries:setup_listener_settlement_occupied()
	core:add_listener(
		"ancillaries_settlement_occupied", -- Unique handle
		"GarrisonOccupiedEvent", -- Campaign Event to listen for
		function(context) -- Criteria
			return context:query_character() 
				and not context:query_character():is_null_interface() 
				and self:is_query_faction_able_to_have_ceos(context:query_character():faction());
		end,
		function(context) -- What to do if listener fires.
			local query_faction = context:query_character():faction();

			if self:is_query_faction_able_to_have_ceos(query_faction) then

				if cm:roll_random_chance( self.event_settlement_occupied_chance, true ) then						
					cm:modify_model():get_modify_faction( query_faction ):ceo_management():apply_trigger(self.event_settlement_occupied_trigger);
				end;

			end;
		end,
		true --Is persistent
	);
end;





--***********************************************************************************************************
--***********************************************************************************************************
-- METHODS
--***********************************************************************************************************
--***********************************************************************************************************





--[[ ancillaries:create_and_equip_ceo_for_character_starting_ancillaries() 
    Goes through and create an ancillary with listeners. When it spawns it'll grab and equip it to the character.
]]--
function ancillaries:create_and_equip_ceo_for_character_starting_ancillaries( query_character )
    local ceo_key = ""
    local ceo_category_key = ""

    -- ADD SPAWN LISTENERS.
    --output("ancillaries:setup_listener_character_starting_ancillaries(): Adding CEO Created listeners.");
    core:add_listener(
        "ancillaries_character_ceo_added",
        "CharacterCeoAdded",
        true,
        function(context)
            ceo_key = context:ceo():ceo_data_key();
            ceo_category_key = context:ceo():category_key();

            --output("ancillaries:add_ceo_spawn_listeners(): Character CEO Added.");
        end,
        false
    );
    
    core:add_listener(
        "ancillaries_faction_ceo_added",
        "FactionCeoAdded",
        true,
        function(context)
            ceo_key = context:ceo():ceo_data_key();
            ceo_category_key = context:ceo():category_key();

            --output("ancillaries:add_ceo_spawn_listeners(): Faction CEO Added.");
        end,
        false
    );


-- TRIGGER CEOS ON THE FACTION
	local trigger_key = self:get_trigger_for_starting_ancillaries_from_character( query_character );
	
    cm:modify_model():get_modify_faction( query_character:faction() ):ceo_management():apply_trigger(trigger_key);

    
-- REMOVE THE LISTENERS AS THEY HAVE EITHER FIRED OR AREN'T NEEDED NOW
    --output("ancillaries:add_ceo_spawn_listeners(): Removing listeners.");

    core:remove_listener("ancillaries_faction_ceo_added");
    core:remove_listener("ancillaries_character_ceo_added");

-- EQUIP THE CEO ON THE CHARACTE
	if ceo_key == "" or ceo_category_key == "" then
		script_error("Didn't return a CEO!");
	end;
    self:equip_ceo_on_character( query_character, ceo_key, ceo_category_key );
end;


--[[ ancillaries:get_num_starting_ancillaries( query_character )
    Tries to grab a char's wealth trait and give them more/less ancillaries based on that. Otherwise, default = 0-1
]]-- 
function ancillaries:get_num_starting_ancillaries( query_character )

    local min_ancillaries = self.char_start_ancillaries_default_min;
    local max_ancillaries = self.char_start_ancillaries_default_max;
   
	if query_character:is_null_interface() then 
        script_error("traits:should_unlock_personality_trait(): Modify character is null") 
        return false;
    end;

	--Usually means it's a castellan.	
	if not query_character:character_type("general") then
		return false;
	end;

	if not query_character:ceo_management() or query_character:ceo_management():is_null_interface() then
		return false;
	end;

    if query_character:ceo_management():number_of_ceos_equipped_for_category("3k_main_ceo_category_wealth") > 0 then
		local ceo_list = query_character:ceo_management():all_ceos_for_category("3k_main_ceo_category_wealth");
		local ceo_node_key = ceo_list:item_at(0):current_node_key();

        min_ancillaries = self.char_start_ancillaries_ceo_node_to_min_max[ ceo_node_key ].min or min_ancillaries;
		max_ancillaries = self.char_start_ancillaries_ceo_node_to_min_max[ ceo_node_key ].max or max_ancillaries;
		
		output("Using Wealth Trait to get amount - " .. min_ancillaries .. "/".. max_ancillaries);
    end;

    return cm:random_number( max_ancillaries, min_ancillaries );
end;


--[[ ancillaries:get_trigger_for_starting_ancillaries_from_character(query_character)
	    Based on the initial data (top) return the string of the trigger to fire for the character.
]]--
function ancillaries:get_trigger_for_starting_ancillaries_from_character(query_character)
    local class_key = nil;
    local trigger_key = nil;
    
    if query_character:ceo_management():all_ceos_for_category("3k_main_ceo_category_class"):num_items() < 1 then
        script_error( "ancillaries:get_trigger_for_starting_ancillaries_from_character(): Character doesn't have a class ceo. " .. query_character:command_queue_index() );
        return nil;
    end;

    class_key = query_character:ceo_management():all_ceos_for_category("3k_main_ceo_category_class"):item_at(0):ceo_data_key();

    if not self.char_start_ancillaries_class_to_ceo_trigger[class_key] then
        script_error( "ancillaries:get_trigger_for_starting_ancillaries_from_character(): No valid initial trigger found for class. " .. class_key );
    end;

    trigger_key = self.char_start_ancillaries_class_to_ceo_trigger[class_key];

    --output("ancillaries:get_trigger_for_starting_ancillaries_from_character(): Returning trigger for character. " .. trigger_key);
    return trigger_key;
end;

--[[ ancillaries:is_template_valid_for_starting_ancillaries(template_key)
        Check if the template is on our banned list.
]]
function ancillaries:is_template_valid_for_starting_ancillaries(template_key)

    for i=1, #self.char_start_ancillaries_banned_character_templates do
        if self.char_start_ancillaries_banned_character_templates[i] == template_key then
            output("ancillaries:is_template_valid_for_starting_ancillaries(): Character is on banned list. " .. template_key);
            return false;
        end;
    end;

    return true;
end;









--***********************************************************************************************************
--***********************************************************************************************************
-- UTILS
--***********************************************************************************************************
--***********************************************************************************************************




--[[ ancillaries:is_query_character_able_to_equip_ceos(query_character)
	    Generic validation for a query character being valid as we call this a few times.
]]--
function ancillaries:is_query_character_able_to_equip_ceos(query_character)
    if query_character:is_null_interface() then
        script_error("3k_campaign_ancillaries:character created(): Recieved null character interface.");
        return false;
    end;

    -- If character isn't of type general, don't bother.
    if not query_character:character_type("general") then
        return false;
	end;
	
	-- Don't spawn for children.
	if not query_character:family_member():come_of_age() then
		return false;
	end;

    if query_character:is_dead() then
        script_error("3k_campaign_ancillaries:character created(): Character CQI: " .. query_character:command_queue_index() .. " is dead!");
        return false;
    end;
    
    if query_character:ceo_management():is_null_interface() then
        script_error("3k_campaign_ancillaries:character created(): Character CQI: " .. query_character:command_queue_index() .. " has no ceo manager.");
        return false;
    end;

    return true;
end;

function ancillaries:is_query_faction_able_to_have_ceos(query_faction)
	if not query_faction or query_faction:is_null_interface() then
		return false;
	end;

	if query_faction:is_dead() then
		return false;
	end;

	if query_faction:name() == "rebels" then
		return false;
	end;

	if not query_faction:ceo_management() or query_faction:ceo_management():is_null_interface() then
		return false;
	end;

	return true;
end;


--[[ ancillaries:equip_ceo_on_character( query_character, ceo_key, ceo_category_key )
	    Equip the selected ceo key on the selected character if we're able to.
]]--
function ancillaries:equip_ceo_on_character( query_character, ceo_key, ceo_category_key )
    local query_model = cm:query_model();
    local modify_model = cm:modify_model();
    local modify_character = modify_model:get_modify_character(query_character);

    -- Check if they can equip CEOs
    if not self:is_query_character_able_to_equip_ceos( query_character ) then
        output("ancillaries:equip_ceo_on_character(): Can't have ceos")
        return;
    end;
    
    -- Get the equipment slot.
    valid_equipment_slot_for_ceo_category = self:get_valid_slot_for_category(query_character, ceo_category_key);

    if not valid_equipment_slot_for_ceo_category then 
        output("ancillaries:equip_ceo_on_character(): No equip slot found for category. " .. ceo_category_key)
    else
        -- Get an equippable CEO matching the key.
        local query_ceo = self:get_slot_equippable_ceo_from_key(valid_equipment_slot_for_ceo_category, ceo_key);

        if query_ceo then
            output("ancillaries:equip_ceo_on_character(): Equipped ceo. " .. ceo_key);
            modify_character:ceo_management():equip_ceo_in_slot(valid_equipment_slot_for_ceo_category, query_ceo);
        else
            output("ancillaries:equip_ceo_on_character(): No equippable ceo found!" .. ceo_key);
        end;
    end;
end;


--[[ ancillaries:get_valid_slot_for_category(query_character, category_key)
	    Generic validation for a query cvharacter being valid as we cann this a few times.
]]--
function ancillaries:get_valid_slot_for_category(query_character, category_key)
    local ceo_equipment_slots_for_category = query_character:ceo_management():all_ceo_equipment_slots_for_category(category_key);
    local best_slot = nil;

    --output("num slots = " .. ceo_equipment_slots_for_category:num_items());

    for i=0, ceo_equipment_slots_for_category:num_items() - 1 do
        local equipment_slot = ceo_equipment_slots_for_category:item_at(i);

        -- Prefer slots which don't have equipment.
        if equipment_slot:equipped_ceo() then
            --output("ancillaries:get_valid_slot_for_category(): Has Ceo Equipped in slot");
            best_slot = equipment_slot;
        else
            --output("ancillaries:get_valid_slot_for_category(): Found empty valid slot");
            best_slot = equipment_slot;
            break; -- break when we find an empty slot with no equipment in.
        end;
    end;

    if best_slot == nil then
        output("ancillaries:get_valid_slot_for_category(): No valid equip slot found");
    end;

    return best_slot;
end;


--[[ ancillaries:get_slot_equippable_ceo_from_key(query_slot, ceo_key, unequipped_only)
	    Get a ceo which the slot can equip matching a key.
]]--
function ancillaries:get_slot_equippable_ceo_from_key(query_slot, ceo_key, unequipped_only)
    unequipped_only = unequipped_only or false;

    local available_ceos = query_slot:all_equippable_ceos();
    local best_ceo = nil;
    
    for j=0, available_ceos:num_items() - 1 do -- Check each equippable CEO if it can be equipped.
        local query_ceo = available_ceos:item_at(j);
        if query_ceo:ceo_data_key() == ceo_key then
            if query_ceo:is_equipped_in_slot() and not unequipped_only then -- Ignore if we don't want unequipped.
               -- output("ancillaries:get_slot_equippable_ceo_from_key(): Found a matching ceo, but it's equipped.");
                best_ceo = query_ceo;
            else
                --output("ancillaries:get_slot_equippable_ceo_from_key(): Found a matching ceo");
                best_ceo = query_ceo;
                break; -- If we found an uneqipped CEO always prefer than one.
            end;
        end;
    end;

    return best_ceo;
end;