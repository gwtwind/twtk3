

--- @loaded_in_battle
--- @loaded_in_campaign
--- @loaded_in_frontend

----------------------------------------------------------------------------
---	@section Table Functions
----------------------------------------------------------------------------

--- @function table_length
--- @desc Gets length of non indexed tables. 
--- @desc Use '#<table>' for indexed oneas as it's faster.
--- @p number table
--- @return number table length
function table_length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

--- @function table.clone
--- @desc Clones a table and its elements. A deep copy will make all ements unique. 
--- @p table table
--- @return table clones table.
function deepcopy(orig)
	local orig_type = type(orig);
	local copy;
	
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value);
        end
        setmetatable(copy, deepcopy(getmetatable(orig)));
    else -- number, string, boolean, etc
        copy = orig;
	end
	
    return copy;
end



----------------------------------------------------------------------------
---	@section Math Library Extensions
----------------------------------------------------------------------------

--- @function clamp
--- @desc Clamps a number between two values.
--- @p number value
--- @p number lower bound
--- @p number upper bound
--- @return number clamped value
function math.clamp(val, lower, upper)
    if lower > upper then 
        lower, upper = upper, lower 
    end -- swap if boundaries supplied the wrong way
    
    return math.max(lower, math.min(upper, val))
end

--- @function round
--- @desc Rounds a number to a certain number of decimal places..
--- @p number Number to round
--- @p number Decimal places
--- @return number Rounded value
function math.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function math.round_to_nearest(num, nearest)
	return math.floor(math.round(num / nearest, 0) * nearest);
end;

----------------------------------------------------------------------------
---	@section Vector Stuff
----------------------------------------------------------------------------

--- @function metric_distance
--- @desc Gets metric distance of two vectors
--- @p number vector
--- @p number vector
--- @return number distance
function metric_distance(v1, v2) 

    if not is_vector(v1) then
		script_error("[ERROR] metric_distance(v1, v2): Vector v1 [" .. tostring(v1) .. "] is not a vector!");
		
		return -1;
    end;
    
    if not is_vector(v2) then
		script_error("[ERROR] metric_distance(v1, v2): Vector v1 [" .. tostring(v2) .. "] is not a vector!");
		
		return -1;
    end;
    
    local x_distance = (v1:get_x() - v2:get_x())*(v1:get_x() - v2:get_x());
    local y_distance = (v1:get_y() - v2:get_y())*(v1:get_y() - v2:get_y());
    local z_distance = (v1:get_z() - v2:get_z())*(v1:get_z() - v2:get_z());

    local square_norm = x_distance + y_distance + z_distance;

    return square_norm^0.5;

end




----------------------------------------------------------------------------
---	@section File output
----------------------------------------------------------------------------

-- VARS
file_output = {
	defaultFilePath = "\\The Creative Assembly\\ThreeKingdoms\\logs\\lua_output_", -- default location for files.
	filePath = nil, -- the actual location for files.
	fileName = nil -- the name of the file on disk.
}

-- new object(fileName, opt_filePath)
function file_output:new(fileName, optClearOldData, optFilePath)
	if not is_string(fileName) then
		script_error("ERROR: file_output:new() fileName must be a string");
		return;
	end;

	if cm:is_multiplayer() then return false end;

	if optFilePath and not is_string(optFilePath) then
		script_error("ERROR: file_output:new() optFilePath must be nil or a string");
		return;
	end;

	optClearOldData = optClearOldData or false;
	if optClearOldData and not is_boolean(optClearOldData) then
		script_error("ERROR: file_output:new() optClearOldData must be nil or a bool");
		return;
	end;

	local fo = {};
	setmetatable(fo, self);
	self.__index = self;
	
	fo.fileName = fileName;
	fo.filePath = os.getenv('APPDATA') .. fo.defaultFilePath;
	
	if optFilePath then
		fo.filePath = optFilePath;
	end;

	if optClearOldData then
		fo:clear();
	end;
	
	return fo;
end;

-- write_line(string)
function file_output:write_line(outputValue, indent)
	indent = indent or 0;

	if not self:is_initialised() then
		script_error("ERROR: file_output:write_line() Output it not initialsed.");
		return false;
	end;

	if not is_string(outputValue) then
		script_error("ERROR: file_output:write_line() outputValue must be a string.");
		return false;
	end;
	
	local output_file = io.open(self:get_output_path(), "a"); -- a = append.
	
	if not output_file then
		script_error("ERROR: file_output:write_line() Unable to open or create output file.");
		return;
	end;

	local out_string = "";
	for i = 1, indent do
		out_string = out_string .. "\t";
	end;
	out_string = out_string .. outputValue;

	output_file:write( out_string );
	output_file:write("\n");
	
	output_file:close();
end;

-- write_lines(strings)
function file_output:write_lines(outputValueTable, indent)
	indent = indent or 0;

	if not self:is_initialised() then
		script_error("ERROR: file_output:write_lines() Output it not initialsed.");
		return false;
	end;

	if not is_table(outputValueTable) then
		script_error("ERROR: file_output:write_lines() outputValueTable is not a table.");
		return false;
	end;
	
	local output_file = io.open(self:get_output_path(), "a"); -- a = append.
	
	if not output_file then
		script_error("ERROR: file_output:write_lines() Unable to open or create output file.");
		return;
	end;

	for i=1, #outputValueTable do
		local out_string = "";
		for i = 1, indent do
			out_string = out_string .. "\t";
		end;
		out_string = out_string .. outputValueTable[i];
		
		output_file:write( out_string );
		output_file:write("\n");
	end;
	
	output_file:close();
end;

-- write_lines(strings)
function file_output:write_line_delimited(outputValue, delimiter)
	if not self:is_initialised() then
		script_error("ERROR: file_output:write_line_delimited() Output it not initialsed.");
		return false;
	end;
	
	if not is_string(outputValue) then
		script_error("ERROR: file_output:write_line_delimited() outputValue must be a string.");
		return false;
	end;

	if not is_string(delimiter) then
		script_error("ERROR: file_output:write_line_delimited() delimiter must be a string.");
		return false;
	end;

	local output_file = io.open(self:get_output_path(), "a"); -- a = append.
	
	if not output_file then
		script_error("ERROR: file_output:write_line_delimited() Unable to open or create output file.");
		return;
	end;

	for token in string.gmatch(outputValue, "[^" .. delimiter .. "]+") do
		output_file:write( token );
		output_file:write("\n");
	end
	
	output_file:close();

end;

-- new_line()
function file_output:new_line()
	self:write_line("\n");
end;

-- clear()
function file_output:clear()
	if not self:is_initialised() then
		script_error("ERROR: file_output:clear() Output it not initialsed.");
		return false;
	end;
	
	if self:file_exists() then
		output("!****************************clear file!****************************");
		local output_file = io.open(self:get_output_path(), "w")
		output_file:write( "" );
		output_file:close();
	end;
end;

-- delete_file()
function file_output:delete_file()
	if not self:is_initialised() then
		script_error("ERROR: file_output:delete_file() Output it not initialsed.");
		return false;
	end;

	if self:file_exists() then
		os.remove(self:get_output_path());
	end;
end;

-- file_exists()
function file_output:file_exists()
	local name = self:get_output_path();
	local f = io.open(name, "r");
	
	if f ~= nil then 
		io.close(f);
		return true;
	end;
	
	return false;
end;

-- is_initialised()
function file_output:is_initialised()
	return self.filePath and self.fileName;
end;

-- get_output_path()
function file_output:get_output_path()
	return self.filePath .. self.fileName;
end;