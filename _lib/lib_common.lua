

--- @loaded_in_battle
--- @loaded_in_campaign
--- @loaded_in_frontend





----------------------------------------------------------------------------
---	@section Angle Conversions
----------------------------------------------------------------------------


--- @function r_to_d
--- @desc Converts a supplied angle in radians to degrees.
--- @p number angle, Angle in radians
--- @return number angle in degrees
function r_to_d(value)
	if not is_number(value) then
		return false;
	else
		return value * 57.29578;
	end;
end;


--- @function d_to_r
--- @desc Converts a supplied angle in degrees to radians.
--- @p number angle, Angle in degrees
--- @return number angle in radians
function d_to_r(value)
	if not is_number(value) then
		return false;
	else
		return value * 0.017453;
	end;
end;








----------------------------------------------------------------------------
---	@section File and Folder Paths
--- @desc Functions to help get the filename and path of the calling script.
----------------------------------------------------------------------------


--- @function get_file_and_folder_path_as_table
--- @desc Returns the file and path of the calling script as a table of strings.
--- @p [opt=0] integer stack offset, Supply a positive integer here to return a result for a different file on the callstack e.g. supply '1' to return the file and folder path of the script file calling the the script file calling this function, for example.
--- @return table table of strings
function get_file_and_folder_path_as_table(stack_offset)
	stack_offset = stack_offset or 0;
	
	if not is_number(stack_offset) then
		script_error("ERROR: get_folder_name_and_shortform() called but supplied stack offset [" .. tostring(stack_offset) .. "] is not a number or nil");
		return false;
	end;
	
	-- path of the file that called this function
	local file_path = debug.getinfo(2 + stack_offset).source;
	
	local retval = {};
	
	if string.len(file_path) == 0 then
		-- don't know if this can happen
		return retval;
	end;
	
	local current_separator_pos = 1;
	local next_separator_pos = 1;
	
	-- list of separators - we have to try each of them each time
	local separators = {"\\/", "\\", "//", "/"};
	
	while true do
		local next_separator_pos = string.len(file_path);
		local separator_found = false;
		
		-- try each of our separators and, if we find any, pick the "earliest"
		for i = 1, #separators do
			-- apologies for variable names in here..
			local this_separator = separators[i];
			
			local this_next_separator_pos = string.find(file_path, this_separator, current_separator_pos);
			
			if this_next_separator_pos and this_next_separator_pos < next_separator_pos then
				next_separator_pos = this_next_separator_pos;
				separator_found = this_separator;
			end;			
		end;

		if separator_found then
			table.insert(retval, string.sub(file_path, current_separator_pos, next_separator_pos - 1));
		else
			-- if we didn't find a separator, we must be the end of the path (and it doesn't end with a separator)
			table.insert(retval, string.sub(file_path, current_separator_pos));
			return retval;
		end;
		
		current_separator_pos = next_separator_pos + string.len(separator_found);
		
		-- stop if we're at the end of our string
		if current_separator_pos >= string.len(file_path) then
			return retval;
		end;
	end;
end;


--- @function get_folder_name_and_shortform
--- @desc Returns the folder name of the calling file and the shortform of its filename as separate return parameters. The shortform of the filename is the portion of the filename before the first "_", if one is found. If no shortform is found the function returns only the folder name.
--- @desc A shortform used to be prepended on battle script files to allow them to be easily differentiated from one another in text editors e.g. "TF_battle_main.lua" vs "PY_battle_main.lua" rather than two "battle_main.lua"'s.
--- @p [opt=0] integer stack offset, Supply a positive integer here to return a result for a different file on the callstack e.g. supply '1' to return the folder name/shortform of the script file calling the the script file calling this function, for example.
--- @return string name of folder containing calling file
--- @return string shortform of calling filename, if any
function get_folder_name_and_shortform(stack_offset)
	stack_offset = stack_offset or 0;
	
	if not is_number(stack_offset) then
		script_error("ERROR: get_folder_name_and_shortform() called but supplied stack offset [" .. tostring(stack_offset) .. "] is not a number or nil");
		return false;
	end;
	
	local path = get_file_and_folder_path_as_table(stack_offset + 1);
	
	-- folder name is the last-but-one element in the returned path
	if #path < 2 then
		script_error("ERROR: get_folder_name_and_shortform() called but couldn't determine a valid path to folder? Investigate");
		return false;
	end;
	
	folder_name = path[#path - 1];
	
	local shortform_end = string.find(folder_name, "_");
	
	-- if we didn't find a "_" character pass back the whole folder name as a single return value
	if not shortform_end then
		return folder_name;
	end;
	
	-- pass back the substring before the first "_" as the folder shortform
	local shortform = string.sub(folder_name, 1, shortform_end - 1);
	
	return folder_name, shortform;
end;


--- @function get_full_file_path
--- @desc Gets the full filepath and name of the calling file.
--- @p [opt=0] integer stack offset, Supply a positive integer here to return a result for a different file on the callstack e.g. supply '1' to return the file path of the script file calling the the script file calling this function, for example.
--- @return string file path
function get_full_file_path(stack_offset)
	stack_offset = stack_offset or 0;
	
	if not is_number(stack_offset) then
		script_error("ERROR: get_full_file_path() called but supplied stack offset [" .. tostring(stack_offset) .. "] is not a number or nil");
		return false;
	end;
	
	return debug.getinfo(2 + stack_offset).source;
end;


--- @function get_file_name_and_path
--- @desc Returns the filename and the filepath of the calling file as separate return parameters.
--- @p [opt=0] integer stack offset, Supply a positive integer here to return a result for a different file on the callstack e.g. supply '1' to return the file name and path of the script file calling the the script file calling this function, for example.
--- @return string file name
--- @return string file path
function get_file_name_and_path(stack_offset)
	stack_offset = stack_offset or 0;
	
	if not is_number(stack_offset) then
		script_error("ERROR: get_file_name_and_path() called but supplied stack offset [" .. tostring(stack_offset) .. "] is not a number or nil");
		return false;
	end;
	
	-- path of the file that called this function
	local file_path = debug.getinfo(2 + stack_offset).source;
	local current_pointer = 1;
	
	print("get_file_name_and_path() called, file_path is " .. file_path);
	
	-- logfile output
	if __write_output_to_logfile then
		local file = io.open(__logfile_path, "a");
		if file then
			file:write("get_file_name_and_path() called, file_path is " .. file_path);
			file:close();
		end;
	end;
	
	while true do
		local separator = "\\";
		local next_separator_pos = string.find(file_path, separator, current_pointer);
		
		if not next_separator_pos then
			separator = "/";
			next_separator_pos = string.find(file_path, separator, current_pointer);
			
			if not next_separator_pos then
				separator = "\\/";
				next_separator_pos = string.find(file_path, separator, current_pointer);
			end;
		end;
		
		if not next_separator_pos then
			-- there are no more separators in the file path
			
			if current_pointer == 1 then
				-- no file path was detected for some reason
				return file_path, "";
			end;
			-- otherwise return the file name and the file path as separate parameters
			return string.sub(file_path, current_pointer), string.sub(file_path, 1, current_pointer - 2);
		end;
		
		current_pointer = next_separator_pos + string.len(separator);
	end;
end;




---------------------------------------------------------------
--
-- Output
-- these are only used in campaign, but need to be present
-- for calls from lib_core to work. In time, output from
-- campaign, battle and frontend should be standardised
--
-- TODO: deprecate this, and fold its functionality into out()
---------------------------------------------------------------

function cache_tab()
	out.cache_tab();
end;

function restore_tab()
	out.restore_tab();
end;


function inc_tab()
	out.inc_tab();
end;

function dec_tab()
	out.dec_tab();
end;


function output(input)
	
	-- support for printing other types of objects
	if not is_string(input) then
		if is_number(input) or is_nil(input) or is_boolean(input) then
			input = tostring(input);
		elseif is_uicomponent(input) then
			out("%%%%% uicomponent (more output on ui tab):");
			out("%%%%% " .. uicomponent_to_str(input));
			output_uicomponent(input);
			return;
		else
			output_campaign_obj(input);
			return;
		end;
	end;
	
	out(input);
end;











----------------------------------------------------------------------------
---	@section Type Checking
----------------------------------------------------------------------------


--- @function is_nil
--- @desc Returns true if the supplied object is nil, false otherwise.
--- @p object object
--- @return boolean is nil
function is_nil(obj)
	if type(obj) == "nil" then
		return true;
	end;
	
	return false;
end;


--- @function is_number
--- @desc Returns true if the supplied object is a number, false otherwise.
--- @p object object
--- @return boolean is number
function is_number(obj)
	if type(obj) == "number" then
		return true;
	end;
	
	return false;
end;


--- @function is_function
--- @desc Returns true if the supplied object is a function, false otherwise.
--- @p object object
--- @return boolean is function
function is_function(obj)
	if type(obj) == "function" then
		return true;
	end;
	
	return false;
end;


--- @function is_string
--- @desc Returns true if the supplied object is a string, false otherwise.
--- @p object object
--- @return boolean is string
function is_string(obj)
	if type(obj) == "string" then
		return true;
	end;
	
	return false;
end;


--- @function is_boolean
--- @desc Returns true if the supplied object is a boolean, false otherwise.
--- @p object object
--- @return boolean is boolean
function is_boolean(obj)
	if type(obj) == "boolean" then
		return true;
	end;
	
	return false;
end;


--- @function is_table
--- @desc Returns true if the supplied object is a table, false otherwise.
--- @p object object
--- @return boolean is table
function is_table(obj)
	if type(obj) == "table" then
		return true;
	end;
	
	return false;
end;


--- @function is_eventcontext
--- @desc Returns true if the supplied object is an event context, false otherwise.
--- @p object object
--- @return boolean is event context
function is_eventcontext(obj)
	if string.sub(tostring(obj), 1, 14) == "Pointer<EVENT>" then
		return true;
	end;
	
	return false;
end;


--- @function is_battlesoundeffect
--- @desc Returns true if the supplied object is a battle sound effect, false otherwise.
--- @p object object
--- @return boolean is battle sound effect
function is_battlesoundeffect(obj)
	if string.sub(tostring(obj), 1, 20) == "battle_sound_effect " then
		return true;
	end;
	
	return false;
end;


--- @function is_battle
--- @desc Returns true if the supplied object is an empire battle object, false otherwise.
--- @p object object
--- @return boolean is battle
function is_battle(obj)
	if string.sub(tostring(obj), 1, 14) == "empire_battle " then
		return true;
	end;
	
	return false;
end;


--- @function is_alliances
--- @desc Returns true if the supplied object is an alliances object, false otherwise.
--- @p object object
--- @return boolean is alliances
function is_alliances(obj)
	if string.sub(tostring(obj), 1, 17) == "battle.alliances " then
		return true;
	end;
	
	return false;
end;


--- @function is_alliance
--- @desc Returns true if the supplied object is an alliance, false otherwise.
--- @p object object
--- @return boolean is alliance
function is_alliance(obj)
	if string.sub(tostring(obj), 1, 16) == "battle.alliance " then
		return true;
	end;
	
	return false;
end;


--- @function is_armies
--- @desc Returns true if the supplied object is an armies object, false otherwise.
--- @p object object
--- @return boolean is armies
function is_armies(obj)
	if string.sub(tostring(obj), 1, 14) == "battle.armies " then
		return true;
	end;
	
	return false;
end;


--- @function is_army
--- @desc Returns true if the supplied object is an army object, false otherwise.
--- @p object object
--- @return boolean is army
function is_army(obj)
	if string.sub(tostring(obj), 1, 12) == "battle.army " then
		return true;
	end;
	
	return false;
end;


--- @function is_units
--- @desc Returns true if the supplied object is a units object, false otherwise.
--- @p object object
--- @return boolean is units
function is_units(obj)
	if string.sub(tostring(obj), 1, 13) == "battle.units " then
		return true;
	end;
	
	return false;
end;

--- @function is_unit
--- @desc Returns true if the supplied object is a unit object, false otherwise.
--- @p object object
--- @return boolean is unit
function is_unit(obj)
	if string.sub(tostring(obj), 1, 12) == "battle.unit " or string.sub(tostring(obj), 1, 21) == "UNIT_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_unitcontroller
--- @desc Returns true if the supplied object is a unitcontroller, false otherwise.
--- @p object object
--- @return boolean is unitcontroller
function is_unitcontroller(obj)
	if string.sub(tostring(obj), 1, 23) == "battle.unit_controller " then
		return true;
	end;
	
	return false;
end;


--- @function is_core
--- @desc Returns true if the supplied object is a @core_object object, false otherwise.
--- @p object object
--- @return boolean is core
function is_core(obj)
	if tostring(obj) == TYPE_CORE then
		return true;
	end;
	
	return false;
end;


--- @function is_battlemanager
--- @desc Returns true if the supplied object is a @battle_manager, false otherwise.
--- @p object object
--- @return boolean is battle manager
function is_battlemanager(obj)
	if tostring(obj) == TYPE_BATTLE_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_campaignmanager
--- @desc Returns true if the supplied object is a campaign manager, false otherwise.
--- @p object object
--- @return boolean is campaign manager
function is_campaignmanager(obj)
	if tostring(obj) == TYPE_CAMPAIGN_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_campaigncutscene
--- @desc Returns true if the supplied object is a campaign cutscene, false otherwise.
--- @p object object
--- @return boolean is campaign cutscene
function is_campaigncutscene(obj)
	if tostring(obj) == TYPE_CAMPAIGN_CUTSCENE then
		return true;
	end;
	
	return false;
end;


--- @function is_cutscene
--- @desc Returns true if the supplied object is a battle cutscene, false otherwise.
--- @p object object
--- @return boolean is cutscene
function is_cutscene(obj)
	if tostring(obj) == TYPE_CUTSCENE_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_vector
--- @desc Returns true if the supplied object is a vector object, false otherwise.
--- @p object object
--- @return boolean is vector
function is_vector(obj)
	local obj_str = tostring(obj);
	if obj_str == TYPE_CAMPAIGN_VECTOR or string.sub(obj_str, 1, 14) == "battle_vector " then
		return true;
	end;
	
	return false;
end;


--- @function is_building
--- @desc Returns true if the supplied object is a building object, false otherwise.
--- @p object object
--- @return boolean is building
function is_building(obj)
	local obj_str = tostring(obj);
	if string.sub(obj_str, 1, 16) == "battle.building " or string.sub(tostring(obj), 1, 25) == "BUILDING_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_buildings
--- @desc Returns true if the supplied object is a buildings object, false otherwise.
--- @p object object
--- @return boolean is buildings
function is_buildings(obj)
	local obj_str = tostring(obj);
	if string.sub(obj_str, 1, 17) == "battle.buildings " then
		return true;
	end;
	
	return false;
end;


--- @function is_buildinglist
--- @desc Returns true if the supplied object is a building list object, false otherwise.
--- @p object object
--- @return boolean is building list
function is_buildinglist(obj)
	if string.sub(tostring(obj), 1, 30) == "BUILDING_LIST_SCRIPT_INTERFACE" then
		return true;
	end;
	
	return false;
end;


--- @function is_convexarea
--- @desc Returns true if the supplied object is a @convex_area, false otherwise.
--- @p object object
--- @return boolean is convex area
function is_convexarea(obj)
	if tostring(obj) == TYPE_CONVEX_AREA then
		return true;
	end;
	
	return false;
end;


--- @function is_scriptunit
--- @desc Returns true if the supplied object is a @script_unit, false otherwise.
--- @p object object
--- @return boolean is scriptunit
function is_scriptunit(obj)
	if tostring(obj) == TYPE_SCRIPT_UNIT then
		return true;
	end;
	
	return false;
end;


--- @function is_scriptunits
--- @desc Returns true if the supplied object is a @script_units object, false otherwise.
--- @p object object
--- @return boolean is scriptunits
function is_scriptunits(obj)
	if tostring(obj) == TYPE_SCRIPT_UNITS then
		return true;
	end;
	
	return false;
end;


--- @function is_subtitles
--- @desc Returns true if the supplied object is a battle subtitles object, false otherwise.
--- @p object object
--- @return boolean is subtitles
function is_subtitles(obj)
	if string.sub(tostring(obj), 1, 17) == "battle.subtitles " then
		return true;
	end;
	
	return false;
end;


--- @function is_patrolmanager
--- @desc Returns true if the supplied object is a patrol manager, false otherwise.
--- @p object object
--- @return boolean is patrol manager
function is_patrolmanager(obj)
	if tostring(obj) == TYPE_PATROL_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_waypoint
--- @desc Returns true if the supplied object is a patrol manager waypoint, false otherwise.
--- @p object object
--- @return boolean is waypoint
function is_waypoint(obj)
	if tostring(obj) == TYPE_WAYPOINT then
		return true;
	end;
	
	return false;
end;


--- @function is_eventhandler
--- @desc Returns true if the supplied object is an event handler, false otherwise.
--- @p object object
--- @return boolean is event handler
function is_eventhandler(obj)
	if tostring(obj) == TYPE_EVENT_HANDLER then
		return true;
	end;
	
	return false;
end;


--- @function is_scriptaiplanner
--- @desc Returns true if the supplied object is a script ai planner, false otherwise.
--- @p object object
--- @return boolean is script ai planner
function is_scriptaiplanner(obj)
	if tostring(obj) == TYPE_SCRIPT_AI_PLANNER then
		return true;
	end;
	
	return false;
end;


--- @function is_timermanager
--- @desc Returns true if the supplied object is a timer manager, false otherwise.
--- @p object object
--- @return boolean is timer manager
function is_timermanager(obj)
	if tostring(obj) == TYPE_TIMER_MANAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_uioverride
--- @desc Returns true if the supplied object is a ui override, false otherwise.
--- @p object object
--- @return boolean is ui override
function is_uioverride(obj)
	if tostring(obj) == TYPE_UI_OVERRIDE then
		return true;
	end;
	
	return false;
end;


--- @function is_uicomponent
--- @desc Returns true if the supplied object is a uicomponent, false otherwise.
--- @p object object
--- @return boolean is uicomponent
function is_uicomponent(obj)
	if string.sub(tostring(obj), 1, 12) == "UIComponent " then
		return true;
	end;
	
	return false;
end;


--- @function is_component
--- @desc Returns true if the supplied object is a component, false otherwise.
--- @p object object
--- @return boolean is component
function is_component(obj)
	if string.sub(tostring(obj), 1, 19) == "Pointer<Component> " then
		return true;
	end;
	
	return false;
end;


--- @function is_scriptmessager
--- @desc Returns true if the supplied object is a script messager, false otherwise.
--- @p object object
--- @return boolean is script messager
function is_scriptmessager(obj)
	if tostring(obj) == TYPE_SCRIPT_MESSAGER then
		return true;
	end;
	
	return false;
end;


--- @function is_generatedbattle
--- @desc Returns true if the supplied object is a generated battle, false otherwise.
--- @p object object
--- @return boolean is generated battle
function is_generatedbattle(obj)
	if tostring(obj) == TYPE_GENERATED_BATTLE then
		return true;
	end;
	
	return false;
end;


--- @function is_generatedarmy
--- @desc Returns true if the supplied object is a generated army, false otherwise.
--- @p object object
--- @return boolean is generated army
function is_generatedarmy(obj)
	if tostring(obj) == TYPE_GENERATED_ARMY then
		return true;
	end;
	
	return false;
end;


--- @function is_generatedcutscene
--- @desc Returns true if the supplied object is a generated cutscene, false otherwise.
--- @p object object
--- @return boolean is generated cutscene
function is_generatedcutscene(obj)
	if tostring(obj) == TYPE_GENERATED_CUTSCENE then
		return true;
	end;
	
	return false;
end;


function is_campaignuimanager(obj)
	if tostring(obj) == TYPE_CAMPAIGN_UI_MANAGER then
		return true;
	end;
	
	return false;
end;


function is_objectivesmanager(obj)
	if tostring(obj) == TYPE_OBJECTIVES_MANAGER then
		return true;
	end;
	
	return false;
end;


function is_infotextmanager(obj)
	if tostring(obj) == TYPE_INFOTEXT_MANAGER then
		return true;
	end;
	
	return false;
end;


function is_missionmanager(obj)
	if tostring(obj) == TYPE_MISSION_MANAGER then
		return true;
	end;
	
	return false;
end;


function is_intervention(obj)
	if tostring(obj) == TYPE_INTERVENTION then
		return true;
	end;
	
	return false;
end;


function is_interventionmanager(obj)
	if tostring(obj) == TYPE_INTERVENTION_MANAGER then
		return true;
	end;
	
	return false;
end;


function is_linkparser(obj)
	if tostring(obj) == TYPE_LINK_PARSER then
		return true;
	end;
	
	return false;
end;


function is_advicemanager(obj)
	if tostring(obj) == TYPE_ADVICE_MANAGER then
		return true;
	end;
	
	return false;
end;


function is_advicemonitor(obj)
	if tostring(obj) == TYPE_ADVICE_MONITOR then
		return true;
	end;
	
	return false;
end;


--------------------------------------------------
--
-- CAMPAIGN INTERFACE OBJECTS
--
--------------------------------------------------
-- NEW
function is_modify_building(obj)
	if string.sub(tostring(obj), 1, 32) == "MODIFY_BUILDING_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_campaign_ai(obj)
	if string.sub(tostring(obj), 1, 35) == "MODIFY_CAMPAIGN_AI_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_character(obj)
	if string.sub(tostring(obj), 1, 33) == "MODIFY_CHARACTER_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_scripting(obj)
	if string.sub(tostring(obj), 1, 42) == "MODIFY_EPISODIC_SCRIPTING_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_faction_province(obj)
	if string.sub(tostring(obj), 1, 40) == "MODIFY_FACTION_PROVINCE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_faction(obj)
	if string.sub(tostring(obj), 1, 31) == "MODIFY_FACTION_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_family_member(obj)
	if string.sub(tostring(obj), 1, 37) == "MODIFY_FAMILY_MEMBER_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_garrison_residence(obj)
	if string.sub(tostring(obj), 1, 42) == "MODIFY_GARRISON_RESIDENCE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_military_force_building(obj)
	if string.sub(tostring(obj), 1, 47) == "MODIFY_MILITARY_FORCE_BUILDING_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_military_force_horde_details(obj)
	if string.sub(tostring(obj), 1, 52) == "MODIFY_MILITARY_FORCE_HORDE_DETAILS_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_military_force(obj)
	if string.sub(tostring(obj), 1, 38) == "MODIFY_MILITARY_FORCE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_military_force_slot(obj)
	if string.sub(tostring(obj), 1, 43) == "MODIFY_MILITARY_FORCE_SLOT_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_mode(obj)
	if string.sub(tostring(obj), 1, 29) == "MODIFY_MODEL_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_pending_battle(obj)
	if string.sub(tostring(obj), 1, 38) == "MODIFY_PENDING_BATTLE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_province(obj)
	if string.sub(tostring(obj), 1, 32) == "MODIFY_PROVINCE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_region_manager(obj)
	if string.sub(tostring(obj), 1, 38) == "MODIFY_REGION_MANAGER_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_region(obj)
	if string.sub(tostring(obj), 1, 30) == "MODIFY_REGION_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_settlement(obj)
	if string.sub(tostring(obj), 1, 34) == "MODIFY_SETTLEMENT_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_slot(obj)
	if string.sub(tostring(obj), 1, 28) == "MODIFY_SLOT_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_unit(obj)
	if string.sub(tostring(obj), 1, 28) == "MODIFY_UNIT_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_modify_world(obj)
	if string.sub(tostring(obj), 1, 29) == "MODIFY_WORLD_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_null_script_interface(obj)
	if string.sub(tostring(obj), 1, 21) == "NULL_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_building_list(obj)
	if string.sub(tostring(obj), 1, 36) == "QUERY_BUILDING_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_building(obj)
	if string.sub(tostring(obj), 1, 31) == "QUERY_BUILDING_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_campaign_ai(obj)
	if string.sub(tostring(obj), 1, 34) == "QUERY_CAMPAIGN_AI_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_campaign_mission(obj)
	if string.sub(tostring(obj), 1, 39) == "QUERY_CAMPAIGN_MISSION_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_character_list(obj)
	if string.sub(tostring(obj), 1, 37) == "QUERY_CHARACTER_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_character(obj)
	if string.sub(tostring(obj), 1, 32) == "QUERY_CHARACTER_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_diplomacy_deal(obj)
	if string.sub(tostring(obj), 1, 37) == "QUERY_DIPLOMACY_DEAL_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_diplomacy_negotiated_deal(obj)
	if string.sub(tostring(obj), 1, 48) == "QUERY_DIPLOMACY_NEGOTIATED_DEAL_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_diplomacy_negotiated_deals(obj)
	if string.sub(tostring(obj), 1, 49) == "QUERY_DIPLOMACY_NEGOTIATED_DEALS_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_diplomacy_negotiated_deal_list(obj)
	if string.sub(tostring(obj), 1, 53) == "QUERY_DIPLOMACY_NEGOTIATED_DEAL_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_episodic_scripting(obj)
	if string.sub(tostring(obj), 1, 41) == "QUERY_EPISODIC_SCRIPTING_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_faction_list(obj)
	if string.sub(tostring(obj), 1, 35) == "QUERY_FACTION_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_province_list(obj)
	if string.sub(tostring(obj), 1, 44) == "QUERY_FACTION_PROVINCE_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_faction_province(obj)
	if string.sub(tostring(obj), 1, 39) == "QUERY_FACTION_PROVINCE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_faction(obj)
	if string.sub(tostring(obj), 1, 30) == "QUERY_FACTION_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_family_member(obj)
	if string.sub(tostring(obj), 1, 36) == "QUERY_FAMILY_MEMBER_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_garrison_residence(obj)
	if string.sub(tostring(obj), 1, 41) == "QUERY_GARRISON_RESIDENCE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_historical_character_list(obj)
	if string.sub(tostring(obj), 1, 48) == "QUERY_HISTORICAL_CHARACTER_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_historical_character_manager(obj)
	if string.sub(tostring(obj), 1, 51) == "QUERY_HISTORICAL_CHARACTER_MANAGER_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_historical_character(obj)
	if string.sub(tostring(obj), 1, 43) == "QUERY_HISTORICAL_CHARACTER_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_military_force_building_list(obj)
	if string.sub(tostring(obj), 1, 51) == "QUERY_MILITARY_FORCE_BUILDING_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_military_force_building(obj)
	if string.sub(tostring(obj), 1, 46) == "QUERY_MILITARY_FORCE_BUILDING_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_military_force_horde_details(obj)
	if string.sub(tostring(obj), 1, 51) == "QUERY_MILITARY_FORCE_HORDE_DETAILS_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_military_force_list(obj)
	if string.sub(tostring(obj), 1, 42) == "QUERY_MILITARY_FORCE_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_military_force(obj)
	if string.sub(tostring(obj), 1, 37) == "QUERY_MILITARY_FORCE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_military_force_slot_list(obj)
	if string.sub(tostring(obj), 1, 47) == "QUERY_MILITARY_FORCE_SLOT_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_military_force_slot(obj)
	if string.sub(tostring(obj), 1, 42) == "QUERY_MILITARY_FORCE_SLOT_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_model(obj)
	if string.sub(tostring(obj), 1, 28) == "QUERY_MODEL_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_pending_battle(obj)
	if string.sub(tostring(obj), 1, 37) == "QUERY_PENDING_BATTLE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_province_list(obj)
	if string.sub(tostring(obj), 1, 36) == "QUERY_PROVINCE_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_province(obj)
	if string.sub(tostring(obj), 1, 31) == "QUERY_PROVINCE_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_region_list(obj)
	if string.sub(tostring(obj), 1, 34) == "QUERY_REGION_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_region_manager(obj)
	if string.sub(tostring(obj), 1, 37) == "QUERY_REGION_MANAGER_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_region(obj)
	if string.sub(tostring(obj), 1, 29) == "QUERY_REGION_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_settlement(obj)
	if string.sub(tostring(obj), 1, 33) == "QUERY_SETTLEMENT_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_slot_list(obj)
	if string.sub(tostring(obj), 1, 32) == "QUERY_SLOT_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_slot(obj)
	if string.sub(tostring(obj), 1, 27) == "QUERY_SLOT_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_unit_list(obj)
	if string.sub(tostring(obj), 1, 32) == "QUERY_UNIT_LIST_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_unit(obj)
	if string.sub(tostring(obj), 1, 27) == "QUERY_UNIT_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;

function is_query_world(obj)
	if string.sub(tostring(obj), 1, 28) == "QUERY_WORLD_SCRIPT_INTERFACE" then
		return true;
	end;

	return false;
end;









----------------------------------------------------------------------------
---	@section Tables
----------------------------------------------------------------------------


--- @function table_contains
--- @desc Returns true if the supplied indexed table contains the supplied object.
--- @p table subject table
--- @p object object
--- @return boolean table contains object
function table_contains(t, obj)
	for i = 1, #t do
		if t[i] == obj then
			return true;
		end;
	end;
	return false;
end;









----------------------------------------------------------------------------
---	@section UIComponents
----------------------------------------------------------------------------


--- @function find_child_uicomponent
--- @desc Takes a uicomponent and a string name. Searches the direct children (and no further - not grandchildren etc) of the supplied uicomponent for another uicomponent with the supplied name. If a uicomponent with the matching name is found then it is returned, otherwise <code>false</code> is returned.
--- @p uicomponent parent ui component
--- @p string name
--- @return uicomponent child, or false if not found
function find_child_uicomponent(parent, name)
	for i = 0, parent:ChildCount() - 1 do
		local uic_child = UIComponent(parent:Find(i));
		if uic_child:Id() == name then
			return uic_child;
		end;
	end;
	
	return false;
end;


-- can be used externally, but find_uicomponent is better
function find_single_uicomponent(parent, component_name)
	if not is_uicomponent(parent) then
		script_error("ERROR: find_single_uicomponent() called but supplied parent [" .. tostring(parent) .."] is not a ui component");
		return false;
	end;
	
	if not is_string(component_name) and not is_number(component_name) then
		script_error("ERROR: find_single_uicomponent() called but supplied component name [" .. tostring(component_name) .. "] is not a string or a number");
		return false;
	end;

	local component = parent:Find(component_name, false);
	
	if not component then
		return false;
	end;
	
	return UIComponent(component);
end;


--- @function find_uicomponent
--- @desc Takes a start uicomponent and one or more string uicomponent names. Starting from the supplied start uicomponent, the function searches through all descendants for a uicomponent with the next supplied uicomponent name in the sequence. If a uicomponent is found, its descendants are then searched for a uicomponent with the next name in the list, and so on until the list is finished or no uicomponent with the supplied name is found. This allows a uicomponent to be searched for by matching its name and part of or all of its path.
--- @p uicomponent parent ui component
--- @p ... list of string names
--- @return uicomponent child, or false if not found.
function find_uicomponent(parent, ...)
	local current_parent = parent;
	
	for i = 1, arg.n do
		local current_child = find_single_uicomponent(current_parent, arg[i]);
		
		if not current_child then
			-- output("find_uicomponent() couldn't find component called " .. tostring(arg[i]));
			return false;
		end;
		
		current_parent = current_child;
	end;
	
	return current_parent;
end;


--- @function find_uicomponent_from_table
--- @desc Takes a start uicomponent and a numerically-indexed table of string uicomponent names. Starting from the supplied start uicomponent, the function searches through all descendants for a uicomponent with the next supplied uicomponent name in the table. If a uicomponent is found, its descendants are then searched for a uicomponent with the next name in the list, and so on until the list is finished or no uicomponent with the supplied name is found. This allows a uicomponent to be searched for by matching its name and part of or all of its path.
--- @p uicomponent parent ui component, Parent uicomponent.
--- @p table table of string names, Table of string names, indexed by number.
--- @p [opt=false] assert on failure, Fire a script error if the search fails.
--- @return uicomponent child, or false if not found.
function find_uicomponent_from_table(parent, t, assert_on_failure)
	if not is_table(t) then
		script_error("ERROR: find_uicomponent_from_table() called but supplied path list [" .. tostring(t) .. "] is not a table");
		return false;
	end;
	
	local current_uic = parent;
	
	for i = 1, #t do
		local current_id = t[i];
		
		if not is_string(current_id) and not is_number(current_id) then
			script_error("ERROR: find_uicomponent_from_table() called but element " .. tostring(i) .. " of supplied path list is not a string, it is [" .. tostring(current_id) .. "]");
			return false;
		end;
		
		current_uic = find_single_uicomponent(current_uic, current_id);
		
		if not current_uic then
			if assert_on_failure then
				local path = table.concat(t, ", ");
				script_error("ERROR: find_uicomponent_from_table() couldn't find uicomponent, path is [" .. path .. "] and the failure occurred trying to find element " .. i .. " [" .. current_id .. "]");
			end;
			
			return false;
		end;
	end;	
	
	return current_uic;
end;


--- @function uicomponent_descended_from
--- @desc Takes a uicomponent and a string name. Returns true if any parent ancestor component all the way up to the ui root has the supplied name (i.e. the supplied component is descended from it), false otherwise.
--- @p uicomponent subject uic
--- @p string parent name
--- @return boolean uic is descended from a component with the supplied name.
function uicomponent_descended_from(uic, parent_name)
	if not is_uicomponent(uic) then
		script_error("ERROR: uicomponent_descended_from() called but supplied uicomponent [" .. tostring(uic) .. "] is not a ui component");
		return false;
	end;
	
	if not is_string(parent_name) then
		script_error("ERROR: uicomponent_descended_from() called but supplied parent name [" .. tostring(parent_name) .. "] is not a string");
		return false;
	end;
	
	local uic_parent = uic;
	local name = uic_parent:Id();
	
	while name ~= "root" do
		if name == parent_name then
			return true;
		end;
		
		uic_parent = UIComponent(uic_parent:Parent());
		name = uic_parent:Id();
	end;
	
	return false;	
end;


--- @function uicomponent_to_str
--- @desc Converts a uicomponent to a string showing its path, for output purposes.
--- @p uicomponent subject uic
--- @return string output
function uicomponent_to_str(uic)
	if not is_uicomponent(uic) then
		return "";
	end;
	
	if uic:Id() == "root" then
		return "root";
	else
		local parent = uic:Parent();
		
		if parent then
			return uicomponent_to_str(UIComponent(parent)) .. " > " .. uic:Id();
		else
			-- this can happen if a click has resulted in some uicomponents being destroyed
			return uic:Id();
		end;
	end;	
end;


--- @function output_uicomponent
--- @desc Outputs extensive debug information about a supplied uicomponent to the console.
--- @p uicomponent subject uic, Subject uicomponent.
--- @p [opt=false] boolean omit children, Do not show information about the uicomponent's children.
function output_uicomponent(uic, omit_children)
	if not is_uicomponent(uic) then
		script_error("ERROR: output_uicomponent() called but supplied object [" .. tostring(uic) .. "] is not a ui component");
		return;
	end;
	
	-- not sure how this can happen, but it does ...
	if not pcall(function() out.ui("uicomponent " .. tostring(uic:Id()) .. ":") end) then
		out.ui("output_uicomponent() called but supplied component seems to not be valid, so aborting");
		return;
	end;
	
	out.ui("");
	out.ui("path from root:\t\t" .. uicomponent_to_str(uic));
	
	if __game_mode == __lib_type_campaign then
		out.inc_tab("ui");
	end;
	
	local pos_x, pos_y = uic:Position();
	local size_x, size_y = uic:Bounds();

	out.ui("position on screen:\t" .. tostring(pos_x) .. ", " .. tostring(pos_y));
	out.ui("size:\t\t\t" .. tostring(size_x) .. ", " .. tostring(size_y));
	out.ui("state:\t\t" .. tostring(uic:CurrentState()));
	out.ui("visible:\t\t" .. tostring(uic:Visible()));
	out.ui("priority:\t\t" .. tostring(uic:Priority()));
	
	if not omit_children then
		out.ui("children:");
		
		if __game_mode == __lib_type_campaign then
			out.inc_tab("ui");
		end;
		
		for i = 0, uic:ChildCount() - 1 do
			local child = UIComponent(uic:Find(i));
			
			out.ui(tostring(i) .. ": " .. child:Id());
		end;
	end;
	
	if __game_mode == __lib_type_campaign then
		out.dec_tab("ui");
		out.dec_tab("ui");
	end;

	out.ui("");
end;


--- @function output_uicomponent_on_click
--- @desc Starts a listener which outputs information to the console about every uicomponent that's clicked on.
function output_uicomponent_on_click()	
	out.ui("*** output_uicomponent_on_click() called ***");
	
	core:add_listener(
		"output_uicomponent_on_click",
		"ComponentLClickUp",
		true,
		function(context) output_uicomponent(UIComponent(context.component), true) end,
		true
	);
end;


--- @function print_all_uicomponent_children
--- @desc Prints the name and path of the supplied uicomponent and all its descendents. Very verbose, and can take a number of seconds to complete.
--- @p uicomponent subject uic, Subject uicomponent.
function print_all_uicomponent_children(uic)
	if not is_uicomponent(uic) then
		uic = core:get_ui_root();
	end;

	out.ui(uicomponent_to_str(uic));
	for i = 0, uic:ChildCount() - 1 do
		local uic_child = UIComponent(uic:Find(i));
		print_all_uicomponent_children(uic_child);
	end;
end;


--- @function pulse_uicomponent
--- @desc Activates or deactivates a pulsing highlight effect on the supplied uicomponent. This is primarily used for scripts which activate when the player moves the mouse cursor over certain words in the help pages, to indicate to the player what UI feature is being talked about on the page.
--- @p uicomponent ui component, Subject ui component.
--- @p boolean should pulse, Set to <code>true</code> to activate the pulsing effect, <code>false</code> to deactivate it.
--- @p [opt=0] number brightness, Pulse brightness. Set a higher number for a more pronounced pulsing effect.
--- @p [opt=false] boolean progagate, Propagate the effect through the component's children. Use this with care, as the visual effect can stack and often it's better to activate the effect on specific uicomponents instead of activating this.
--- @p [opt=nil] string state name, Optional state name to affect. If a string name is supplied, the pulsing effect is only applied to the specified state instead of to all states on the component.
function pulse_uicomponent(uic, should_pulse, brightness_modifier, propagate, state_name)
	
	brightness_modifier = brightness_modifier or 0;
	silent = silent or false;

	if not is_uicomponent(uic) then
		script_error("ERROR: pulse_uicomponent() called but supplied uicomponent [" .. tostring(uic) .. "] is not a ui component");
		return false;
	end;
	
	if should_pulse then
		if state_name then
			uic:StartPulseHighlight(brightness_modifier, state_name);
		else
			uic:StartPulseHighlight(brightness_modifier);
		end;
	else
		if state_name then
			uic:StopPulseHighlight(state_name);
		else
			uic:StopPulseHighlight();
		end;
	end;
	
	if propagate then
		for i = 0, uic:ChildCount() - 1 do
			pulse_uicomponent(UIComponent(uic:Find(i)), should_pulse, brightness_modifier, propagate, state_name);
		end;
	end;
end;


--- @function is_fully_onscreen
--- @desc Returns true if the uicomponent is fully on-screen, false otherwise.
--- @return boolean is onscreen
function is_fully_onscreen(uicomponent)
	local screen_x, screen_y = core:get_screen_resolution();
	
	local min_x, min_y = uicomponent:Position();
	local size_x, size_y = uicomponent:Bounds();
	local max_x = min_x + size_x;
	local max_y = min_y + size_y;
	
	-- output("is_fully_onscreen() called, component id: " .. uicomponent:Id() .. ", screen size [" .. screen_x .. ", " .. screen_y .. "], component min xy [" .. min_x .. ", " .. min_y .. "] and max xy [" .. max_x .. ", " .. max_y .. "]");
	
	return min_x >= 0 and max_x <= screen_x and min_y >= 0 and max_y <= screen_y;	
end;


--- @function is_partially_onscreen
--- @desc Returns true if the uicomponent is partially on-screen, false otherwise.
--- @return boolean is onscreen
function is_partially_onscreen(uicomponent)
	local screen_x, screen_y = core:get_screen_resolution();
	
	local min_x, min_y = uicomponent:Position();
	local size_x, size_y = uicomponent:Bounds();
	local max_x = min_x + size_x;
	local max_y = min_y + size_y;
	
	return ((min_x >= 0 and min_x <= screen_x) or (max_x >= 0 and max_x <= screen_x)) and ((min_y >= 0 and min_y <= screen_y) or (max_y >= 0 and max_y <= screen_y));	
end;




--- @function set_component_visible
--- @desc Sets a uicomponent visible or invisible by its path. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean set visible
--- @p ... list of string names
function set_component_visible(visible, ...)
	local parent = core:get_ui_root();

	local arg_list = {};
	
	for i = 1, arg.n do
		table.insert(arg_list, arg[i]);
	end;
	
	local uic = find_uicomponent_from_table(parent, arg_list);
	
	if is_uicomponent(uic) then
		uic:SetVisible(not not visible);
	end;
end;


--- @function set_component_visible_with_parent
--- @desc Sets a uicomponent visible or invisible by its path. The path should be one or more strings which when sequentially searched for from a supplied uicomponent parent lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean set visible
--- @p uicomponent parent uicomponent
--- @p ... list of string names
function set_component_visible_with_parent(visible, parent, ...)
	local arg_list = {};
	
	for i = 1, arg.n do
		table.insert(arg_list, arg[i]);
	end;
	
	local uic = find_uicomponent_from_table(parent, arg_list)

	if is_uicomponent(uic) then
		uic:SetVisible(not not visible);
	end;
end;


--- @function set_component_active
--- @desc Sets a uicomponent to be active or inactive by its path. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean set active
--- @p ... list of string names
function set_component_active(is_active, ...)
	local parent = core:get_ui_root();
	
	local arg_list = {};
	
	for i = 1, arg.n do
		table.insert(arg_list, arg[i]);
	end;
	
	local uic = find_uicomponent_from_table(parent, arg_list);
	
	if is_uicomponent(uic) then
		set_component_active_action(is_active, uic);
	end;
end;


--- @function set_component_active_with_parent
--- @desc Sets a uicomponent to be active or inactive by its path. The path should be one or more strings which when sequentially searched for from a supplied uicomponent parent lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean set active
--- @p uicomponent parent uicomponent
--- @p ... list of string names
function set_component_active_with_parent(is_active, parent, ...)
	local arg_list = {};
	
	for i = 1, arg.n do
		table.insert(arg_list, arg[i]);
	end;
	
	local uic = find_uicomponent_from_table(parent, arg_list);
	
	if is_uicomponent(uic) then
		set_component_active_action(is_active, uic);
	end;
end;


-- for internal use
function set_component_active_action(is_active, uic)
	local active_str = nil;
	
	if is_active then
		active_str = "active";
	else
		active_str = "inactive";
	end;

	uic:SetState(active_str);
end;


--- @function highlight_component
--- @desc Highlights or unhighlights a uicomponent by its path. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean activate highlight, Set <code>true</code> to activate the highlight, <code>false</code> to deactivate.
--- @p boolean is square, Set to <code>true</code> if the target uicomponent is square, <code>false</code> if it's circular.
--- @p ... list of string names
function highlight_component(value, is_square, ...)
	return highlight_component_action(false, value, is_square, unpack(arg));
end;


--- @function highlight_visible_component
--- @desc Highlights or unhighlights a uicomponent by its path, but only if it's visible. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p boolean activate highlight, Set <code>true</code> to activate the highlight, <code>false</code> to deactivate.
--- @p boolean is square, Set to <code>true</code> if the target uicomponent is square, <code>false</code> if it's circular.
--- @p ... list of string names
function highlight_visible_component(value, is_square, ...)
	return highlight_component_action(true, value, is_square, unpack(arg));
end;


function highlight_component_action(visible_only, value, is_square, ...)
	local uic = find_uicomponent_from_table(core:get_ui_root(), arg, true);
	
	if is_uicomponent(uic) then
		if not visible_only or uic:Visible() then
			uic:Highlight(value, is_square, 0);
		end;
		return true;
	end;
	
	return false;
end;


--- @function play_component_animation
--- @desc Plays a specified component animation on a uicomponent by its path. The path should be one or more strings which when sequentially searched for from the ui root lead to the target uicomponent (see documentation for @global:find_uicomponent_from_table, which performs the search).
--- @p string animation name
--- @p ... list of string names
function play_component_animation(animation, ...)
	
	local uic = find_uicomponent_from_table(core:get_ui_root(), arg, true);
	
	if is_uicomponent(uic) then
		uic:TriggerAnimation(animation);
	end;
end;


--- @function interface_function
--- @desc Calls a specified interface function on a specified component, after performing some debug output.
--- @p uicomponent uicomponent
--- @p string function name
--- @p ... arguments
--- @return ... return values
function interface_function(uicomponent, function_name, ...)
	if not is_uicomponent(uicomponent) then
		script_error("ERROR: interface_function() called but supplied uicomponent [" .. tostring(uicomponent) .. "] is not a uicomponent")
		return false;
	end;
	
	if not is_string(function_name) then
		script_error("ERROR: interface_function() called but supplied function name [" .. tostring(function_name) .. "] is not a string")
		return false;
	end;
	
	out.ui("interface_function() called, function_name is " .. tostring(function_name));
	out.ui("uicomponent is " .. uicomponent_to_str(uicomponent));
	
	return uicomponent:InterfaceFunction(function_name, unpack(arg));
end;























----------------------------------------------------------------------------
---	@section Advisor Progress Button
----------------------------------------------------------------------------


--- @function get_advisor_progress_button
--- @desc Returns the advisor progress/close button uicomponent.
--- @return uicomponent
function get_advisor_progress_button()
	local uic_progress_button = false;
		
	if __game_mode == __lib_type_battle then
		uic_progress_button = find_uicomponent(core:get_ui_root(), "advice_interface", "button_close");
	elseif __game_mode == __lib_type_campaign then
		uic_progress_button = find_uicomponent(core:get_ui_root(), "advice_interface", "button_close");
	else
		script_error("ERROR: get_advisor_progress_button() called in frontend");
		return false;
	end;
	
	if not uic_progress_button then
		script_error("ERROR: get_advisor_progress_button() called but couldn't find advisor button");
		return false;
	end;
	
	return uic_progress_button;
end;


--- @function show_advisor_progress_button
--- @desc Shows or hides the advisor progress/close button.
--- @p [opt=true] boolean show button
function show_advisor_progress_button(value)
	if value ~= false then
		value = true;
	end;
		
	local uic_button = get_advisor_progress_button();
		
	if uic_button then
		uic_button:SetVisible(value);
	end;
	
	-- enable or disable the advisor button on the menu bar
	set_component_active(value, "menu_bar", "button_show_advice");
end;


--- @function highlight_advisor_progress_button
--- @desc Activates or deactivates a highlight on the advisor progress/close button.
--- @p [opt=true] boolean show button
function highlight_advisor_progress_button(value)
	if __game_mode == __lib_type_frontend then
		script_error("ERROR: highlight_advisor_progress_button() called when not in battle or campaign");
		return false;
	end;
	
	highlight_component(value, false, "advice_interface", "button_close");
	set_component_visible(value, "advice_interface", "tut_anim");
end;









----------------------------------------------------------------------------
--	String Extensions
--	http://lua-users.org/wiki/StringRecipes
--
--	starts_with
--		example:
--			local mystring = "hello world";
--			local bool_hello = mystring:starts_with("hello");
--
--	ends_with
--		example:
--			local mystring = "hello world";
--			local bool_world = mystring:ends_with("world");
--
----------------------------------------------------------------------------
function string.starts_with(input, start_str)
   return string.sub(input, 1, string.len(start_str)) == start_str
end

function string.ends_with(input, end_str)
   return end_str == '' or string.sub(input, -string.len(end_str)) == end_str
end