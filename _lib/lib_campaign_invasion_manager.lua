--------------------------------------------------------------------------
---- Invasion Manager ----------------------------------------------------
--------------------------------------------------------------------------
---- Used to create and manage scripted A.I invasions in the campaign ----
--------------------------------------------------------------------------

-- Example Usage:
--
-- 1) Create the manager
-- local im = invasion_manager;
--
-- 2) Add a spawn location (optional, can be specified implicitly per invasion)
-- im:new_spawn_location("my_spawn", 55, 44);
--
-- 3) Add a new invasion
-- im:new_invasion("my_invasion", "invader_faction", "unit1,unit2,unit3", "my_spawn");
--
-- 4) Optional: Set a target for this invasion as a region, specify target type, target key and the intended enemy faction
-- im:invasions["my_invasion"]:set_target("REGION", "altdorf_region", "target_faction_key");
--		Target Types are: REGION, CHARACTER, LOCATION, PATROL
--
-- 5) Start the invasion!
-- im:invasions["my_invasion"]:start_invasion();


---------------------
---- Definitions ----
---------------------
invasion_manager = {
	invasions = {}
};
im_spawn_locations = {};
invasion = {};

-----------------------------------------------------
---- Adds a new invasion to the invasion manager ----
-----------------------------------------------------
function invasion_manager:new_invasion(key, faction_key, force_list, spawn_location)
	output("Invasion Manager: New Invasion '"..tostring(key).."'...");
	output("\tFaction: "..tostring(faction_key));
	output("\tForce: "..tostring(force_list));
	output("\tSpawn: "..tostring(spawn_location));
	
	if self.invasions[key] ~= nil then
		script_error("ERROR: Attempted to create an invasion with a key that already exists!");
		return nil;
	end

	local new_invasion = invasion:new();
	new_invasion.key = key;
	new_invasion.faction = faction_key;
	new_invasion.general_cqi = nil;
	new_invasion.force_cqi = nil;
	new_invasion.unit_list = force_list;
	new_invasion.spawn = self:parse_spawn_location(spawn_location);
	new_invasion.target_type = "NONE";
	new_invasion.target = nil;
	new_invasion.target_faction = nil;
	new_invasion.effect = nil;
	new_invasion.effect_turns = nil;
	new_invasion.turn_spawned = nil;
	new_invasion.started = false;
	new_invasion.stop_at_end = false;
	new_invasion.patrol_position = nil;
	new_invasion.callback = nil;
	new_invasion.prespawned = false;
	
	self.invasions[key] = new_invasion;
	output("\tInvasion Created!");
	return new_invasion;
end

------------------------------------------------------------------------------------
---- Adds a new invasion to the invasion manager created from an existing force ----
------------------------------------------------------------------------------------
function invasion_manager:new_invasion_from_existing_force(key, force)
	output("Invasion Manager: New Invasion from existing force'"..tostring(key).."'...");
	output("\tForce: "..tostring(force));
	
	if self.invasions[key] ~= nil then
		script_error("ERROR: Attempted to create an invasion with a key that already exists!");
		return nil;
	end

	local new_invasion = invasion:new();
	new_invasion.key = key;
	new_invasion.faction = force:faction():name();
	new_invasion.general_cqi = force:general_character():command_queue_index();
	new_invasion.force_cqi = force:command_queue_index();
	new_invasion.unit_list = nil;
	new_invasion.spawn = nil;
	new_invasion.target_type = "NONE";
	new_invasion.target = nil;
	new_invasion.target_faction = nil;
	new_invasion.effect = nil;
	new_invasion.effect_turns = nil;
	new_invasion.turn_spawned = nil;
	new_invasion.started = false;
	new_invasion.stop_at_end = false;
	new_invasion.patrol_position = nil;
	new_invasion.callback = nil;
	new_invasion.prespawned = true;
	
	self.invasions[key] = new_invasion;
	output("\tInvasion Created!");
	return new_invasion;
end

------------------------------------------------------------
---- Create a new spawn location that can be used later ----
------------------------------------------------------------
function invasion_manager:new_spawn_location(key, x, y)
	local spawn = {};
	spawn.x = x;
	spawn.y = y;
	im_spawn_locations[key] = spawn;
end

--------------------------------------------------------------------------------
---- Allows parsing of arbitrary spawn location data into a relevant format ----
--------------------------------------------------------------------------------
function invasion_manager:parse_spawn_location(spawn_location)
	output("Invasion Manager: Parsing a Spawn Location of '"..tostring(spawn_location).."'");
	
	local cm = get_cm();
	
	local return_val = nil;
	
	if type(spawn_location) == "table" then
		-- Assume it's an X/Y coordinate table
		return_val = {x = spawn_location.x or spawn_location[1], y = spawn_location.y or spawn_location[2]};		
	elseif type(spawn_location) == "string" then
		-- Assume it's a predetermined location key
		for key, value in pairs(im_spawn_locations) do
			if spawn_location == key then
				return_val = {x = value.x, y = value.y};
			end
		end
	elseif not spawn_location then
		-- If no spawn location is supplied, pick a random one
		local size = 0;
		for key, value in pairs(im_spawn_locations) do
			size = size + 1;
		end
		
		-- Pick a random record based on the size
		local index = cm:random_number(size);
		local count = 0;
		
		for key, value in pairs(im_spawn_locations) do
			count = count + 1;
			
			if count == index then
				local chosen_x = value.x;
				local chosen_y = value.y;
				
				if self:is_valid_position(chosen_x, chosen_y) then
					return_val = {x = chosen_x, y = chosen_y};
				else
					script_error("ERROR: Parse_Spawn_Location() called but failed as a character is standing at ccoordinates ["..tostring(spawn_location).."]");
				end
				break;
			end
		end
	end
	
	if return_val then
		return return_val;
	else
		script_error("ERROR: Parse_Spawn_Location() called but failed to find coordinates ["..tostring(spawn_location).."]");
	end
end

-----------------------------------------------------------------------------------------------
---- Validates a set of coordinates by testing if a character is standing at that location ----
-----------------------------------------------------------------------------------------------
function invasion_manager:is_valid_position(x, y)
	local cm = get_cm();
	local faction_list = cm:query_model():world():faction_list();
	
	for i = 0, faction_list:num_items() - 1 do
		local faction = faction_list:item_at(i);
		local char_list = faction:character_list();

		for i = 0, char_list:num_items() - 1 do
			local character = char_list:item_at(i);
			
			if character:logical_position_x() == x and character:logical_position_y() == y then
				return false;
			end
		end
	end
	return true;
end

-------------------------------------------------------
---- Removes an invasion from the invasion manager ----
-------------------------------------------------------
function invasion_manager:remove_invasion(key)
	if key ~= nil then
		output("Invasion Manager: Removing Invasion '"..key.."'");
		self.invasions[key] = nil;
		core:remove_listener("INVASION_"..key);
	end
end

----------------------------------------------------
---- Kills an invasion via the invasion manager ----
----------------------------------------------------
function invasion_manager:kill_invasion_by_key(key)	
	local invasion = self.invasions[key];
	
	if invasion then
		output("Invasion Manager: Killing Invasion [" .. invasion.key .. "]");
		invasion:kill();
	end
end

---------------------------------------
---- Creates a new invasion object ----
---------------------------------------
function invasion:new(o)
	output("Invasion: New Invasion object created... ["..tostring(o).."]");
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end

-----------------------------------------
---- Sets the target for an invasion ----
-----------------------------------------
function invasion:set_target(target_type, target, target_faction_key)
	output("Invasion: Set Target for '"..self.key.."'...");
	
	if target_type == "REGION" then
		output("\tTarget: "..target_type.." - "..tostring(target));
		self.target_type = target_type;
		self.target = target;		
	elseif target_type == "CHARACTER" then
		output("\tTarget: "..target_type.." - "..tostring(target));
		self.target_type = target_type;
		self.target = target;
	elseif target_type == "LOCATION" then
		output("\tTarget: "..target_type.." - X:"..tostring(target.x).." / Y:"..tostring(target.y));
		self.target_type = target_type;
		self.target = target;
	elseif target_type == "PATROL" then
		output("\tTarget: "..target_type.." - "..tostring(target));
		self.target_type = target_type;
		self.target = target;
		self.patrol_position = 1;
	else
		output("\tTarget: NONE");
		self.target_type = "NONE";
		self.target = nil;
	end
	
	self.target_faction = target_faction_key or nil;
end

-------------------------------------------------------
---- Sets an invasion to no longer have any target ----
-------------------------------------------------------
function invasion:remove_target()
	if self.target ~= nil then
		output("Invasion: Removing Target for '"..self.key.."'");
		self.target_type = "NONE";
		self.target = nil;
		self.target_faction = nil;
	end
end

---------------------------------------------------------------
---- Sets a General to be used when spawning this invasion ----
---------------------------------------------------------------
function invasion:assign_general(character)
	if type(character) == "number" then
		self.general_cqi = character;
	else
		if character:is_null_interface() == false then
			self.general_cqi = character:command_queue_index();
		end
	end
end

---------------------------------------------------------------------------
---- Sets the Invasion should not move after completing it's objective ----
---------------------------------------------------------------------------
function invasion:should_stop_at_end(should_stop)
	if should_stop == true then
		output("Invasion: Invasion will stop after target");
	else
		output("Invasion: Invasion will NOT stop after target");
	end
	self.stop_at_end = should_stop;
end

-----------------------------------------------------------------------------
---- Allows you to apply an effect bundle to the forces in this invasion ----
-----------------------------------------------------------------------------
function invasion:apply_effect(effect_key, turns)
	script_error("WARNING: apply_effect() called but 3K does not support adding effect bundles to military forces");
	--[[
	if effect_key == nil and turns == nil then
		output("Invasion: Applying stored effect '"..self.effect.."' ("..self.effect_turns..") to force "..self.force_cqi);
		cm:apply_effect_bundle_to_force(self.effect, self.force_cqi, self.effect_turns);
	else
		if self.started == true then
			output("Invasion: Applying effect '"..effect_key.."' ("..turns..") to force "..self.force_cqi);
			cm:apply_effect_bundle_to_force(effect_key, self.force_cqi, turns);
		else
			output("Invasion: Preparing effect '"..effect_key.."' ("..turns..")");
			self.effect = effect_key;
			self.effect_turns = turns;
		end
	end
	]]
end

----------------------------------------------------------------------
---- Allows you to add experience to the general in this invasion ----
----------------------------------------------------------------------
function invasion:add_character_experience(experience_amount)
	local cm = get_cm();
	if not experience_amount then
		output("Invasion: Applying stored character experience amount of " .. self.experience_amount .. " to general " .. self.general_cqi);
		cm:add_agent_experience(char_lookup_str(self.general_cqi), self.experience_amount);
	else
		if self.started then
			output("Invasion: Applying character experience amount of " .. experience_amount .. " to general " .. self.general_cqi);
			cm:add_agent_experience(char_lookup_str(self.general_cqi), experience_amount);
		else
			output("Invasion: Preparing character experience amount of " .. experience_amount);
			self.experience_amount = experience_amount;
		end
	end
end

--------------------------------------------------------------------------------
---- Allows you to add experience to the units of the army in this invasion ----
--------------------------------------------------------------------------------
function invasion:add_unit_experience(unit_experience_amount)
	local cm = get_cm();
	if not cm:can_modify() then
		return;
	end;
	
	if not unit_experience_amount then
		out("Invasion: Applying stored unit experience amount of " .. self.unit_experience_amount .. " to units of general " .. self.general_cqi);
		cm:modify_character(self.general_cqi):add_experience(unit_experience_amount, 0);
	else
		if self.started then
			out("Invasion: Applying unit experience amount of " .. unit_experience_amount .. " to units of general " .. self.general_cqi);
			cm:modify_character(self.general_cqi):add_experience(unit_experience_amount, 0);
		else
			out("Invasion: Preparing unit experience amount of " .. unit_experience_amount);
			self.unit_experience_amount = unit_experience_amount;
		end
	end
end

-----------------------------
---- Begin the invasion! ----
-----------------------------
function invasion:start_invasion(callback_function, declare_war)
	local cm = get_cm();
	if not cm:can_modify() then
		return;
	end;
	
	output("Invasion: Starting Invasion for '"..self.key.."'...");
	
	if declare_war == nil then
		declare_war = true;
	end
	
	if self.started == false then
		self.started = true;
		self.callback = callback_function or nil;
		
		if self.target_faction ~= nil then
			local modify_faction = cm:modify_faction(self.faction);
			
			if not modify_faction:query_faction():is_dead() and declare_war then
				output("\t"..self.faction.." declares war on "..self.target_faction);
				-- cm:force_declare_war(self.faction, self.target_faction, true, true);
				script_error("WARNING: force_declare_war() has been removed in 3K, bug the campaign programmers to reinstate it");
			end
		end
		
		if self.prespawned == true then
			output("\tPre-Spawned force: Ignoring force spawning...");
			self:force_created(self.general_cqi, declare_war);
		else
			output("\tSpawning Force '"..tostring(self.unit_list).."'...");
			local temp_region = cm:query_model():world():region_manager():region_list():item_at(0):name();
			
			if self.general_cqi == nil then
				cm:create_force(self.faction, self.unit_list, temp_region, self.spawn.x, self.spawn.y, "INVASION_FORCE_"..self.key, true,
				function(cqi) self:force_created(cqi, declare_war) end);
			else
				cm:create_force_with_existing_general("character_cqi:"..self.general_cqi, self.faction, self.unit_list, temp_region, self.spawn.x, self.spawn.y, "INVASION_FORCE_"..self.key,
				function(cqi) self:force_created(cqi, declare_war) end);
			end
		end
		
		output("\tAdding Listener 'INVASION_"..self.key.."'");
		core:add_listener(
			"INVASION_"..self.key,
			"FactionBeginTurnPhaseNormal",
			function(context)
				return context:faction():name() == self.faction;
			end,
			function(context) self:advance() end,
			true
		);
	else
		script_error("ERROR: Trying to start an invasion that has already been started!");
	end
end

function invasion:force_created(general_cqi, declare_war)
	local cm = get_cm();

	self.general_cqi = general_cqi;
	
	if self.target_type ~= "NONE" then
		cm:modify_campaign_ai():cai_disable_movement_for_character("character_cqi:"..general_cqi);
	end
	
	local force = force_from_general_cqi(general_cqi);
	
	if force:is_null_interface() == false then
		self.force_cqi = force:command_queue_index();
	end
	
	output("\t\tForce Spawned (General CQI: "..tostring(general_cqi)..", Force CQI: "..tostring(self.force_cqi)..", Invasion: "..tostring(self.key)..")");
	
	self.turn_spawned = cm:turn_number();
	
	if self.callback ~= nil and type(self.callback) == "function" then
		self.callback(self);
	end
	
	if self.effect ~= nil and self.effect_turns ~= nil then
		self:apply_effect();
	end
	
	if self.experience_amount then
		self:add_character_experience();
	end
	
	if self.unit_experience_amount then
		self:add_unit_experience();
	end
	
	if self.target_faction ~= nil and not cm:query_faction(self.faction):at_war_with(cm:query_faction(self.target_faction)) and declare_war then
		output("\t\t"..self.faction.." declares war on "..self.target_faction);
		-- cm:force_declare_war(self.faction, self.target_faction, true, true);
		script_error("WARNING: force_declare_war() has been removed in 3K, bug the campaign programmers to reinstate it");
	end
end

---------------------------------------------------------------------------------
---- Advances the invasion, moving or attacking their target if there is one ----
---------------------------------------------------------------------------------
function invasion:advance()
	local cm = get_cm();

	output("Invasion: Advancing Invasion for '"..self.key.."'...");	
	local force = self:get_force();
	
	if force:is_null_interface() then
		-- This invasion force is likely dead, remove it.
		output("\tForce is a null interface, assuming it has died...");
		self.target_type = "NONE";
	else
		local general = self:get_general();
		
		if general:is_null_interface() == false then
			local general_cqi = general:command_queue_index();
			local general_lookup = "character_cqi:"..general_cqi;
			output("\tGeneral Lookup: "..general_lookup);
			output("\tTarget: "..tostring(self.target_type).." ["..tostring(self.target).."]");
			
			if self.target_type ~= "NONE" then
				output("\tDisabling movement for invasion general");
				cm:modify_campaign_ai():cai_disable_movement_for_character(general_lookup);
				
				if self.target_faction ~= nil then
					output("\ton advance, "..self.faction.." declares war on "..self.target_faction);
					-- cm:force_declare_war(self.faction, self.target_faction, true, true);
					script_error("WARNING: force_declare_war() has been removed in 3K, bug the campaign programmers to reinstate it");
				end
				
				if self.target_type == "LOCATION" then
					--------------------------------------------------------------------------------
					---- LOCATION ------------------------------------------------------------------
					--------------------------------------------------------------------------------
					---- Move to a location and then release the army when it gets close enough ----
					--------------------------------------------------------------------------------
					output("\tMoving to Location... ["..self.target.x..", "..self.target.y.."]");
					local distance_from_target = distance_2D(general:logical_position_x(), general:logical_position_y(), self.target.x, self.target.y);
					output("\tDistance from target = "..distance_from_target);
				
					if distance_from_target < 3 then
						output("\tArrived at Location!");
						self.target_type = "NONE";
					else
						output("\tMoving...");
						
						cm:modify_character(general_cqi):walk_to(self.target.x, self.target.y);
					end
				elseif self.target_type == "CHARACTER" then
					-------------------------------------------------------------------------------------
					---- CHARACTER ----------------------------------------------------------------------
					-------------------------------------------------------------------------------------
					---- Attack a character as long as they aren't a null interface and have a force ----
					-------------------------------------------------------------------------------------
					local target_character_cqi = self.target;
					local target_character_lookup = "character_cqi:"..target_character_cqi;
					local target_character_obj = cm:query_model():character_for_command_queue_index(target_character_cqi);
					
					if target_character_obj:is_null_interface() == false and target_character_obj:has_military_force() then
						output("\Attacking Character...");
						
						local modify_character = cm:modify_character(general_cqi);
						modify_character:enable_movement();
						modify_character:replenish_action_points();
						
						local target_character = cm:query_character(target_character_cqi);
						if target_character then
							modify_character:attack(target_character);
						end;
					else
						output("\tCouldn't find target... releasing force!");
						self.target_type = "NONE";
					end
				elseif self.target_type == "REGION" then
					-----------------------------------------------------------------------------------
					---- REGION -----------------------------------------------------------------------
					-----------------------------------------------------------------------------------
					---- Attack a region providing it is not a null interface and is not abandoned ----
					-----------------------------------------------------------------------------------
					local target_region_key = self.target;
					local target_region_obj = cm:query_model():world():region_manager():region_by_key(target_region_key);
					
					if target_region_obj:is_null_interface() == false and target_region_obj:is_abandoned() == false then
						output("\Attacking Region...");
						
						local modify_character = cm:modify_character(general_cqi);
						modify_character:enable_movement();
						modify_character:replenish_action_points();
						
						script_error("ERROR: attack_region() not supported in 3K, bug the campaign programmers to add it");
						-- cm:attack_region(general_lookup, target_region_key, true);
					else
						output("\tCouldn't find target... releasing force!");
						self.target_type = "NONE";
					end
				elseif self.target_type == "FORCE" then
					-------------------------------------------------------------------------------
					---- FORCE --------------------------------------------------------------------
					-------------------------------------------------------------------------------
					---- Attack a force providing it is not a null interface and has a general ----
					-------------------------------------------------------------------------------
					local target_force_cqi = self.target;
					local target_force_obj = cm:query_model():military_force_for_command_queue_index(target_force_cqi);
					
					if target_force_obj:is_null_interface() == false then
						if target_force_obj:has_general() == true then
							local enemy_general_cqi = target_force_obj:general_character():command_queue_index();
							local enemy_general_lookup = "character_cqi:"..enemy_general_cqi;
							
							output("\Attacking Force...");
							
							local modify_character = cm:modify_character(general_cqi);
							modify_character:enable_movement();
							modify_character:replenish_action_points();
							
							local target_character = cm:query_character(enemy_general_cqi);
							if target_character then
								cm:modify_character(general_cqi):attack(target_character);
							end;
						end
					else
						output("\tCouldn't find target... releasing force!");
						self.target_type = "NONE";
					end
				elseif self.target_type == "PATROL" then
					------------------------------------------------------------------------------------
					---- PATROL ------------------------------------------------------------------------
					------------------------------------------------------------------------------------
					---- Walks to a set of coordinates indefinitely until destroyed or told to stop ----
					------------------------------------------------------------------------------------
					output("\tFollowing patrol route...");
					output("\tNext patrol point: #"..self.patrol_position.." ["..self.target[self.patrol_position].x..", "..self.target[self.patrol_position].y.."]");
					local distance_from_target = distance_2D(general:logical_position_x(), general:logical_position_y(), self.target[self.patrol_position].x, self.target[self.patrol_position].y);
					output("\tDistance from next patrol point = "..distance_from_target);
				
					if distance_from_target < 3 then
						output("\tArrived at patrol location #"..self.patrol_position);
						
						if self.patrol_position == #self.target then
							output("\t\tLast patrol position reached...");
							
							if self.stop_at_end == true then
								output("\t\t\tStopping!");
								self.target_type = "NONE";
								self.patrol_position = 0;
							else
								output("\t\t\tRestarting patrol and moving... #"..self.patrol_position.." ["..self.target[self.patrol_position].x..", "..self.target[self.patrol_position].y.."]");
								self.patrol_position = 1;
								cm:modify_character(general_cqi):walk_to(self.target[self.patrol_position].x, self.target[self.patrol_position].y);
							end
						elseif self.target[self.patrol_position + 1] ~= nil then
							output("\t\tMoving to next patrol point... #"..self.patrol_position.." ["..self.target[self.patrol_position].x..", "..self.target[self.patrol_position].y.."]");
							self.patrol_position = self.patrol_position + 1;
							cm:modify_character(general_cqi):walk_to(self.target[self.patrol_position].x, self.target[self.patrol_position].y);
						else
							output("\t\t\tAborting?!");
							self.target_type = "NONE";
							self.patrol_position = 0;
						end
					else
						output("\tMoving... #"..self.patrol_position.." ["..self.target[self.patrol_position].x..", "..self.target[self.patrol_position].y.."]");
						cm:modify_character(general_cqi):walk_to(self.target[self.patrol_position].x, self.target[self.patrol_position].y);
					end
				end
			end
		end
	end
	
	if self.target_type == "NONE" then
		local general = self:get_general();
		local should_remove = false;
		
		if general:is_null_interface() == false then
			local general_cqi = general:command_queue_index();
			local general_lookup = "character_cqi:"..general_cqi;
			
			if self.stop_at_end == true then
				output("\tInvasion has been told to stop after completion");
				output("\tDisabling movement for invasion general");
				cm:modify_campaign_ai():cai_disable_movement_for_character(general_lookup);
				
			else
				output("\tEnabling movement for invasion general ["..general_lookup.."]");
				cm:modify_campaign_ai():cai_enable_movement_for_character(general_lookup);
				cm:modify_character(general_cqi):enable_movement();
				
				should_remove = true;
			end
		end
		
		if should_remove == true then
			invasion_manager:remove_invasion(self.key);
		end
	end
end

---------------------------------------------------------
---- Kills the invasions General and the whole force ----
---------------------------------------------------------
function invasion:kill()
	output("Invasion: Killing Invasion with key '"..self.key.."'...");	
	local general = self:get_general();
	local general_cqi = general:command_queue_index();
	
	get_cm():modify_character(general_cqi):kill_character(true);
end

-----------------------------------------------------------
---- Returns the character leading this invasion force ----
-----------------------------------------------------------
function invasion:get_general()
	return general_from_force_cqi(self.force_cqi);
end

------------------------------------------------------
---- Returns the force interface of this invasion ----
------------------------------------------------------
function invasion:get_force()
	return get_cm():query_model():military_force_for_command_queue_index(self.force_cqi);
end

--------------------------------------------
---- Checks if an invasion has a target ----
--------------------------------------------
function invasion:has_target()
	return (self.target ~= nil);
end

-------------------------------------------
---- Checks if an invasion has started ----
-------------------------------------------
function invasion:has_started()
	return self.started or false;
end

------------------------------------------------
---- What turn this invasion was spawned on ----
------------------------------------------------
function invasion:turn_spawned()
	return self.turn_spawned or 0;
end

--------------------------
---- Helper Functions ----
--------------------------
function general_from_force_cqi(force_cqi)
	local cm = get_cm();
	local force_obj = cm:query_model():military_force_for_command_queue_index(force_cqi);
	
	if force_obj:is_null_interface() == false then
		if force_obj:has_general() then
			return force_obj:general_character();
		end
	end
	return cm:null_interface();
end
function force_from_general_cqi(general_cqi)
	local cm = get_cm();
	local general_obj = cm:query_model():character_for_command_queue_index(general_cqi);
	
	if general_obj:is_null_interface() == false then
		if general_obj:has_military_force() then
			return general_obj:military_force();
		end
	end
	return cm:null_interface();
end
function distance_2D(ax, ay, bx, by)
	return (((bx - ax) ^ 2 + (by - ay) ^ 2) ^ 0.5);
end

--------------------------
---- Saving / Loading ----
--------------------------
function save_invasion_manager(context)
	cm:save_named_value("invasion_manager", invasion_manager);
end

function load_invasion_manager(context)
	output("!!!!!!! LOADING INVASION MANAGER !!!!!!!");
	local loaded_invasion_manager = cm:load_named_value("invasion_manager", invasion_manager);
	output("\t"..tostring(loaded_invasion_manager));
	
	for key, value in pairs(loaded_invasion_manager.invasions) do
		output("\t\tKey: "..tostring(key)..", Value: "..tostring(value));
		local loaded_invasion = invasion:new(value);
		invasion_manager.invasions[key] = loaded_invasion;
		
		if loaded_invasion:has_started() then
			-- Re-enable the invasion listeners
			output("\tAdding Listener 'INVASION_"..key.."'");
			core:add_listener(
				"INVASION_"..key,
				"FactionBeginTurnPhaseNormal",
				function(context)
					return context:faction():name() == value.faction;
				end,
				function(context) value:advance() end,
				true
			);
		end
	end
end