


----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	TEXT POINTERS
--
--- @loaded_in_battle
--- @loaded_in_campaign
--- @loaded_in_frontend
--- @class text_pointer Text Pointers
--- @desc Text pointers are floating labels with optional attached arrows and close buttons that point to items on screen, drawing the player's attention there. They are primarily intended for use in tutorial scripts. They have been extended to show streaming text in cutscenes in battle, using @cutscene:show_custom_cutscene_subtitle.
--- @desc Text pointer objects are created with @text_pointer:new, configured, and then visually shown with @text_pointer:show. Once shown, a text pointer may be hidden again by calling text_pointer:hide. Alternatively, the core object provides the function @core_object:hide_all_text_pointers to hide all visible text pointers.
--- @desc A great many configuration options exist for text pointers. To simplify configuration as much as possible, a number of syles have been provided, each of which sets a range of configuration options automatically. Styles can be set with @text_pointer:set_style.
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------




--- @end_class
--- @section Type Checking


TYPE_TEXT_POINTER = "text_pointer";

--- @function is_textpointer
--- @desc Returns true if the supplied object is a text pointer, false otherwise.
--- @p object object
--- @return boolean is text pointer
function is_textpointer(obj)
	if tostring(obj) == TYPE_TEXT_POINTER then
		return true;
	end;
	
	return false;
end;


-- definition
text_pointer = {
	ui_root = nil,
	name = "",
	full_name = "",
	pointed_pos_x = 0,
	pointed_pos_y = 0,
	pointer_length = 0,
	pointer_width = 5,
	line_end_height = 15,
	line_end_width = 15,
	pointer_display_mode = "",
	layout_path = "UI/Common UI/",
	layout = "text_pointer_text_only",			-- text only by default
	line_parent_layout_path = "UI/Common UI/text_pointer_line_parent",
	docker_layout_path = "UI/Campaign UI/campaign_text_pointer_docker",
	text_pointer_parent_layout_path = "UI/Common UI/text_pointer_parent",
	component_overrides = {},
	component_priority = -1,
	is_showing = false,
	uic_text_label = false,
	uic_pointer_line_parent = false,
	uic_pointer_line = false,
	uic_pointer_line_end = false,
	uic_docker = false,
	should_set_topmost = false,
	x_offset = 0,
	y_offset = 0,
	worldspace_display_height = 0,
	should_pulse = false,
	panel_pulse_strength = 5,
	show_close_button = false,
	close_button_callback = false,
	close_button_callback_delay = 0,
	close_button_component_name = "button_close",
	hide_on_close_button_clicked = true,
	text_state_override = false,
	panel_state_override = false,
	panel_width_override = false,
	panel_width_to_screen_override = false,
	shrink_horizontally_if_one_line = false,
	highlight_close_button_wait_offset = false,
	close_button_is_highlighted = false,
	panel_show_animation = "show",
	panel_hide_animation = "hide",
	text_show_animation = false,
	text_hide_animation = false,
	position_as_subtitle = false,
	stream_by_char = false,
	stream_duration = false
};








----------------------------------------------------------------------------
--- @class text_pointer Text Pointers
--- @section Creation
----------------------------------------------------------------------------

--- @function new
--- @desc Creates a text_pointer object. Text pointers must be given a unique name, an x/y position, a pointer.
--- @p string name, Name for the text pointer. Must be unique amongst text pointers.
--- @p number x position, X position. This is either the absolute position on-screen, or the position in 3D space if the pointer display mode is set to worldspace. 
--- @p number y position, Y position. This is either the absolute position on-screen, or the position in 3D space if the pointer display mode is set to worldspace.
--- @p number length, Length of the attached arrow pointer and line. Can be zero.
--- @p string display mode, Pointer display mode. Determines in what direction the arrow pointer appears relative to the pointer label. Supported values:
--- @p_long_desc &emsp;- "top", the pointer line is drawn above the text label, pointing upwards
--- @p_long_desc &emsp;- "bottom", the pointer line is drawn below the text label, pointing downwards
--- @p_long_desc &emsp;- "left", the pointer line is drawn to the left of the text label, pointing to the left
--- @p_long_desc &emsp;- "right", the pointer line is drawn to the right of the text label, pointing to the right
--- @p_long_desc &emsp;- "worldspace", a special mode, whereby the text pointer appears in 3D space rather than 2D. In this case the pointer line appears below the text label.
--- @p_long_desc &emsp;- "subtitle", a special mode, whereby the text pointer appears and behaves as a cutscene subtitle in the lower cinematic bar. x/y positions are disregarded in this case.
--- @return text_pointer
function text_pointer:new(name, pointed_pos_x, pointed_pos_y, pointer_length, pointer_display_mode)

	if not is_string(name) then
		script_error("ERROR: attempt was made to create text pointer but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if core:is_text_pointer_name_registered(name) then
		script_error("ERROR: attempt was made to create text pointer but a pointer with supplied name [" .. tostring(name) .. "] has already been registered");
		return false;
	end;
	
	pointed_pos_x = pointed_pos_x or 0;
	
	if not is_number(pointed_pos_x) or pointed_pos_x < 0 then
		script_error("ERROR: attempt was made to create text pointer but supplied x co-ordinate [" .. tostring(pointed_pos_x) .. "] is not a positive number");
		return false;
	end;
	
	pointed_pos_y = pointed_pos_y or 0;
	
	if not is_number(pointed_pos_y) or pointed_pos_y < 0 then
		script_error("ERROR: attempt was made to create text pointer but supplied y co-ordinate [" .. tostring(pointed_pos_y) .. "] is not a positive number");
		return false;
	end;
	
	pointer_length = pointer_length or 0;
		
	if not is_number(pointer_length) or pointer_length < 0 then
		script_error("ERROR: attempt was made to create text pointer but supplied pointer length [" .. tostring(pointer_length) .. "] is not a positive number or nil");
		return false;
	end;
	
	if pointer_display_mode and not is_string(pointer_display_mode) then
		script_error("ERROR: attempt was made to create text pointer but supplied pointer display mode [" .. tostring(pointer_display_mode) .. "] is not a string or nil");
		return false;
	end;
	
	pointer_display_mode = pointer_display_mode or "bottom";
	
	if pointer_display_mode ~= "subtitle" and pointer_display_mode ~= "bottom" and pointer_display_mode ~= "top" and pointer_display_mode ~= "left" and pointer_display_mode ~= "right" and pointer_display_mode ~= "worldspace" then
		script_error("ERROR: attempt was made to create text pointer but supplied pointer display mode [" .. tostring(pointer_display_mode) .. "] is not recognised - valid values are \"top\", \"bottom\", \"left\", \"right\", \"subtitle\" and \"worldspace\"");
		return false;
	end;
	
	local tp = {};
	
	setmetatable(tp, self);
	self.__index = self;
	self.__tostring = function() return TYPE_TEXT_POINTER end;
	
	tp.ui_root = core:get_ui_root();
	
	tp.name = name;
	tp.full_name = "text_pointer_" .. name;
	tp.pointed_pos_x = pointed_pos_x;
	tp.pointed_pos_y = pointed_pos_y;
	tp.pointer_length = pointer_length;
	tp.pointer_display_mode = pointer_display_mode;
	tp.component_overrides = {};
	
	core:register_text_pointer_name(name);
	
	return tp;
end;







----------------------------------------------------------------------------
--- @section Layout Configuration
----------------------------------------------------------------------------

--- @function set_layout_path
--- @desc Sets the path to the folder that contains the component layout file. Default value is "UI/Common UI/".
--- @p string path
function text_pointer:set_layout_path(layout_path)
	if not is_string(layout_path) then
		script_error("ERROR: set_layout_path() called but supplied layout path [" .. tostring(layout_path) .. "] is not a string");
		return false;
	end;
	
	self.layout_path = layout_path;
end;


--- @function set_layout
--- @desc Sets the name of the layout to use for this text pointer. Default value is "text_pointer_text_only".
--- @p string path
function text_pointer:set_layout(layout_name)
	if not is_string(layout_name) then
		script_error("ERROR: set_layout() called but supplied layout name [" .. tostring(layout_name) .. "] is not a string");
		return false;
	end;
	
	self.layout = layout_name;
end;









----------------------------------------------------------------------------
--- @section Display Dimensions and Position
----------------------------------------------------------------------------


--- @function get_text_label
--- @desc Returns the text label uicomponent
--- @return uicomponent text label
function text_pointer:get_text_label()
	return self.uic_text_label;
end;


--- @function set_pointer_width
--- @desc Sets the width of the pointer line. Default width is 5 pixels.
--- @p number pointer width
function text_pointer:set_pointer_width(width)
	if not is_number(width) or width <= 0 then
		script_error(self.full_name .. " ERROR: set_pointer_width() called but supplied width [" .. tostring(width) .. "] is not a number > 0");
		return false;
	end;
	
	self.pointer_width = width;
end;


--- @function set_panel_width
--- @desc Sets the width of the text panel on-screen. The default width is set by the component layout.
--- @p number panel width, Width of panel on-screen in pixels.
--- @p [opt=false] boolean shrink horizontally, Shrink text horizontally if on one line.
function text_pointer:set_panel_width(override, shrink_horizontally_if_one_line)
	if not is_number(override) or override <= 0 then
		script_error(self.full_name .. " ERROR: set_panel_width() called but supplied override [" .. tostring(override) .. "] is not a number greater than zero");
		return false;
	end;
	
	self.panel_width_override = override;
	self.shrink_horizontally_if_one_line = shrink_horizontally_if_one_line;
end;


--- @function set_panel_width_to_screen
--- @desc Sets the width of the text panel on-screen to be the screen width minus a supplied numeric value.
--- @p number difference, Width of panel on-screen will be the screen width minus this value, in pixels.
--- @p [opt=false] boolean shrink horizontally, Shrink text horizontally if on one line.
function text_pointer:set_panel_width_to_screen(override, shrink_horizontally_if_one_line)
	if not is_number(override) or override < 0 then
		script_error(self.full_name .. " ERROR: set_panel_width_to_screen() called but supplied difference [" .. tostring(override) .. "] is not a positive number");
		return false;
	end;
	
	self.panel_width_to_screen_override = override;
	self.shrink_horizontally_if_one_line = shrink_horizontally_if_one_line;
end;


--- @function set_worldspace_display_height
--- @desc Sets the height of the terrain at the pointer position. This only needs to be set if the pointer is displaying in worldspace. The script has no way of determining the height of the terrain at a position in worldspace, so it must be supplied here.
--- @desc Without setting a height, a worldspace pointer will appear pointing to a height of 0, which will likely be beneath the terrain being pointed at.
--- @p number display height
function text_pointer:set_worldspace_display_height(value)
	if not is_number(value) then
		script_error("ERROR: set_worldspace_display_height() called but supplied height [" .. tostring(value) .. "] is not a number");
		return false;
	end;
	
	self.worldspace_display_height = value;
end;


--- @function set_label_offset
--- @desc Without setting a label offset, the text label with be centred to the position being pointed at e.g. centred directly above it if the display mode is set to "bottom", centred to the left if the display mode is set to "right" etc. Set a label offset to move the label relative to this position.
--- @p number x offset
--- @p number y offset
function text_pointer:set_label_offset(x_offset, y_offset)
	if not is_number(x_offset) then
		script_error(self.full_name .. " ERROR: set_label_offset() called but supplied x offset [" .. tostring(x_offset) .. "] is not a number");
		return false;
	end;
	
	if not is_number(y_offset) then
		script_error(self.full_name .. " ERROR: set_label_offset() called but supplied y offset [" .. tostring(y_offset) .. "] is not a number");
		return false;
	end;
	
	self.x_offset = x_offset;
	self.y_offset = y_offset;
end;











----------------------------------------------------------------------------
--- @section Component Priority and Topmost
----------------------------------------------------------------------------


--- @function set_priority
--- @desc Sets the component priority of the text pointer. This determines what components the text pointer is drawn on top of, and what components it is drawn underneath.
--- @p number priority
function text_pointer:set_priority(value)
	if not is_number(value) or value < 0 then
		script_error(self.full_name .. " ERROR: set_pointer_width() called but supplied width [" .. tostring(value) .. "] is not a positive number");
		return false;
	end;
	
	self.component_priority = value;
end;


--- @function set_topmost
--- @desc Sets the text pointer components to be topmost in the UI heirarchy.
--- @p [opt=true] boolean topmost
function text_pointer:set_topmost(value)
	if value == false then
		self.should_set_topmost = false;
	else
		self.should_set_topmost = true;
	end;
end;













----------------------------------------------------------------------------
--- @section Pulse Highlighting
----------------------------------------------------------------------------

--- @function set_should_pulse
--- @desc Sets the text pointer to pulse-highlight when it shows.
--- @p [opt=true] boolean pulse, Set to <code>true</code> to enable pulsing.
--- @p [opt=nil] number pulse strength, Pulse strength override. Supply a positive number here to modify the strength of the pulse. Default value is 5.
function text_pointer:set_should_pulse(value, panel_pulse_strength)
	if value == false then
		self.should_pulse = false;
	else
		self.should_pulse = true;
	end;
	
	if panel_pulse_strength then
		if not is_number(panel_pulse_strength) or panel_pulse_strength < 0 then
			script_error(self.name .. " WARNING: set_should_pulse() but supplied panel pulse strength value [" .. tostring(panel_pulse_strength) .. "] is not a positive number or nil - disregarding");
			return false;
		end;
		
		self.panel_pulse_strength = panel_pulse_strength;
	end;
end;










----------------------------------------------------------------------------
--- @section Streaming
----------------------------------------------------------------------------


--- @function set_stream_by_char
--- @desc Sets the text pointer to stream its text, and optionally sets the duration over which the text is to be streamed.
--- @p boolean should stream
--- @p [opt=nil] number stream duration
function text_pointer:set_stream_by_char(value, stream_duration)
	if stream_duration and (not is_number(stream_duration) or stream_duration <= 0) then
		script_error(self.full_name .. " ERROR: set_stream_by_char() called but supplied stream duration [" .. tostring(stream_duration) .. "] is not a number greater than zero");
		return false;
	end;
	
	if value == false then
		self.stream_by_char = false;
	else
		self.stream_by_char = true;
	end;
	
	if stream_duration then
		self.stream_duration = stream_duration;
	end;
end;


--- @function set_stream_duration
--- @desc Sets just the duration over which the text is to be streamed.
--- @p number stream duration
function text_pointer:set_stream_duration(stream_duration)
	if not is_number(stream_duration) or stream_duration <= 0 then
		script_error(self.full_name .. " ERROR: set_stream_duration() called but supplied stream duration [" .. tostring(stream_duration) .. "] is not a number greater than zero");
		return false;
	end;
	
	self.stream_duration = stream_duration;
end;










----------------------------------------------------------------------------
--- @section Show and Hide Animations
----------------------------------------------------------------------------


--- @function set_panel_show_animation
--- @desc Sets a different panel show animation. Any animation set here must be present on the panel component in the text pointer layout. Default is "show".
--- @p string animation name
function text_pointer:set_panel_show_animation(anim)
	if not is_string(anim) then
		script_error(self.full_name .. " ERROR: set_panel_show_animation() called but supplied animation name [" .. tostring(anim) .. "] is not a string");
		return false;
	end;
	
	self.panel_show_animation = anim;
end;


--- @function set_panel_hide_animation
--- @desc Sets a different panel hide animation. Any animation set here must be present on the panel component in the text pointer layout. Default is "hide".
--- @p string animation name
function text_pointer:set_panel_hide_animation(anim)
	if not is_string(anim) then
		script_error(self.full_name .. " ERROR: set_panel_hide_animation() called but supplied animation name [" .. tostring(anim) .. "] is not a string");
		return false;
	end;
	
	self.panel_hide_animation = anim;
end;


--- @function set_text_show_animation
--- @desc Sets a text show animation. Any animation set here must be present on the line component in the text pointer layout.
--- @p string animation name
function text_pointer:set_text_show_animation(anim)
	if not is_string(anim) then
		script_error(self.full_name .. " ERROR: set_text_show_animation() called but supplied animation name [" .. tostring(anim) .. "] is not a string");
		return false;
	end;
	
	self.text_show_animation = anim;
end;


--- @function set_text_hide_animation
--- @desc Sets a text hide animation. Any animation set here must be present on the line component in the text pointer layout.
--- @p string animation name
function text_pointer:set_text_hide_animation(anim)
	if not is_string(anim) then
		script_error(self.full_name .. " ERROR: set_text_show_animation() called but supplied animation name [" .. tostring(anim) .. "] is not a string");
		return false;
	end;
	
	self.text_hide_animation = anim;
end;













----------------------------------------------------------------------------
--- @section State Overrides
----------------------------------------------------------------------------


--- @function set_panel_state_override
--- @desc Sets a different state for the text pointer panel. Any state set here must be present on the panel component in the text pointer layout.
--- @p string state name
function text_pointer:set_panel_state_override(override)
	if not is_string(override) then
		script_error(self.full_name .. " ERROR: set_panel_state_override() called but supplied override [" .. tostring(override) .. "] is not a string");
		return false;
	end;
	
	self.panel_state_override = override;
end;


--- @function set_text_state_override
--- @desc Sets a different state for each line of text pointer panel. Any state set here must be present on the line component in the text pointer layout.
--- @p string state name
function text_pointer:set_text_state_override(override)
	if not is_string(override) then
		script_error(self.full_name .. " ERROR: set_text_state_override() called but supplied override [" .. tostring(override) .. "] is not a string");
		return false;
	end;
	
	self.text_state_override = override;
end;









----------------------------------------------------------------------------
--- @section Close Button
----------------------------------------------------------------------------


--- @function set_show_close_button
--- @desc Shows a close button on the text pointer. By default a close button is not shown.
--- @p [opt=true] boolean show button
function text_pointer:set_show_close_button(value)
	if value == false then
		self.show_close_button = false;
	else
		self.show_close_button = true;
	end;
end;


--- @function set_hide_on_close_button_clicked
--- @desc Hides the text pointer when the close button is clicked. By default, this is enabled, so the panel closes when the button is clicked.
--- @p [opt=true] boolean close on click
function text_pointer:set_hide_on_close_button_clicked(value)
	if value == false then
		self.hide_on_close_button_clicked = false;
	else
		self.hide_on_close_button_clicked = true;
	end;
end;


--- @function set_close_button_callback
--- @desc Set a callback to call when the close button is clicked. An optional delay may also be set. This also sets the close button to show.
--- @p function callback, Callback
--- @p [opt=0] number delay, Delay before calling callback, in s (campaign) or ms (battle/frontend)
function text_pointer:set_close_button_callback(callback, delay)
	if not is_function(callback) then
		script_error(self.full_name .. " ERROR: set_close_button_callback() called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	delay = delay or 0;
	
	if not is_number(delay) or delay < 0 then
		script_error(self.full_name .. " ERROR: set_close_button_callback() called but supplied callback delay [" .. tostring(delay) .. "] is not a number > 0");
	end;
	
	self.show_close_button = true;
	self.close_button_callback = callback;
	self.close_button_callback_delay = delay;
end;


--- @function set_close_button_component
--- @desc Overrides the component to use as the close button, by name.
--- @p string component name
function text_pointer:set_close_button_component(component_name)
	if not is_string(component_name) then
		script_error(self.full_name .. " ERROR: set_close_button_component() called but supplied component name [" .. tostring(component_name) .. "] is not a string");
		return false;
	end;
	
	self.close_button_component_name = component_name;
end;


--- @function set_highlight_close_button
--- @desc Instructs the text pointer to highlight the close button when it shows, with an optional delay between the time of showing and the time the close button is highlighted. Immediately highlights the close button if the text pointer is already showing.
--- @p [opt=0] delay, Period the text pointer should wait after being shown before the button highlight begins. This is specified in s in campaign, ms in battle or the frontend.
--- @p_long_desc This is disregarded if the text pointer is already showing at the time this function is called.
function text_pointer:set_highlight_close_button(wait_offset)	
	if self.is_showing then
		self:highlight_close_button();
		return;
	end;

	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error(self.full_name .. " ERROR: highlight_close_button() called but supplied wait offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	self.highlight_close_button_wait_offset = wait_offset;
end;













----------------------------------------------------------------------------
--- @section Subtitle Mode
----------------------------------------------------------------------------


--- @function set_position_as_subtitle
--- @desc Sets the text pointer to position itself/behave as a cutscene subtitle, in the lower cinematic bar. This is akin to setting the pointer display mode to "subtitle" in @text_pointer:new.
--- @p [opt=true] position as subtitle
function text_pointer:set_position_as_subtitle(value)
	if value == false then
		self.position_as_subtitle = false;
	else
		self.position_as_subtitle = true;
	end;
end;










----------------------------------------------------------------------------
--- @section Relative Positioning to Text Pointer
----------------------------------------------------------------------------


--- @function set_position_offset_to_text_pointer
--- @desc Sets the position of this text pointer relative to another pointer. Calling this function overrides this text pointer's display mode, and causes it to display relative to another text pointer's position when shown.
--- @p text_pointer text pointer, Text pointer object to display relative to.
--- @p number x offset, x offset in pixels from the other text pointer. This takes into account the other text pointer's size, so the two text pointers cannot overlap.
--- @p_long_desc Supplying a value of 10 would mean a gap of 10 pixels between the two text pointers, with this text pointer on the right of the other, while a value of -10 would mean a gap of 10 pixels with this text pointer on the left.
--- @p number y offset, y offset in pixels from the other text pointer. This takes into account the other text pointer's size, so the two text pointers cannot overlap.
--- @p_long_desc Supplying a value of 10 would mean a gap of 10 pixels between the two text pointers, with this text pointer below the other (as a higher value of y means a position further down the screen), while a value of -10 would mean a gap of 10 pixels with this text pointer above the other.
function text_pointer:set_position_offset_to_text_pointer(pointer, x_offset, y_offset)
	
	if not is_textpointer(pointer) then
		script_error(self.full_name .. " ERROR: set_position_offset_to_text_pointer() called but supplied text pointer [" .. tostring(pointer) .. "] is not a valid text pointer");
		return false;
	end;
	
	if pointer == self then
		script_error(self.full_name .. " ERROR: set_position_offset_to_text_pointer() called but supplied text pointer [" .. tostring(pointer) .. "] is this text pointer - you can't do this!");
		return false;
	end;
	
	if not is_number(x_offset) then
		script_error(self.full_name .. " ERROR: set_position_offset_to_text_pointer() called but supplied x offset [" .. tostring(x_offset) .. "] is not a number");
		return false;
	end;
	
	if not is_number(y_offset) then
		script_error(self.full_name .. " ERROR: set_position_offset_to_text_pointer() called but supplied y offset [" .. tostring(y_offset) .. "] is not a number");
		return false;
	end;
	
	if x_offset == 0 and y_offset == 0 then
		script_error(self.full_name .. " ERROR: set_position_offset_to_text_pointer() called but both supplied x offset and supplied y offset are 0");
		return false;
	end;
	
	if x_offset ~= 0 and y_offset ~= 0 then
		script_error(self.full_name .. " WARNING: set_position_offset_to_text_pointer() called but both supplied x offset and supplied y offset are not 0 - the y offset will be discarded");
		return false;
	end;
	
	self.pointer_display_mode = "offset";
	self.position_offset_from_text_pointer = pointer;
	self.position_offset_from_text_pointer_x = x_offset;
	self.position_offset_from_text_pointer_y = y_offset;
end;


function text_pointer:add_component_text(component_name, override_text, exempt_from_streaming)
	if not is_string(component_name) and not is_number(component_name) then
		script_error(self.full_name .. " ERROR: add_component_text() called but supplied component id [" .. tostring(component_name) .. "] is not a string or a number");
		return false;
	end;
	
	if not is_string(override_text) then
		script_error(self.full_name .. " ERROR: add_component_text() called but supplied text label [" .. tostring(override_text) .. "] is not a string");
		return false;
	end;
	
	local override_record = {};
	
	override_record.component_name = component_name;
	override_record.override_text = override_text;
	override_record.exempt_from_streaming = not not exempt_from_streaming;
	
	table.insert(self.component_overrides, override_record);
end;












----------------------------------------------------------------------------
--- @section Showing and Hiding
----------------------------------------------------------------------------


--- @function show
--- @desc Makes the text pointer visible.
--- @p [opt=false] force display, Forces the text pointer to display. This flag is only considered if the text pointer has been set to behave as a subtitle with @text_pointer:set_position_as_subtitle, and if set to <code>true</code> causes the text pointer to override the player's subtitles preferences.
function text_pointer:show(force_display)

	-- don't proceed if this text point is emulating subtitles, subtitles are disabled, and the force_display flag is not set
	if self.position_as_subtitle and not effect.subtitles_enabled() and not force_display then
		return;
	end;
	
	local ui_root = self.ui_root;					-- root
	local uic_text_pointer_parent = false;			-- parent component of all text pointers, child of root
	
	local uic_text_label = false;					-- text box, child of uic_text_pointer_parent
	local uic_pointer_line_parent = false;			-- parent component of the line, only used if a line is needed. Also a child of uic_text_pointer_parent
	local uic_pointer_line = false;					-- the visible line, only created if needed. Child of uic_pointer_line_parent
	local uic_pointer_line_end = false;				-- the arrow on the end of the line, only created if needed. Child of uic_pointer_line_parent
	
	local uic_docker = false;						-- worldspace docker, only used if the label is positioned in worldspace. Child of uic_text_pointer_parent
	
	do
		-- get or create text pointer parent
		local parent_was_created = false;
		uic_text_pointer_parent, parent_was_created = core:get_or_create_component("text_pointer_parent", self.text_pointer_parent_layout_path);
	
		-- set the priority of the line parent at this point, and make the root component re-adopt it
		uic_text_pointer_parent:PropagatePriority(self.component_priority);
		
		if parent_was_created then
			ui_root:Adopt(uic_text_pointer_parent:Address());
		end;
	end;
	
	local pointer_display_mode = self.pointer_display_mode;
	
	-- get/create text label
	uic_text_label = core:get_or_create_component(self.full_name, self.layout_path .. self.layout, uic_text_pointer_parent);
	
	-- create the line
	local pointer_length = self.pointer_length;
	
	if pointer_length > 0 then
		-- get/create line parent
		uic_pointer_line_parent = core:get_or_create_component(self.full_name .. "_line_parent", self.line_parent_layout_path, uic_text_pointer_parent);
		uic_pointer_line = find_uicomponent(uic_pointer_line_parent, "line");
		uic_pointer_line_end = find_uicomponent(uic_pointer_line_parent, "line_end");
		
		output_uicomponent(uic_pointer_line_parent);
		output_uicomponent(uic_pointer_line);
		output_uicomponent(uic_pointer_line_end);
	end;
	
	self.is_showing = true;
	
	-- override panel state if we've been told to
	if self.panel_state_override then
		uic_text_label:SetState(self.panel_state_override);
	end;
	
	-- calculate a panel width override at this point if we have a panel_width_to_screen_override
	if self.panel_width_to_screen_override then
		local screen_x, screen_y = core:get_screen_resolution();
		
		self.panel_width_override = screen_x - self.panel_width_to_screen_override;
	end;
	
	uic_text_label:SetCanResizeWidth(true);
	
	local parser = get_link_parser();
	
	out.design("*** " .. self.full_name .. " showing text pointer");
	
	-- fill out text label components with component overrides
	local component_overrides = self.component_overrides;
		
	for i = 1, #component_overrides do
		local override_record = component_overrides[i];
		local component_name = override_record.component_name;
		local override_text = override_record.override_text;		
		local uic_to_override = find_uicomponent(uic_text_label, component_name);
		
		if not uic_to_override then
			script_error(self.name .. " ERROR: show() attempted to find component [" .. component_name .. "] to override but was unable to do so");
			return false;
		end;
		
		-- override component state if we've been told to
		if self.text_state_override then
			uic_to_override:SetState(self.text_state_override);
		elseif self.panel_state_override then
			uic_to_override:SetState(self.panel_state_override);
		end;
		
		-- get the localised text for this override
		local localised_text = false;
		
		if pointer_display_mode == "worldspace" then
			localised_text = parser:parse_for_no_links(effect.get_localised_string(override_text));
		else
			localised_text = parser:parse_for_tooltips(effect.get_localised_string(override_text));
		end;
		
		override_record.localised_text = localised_text;
		override_record.localised_text_len = string.len(localised_text);
		override_record.uic = uic_to_override;
		
		-- set the text
		uic_to_override:SetStateText(localised_text);
		
		-- override component width if we should
		if self.panel_width_override then
			uic_to_override:ResizeTextResizingComponentToInitialSize(self.panel_width_override, uic_to_override:Height());
			
			-- if we're now only on one line, shrink to fit horizontally if we should
			if self.shrink_horizontally_if_one_line then
				local text_x, text_y, text_l = uic_to_override:TextDimensions();
				
				if text_x < self.panel_width_override then
					uic_to_override:ResizeTextResizingComponentToInitialSize(text_x, uic_to_override:Height());
				end;
				
				-- resize the component again to pull in any deadspace that got generated below it
				local text_x, text_y, text_l = uic_to_override:TextDimensions();
				uic_to_override:ResizeTextResizingComponentToInitialSize(text_x, text_y);
			else
				-- resize the component again to pull in any deadspace that got generated below it
				local text_x, text_y, text_l = uic_to_override:TextDimensions();
				uic_to_override:ResizeTextResizingComponentToInitialSize(self.panel_width_override, text_y);
			end;
			
			out.design("\toverriding component [" .. component_name .. "] to localised text [" .. localised_text .. "] with width [" .. self.panel_width_override .. "]");
		else
			out.design("\toverriding component [" .. component_name .. "] to localised text [" .. localised_text .. "]");
		end;
		
		uic_to_override:SetInteractive(true);
	end;
	
	-- show a close button if we should
	if self.show_close_button then
		local uic_close_button = find_uicomponent(uic_text_label, self.close_button_component_name);
		
		out.design("\tshowing close button");
		
		if uic_close_button then
			local uic_button_parent = UIComponent(uic_close_button:Parent());
		
			-- resize the width of the close button parent if we have resized the width of the panel
			if self.panel_width_override then
				uic_button_parent:ResizeTextResizingComponentToInitialSize(self.panel_width_override, uic_button_parent:Height());
			end;
			
			-- position it relative to the bottom-right of the text panel (useful if we've resized the panel)
			local label_pos_x, label_pos_y = uic_text_label:Position();
			local label_size_x, label_size_y = uic_text_label:Dimensions();
			
			local button_size_x, button_size_y = uic_close_button:Dimensions();
			
			uic_close_button:MoveTo(label_pos_x + label_size_x - (button_size_x + 10), label_pos_y + label_size_y - (button_size_y + 10));
		
			-- make the close button and parent visible
			uic_close_button:SetVisible(true);
			uic_button_parent:SetVisible(true);
			
			local close_callback = function()
				-- un-steal the escape key
				if core:is_campaign() then
					get_cm():release_escape_key_with_callback(self.full_name);
				else
					get_bm():release_escape_key_with_callback(self.full_name);
				end;
				
				core:remove_listener(self.full_name .. "_close_button_clicked");
			
				-- hide the button
				uic_close_button:SetVisible(false);
				
				-- unhighlight close button, and stop any pending highlight
				self:highlight_close_button(false);
				self:stop_pending_highlight();
			
				-- hide the text pointer if we should
				if self.hide_on_close_button_clicked then
					self:hide();
				end;
			
				-- call callback if we should
				if self.close_button_callback then
					if self.close_button_callback_delay == 0 then
						self.close_button_callback(context);
					else
						-- not safe to pass in context if we're delaying call
						if core:is_campaign() then
							get_cm():callback(function() self.close_button_callback() end, self.close_button_callback_delay);
						else
							get_tm():callback(function() self.close_button_callback() end, self.close_button_callback_delay);
						end;
					end;
				end;
			end;
			
			-- steal ESC key
			if core:is_campaign() then
				get_cm():steal_escape_key_with_callback(
					self.full_name,
					function()
						out.design("*** " .. self.full_name .. ": ESC key pressed");
						close_callback();
					end
				);
			else
				get_bm():steal_escape_key_with_callback(
					self.full_name,
					function()
						out.design("*** " .. self.full_name .. ": ESC key pressed");
						close_callback();
					end
				);
			end;
			
			-- set up a listener for the close button being clicked
			core:add_listener(
				self.full_name .. "_close_button_clicked",
				"ComponentLClickUp",
				function(context) 
					-- return true if the grandparent of the clicked button is the text label
					return UIComponent(UIComponent(UIComponent(context.component):Parent()):Parent()) == self.uic_text_label end,
				function(context)
					out.design("*** " .. self.full_name .. ": close button clicked");
					close_callback();
				end,
				true
			);
			
			-- highlight the close button after a period, if we should
			local highlight_close_button_wait_offset = self.highlight_close_button_wait_offset;
			if highlight_close_button_wait_offset then	
				if highlight_close_button_wait_offset == 0 then
					self:highlight_close_button(true);
				else
					if core:is_campaign() then
						get_cm():callback(function() self:highlight_close_button(true) end, highlight_close_button_wait_offset, self.full_name);
					else
						get_tm():callback(function() self:highlight_close_button(true) end, highlight_close_button_wait_offset, self.full_name);
					end;
				end;
			end;
		else
			script_error(self.name .. " WARNING: show() failed to find close button with name " .. self.close_button_component_name .. ", no close button will be displayed");
		end;
	end;
	
	uic_text_label:SetCanResizeWidth(false);
	
	-- position this text pointer is pointing to
	local pointed_pos_x = self.pointed_pos_x;
	local pointed_pos_y = self.pointed_pos_y;
	
	local label_size_x, label_size_y = uic_text_label:Dimensions();
	local label_pos_x, label_pos_y = 0;
	
	local line_size_x = 0;
	local line_size_y = 0;
	local line_pos_x = 0;
	local line_pos_y = 0;
	local line_image_rot = 0;
	
	local line_end_size_x = 0;
	local line_end_size_y = 0;
	local line_end_pos_x = 0;
	local line_end_pos_y = 0;
	local line_end_image_rot = 0;
	
	-- calculate positions of label and line
	if self.position_as_subtitle or pointer_display_mode == "subtitle" then
		-- we are setting our position in the subtitle bar
		local screen_x, screen_y = core:get_screen_resolution();
	
		label_pos_x = (screen_x - label_size_x) / 2;
		label_pos_y = (screen_y - 80) - label_size_y / 2;
		
		-- apply label offset
		label_pos_x = label_pos_x + self.x_offset;
		label_pos_y = label_pos_y + self.y_offset;
		
	elseif pointer_display_mode == "offset" then
		-- we are setting our position relative to another text pointer
		local foreign_pointer = self.position_offset_from_text_pointer;	
		local offset_x = self.position_offset_from_text_pointer_x;
		local offset_y = self.position_offset_from_text_pointer_y;
		
		local foreign_text_label = self.position_offset_from_text_pointer:get_text_label();
		
		if not foreign_text_label then
			script_error(self.name .. " ERROR: trying to show text pointer with offset [" .. offset_x .. ", " .. offset_y .. "] from another pointer with name [" .. foreign_pointer.name .. "] but no foreign text label could be found - has it not been shown yet?");
			return false;
		end;
		
		local foreign_pos_x, foreign_pos_y = foreign_text_label:Position();
		local foreign_size_x, foreign_size_y = foreign_text_label:Dimensions();
		
		if offset_x < 0 then
			-- our label is to the left of the foreign label
			label_pos_x = foreign_pos_x - (label_size_x + offset_x);
			label_pos_y = foreign_pos_y;
		elseif offset_x > 0 then
			-- our label is to the right of the foreign label
			label_pos_x = foreign_pos_x + foreign_size_x + offset_x;
			label_pos_y = foreign_pos_y;
		elseif offset_y < 0 then
			-- our label is above the foreign label
			label_pos_x = foreign_pos_x;
			label_pos_y = foreign_pos_y - (label_size_y + offset_y);
		elseif offset_y > 0 then
			-- our label is below the foreign label
			label_pos_x = foreign_pos_x;
			label_pos_y = foreign_pos_y - (label_size_y + offset_y);
		else
			script_error(self.name .. " ERROR: trying to set position offset from text pointer but both our x and y offsets are 0 - how can this be?");
			return false;
		end;
		
		-- apply label offset
		label_pos_x = label_pos_x + self.x_offset;
		label_pos_y = label_pos_y + self.y_offset;
		
		out.design("\tsetting position of label from foreign pointer at [" .. label_pos_x .. ", " .. label_pos_y .. "]");
	
	elseif pointer_display_mode == "bottom" then
		-- pointer line is drawn below the text label
		label_pos_x = math.floor(pointed_pos_x - (label_size_x / 2));
		label_pos_y = pointed_pos_y - (label_size_y + pointer_length);
		
		-- apply label offset
		label_pos_x = label_pos_x + self.x_offset;
		label_pos_y = label_pos_y + self.y_offset;
		
		line_end_image_rot = math.pi / 2;
		line_image_rot = line_end_image_rot;
		
		line_size_x = pointer_length - self.line_end_width;					-- size of line prior to rotating
		line_size_y = self.pointer_width;
		
		line_pos_x = math.floor(pointed_pos_x - line_size_x / 2);
		line_pos_y = math.floor(pointed_pos_y - (self.line_end_width + line_size_x / 2 + line_size_y / 2));
		
		line_end_pos_x = math.floor(pointed_pos_x - self.line_end_width / 2);
		line_end_pos_y = pointed_pos_y - self.line_end_height;
		
		out.design("\tsetting position of label at [" .. label_pos_x .. ", " .. label_pos_y .. "], line is below");
		out.design("\t\tpointed position is [" .. pointed_pos_x .. ", " .. pointed_pos_y .. "] line size is [" .. line_size_x .. ", " .. line_size_y .. "] at position [" .. line_pos_x .. ", " .. line_pos_y .. "]");
		
	elseif pointer_display_mode == "top" then
		-- pointer line is drawn above the text label
		label_pos_x = math.floor(pointed_pos_x - (label_size_x / 2));
		label_pos_y = pointed_pos_y + pointer_length;
		
		-- apply label offset
		label_pos_x = label_pos_x + self.x_offset;
		label_pos_y = label_pos_y + self.y_offset;
		
		line_end_image_rot = math.pi * 3 / 2;
		line_image_rot = line_end_image_rot;
		
		line_size_x = pointer_length - self.line_end_width;					-- size of line prior to rotating
		line_size_y = self.pointer_width;
		
		line_pos_x = math.floor(pointed_pos_x - line_size_x / 2);
		line_pos_y = math.floor(pointed_pos_y + self.line_end_width + line_size_x / 2 - line_size_y / 2);
		
		line_end_pos_x = math.floor(pointed_pos_x - self.line_end_width / 2);
		line_end_pos_y = pointed_pos_y;
		
		out.design("\tsetting position of label at [" .. label_pos_x .. ", " .. label_pos_y .. "], line is above");
		out.design("\t\tpointed position is [" .. pointed_pos_x .. ", " .. pointed_pos_y .. "] line size is [" .. line_size_x .. ", " .. line_size_y .. "] at position [" .. line_pos_x .. ", " .. line_pos_y .. "]");
		
	elseif pointer_display_mode == "left" then
		-- pointer line is drawn to the left of the text label
		label_pos_x = pointed_pos_x + pointer_length;
		label_pos_y = math.floor(pointed_pos_y - (label_size_y / 2));
		
		-- apply label offset
		label_pos_x = label_pos_x + self.x_offset;
		label_pos_y = label_pos_y + self.y_offset;
		
		line_end_image_rot = math.pi;
		line_image_rot = line_end_image_rot;
		
		line_size_x = pointer_length - self.line_end_width;					-- size of line prior to rotating
		line_size_y = self.pointer_width;
		
		line_pos_x = pointed_pos_x + self.line_end_width;
		line_pos_y = math.floor(pointed_pos_y - line_size_y / 2);
		
		line_end_pos_x = pointed_pos_x;
		line_end_pos_y = math.floor(pointed_pos_y - self.line_end_height / 2);
		
		out.design("\tsetting position of label at [" .. label_pos_x .. ", " .. label_pos_y .. "], line is to the left");
		out.design("\t\tpointed position is [" .. pointed_pos_x .. ", " .. pointed_pos_y .. "] line size is [" .. line_size_x .. ", " .. line_size_y .. "] at position [" .. line_pos_x .. ", " .. line_pos_y .. "]");
		
	elseif pointer_display_mode == "right" then
		-- pointer line is drawn to the right of the text label
		label_pos_x = pointed_pos_x - (label_size_x + pointer_length);
		label_pos_y = math.floor(pointed_pos_y - (label_size_y / 2));
		
		-- apply label offset
		label_pos_x = label_pos_x + self.x_offset;
		label_pos_y = label_pos_y + self.y_offset;
		
		line_end_image_rot = 0;
		line_image_rot = 0;
		
		line_size_x = pointer_length - self.line_end_width;					-- size of line prior to rotating
		line_size_y = self.pointer_width;
		
		line_pos_x = pointed_pos_x - pointer_length;
		line_pos_y = math.floor(pointed_pos_y - line_size_y / 2);
		
		line_end_pos_x = pointed_pos_x - self.line_end_width;
		line_end_pos_y = math.floor(pointed_pos_y - self.line_end_height / 2);
		
		out.design("\tsetting position of label at [" .. label_pos_x .. ", " .. label_pos_y .. "], line is to the right");
		out.design("\t\tpointed position is [" .. pointed_pos_x .. ", " .. pointed_pos_y .. "] line size is [" .. line_size_x .. ", " .. line_size_y .. "] at position [" .. line_pos_x .. ", " .. line_pos_y .. "]");
		
	elseif pointer_display_mode == "worldspace" then
		-- pointer and text label are drawn in worldspace
		
		-- create the docker
		uic_docker = core:get_or_create_component(self.full_name .. "_docker", self.docker_layout_path, uic_text_pointer_parent);
		
		-- have the docker adopt the text label and pointer
		uic_docker:Adopt(uic_text_label:Address());
		if uic_pointer_line then
			uic_docker:Adopt(uic_pointer_line_parent:Address());
		end;
		
		local docker_x, docker_y = uic_docker:Position();
		
		label_pos_x = math.floor(docker_x - label_size_x / 2);
		label_pos_y = docker_y - (label_size_y + pointer_length);
		
		-- apply label offset
		label_pos_x = label_pos_x + self.x_offset;
		label_pos_y = label_pos_y + self.y_offset;
		
		line_end_image_rot = math.pi / 2;
		line_image_rot = line_end_image_rot;
		
		line_size_x = pointer_length - self.line_end_width;					-- size of line prior to rotating
		line_size_y = self.pointer_width;
		
		line_pos_x = math.floor(docker_x - line_size_x / 2);
		line_pos_y = math.floor(docker_y - (self.line_end_width + line_size_x / 2 + line_size_y / 2));
		
		line_end_pos_x = math.floor(docker_x - self.line_end_width / 2);
		line_end_pos_y = math.floor(docker_y - self.line_end_height);
		
		-- disable depth rendering
		uic_docker:SetProperty("depth_disabled", "1");
		
		out.design("\tsetting position of label in worldspace");
		
		out.design("\t\tdocker pos [" .. docker_x .. ", " .. docker_y .. "], line size [" .. line_size_x .. ", " .. line_size_y .. "], line pos [" .. line_pos_x .. ", " .. line_pos_y .. "], line end pos [" .. line_end_pos_x .. ", " .. line_end_pos_y .."]");
		out.design("\t\tlabel pos [" .. label_pos_x .. ", " .. label_pos_y .. "], and label size [" .. label_size_x .. ", " .. label_size_y .. "]");
		
	else
		script_error(self.full_name .. " ERROR: show() called but didn't recognise pointer display mode [" .. tostring(pointer_display_mode) .. "] - how can this be?");
		return false;
	end;
	
	-- reposition/resize text label
	uic_text_label:MoveTo(label_pos_x, label_pos_y);
		
	-- set component priority
	if uic_docker then
		uic_docker:PropagatePriority(self.component_priority);
		
		if self.should_set_topmost then
			out.design("\tpropagating docker priority [" .. tostring(self.component_priority) .. "] and setting topmost");
			uic_docker:RegisterTopMost();
		else
			out.design("\tpropagating docker priority [" .. tostring(self.component_priority) .. "]");
		end;
	else
		uic_text_label:PropagatePriority(self.component_priority);
		
		if self.should_set_topmost then
			out.design("\tpropagating text label priority [" .. tostring(self.component_priority) .. "] and setting topmost");
			uic_text_label:RegisterTopMost();
		else
			out.design("\tpropagating text label priority [" .. tostring(self.component_priority) .. "]");
		end;
		
		-- show the label
		uic_text_label:SetVisible(true);
		uic_text_label:TriggerAnimation(self.panel_show_animation);
	end;
	
	-- reposition, set priority and show the line
	if uic_pointer_line then
		uic_pointer_line:Resize(line_size_x, line_size_y);
		uic_pointer_line:MoveTo(line_pos_x, line_pos_y);
		uic_pointer_line:SetImageRotation(0, line_image_rot);
		
		uic_pointer_line_end:MoveTo(line_end_pos_x, line_end_pos_y);
		uic_pointer_line_end:SetImageRotation(0, line_end_image_rot);
		
		uic_pointer_line_parent:PropagatePriority(self.component_priority);
		
		if self.should_set_topmost then
			uic_pointer_line_parent:RegisterTopMost();
			out.design("\tpropagating line priority [" .. tostring(self.component_priority) .. "] and setting topmost");
		else
			out.design("\tpropagating line priority [" .. tostring(self.component_priority) .. "]");
		end;
		
		uic_pointer_line_parent:SetVisible(true);
		uic_pointer_line_parent:TriggerAnimation(self.panel_show_animation);
		-- uic_pointer_line:TriggerAnimation(self.panel_show_animation);
		-- uic_pointer_line_end:TriggerAnimation(self.panel_show_animation);
	end;
	
	-- position the docker in worldspace if we have one
	if uic_docker then
		out.design("\tpositioning docker in worldspace at [" .. tostring(self.pointed_pos_x) .. ", " .. tostring(self.worldspace_display_height) .. ", " .. tostring(self.pointed_pos_y) .. "]");
		uic_docker:SetProperty("x", tostring(self.pointed_pos_x));
		uic_docker:SetProperty("y", tostring(self.worldspace_display_height));
		uic_docker:SetProperty("z", tostring(self.pointed_pos_y));
	end;
	
	-- play any additional animations on the various text components if we have to
	if self.text_show_animation then
		for i = 1, #component_overrides do
			local override_record = component_overrides[i];
		
			-- only proceed with animating this component if we are not set to stream in, or if we are and this record is set to be exempt
			if not (self.stream_text_by_word or self.stream_text_by_char) or override_record.exempt_from_streaming then
				local uic_to_animate = find_uicomponent(uic_text_label, override_record.component_name);
			
				if not uic_to_animate then
					script_error(self.name .. " ERROR: show() attempted to find component [" .. override_record.component_name .. "] whilst playing show animation but was unable to do so, how can this be?");
					return false;
				end;
				
				uic_to_animate:TriggerAnimation(self.text_show_animation);
			end;
		end;
	end;
	
	uic_text_label:SetInteractive(true);
	
	-- make the panel pulse if we should
	if self.should_pulse then
		pulse_uicomponent(uic_text_label, true, self.panel_pulse_strength, true);
	end;
	
	self.uic_text_label = uic_text_label;
	self.uic_pointer_line = uic_pointer_line;
	self.uic_pointer_line_end = uic_pointer_line_end;
	self.uic_pointer_line_parent = uic_pointer_line_parent;
	self.uic_docker = uic_docker;
	
	-- listen for a destroy message
	core:add_listener(
		self.full_name,
		"ScriptEventHideTextPointers",
		true,
		function() self:hide() end,
		false
	);
	
	-- stream text (if we should)
	if self.stream_by_char then
		self:start_streaming_text();
	end;
end;


-- internal function to enable or disable a highlight on the close button
function text_pointer:highlight_close_button(value)
	if not self.is_showing then
		return;
	end;
	
	if value and not self.close_button_is_highlighted then
		local uic_close_button = find_uicomponent(self.uic_text_label, self.close_button_component_name);
		
		if not uic_close_button then
			return;
		end;
	
		self.close_button_is_highlighted = true;
		
		uic_close_button:Highlight(true, false, self.component_priority + 100);
		
		return;
	end;
	
	if not value and self.close_button_is_highlighted then
		local uic_close_button = find_uicomponent(self.uic_text_label, self.close_button_component_name);
		
		if not uic_close_button then
			return;
		end;
	
		self.close_button_is_highlighted = false;
		
		uic_close_button:Highlight(false, false, self.component_priority + 100);
		
		return;
	end;
end;


-- internal function to start streaming text behaviour
function text_pointer:start_streaming_text()
	
	-- mark the first override as active, and count the number of characters
	local override_marked_as_active = false;
	local chars_in_stream = 0;
	for i = 1, #self.component_overrides do
		local override_record = self.component_overrides[i];
		if not override_record.exempt_from_streaming then
			if not override_marked_as_active then
				override_marked_as_active = true;
				override_record.is_streaming = true;
				override_record.bookmark = 0;
			end;
			
			chars_in_stream = chars_in_stream + string.len(override_record.localised_text);
		end;
	end;
	
	-- return if there is nothing to stream
	if not override_marked_as_active then
		return;
	end;
	
	local chars_per_update = 1;
	local update_time = 100;
	
	if core:is_campaign() then
		update_time = 0.1;
	end;
	
	-- if we have a desired stream duration, work out what the ideal per-char interval is based on the number of chars in the stream
	if self.stream_duration then
		chars_per_update = 0.1 * chars_in_stream / self.stream_duration;
	end;

	-- chars_per_update needs to be >= 1 - double it, and the update time, until it is
	while chars_per_update < 1 do
		chars_per_update = chars_per_update * 2;
		update_time = update_time * 2;
	end;
	
	self:update_streaming_text_by_char(chars_per_update, update_time);
end;


-- internal function to update streaming text behaviour
function text_pointer:update_streaming_text_by_char(chars_per_update, update_time, chars_remaining_this_update)
	
	-- characters we actually have the budget to show this tick
	chars_remaining_this_update = chars_remaining_this_update or chars_per_update;
	
	-- find the next char to show
	for i = 1, #self.component_overrides do
		local override_record = self.component_overrides[i];
		
		if override_record.is_streaming then
			local bookmark = override_record.bookmark;
			local bookmark_floor = math.floor(bookmark);		-- last char displayed
			
			if bookmark + chars_per_update > override_record.localised_text_len then
			
				-- we will overrun the end of the current text if we try and display all our chars
				override_record.is_streaming = nil;
				override_record.bookmark = nil;
				
				if bookmark_floor <= override_record.localised_text_len then
					-- we still have some characters at the end of this line to display - show them, make the next line eligible and then re-call this function with the remainder					
					override_record.uic:SetStateText(override_record.localised_text);
					
					chars_remaining_this_update = chars_per_update - (override_record.localised_text_len - bookmark_floor);
				end;		
				
				-- if we are not on the last overriden component then mark the next eligible line as active and re-call the function, otherwise don't do anything as we are finished
				local next_line_additive = 1;
				while true do
					if i + next_line_additive > #self.component_overrides then
						-- there are no more lines that are not exempt, we are finished
						return;
					else
					
						local next_override_record = self.component_overrides[i + next_line_additive];
					
						if not next_override_record.exempt_from_streaming then
							next_override_record.is_streaming = true;
							next_override_record.bookmark = 0;
							
							self:update_streaming_text_by_char(chars_per_update, update_time, chars_remaining_this_update);
							return;
						end;
					end;
				end;				
			else
				-- assemble and show the updated display text
				local localised_text = override_record.localised_text;
				local divide_point = bookmark_floor + math.floor(chars_remaining_this_update);
				local text_to_display = string.sub(localised_text, 1, divide_point) .. "[[opacity:0]]" .. string.sub(localised_text, divide_point + 1) .. "[[/opacity]]";
				
				override_record.uic:SetStateText(text_to_display);
				override_record.bookmark = bookmark + chars_remaining_this_update;
				
				-- show the next character in a bit 
				if core:is_campaign() then
					get_cm():callback(function() self:update_streaming_text_by_char(chars_per_update, update_time) end, update_time, self.full_name);
				else
					get_tm():callback(function() self:update_streaming_text_by_char(chars_per_update, update_time) end, update_time, self.full_name);
				end;
			end;
		end;
	end;
end;


-- internal function to cancel any pending close-button highlights
function text_pointer:stop_pending_highlight()
	if self.highlight_close_button_wait_offset and not self.close_button_is_highlighted then	
		if core:is_campaign() then
			get_cm():remove_callback(self.full_name);
		else
			get_tm():remove_callback(self.full_name);
		end;
	end;
end;


--- @function hide
--- @desc Hides the text pointer. Supply <code>true</code> as a single argument to hide it immediately and prevent it from animating.
--- @p [opt=false] hide immediately
function text_pointer:hide(immediately)
	if not self.is_showing then
		return;
	end;
	
	-- unhighlight the close button (should there be one and should it be highlighted)
	self:highlight_close_button(false);
	
	-- cancel any pending close button highlights
	self:stop_pending_highlight();
	
	local uic_text_label = self.uic_text_label;
	local uic_docker = self.uic_docker;
	
	-- stop any pulsing
	if self.should_pulse then
		if core:is_campaign() then
			get_cm():callback(function() pulse_uicomponent(uic_text_label, false, self.panel_pulse_strength, true) end, 0.5);
		else
			get_tm():callback(function() pulse_uicomponent(uic_text_label, false, self.panel_pulse_strength, true) end, 500);
		end;
	end;
	
	self.is_showing = false;
	core:remove_listener(self.full_name);
	
	if core:is_campaign() then
		get_cm():remove_callback(self.full_name);
	else
		get_tm():remove_callback(self.full_name);
	end;
	
	-- hide immediately if we should
	if immediately then
		if uic_docker then
			uic_docker:SetVisible(false);
			out.design("*** " .. self.full_name .. " hiding docker immediately");
			
			if self.should_set_topmost then
				uic_docker:RemoveTopMost();
			end;
		else			
			uic_text_label:SetVisible(false);
			
			if self.uic_pointer_line then
				self.uic_pointer_line:SetVisible(false);
				self.uic_pointer_line_end:SetVisible(false);
				out.design("*** " .. self.full_name .. " hiding text label and line immediately");
			else
				out.design("*** " .. self.full_name .. " hiding text label immediately");
			end;
			
			if self.should_set_topmost then
				uic_text_label:RemoveTopMost();
				
				if self.uic_pointer_line then
					self.uic_pointer_line:RemoveTopMost();
					self.uic_pointer_line_end:RemoveTopMost();
				end;
			end;
		end;
		
		return;
	end;
	
	-- or play the hide animations
	if uic_docker then
		uic_docker:TriggerAnimation(self.panel_hide_animation);
		out.design("*** " .. self.full_name .. " hiding docker with animation");
		
		if self.should_set_topmost then
			uic_docker:RemoveTopMost();
		end;
	else
		uic_text_label:TriggerAnimation(self.panel_hide_animation);
		
		if self.uic_pointer_line then
			self.uic_pointer_line:TriggerAnimation(self.panel_hide_animation);
			self.uic_pointer_line_end:TriggerAnimation(self.panel_hide_animation);
			self.uic_pointer_line_parent:TriggerAnimation(self.panel_hide_animation);
			out.design("*** " .. self.full_name .. " hiding text label and line with animation");
		else
			out.design("*** " .. self.full_name .. " hiding text label with animation");
		end;
	end;
	
	-- play any additional animations on the various text components if we have to
	if self.text_hide_animation then
		for i = 1, #self.component_overrides do
			local override_record = self.component_overrides[i];
			local component_name = override_record.component_name;
		
			local uic_to_animate = find_uicomponent(uic_text_label, component_name);
		
			if not uic_to_animate then
				script_error(self.name .. " ERROR: show() attempted to find component [" .. component_name .. "] whilst playing show animation but was unable to do so, how can this be?");
				return false;
			end;
			
			uic_to_animate:TriggerAnimation(self.text_hide_animation);
		end;
	end;
end;





----------------------------------------------------------------------------
--- @section Styles
----------------------------------------------------------------------------


--- @function set_style
--- @desc Sets the style of this text pointer. Setting a style automatically sets a range of configuration options common to that style - inspect the script function to find out what exactly gets set or to add more styles. Current supported styles are:
--- @desc &emsp;- standard
--- @desc &emsp;- semitransparent_worldspace
--- @desc &emsp;- semitransparent
--- @desc &emsp;- semitransparent_large
--- @desc &emsp;- semitransparent_2_sec_highlight
--- @desc &emsp;- e3_subtitle_with_frame
--- @desc &emsp;- subtitle_with_frame
--- @p string style
function text_pointer:set_style(style, param1)

	if style == "standard" then
		self:set_priority(1500);
		self:set_topmost();
	elseif style == "semitransparent_worldspace" then
		self:set_panel_state_override("semitransparent");
	elseif style == "semitransparent" then
		self:set_priority(1500);
		self:set_topmost();
		self:set_panel_state_override("semitransparent");
	elseif style == "semitransparent_large" then
		self:set_priority(1500);
		self:set_topmost();
		self:set_panel_state_override("semitransparent_large");
	elseif style == "semitransparent_2_sec_highlight" then
		self:set_priority(1500);
		self:set_topmost();
		self:set_panel_state_override("semitransparent");
		self:set_highlight_close_button(2);
		self:set_hide_on_close_button_clicked(false);
	elseif style == "e3_subtitle_with_frame" then
		self:set_priority(1500);
		self:set_topmost();
		self:set_panel_state_override("framed");
		self:set_text_state_override("e3_subtitle");
		self:set_panel_show_animation("show_500ms");
		self:set_panel_hide_animation("hide_500ms");
		self:set_text_hide_animation("slide_out_br_500ms");
		self:set_position_as_subtitle(true);
		self:set_panel_width_to_screen(300, true);
		self:set_stream_by_char(true);
	elseif style == "subtitle_with_frame" then
		self:set_priority(1500);
		self:set_topmost();
		self:set_panel_state_override("framed");
		self:set_text_state_override("subtitle");
		self:set_panel_show_animation("show_500ms");
		self:set_panel_hide_animation("hide_500ms");
		self:set_text_hide_animation("slide_out_br_500ms");
		self:set_position_as_subtitle(true);
		self:set_panel_width_to_screen(300, true);
		self:set_stream_by_char(true);
	end;
end;


