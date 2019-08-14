




----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	GENERATED BATTLE
--
--- @loaded_in_battle
---	@class generated_battle Generated Battle
--- @desc The generated battle system is designed to allow scripters to create battles of moderate complexity relatively cheaply. The central premise of the generated battle system is that events are directed without needing to refer to the individual units, which would be the case with full battle scripts. Instead, orders are given and conditions are detected at army level (or across the battle as a whole). This limits the complexity of what can be done but allows for a much simpler interface. The generated battle system is used to script most/all quest battles.
--- @desc A <code>generated_battle</code> object is created first with @generated_battle:new, and from that multiple @generated_army objects are created using calls to @generated_battle:get_army, one for each conceptual army on the battlefield. A conceptual army may be an entire army in the conventional sense, or it may be a collection of units within an army grouped together by a common script_name. 
--- @desc Commands are given through the use of messages, built on the @script_messager system. Once created, the <code>generated_battle</code> object and @generated_army objects can be instructed to listen for certain messages, and act in some manner when they are received. Additionally, the <code>generated_battle</code> and @generated_army objects can be instructed to trigger messages when certain conditions are met e.g. when under attack. Using these tools, scripted scenarios of surprising complexity may be constructed relatively easily. 
--- @desc The message listeners a <code>generated_battle</code> object provides can be viewed here: @"generated_battle:Message Listeners", and the messages it can generate can be viewed here: @"generated_battle:Message Generation". The message listeners a @generated_army object provides can be viewed here: @"generated_army:Message Listeners", and the messages it can generate can be viewed here: @"generated_army:Message Generation".
--- @desc In addition, the generated battle object sends the following messages during battle automatically:
--- @desc &emsp;-  <code><strong>"deployment_started"</strong></code> when the deployment phase begins.
--- @desc &emsp;-  <code><strong>"battle_started"</strong></code> when the playable combat phase begins.
--- @desc &emsp;-  <code><strong>"battle_ending"</strong></code> when the VictoryCountdown phase begins (someone has won).
--- @desc &emsp;-  <code><strong>"cutscene_ended"</strong></code> when any @cutscene ends.
--- @desc &emsp;-  <code><strong>"generated_custscene_ended"</strong></code> when a generated cutscene ends.
--- @desc &emsp;-  <code><strong>"outro_camera_finished"</strong></code> when the outro camera movement on a generated cutscene intro has finished.
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------



__generated_battle = nil;

__GENERATED_ARMY_IS_PLAYER = 0;
__GENERATED_ARMY_IS_ALLY_OF_PLAYER = 1;
__GENERATED_ARMY_IS_ENEMY_OF_PLAYER = 2;


generated_battle = {
	bm = nil,
	sm = nil,
	generated_armies = {},
	screen_starts_black = false,
	prevent_deployment_for_player = false,
	prevent_deployment_for_ai = false,
	intro_cutscene = nil,
	cutscene_during_deployment = false,
	end_deployment_phase_after_loading_screen = false,
	is_debug = false,
	battle_has_started = false,
	current_objectives = {}
};










----------------------------------------------------------------------------
---	@section Creation
----------------------------------------------------------------------------


--- @function new
--- @desc Creates an generated_battle. There should be only one of these per-battle script.
--- @p [opt=false] boolean screen starts black, The screen starts black. This should match the prepare_for_fade_in flag in the battle setup, which always seems to be true for quest battles. Furthermore, this flag is only considered if no intro cutscene callback is specified.
--- @p [opt=false] boolean prevent player deployment, Prevents player control during deployment.
--- @p [opt=false] boolean prevent ai deployment, Prevents deployment for the ai.
--- @p [opt=nil] function intro cutscene, Intro cutscene callback. This is called when deployment phase ends, unless @generated_battle:set_cutscene_during_deployment is set.
--- @p [opt=false] boolean debug mode, Turns on debug mode, for more output.
--- @return generated_battle
function generated_battle:new(screen_starts_black, prevent_deployment_for_player, prevent_deployment_for_ai, intro_cutscene, is_debug)
	screen_starts_black = screen_starts_black or false;
	prevent_deployment_for_player = prevent_deployment_for_player or false;
	is_debug = is_debug or false;
	
	if not is_nil(intro_cutscene) and not is_function(intro_cutscene) then
		script_error("ERROR: attempt made to create a generated_battle() but the supplied intro cutscene callback is not a function or nil");
		return;
	end;
		
	local gb = {};
	
	setmetatable(gb, self);
	self.__index = self;
	self.__tostring = function() return TYPE_GENERATED_BATTLE end;
	
	local bm = get_bm(true);
	local sm = get_messager();
	
	gb.bm = bm;
	gb.sm = sm;
	gb.screen_starts_black = screen_starts_black;
	gb.prevent_deployment_for_player = prevent_deployment_for_player;
	gb.prevent_deployment_for_ai = prevent_deployment_for_ai;
	gb.intro_cutscene = intro_cutscene;
	gb.is_debug = is_debug;
	
	bm:out("==============================");
	bm:out("==============================");
	bm:out("== generated_battle created ==");
	bm:out("==============================");
	bm:out("battle configuration file: " .. get_full_file_path(1));
	bm:out("==============================");
	
	-- build all our generated_army objects
	gb:build_armies();
	
	-- make a list of all currently-running objective keys
	gb.current_objectives = {};
	
	-- report on loaded armies
	gb:generated_armies_report();
	
	bm:out("==============================");
	
	-- deployment message
	bm:register_phase_change_callback(
		"Deployment", 
		function() 
			gb:start_deployment();
		end
	);
	
	-- ending deployment
	if prevent_deployment_for_player then
		bm:setup_battle(function() gb:start_battle() end);	
	else
		bm:register_phase_change_callback("Deployed", function() gb:start_battle() end);
	end;

	return gb;
end;


-- for internal use
function generated_battle:should_not_deploy_ai()
	return self.prevent_deployment_for_ai;
end;


-- prints a report to the console about loaded armies. For internal use.
function generated_battle:generated_armies_report()
	local generated_armies = self.generated_armies;

	self.bm:out("Armies report:");
	for i = 1, #generated_armies do
		local current_alliance = generated_armies[i];
		
		self.bm:out("\tAlliance " .. i .. " of " .. #self.generated_armies);
		
		for j = 1, #current_alliance do
			local current_armies = current_alliance[j];
			
			self.bm:out("\t\tArmy " .. j .. " of " .. #current_alliance);
			
			for k = 1, #current_armies do
				local current_army = current_armies[k];			
				local total_units = current_army.sunits:count();
				local army_id = current_army.id;
				local army_script_name = current_army.script_name;
				local append_str = "";
				
				if army_script_name ~= "" then
					append_str = ", script name is " .. tostring(army_script_name);
				end;
				
				if total_units == 1 then
					self.bm:out("\t\t\t" .. army_id .. " contains 1 unit" .. append_str);
				else
					self.bm:out("\t\t\t" .. army_id .. " contains " .. total_units .. " units" .. append_str);
				end;
				
			end;
		end;
	end;
end;


-- build the collection of generated armies for this battle
function generated_battle:build_armies()
	self.generated_armies = {};

	local alliances = self.bm:alliances();
				
	for i = 1, alliances:count() do
		local armies = alliances:item(i):armies();
		
		self.generated_armies[i] = {};
		
		if self.is_debug then
			self.bm:out("\tadding alliance " .. tostring(i) .. ":");
		end;
				
		for j = 1, armies:count() do
			local current_army = armies:item(j);
			
			self.generated_armies[i][j] = {};
			
			-- table of generated armies data to create with
			local generated_armies_to_create = {};
			
			-- count the number of units that we have
			local num_units = current_army:units():count();
			
			-- include reinforcing armies
			for k = 1, current_army:num_reinforcement_units() do
				local r_units = current_army:get_reinforcement_units(k);
				
				if is_units(r_units) then
					num_units = num_units + r_units:count();
				end;
			end;
			
			-- inspect the names of all the units in the army to determine how many different ga's we need to create
			for k = 1, num_units do
				local new_sunit = script_unit:new(current_army, k);
				
				if not is_scriptunit(new_sunit) then
					script_error("ERROR: generated_battle:build_armies() failed to create unit " .. k .. " in army " .. j .. ", alliance " .. i);
					return false;
				else
					-- we are currently using the scriptunit name to determine the army script name - this might change in future
					local army_script_name = new_sunit.unit:name();
					
					-- if the name is just a number then no custom name was actually set, so we reset it to ""
					if tonumber(army_script_name) then
						army_script_name = "";
					end;
					
					-- attempt to add this scriptunit to the army that matches its name
					local sunit_added = false;
					for l = 1, #generated_armies_to_create do
						if generated_armies_to_create[l].script_name == army_script_name then				
							generated_armies_to_create[l].sunits:add_sunits(new_sunit);
							sunit_added = true;
							break;
						end;
					end;
					
					-- if the sunit was not added anywhere, then create a new army record and add this sunit
					if not sunit_added then
						ga_record = {};
						ga_record.script_name = army_script_name;
						ga_record.sunits = script_units:new(army_script_name);
						ga_record.sunits:add_sunits(new_sunit);
						table.insert(generated_armies_to_create, ga_record);
					end;
				end;
			end;
			
			-- go through our list and build generated_army objects out of all the records we find
			for k = 1, #generated_armies_to_create do
				local current_army_rec = generated_armies_to_create[k];
			
				local ga = generated_army:new(current_army_rec.script_name, k, current_army_rec.sunits, self, self.is_debug);
				
				if self.is_debug then
					if current_army_rec.script_name == "" then
						self.bm:out("\t\tadding army " .. tostring(j) .. " containing " .. tostring(ga.sunits:count()) .. " units");
					else
						self.bm:out("\t\tadding army " .. tostring(j) .. " containing " .. tostring(ga.sunits:count()) .. " units with name " .. current_army_rec.script_name);
					end;			
				end;
				
				table.insert(self.generated_armies[i][j], ga);
			end;
		end;	
	end;
	
	self.bm:out(" ");
end;


-- called internally when deployment starts
function generated_battle:start_deployment()
	self.bm:out("Starting deployment.");
	self.sm:trigger_message("deployment_started");
	
	-- Generic message when loading screen is dismissed.
	core:progress_on_loading_screen_dismissed(
		function()
			self.sm:trigger_message("loading_screen_dismissed");
		end,
		true
	);

	if self.intro_cutscene then
		if self.cutscene_during_deployment then
			-- we have a cutscene and we should show it during deployment - hide the "Start Battle" button, show the cutscene, and then re-enable the button when the cutscene is completed
		
			-- toggle the start battle UI during the cutscene
			self.bm:show_start_battle_button(false);
			self.sm:add_listener(
				"cutscene_ended",
				function()
					self.bm:show_start_battle_button(true);
				end
			);
			
			core:progress_on_loading_screen_dismissed(
				function()
					self.intro_cutscene();
				end,
				true
			);
			return;
		elseif self.end_deployment_phase_after_loading_screen then
			core:progress_on_loading_screen_dismissed(
				function()
					self.bm:end_current_battle_phase();
				end,
				true
			);
		end;
	else
		-- enable the UI and fade in the camera if we have no intro cutscene, screen_starts_black is true and the player should be able to deploy
		if self.screen_starts_black and not self.prevent_deployment_for_player then
		
			self.bm:enable_cinematic_ui(false, true, false);
			self.bm:camera():fade(false, 0.5);
		end;

		if self.end_deployment_phase_after_loading_screen then
			core:progress_on_loading_screen_dismissed(function() self.bm:end_current_battle_phase() end);
		end;
	end;
end;


-- called internally when the playable battle starts
function generated_battle:start_battle()
	self.battle_has_started = true;

	self.bm:out("Starting generated battle");
	self.sm:trigger_message("battle_started");
	
	self.bm:setup_victory_callback(function() self:battle_ending() end);
		
	if self.cutscene_during_deployment and self.intro_cutscene then
		return;
	end;
	
	if self.intro_cutscene then	
		core:progress_on_loading_screen_dismissed(function() self.intro_cutscene() end, true);
	elseif self.screen_starts_black and self.prevent_deployment_for_player then
		-- enable the UI and fade in the camera if screen_starts_black is true and we didn't deploy
		self.bm:enable_cinematic_ui(false, true, false);
		self.bm:camera():fade(false, 0.5);
	end;
end;











----------------------------------------------------------------------------
---	@section Configuration
----------------------------------------------------------------------------


--- @function set_cutscene_during_deployment
--- @desc Sets the supplied intro cutscene callback specified in @generated_battle:new to play at the start of deployment, rather than at the end.
--- @p [opt=true] boolean play in deployment
function generated_battle:set_cutscene_during_deployment(value)
	if value == false then
		self.cutscene_during_deployment = false;
	else
		self.cutscene_during_deployment = true;
	end;
end;


function generated_battle:set_end_deployment_phase_after_loading_screen(value)
	if value == false then
		self.end_deployment_phase_after_loading_screen = false;
	else
		self.end_deployment_phase_after_loading_screen = true;
	end;
end;







----------------------------------------------------------------------------
---	@section Querying
----------------------------------------------------------------------------


--- @function has_battle_started
--- @desc Returns <code>true</code> if the combat phase of the battle has started, <code>false</code> otherwise.
--- @return boolean battle has started
function generated_battle:has_battle_started()
	return self.battle_has_started;
end;


--- @function get_player_alliance_num
--- @desc Returns the index of the alliance the player is a part of.
--- @return number index
function generated_battle:get_player_alliance_num()
	return bm:get_player_alliance_num();
end


--- @function get_non_player_alliance_num
--- @desc Returns the index of the enemy alliance to the player.
--- @return number index
function generated_battle:get_non_player_alliance_num()
	return bm:get_non_player_alliance_num();
end







----------------------------------------------------------------------------
---	@section Creating Generated Armies
--- @desc @generated_battle:get_army is called to create @generated_army objects.
----------------------------------------------------------------------------


--- @function get_army
--- @desc Returns a @generated_army corresponding to the supplied arguments. Use in one of two modes:
--- @desc &emsp;- Supply an alliance number, an army number, and (optionally) a script name. This is the original way armies were specified in quest battle scripts. Returns a @generated_army corresponding to the supplied alliance/army numbers, containing all units where the name matches the supplied script name (or all of them if one was not supplied). WARNING: at time of writing the ordering of armies in an alliance beyond the first cannot be guaranteed if loading from campaign, so specifying an army index in this case may not be a good idea.
--- @desc &emsp;- Supply an alliance number and an optional script name. This supports the randomised ordering of armies in an alliance that we see from campaign. If no script name
--- @return boolean battle has started is specified then it will be assumed that the script name is a blank string. No more than one army in the specified alliance can contain units with the supplied script name.
--- @return generated_army
function generated_battle:get_army(alliance_number, second_param, third_param)

	if not is_number(alliance_number) then
		script_error("ERROR: get_army() called but supplied alliance number [" .. tostring(alliance_number) .. "] is not a number");
		return false;
	end;
	
	-- if no second_param or third_param has been passed in, then set second_param to be a blank string
	if not second_param and not third_param then
		second_param = "";
	end;
	
	if is_number(second_param) then
		-- the user is specifying an alliance number, an army number, and (optionally) a script name
		return self:get_army_by_alliance_army_and_script_name(alliance_number, second_param, third_param);
	
	elseif is_string(second_param) then
		-- the user is specifying an alliance number and a script name

		-- try and determine the army_number ourselves, by looking through all armies in this alliance for an army with a matching script name
		-- if more than one army has a matching script name, throw an error
		local alliance = self.generated_armies[alliance_number];
		local army_number = false;
		
		for i = 1, #alliance do
			local current_army = alliance[i];
			
			for j = 1, #current_army do
				local current_sub_army = current_army[j];
				
				if current_sub_army.script_name == second_param then
					if army_number then
						script_error("ERROR: get_army() called but more than one army in specified alliance index [" .. alliance_number .. "] was found with the supplied name [" .. second_param .. "]");
						return false;
					else
						army_number = i;
					end;
				end;
			end;
		end;
		
		if not army_number then
			script_error("ERROR: get_army() called but no army in supplied alliance index [" .. alliance_number .. "] was found with the supplied name [" .. second_param .. "]");
			return false;
		end;
		
		return self:get_army_by_alliance_army_and_script_name(alliance_number, army_number, second_param);
		
	else
		script_error("ERROR: get_army() called but supplied second parameter [" .. second_param .. "] was not an integer army index or a string script name");
	end;	
end;


-- internal function to return a generated army when it has been specified by alliance number, army number, and (opt) a script name
function generated_battle:get_army_by_alliance_army_and_script_name(alliance_number, army_number, army_script_name)
	
	local armies = self.generated_armies[alliance_number][army_number];
	
	if not is_table(armies) then
		script_error("ERROR: get_army_by_alliance_army_and_script_name() called but no army was found with alliance number [" .. alliance_number .. "] and army number [" .. army_number .. "], check your battle definition");
		return false;
	end;
	
	army_script_name = army_script_name or "";
	
	if army_script_name == "" and #armies >= 1 then
		return armies[1];	
	end;
	
	for i = 1, #armies do
		local current_army = armies[i];
		
		if current_army.script_name == army_script_name then
			return current_army;
		end;
	end;
	
	if army_script_name == "" then
		script_error("ERROR: get_army() called but couldn't find a generated_army with no name matching supplied army number [" .. tostring(army_number) .. "], though the alliance was valid");
	else
		script_error("ERROR: get_army() called but couldn't find a generated_army with script name [" .. army_script_name .. "] matching supplied army number [" .. tostring(army_number) .. "], though the alliance was valid");
	end;
end;


--
--	Takes an alliance and army number, and returns a table of all sunits that are allied to this army.
--	Used internally by generated_army objects to build a list of all their allies.
function generated_battle:get_allied_force(alliance_num, army_num)
	local sunits_table = {};

	for i = 1, #self.generated_armies do
		if i == alliance_num then
			for j = 1, #self.generated_armies[i] do
				if j ~= army_num then
					for k = 1, #self.generated_armies[i][j] do
					
						-- add this force to the sunits_table force
						local generated_army_sunits = self.generated_armies[i][j][k].sunits;
						
						for l = 1, generated_army_sunits:count() do
							table.insert(sunits_table, generated_army_sunits:item(l));
						end;
					end;
				end;
			end;
		end;
	end;
	
	local sunits_allied = script_units:new("allied_sunits", sunits_table);
	return sunits_allied;
end;


--
--	Takes an alliance and army number, and returns a table of all sunits that are the enemy of this army.
--	Used internally by generated_army objects to build a list of all their enemies.
function generated_battle:get_enemy_force(alliance_num, army_num)
	local sunits_table = {};

	for i = 1, #self.generated_armies do
		if i ~= alliance_num then
			for j = 1, #self.generated_armies[i] do
				for k = 1, #self.generated_armies[i][j] do
					-- add this force to the sunits_table force
					local generated_army_sunits = self.generated_armies[i][j][k].sunits;
					
					for l = 1, generated_army_sunits:count() do					
						table.insert(sunits_table, generated_army_sunits:item(l));
					end;
				end;
			end;
		end;
	end;
	
	local sunits_enemy = script_units:new("enemy_sunits", sunits_table);
	return sunits_enemy;
end;








----------------------------------------------------------------------------
---	@section Script Message Listeners
----------------------------------------------------------------------------


---	@function add_listener
---	@desc Allows the generated_battle object to listen for a message and trigger an arbitrary callback. The call gets passed to the underlying @script_messager - see @script_messager:add_listener.
--- @p string message name
--- @p function callback to call
--- @p [opt=false] boolean persistent
function generated_battle:add_listener(...)
	return self.sm:add_listener(...);
end;


--- @function remove_listener
--- @desc Removes any listener listening for a particular message. This call gets passed through to @script_messager:remove_listener.
--- @p string message name
function generated_battle:remove_listener(message)
	return self.sm:remove_listener(message);
end;








----------------------------------------------------------------------------
---	@section Message Listeners
----------------------------------------------------------------------------


---	@function advice_on_message
---	@desc Takes a string message, a string advice key, and an optional time offset in ms. Instruct the generated_battle to play a piece of advice on receipt of a message, with the optional time offset so that it doesn't happen robotically at the same moment as the message.
--- @p string message
--- @p string advice key
--- @p [opt=0] number wait offset in ms
function generated_battle:advice_on_message(message, advice_key, wait_offset)
	if not is_string(advice_key) then
		script_error("generated_battle ERROR: advice_on_message() called but supplied advice key [" .. tostring(advice_key) .. "] is not a string");
		return false;
	end;

	if not is_string(message) then
		script_error("generated_battle ERROR: advice_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: advice_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:advice_on_message() now queueing advice " .. advice_key);
					self.bm:queue_advisor(advice_key);
				end,
				wait_offset
			);
		end
	);
end;


---	@function play_sound_on_message
---	@desc Instruct the generated_battle to play a sound on receipt of a message.
--- @p string message, Play the sound on receipt of this message.
--- @p battle_sound_effect sound, Sound file to play.
--- @p [opt=nil] vector position, Position at which to play the sound. Supply <code>nil</code> to play the sound at the camera.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the supplied sound starting to play, in ms.
--- @p [opt=nil] string end message, Message to send when the sound has finished playing.
--- @p [opt=500] number minimum duration, Minimum duration of the sound in ms. This is only used if an end message is supplied, and is handy during development for when the sound has not been recorded.
function generated_battle:play_sound_on_message(message, sound, position, wait_offset, message_on_finished, minimum_sound_duration)

	position = position or v(0, 0);
	wait_offset = wait_offset or 0;
	message_on_finished = message_on_finished or nil;
	minimum_sound_duration = minimum_sound_duration or 500;
	
	if not is_string(message) then
		script_error("generated_battle ERROR: play_sound_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_nil(message_on_finished) and not is_string(message_on_finished) then
		script_error("generated_battle ERROR: play_sound_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: play_sound_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number");
		return false;
	end;
	
	if not is_battlesoundeffect(sound) then
		script_error("generated_battle ERROR: play_sound_on_message() called but supplied object [" .. tostring(sound) .. "] is not a battle_sound_effect");
		return false;
	end;

	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
				
					self.bm:out("generated_battle:play_sound_on_message() now playing sound " .. tostring(sound));
					play_sound(position, sound);
					
					if not is_nil(message_on_finished) then
						-- Running through a callback so we can delay the test. If we test straight away is_playing() will always return false.
						self.bm:callback(
							-- Return when the sound is no longer playing. This covers for the case where a null sound has been passed in so we don't have any watches hanging around.
							function()
								self.bm:out("generated_battle:play_sound_on_message() Sound " .. tostring(sound) .. " is playing: " .. tostring(sound:is_playing()));
								self.bm:watch(
									function()
										return not sound:is_playing();
									end,
									0,
									function()
										self.bm:out("generated_battle:play_sound_on_message() Sound " .. tostring(sound) .. " finished. Firing message " .. message_on_finished);
										self.sm:trigger_message(message_on_finished);
									end
								);
							end,
							minimum_sound_duration
						);
					end;
					
				end,
				wait_offset
			);
		end
	);

end;


---	@function stop_sound_on_message
---	@desc Instructs the generated_battle to stop a sound on receipt of a message.
--- @p string message, Stop the sound on receipt of this message.
--- @p battle_sound_effect sound, Sound file to stop.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the supplied sound being stopped, in ms.
function generated_battle:stop_sound_on_message(message, sound, wait_offset)
	wait_offset = wait_offset or 0;
	
	if not is_string(message) then
		script_error("generated_battle ERROR: stop_sound_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: stop_sound_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number");
		return false;
	end;
	
	if not is_battlesoundeffect(sound) then
		script_error("generated_battle ERROR: stop_sound_on_message() called but supplied object [" .. tostring(sound) .. "] is not a battle_sound_effect");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:stop_sound_on_message() now stopping sound " .. tostring(sound));
					stop_sound(sound);
				end,
				wait_offset
			);
		end
	);
end;


---	@function start_terrain_composite_scene_on_message
---	@desc Instructs the generated_battle to start a terrain composite scene on receipt of a message. Terrain composite scenes are general-purpose scene containers, capable of playing animations, sounds, vfx and more.
--- @p string message, Play the composite scene on receipt of this message.
--- @p string scene key, Composite scene key.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the scene being started, in ms.
function generated_battle:start_terrain_composite_scene_on_message(message, comp_scene_key, wait_offset)

	if not is_string(comp_scene_key) then
		script_error("generated_battle ERROR: start_terrain_composite_scene_on_message() called but supplied composite scene key [" .. tostring(comp_scene_key) .. "] is not a string");
		return false;
	end;

	if not is_string(message) then
		script_error("generated_battle ERROR: start_terrain_composite_scene_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: start_terrain_composite_scene_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:start_terrain_composite_scene_on_message() now starting composite scene with key " .. comp_scene_key);
					self.bm:start_terrain_composite_scene(comp_scene_key)
				end,
				wait_offset
			);
		end
	);
end;


---	@function stop_terrain_composite_scene_on_message
---	@desc Instructs the generated_battle to stop a terrain composite scene on receipt of a message.
--- @p string message, Stop the composite scene on receipt of this message.
--- @p string scene key, Composite scene key.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the scene being stopped, in ms.
function generated_battle:stop_terrain_composite_scene_on_message(message, comp_scene_key, wait_offset)

	if not is_string(comp_scene_key) then
		script_error("generated_battle ERROR: stop_terrain_composite_scene_on_message() called but supplied composite scene key [" .. tostring(comp_scene_key) .. "] is not a string");
		return false;
	end;

	if not is_string(message) then
		script_error("generated_battle ERROR: stop_terrain_composite_scene_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: stop_terrain_composite_scene_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:stop_terrain_composite_scene_on_message() now stopping composite scene with key " .. comp_scene_key);
					self.bm:stop_terrain_composite_scene(comp_scene_key)
				end,
				wait_offset
			);
		end
	);
end;


---	@function set_objective_on_message
---	@desc Instructs the generated_battle to add a scripted obective to the objectives panel, or update an existing scripted objective, on receipt of a message. The scripted objective is automatically completed or failed when the battle ends, based on the winner of the battle.
--- @p string message, Add/update the objective on receipt of this message.
--- @p string objective key, Objective key to add or update.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the objective being added/updated, in ms.
--- @p [opt=nil] number objective param a, First numeric objective parameter, if required. See documentation for @objectives_manager:set_objective.
--- @p [opt=nil] number objective param b, Second numeric objective parameter, if required. See documentation for @objectives_manager:set_objective.
function generated_battle:set_objective_on_message(message, objective_key, wait_offset, param1, param2)

	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: set_objective_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;

	if not is_string(message) then
		script_error("generated_battle ERROR: set_objective_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("generated_battle ERROR: set_objective_on_message() called but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					local bm = self.bm;
					
					bm:out("generated_battle:set_objective_on_message() now adding objective " .. objective_key);
					bm:set_objective(objective_key, param1, param2);
					self.current_objectives[objective_key] = true;
					-- bm:callback(function() self:pulse_objective(objective_key) end, 200);
				end,
				wait_offset
			);
		end
	);
end;


---	@function complete_objective_on_message
---	@desc Instructs the generated_battle to mark a specified objective as complete, on receipt of a message. Note that objectives issued to the player are automatically completed if they win the battle.
--- @p string message, Complete the objective on receipt of this message.
--- @p string objective key, Objective key to complete.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the objective being completed, in ms.
function generated_battle:complete_objective_on_message(message, objective_key, wait_offset)

	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: complete_objective_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	if not is_string(message) then
		script_error("generated_battle ERROR: complete_objective_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("generated_battle ERROR: complete_objective_on_message() called but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:complete_objective_on_message() responding to message " .. message .. ", completing objective " .. objective_key);
					self.bm:complete_objective(objective_key);
					self.current_objectives[objective_key] = false;
				end,
				wait_offset
			);
		end
	);
end;


---	@function fail_objective_on_message
---	@desc Instructs the generated_battle to mark a specified objective as failed, on receipt of a message. Note that objectives issued to the player are automatically failed if they lose the battle.
--- @p string message, Fail the objective on receipt of this message.
--- @p string objective key, Objective key to fail.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the objective being failed, in ms.
function generated_battle:fail_objective_on_message(message, objective_key, wait_offset)

	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: set_objective_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	if not is_string(message) then
		script_error("generated_battle ERROR: fail_objective_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("generated_battle ERROR: fail_objective_on_message() called but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:fail_objective_on_message() responding to message " .. message .. ", failing objective " .. objective_key);
					self.bm:fail_objective(objective_key);
					self.current_objectives[objective_key] = false;
				end,
				wait_offset
			);
		end
	);
end;


---	@function remove_objective_on_message
---	@desc Instructs the generated_battle to remove a specified objective from the UI on receipt of a message.
--- @p string message, Remove the objective on receipt of this message.
--- @p string objective key, Objective key to remove.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the objective being removed, in ms.
function generated_battle:remove_objective_on_message(message, objective_key, wait_offset)

	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: set_objective_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	if not is_string(message) then
		script_error("generated_battle ERROR: remove_objective_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("generated_battle ERROR: remove_objective_on_message() called but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:remove_objective_on_message(): Removing objective " .. objective_key);
					self.bm:remove_objective(objective_key);
					self.current_objectives[objective_key] = false;
				end,
				wait_offset
			);
		end
	);
end;


---	@function set_locatable_objective_on_message
---	@desc Instructs the generated_battle to set a locatable objective on receipt of a message. See @battle_manager:set_locatable_objective for more details.
--- @p string message, Add/update the locatable objective on receipt of this message.
--- @p string objective key, Objective key to add or update.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the objective being added/updated, in ms.
--- @p vector camera position, Camera position to zoom camera to when objective button is clicked.
--- @p vector camera target, Camera target to zoom camera to when objective button is clicked.
--- @p number camera move time, Time the camera takes to pan to the objective when the objective button is clicked, in seconds.
function generated_battle:set_locatable_objective_on_message(message, objective_key, wait_offset, cam_pos, cam_targ, duration)

	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: set_locatable_objective_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;

	if not is_string(message) then
		script_error("generated_battle ERROR: set_locatable_objective_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("generated_battle ERROR: set_locatable_objective_on_message() called but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	if not is_vector(cam_pos) then
		script_error("generated_battle ERROR: set_locatable_objective_on_message() called but supplied camera position [" .. tostring(cam_pos) .. "] is not a vector");
		return false;
	end;
	
	if not is_vector(cam_targ) then
		script_error("generated_battle ERROR: set_locatable_objective_on_message() called but supplied camera target [" .. tostring(cam_targ) .. "] is not a vector");
		return false;
	end;
	
	if not is_number(duration) or duration <= 0 then
		script_error("generated_battle ERROR: set_locatable_objective_on_message() called but supplied duration [" .. tostring(duration) .. "] is not a number > 0");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					local bm = self.bm;
					
					bm:out("generated_battle:set_locatable_objective_on_message() now adding objective " .. objective_key);
					bm:set_locatable_objective(objective_key, cam_pos, cam_targ, duration);
					self.current_objectives[objective_key] = true;
					-- bm:callback(function() self:pulse_objective(objective_key) end, 200);
				end,
				wait_offset
			);
		end
	);
end;


---	@function add_ping_icon_on_message
---	@desc Instructs the generated_battle to add a battlefield ping icon on receipt of a message. This is a marker that appears in 3D space and can be used to point out the location of objectives to the player.
--- @p string message, Add the ping icon on receipt of this message.
--- @p vector marker position, Marker position.
--- @p number marker type, Marker type. These have to be looked up from code.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the marker being added, in ms.
--- @p [opt=nil] number duration, Duration that the marker should stay visible for, in ms. If not set then the marker stays on-screen until it is removed with @generated_battle:remove_ping_icon_on_message.
function generated_battle:add_ping_icon_on_message(message, position, marker_type, wait_offset, duration)
	wait_offset = wait_offset or 0;
	marker_type = marker_type or 8;		-- default type
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: add_ping_icon_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;

	if not is_string(message) then
		script_error("generated_battle ERROR: add_ping_icon_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_vector(position) then
		script_error("generated_battle ERROR: add_ping_icon_on_message() called but supplied position [" .. tostring(position) .. "] is not a vector");
		return false;
	end;
	
	if not is_number(marker_type) then
		script_error("generated_battle ERROR: add_ping_icon_on_message() called but supplied marker type [" .. tostring(marker_type) .. "] is not a numeric type or nil");
		return false;
	end;
	
	if duration and not (is_number(duration) and duration > 0) then
		script_error("generated_battle ERROR: add_ping_icon_on_message() called but supplied duration [" .. tostring(duration) .. "] is not a positive number or nil");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:add_ping_icon_on_message() responding to message " .. message .. ", adding ping marker at " .. v_to_s(position) .. " of type " .. marker_type);
					
					self.bm:add_ping_icon(position:get_x(), position:get_y(), position:get_z(), marker_type, false);
					
					if duration then
						self.bm:callback(
							function()
								self.bm:remove_ping_icon(position:get_x(), position:get_y(), position:get_z());
							end,
							duration
						);
					end;
				end,
				wait_offset
			);
		end
	);
end;


---	@function remove_ping_icon_on_message
---	@desc Instructs the generated_battle to remove a battlefield ping icon on receipt of a message. The marker is specified by its position.
--- @p string message, Remove the ping icon on receipt of this message.
--- @p vector marker position, Marker position.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the marker being removed, in ms.
function generated_battle:remove_ping_icon_on_message(message, position, wait_offset)
	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: remove_ping_icon_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;

	if not is_string(message) then
		script_error("generated_battle ERROR: remove_ping_icon_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_vector(position) then
		script_error("generated_battle ERROR: remove_ping_icon_on_message() called but supplied position [" .. tostring(position) .. "] is not a vector");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:remove_ping_icon_on_message() responding to message " .. message .. ", removing ping marker at " .. v_to_s(position));
					self.bm:remove_ping_icon(position:get_x(), position:get_y(), position:get_z());
				end,
				wait_offset
			);
		end
	);
end;


-- internal function to pulse an objective as it's being added. Not currently in use.
function generated_battle:pulse_objective(objective_key)
	local uic_objectives = find_uicomponent(self.bm.ui_root, "scripted_objectives_panel");
	
	if not uic_objectives then
		script_error("ERROR: pulse_objective() couldn't find scripted objectives panel");
		return;
	end;
	
	local uic_objective = find_uicomponent(uic_objectives, objective_key);
	
	if not uic_objective then
		script_error("ERROR: pulse_objective() couldn't find objective key " .. objective_key);
		return;
	end;
	
	uic_objective:TextShaderTechniqueSet("glow_pulse_t0");
	uic_objective:TextShaderVarsSet(0, 3, 1.5, 0);
	
	self.bm:callback(
		function()
			self:stop_pulse_objective(objective_key);
		end,
		1500
	);
end;


-- internal function to stop pulsing an objective, after it's been added. Not currently in use.
function generated_battle:stop_pulse_objective(objective_key)
	local uic_objectives = find_uicomponent(self.bm.ui_root, "scripted_objectives_panel");
	
	if not uic_objectives then
		return;
	end;
	
	local uic_objective = find_uicomponent(uic_objectives, objective_key);
	
	if not uic_objective then
		return;
	end;
	
	uic_objective:TextShaderTechniqueSet("normal_t0");
	uic_objective:TextShaderVarsSet(0, 0, 0, 0);
end;


---	@function fade_in_on_message
---	@desc Takes a string message, and a fade duration in seconds. Fades the scene from black to picture over the supplied duration when the supplied message is received.
--- @p string message
--- @p number duration
function generated_battle:fade_in_on_message(message, duration)
	if not is_string(message) then
		script_error("generated_battle ERROR: fade_in_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(duration) or duration < 0 then
		script_error("generated_battle ERROR: fade_in_on_message() called but supplied duration [" .. tostring(duration) .. "] is not a positive number, it needs to be a time in seconds");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out("generated_battle responding to message " .. message .. ", fading scene in over " .. duration .. "s");
			self.bm:camera():fade(false, duration);
		end
	);
end;


---	@function set_custom_loading_screen_on_message
---	@desc Takes a string message and a string custom loading screen key. Sets that loading screen key to be used as the loading screen on receipt of the string message. This is used to set a custom outro loading screen.
--- @p string message
--- @p number duration
function generated_battle:set_custom_loading_screen_on_message(message, loading_screen_key)
	if not is_string(message) then
		script_error("generated_battle ERROR: set_custom_loading_screen_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(message) then
		script_error("generated_battle ERROR: set_custom_loading_screen_on_message() called but supplied loading screen key [" .. tostring(loading_screen_key) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out("generated_battle responding to message " .. message .. ", setting loading screen to " .. loading_screen_key);
			effect.set_custom_loading_screen_key(loading_screen_key);
		end
	);
end;


---	@function start_terrain_effect_on_message
---	@desc Instructs the generated_battle to start a terrain effect on receipt of a message.
--- @p string message, Start the terrain effect on receipt of this message.
--- @p string effect name, Effect name to start.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the effect being started, in ms.
function generated_battle:start_terrain_effect_on_message(message, effect_name, wait_offset)
	if not is_string(message) then
		script_error("generated_battle ERROR: start_terrain_effect_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(effect_name) then
		script_error("generated_battle ERROR: start_terrain_effect_on_message() called but supplied effect name [" .. tostring(effect_name) .. "] is not a string");
		return false;
	end;
	
	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: start_terrain_effect_on_message() called but supplied wait offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			local bm = self.bm;
			
			bm:callback(
				function()
					bm:out("generated_battle responding to message " .. message .. ", starting terrain effect " .. effect_name);
					bm:start_terrain_effect(effect_name);
				end,
				wait_offset
			);
		end
	);
end;


---	@function stop_terrain_effect_on_message
---	@desc Instructs the generated_battle to stop a terrain effect on receipt of a message.
--- @p string message, Stop the terrain effect on receipt of this message.
--- @p string effect name, Effect name to stop.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the effect being stopped, in ms.
function generated_battle:stop_terrain_effect_on_message(message, effect_name, wait_offset)
	if not is_string(message) then
		script_error("generated_battle ERROR: stop_terrain_effect_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(effect_name) then
		script_error("generated_battle ERROR: stop_terrain_effect_on_message() called but supplied effect name [" .. tostring(effect_name) .. "] is not a string");
		return false;
	end;
	
	wait_offset = wait_offset or 0;
	
	if not is_number(wait_offset) or wait_offset < 0 then
		script_error("generated_battle ERROR: stop_terrain_effect_on_message() called but supplied wait offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			local bm = self.bm;
			
			bm:callback(
				function()
					bm:out("generated_battle responding to message " .. message .. ", stopping terrain effect " .. effect_name);
					bm:stop_terrain_effect(effect_name);
				end,
				wait_offset
			);
		end
	);
end;


---	@function queue_help_on_message
---	@desc Enqueues a help message for display on-screen on receipt of a message. The message appears above the army panel with a black background. See @"battle_manager:Help Message Queue" for more information. Note that if the battle is ending, this message will not display.
--- @p string message, Enqueue the help message for display on receipt of this message.
--- @p string objective key, Message key, from the scripted_objectives table.
--- @p [opt=10000] number display time, Time for which the help message should be displayed on-screen, in ms.
--- @p [opt=2000] number display time, Time for which the help message should be displayed on-screen, in ms.
--- @p [opt=0] number wait offset, Delay between receipt of the message and the help message being enqueued, in ms.
--- @p [opt=false] boolean high priority, High priority advice gets added to the front of the help queue rather than the back.
--- @p [opt=nil] string message on trigger, Specifies a message to be sent when this help message is actually triggered for display.
function generated_battle:queue_help_on_message(message, objective_key, display_time, fade_time, offset_time, is_high_priority, message_on_trigger)
	if not is_string(message) then
		script_error("generated_battle ERROR: queue_help_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective_key) then
		script_error("generated_battle ERROR: queue_help_on_message() called but supplied objective key [" .. tostring(objective_key) .. "] is not a string");
		return false;
	end;
	
	display_time = display_time or 10000;
		
	if not is_number(display_time) or display_time < 0 then
		script_error("generated_battle ERROR: queue_help_on_message() called but supplied display time [" .. tostring(display_time) .. "] is not a positive number or nil");
		return false;
	end;
	
	fade_time = fade_time or 2000;
	
	if not is_number(fade_time) or fade_time < 0 then
		script_error("generated_battle ERROR: queue_help_on_message() called but supplied fade time [" .. tostring(fade_time) .. "] is not a positive number or nil");
		return false;
	end;
	
	offset_time = offset_time or 0;
	
	if not is_number(offset_time) or offset_time < 0 then
		script_error("generated_battle ERROR: queue_help_on_message() called but supplied offset time [" .. tostring(offset_time) .. "] is not a positive number or nil");
		return false;
	end;
	
	if message_on_trigger and not is_string(message_on_trigger) then
		script_error("generated_battle ERROR: queue_help_on_message() called but supplied on-trigger message [" .. tostring(message_on_trigger) .. "] is not a string or nil");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:queue_help_on_message() responding to message " .. message .. ", enqueueing help message " .. objective_key);
					self.bm:queue_help_message(
						objective_key, 
						display_time, 
						fade_time, 
						is_high_priority,
						false,
						function()
							if message_on_trigger then
								self.sm:trigger_message(message_on_trigger);
							end;
						end
					);
				end,
				offset_time
			);
		end
	);
end;


--- @function set_victory_countdown_on_message
--- @desc Sets the victory countdown time for the battle to the specified value when the specified message is received. The victory countdown time is the grace period after the battle is deemed to have a victor, and before the battle formally ends, in which celebratory/commiseratory advice often plays. Set this to a negative number for the battle to never end after entering victory countdown phase, or 0 for it to end immediately. 
--- @desc Note that it's possible to set a negative victory countdown period, then enter the phase, then set a victory countdown period of zero to end the battle immediately.
--- @p string message, Set victory countdown on receipt of this message.
--- @p number countdown time, Victory countdown time in ms.
function generated_battle:set_victory_countdown_on_message(message, countdown_time)
	
	if not is_string(message) then
		script_error("generated_battle ERROR: set_victory_countdown_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;

	if not is_number(countdown_time) then
		script_error("generated_battle ERROR: set_victory_countdown_on_message() called but supplied countdown_time [" .. tostring(countdown_time) .. "] is not a number, it needs to be a time in ms");
		return false;
	end;
	
	if countdown_time > 0 then
		countdown_time = countdown_time / 1000;
	end
	self.bm:out("generated_battle:set_victory_countdown_on_message(): for message " .. message);
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out("generated_battle:set_victory_countdown_on_message() setting victory countdown to " .. countdown_time .. "ms");
			self.bm:change_victory_countdown_limit(countdown_time);		-- function needs it in seconds
		end
	);
end;


--- @function block_message_on_message
--- @desc Blocks or unblocks a message from being triggered, on receipt of a message. Scripts listening for a blocked message will not be notified when that message is triggered. See @script_messager:block_message for more information.
--- @p string message, Perform the blocking or unblocking on receipt of this message.
--- @p string message to block, Message to block or unblock.
--- @p [opt=true] boolean should block, Should block the message. Set this to <code>false</code> to unblock a previously-blocked message.
function generated_battle:block_message_on_message(message, message_to_block, should_block)
	
	if not is_string(message) then
		script_error("generated_battle ERROR: block_message_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(message_to_block) then
		script_error("generated_battle ERROR: block_message_on_message() called but supplied message to block [" .. tostring(message_to_block) .. "] is not a string");
		return false;
	end;
	
	if should_block ~= false then
		should_block = true;
	end;
	
	self.sm:add_listener(
		message,
		function()
			if should_block then
				self.bm:out("generated_battle:block_message_on_message() responding to message " .. message .. " and is blocking message " .. message_to_block .. " from being triggered in the future");
			else
				self.bm:out("generated_battle:block_message_on_message() responding to message " .. message .. " and is unblocking message " .. message_to_block);
			end;
			self.sm:block_message(message_to_block, should_block);
		end
	);
end;


function generated_battle:battle_ending()
	self.bm:out("generated_battle is ending");
	self.sm:trigger_message("battle_ending");
	
	-- end the battle in ten seconds
	self.bm:callback(function() self.bm:end_battle() end, 10000);
	
	-- attempt to work out which alliance has won
	-- this script should be rewritten when the script has the proper ability to determine who has won
	local alliances = self.bm:alliances();
	local winning_alliance_num = false;
	local no_armies_routed = true;
	
	-- go backwards through our alliances - if the enemy alliance still has troops left, assume that it's won.
	-- Additionally, if no alliance has routed or died, the battle has ended for some other reason.
	for i = alliances:count(), 1, -1 do
		local alliance = alliances:item(i);
		
		if not is_routing_or_dead(alliance) then
			winning_alliance_num = i;
		else
			no_armies_routed = false;
		end;
	end;
	
	if no_armies_routed then
		self.bm:out("\twarning: could not determine the winning alliance. Firing 'battle_ending_no_clear_victor' and leaving it for the script to decide the victor.");
		self.sm:trigger_message("battle_ending_no_clear_victor");

		return;
	end;
	
	-- we have a winning alliance, notify the relevant armies
	for i = 1, #self.generated_armies do
		for j = 1, #self.generated_armies[i] do
			for k = 1, #self.generated_armies[i][j] do
				local current_ga = self.generated_armies[i][j][k];
				
				if current_ga.alliance_number == winning_alliance_num then
					current_ga:notify_of_victory();
				else
					current_ga:notify_of_defeat();
				end;
			end;
		end;
	end;
	
	-- complete or fail all currently-active objectives
	for objective_name, objective_value in pairs(self.current_objectives) do
		if objective_value == true then
			if winning_alliance_num == self:get_player_alliance_num() then
				self.bm:complete_objective(objective_name);
			else
				self.bm:fail_objective(objective_name);
			end;
		end;
	end;
end;





----------------------------------------------------------------------------
---	@section Message Generation
----------------------------------------------------------------------------


---	@function message_on_all_messages_received
---	@desc Takes a subject message, and then one or more other messages. When all of these other messages are received, the subject message is sent.
--- @p string message, Subject message to send.
--- @p ... messages, One or more string messages to receive.
function generated_battle:message_on_all_messages_received(message, ...)
	if not is_string(message) then
		script_error("generated_battle ERROR: message_on_all_messages_received() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if arg.n == 0 then
		script_error("generated_battle ERROR: message_on_all_messages_received() called but no messages to listen to were specified");
		return false;
	end;
	
	for i = 1, arg.n do
		if not is_string(arg[i]) then
			script_error("generated_battle ERROR: message_on_all_messages_received() called but message to listen to [" .. i .. "] is not a string, it's value is [" .. tostring(arg[i]) .. "]");
			return false;
		end;
	end;
	
	local num_messages_received = 0;
	
	for i = 1, arg.n do
		self.sm:add_listener(
			arg[i],
			function()
				num_messages_received = num_messages_received + 1;
				
				if num_messages_received == arg.n then
					local output_str = "generated_battle:message_on_all_messages_received() is sending message [" .. message .. "] having received all the following messages [";
					
					for i = 1, arg.n - 1 do
						output_str = output_str .. arg[i] .. ",";
					end;
					
					output_str = output_str .. arg[arg.n] .. "]";
					
					self.bm:out(output_str);
					
					self.sm:trigger_message(message);
				end;
			end
		);
	end;
end;


---	@function message_on_any_message_received
---	@desc Takes a subject message, and then one or more other messages. When any of these other messages are received, the subject message is sent.
--- @p string message, Subject message to send.
--- @p ... messages, One or more string messages to receive.
function generated_battle:message_on_any_message_received(message, ...)
	if not is_string(message) then
		script_error("generated_battle ERROR: message_on_any_message_received() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if arg.n == 0 then
		script_error("generated_battle ERROR: message_on_any_message_received() called but no messages to listen to were specified");
		return false;
	end;
	
	for i = 1, arg.n do
		if not is_string(arg[i]) then
			script_error("generated_battle ERROR: message_on_any_message_received() called but message to listen to [" .. i .. "] is not a string, it's value is [" .. tostring(arg[i]) .. "]");
			return false;
		end;
	end;
	
	local message_sent = false;
	
	for i = 1, arg.n do
		self.sm:add_listener(
			arg[i],
			function()
				if not message_sent then
					message_sent = true;					
					self.bm:out("generated_battle:message_on_any_message_received() is sending message [" .. message .. "] having received the message [" .. arg[i] .. "]");
					self.sm:trigger_message(message);
				end;
			end
		);
	end;
end;


---	@function message_on_time_offset
---	@desc Takes a string message and a wait time in ms. Waits for the specified interval and then triggers the message. If an optional start message is supplied as a third argument then the timer will start when this message is received, otherwise it starts when the battle is started. A cancellation message may be supplied as a fourth argument - this will cancel the timer if the message is received (whether the timer has been started or not).
--- @p string message, Subject message to send.
--- @p number wait period, Wait period between the start of the battle (or the receipt of the start message) and the sending of the subject message.
--- @p [opt="battle_started"] string start message, Start message.
--- @p [opt=nil] string cancel message.
function generated_battle:message_on_time_offset(message, wait_time, start_message, cancel_message)
	if not is_string(message) then
		script_error("generated_battle ERROR: message_on_time_offset() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;

	if not is_number(wait_time) then
		script_error("generated_battle ERROR: message_on_time_offset() called but supplied wait_time [" .. tostring(wait_time) .. "] is not a number, it needs to be a time in ms");
		return false;
	end;
	
	start_message = start_message or "battle_started";
	
	if not is_string(start_message) then
		script_error("generated_battle ERROR: message_on_time_offset() called but supplied cancellation message [" .. tostring(cancel_message) .. "] is not a string");
		return false;
	end;
	
	if not is_nil(cancel_message) and not is_string(cancel_message) then
		script_error("generated_battle ERROR: message_on_time_offset() called but supplied cancellation message [" .. tostring(cancel_message) .. "] is not a string");
		return false;
	end;
	
	local message_cancelled = false;
	
	self.sm:add_listener(
		start_message, 
		function()
			if not message_cancelled then
				local process_name = "gb_message_on_time_offset_" .. message;
				
				self.bm:out("generated_battle:message_on_time_offset() is starting timer having received start message " .. start_message .. ", will trigger message " .. message .. " in " .. wait_time .. "ms");
			
				self.bm:callback(
					function()
						self.bm:out("generated_battle:message_on_time_offset() triggering message " .. message);
						if cancel_message then
							self.sm:remove_listener(cancel_message);
						end
						self.sm:trigger_message(message);
					end,
					wait_time,
					process_name
				);
			end;
		end
	);
	
	if cancel_message then
		self.sm:add_listener(
			cancel_message,
			function()
				self.bm:out("generated_battle:message_on_time_offset() has received cancellation message " .. cancel_message .. " so won't be triggering message " .. message);
				self.bm:remove_process(process_name);
				message_cancelled = true;
			end
		);
	end
end;





































----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	GENERATED ARMY
--
---	@class generated_army Generated Army
--- @page generated_battle
--- @desc A generated army object represents a conceptual army in a generated battle. This can mean an entire army in the conventional sense, or a collection of units within a conventional army, grouped together by the same script_name. A generated_army object can be created by calling @generated_battle:get_army.
--- @desc Each generated army object can be instructed to respond to trigger script messages when certain in-battle conditions are met (e.g. when a certain proportion of casualties has been taken, or the enemy is within a certain distance), or to respond to script messages triggered by other parts of the script by attacking/defending/moving and more. Using these tools, the actions that determine the course of events in a generated/quest battle can be laid out.
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


generated_army = {
	bm = nil,
	sm = nil,
	id = "",
	army = nil,
	uc = nil,
	alliance_number = 0,
	army_number = 0,
	sunits = {},
	script_name = "",
	script_ai_planner = nil,
	total_units = 0,
	generated_battle = nil,
	is_allied_to_player = false,
	enemy_force = false,
	allied_force = false,
	victory_message = false,
	defeat_message = false,
	enemies_and_allies_known = false,
	is_debug = false
};


-- creator, not to be called externally - use generated_battle:get_army instead
function generated_army:new(script_name, sub_army_num, sunits, generated_battle, is_debug)
	if not is_string(script_name) then
		script_error("ERROR: tried to created generated_army but supplied script_name [" .. tostring(script_name) .. "] is not a string");
		return false;
	end;
	
	if not is_number(sub_army_num) then
		script_error("ERROR: tried to created generated_army but supplied sub army number [" .. tostring(sub_army_num) .. "] is not a number");
		return false;
	end;

	if not is_scriptunits(sunits) then
		script_error("ERROR: tried to created generated_army but supplied sunits collection [" .. tostring(sunits) .. "] is not a scriptunits object");
		return false;
	end;
	
	if sunits:count() == 0 then
		script_error("ERROR: tried to created generated_army but supplied sunits collection is empty");
		return false;
	end;
	
	if not is_generatedbattle(generated_battle) then
		script_error("ERROR: tried to created generated_army but supplied generated battle [" .. tostring(generated_battle) .. "] is not a generated_battle");
		return false;
	end;

	local ga = {};
	
	setmetatable(ga, self);
	self.__index = self;
	self.__tostring = function() return TYPE_GENERATED_ARMY end;
	
	local bm = get_bm();
	local sm = get_messager();
	
	-- get a handle to the first sunit, as we can ask it for other important info
	local first_sunit = sunits:item(1);
		
	ga.bm = bm;
	ga.sm = sm;
	
	local alliance_number = first_sunit.alliance_num;
	local army_number = first_sunit.army_num;
	local army = first_sunit.army;
	
	ga.alliance_number = alliance_number
	ga.army_number = army_number;
	ga.army = army;
	
	-- unique id for this ga. This is not the name that can be used to get a handle to it - that's the script_name
	ga.id = "generated_army_" .. tostring(alliance_number) .. ":" .. tostring(army_number) .. ":" .. sub_army_num;
	
	if script_name ~= "" then
		ga.id = ga.id .. ":" .. script_name;
	end;
	
	ga.script_name = tostring(script_name);
	
	-- create unitcontroller
	local uc = army:create_unit_controller();
	
	for i = 1, sunits:count() do
		uc:add_units(sunits:item(i).unit);
	end;

	ga.uc = uc;
	
	ga.sunits = sunits;			-- this is now a scriptunits collection object, passed in from the generated_battle object
	ga.total_units = sunits:count();
	
	ga.generated_battle = generated_battle;
	ga.is_debug = is_debug;
	
	-- take script control of these sunits if the generated battle wishes us to (so they can't deploy)
	if not (alliance_number == bm:local_alliance() and army_number == bm:local_army()) and generated_battle:should_not_deploy_ai() then
		ga.sunits:take_control();
	end;
	
	return ga;
end;

--	called internally to ensure the script planner is set up
function generated_army:set_up_script_planner()
	if not self.script_ai_planner then
		self.script_ai_planner = script_ai_planner:new(self.id, self.sunits:get_sunit_table(), self.is_debug);	
	end;
end;


--	Builds the enemy_force and allied_force lists, which are tables of scriptunits of all enemies and allies.
--	These are sourced from the generated_battle parent object
--	For internal use
function generated_army:get_allied_and_enemy_forces()
	if self.enemies_and_allies_known then
		return;
	end;
	
	self.enemies_and_allies_known = true;
	
	self.enemy_force = self.generated_battle:get_enemy_force(self.alliance_number, self.army_number);
	self.allied_force = self.generated_battle:get_allied_force(self.alliance_number, self.army_number);
end;


--	Releases all sunits in this generated_army from the script_ai_planner
--	For internal use
function generated_army:release_control_of_all_sunits()
	if not is_nil(self.script_ai_planner) then
		self.script_ai_planner:remove_sunits(self.sunits:get_sunit_table());
		self.script_ai_planner = nil;
	end
	
	-- go through list of sunits and explicitly release them
	self.sunits:release_control();
end;










----------------------------------------------------------------------------
---	@section Querying
----------------------------------------------------------------------------


--- @function get_script_name
--- @desc Gets the script_name of the generated army.
--- @return string script_name
function generated_army:get_script_name()
	return self.script_name;
end;


--- @function get_unitcontroller
--- @desc Gets a unitcontroller with control over all units in the generated army. This can be useful for the intro cutscene which needs this to restrict player control.
--- @return unitcontroller
function generated_army:get_unitcontroller()
	return self.uc;	
end;


--- @function get_handicap
--- @desc Returns the battle difficulty.
--- @return number army handicap
function generated_army:get_handicap()
	return self.army:army_handicap();
end;


--- @function get_first_scriptunit
--- @desc Returns the first scriptunit of the generated army.
--- @return script_unit
function generated_army:get_first_scriptunit()
	return self.sunits:item(1);
end;


--- @function get_first_active_scriptunit
--- @desc Returns the first scriptunit of the generated army which is active on the battlefield.
--- @return script_unit
function generated_army:get_first_active_scriptunit()
	
	for i = 1, self.sunits:count() do
		local current_sunit = self.sunits:item(i);

		if current_sunit:are_any_active_on_battlefield() then
			return current_sunit;
		end;
	end;	

	return nil;
end;


--- @function get_most_westerly_scriptunit
--- @desc Returns the @script_unit within the generated army positioned furthest to the west.
--- @return script_unit
function generated_army:get_most_westerly_scriptunit()
	return self.sunits:get_westernmost(true);
end;


--- @function get_most_easterly_scriptunit
--- @desc Returns the @script_unit within the generated army positioned furthest to the east.
--- @return script_unit
function generated_army:get_most_easterly_scriptunit()
	return self.sunits:get_easternmost(true);
end;


--- @function get_most_northerly_scriptunit
--- @desc Returns the @script_unit within the generated army positioned furthest to the north.
--- @return script_unit
function generated_army:get_most_northerly_scriptunit()
	return self.sunits:get_northernmost(true);
end;


--- @function get_most_southerly_scriptunit
--- @desc Returns the @script_unit within the generated army positioned furthest to the south.
--- @return script_unit
function generated_army:get_most_southerly_scriptunit()
	return self.sunits:get_southernmost(true);
end;


--- @function get_casualty_rate
--- @desc Returns the amount of casualties this generated army has taken as a unary value e.g. 0.2 = 20% casualties.
--- @return number casualties
function generated_army:get_casualty_rate()
	return 1 - self.sunits:unary_hitpoints();
end;


--- @function get_rout_proportion
--- @desc Returns the unary proportion (0 - 1) of the units in this generated army that are routing e.g. 0.2 = 20% routing
--- @return number rout proportion
function generated_army:get_rout_proportion()
	local total_units = self.sunits:count();
	
	-- divide-by-zero guard
	if total_units == 0 then
		return 0;
	end;
	
	local units_routing = num_units_routing(self.sunits);
	
	return units_routing / total_units;	
end;


--- @function get_shattered_proportion
--- @desc Returns the unary proportion (0 - 1) of the units in this generated army that are shattered e.g. 0.2 = 20% routing
--- @return number shattered proportion
function generated_army:get_shattered_proportion()
	local total_units = self.sunits:count();
	
	-- divide-by-zero guard
	if total_units == 0 then
		return 0;
	end;

	local units_shattered = num_units_shattered(self.sunits);
	
	return units_shattered / total_units;
end;


--- @function are_unit_types_in_army
--- @desc Returns true if any of the supplied unit types are present in the army, false otherwise.
--- @return boolean army contains types
function generated_army:are_unit_types_in_army(...)
	for i = 1, arg.n do
		if not is_string(arg[i]) then
			script_error(self.id .. " ERROR: are_unit_types_in_army() called but supplied argument [" .. i .. "] is [" .. tostring(arg[i]) .. "] and not a string");
			return false;
		end;		
	
		if self.sunits:contains_type(arg[i]) then
			self.bm:out(self.id .. ": are_unit_types_in_army() found matching type " .. arg[i]);
			return true;
		end
	end;
	
	self.bm:out(self.id .. ": are_unit_types_in_army() found no matching types");
	return false;
end;













----------------------------------------------------------------------------
---	@section Direct Commands
--- @desc These commands directly call some function or give some instruction to the generated army without listening for a script message. They are mostly for use within intro cutscenes, or they may be used internally by the functions that listen for messages.
----------------------------------------------------------------------------


--- @function set_visible_to_all
--- @desc Sets the visibility on a @generated_army, so that they are visible in an intro cutscene.
--- @p [opt=true] boolean visible
function generated_army:set_visible_to_all(value)
	if value == false then
		self.uc:set_always_visible_to_all(false);
	else
		self.uc:set_always_visible_to_all(true);
	end;
end;


--- @function set_enabled
--- @desc Sets whether a generated_army is enabled - when disabled, they will be invisible and effectively not exist. See @script_unit:set_enabled.
--- @p [opt=true] boolean enabled
function generated_army:set_enabled(value)
	self.sunits:set_enabled(value);
end;


--- @function halt
--- @desc Halts the generated_army.
function generated_army:halt()	
	self.sunits:halt();
end;

--- @function hold_fire
--- @desc The generated_army holds fire
function generated_army:hold_fire()	
	self.sunits:hold_fire();
end;

--- @function celebrate
--- @desc Orders the generated_army to celebrate.
function generated_army:celebrate()
	self.sunits:celebrate();
end;


--- @function taunt
--- @desc Orders the generated_army to taunt.
function generated_army:taunt()
	self.sunits:taunt();
end;


--- @function play_sound_charge
--- @desc Orders the generated_army to trigger the charge sound.
function generated_army:play_sound_charge()
	self.bm:out("generated_army:play_sound_charge() - Playing Charge Sound");
	self.sunits:play_sound_charge();
end;


--- @function play_sound_taunt
--- @desc Orders the generated_army to trigger the taunt sound.
function generated_army:play_sound_taunt()
	self.bm:out("generated_army:play_sound_taunt() - Playing Taunt Sound");
	self.sunits:play_sound_taunt();
end;


--- @function add_ping_icon
--- @desc Adds a ping icon to a unit within the generated army. See @script_unit:add_ping_icon.
--- @p [opt=8] number icon type, Icon type. This is a numeric index defined in code.
--- @p [opt=1] number unit index, Index of unit within the army to add the ping icon to.
--- @p [opt=nil] number duration, Duration to show the ping icon, in ms. Leave blank to show the icon indefinitely.
function generated_army:add_ping_icon(icon_type, unit_index, duration)
	unit_index = unit_index or 1;
	
	if unit_index and not (is_number(unit_index) and unit_index > 0) then
		script_error(self.id .. " ERROR: add_ping_icon() called but supplied unit index [" .. tostring(unit_index) .. "] is not a number > 0 or nil");
		return false;
	end;

	if unit_index > self.sunits:count() then
		script_error(self.id .. " ERROR: add_ping_icon() called with unit index [" .. tostring(unit_index) .. "] but this is greater than the number of units in this army [" .. self.sunits:count() .. "]");
		return false;
	end;
	
	self.sunits:item(unit_index):add_ping_icon(icon_type, duration);
end;


--- @function remove_ping_icon
--- @desc Removes a ping icon from a unit within the generated army.
--- @p [opt=1] number unit index, Index of unit within the army to remove the ping icon from.
function generated_army:remove_ping_icon(unit_index)
	unit_index = unit_index or 1;
	
	if unit_index and not (is_number(unit_index) and unit_index > 0) then
		script_error(self.id .. " ERROR: remove_ping_icon() called but supplied unit index [" .. tostring(unit_index) .. "] is not a number > 0 or nil");
		return false;
	end;

	if unit_index > self.sunits:count() then
		script_error(self.id .. " ERROR: remove_ping_icon() called with unit index [" .. tostring(unit_index) .. "] but this is greater than the number of units in this army [" .. self.sunits:count() .. "]");
		return false;
	end;
	
	self.sunits:item(unit_index):remove_ping_icon();
end;


--- @function teleport_to_start_location_offset
--- @desc Teleports the generated army to a position offset from its start location. Supply no offset to teleport it directly to its start location.
--- @p [opt=0] number x offset
--- @p [opt=0] number z offset
function generated_army:teleport_to_start_location_offset(x_offset, z_offset)
	x_offset = x_offset or 0;
	z_offset = z_offset or 0;

	if not is_number(x_offset) then
		script_error(self.id .. " ERROR: teleport_to_start_location_offset() called but supplied x_offset [" .. tostring(x_offset) .. "] is not a number");
		return false;
	end;
	
	if not is_number(z_offset) then
		script_error(self.id .. " ERROR: teleport_to_start_location_offset() called but supplied z_offset [" .. tostring(z_offset) .. "] is not a number");
		return false;
	end;
	
	local sunits = self.sunits;
	
	if x_offset == 0 and z_offset == 0 then
		-- there is no offset, teleport to start location
		sunits:teleport_to_start_location();
	else
		-- there is an offset so teleport to there
		sunits:teleport_to_start_location_offset(x_offset, z_offset);
	end;
end;


--- @function goto_start_location
--- @desc Instructs all the units in a generated army to move to the position/angle/width at which they started the battle.
--- @p [opt=false] boolean move fast
function generated_army:goto_start_location(should_run)
	self.sunits:goto_start_location(should_run);
end;


--- @function goto_location_offset
--- @desc Instructs all units in a generated army to go to a location offset from their current position. Supply a numeric x/z offset and a boolean argument specifying whether they should run.
--- @p number x offset, x offset in m
--- @p number x offset, z offset in m
--- @p [opt=false] boolean move fast
function generated_army:goto_location_offset(x_offset, z_offset, should_run)
	should_run = not not should_run;
	
	self.sunits:goto_location_offset(x_offset, z_offset, should_run);
end;


--- @function move_to_position
--- @desc Instructs all units in a generated army to move to a position under control of a @script_ai_planner. See @script_ai_planner:move_to_position.
--- @p vector position
function generated_army:move_to_position(position)
	-- ensure we have built our allied and enemy forces
	self:get_allied_and_enemy_forces();
	
	if self.is_debug and not no_debug_output then
		self.bm:out(self.id .. ":move_to_position(" .. v_to_s(position) .. ") called");
	end;
	
	-- Ensure script planner is set up
	self:set_up_script_planner();
	
	-- issue the order
	self.script_ai_planner:move_to_position(position);
end;


--- @function advance
--- @desc Instructs all units in a generated army to advance upon the enemy.
function generated_army:advance(no_debug_output)
	-- ensure we have built our allied and enemy forces
	self:get_allied_and_enemy_forces();
	
	if self.is_debug and not no_debug_output then
		self.bm:out(self.id .. ":advance() called");
	end;
	
	-- Ensure script planner is set up
	self:set_up_script_planner();
	
	-- issue the order
	self.script_ai_planner:move_to_force(self.enemy_force);
end;


--- @function attack
--- @desc Instructs all units in a generated army to attack the enemy.
function generated_army:attack(no_debug_output)
	-- ensure we have built our allied and enemy forces
	self:get_allied_and_enemy_forces();
	
	if self.is_debug and not no_debug_output then
		self.bm:out(self.id .. ":attack() called");
	end;
	
	-- Ensure script planner is set up
	self:set_up_script_planner();
	
	self.script_ai_planner:attack_force(self.enemy_force);
end;


--- @function attack_force
--- @desc Instructs all units in a generated army to attack a specific enemy force.
--- @p script_units enemy force
function generated_army:attack_force(enemy_force)
	-- ensure we have built our allied and enemy forces
	self:get_allied_and_enemy_forces();
	
	if self.is_debug then
		self.bm:out(self.id .. ":attack_force() called, target is " .. enemy_force.script_name);
	end;
	
	-- Ensure script planner is set up
	self:set_up_script_planner();
	
	-- use move_to_force instead of attack_force, as the latter gets tripped-up by visibility
	-- self.script_ai_planner:attack_force(enemy_force);
	self.script_ai_planner:move_to_force(enemy_force);
end;


--- @function defend
--- @desc Instructs all units in a generated army to defend a position.
--- @p number x co-ordinate, x co-ordinate in m
--- @p number y co-ordinate, y co-ordinate in m
--- @p number radius
function generated_army:defend(x, y, radius, no_debug_output)
	if self.is_debug and not no_debug_output then
		self.bm:out(self.id .. ":defend() called, defending position [" .. x .. ", " .. y .. "] with radius " .. radius .. "m");
	end;
	
	-- Ensure script planner is set up
	self:set_up_script_planner();
	
	self.script_ai_planner:defend_position(v(x, y), radius);
end;


--- @function release
--- @desc Instructs the generated army to release control of all its units to the player/general ai.
function generated_army:release(no_debug_output)
	if self.is_debug and not no_debug_output then
		self.bm:out(self.id .. ":release() called, releasing controlled units to the AI");
	end;

	-- release control of our sunits to the AI
	self:release_control_of_all_sunits();
end;

















----------------------------------------------------------------------------
---	@section Message Listeners
--- @desc These functions listen for messages and issue commands to the generated army on their receipt. They are intended to be the primary method of causing armies to follow orders on the battlefield during open gameplay - use these instead of issuing direct orders where possible.
----------------------------------------------------------------------------


--- @function teleport_to_start_location_offset_on_message
--- @desc Teleports the units in the army to their start position with the supplied offset when the supplied message is received.
--- @p string message
--- @p number x offset, x offset in m
--- @p number y offset y offset in m
function generated_army:teleport_to_start_location_offset_on_message(message, x_offset, z_offset)
	if not is_string(message) then
		script_error(self.id .. " ERROR: teleport_to_start_location_offset_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:out(self.id .. " responding to message " .. message .. ", teleporting to start location (offset: [" .. x_offset .. ", " .. z_offset .. "]");
			self:teleport_to_start_location_offset(x_offset, z_offset);
		end
	)
end;


--- @function goto_start_location_on_message
--- @desc Instructs the units in the army to move to the locations they started the battle at when the supplied message is received.
--- @p string message
--- @p [opt=false] boolean move fast
function generated_army:goto_start_location_on_message(message, should_run)
	if not is_string(message) then
		script_error(self.id .. " ERROR: goto_start_location_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:out(self.id .. " responding to message " .. message .. ", moving to start location");
			self:goto_start_location(should_run)
		end
	)
end;


--- @function goto_location_offset_on_message
--- @desc Instructs the units in the army to move relative to their current locations when the supplied message is received.
--- @p string message
--- @p number x offset, x offset in m
--- @p number z offset, z offset in m
--- @p boolean move fast
function generated_army:goto_location_offset_on_message(message, x_offset, z_offset, should_run)
	if not is_string(message) then
		script_error(self.id .. " ERROR: goto_location_offset_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:out(self.id .. " responding to message " .. message .. ", moving to location offset [" .. x_offset .. ", " .. z_offset .. "]");
			self:goto_location_offset(x_offset, z_offset, should_run);
		end
	)
end;


--- @function set_enabled_on_message
--- @desc Sets the enabled status of a generated army on receipt of a message.
--- @p string message
--- @p boolean enabled
function generated_army:set_enabled_on_message(message, value)
	value = not not value;
	
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:out(self.id .. " responding to message " .. message .. ", setting enabled: " .. tostring(value));
			self:set_enabled(value);
		end
	)
end;


--- @function set_formation_on_message
--- @desc Sets the formation of the units in the generated army to the supplied formation on receipt of a message. For valid formation strings, see documentation for @script_units:change_formation.
--- @p string message, Message.
--- @p string formation, Formation name.
--- @p boolean release, set to <code>true</code> to release script control after issuing the command. Set this if the command is happening to the player's army.
function generated_army:set_formation_on_message(message, formation, release_afterwards)
	if not is_string(message) then
		script_error(self.id .. " ERROR: set_formation_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(formation) then
		script_error(self.id .. " ERROR: set_formation_on_message() called but supplied formation name [" .. tostring(formation) .. "] is not a string");
		return false;
	end;
	
	release_afterwards = not not release_afterwards;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. " responding to message " .. message .. ", changing unit formation to " .. formation);
			self.uc:change_group_formation(formation);
			
			if release_afterwards then
				self.uc:release_control();
			end;
		end
	);	
end;


--- @function move_to_position_on_message
--- @desc Instructs all units in a generated army to move to a position under control of a @script_ai_planner on receipt of a message. See @generated_army:move_to_position.
--- @p string message
--- @p vector position
function generated_army:move_to_position_on_message(message, position)
	if not is_string(message) then
		script_error(self.id .. " ERROR: move_to_position_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_vector(position) then
		script_error(self.id .. " ERROR: move_to_position_on_message() called but supplied position [" .. tostring(position) .. "] is not a vector");
		return false;
	end;
		
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:out(self.id .. " responding to message " .. message .. ", being told to move to position " .. v_to_s(position));
			self:move_to_position(position);
		end
	)
end;


--- @function advance_on_message
--- @desc Orders the units in the generated army to advance on the enemy upon receipt of a supplied message.
--- @p string message, Message.
--- @p [opt=0] number wait offset, Time to wait after receipt of the message before issuing the advance order.
function generated_army:advance_on_message(message, wait_offset)
	if not is_string(message) then
		script_error(self.id .. " ERROR: advance_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error(self.id .. " ERROR: advance_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number");
		return false;
	end;
		
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function()
			if wait_offset == 0 then
				self.bm:out(self.id .. " responding to message " .. message .. ", being told to advance");
				self:advance(true);
			else
				self.bm:out(self.id .. " responding to message " .. message .. ", being told to advance - will wait " .. wait_offset .. "ms before issuing order");
				self.bm:callback(
					function()
						self:advance(true);
					end,
					wait_offset
				);
			end;
		end
	);
end;


--- @function attack_on_message
--- @desc Orders the units in the generated army to attack the enemy upon receipt of a supplied message.
--- @p string message, Message.
--- @p [opt=0] number wait offset, Time to wait after receipt of the message before issuing the attack order.
function generated_army:attack_on_message(message, wait_offset)
	if not is_string(message) then
		script_error(self.id .. " ERROR: attack_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error(self.id .. " ERROR: attack_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number");
		return false;
	end;
		
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function()
			if wait_offset == 0 then
				self.bm:out(self.id .. " responding to message " .. message .. ", being told to attack");
				self:attack(true);
			else
				self.bm:out(self.id .. " responding to message " .. message .. ", being told to attack - will wait " .. wait_offset .. "ms before issuing order");
				self.bm:callback(
					function()
						self:attack(true);
					end,
					wait_offset
				);
			end;
		end
	);
end;


--- @function attack_force_on_message
--- @desc Orders the units in the generated army to attack a specified enemy force upon receipt of a supplied message.
--- @p string message, Message.
--- @p generated_army target, Target force.
--- @p [opt=0] number wait offset, Time to wait after receipt of the message before issuing the attack order.
function generated_army:attack_force_on_message(message, enemy_force, wait_offset)
	if not is_string(message) then
		script_error(self.id .. " ERROR: attack_force_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_generatedarmy(enemy_force) then
		script_error(self.id .. " ERROR: attack_force_on_message() called but supplied enemy force [" .. tostring(enemy_force) .. "] is not a generated army");
		return false;
	end;
	
	if enemy_force.alliance_number == self.alliance_number then
		script_error(self.id .. " ERROR: attack_force_on_message() called but supplied enemy force [" .. tostring(enemy_force) .. "] is an ally");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error(self.id .. " ERROR: attack_force_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out(self.id .. " responding to message " .. message .. ", being told to attack enemy force with script name " .. enemy_force.script_name);
					
					self:attack_force(enemy_force.sunits);
				end,
				wait_offset
			);
		end
	);
end;


--- @function defend_on_message
--- @desc Orders the units in the generated army to defend a specified position upon receipt of a supplied message.
--- @p string message, Message.
--- @p number x co-ordinate, x co-ordinate in m.
--- @p number x co-ordinate, y co-ordinate in m.
--- @p number radius, Defence radius.
--- @p [opt=0] number wait offset, Time to wait after receipt of the message before issuing the defend order.
function generated_army:defend_on_message(message, x, y, radius, wait_offset)
	if not is_string(message) then
		script_error(self.id .. " ERROR: defend_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(x) then
		script_error(self.id .. " ERROR: defend_on_message() called but supplied x co-ordinate [" .. tostring(x) .. "] is not a number");
		return false;
	end;
	
	if not is_number(y) then
		script_error(self.id .. " ERROR: defend_on_message() called but supplied y co-ordinate [" .. tostring(y) .. "] is not a number");
		return false;
	end;
	
	if not is_number(radius) then
		script_error(self.id .. " ERROR: defend_on_message() called but supplied radius [" .. tostring(radius) .. "] is not a number");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error(self.id .. " ERROR: defend_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:callback(
				function()
					self.bm:out(self.id .. " responding to message message " .. message .. ", being told to defend [" .. tostring(x) .. ", " .. tostring(y) .. "] with radius " .. tostring(radius));
					self:defend(x, y, radius, true);
				end,
				wait_offset
			);
		end
	)
end;


--- @function release_on_message
--- @desc Releases script control of the units in the generated army to the player/general AI upon receipt of a supplied message.
--- @p string message, Message.
--- @p [opt=0] number wait offset, Time to wait after receipt of the message before the units are released.
function generated_army:release_on_message(message, wait_offset)
	if not is_string(message) then
		script_error(self.id .. " ERROR: release_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error(self.id .. " ERROR: defend_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number or nil");
		return false;
	end;
	
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:callback(
				function()
					self.bm:out(self.id .. " responding to message " .. message .. ", being released to AI");
					self:release(true);
				end,
				wait_offset
			);
		end
	)
end;


--- @function reinforce_on_message
--- @desc Prevents the units in the generated army from entering the battlefield as reinforcements until the specified message is received, at which point they are deployed.
--- @p string message, Message.
--- @p [opt=0] number wait offset, Time to wait after receipt of the message before issuing the reinforce order.
function generated_army:reinforce_on_message(message, wait_offset)
	if not is_string(message) then
		script_error(self.id .. " ERROR: reinforce_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if is_nil(wait_offset) then
		wait_offset = 0;
	elseif not is_number(wait_offset) or wait_offset < 0 then
		script_error(self.id .. " ERROR: reinforce_on_message() called but supplied wait_offset [" .. tostring(wait_offset) .. "] is not a positive number");
		return false;
	end;
	
	self.bm:out(self.id .. " is being prevented from reinforcing");
	
	self.sunits:deploy_reinforcement(false);
		
	self.sm:add_listener(
		message,
		function()
			self.bm:callback(
				function()
					self.bm:out(self.id .. " responding to message " .. message .. ", being told to deploy");
					self.sunits:deploy_reinforcement(true);
				end,
				wait_offset
			);
		end
	);
end;


--- @function rout_over_time_on_message
--- @desc Routs the units in the generated army over the specified time period upon receipt of a supplied message. See @script_units:rout_over_time.
--- @p string message, Message.
--- @p number wait offset, Period over which the units in the generated army should rout, in ms.
function generated_army:rout_over_time_on_message(message, period)
	if not is_string(message) then
		script_error(self.id .. " ERROR: rout_all_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(period) then
		script_error(self.id .. " ERROR: rout_all_on_message() called but supplied wait_offset [" .. tostring(period) .. "] is not a number");
		return false;
	end;
	
	if period < 0 then
		script_error(self.id .. " ERROR: rout_all_on_message() called but supplied wait_offset [" .. tostring(period) .. "] is not a positive number");
		return false;
	end;
		
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. " responding to message " .. message .. ", routing all units over a period of " .. period .. "ms");
			self.sunits:rout_over_time(period);
		end
	);
end;


--- @function withdraw_on_message
--- @desc Withdraw the units in the generated army upon receipt of a supplied message.
--- @p string message, Message.
function generated_army:withdraw_on_message(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: withdraw_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. " responding to message " .. message .. ", withdrawing units");
			self.sunits:withdraw(true);
		end
	);
end;


--- @function set_melee_mode_on_message
--- @desc Activates or deactivates melee mode on units within the generated army on receipt of a supplied message. An additional flag specifies whether script control of the units should be released afterwards - set this to true if the player is controlling this army.
--- @p string message, Message.
--- @p [opt=true] boolean activate, Should activate melee mode.
--- @p [opt=false] boolean release, Release script control afterwards.
function generated_army:set_melee_mode_on_message(message, activate, should_release)
	if not is_string(message) then
		script_error(self.id .. " ERROR: set_melee_mode_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. " responding to message " .. message .. ", setting melee mode for all units to " .. tostring(activate));
			self.sunits:set_melee_mode(activate, should_release);
		end
	);
end;


--- @function change_behaviour_active_on_message
--- @desc Activates or deactivates a supplied behaviour on units within the generated army on receipt of a supplied message. An additional flag specifies whether script control of the units should be released afterwards - set this to true if the player is controlling this army.
--- @p string message, Message.
--- @p string behaviour, Behaviour to activate or deactivate. See documentation on @script_unit:change_behaviour_active for a list of valid values.
--- @p [opt=true] boolean activate, Should activate behaviour.
--- @p [opt=false] boolean release, Release script control afterwards.
function generated_army:change_behaviour_active_on_message(message, behaviour, activate, should_release)
	if not is_string(message) then
		script_error(self.id .. " ERROR: change_behaviour_active_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_string(behaviour) then
		script_error(self.id .. " ERROR: change_behaviour_active_on_message() called but supplied behaviour [" .. tostring(behaviour) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. " responding to message " .. message .. ", setting behaviour " .. behaviour .. " for all units to " .. tostring(activate));
			self.sunits:change_behaviour_active(behaviour, activate, should_release);
		end
	);
end;


--- @function set_invincible_on_message
--- @desc Sets the units in the generated army to be invincible and fearless upon receipt of a supplied message.
--- @p string message, Message.
function generated_army:set_invincible_on_message(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: set_invincible_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. " responding to message " .. message .. ", making all currently-standing units invincible and fearless");
			self.sunits:invincible_if_standing();
		end
	);
end;


--- @function deploy_at_random_intervals_on_message
--- @desc Prevents the units in the generated army from deploying as reinforcements when called, and instructs them to enter the battlefield in random chunks upon receipt of a supplied message. Supply min/max values for the number of units to be deployed at one time, and a min/max period between deployment chunks. Each chunk will be of a random size between the supplied min/max, and will deploy onto the battlefield at a random interval between the supplied min/max period after the previous chunk. This process will repeat until all units in the generated army are deployed, or until the cancel message is received. See @script_units:deploy_at_random_intervals for more information.
--- @desc A cancel message may also be supplied, which will stop the reinforcement process either before or after the trigger message is received.
--- @p string message, Trigger message.
--- @p number min units, Minimum number of units to deploy in chunk.
--- @p number max units, Maximum number of units to deploy in chunk.
--- @p string min period, Minimum duration between chunks.
--- @p string max period, Maximum duration between chunks.
--- @p [opt=nil] string cancel message, Cancel message. If specified, this stops the deployment once received.
function generated_army:deploy_at_random_intervals_on_message(message, min_units, max_units, min_period, max_period, cancel_message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: deploy_at_random_intervals_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_nil(cancel_message) and not is_string(cancel_message) then
		script_error("generated_battle ERROR: deploy_at_random_intervals_on_message() called but supplied cancellation message [" .. tostring(cancel_message) .. "] is not a string");
		return false;
	end;
	
	self.bm:out(self.id .. " is being prevented from reinforcing");
	self.sunits:deploy_reinforcement(false);
	
	local cancel_message_received = false;
	
	self.sm:add_listener(
		message,
		function()
			if not cancel_message_received then
				self.bm:out(self.id .. " responding to message " .. message .. ", starting to deploy reinforcements at random intervals");
				self.sunits:deploy_at_random_intervals(min_units, max_units, min_period, max_period, true);
			end;
		end,
		0
	);
	
	if cancel_message then
		self.sm:add_listener(
			cancel_message,
			function()
				self.bm:out("generated_battle:deploy_at_random_intervals_on_message() has received cancellation message " .. cancel_message .. " so will stop trickling reinforcements");
				self.sunits:cancel_deploy_at_random_intervals();
				cancel_message_received = true;
			end
		);
	end
end;


--- @function grant_infinite_ammo_on_message
--- @desc Continually refills the ammunition of all units in the generated army upon receipt of the supplied message.
--- @p string message
function generated_army:grant_infinite_ammo_on_message(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: grant_infinite_ammo_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. " responding to message " .. message .. ", granting infinite ammo");
			self.sunits:grant_infinite_ammo();
		end,
		0
	);
end;


-- [ARMY]
--- @function add_ping_icon_on_message
--- @desc Adds a ping marker to a specified unit within the generated army upon receipt of a supplied message.
--- @p string message, Trigger message
--- @p [opt=8] number icon type, Icon type. This is a numeric index defined in code.
--- @p [opt=1] number unit index, The unit to apply the ping marker to is specified by their index value within the generated army, so 1 would be the first unit (usually the general).
--- @p [opt=nil] number duration, Duration to display the ping icon for, in ms
function generated_army:add_ping_icon_on_message(message, icon_type, unit_index, duration)
	if not is_string(message) then
		script_error(self.id .. " ERROR: add_ping_icon_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	unit_index = unit_index or 1;
	icon_type = icon_type or 8;

	if unit_index and not (is_number(unit_index) and unit_index > 0) then
		script_error(self.id .. " ERROR: add_ping_icon_on_message() called but supplied unit index [" .. tostring(unit_index) .. "] is not a number > 0 or nil");
		return false;
	end;

	if unit_index > self.sunits:count() then
		script_error(self.id .. " ERROR: add_ping_icon_on_message() called with unit index [" .. tostring(unit_index) .. "] but this is greater than the number of units in this army [" .. self.sunits:count() .. "]");
		return false;
	end;
	
	if duration and not (is_number(duration) and duration > 0) then
		script_error(self.id .. " ERROR: add_ping_icon_on_message() called but supplied duration [" .. tostring(duration) .. "] is not a positive number or nil");
		return false;
	end;
	
	if icon_type and not is_number(icon_type) then
		script_error(self.id .. " ERROR: add_ping_icon_on_message() called but supplied icon type [" .. tostring(icon_type) .. "] is not a number or nil");
		return false;
	end;
	
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:out(self.id .. " responding to message " .. message .. ", adding ping icon to unit (index: " .. unit_index .. ")");
			self:add_ping_icon(icon_type, unit_index, duration);
		end
	);
end;


-- [ARMY]
--- @function remove_ping_icon_on_message
--- @desc Removes a ping marker from a specified unit within the generated army upon receipt of a supplied message.
--- @p string message, Trigger message
--- @p [opt=1] number unit index, The unit to remove the ping marker from is specified by their index value within the generated army, so 1 would be the first unit (usually the general).
function generated_army:remove_ping_icon_on_message(message, unit_index)
	if not is_string(message) then
		script_error(self.id .. " ERROR: remove_ping_icon_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	unit_index = unit_index or 1;

	if unit_index and not (is_number(unit_index) and unit_index > 0) then
		script_error(self.id .. " ERROR: remove_ping_icon_on_message() called but supplied unit index [" .. tostring(unit_index) .. "] is not a number > 0 or nil");
		return false;
	end;

	if unit_index > #self.sunits then
		script_error(self.id .. " ERROR: remove_ping_icon_on_message() called with unit index [" .. tostring(unit_index) .. "] but this is greater than the number of units in this army [" .. #self.sunits .. "]");
		return false;
	end;
	
	-- set up a listener for this message
	self.sm:add_listener(
		message, 
		function() 
			self.bm:out(self.id .. " responding to message " .. message .. ", removing ping icon from unit (index: " .. unit_index .. ")");
			self:remove_ping_icon(unit_index);
		end
	);
end;


--- @function add_winds_of_magic_on_message
--- @desc Adds an amount to the winds of magic reserve for the generated army upon receipt of a supplied message.
--- @p string message, Trigger message.
--- @p number modification value, Winds of Magic modification value.
function generated_army:add_winds_of_magic_on_message(message, value)
	if not is_string(message) then
		script_error(self.id .. " ERROR: add_winds_of_magic_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(value) then
		script_error(self.id .. " ERROR: add_winds_of_magic_on_message() called but supplied value [" .. tostring(value) .. "] is not a number");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. " responding to message " .. message .. ", adding [" .. value .. "] to winds of magic reserve");
			self.army:modify_winds_of_magic_max_depletion(value);
		end,
		0
	);
end;


--- @function set_always_visible_on_message
--- @desc On receipt of the supplied message, sets the army's visibility status to the supplied true or false value. True = the army will not be hidden by terrain LOS, false = the army can be (i.e. normal behaviour). Note that the target units will still be able to hide in forests or long grass. Also note that they may perform a fade in from the point this function is called, so may not be fully visible until several seconds later.
--- @desc If the release_control flag is set to true, control of the sunits is released after the operation is performed. Do this if the army belongs to the player, otherwise they won't be able to control them.
--- @p string message
--- @p [opt=false] boolean always visible
--- @p [opt=false] boolean release control
function generated_army:set_always_visible_on_message(message, value, release_control)
	if not is_string(message) then
		script_error(self.id .. " ERROR: set_always_visible_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	value = not not value;
	release_control = not not release_control;
	
	self.sm:add_listener(
		message,
		function()
			local output_str = self.id .. ":set_always_visible_on_message() has received message " .. message .. " and is now forcing always-visible status to " .. tostring(value);
			
			if release_control then
				self.bm:out(output_str .. ", also releasing control");
			else
				self.bm:out(output_str);
			end;
			
			-- ensure we have built our allied and enemy forces
			self:get_allied_and_enemy_forces();
			
			-- set this army's visibility status
			self.sunits:set_always_visible(true);
			
			if release_control then
				self.sunits:release_control();
			end;
		end
	);

end;


--- @function force_victory_on_message
--- @desc Forces the enemies of the generated army to rout over time upon receipt of the supplied message. After the enemies have all routed, this generated army will win the battle.
--- @p string message, Trigger message.
--- @p [opt=10000] number duration, Duration over which to rout the enemy in ms.
function generated_army:force_victory_on_message(message, duration)
	if not is_string(message) then
		script_error(self.id .. " ERROR: force_victory_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	duration = duration or 10000;
	
	if not is_number(duration) or duration < 0 then
		script_error(self.id .. " ERROR: force_victory_on_message() called but supplied duration [" .. tostring(duration) .. "] is not a positive number");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out(self.id .. ":force_victory_on_message() now forcing victory over " .. duration .. "ms after receiving message " .. message);
			
			-- ensure we have built our allied and enemy forces
			self:get_allied_and_enemy_forces();
			
			-- prevent the battle from ending once the enemy commander dies
			self.bm:change_victory_countdown_limit(-1);		-- function needs it in seconds

			-- start the enemy army routing over the duration
			self.enemy_force:rout_over_time(duration);

			-- prevent this army from routing in this time
			self.sunits:invincible_if_standing(true);

			-- allow battle to end after the duration
			self.bm:callback(
				function()
					-- force the battle victory at the point that all units should be routed - this makes the command work even if reinforcements have yet to come on to the battlefield
					self.bm:alliances():item(self.alliance_number):force_battle_victory();
					
					self.bm:end_battle()
				end,
				duration
			);
		end
	);
end;


--- @function remove_on_message
--- @desc Immediately kills and removes the units in the generated army upon receipt of the supplied message.
--- @p string message, Trigger message.
function generated_army:remove_on_message(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: remove_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out("generated_battle:remove_on_message() is killing and removing army after receiving message " .. message);
			self.sunits:kill_proportion(1, false, true);
		end
	);
end;


--- @function take_control_on_message
--- @desc Forces script control upon receipt of the supplied message. While this prevents the general AI from issuing orders to the units it will not be effective while scripted AI behaviours are active. As such, it is of most use during intro cutscenes.
--- @p string message, Trigger message.
function generated_army:take_control_on_message(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: take_control_on_message() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	self.sm:add_listener(
		message,
		function()
			self.bm:out("generated_battle:take_control_on_message() is taking script control of these units after receiving message " .. message);
			self.sunits:take_control();
		end
	);
end;











----------------------------------------------------------------------------
---	@section Message Generation
--- @desc These functions listen for conditions and generate messages when they are met.
----------------------------------------------------------------------------


--- @function message_on_casualties
--- @desc Fires the supplied message when the casualty rate of this generated army equals or exceeds the supplied threshold.
--- @p string message, Message to trigger.
--- @p number unary threshold, Unary threshold (between 0 and 1).
function generated_army:message_on_casualties(message, threshold)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_casualties() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(threshold) then
		script_error(self.id .. " ERROR: message_on_casualties() called but supplied threshold [" .. tostring(threshold) .. "] is not a number");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_casualties(message, threshold) end);
		return;
	end;
	
	self.bm:watch(
		function()
			local current_casualty_rate = self:get_casualty_rate();
			-- self.bm:out(self.id .. " is checking casualty rate and found it to be " .. tostring(current_casualty_rate));
			return current_casualty_rate > threshold;
		end,
		0,
		function()
			self.bm:out(self.id .. " casualty rate has exceeded threshold of " .. threshold .. ", triggering script message " .. message);		
			self.sm:trigger_message(message)
		end,
		self.id
	);
end;


--- @function message_on_proximity_to_enemy
--- @desc Triggers the supplied message when this generated army finds itself with the supplied distance of its enemy.
--- @p string message, Message to trigger.
--- @p number threshold distance, Threshold distance in m.
function generated_army:message_on_proximity_to_enemy(message, distance)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_proximity_to_enemy() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(distance) then
		script_error(self.id .. " ERROR: message_on_proximity_to_enemy() called but supplied distance [" .. tostring(distance) .. "] is not a number");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_proximity_to_enemy(message, distance) end);
		return;
	end;
	
	-- ensure we have built our allied and enemy forces
	self:get_allied_and_enemy_forces();
	
	self.bm:watch(
		function()
			local current_distance = distance_between_forces(self.army, self.enemy_force, true);
			-- self.bm:out(self.id .. " is checking current distance to enemy and found it to be " .. tostring(current_distance) .. "m");
			return current_distance < distance;
		end,
		0,
		function()
			self.bm:out(self.id .. " enemy have moved within " .. distance .. "m, triggering script message " .. message);		
			self.sm:trigger_message(message);
		end,
		self.id
	);
end;


--- @function message_on_proximity_to_ally
--- @desc Triggers the supplied message when this generated army finds itself with the supplied distance of any allied generated armies.
--- @p string message, Message to trigger.
--- @p number threshold distance, Threshold distance in m.
function generated_army:message_on_proximity_to_ally(message, distance)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_proximity_to_ally() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(distance) then
		script_error(self.id .. " ERROR: message_on_proximity_to_ally() called but supplied distance [" .. tostring(distance) .. "] is not a number");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_proximity_to_ally(message, distance) end);
		return;
	end;
	
	-- ensure we have built our allied and enemy forces
	self:get_allied_and_enemy_forces();
	
	if is_nil(self.allied_force) then
		script_error(self.id .. " ERROR: message_on_proximity_to_ally() called but there is no allied force in the battle.");
		return false;
	end
	
	self.bm:watch(
		function()
			local current_distance = distance_between_forces(self.army, self.allied_force, true);
			-- self.bm:out(self.id .. " is checking current distance to enemy and found it to be " .. tostring(current_distance) .. "m");
			return current_distance < distance;
		end,
		0,
		function()
			self.bm:out(self.id .. " enemy have moved within " .. distance .. "m, triggering script message " .. message);		
			self.sm:trigger_message(message);
		end,
		self.id
	);
end;


--- @function message_on_proximity_to_position
--- @desc Triggers the supplied message when this generated army finds itself with the supplied distance of the supplied position.
--- @p string message, Message to trigger.
--- @p vector position, Test position.
--- @p number threshold distance, Threshold distance in m.
function generated_army:message_on_proximity_to_position(message, position, distance)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_proximity_to_position() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_vector(position) then
		script_error(self.id .. " ERROR: message_on_proximity_to_position() called but supplied position [" .. tostring(position) .. "] is not a vector");
		return false;
	end;
	
	if not is_number(distance) or distance <= 0 then
		script_error(self.id .. " ERROR: message_on_proximity_to_position() called but supplied distance [" .. tostring(distance) .. "] is not a positive number");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_proximity_to_position(message, position, distance) end);
		return;
	end;
	
	-- ensure we have built our allied and enemy forces
	self:get_allied_and_enemy_forces();
	
	self.bm:watch(
		function()
			return standing_is_close_to_position(self.sunits, position, distance)
		end,
		0,
		function()
			self.bm:out(self.id .. " has moved within " .. distance .. "m of " .. v_to_s(position) .. ", triggering script message " .. message);		
			self.sm:trigger_message(message);
		end,
		self.id
	);
end;


--- @function message_on_rout_proportion
--- @desc Triggers the supplied message when the proportion of units routing in this generated army exceeds the supplied unary threshold.
--- @p string message, Message to trigger.
--- @p number threshold, Unary threshold (0 - 1).
function generated_army:message_on_rout_proportion(message, threshold)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_rout_proportion() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(threshold) then
		script_error(self.id .. " ERROR: message_on_rout_proportion() called but supplied threshold [" .. tostring(threshold) .. "] is not a number");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_rout_proportion(message, threshold) end);
		return;
	end;
	
	self.bm:watch(
		function()
			local current_rout_proportion = self:get_rout_proportion();
			-- self.bm:out(self.id .. " is checking rout proportion and found it to be " .. tostring(current_rout_proportion));		
			return current_rout_proportion >= threshold;
		end,
		0,
		function()
			self.bm:out(self.id .. " rout proportion has exceeded threshold of " .. threshold .. ", triggering script message " .. message);
			self.sm:trigger_message(message)
		end,
		self.id
	);
end;


--- @function message_on_shattered_proportion
--- @desc Triggers the supplied message when the proportion of units that are shattered in this generated army exceeds the supplied unary threshold.
--- @p string message, Message to trigger.
--- @p number threshold, Unary threshold (0 - 1).
function generated_army:message_on_shattered_proportion(message, threshold)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_shattered_proportion() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	if not is_number(threshold) then
		script_error(self.id .. " ERROR: message_on_shattered_proportion() called but supplied threshold [" .. tostring(threshold) .. "] is not a number");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_shattered_proportion(message, threshold) end);
		return;
	end;
	
	self.bm:watch(
		function()
			local current_shattered_proportion = self:get_shattered_proportion();
			-- self.bm:out(self.id .. " is checking rout proportion and found it to be " .. tostring(current_rout_proportion));		
			return current_shattered_proportion >= threshold;
		end,
		0,
		function()
			self.bm:out(self.id .. " shattered proportion has exceeded threshold of " .. threshold .. ", triggering script message " .. message);
			self.sm:trigger_message(message)
		end,
		self.id
	);
end;


--- @function message_on_deployed
--- @desc Triggers the supplied message when the units in the generated army are all fully deployed.
--- @p string message, Message to trigger.
function generated_army:message_on_deployed(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_deployed() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_deployed(message) end);
		return;
	end;
	
	self.bm:watch(
		function()
			return has_deployed(self.sunits);
		end,
		0,
		function()
			self.bm:out(self.id .. " has deployed, triggering script message " .. message);
			self.sm:trigger_message(message)
		end,
		self.id
	);
end;


--- @function message_on_any_deployed
--- @desc Triggers the supplied message when any of the units in the generated army have deployed.
--- @p string message, Message to trigger.
function generated_army:message_on_any_deployed(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_any_deployed() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_any_deployed(message) end);
		return;
	end;
	
	self.bm:watch(
		function()
			return self.sunits:have_any_deployed();
		end,
		0,
		function()
			self.bm:out(self.id .. " has partially deployed, triggering script message " .. message);
			self.sm:trigger_message(message)
		end,
		self.id
	);
end;


--- @function message_on_seen_by_enemy
--- @desc Triggers the supplied message when any of the units in the generated army have become visible to the enemy.
--- @p string message, Message to trigger.
function generated_army:message_on_seen_by_enemy(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_seen_by_enemy() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_seen_by_enemy(message) end);
		return;
	end;
	
	-- get a handle to the enemy alliance (bit inelegant, this)
	local enemy_alliance = nil;
	if self.alliance_number == 1 then
		enemy_alliance = self.bm:alliances():item(2);
	else
		enemy_alliance = self.bm:alliances():item(1);
	end;
	
		
	self.bm:watch(
		function()
			return is_visible(self.sunits, enemy_alliance);
		end,
		0,
		function()
			self.bm:out(self.id .. " is visible to its enemy, triggering script message " .. message);
			self.sm:trigger_message(message)
		end,
		self.id
	);
end;


--- @function message_on_commander_death
--- @desc Triggers the supplied message when the commander of the army corresponding to this generated army has died. Note that the commander of the army may not be in this generated army.
--- @p string message, Message to trigger.
function generated_army:message_on_commander_death(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_commander_death() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_commander_death(message) end);
		return;
	end;
	
	self.bm:watch(
		function()
			return not self.army:is_commander_alive()
		end,
		0,
		function()
			self.bm:out(self.id .. " has lost its commander, triggering script message " .. message);
			self.sm:trigger_message(message)
		end,
		self.id
	);
end;


--- @function message_on_commander_dead_or_routing
--- @desc Triggers the supplied message when the commanding unit within this generated army is either dead or routing. If no commanding unit exists in the generated army, this function will throw a script error.
--- @p string message, Message to trigger.
function generated_army:message_on_commander_dead_or_routing(message)
	
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_commander_dead_or_routing() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;

	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_commander_dead_or_routing(message) end);
		return;
	end;

	local unit;
	--Get and cache the general of the army.
	for i = 1, self.army:units():count() do
		if self.army:units():item(i):is_commanding_unit() then
			unit = self.army:units():item(i);
			break;
		end
	end
	
	if is_nil(unit) then
		script_error(self.id .. " ERROR: message_on_commander_dead_or_routing() called but this generated army has no general.");
		return false;
	end
	
	self.bm:out(self.id .. " Registering message_on_commander_dead_or_routing() with message " .. tostring(message));
	
	self.bm:watch(
		function()
			return unit:is_routing() or unit:is_shattered() or not self.army:is_commander_alive();
		end,
		0,
		function()
			self.bm:out(self.id .. " commander is dead or routing, triggering script message " .. message);
			self.sm:trigger_message(message);
		end,
		self.id
	);
end


--- @function message_on_commander_dead_or_shattered
--- @desc Triggers the supplied message when the commanding unit within this generated army is either dead or shattered. If no commanding unit is present, this function will throw a script error.
--- @p string message, Message to trigger.
function generated_army:message_on_commander_dead_or_shattered(message)

	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_commander_dead_or_shattered() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;

	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_commander_dead_or_shattered(message) end);
		return;
	end;

	local unit;
	--Get and cache the general of the army.
	for i = 1, self.army:units():count() do
		if self.army:units():item(i):is_commanding_unit() then
			unit = self.army:units():item(i);
			break;
		end
	end
	
	if is_nil(unit) then
		script_error(self.id .. " ERROR: message_on_commander_dead_or_shattered() called but this army has no general.");
		return false;
	end
	
	self.bm:out(self.id .. " Registering message_on_commander_dead_or_shattered() with message " .. tostring(message));
	
	self.bm:watch(
		function()
			return unit:is_shattered() or not self.army:is_commander_alive() or unit:number_of_men_alive() < 1;
		end,
		0,
		function()
			self.bm:out(self.id .. " commander is dead or shattered, triggering script message " .. message);
			self.sm:trigger_message(message);
		end,
		self.id
	);
end


--- @function message_on_under_attack
--- @desc Triggers the supplied message when any of the units in this generated army come under attack.
--- @p string message, Message to trigger.
function generated_army:message_on_under_attack(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_under_attack() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_under_attack(message) end);
		return;
	end;
	
	-- cache the current health of all these units
	self.sunits:cache_health(true);
	
	self.bm:watch(
		function()
			return self.sunits:is_under_attack();
		end,
		0,
		function()
			self.bm:out(self.id .. " is under attack, triggering script message " .. message);
			self.sm:trigger_message(message)
		end,
		self.id
	);
end;


--- @function message_on_alliance_not_active_on_battlefield
--- @desc Triggers the supplied message if none of the units in the alliance to which this generated army belongs are a) deployed and b) not routing, shattered or dead
--- @p string message, Message to trigger.
function generated_army:message_on_alliance_not_active_on_battlefield(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_alliance_not_active_on_battlefield() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_alliance_not_active_on_battlefield(message) end);
		return;
	end;
	
	local alliance_sunits = self.generated_battle:get_allied_force(self.alliance_number, -1);
	
	local bm = self.bm;
	
	-- wait a moment for the units to enter the battlefield after deployment properly before beginning the monitor
	bm:callback(
		function()
			bm:watch(
				function()
					return not alliance_sunits:are_any_active_on_battlefield();
				end,
				0,
				function()
					bm:out(self.id .. " is triggering message " .. message .. " as no units from this alliance are active on the battlefield");
					self.sm:trigger_message(message)
				end,
				self.id
			);
		end,
		5000,
		self.id
	);
end;


-- called internally by the generated_battle object
function generated_army:notify_of_victory()
	if self.victory_message then
		local message = self.victory_message;
		
		self.bm:out(self.id .. " has won the battle, triggering script message " .. message);
		self.sm:trigger_message(message)
	end;
end;


-- called internally by the generated_battle object
function generated_army:notify_of_defeat()
	if self.defeat_message then
		local message = self.defeat_message;
		
		self.bm:out(self.id .. " has lost the battle, triggering script message " .. message);
		self.sm:trigger_message(message)
	end;
end;


--- @function message_on_victory
--- @desc Triggers the supplied message if this generated army wins the battle.
--- @p string message, Message to trigger.
function generated_army:message_on_victory(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_victory() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_victory(message) end);
		return;
	end;
	
	self.victory_message = message;
end;


--- @function message_on_defeat
--- @desc Triggers the supplied message if this generated army loses the battle.
--- @p string message, Message to trigger.
function generated_army:message_on_defeat(message)
	if not is_string(message) then
		script_error(self.id .. " ERROR: message_on_defeat() called but supplied message [" .. tostring(message) .. "] is not a string");
		return false;
	end;
	
	-- if the battle hasn't started then put this off until it has
	if not self.generated_battle:has_battle_started() then
		self.sm:add_listener("battle_started", function() self:message_on_defeat(message) end);
		return;
	end;
	
	self.defeat_message = message;
end;
























----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--
--	GENERATED CUTSCENE
--
-- @class generated_cutscene Generated Cutscene
-- @page generated_battle
-- @desc Generated cutscenes provide a method of partially automating the camera movements and other events that occur in the intro cutscene of a @generated_battle.
--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------



--[[ Plays an autogenerated cutscene based on objects passed in. Expects the format:
{
	{[opt]sfx_name, subtitle, [opt]camera, [opt]loop_camera, [opt]min_length, [opt] wait_for_vo, [opt] wait_for_camera},
	{[opt]sfx_name, subtitle, [opt]camera, [opt]loop_camera, [opt]min_length, [opt] wait_for_vo, [opt] wait_for_camera}
}
]]--
generated_cutscene =
{
	is_debug = false, -- Should output debug values.
	iterated_time = 0,
	elapsed_time = 0,
	has_played_outro = false,
	has_skipped_cameras = false,
	has_skipped_vo = false,
	disable_outro_camera = false,
	outro_camera_key = "_end_cutscene_outro_camera",
	outro_camera_time = 4000,
	elements = {},
	use_wh2_subtitles = false,
	force_display_subtitles = false
}





----------------------------------------------------------------------------
-- @section Creation
----------------------------------------------------------------------------


-- @function new
-- @p [opt=false] boolean is debug
-- @p [opt=false] boolean disable outro camera
-- @p [opt=false] boolean ignore final camera index
-- @return generated_cutscene
function generated_cutscene:new(is_debug, disable_outro_camera, ignore_last_camera_index)
	is_debug = is_debug or false;
	disable_outro_camera = disable_outro_camera or false;
	ignore_last_camera_index = ignore_last_camera_index or false;
	
	local gc = {};
	setmetatable(gc, self);
	self.__index = self;
	self.__tostring = function() return TYPE_GENERATED_CUTSCENE end;
	
	gc.elements = {};
	gc.is_debug = is_debug;
	gc.disable_outro_camera = disable_outro_camera;
	gc.ignore_last_camera_index = ignore_last_camera_index;
	
	return gc;
end


function generated_cutscene:add_element(sfx_name, subtitle, camera, min_length, wait_for_vo, wait_for_camera, play_taunt_at_start, message_on_start)
	-- add a new table element.
	local ne = {};
	
	ne.id = "element_" .. #self.elements;

	ne.has_speech = false;
	if is_string(sfx_name) and sfx_name:len() > 0 then

		-- Test if it has PLAY_ at the start.
		local find_play = string.find(sfx_name, "Play_", 1);
		if is_nil(find_play) or find_play ~= 1 then
			sfx_name = "Play_" .. sfx_name
		end

		-- Passing speech in here as an empty string causes this to error.
		ne.speech = new_sfx(sfx_name);
		ne.has_speech = true;
	end
	
	ne.has_subtitle = false;
	if is_string(subtitle) and subtitle:len() > 0 then
		ne.subtitle = subtitle;
		ne.has_subtitle = true;
	end
	
	ne.has_camera = false;
	if is_string(camera) and camera:len() > 0 then
		ne.camera = camera;
		ne.loop_camera = false; -- Forcing to false as the actual camera files give better results.
		ne.has_camera = true;
	end
	
	ne.min_length = min_length;
	ne.wait_for_vo = wait_for_vo;
	ne.wait_for_camera = wait_for_camera;
	ne.play_taunt_at_start = play_taunt_at_start;
	
	if is_string(message_on_start) then
		ne.message_on_start = message_on_start;
	end
	
	table.insert(self.elements, ne);
end

function generated_cutscene:iterate_timer(amount)
	local iterate_amount = amount or 50
	if is_nil(self) then
		script_error("Trying to call function on nil self.");
		return 0;
	end
	
	self.elapsed_time = self.elapsed_time + iterate_amount;
	self.iterated_time = self.iterated_time + iterate_amount;

	return self.elapsed_time;
end

function generated_cutscene:set_wh2_subtitles()
	self.use_wh2_subtitles = true;
end;

function generated_cutscene:force_on_subtitles()
	self.force_display_subtitles = true;
end;

function generated_battle:start_generated_cutscene(gc)
	local bm = self.bm;

	bm:out("generated_battle: start_generated_cutscene(): Beginning cutscene generation.");
	
	if not is_generatedcutscene(gc) then
		script_error("generated_battle ERROR: start_generated_cutscene() called but supplied cutscene is not a cutscene");
		return false;
	end

	if #gc.elements < 1 then
		script_error("generated_battle ERROR: start_generated_cutscene() called but supplied elements is nil. Have you added any?");
		return false;
	end;
	
	
	-- Start our new cutscene
	local cutscene_intro = cutscene:new(
		"generated_cutscene_intro",
		self:get_army(self:get_player_alliance_num(), 1):get_unitcontroller(), -- We assume the player's army is always the first.
		10000000 -- Set to infinite so that the cutscene won't end unless we want it to.
	);	
		
	
	--Initial Settings
	cutscene_intro:set_do_not_end(true);
	cutscene_intro:set_show_cinematic_bars(true);
	cutscene_intro:subtitles():set_alignment("bottom_centre");
	cutscene_intro:subtitles():clear();
	cutscene_intro:set_skippable(false);
		
	--Use our own skip cutscene function as the cutscene skip ends the cutscene! Currently runs through and plays an outro which queues up the skip.
	self.bm:steal_escape_key_with_callback(
		"generated_battle_cutscene", 
		function() self:skip_generated_cutscene_cameras(cutscene_intro, gc)  end
	);
	
	self:enqueue_cutscene_elements(cutscene_intro, gc);
	
		
	-- Once we've loaded everything start the cutscene
	cutscene_intro:start();
end

function generated_battle:play_outro_camera(cutscene_intro, gc)
	if gc.has_played_outro then
		self.bm:out("generated_battle:play_outro_camera(): Already played an outro, skipping.");
		return;
	end

	-- Add in our outro camera here which will always play at the end.
	self.bm:out("generated_battle:play_outro_camera(): Playing Outro Camera");
	cutscene_intro:camera():play(gc.outro_camera_key .. ".battle_speech_camera", false);
	
	cutscene_intro:subtitles():clear();
	cutscene_intro:hide_custom_cutscene_subtitles();
	
	-- play a charge sound.
	self.bm:callback(
		function()
			gb:get_army(gb:get_player_alliance_num(), 1):play_sound_charge();
		end,
		1000
	);
	
	gc.has_played_outro = true;
	
	-- Add a listener to trigger the function afyer the camera has finished.
	self.bm:callback(
		function()
			get_messager():trigger_message("outro_camera_finished");
		end,
		gc.outro_camera_time
	);
	
end

-- When Esc is pressed.
-- Skips just the cameras for the generated cutscene.
function generated_battle:skip_generated_cutscene_cameras(cutscene_intro, gc)
	
	if gc.has_skipped_cameras then
		self.bm:out("generated_battle: skip_generated_cutscene_cameras(): We've alrerady skipped cameras, skipping.");
		return;
	end
	
	self.bm:out("generated_battle: skip_generated_cutscene_cameras(): Skipping Cameras");

	-- Remove esc key functionality.
	self.bm:release_escape_key_with_callback("generated_battle_cutscene");
	
	gc.has_skipped_cameras = true;
	
	--If we skip the outro just end all the cameras.
	if not gc.disable_outro_camera then
		-- Play the outro
		self:play_outro_camera(cutscene_intro, gc);
		
		--Wait for outro to finish before tidying up.
		gb:add_listener(
			"outro_camera_finished", 
			function() 
				self:clear_cameras(cutscene_intro, gc);
			end
		);
	else
		self.bm:out("generated_battle:skip_generated_cutscene_cameras(): Skipping Outro Camera");
		self:clear_cameras(cutscene_intro, gc);
	end;
	

	
end

function generated_battle:clear_cameras(cutscene_intro, gc)
	local bm = self.bm;

	-- Tidy up.
	cutscene_intro:camera():stop(true);
	cutscene_intro:set_show_cinematic_bars(false);
	cutscene_intro:subtitles():clear();
	cutscene_intro:hide_custom_cutscene_subtitles();
	bm:release_input_focus();
	bm:enable_cinematic_ui(false, true, false);
	cutscene_intro.cam:enable_anchor_to_army();
	cutscene_intro.cam:change_height_range(-1, -1);
	bm:change_conflict_time_update_overridden(false);
	cutscene_intro.cam:enable_shake();
	bm:enable_cinematic_camera(false);
	
	self:end_cutscene(cutscene_intro, gc);
	
	-- release the player's army
	if cutscene_intro.should_release_players_army then
		cutscene_intro.players_army:release_control();
	end;

	-- send a script message that a cutscene has finished (useful for generated battles)
	get_messager():trigger_message("generated_custscene_cameras_skipped");

	-- allow battle time to start elapsing
	bm:change_conflict_time_update_overridden(false);
end

-- When the cutscene naturally times out.
function generated_battle:finish_cutscene(cutscene_intro, gc)
	self.bm:out("generated_battle: end_cutscene(): Finishing Cutscene as it's played all elements.");
	
	self:skip_generated_cutscene_cameras(cutscene_intro, gc)
	
	gb:add_listener(
		"generated_custscene_cameras_skipped", 
		function() 
			self:end_cutscene(cutscene_intro, gc);
		end
	);
end

-- When Start Battle pressed after skipping cameras.
-- kills everything. 
function generated_battle:end_cutscene(cutscene_intro, gc)
	if gc.has_skipped_vo then
		self.bm:out("generated_battle: end_cutscene(): We've alrerady ended cutscene, skipping.");
		return;
	end
	
	self.bm:out("generated_battle: end_cutscene(): Ending Cutscene");
	
	self.sm:trigger_message("generated_custscene_ended");
	
	gc.has_skipped_vo = true;
	
	--cutscene_intro:skip();
	cutscene_intro:finish();
end

function generated_battle:enqueue_cutscene_elements(cutscene_intro, gc)
	-- Get the player commander as the source of the VO.
	local player_army = gb:get_army(gb:get_player_alliance_num(), 1);
	local player_commander = player_army:get_first_scriptunit();
	
	if not is_scriptunit(player_commander) then
		self.bm:out("No Commander found for player's army, VO will play in world");
	end
	
	--Loop through our fragments and queue up the actions.
	local last_camera_index = 0;
	for i,v in ipairs(gc.elements) do	
		if v.has_camera or v.wait_for_camera then
			last_camera_index = i;
		end
	end

	--Loop through our fragments and queue up the actions.
	for i,element in ipairs(gc.elements) do	
	-- SETUP --
		local speech = element.speech;
		local subtitle = element.subtitle;
		local camera = element.camera;
		local min_length = element.min_length;
		local wait_for_vo = element.wait_for_vo;
		local wait_for_camera = element.wait_for_camera;
		local loop_camera = element.loop_camera;
		local play_taunt_at_start = element.play_taunt_at_start;
		local message_on_start = element.message_on_start;
		
		if gc.is_debug then
			self.bm:out(element.id .. "= " .. tostring(speech) .. "," .. tostring(subtitle) .. "," .. tostring(camera) .. "," .. tostring(min_length) .. "," .. tostring(loop_camera) .. "," .. tostring(wait_for_vo_start) .. "," .. tostring(wait_for_vo_end));
		end
		
		
	-- ERROR CHECKING --
	
		-- Make sure we don't have a wait for camera and a looping camera as this could go on forever.
		if wait_for_camera and loop_camera then
			script_error("Adding a looping camera and a wait for camera on element " .. element.id .. ". This is not allowed, exiting cutscene.");
			return;
		end;
		
			
		
	-- EARLY EXIT --
		--If this was the last camera exit back into regular deployment.		
		if not gc.ignore_last_camera_index and i > last_camera_index then	
			cutscene_intro:action(
				function() 
					if gc.is_debug then
						self.bm:out("generated_battle: enqueue_cutscene_elements(): Last camera ended, restoring control.");
					end
					self:skip_generated_cutscene_cameras(cutscene_intro, gc);
				end, 
				gc:iterate_timer()
			);
		end

		
	-- MESSAGE ON START --
		if not is_nil(message_on_start) and is_string(message_on_start) then
			cutscene_intro:action(
				function()
					if not gc.has_skipped_vo then
						if gc.is_debug then
							self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Playing speechfile: " .. tostring(speech));
						end
						self.sm:trigger_message(message_on_start);
					end
				end, 
				gc.elapsed_time
			);
		end
	
	
	-- AUDIO  & SUBTITLES --
		
		--If we haven't skipped the VO - This occurs when the battle starts.
		if not gc.has_skipped_vo then
		
			-- If we have an audio file then play audio
			if element.has_speech then
				cutscene_intro:action(
					function()
						if not gc.has_skipped_vo then
							-- If we have a player commander he should be speaking. If not we play the sound in 2D space.
							if is_scriptunit(player_commander) then
								cutscene_intro:play_vo(speech, player_commander);
								if gc.is_debug then
									self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Playing Speech as VO : " .. tostring(speech));
								end
							else
								cutscene_intro:play_sound(speech);
								if gc.is_debug then
									self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Playing Speech as Sound: " .. tostring(speech));
								end
							end
						end
					end, 
					gc:iterate_timer()
				);
			end
			
			-- Show Subtitles
			if element.has_subtitle then
				cutscene_intro:action(
					function() 
						if not gc.has_skipped_vo and (effect.subtitles_enabled() or gc.force_display_subtitles) then
							if gc.is_debug then
								self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Showing subtitle: " .. subtitle);
							end
							if gc.use_wh2_subtitles then
								cutscene_intro:show_custom_cutscene_subtitle("scripted_subtitles_localised_text_" .. subtitle, "subtitle_with_frame", 5, true);
							else
								cutscene_intro:subtitles():set_text(subtitle);
							end;
						end
					end, 
					gc:iterate_timer()
				);
			end
		else
			if gc.is_debug then
				self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- No vo or subtitles");
			end
		end
		
		
	-- CAMERAS --
		
		-- Check is the player has skipped the intro with the ESC key. We only want to skip cameras at that point.
		if not gc.has_skipped_cameras and not gc.has_played_outro then
			if play_taunt_at_start then
				cutscene_intro:action(
					function() 
						if not gc.has_skipped_cameras and not gc.has_played_outro then
							if gc.is_debug then
								self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Playing Taunt");
							end
							
							player_army:taunt();
							player_army:play_sound_taunt();
						end
					end, 
					gc:iterate_timer()
				); 
			end
			
			-- Play Camera
			if element.has_camera then
				cutscene_intro:action(
					function() 
						if not gc.has_skipped_cameras and not gc.has_played_outro then
							if gc.is_debug then
								self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Playing Camera: " .. camera .. ".battle_speech_camera");
							end
							
							--cutscene_intro:camera():stop();--Stop the previous camera.
							cutscene_intro:camera():play(camera .. ".battle_speech_camera", loop_camera)
						end
					end, 
					gc:iterate_timer()
				); 
			end
		else
			if gc.is_debug then
				self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- No cameras or skipped.");
			end
		end
		
		
	-- WAITS --

		-- Wait for the vo to finish before we move on. should auto return false if we don't have VO playing
		--Iterate to allow for audio to play.
		gc:iterate_timer(500);

		if wait_for_vo then
			cutscene_intro:action(
				function()
					if gc.is_debug then
						self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Setting Wait for VO");
					end
					cutscene_intro:wait_for_vo() 
				end, 
				gc:iterate_timer()
			);
		else
			if gc.is_debug then
				self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Will not Wait for VO");
			end
		end
		
		
		-- Wait for the camera to end before advancing.
		if cutscene_intro:is_playing_camera() then
			if wait_for_camera then
				cutscene_intro:action(
					function() 
						if gc.has_skipped_cameras or gc.has_played_outro then
							self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Skipping wait for camera as we've skipped them.");
							return;
						end
						
						if gc.is_debug then
							self.bm:out("generated_battle: enqueue_cutscene_elements(): " .. element.id .."- Setting Wait for camera.");
						end
						
						cutscene_intro:wait_for_camera() 
					end, 
					gc:iterate_timer()
				);
			else
				if gc.is_debug then
					self.bm:out("generated_battle: start_generated_cutscene(): " .. element.id .."- Will not Wait for Camera");
				end
			end
		end		
		
		--Iterate the cutscene by the min_time so that it always plays for at least x seconds.
		--Since we use a lot of time between elements, we store how much we've used and subtract it from the min time so we can never add too much.
		gc.elapsed_time = gc.elapsed_time + (min_length - gc.iterated_time);
		gc.iterated_time = 0;
	end;
	
	-- FINISHING --	
	
	-- When we finish naturally we play outro, skip and end the cutscene.
	cutscene_intro:action(
		function() 
			if gc.is_debug then
				self.bm:out("generated_battle: enqueue_cutscene_elements(): No more fragments to play. Ending cutscene.");
			end
			cutscene_intro:hide_custom_cutscene_subtitles();
			self:finish_cutscene(cutscene_intro, gc);
			
		end, 
		gc:iterate_timer()
	);
	
	
-- SKIPPING --	

	-- Kill the cutscene when start battle is pressed. This means the playert has already skipped cameras, so just end.
	self.sm:add_listener(
		"battle_started",
		function()
			self.bm:callback(
				function()
					self.bm:out("generated_battle:enqueue_cutscene_elements() Battle Started - Stopping VO");
					self:end_cutscene(cutscene_intro, gc)
				end,
				0
			);
		end
	);
	
	
	if gc.is_debug then
		self.bm:out("generated_battle: enqueue_cutscene_elements(): Queued up all actions. Starting cutscene.");
	end
end

