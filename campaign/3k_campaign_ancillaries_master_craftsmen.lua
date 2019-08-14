---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Master Crafstmen System
----- Author: 		Simon Mann
----- Description: 	Three Kingdoms system to allow certain buildings to spawn ancillaries to give to their owner.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------
----- Data
---------------------------------------------------------------------------------------------------------
master_craftsmen = 
{
	--[[ Holds all the generic spawning data for the ancillary pools.
	Should NOT be serialsied ]]--
	trigger_data = {
	-- ANIMAL TRAINERS
		["3k_resource_metal_craftsmen_animal_1"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 15,
			rounds_to_trigger_max = 20,
			events = {
				"3k_main_master_craftsmen_animal_trainer_lvl01_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_animal_1",
			ignore_for_yellow_turbans = false
		},
		["3k_resource_metal_craftsmen_animal_2"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 10,
			rounds_to_trigger_max = 15,
			events = {
				"3k_main_master_craftsmen_animal_trainer_lvl02_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_animal_2",
			ignore_for_yellow_turbans = false
		},
		["3k_resource_metal_craftsmen_animal_3"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 5,
			rounds_to_trigger_max = 10,
			events = {
				"3k_main_master_craftsmen_animal_trainer_lvl03_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_animal_3",
			ignore_for_yellow_turbans = false
		},
	
	-- ARMOUR MAKERS
		["3k_resource_metal_craftsmen_armour_1"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 15,
			rounds_to_trigger_max = 20,
			events = {
				"3k_main_master_craftsmen_armourmaker_lvl01_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_armour_1",
			ignore_for_yellow_turbans = true
		},
		["3k_resource_metal_craftsmen_armour_2"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 10,
			rounds_to_trigger_max = 15,
			events = {
				"3k_main_master_craftsmen_armourmaker_lvl02_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_armour_2",
			ignore_for_yellow_turbans = true
		},
		["3k_resource_metal_craftsmen_armour_3"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 5,
			rounds_to_trigger_max = 10,
			events = {
				"3k_main_master_craftsmen_armourmaker_lvl03_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_armour_3",
			ignore_for_yellow_turbans = true
		},
	
	-- WEAPON MASTERS
		["3k_resource_metal_craftsmen_weapon_1"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 15,
			rounds_to_trigger_max = 20,
			events = {
				"3k_main_master_craftsmen_weaponmaster_lvl01_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_weapon_1",
			ignore_for_yellow_turbans = false
		},
		["3k_resource_metal_craftsmen_weapon_2"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 10,
			rounds_to_trigger_max = 15,
			events = {
				"3k_main_master_craftsmen_weaponmaster_lvl02_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_weapon_2",
			ignore_for_yellow_turbans = false
		},
		["3k_resource_metal_craftsmen_weapon_3"] = {
			start_round_min = 2,
			start_round_max = 3,
			rounds_to_trigger_min = 5,
			rounds_to_trigger_max = 10,
			events = {
				"3k_main_master_craftsmen_weaponmaster_lvl03_01_incident_scripted"
			},
			ai_trigger_key = "3k_main_ceo_trigger_craftsmen_weapon_3",
			ignore_for_yellow_turbans = false
		}
	};

	--[[ Holds a list of regions and the last round they spawned an ancillary.
	SHOULD be serialsied!!!
		Formed as = { {name, turns}, {name, turns}, etc. } so it's mp safe when changing.
	]]--
	region_next_trigger_round = {};
};

---------------------------------------------------------------------------------------------------------
----- Initialisers
---------------------------------------------------------------------------------------------------------


--// add_listeners()
--// setup the listeners for the system. This needs to be done super early as LoadGame is called before FirstWorldTick.
function master_craftsmen:add_listeners()
	output("master_craftsmen:add_listeners(): Adding listeners" );

	-- Example: trigger_cli_debug_event master_craftsmen.trigger_update(3k_main_faction_sun_jian, true)
	core:add_cli_listener("master_craftsmen.trigger_update", 
		function(faction_key, ignore_timers)
			ignore_timers = ignore_timers or false; 
			output("master_craftsmen: Debug Trigger update");
			local query_faction = cm:query_faction(faction_key);
			if query_faction then
				self:update( query_faction, ignore_timers );
			end;
		end
	);

	-- Example: trigger_cli_debug_event master_craftsmen.output_trigger_rounds()
	core:add_cli_listener("master_craftsmen.output_trigger_rounds", 
		function()
			output("master_craftsmen: Outputting Trigger rounds.");
			inc_tab();
			for i, v in ipairs(self.region_next_trigger_round) do
				output(i .. " = " .. v[1] .. ", " .. v[2]);
			end;
			dec_tab();
		end
	);

	core:add_listener(
		"master_craftsmen_faction_round_start_listener", -- UID
		"FactionRoundStart", -- Event
		function(faction_round_start_event)
			return self:faction_owns_craftsmen_region( faction_round_start_event:faction() );
		end, --Conditions for firing
		function(faction_round_start_event)
			self:update( faction_round_start_event:faction(), false );
		end, -- Function to fire.
		true -- Is Persistent?
	);

end;


--// initialise()
--// Sets up the system on game load.
function master_craftsmen:initialise()
	output("3k_campaign_master_craftsmen.lua: Initialise()" );

	inc_tab();
	
	output("master_craftsmen:initialise(): Generating Region List" );

	-- Go through every region in the world.
	local region_list = cm:query_model():world():region_manager():region_list();
	for i=0, region_list:num_items() - 1 do
		local region_name = region_list:item_at(i):name();
		local slot_list = region_list:item_at(i):slot_list();

		-- Go through each slot in that region.
		  for j=0, slot_list:num_items() - 1 do
			
			-- If the building is in our list.
			if self:slot_has_valid_building_level(slot_list:item_at(j)) then
				local building_name = slot_list:item_at(j):building():name();
				
				if not self:has_trigger_round(region_name) then
					output("master_craftsmen:update(): Found MC region with no trigger rounds, adding.");
					-- Setup the initial rounds to trigger for buildings already in startpos.
					self:set_initial_trigger_round(building_name, region_name);
				end;
			end;
		end;

    end;

	self:add_listeners();

	dec_tab();
end;


--// update()
--// Goes through all the faction's regions and spawns ancillaries on slots if they exist.
function master_craftsmen:update(query_faction, ignore_timers)
	ignore_timers = ignore_timers or false;

	if query_faction:region_list():num_items() < 1 then
		output("master_craftsmen:update(): Faction has no regions.");
	end;

	
	-- Go through each region the faction owns.
	for i=0, query_faction:region_list():num_items() - 1 do
		local query_region = query_faction:region_list():item_at(i);
		local region_name = query_region:name();

		-- Go through each slot in that region.
		for j=0, query_region:slot_list():num_items() - 1 do
			local query_slot = query_region:slot_list():item_at(j);

			-- Check if the slot is used.
			if query_slot:has_building() then
				local building_name = query_slot:building():name();

				-- If the building is in our list of valid buildings and out subculture isn't banned.
				if self:slot_has_valid_building_level(query_slot, query_faction:subculture()) then
					
					-- If we have a trigger round already for that building. If we don't add a new one.
					-- This is to fix the bug that if it wasn't valid in startpos it'd never spawn as it didn't have a valid timer.
					if not self:has_trigger_round(region_name) then
						output("master_craftsmen:update(): Found MC region with no trigger rounds, adding.");
						self:reset_random_trigger_round(building_name, region_name);
					end;

					-- Check if our timer has elapsed yet
					if self:has_trigger_round_elapsed(query_slot) or ignore_timers then

						-- If it has, try to spawn an ancillary.
						self:give_ancillary_for_building_slot(query_slot);

						-- Reset our trigger round.
						self:reset_random_trigger_round(building_name, region_name);
					end;
				end;
			end;
		end;
	end;
end;



---------------------------------------------------------------------------------------------------------
----- Methods
---------------------------------------------------------------------------------------------------------

--// slot_has_valid_building_level()
--// Works out if the slot has one of the buildings specified in the data.
function master_craftsmen:slot_has_valid_building_level(query_slot, optional_subculture)
	-- Check if the slot is used.
	if not query_slot:has_building() then
		return false;
	end;

	local building_name = query_slot:building():name();

	--output("Testing building name " .. building_name);
	-- Check if the building in the building list.
	for key, value in pairs(self.trigger_data) do
		if building_name == key then

			-- Yellow turban check.
			if optional_subculture and optional_subculture == "3k_main_subculture_yellow_turban" and value.ignore_for_yellow_turbans then
				return false;
			end;

			return true;
		end;
	end;
	
	return false;
end;


--// give_ancillary_for_building_slot()
--// Fires on round start per slot. Means around 334 loops, doing this on RoundStart would involve looping through regions, factions, etc.
function master_craftsmen:give_ancillary_for_building_slot(query_slot)	
	local owning_faction_modify_interface = cm:modify_model():get_modify_faction(query_slot:faction());
	local region_name = query_slot:region():name();
	local current_round = query_slot:model():turn_number();
	local building_name = query_slot:building():name();
	local ceo_trigger_key = self.trigger_data[building_name].ai_trigger_key;

	
	-- Only go further if we have a trigger.
	if string.len(ceo_trigger_key) < 3 then
		self:set_trigger_round(region_name, self:get_trigger_round(region_name) + 1);
		output("master_craftsmen:give_ancillary_for_building_slot(): Slot: " .. region_name .. ", " .. building_name .. ": Not spawning Ancillary as region is desolate. Adding a round.");

	-- If the building is damaged, we add a turn to the timer to prevent players 'missing' their slot.
	elseif query_slot:building():percent_health() < 100 then
		self:set_trigger_round(region_name, self:get_trigger_round(region_name) + 1);
		output("master_craftsmen:give_ancillary_for_building_slot(): " .. region_name .. ", " .. building_name.. ": Not able to fire due to damage. Adding a round");

	else
		--If it's the player, we'll fire a random incident if we have one! For the AI we just give them an ancillary.
		if owning_faction_modify_interface:query_faction():is_human() then
			--output("master_craftsmen:give_ancillary_for_building_slot(): Human faction owns this");
			if #self.trigger_data[building_name].events == 0 then
				script_error("master_craftsmen:give_ancillary_for_building_slot(): No events to fire.");	
				return;
			end;

			-- Pick a random event from our event list.
			local events = self.trigger_data[building_name].events;
			local event_key = self.trigger_data[building_name].events[1];
			if #events > 1 then
				event_key = events[cm:modify_model():random_number(1, #events)];
			end;
			
			output("master_craftsmen:give_ancillary_for_building_slot(): Player Trigger: Slot: " .. region_name .. ", " .. building_name .. ": Triggering event.");
			if not owning_faction_modify_interface:trigger_incident(event_key, true) then
				output("master_craftsmen:give_ancillary_for_building_slot(): Player Trigger: Slot: " .. region_name .. ", " .. building_name .. ": No event triggered!");
				owning_faction_modify_interface:ceo_management():apply_trigger(ceo_trigger_key);
			end;
			
		else
			output("master_craftsmen:give_ancillary_for_building_slot(): AI Trigger: Slot: " .. region_name .. ", " .. building_name .. ": Giving Ancillary from group: " .. ceo_trigger_key);
			owning_faction_modify_interface:ceo_management():apply_trigger(ceo_trigger_key);
		end;
	end;

	
end;


--// faction_owns_craftsmen_region()
--// Checks if the faction owns any spawn regions.
function master_craftsmen:faction_owns_craftsmen_region(query_faction)
	local region_list = query_faction:region_list();

	-- Go through the faction's regions.
	for i=0, region_list:num_items() - 1 do
		local query_region = region_list:item_at(i);
		
		-- Go through the slots in the region.
		for j=0, query_region:slot_list():num_items() - 1 do

			-- Go through our valid keys and test if it matches a building in the region.
			for key, value in pairs(self.trigger_data) do
				if query_region:slot_list():buliding_type_exists(key) then
					return true;
				end;
			end;
		end;
    end;

	return false;
end;



--// has_trigger_round()
--// Checks if the region is valid for spawning.
function master_craftsmen:has_trigger_round(region_name)
	if not region_name then
		script_error("master_craftsmen:has_trigger_round(): Region name is null");
	end;

	-- Check if the slot is a craftsman.
	for i, v in ipairs(self.region_next_trigger_round) do	
		if region_name == v[1] then
			return true;
		end;
	end;

	return false;
end;


--// has_trigger_round_elapsed()
--// Returns true if the Master Craftsmen slot can spawn now.
--// Returns false when the slot if not a master crastsmen slot or cannot fire yet.
function master_craftsmen:has_trigger_round_elapsed(query_slot_interface)
	local building_name = query_slot_interface:building():name();
	local current_round = query_slot_interface:model():turn_number();
	local region_name = query_slot_interface:region():name();
	local owning_faction_name = query_slot_interface:faction():name();

	-- Check if slot has hit its turns required.
	if current_round < self:get_trigger_round(region_name) then
		output("master_craftsmen:has_trigger_round_elapsed(): CANNOT FIRE " .. region_name .. ", " .. building_name.. ", Owner: " .. owning_faction_name .. "- Not able to fire again. Next Round = " .. self:get_trigger_round(region_name).. ", Round = " .. current_round);
		return false;
	end;

	output("master_craftsmen:has_trigger_round_elapsed(): FIRING! " .. region_name .. ", " .. building_name .. ", Owner: " .. owning_faction_name .. ", Next Round = " .. self:get_trigger_round(region_name) .. ", Round = " .. current_round);
	return true;
end;


--// reset_random_trigger_round()
--// Sets the trigger rounds to the values assigned in the data
function master_craftsmen:reset_random_trigger_round(building_name, region_name)
	self:set_random_trigger_round(building_name, region_name, self.trigger_data[building_name].rounds_to_trigger_min, self.trigger_data[building_name].rounds_to_trigger_max);

	output("master_craftsmen:reset_random_trigger_round(): " .. region_name .. ", Building Key:" .. building_name .. ", Next spawn Round: " .. self:get_trigger_round(region_name));
end;

--// set_initial_trigger_round()
--// Sets the trigger rounds to the values assigned in the data
function master_craftsmen:set_initial_trigger_round(building_name, region_name)
	self:set_random_trigger_round(building_name, region_name, self.trigger_data[building_name].start_round_min, self.trigger_data[building_name].start_round_max);

	output("master_craftsmen:set_initial_trigger_round(): " .. region_name .. ", Building Key:" .. building_name .. ", Start Round: " .. self:get_trigger_round(region_name));
end;

--// set_random_trigger_round()
--// Sets the trigger rounds between min and max.
function master_craftsmen:set_random_trigger_round(building_name, region_name, min_rounds, max_rounds)
	-- Work our the next fire round.
	local num_rounds_till_next = min_rounds;

	if min_rounds < max_rounds then
		num_rounds_till_next = cm:modify_model():random_number(min_rounds, max_rounds);
	end;

	num_rounds_till_next = math.round(num_rounds_till_next, 0);

	self:set_trigger_round(region_name, cm:query_model():turn_number() + num_rounds_till_next);
end;


--// set_trigger_round()
--// Sets the trigger round for the region, or adds a new one.
function master_craftsmen:set_trigger_round(region_name, round_to_set)
	if not region_name then
		script_error("master_craftsmen:set_trigger_round(): Region name is null");
	end;

	-- Update existing if we find it.
	for i, v in ipairs(self.region_next_trigger_round) do
		if v[1] == region_name then
			v[2] = round_to_set;
			return;
		end;
	end;

	-- Create new if we didn't
	output("master_craftsmen:set_trigger_round(): Adding new trigger round for region " .. region_name);
	table.insert( self.region_next_trigger_round, {region_name, round_to_set} );
end;


--// get_trigger_round()
--// Gets the trigger round for the region.
function master_craftsmen:get_trigger_round(region_name)
	if not region_name then
		script_error("master_craftsmen:get_trigger_round(): Region name is null");
	end;
	
	-- Update existing if we find it.
	for i, v in ipairs(self.region_next_trigger_round) do
		if v[1] == region_name then
			return v[2];
		end;
	end;

	return false;
end;



---------------------------------------------------------------------------------------------------------
----- SAVE/LOAD
---------------------------------------------------------------------------------------------------------
function master_craftsmen:register_save_load_callbacks()
	cm:add_saving_game_callback(
		function(saving_game_event)
			cm:save_named_value("master_craftsmen_trigger_rounds", self.region_next_trigger_round);
		end
	);


	cm:add_loading_game_callback(
		function(loading_game_event)
			local load_tbl =  cm:load_named_value("master_craftsmen_trigger_rounds", self.region_next_trigger_round);

			self.region_next_trigger_round = load_tbl;
		end
	);
end;

master_craftsmen:register_save_load_callbacks();