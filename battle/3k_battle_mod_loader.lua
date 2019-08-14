

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	BATTLE MOD LOADER
--	This will load and execute all *.lua files in the folder data/script/battle/mod/
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

local logMade = false;
function ModLog(text)
	if logMade == false then
		logMade = true;
		local logInterface = io.open("lua_mod_log.txt", "w");
		logInterface:write(text.."\n");
		logInterface:flush();
		logInterface:close();
	else
		local logInterface = io.open("lua_mod_log.txt", "a");
		logInterface:write(text.."\n");
		logInterface:flush();
		logInterface:close();
	end
end


function load_mod_script(current_file)
	local pointer = 1;
	
	while true do
		local next_separator = string.find(current_file, "\\", pointer) or string.find(current_file, "/", pointer);
		
		if next_separator then
			pointer = next_separator + 1;
		else
			if pointer > 1 then
				current_file = string.sub(current_file, pointer);
			end
			break;
		end
	end
	
	local suffix = string.sub(current_file, string.len(current_file) - 3);
	
	if string.lower(suffix) == ".lua" then
		current_file = string.sub(current_file, 1, string.len(current_file) - 4);
	end
	
	-- Loads a Lua chunk from the file
	local loaded_file = loadfile(current_file);
	
	-- Make sure something was loaded from the file
	if loaded_file then
		bm:out("loading mod file " .. current_file);
	
		-- Get the local environment
		local local_env = getfenv(1);
		-- Set the environment of the Lua chunk to the same one as this file
		setfenv(loaded_file, local_env);
		-- Make sure the file is set as loaded
		package.loaded[current_file] = true;
		-- Execute the loaded Lua chunk so the functions within are registered
		loaded_file();
	end
end


local path_to_battle_mod_folder = "/script/battle/mod/";

package.path = path_to_battle_mod_folder .. "?.lua;" .. package.path;

local file_str = effect.filesystem_lookup(path_to_battle_mod_folder, "*.lua");

for filename in string.gmatch(file_str, '([^,]+)') do
	local ok, err = pcall(load_mod_script, filename);
	
	if not ok then
		ModLog("ERROR : ["..tostring(filename).."]");
		ModLog("\t"..tostring(err));
	else
		ModLog("Loaded Mod: ["..tostring(filename).."]");
	end
end