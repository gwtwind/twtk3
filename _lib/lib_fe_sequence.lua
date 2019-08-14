


-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	HISTORIC BATTLE FRONTEND SEQUENCES
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------


fe_hb_sequence = {
	name = "",
	timer_name = "",
	advice = {},
	graphics = {},
	eh = nil,
	timers = nil,
	current_advice = 1,
	is_playing = false,
	end_callback = nil,
	uic = nil,
	fade_out_on_end = false,
	post_advice_pause = 1000,
	post_sequence_pause = 1000
};



function fe_hb_sequence:new(new_name, new_eh, new_tm, new_end_callback)
	if not is_string(new_name) then
		script_error("ERROR: trying to create fe_sequence but name given [" .. tostring(new_name) .. "] is not a string");
		return false;
	end;
	
	if not is_eventhandler(new_eh) then
		script_error("ERROR: trying to create fe_sequence but event handler specified [" .. tostring(new_eh) .. "] is not an event handler");
		return false;
	end;

	if not is_timermanager(new_tm) then
		script_error("ERROR: trying to create fe_sequence but timer object supplied [" .. tostring(new_tm) .. "] is not a timer manager");
		return false;
	end;
	
	if not is_function(new_end_callback) then
		script_error("ERROR: trying to create fe_sequence but end callback supplied [" .. tostring(new_end_callback) .. "] is not a function");
		return false;
	end;

	local fe = {};
	
	setmetatable(fe, self);
	self.__tostring = function() return TYPE_FE_HB_SEQUENCE end;
	self.__index = self;
	
	fe.name = new_name;
	fe.timer_name = new_name .. "_fe_hb_sequence";
	fe.eh = new_eh;
	fe.tm = new_tm;
	fe.end_callback = new_end_callback;
	fe.advice = {};
	fe.graphics = {};
	
	return fe;
end;


function fe_hb_sequence:add_advice(...)
	for i = 1, arg.n do
		if is_string(arg[i]) then
			table.insert(self.advice, arg[i]);
		else
			script_error(self.name .. " fe_hb_sequence WARNING: add_advice called but supplied parameter " .. i .. " [" .. tostring(arg[i]) .. "] is not a string");
		end;
	end;
end;


function fe_hb_sequence:add_graphic(new_component, new_fade_in_anim, new_fade_in_time, new_fade_out_anim, new_fade_out_time)
	if not is_string(new_component) then
		script_error(self.name .. " fe_hb_sequence ERROR: add_graphic called but component name supplied [" .. tostring(new_component) .. "] is not a string");
		return;
	end;
	
	if not is_string(new_fade_in_anim) then
		script_error(self.name .. " fe_hb_sequence ERROR: add_graphic called but fade in anim supplied [" .. tostring(new_fade_in_anim) .. "] is not a string");
		return;
	end;
	
	if not is_number(new_fade_in_time) then
		script_error(self.name .. " fe_hb_sequence ERROR: add_graphic called but fade in time supplied [" .. tostring(new_fade_in_time) .. "] is not a number");
		return;
	end;
	
	if not is_string(new_fade_out_anim) then
		script_error(self.name .. " fe_hb_sequence ERROR: add_graphic called but fade out anim supplied [" .. tostring(new_fade_out_anim) .. "] is not a string");
		return;
	end;
	
	if not is_number(new_fade_out_time) then
		script_error(self.name .. " fe_hb_sequence ERROR: add_graphic called but fade out time supplied [" .. tostring(new_fade_out_time) .. "] is not a number");
		return;
	end;
	
	local new_graphic = {
		component = new_component,
		fade_in_anim = new_fade_in_anim,
		fade_in_time = new_fade_in_time,
		fade_out_anim = new_fade_out_anim,
		fade_out_time = new_fade_out_time
	};
	
	table.insert(self.graphics, new_graphic);
end;


function fe_hb_sequence:contains_graphic(component)
	for i = 1, #self.graphics do
		if self.graphics[i].component == component then
			return i;
		end;
	end;
	
	return false;
end;




function fe_hb_sequence:play_graphic(component, start_advice, start_advice_time, end_advice, end_advice_time)
	if not is_string(component) then
		script_error(self.name .. " fe_hb_sequence ERROR: play_graphic called but component name supplied [" .. tostring(component) .. "] is not a string");
		return;
	end;
	
	local graphic_index = self:contains_graphic(component);
	
	if not graphic_index then
		script_error(self.name .. " fe_hb_sequence ERROR: play_graphic called but supplied component name [" .. tostring(component) .. "] has not been added with add_graphic()");
		return;
	end;
	
	if not is_number(start_advice) or start_advice <= 0 or start_advice > #self.advice then
		script_error(self.name .. " fe_hb_sequence ERROR: play_graphic called but start advice supplied [" .. tostring(start_advice) .. "] is not a valid number");
		return;
	end;
	
	if not is_number(start_advice_time) or start_advice_time < 0 then
		script_error(self.name .. " fe_hb_sequence ERROR: play_graphic called but start advice time supplied [" .. tostring(start_advice_time) .. "] is not a positive number");
		return;
	end;
	
	if not is_number(end_advice) then
		script_error(self.name .. " fe_hb_sequence ERROR: play_graphic called but end advice supplied [" .. tostring(end_advice) .. "] is not a valid number");
		return;
	end;
	
	if not is_number(end_advice_time) or end_advice_time < 0 then
		script_error(self.name .. " fe_hb_sequence ERROR: play_graphic called but end advice time supplied [" .. tostring(end_advice_time) .. "] is not a positive number");
		return;
	end;
	
	
	local graphic = self.graphics[graphic_index];
	
	graphic.start_advice = start_advice;
	graphic.start_advice_time = start_advice_time;
	graphic.end_advice = end_advice;
	graphic.end_advice_time = end_advice_time;
	graphic.is_visible = false;
	graphic.is_fading_in = false;
end;







function fe_hb_sequence:play(uic)
	if #self.advice == 0 then
		script_error(self.name .. " ERROR: play() called but no advice loaded");
		return false;
	end;
	
	if self.is_playing then
		script_error(self.name .. " ERROR: play() called but sequence is already playing");
		return false;
	end;
	
	if not uic then
		script_error(self.name .. " ERROR: play() called but no UIComponent specified");
		return false;
	end;
	
	self.uic = uic;
	self.is_playing = true;
	self.current_advice = 1;
	
	print("Playing historic battle sequence: " .. self.name);
	
	self:play_next();
end;


function fe_hb_sequence:fade_in_graphic(graphic)
	-- play animation
	-- UIComponent(UIComponent(uic:Find("hb_image_container")):Find(graphic.component)):TriggerAnimation(graphic.fade_in_anim);
	UIComponent(uic:Find(graphic.component)):TriggerAnimation(graphic.fade_in_anim);
	
	print("\t\t" .. self.name .. " is fading in graphic " .. graphic.component .. " with animation " .. graphic.fade_in_anim .. ", starting " .. tostring(graphic.start_advice_time) .. "ms after advice #" .. tostring(graphic.start_advice) .. " in sequence");
					
	-- register that the animation is playing while it is
	graphic.is_fading_in = true;
	self.tm:callback(
		function() 
			graphic.is_fading_in = false;
			graphic.is_visible = true;
		end, 
		graphic.fade_in_time,
		self.timer_name
	);
end;




function fe_hb_sequence:fade_out_graphic(graphic)
	--UIComponent(UIComponent(uic:Find("hb_image_container")):Find(graphic.component)):TriggerAnimation(graphic.fade_out_anim);
	UIComponent(uic:Find(graphic.component)):TriggerAnimation(graphic.fade_out_anim);
	
	print("\t\t" .. self.name .. " is fading out graphic " .. graphic.component .. " with animation " .. graphic.fade_out_anim .. ", starting " .. tostring(graphic.end_advice_time) .. "ms after advice #" .. tostring(graphic.end_advice) .. " in sequence");
	
	graphic.is_visible = false;
end;





function fe_hb_sequence:play_next()

	-- if we've overrun the end of our advice list, finish
	if self.current_advice > #self.advice then
		self.is_playing = false;
		
		if self.fade_out_on_end then
			for i = 1, #self.graphics do
				local current_graphic = self.graphics[i];
				
				if current_graphic.is_visible or current_graphic.is_fading_in then
					self:fade_out_graphic(current_graphic);
				end;
			end;
		end;
		
		
		if is_function(self.end_callback) then
			print("\t" .. self.name .. ": finished");
			self.tm:callback(function() self.end_callback() end, self.post_sequence_pause, self.timer_name);
		end;
		return;
	end;
	
	
	-- otherwise, play the next advice
	local advice_to_add = self.advice[self.current_advice];
	-- local played_audio = self.uic:InterfaceFunction("AddAdvice", advice_to_add);
	local played_audio = interface_function(self.uic, "AddAdvice", advice_to_add);
	print("\t" .. self.name .. ": adding advice " .. advice_to_add);
	
	-- record the time of the last event for this advice section, so we can work out how long we have to
	-- play it in the event that the audio is disabled (in which case we'd never get the event)
	local last_event = 4000;
	
	-- queue up the relevant animations
	for i = 1, #self.graphics do
		local current_graphic = self.graphics[i];
		
		if current_graphic.start_advice == self.current_advice then
			if current_graphic.start_advice_time == 0 then
				self:fade_in_graphic(current_graphic);
			else
				self.tm:callback(function() self:fade_in_graphic(current_graphic) end, current_graphic.start_advice_time, self.timer_name);
			end;
			
			if current_graphic.start_advice_time > last_event then
				last_event = current_graphic.start_advice_time;
			end;
		end;
		
		if current_graphic.end_advice == self.current_advice then
			self.tm:callback(function() self:fade_out_graphic(current_graphic) end, current_graphic.end_advice_time, self.timer_name);
			
			if current_graphic.end_advice_time > last_event then
				last_event = current_graphic.end_advice_time;
			end;
		end;
	end;
	
	if played_audio then
		core:add_listener(
			self.timer_name,
			"AdviceFinishedTrigger",
			true,
			function()
				self.tm:callback(
					function()
						self.current_advice = self.current_advice + 1;
						self:play_next();
					end,
					self.post_advice_pause,
					self.timer_name
				);
			end,
			false
		);
	else
		-- for if not audio is played
		self.tm:callback(
			function()
				self.current_advice = self.current_advice + 1;
				self:play_next();
			end,
			last_event + 2000,
			self.timer_name
		);
	end;
end;


function fe_hb_sequence:skip()
	if not self.is_playing then
		return;
	end;

	self.is_playing = false;
	
	for i = 1, #self.graphics do
		local current_graphic = self.graphics[i];
		
		-- immediately hide component if it's fading in
		if current_graphic.is_fading_in then			
			UIComponent(UIComponent(uic:Find("hb_image_container")):Find(current_graphic.component)):SetVisible(false);
		elseif current_graphic.is_visible then
			UIComponent(UIComponent(uic:Find("hb_image_container")):Find(current_graphic.component)):TriggerAnimation(current_graphic.fade_out_anim);
		end;	
	end;
	
	core:remove_listener(self.timer_name);
	self.tm:remove_callback(self.timer_name);
	
	if is_function(self.end_callback) then
		self.tm:callback(function() self.end_callback() end, self.post_sequence_pause, self.timer_name);
	end;
end;









