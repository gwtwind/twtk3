



--- @loaded_in_battle
--- @loaded_in_campaign




----------------------------------------------------------------------------
--- @section Vector Manipulation
--- @desc A suite of functions related to vectors. In battle scripting terminology, vectors are 2D/3D positions in the game world.
----------------------------------------------------------------------------


--- @function v_to_s
--- @desc Converts a vector to a string, for debug output
--- @p vector subject vector
--- @return string
function v_to_s(pos)
	if not is_vector(pos) then
		return "[[not a vector, actually " .. tostring(pos) .. "]]";
	end;
	
	return "[" .. pos:get_x() .. ", " .. pos:get_y() .. ", " .. pos:get_z() .. "]";
end;


--- @function v_offset
--- @desc Takes a source vector and some x/y/z offset values. Returns a target vector which is offset from the source by the supplied values.
--- @p vector source vector
--- @p [opt=0] number x offset
--- @p [opt=0] number y offset
--- @p [opt=0] number z offset
--- @return target vector
function v_offset(vector, x, y, z)
	
	if not is_vector(vector) then
		script_error("ERROR: v_offset() called but supplied position [" .. tostring(vector) .. "] is not a vector");
		return false;
	end;

	-- set default parameters
	local x = x or 0;
	local y = y or 0;
	local z = z or 0;

	return v(vector:get_x() + x, vector:get_y() + y, vector:get_z() + z);
end;


--- @function v_add
--- @desc Takes two vectors, and returns a third which is the sum of both.
--- @p vector vector a
--- @p vector vector b
--- @return target vector
function v_add(vector_a, vector_b)

	if not is_vector(vector_a) then
		script_error("ERROR: v_add() called but first supplied position [" .. tostring(vector_a) .. "] is not a vector");
		return false;
	end;
	
	if not is_vector(vector_b) then
		script_error("ERROR: v_add() called but second supplied position [" .. tostring(vector_b) .. "] is not a vector");
		return false;
	end;
	
	return v(vector_a:get_x() + vector_b:get_x(), vector_a:get_y() + vector_b:get_y(), vector_a:get_z() + vector_b:get_z());
end;


--- @function v_subtract
--- @desc Takes two vectors, and returns a third which is the second subtracted from the first.
--- @p vector vector a
--- @p vector vector b
--- @return target vector
function v_subtract(vector_a, vector_b)
	
	if not is_vector(vector_a) then
		script_error("ERROR: v_subtract() called but first supplied position [" .. tostring(vector_a) .. "] is not a vector");
		return false;
	end;
	
	if not is_vector(vector_b) then
		script_error("ERROR: v_subtract() called but second supplied position [" .. tostring(vector_b) .. "] is not a vector");
		return false;
	end;
	
	return v(vector_a:get_x() - vector_b:get_x(), vector_a:get_y() - vector_b:get_y(), vector_a:get_z() - vector_b:get_z());
end;


--@function offset_vector_by_angle_xz
--@desc Offsets a vector by an amount in given direction, in degrees.
--@p vector the starting position
--@p number the angle to project with in degrees
--@p number the distance
--@return vector the result
function offset_vector_by_angle_xz( vector_a, angle, distance )

	if not is_vector( vector_a ) then
		script_error("ERROR: offset_vector_in_direction() called but first supplied position [" .. tostring(vector_a) .. "] is not a vector");
		return false;
	end;

	if not is_number( angle ) then
		script_error("ERROR: offset_vector_in_direction() angle is not a number.");
		return false;
	end;

	if not is_number( distance ) then
		script_error("ERROR: offset_vector_in_direction() distance is not a number.");
		return false;
	end;

	local angle_vector = deg_to_vector_xz(angle);
	local x_offset = angle_vector:get_x() * distance;
	local y_offset = 0;
	local z_offset = angle_vector:get_z() * distance;

	local retval = v_offset( vector_a, x_offset, y_offset, z_offset );

	return retval;
end;


--@function deg_to_vector_xz
--@desc Converts an angle to a vector looking down.
--@p number the angle to project with in degrees
--@return vector the result
function deg_to_vector_xz( angle )
	--[[ Angle maths!
		Looking top-down directions are:
				+z
				|
				|
		-x -----|----- +x
				|
				|
				-z

		Rotations are:
			0 	= 	Up
			90 	= 	Right
			180 = 	Down
			270 = 	Left
	]]--

	if not is_number( angle ) then
		script_error("ERROR: angle_to_vector() angle is not a number.");
		return false;
	end;

	local angle_r = d_to_r( angle );
	
	x = math.round( math.sin( angle_r ), 2);
	y = 0;
	z = math.round( math.cos( angle_r ), 2 );

	return v(x, y, z);
end;

--@function vector_to_deg_xz
--@desc Converts a vector to an angle looking down..
--@p vector the vector to test
--@return number the angle
function vector_to_deg_xz( vector )
	if not is_vector( vector ) then
		script_error("ERROR: offset_vector_in_direction() called but first supplied position [" .. tostring(vector) .. "] is not a vector");
		return false;
	end;

	local out_rad = math.atan(vector:get_x(), vector:get_z());
	return math.deg(out_rad);
end;


--- @function angle_between_vectors
--- @desc Takes two vectors which represent locations in world and returns the angle between. A third vector can be introduced which makes it an angle from that point.
--- @p vector vector_from
--- @p vector vector_to
--- @p vector an optional source position to get the angle from.
--- @return number angle between vectors
function angle_between_vectors(v1, v2, opt_source_pos)
	local v1_mod = v1;
	local v2_mod = v2;

	if opt_source_pos then
		v1_mod = v_subtract(v1, opt_source_pos);
		v2_mod = v_subtract(v2, opt_source_pos);
	end;

	--v1_mod.normal

	local r = math.acos( dot3d( v1_mod, v2_mod ) / ( v1_mod:length() * v2_mod:length() ) );
	return math.deg(r);
end;


--- @function centre_point_table
--- @desc Takes a table of vectors, buildings, units or scriptunits, and returns a vector which is the mean centre of the positions described by those objects.
--- @p table position collection, Table of vectors/buildings/units/scriptunits.
--- @return vector centre position
function centre_point_table(t)
	local total_x = 0;
	local total_y = 0;
	local total_z = 0;

	if not is_table(t) then
		script_error("ERROR: centre_point_table() called but supplied object [" .. tostring(t) .. "] is not a table!");
	end;
	
	local table_size = #t;
	
	if table_size == 0 then
		return v(0, 0, 0);
	end;
	
	for i = 1, #t do
		local curr_vector = false;
		
		if is_vector(t[i]) then
			curr_vector = t[i];
			
		elseif is_building(t[i]) then
			curr_vector = t[i]:central_position();
			
		elseif is_unit(t[i]) then
			curr_vector = t[i]:position();
			
		elseif is_scriptunit(t[i]) then
			curr_vector = t[i].unit:position();
			
		else
			script_error("ERROR: centre_point_table() called but list item " .. i .. " is not a vector, building, unit or scriptunit, but a [" .. tostring(t[i]) .. "]");		
			return false;
		end;
		
		total_x = total_x + curr_vector:get_x();
		total_y = total_y + curr_vector:get_y();
		total_z = total_z + curr_vector:get_z();
	end;
	
	return v( total_x / table_size, total_y / table_size, total_z / table_size);
end;


--- @function get_position_near_target
--- @desc Returns a vector at a random position near to a supplied vector. Additional parameters allow a min/max distance and a min/max angle in degrees from the source vector to be specified.
--- @p vector source position
--- @p [opt=20] number min distance, Minimum distance of target position in m.
--- @p [opt=50] number max distance, Maximum distance of target position in m.
--- @p [opt=0] number min bearing, Minimum bearing of target position in degrees.
--- @p [opt=360] number max bearing, Maximum bearing of target position in degrees.
--- @return vector target position
function get_position_near_target(pos, min_dist, max_dist, min_angle, max_angle)

	if not is_vector(pos) then
		script_error("ERROR: get_position_near_target() called but supplied position [" .. tostring(pos) .. "] is not a vector");
		return false;
	end;
	
	min_dist = min_dist or 20;
	max_dist = max_dist or 50;
	min_angle = min_angle or 0;
	max_angle = max_angle or 360;
	
	if not is_number(min_dist) or min_dist < 0 then
		script_error("ERROR: get_position_near_target() called but supplied minimum distance [" .. tostring(min_dist) .. "] is not a positive number");
		return false;
	end;
	
	if not is_number(max_dist) or max_dist < min_dist then
		script_error("ERROR: get_position_near_target() called but supplied maximum distance [" .. tostring(max_dist) .. "] is not a number greater than the supplied minimum distance [" .. tostring(min_dist) .. "]");
		return false;
	end;
	
	local retval = v(0,0);
	
	local dist = math.random(min_dist, max_dist);
	local angle = math.random(min_angle, max_angle);
	
	retval:set_x(pos:get_x() + (dist * math.cos(d_to_r(angle))));
	retval:set_y(pos:get_y());
	retval:set_z(pos:get_z() + (dist * math.sin(d_to_r(angle))));
	
	return retval;
end;


-- support function for get_furthest/get_nearest
function get_extreme_object(subject, v_list, get_nearest)
	-- if get_nearest we are looking for the nearest point, otherwise we are looking for the furthest
	local func_name = "get_furthest()";
	
	if get_nearest then
		func_name = "get_nearest()";
	end;

	-- check parameters
	if not is_vector(subject) then
		script_error("ERROR: " .. func_name .. " called but supplied subject [" .. tostring(subject) .. "] is not a vector");
		return false;
	end;
	
	-- if our list of positions is a sunits object then get its internal sunits table
	if is_scriptunits(v_list) then
		v_list = v_list:get_sunit_table();
	end;
	
	if not is_table(v_list) then
		script_error("ERROR: " .. func_name .. " called but supplied vector list [" .. tostring(v_list) .. "] is not a table");
		return false;
	end;
	
	if #v_list == 0 then
		script_error("ERROR: " .. func_name .. " called but supplied vector list is empty!");
		return false;
	end;
	
	local extreme_distance = 0;
	local extreme_index = nil;
	local comparison_test = false;
	
	if get_nearest then
		-- set up extreme distance and comparison test as if we were testing for the nearest distance
		extreme_distance = 5000;
		comparison_test = 
			function(vec_a, vec_b, curr_min)
				local curr_dist = vec_a:distance(vec_b);
				if curr_dist < curr_min then
					return curr_dist;
				else
					return false;
				end;
			end;
	else
		-- set up comparison test as if we were testing for the furthest distance
		comparison_test = 
			function(vec_a, vec_b, curr_max)
				local curr_dist = vec_a:distance(vec_b);
				if curr_dist > curr_max then
					return curr_dist;
				else
					return false;
				end;
			end;
	end;
	
	for i = 1, #v_list do
		local curr_list_item = v_list[i];
		local curr_list_vec = false;
		
		if is_vector(curr_list_item) then
			curr_list_vec = curr_list_item;
		elseif is_unit(curr_list_item) then
			curr_list_vec = curr_list_item:position();
		elseif is_scriptunit(curr_list_item) then
			curr_list_vec = curr_list_item.unit:position();
		elseif is_building(curr_list_item) then
			curr_list_vec = curr_list_item:central_position();
		else
			script_error("ERROR: " .. func_name .. " called but object " .. i .. " in vector list is not a vector, unit, scriptunit or building, but [" .. tostring(curr_list_vec) .. "]");
			return false;
		end;
		
		-- do the test, if it returns a value then we have a new max/min distance value
		local test_result = comparison_test(subject, curr_list_vec, extreme_distance);
		if test_result then
			extreme_distance = test_result;
			extreme_index = i;
		end;
	end;
		
	return extreme_index, extreme_distance;
end;


--- @function get_furthest
--- @desc Takes a subject vector and a table of vectors/units/sunits/buildings (or a scriptunits collection). Returns the index of the vector in the table/collection which is furthest from the subject vector.
--- @p vector source position
--- @p table position collection, Table of vector/unit/sunit/building objects, or a scriptunits collection
--- @return integer index of furthest object in list
function get_furthest(subject, v_list)
	return get_extreme_object(subject, v_list, false);
end;


--- @function get_nearest
--- @desc Takes a subject vector and a table of vectors/units/sunits/buildings (or a scriptunits collection). Returns the index of the vector in the table/collection which is closest to the subject vector.
--- @p vector source position
--- @p table position collection, Table of vector/unit/sunit/building objects, or a scriptunits collection
--- @return integer index of closest object in list
function get_nearest(subject, v_list)
	return get_extreme_object(subject, v_list, true);
end;


--- @function position_along_line
--- @desc Takes two vector positions as parameters and a distance in metres, and returns a position which is that distance from the first vector in the direction of the second vector.
--- @p vector first position
--- @p vector second position
--- @p number distance
--- @return vector target position
function position_along_line(vector_a, vector_b, dist)
	dist = dist or 1;
	
	local magnitude = vector_a:distance(vector_b);
	
	-- divide-by-zero guard
	if magnitude == 0 then
		return vector_a;
	end;
	
	local x = dist * (vector_b:get_x() - vector_a:get_x()) / magnitude;
	local y = dist * (vector_b:get_y() - vector_a:get_y()) / magnitude;
	local z = dist * (vector_b:get_z() - vector_a:get_z()) / magnitude;
	
	return v_add(vector_a, v(x, y, z));
end;


--- @function dot
--- @desc Returns the dot product of two supplied vectors.
--- @p vector first position
--- @p vector second position
--- @return number dot product
function dot(vector_a, vector_b)
	return (vector_a:get_x() * vector_b:get_x()) + (vector_a:get_z() * vector_b:get_z())
end;


--- @function dot3d
--- @desc Returns the dot product of two supplied vectors in three dimensions.
--- @p vector first position
--- @p vector second position
--- @return number dot product
function dot3d(vector_a, vector_b)
	return (vector_a:get_x() * vector_b:get_x()) + (vector_a:get_y() * vector_b:get_y()) + (vector_a:get_z() * vector_b:get_z())
end;

--- @function normalised
--- @desc Returns the vector normalised
--- @p vector vector to normalise
--- @return vector normalised
function normalised(vector)

	local len = vector:length();

	local x = vector:get_x() / len;
	local y = vector:get_y() / len;
	local z = vector:get_z() / len;

	return v(x, y, z);
  end


--- @function normal
--- @desc Returns the normal vector of two supplied vectors.
--- @p vector first position
--- @p vector second position
--- @return vector normal
function normal(vector_a, vector_b)
	return v(vector_a:get_x() + vector_b:get_z() - vector_a:get_z(), 0, vector_a:get_z() + vector_a:get_x() - vector_b:get_x());
end;


--- @function distance_to_line
--- @desc Takes two vector positions that describe a 2D line of infinite length, and a target vector position. Returns the distance from the line to the target vector.
--- @p vector line position a
--- @p vector line position b
--- @p vector target position
--- @return number distance
function distance_to_line(line_a, line_b, position)
	
	if line_a:get_x() == line_b:get_x() and line_a:get_z() == line_b:get_z() then
		return 0;
	end;

	--reposition everything as if line_a was the origin
	local new_line_a = v(0,0,0);
	local new_line_b = v(line_b:get_x() - line_a:get_x(), 0, line_b:get_z() - line_a:get_z());
	local new_position = v(position:get_x() - line_a:get_x(), 0, position:get_z() - line_a:get_z());
	
	local dist = new_line_a:distance(new_line_b);
	
	-- divide-by-zero check
	if dist == 0 then
		return 0;
	end;
	
	return (dot(normal(new_line_a, new_line_b), new_position) / dist);
end;


--- @function has_crossed_line
--- @desc Takes a vector, unit, scriptunit or collection of objects and returns true if any element within it has crossed a line demarked by two supplied vector positions.
--- @desc An optional fourth parameter instructs <code>has_crossed_line</code> to only consider the positions of non-routing units, if set to true.
--- @desc An object is deemed to have 'crossed' the line if it's on the right-hand side of the line.
--- @p object position collection, Collection of position objects to test. Supported collection object types are scriptunits, units, army, armies, alliance or a numerically-indexed table of any supported objects.
--- @p vector line position a
--- @p vector line position b
--- @p boolean standing only, Do not count positions of any routing or dead units
--- @return boolean has crossed line
function has_crossed_line(obj, line_a, line_b, standing_only)
	if is_vector(obj) then
		if not is_vector(line_a) then
			script_error("ERROR: has_crossed_line called but first line point " .. tostring(line_a) .. " is not a vector!");
			
			return false;
		end;
		
		if not is_vector(line_b) then
			script_error("ERROR: has_crossed_line called but second line point " .. tostring(line_b) .. " is not a vector!");
			
			return false;
		end;
		
		if (distance_to_line(line_a, line_b, obj) > 0) then
			--position is on the right side of the line defined by line_a -> line_b
			return true;
		end;
	
	elseif is_unit(obj) then
		if (not standing_only) or (standing_only and not is_routing_or_dead(obj)) then
			return has_crossed_line(obj:position(), line_a, line_b, standing_only);		
		end;
		
	elseif is_scriptunit(obj) then
		return has_crossed_line(obj.unit, line_a, line_b, standing_only);
		
	elseif is_scriptunits(obj) then
		for i = 1, obj:count() do
			if has_crossed_line(obj:item(i).unit, line_a, line_b, standing_only) then
				return true;
			end;
		end;
	
	elseif is_units(obj) then
		for i = 1, obj:count() do
			if has_crossed_line(obj:item(i), line_a, line_b, standing_only) then
				return true;
			end;
		end;
	
	elseif is_army(obj) then
		if has_crossed_line(obj:units(), line_a, line_b, standing_only) then
			return true;
		end;
		
		-- check all reinforcing armies
		for i = 1, obj:num_reinforcement_units() do
			local r_units = obj:get_reinforcement_units(i);
			local result = false;
			
			if is_units(r_units) then
				result = has_crossed_line(r_units, line_a, line_b, standing_only);
				
				if result then
					return true;
				end;
			end;
		end;
		
	elseif is_armies(obj) then
		for i = 1, obj:count() do
			if has_crossed_line(obj:item(i), line_a, line_b, standing_only) then
				return true;
			end;
		end;
	
	elseif is_alliance(obj) then
		return has_crossed_line(obj:armies(), line_a, line_b, standing_only);
	
	elseif is_table(obj) then
		for i = 1, #obj do
			if has_crossed_line(obj[i], line_a, line_b, standing_only) then
				return true;
			end;
		end;
	
	else
		script_error("ERROR: has_crossed_line didn't recognise object " .. tostring(obj) .. " to test!");
	end;
	
	return false;	
end;


--- @function distance_along_line
--- @desc Takes two vectors that describe a 3D line of infinite length, and a numeric distance in metres. Returns a position along the line that is the supplied distance from the first supplied position.
--- @p vector line position a
--- @p vector line position b
--- @p number distance
--- @return vector position along line
function distance_along_line(line_a, line_b, distance)
	-- calculate distance between line_a and line_b
	local hyp = line_a:distance(line_b);
		
	local targ_x = (distance * (line_b:get_x() - line_a:get_x()) / hyp) + line_a:get_x();
	local targ_y = (distance * (line_b:get_y() - line_a:get_y()) / hyp) + line_a:get_y();
	local targ_z = (distance * (line_b:get_z() - line_a:get_z()) / hyp) + line_a:get_z();
	
	return v(targ_x, targ_y, targ_z);
end;










----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
--
--	CONVEX AREA
--
--	Allows you to define a convex hull on the battlefield via a series of vectors (i.e. a 2D trigger area), 
--	and then test to see if a given position/unit is within that convex hull. This should allow the user to 
--	precisely determine whether a unit is within an arbritrary-shaped area of the battlefield. The convex 
--	hull object must be created before use by supplying a table of vectors. They must be supplied in clockwise 
--	order around the circumference of the hull. 
--
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

--- @class convex_area Convex Area
--- @desc By creating a convex area, client scripts may define a convex hull shape on the battlefield through a series of vectors, and then perform tests with it, such as seeing if a given position/unit is within the described shape.
--- @desc Convex areas are most useful for battle scripts, but may also be used in campaign.

convex_area = {
	my_points = {}
}


--- @section Creation

--- @function new
--- @desc Creates a convex area from a supplied table of vectors. The supplied table must contain a minimum of three vector positions, and these must describe a convex hull shape. The points must declared in a clockwise orientation around the hull shape.
--- @p table positions, Table of vector positions
--- @return convex_area
function convex_area:new(point_list)	
	local ca = {};
	setmetatable(ca, self);
	self.__index = self;
	self.__tostring = function() return TYPE_CONVEX_AREA end;
	
	local valid, error_msg = ca:process_points(point_list)
	
	if not valid then
		script_error("ERROR: tried to create convex area but supplied points list was invalid! " .. error_msg);
		
		return false;
	end;
	  	
	return ca;
end;


-- validates a list of points being used to create a convex area
function convex_area:validate_points(forward_point, line_a, line_b)
	if not has_crossed_line(forward_point, line_a, line_b) then
		return false, (" Point " .. v_to_s(forward_point) .. " is not on the right side of the line defined by preceding points " .. v_to_s(line_a) .. " to " .. v_to_s(line_b));
	end;
	
	return true;
end;


-- process a series of points being used to create a convex area (test if they are valid, and return an error if not)
function convex_area:process_points(p)
	if not p or not is_table(p) or #p < 3 then
		return false, " No points list given!";
	end;
	
	if not is_table(p) then
		return false, " Points list is not a table!";	
	end;
	
	if #p < 3 then
		return false, " Points list does not contain at least three points!";
	end;
	
	for i = 1, #p do
		if not is_vector(p[i]) then
			return false, " List item " .. i .. " (" .. tostring(p[i]) .. " is not a vector!";
		end;
	end;
	
	-- walk the line and make sure that each point is on the
	-- correct side of the line formed of the two prior points
	local valid, error_msg = false, "";
	
	for j = 1, (#p - 2) do
		valid, error_msg = self:validate_points(p[j+2], p[j], p[j+1]);
		if not valid then
			-- outer edge of shape has turned anti-clockwise, bad !
			return false, error_msg;
		end;
	end;

	-- need to specifically validate last two point clusters as they wrap around the list
	valid, error_msg = self:validate_points(p[1], p[#p - 1], p[#p]);
	if not valid then
		return false, error_msg;
	end;
	
	valid, error_msg = self:validate_points(p[2], p[#p], p[1]);
	if not valid then
		return false, error_msg;
	end;
	
	self.my_points = p;
	
	return true;
end;


--- @section Querying

--- @function item
--- @desc Retrieves the nth vector in the convex area. Returns false if no vector exists at this index.
--- @p integer index
--- @return vector
function convex_area:item(index)
	if index > 0 and index <= #self.my_points then
		return self.my_points[index];
	end;
	
	return false;
end;


--- @function count
--- @desc Returns the number of vector positions that make up this convex area shape
--- @return integer number of positions
function convex_area:count()
	return #self.my_points;
end;


--- @function is_in_area
--- @desc Returns true if any element of the supplied object or collection is in the convex area, false otherwise.
--- @desc The second boolean flag, if set to true, instructs <code>is_in_area</code> to disregard any routing or dead units in the collection.
--- @p object collection, Object or collection to test. Supported object/collection types are vector, unit, scriptunit, scriptunits, units, army, armies, alliance and table.
--- @p [opt=false] boolean standing only, Disregard routing or dead units.
--- @return boolean any are in area
function convex_area:is_in_area(obj, standing_only)
	if is_vector(obj) then
		for i = 1, #self.my_points-1 do
			if not has_crossed_line(self.my_points[i], self.my_points[i+1], obj) then
				return false;
			end;
		end;
	
		if not has_crossed_line(self.my_points[#self.my_points], self.my_points[1], obj) then
			return false;
		end;
	
		return true;
	
	elseif is_unit(obj) then
		if (not standing_only) or (standing_only and not is_routing_or_dead(obj)) then
			return self:is_in_area(obj:position());
		end;
	
	elseif is_scriptunit(obj) then
		return self:is_in_area(obj.unit, standing_only);
	
	elseif is_scriptunits(obj) then
		for i = 1, obj:count() do
			if self:is_in_area(obj:item(i).unit, standing_only) then
				return true;
			end;
		end;
		
	elseif is_units(obj) then
		for i = 1, obj:count() do
			if self:is_in_area(obj:item(i), standing_only) then
				return true;
			end;
		end;
			
	elseif is_army(obj) then
		if self:is_in_area(obj:units(), standing_only) then
			return true;
		end;
		
		-- check all reinforcing armies
		for i = 1, obj:num_reinforcement_units() do
			local r_units = obj:get_reinforcement_units(i);
			local result = false;
			
			if is_units(r_units) then
				result = self:is_in_area(r_units, standing_only);
				
				if result then
					return true;
				end;
			end;
		end;
	
	elseif is_armies(obj) then
		for i = 1, obj:count() do
			if self:is_in_area(obj:item(i), standing_only) then
				return true;
			end;
		end;
		
	elseif is_generatedarmy(obj) then
		return self:is_in_area(obj.sunits, standing_only);
		
	elseif is_alliance(obj) then
		return self:is_in_area(obj:armies(), standing_only);
	
	elseif is_table(obj) then
		for i = 1, #obj do
			if self:is_in_area(obj[i], standing_only) then
				return true;
			end;
		end;
		
	else
		script_error("ERROR: convex_area:is_in_area() called but parameter " .. tostring(obj) .. " not supported!")
	end;
	
	return false;
end;


--- @function standing_is_in_area
--- @desc Alias for <code>is_in_area(obj, <strong>true</strong>)</code>. Returns true if any element of the supplied object or collection is in the convex area, false otherwise. Supported object/collection types are vector, unit, scriptunit, scriptunits, units, army, armies, alliance and table. Disregards routing or dead units.
--- @p object object or collection to test
--- @return boolean any are in area
function convex_area:standing_is_in_area(obj)
	return self:is_in_area(obj, true);
end;


--- @function not_in_area
--- @desc Returns true if any element of the supplied object or collection is NOT in the convex area, false otherwise.
--- @desc The second boolean flag, if set to true, instructs <code>not_in_area</code> to disregard any routing or dead units in the collection.
--- @p object collection, Object or collection to test. Supported object/collection types are vector, unit, scriptunit, scriptunits, units, army, armies, alliance and table.
--- @p [opt=false] boolean standing only, Disregard routing or dead units.
--- @return boolean any are not in area
function convex_area:not_in_area(obj, standing_only)
	if is_vector(obj) then
		if not self:is_in_area(obj) then
			return true;
		end;
	
	elseif is_unit(obj) then
		if (not standing_only) or (standing_only and not is_routing_or_dead(obj)) then
			return self:not_in_area(obj:position());
		end;
	
	elseif is_scriptunit(obj) then
		return self:not_in_area(obj.unit, standing_only);
	
	elseif is_scriptunits(obj) then
		for i = 1, obj:count() do
			if self:not_in_area(obj:item(i).unit, standing_only) then
				return true;
			end;
		end;
		
	elseif is_units(obj) then
		for i = 1, obj:count() do
			if self:not_in_area(obj:item(i), standing_only) then
				return true;
			end;
		end;
			
	elseif is_army(obj) then
		if self:not_in_area(obj:units(), standing_only) then
			return true;
		end;
		
		-- check all reinforcing armies
		for i = 1, obj:num_reinforcement_units() do
			local r_units = obj:get_reinforcement_units(i);
			local result = false;
			
			if is_units(r_units) then
				result = self:not_in_area(r_units, standing_only);
				
				if result then
					return true;
				end;
			end;
		end;
			
	elseif is_armies(obj) then
		for i = 1, obj:count() do
			if self:not_in_area(obj:item(i), standing_only) then
				return true;
			end;
		end;
	
	elseif is_alliance(obj) then
		return self:not_in_area(obj:armies(), standing_only);
	
	elseif is_table(obj) then
		for i = 1, #obj do
			if self:not_in_area(obj[i], standing_only) then
				return true;
			end;
		end;
		
	else
		script_error("ERROR: convex_area:not_in_area() called but parameter " .. tostring(obj) .. " not supported!")
	end;
	
	return false;
end;


--- @function standing_not_in_area
--- @desc Alias for <code>not_in_area(obj, <strong>true</strong>)</code>. Returns true if any element of the supplied object or collection is NOT in the convex area, false otherwise.
--- @p object collection, Object or collection to test. Supported object/collection types are vector, unit, scriptunit, scriptunits, units, army, armies, alliance and table. Disregards routing or dead units.
--- @return boolean any are not in area
function convex_area:standing_not_in_area(obj)
	return self:not_in_area(obj, true);
end;


--- @function number_in_area
--- @desc Returns the number of elements in the target collection that fall in the convex area.
--- @desc The second boolean flag, if set to true, instructs <code>number_in_area</code> to disregard any routing or dead units in the collection.
--- @p object collection, Object or collection to test. Supported object types are unit, units, scriptunit, scriptunits, army, armies, alliance and table. 
--- @p [opt=false] boolean standing only, Disregard routing or dead units.
--- @return integer number in area
function convex_area:number_in_area(obj, standing_only)
	local count = 0;
	
	if is_vector(obj) then
		if self:is_in_area(obj) then
			return 1;
		end;
		
	elseif is_unit(obj) then
		if self:is_in_area(obj, standing_only) then
			return 1;
		end;
		
	elseif is_scriptunit(obj) then
		if self:is_in_area(obj.unit, standing_only) then
			return 1;
		end;

	elseif is_scriptunits(obj) then
		for i = 1, obj:count() do
			if self:is_in_area(obj:item(i).unit, standing_only) then
				count = count + 1;
			end;
		end;
		
	elseif is_units(obj) then
		for i = 1, obj:count() do
			if self:is_in_area(obj:item(i), standing_only) then
				count = count + 1;
			end;
		end;
			
	elseif is_army(obj) then
		count = count + self:number_in_area(obj:units(), standing_only);
				
		-- check all reinforcing armies
		for i = 1, obj:num_reinforcement_units() do
			local r_units = obj:get_reinforcement_units(i);
			
			if is_units(r_units) then
				count = count + self:number_in_area(r_units, standing_only);
			end;
		end;

	elseif is_armies(obj) then
		for i = 1, obj:count() do
			count = count + self:number_in_area(obj:item(i), standing_only);
		end;
	
	elseif is_alliance(obj) then
		return self:number_in_area(obj:armies(), standing_only);
	
	elseif is_table(obj) then
		for i = 1, #obj do
			count = count + self:number_in_area(obj[i], standing_only);
		end;
		
	else
		script_error("ERROR: convex_area:is_in_area() called but parameter " .. tostring(obj) .. " not supported!")
	end;
	
	return count;
end;


--- @function standing_number_in_area
--- @desc Alias for <code>standing_number_in_area(obj, <strong>true</strong>)</code>. Returns the number of elements in the target collection that fall in the convex area. 
--- @p object collection, Object or collection to test. Supported object types are unit, units, scriptunit, scriptunits, army, armies, alliance and table. isregards routing or dead units.
--- @return integer number in area
function convex_area:standing_number_in_area(obj)
	return self:number_in_area(obj, true);
end;




