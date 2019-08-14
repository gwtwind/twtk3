----------------------------------------
--[[ MOD SCRIPT LOADER
Written by Vandy. This will load and execute all lua files in the folder in script/_lib/mod, followed by all lua files in script/campaign/mod. Scripts in 
subfolders are not loaded (unless explicitly loaded by those scripts in the root mod folder). This loading happens as soon as lua is initialised in the frontend, 
which is before the UI is created. As such, mod scripts that wish to interface with the UI should wait for it by registering a listener for the UICreated event.

Written by Vandy. This will load all and execute all lua files in the folder script/_lib/mod, followed by all lua files in script/campaign/mod. Scripts in 
subfolders are not loaded (unless explicitly loaded by those scripts in one of the two root mod folders). This loading happens as soon as lua is initialised 
in the campaign, which is before the UI or campaign model are created. Mod scripts should wait for the first tick by registering a listener with
add_first_tick_callback().



local function start_cool_mod()
	output("cool mod is starting")
	-- start mod
end

cm:add_first_tick_callback(function()
	start_cool_mod()
end)

You can also use a global function, ModLog("example!"), to print out whatever outs you'd like to debug, and they'll show up in lua_mod_log.txt.

--]]
----------------------------------------


local mod_script_files = {};

local log_made = false;
local function ModLog(text)
	if log_made then
		local logInterface = io.open("lua_mod_log.txt", "a");
		logInterface:write(text.."\n");
		logInterface:flush();
		logInterface:close();
	else
		log_made = true;
		local logInterface = io.open("lua_mod_log.txt", "w");
		logInterface:write(text.."\n");
		logInterface:flush();
		logInterface:close();
	end
end

function load_mod_script(current_file)
	current_file = string.match(current_file, "[\\/]mod[\\/](.+)");
	
	if string.find(current_file, "\\") or string.find(current_file, "/") then
		return false;
    end
	
	local suffix = string.sub(current_file, string.len(current_file) - 3);
	
    if string.lower(suffix) == ".lua" then
		-- Strip lua suffix
		current_file = string.sub(current_file, 1, string.len(current_file) - 4);
		
		-- Avoid loading more than once
		if package.loaded[current_file] then
			return false;
		end
		
		-- Load the Lua file
        local lua_chunk = loadfile(current_file);
		
		if lua_chunk then
			-- Set the environment of the loaded Lua chunk
            setfenv(lua_chunk, getfenv(1));
			
			-- Run the chunk and get anything that the file may return
			local lua_module = lua_chunk(current_file);
			-- Cache either the module or mark it as loaded
			package.loaded[current_file] = lua_module or true;
			
			-- Add this to list of loaded mod scripts
            local newmod = {};

			newmod.file = current_file;
			newmod.called = false;
			table.insert(mod_script_files, newmod);
			ModLog("Loaded Mod: ["..tostring(current_file).."]");
			return true;
        else
			-- Require the mod file with pcall to get the error as the file failed to load
            local loaded_file, err = pcall(require, current_file);
			
            if loaded_file then
				-- Add this to list of loaded mod scripts
				local newmod = {};
				newmod.file = current_file;
                newmod.called = false;

				table.insert(mod_script_files, newmod);
				ModLog("Loaded Mod: ["..tostring(current_file).."]");
				return true;
			else
				ModLog("ERROR (loadfile failed): ["..tostring(current_file).."]");
				ModLog("\t"..tostring(err));
			end
		end
	end
	return false;
end

local function load_mod_scripts()
	-- Script Library Folder
	local file_str_l = effect.filesystem_lookup("/script/_lib/mod/", "*.lua");
    if file_str_l ~= "" then
		package.path = package.path .. ";" .. "/script/_lib/mod/?.lua;";
		
        for filename in string.gmatch(file_str_l, '([^,]+)') do
			load_mod_script(filename);
		end
	end

	-- Campaign Folder
	local file_str_c = effect.filesystem_lookup("/script/campaign/mod/", "*.lua");
	
    if file_str_c ~= "" then
        package.path = package.path .. ";" .. "/script/campaign/mod/?.lua;";
		
        for filename in string.gmatch(file_str_c, '([^,]+)') do
            load_mod_script(filename);
		end
	end
end

-- trigger the load_mod_scripts() function before most other tables
output("*** Start Loading Campaign Mod Scripts ***");
ModLog("*** Start Loading Campaign Mod Scripts ***");
load_mod_scripts();
output("***  End Loading Campaign Mod Scripts  ***");
ModLog("***  End Loading Campaign Mod Scripts  ***");