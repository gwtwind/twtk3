-------------------------------------------------------------------------------------------------------
---- Random Army Manager ------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
---- Used to create and manage multiple random or semi-random army templates that can be generated ----
-------------------------------------------------------------------------------------------------------

-- Example Usage:
--
-- 1) Create the manager
-- local ram = random_army_manager;
--
-- 2) Create an army template
-- ram:new_force("my_template");
--
-- 3) Add 4 units to this army that will always be used when generating this template
-- ram:add_mandatory_unit("my_template", "unit_key1", 4);
--
-- 4) Add units to the template that can be randomly generated, with their weighting (that is their chance of being picked, this is not how many will be picked)
-- ram:add_unit("my_template", "unit_key1", 1);
-- ram:add_unit("my_template", "unit_key2", 1);
-- ram:add_unit("my_template", "unit_key3", 2);
--
-- 5) Generate a random army of 6 units from this template
-- local force = ram:generate_force("my_template", 7, false);
-- Force: "unit_key1,unit_key1,unit_key1,unit_key1,unit_key2,unit_key3"


---------------------
---- Definitions ----
---------------------
random_army_manager = {
	force_list = {}
};

---------------------------------------------------------------------------------------
---- Creates a new force available for selection and add it to the table of forces ----
---------------------------------------------------------------------------------------
function random_army_manager:new_force(key)
	out.random_army("Random Army Manager: Creating New Force with key [" .. key .. "]");
	for i = 1, #self.force_list do
		if key == self.force_list[i].key then
			out.random_army("\tForce with key [" .. key .. "] already exists!");
			return false;
		end
	end

	local force = {};
	force.key = key;
	force.units = {};
	force.mandatory_units = {};
	table.insert(self.force_list, force);
	out.random_army("\tForce with key [" .. key .. "] created!");
	return true;
end

-----------------------------------------------------------------------------------------------------
---- Adds a unit to a force, making it available for random selection if this force is generated ----
---- The weight value is an arbitrary figure that should be relative to other units in the force ----
-----------------------------------------------------------------------------------------------------
function random_army_manager:add_unit(force_key, key, weight)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			for j = 1, weight do
				table.insert(self.force_list[i].units, key);
				out.random_army("Random Army Manager: Adding Unit- [" .. key .. "] with weight: [" .. weight .. "] to force: [" .. force_key .. "]");
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------
---- Adds a mandatory unit to a force composition, making it so that if this force is generated this unit will always be part of it ----
----------------------------------------------------------------------------------------------------------------------------------------
function random_army_manager:add_mandatory_unit(force_key, key, amount)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			for j = 1, amount do
				table.insert(self.force_list[i].mandatory_units, key);
				out.random_army("Random Army Manager: Adding Mandatory Unit- [" .. key .. "] with amount: [" .. amount .. "] to force: [" .. force_key .. "]");
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------
---- This generates a force randomly, first taking into account the mandatory unit and then making random selection of units based on weighting ----
---- Returns an array of unit keys or a comma separated string for use in the create_force function if the last boolean value is passed as true ----
----------------------------------------------------------------------------------------------------------------------------------------------------
function random_army_manager:generate_force(force_key, unit_count, return_as_table)
	local force = {};
	
	if is_table(unit_count) then
		unit_count = cm:random_number(math.max(unit_count[1], unit_count[2]), math.min(unit_count[1], unit_count[2]));
	end;
	
	unit_count = math.min(19, unit_count);
	
	out.random_army("Random Army Manager: Getting Random Force for army [" .. force_key .. "] with size [" .. unit_count .. "]");
	
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then			
			local mandatory_units_added = 0;
			
			for j = 1, #self.force_list[i].mandatory_units do
				table.insert(force, self.force_list[i].mandatory_units[j]);
				mandatory_units_added = mandatory_units_added + 1;
			end
		
			for k = 1, unit_count - mandatory_units_added do
				local unit_index = cm:random_number(#self.force_list[i].units);
				table.insert(force, self.force_list[i].units[unit_index]);
			end
		end
	end
	
	if #force == 0 then
		script_error("Random Army Manager: Did not add any units to force with force_key [" .. force_key .. "] - was the force created?");
		return false;
	elseif return_as_table then
		return force;
	else
		return table.concat(force, ",");
	end
end

------------------------------------------------------
---- Remove an existing force from the force list ----
------------------------------------------------------
function random_army_manager:remove_force(force_key)
	out.random_army("Random Army Manager: Removing Force with key [" .. force_key .. "]");
	
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			table.remove(i);
		end
	end
end


local show_debug_output_ram = false;
function output_ram(text)
	if show_debug_output_ram then
		output(text);
	end
end