


----------------------------------------------------------------------------
--
--	OBJECTIVES MANAGER
--
--- @loaded_in_battle
--- @loaded_in_campaign
--- @class objectives_manager Objectives Manager
--- @desc Provides an interface for setting and managing the scripted objectives that appear in the scripted objectives panel, underneath the advisor in campaign and battle. With no advisor present, the scripted objectives panel appears in the top-left of the screen (it is displaced down the screen should the advisor appear). Scripted objectives are mainly used by tutorial scripts, but are also used in quest battles to deliver gameplay objectives.
--- @desc Once a scripted objective is set, with @objectives_manager:set_objective, it is down to the script to mark it as complete with @objectives_manager:complete_objective or failed with @objectives_manager:fail_objective, and to subsequently remove it from the scripted objectives panel with @objectives_manager:remove_objective.
--- @desc The objectives manager also provides an interface for setting up an objectives chain, which allows only one objective from the chain to be shown at a time. This is useful for tutorial scripts which are providing close instruction to the player, allowing them to set up a cooking-recipe series of mini-steps (e.g. "Select your army" / "Open the Recruitment panel" / "Recruit a Unit") which are chained together and can be advanced/rewound.
--- @desc Note that the @battle_manager and @campaign_manager both create an objectives manager, and provide passthrough interfaces for its most common functionality, so it should be rare for a battle or campaign script to need to get a handle to an objectives manager, or call functions on it directly.
----------------------------------------------------------------------------


objectives_manager = {
	uic_objectives = nil,
	objectives_list = {},
	objective_chain_active = "",
	previous_objective_chains = {},
	objective_chain_cached_objective = false,
	objective_chain_cached_objective_chain_name = false,
	objective_chain_cached_opt_a = false,
	objective_chain_cached_opt_b = false,
	is_debug = false,
	set_panel_top_centre_on_creation = false,
	set_panel_bottom_centre_on_creation = false
};


----------------------------------------------------------------------------
---	@section Creation
----------------------------------------------------------------------------

__objectives_manager = nil;

--- @function new
--- @desc Creates an objective manager. It should never be necessary for client scripts to call this directly, for an objective manager is automatically set up whenever a @battle_manager or @campaign_manager is created.
function objectives_manager:new()
	if __objectives_manager then
		return __objectives_manager;
	end;

	local o = {};

	setmetatable(o, self);
	self.__index = self;
	self.__tostring = function() return TYPE_OBJECTIVES_MANAGER end;
	
	o.objectives_list = {};
	o.previous_objective_chains = {};
	
	__objectives_manager = o;

	return o;
end;


--- @end_class
--- @section Objectives Manager

--- @function get_objectives_manager
--- @desc Gets an objectives manager, or creates one if one doesn't already exist.
--- @return objectives_manager
function get_objectives_manager()
	return objectives_manager:new();
end;


--- @class objectives_manager Objectives Manager
--- @section Debug

--- @function set_debug
--- @desc Sets the objectives manager into debug mode for more verbose output
--- @p [opt=true] boolean debug mode
function objectives_manager:set_debug(value)
	if value == false then
		self.is_debug = false;
	else
		self.is_debug = true;
	end;
end;


----------------------------------------------------------------------------
--	output
----------------------------------------------------------------------------

--	prints output if the objectives manager is in debug mode
function objectives_manager:objective_output(str)
	if self.is_debug then
		if __game_mode == __lib_type_battle then
			get_bm():out(str);
		else
			output(str);
		end;
	end;
end;




----------------------------------------------------------------------------
--	Objectives Panel Creation
----------------------------------------------------------------------------

--	creates the objective panel ui component.  To be called only when needed - do not call on
--	campaign startup, as the advisor panel ui component needs to be created first. For internal use.
function objectives_manager:create_objectives_panel()
	if self.uic_objectives then
		return;
	end;
	
	-- note: in 3K, objectives no longer appear within the scripted objectives panel but are placed elsewhere on the HUD
	-- they are still added through an InterfaceFunction on the scripted_objectives_panel uicomponent, however
	self.uic_objectives = find_uicomponent(core:get_ui_root(), "scripted_objectives_panel");
end;





----------------------------------------------------------------------------
--- @section UI Component
----------------------------------------------------------------------------


--- @function get_uicomponent
--- @desc Gets a uicomponent handle to the scripted objectives panel
--- @return uicomponent
function objectives_manager:get_uicomponent()
	self:create_objectives_panel();
	
	return self.uic_objectives;
end;





----------------------------------------------------------------------------
-- UI Component Manipulation
-- These functions can be used to show the scripted objectives panel in the top centre/bottom centre of the screen
----------------------------------------------------------------------------

function objectives_manager:undock_panel()
	self:create_objectives_panel();
	self:get_uicomponent():SetDockingPoint(0, 0);
end;


function objectives_manager:move_panel(x, y)
	self:create_objectives_panel();
	self:get_uicomponent():MoveTo(x, y);
end;


function objectives_manager:move_panel_top_centre()
	local screen_x, screen_y = core:get_screen_resolution();
	
	local uic_objectives = self:get_uicomponent();
	
	if not uic_objectives then
		self.set_panel_top_centre_on_creation = true;
		return;
	end;
	
	local panel_x, panel_y = uic_objectives:Dimensions();
	
	self:undock_panel();
	
	local panel_pos_x = (screen_x - panel_x) / 2;
	local panel_pos_y = 20;	-- offset from top of screen
	
	self:objective_output("Moving objectives panel to [" .. panel_pos_x .. ", " .. panel_pos_y .. "], screen resolution is [" .. screen_x .. ", " .. screen_y .. "] and panel size is [" .. panel_x .. ", " .. panel_y .. "]");
	
	uic_objectives:MoveTo(panel_pos_x, panel_pos_y);
end;


function objectives_manager:move_panel_bottom_centre()
	local screen_x, screen_y = core:get_screen_resolution();
	
	local uic_objectives = self:get_uicomponent();
	
	if not uic_objectives then
		self.set_panel_bottom_centre_on_creation = true;
		return;
	end;
	
	if __game_mode == __lib_type_battle then
		local bm = get_bm();
		
		local panel_x, panel_y = uic_objectives:Dimensions();
		
		self:undock_panel();
		
		local panel_pos_x = (screen_x - panel_x) / 2;
		local panel_pos_y = screen_y - 70;
		
		self:objective_output("Moving objectives panel to [" .. panel_pos_x .. ", " .. panel_pos_y .. "], screen resolution is [" .. screen_x .. ", " .. screen_y .. "] and panel size is [" .. panel_x .. ", " .. panel_y .. "]");
		
		uic_objectives:MoveTo(panel_pos_x, panel_pos_y);
		
		-- attach to battle_orders component
		--[[
		local uic_battle_orders = find_uicomponent(core:get_ui_root(), "battle_orders");
		
		if not uic_battle_orders then
			script_error("ERROR: move_panel_bottom_centre() could not find battle_orders uicomponent");
			return false;
		end;
		
		uic_battle_orders:Adopt(uic_objectives:Address());
		
		local battle_orders_width, battle_orders_height = uic_battle_orders:Dimensions();
		local objectives_width, objectives_height = uic_objectives:Dimensions();
		
		uic_objectives:SetDockingPoint((battle_orders_width - objectives_width) / 2, battle_orders_height + objectives_height + 20);
		
		-- self:objective_output("Docking objectives panel with battle_orders");	


		local show_obj_panel_func = function()
			local uic_obj = bm:ui_component("scripted_objectives_panel");
			if uic_obj then
				uic_obj:SetVisible(true);
				output_uicomponent(uic_obj);
			else
				script_error("Couldn't find scripted_objectives_panel panel");
			end;
		end;
		
		show_obj_panel_func();
		bm:repeat_callback(function() show_obj_panel_func() end, 1000);
		]]
	end;
end;



function objectives_manager:update_position_on_first_use()
	if self.panel_position_updated_on_first_use then
		return false;
	end;

	self.panel_position_updated_on_first_use = true;
	
	if self.set_panel_top_centre_on_creation then
		self:move_panel_top_centre();
	elseif self.set_panel_bottom_centre_on_creation then
		self:move_panel_bottom_centre();
	end;
end;






----------------------------------------------------------------------------
--- @section Objectives
----------------------------------------------------------------------------


--- @function set_objective
--- @desc Sets up a scripted objective for the player, which appears in the scripted objectives panel. This objective can then be updated, removed, or marked as completed or failed by the script at a later time.
--- @desc A key to the scripted_objectives table must be supplied with set_objective, and optionally one or two numeric parameters to show some running count related to the objective. To update these parameter values later, <code>set_objective</code> may be re-called with the same objective key and updated values.
--- @p string objective key, Objective key, from the scripted_objectives table.
--- @p [opt=nil] number param a, First numeric objective parameter. If set, the objective will be presented to the player in the form [objective text]: [param a]. Useful for showing a running count of something related to the objective.
--- @p [opt=nil] number param b, Second numeric objective parameter. A value for the first must be set if this is used. If set, the objective will be presented to the player in the form [objective text]: [param a] / [param b]. Useful for showing a running count of something related to the objective.
function objectives_manager:set_objective(new_obj_name, obj_param_a, obj_param_b)
	if not is_string(new_obj_name) then
		script_error("ERROR: set_objective() called but supplied objective name [" .. tostring(new_obj_name) .. "] is not a string");
		return false;
	end;
	
	self:objective_output("[OBJECTIVES] set_objective() called, key is [" .. new_obj_name .. "], optional params are [" .. tostring(obj_param_a) .. ", " .. tostring(obj_param_b) .. "]");
	
	self:update_objectives_position();		-- (should this be here?)
	self:create_objectives_panel();
	
	local uic_objectives = self:get_uicomponent();
	
	if obj_param_b then
		self:objective_output("[OBJECTIVES] performing set_objective action, key is [" .. new_obj_name .. "], params are [" .. tostring(obj_param_a) .. ", " .. tostring(obj_param_b) .. "]");
		-- uic_objectives:InterfaceFunction("set_objective", new_obj_name, obj_param_a, obj_param_b);
		interface_function(uic_objectives, "set_objective", new_obj_name, obj_param_a, obj_param_b);
	elseif obj_param_a then
		self:objective_output("[OBJECTIVES] performing set_objective action, key is [" .. new_obj_name .. "], param is [" .. tostring(obj_param_a) .. "]");
		-- uic_objectives:InterfaceFunction("set_objective", new_obj_name, obj_param_a);
		interface_function(uic_objectives, "set_objective", new_obj_name, obj_param_a);
	else
		self:objective_output("[OBJECTIVES] performing set_objective action, key is [" .. new_obj_name .. "]");
		-- uic_objectives:InterfaceFunction("set_objective", new_obj_name);
		interface_function(uic_objectives, "set_objective", new_obj_name);
	end;
	
	-- if we have objective parameters then dont try and complete, but add this objective to the list if it's not already there
	if obj_param_a then
		for i = 1, #self.objectives_list do
			local current_obj = self.objectives_list[i];
			
			if current_obj.name == new_obj_name then
				return;
			end;
		end;
	else
		-- otherwise look for the objective in our list
		for i = 1, #self.objectives_list do
			local current_obj = self.objectives_list[i];
			
			if current_obj.name == new_obj_name then
				if current_obj.completed then
					self:objective_output("[OBJECTIVES] performing complete_objective action, key is [" .. new_obj_name .. "] - objective was already complete when it was set");
					-- uic_objectives:InterfaceFunction("complete_objective", new_obj_name);
					interface_function(uic_objectives, "complete_objective", new_obj_name);
				end;
				return;
			end;
		end;
	end;
	
	self:update_position_on_first_use();
	
	-- we didn't find the objective in our list, so add it
	local new_obj = {name = new_obj_name, completed = false};
	table.insert(self.objectives_list, new_obj);
end;


--- @function complete_objective
--- @desc Marks a scripted objective as completed for the player to see. Note that it will remain on the scripted objectives panel until removed with @objectives_manager:remove_objective.
--- @desc Note also that is possible to mark an objective as complete before it has been registered with @objectives_manager:set_objective - in this case, it is marked as complete as soon as @objectives_manager:set_objective is called.
--- @p string objective key, Objective key, from the scripted_objectives table.
function objectives_manager:complete_objective(obj_name)
	if not is_string(obj_name) then
		script_error("ERROR: complete_objective() called but supplied objective name [" .. tostring(obj_name) .. "] is not a string");
		return false;
	end;

	self:create_objectives_panel();
	
	self:objective_output("[OBJECTIVES] complete_objective() called, key is [" .. obj_name .. "]");
	
	self:update_objectives_position();

	for i = 1, #self.objectives_list do
		local current_obj = self.objectives_list[i];
		
		if current_obj.name == obj_name then
			self:objective_output("[OBJECTIVES] performing complete_objective action, key is [" .. obj_name .. "] - objective was already complete when it was set");
			-- self:get_uicomponent():InterfaceFunction("complete_objective", obj_name);
			interface_function(self:get_uicomponent(), "complete_objective", obj_name);
			return;
		end;
	end;
	
	-- objective not found in our list, so add it
	self:objective_output("[OBJECTIVES] objective to complete [" .. obj_name .. "] was not found in the objectives list, so adding it for later");
	local new_obj = {name = obj_name, completed = true};
	table.insert(self.objectives_list, new_obj);
end;


--- @function fail_objective
--- @desc Marks a scripted objective as failed for the player to see. Note that it will remain on the scripted objectives panel until removed with @objectives_manager:remove_objective.
--- @p string objective key, Objective key, from the scripted_objectives table.
function objectives_manager:fail_objective(obj_name)
	if not is_string(obj_name) then
		script_error("ERROR: fail_objective() called but supplied objective name [" .. tostring(obj_name) .. "] is not a string");
		return false;
	end;
	
	self:objective_output("[OBJECTIVES] fail_objective() called, key is [" .. obj_name .. "]");

	self:create_objectives_panel();

	-- self:get_uicomponent():InterfaceFunction("fail_objective", obj_name);
	interface_function(self:get_uicomponent(), "fail_objective", obj_name);
	
	self:update_objectives_position();
end;


--- @function remove_objective
--- @desc Removes a scripted objective from the scripted objectives panel.
--- @p string objective key, Objective key, from the scripted_objectives table.
function objectives_manager:remove_objective(obj_name)
	if not is_string(obj_name) then
		script_error("ERROR: remove_objective() called but supplied objective name [" .. tostring(obj_name) .. "] is not a string");
		return false;
	end;

	self:create_objectives_panel();
	
	self:objective_output("[OBJECTIVES] remove_objective() called, key is [" .. obj_name .. "]");
	
	local uic_objectives = self:get_uicomponent();
	
	-- remove from the objectives list, if it's there
	for i = 1, #self.objectives_list do
		local current_obj = self.objectives_list[i];
	
		if current_obj.name == obj_name then
			self:objective_output("[OBJECTIVES] performing remove_objective action, key is [" .. obj_name .. "]");
			-- uic_objectives:InterfaceFunction("remove_objective", obj_name);
			interface_function(uic_objectives, "remove_objective", obj_name);
			table.remove(self.objectives_list, i);
			return;
		end;
	end;
	
	self:update_objectives_position();
end;





----------------------------------------------------------------------------
--	Updating Objectives Panel Position
--	The objectives panel is currently a child of the advisor panel, which
--	frequently needs pinging to update the position of its children. For
--	internal use mainly.
----------------------------------------------------------------------------

function objectives_manager:update_objectives_position()
	self:create_objectives_panel();
	
	local infotext = get_infotext_manager();

	if self:get_uicomponent():CurrentAnimationId() == "" and (not infotext:get_uicomponent() or infotext:get_uicomponent():CurrentAnimationId() == "") then
		local uic_advice = find_uicomponent(core:get_ui_root(), "advice_interface");
		
		if not is_uicomponent(uic_advice) then
			script_error("ERROR: update_objectives_position() could not find a ui component called advice_interface - objectives panel position will not be updated");
			return false;
		end;
		-- uic_advice:InterfaceFunction("update_objective_panel_pos");
		interface_function(uic_advice, "update_objective_panel_pos");
	else
		if __game_mode == __lib_type_battle then
			get_bm():callback(function() self:update_objectives_position() end, 200);
		else
			get_cm():callback(function() self:update_objectives_position() end, 0.2);
		end;
	end;
end;




----------------------------------------------------------------------------
--	Remove All Objectives
--	Removes all currently-active objectives. Allows specification of a
--	single exception, so that one objective stays active (this is used by
--	the objective chain system).
----------------------------------------------------------------------------

function objectives_manager:remove_all_objectives(exception)
	if exception then
		self:objective_output("[OBJECTIVES] remove_all_objectives() called with exception [" .. tostring(exception) .. "] specified");
	else
		self:objective_output("[OBJECTIVES] end_objective_chain() called, no exception specified");
	end;
	
	self:create_objectives_panel();

	local new_objectives_list = {};
	
	for i = 1, #self.objectives_list do
		local current_obj = self.objectives_list[i];
		local name = current_obj.name;
		
		if name ~= exception then
			self:objective_output("[OBJECTIVES] performing remove_objective action, key is [" .. name .. "]");
			-- self:get_uicomponent():InterfaceFunction("remove_objective", name);
			interface_function(self:get_uicomponent(), "remove_objective", name);
			
		else
			table.insert(new_objectives_list, current_obj);
		end;
	end;
	
	self.objectives_list = new_objectives_list;
	
	self:update_objectives_position();
end;











----------------------------------------------------------------------------
--- @section Objective Chains
--- @desc Objectives chains allow calling scripts to set up a sequence of objectives that are conceptually linked in such a manner that they are sequentially delivered to the player. This is useful for tutorial scripts which may wish to deliver close support to the player while they are performing a task for the first time e.g. "Open this panel" then "click on that button" then "select that option" and so on. Client scripts can update the status of an objective chain by name, and the objectives manager automatically removes or updates the onscreen objective.
--- @desc An objective chain may be started with @objectives_manager:activate_objective_chain, updated with @objectives_manager:update_objective_chain and finally terminated with @objectives_manager:end_objective_chain. Only one objective chain may be active at once, so terminate an existing chain before starting a new one.
----------------------------------------------------------------------------


--- @function activate_objective_chain
--- @desc Starts a new objective chain. Each objective chain must be given a unique string name, by which the objectives chain is later updated or ended.
--- @p string chain name, Name for the objective chain. Must not be shared with other objective chain names.
--- @p string objective key, Objective key, from the scripted_objectives table.
--- @p [opt=nil] number number param a, First numeric objective parameter. See documentation for @objectives_manager:set_objective.
--- @p [opt=nil] number number param b, Second numeric objective parameter. See documentation for @objectives_manager:set_objective.
function objectives_manager:activate_objective_chain(name, objective, opt_a, opt_b)
	if not is_string(name) then
		script_error("ERROR: activate_objective_chain() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective) then
		script_error("ERROR: activate_objective_chain() called but supplied objective [" .. tostring(objective) .. "] is not a string");
		return false;
	end;

	-- if this objective chain is in the previous objective chain list then don't start it, as it's already finished
	if self.previous_objective_chains[name] then
		self:objective_output("[OBJECTIVE CHAIN] activate_objective_chain() called with name [" .. name .. "] and objective [" .. objective .. "] but it's already been completed, discarding");
		return;
	end;
	
	self:objective_output("[OBJECTIVE CHAIN] activate_objective_chain() called with name [" .. name .. "] and objective [" .. objective .. "], setting it to be the active chain and updating");
	
	self.objective_chain_active = name;
	self:update_objective_chain(name, objective, opt_a, opt_b);
end;


--- @function update_objective_chain
--- @desc Updates an objective chain, either with new parameters for the existing objective or a new objective (in which case the existing objective will be removed).
--- @p string chain name, Name for the objective chain.
--- @p string objective key, Objective key, from the scripted_objectives table.
--- @p [opt=nil] number number param a, First numeric objective parameter. See documentation for @objectives_manager:set_objective.
--- @p [opt=nil] number number param b, Second numeric objective parameter. See documentation for @objectives_manager:set_objective.
function objectives_manager:update_objective_chain(name, objective, opt_a, opt_b)
	if not is_string(name) then
		script_error("ERROR: update_objective_chain() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(objective) then
		script_error("ERROR: update_objective_chain() called but supplied objective [" .. tostring(objective) .. "] is not a string");
		return false;
	end;
	
	-- if this objective chain is not active stash the given objective chain for later
	if self.objective_chain_active ~= name then
		self:objective_output("[OBJECTIVE CHAIN] update_objective_chain() called with name [" .. name .. "] and objective [" .. objective .. "] but this is not the active chain, caching it instead");
		
		self.objective_chain_cached_objective = objective;
		self.objective_chain_cached_objective_chain_name = name;
		self.objective_chain_cached_opt_a = opt_a;
		self.objective_chain_cached_opt_b = opt_b;
		return;
	end;
		
	-- if we have a current objective, use that instead of the one supplied
	if self.objective_chain_cached_objective and self.objective_chain_cached_objective_chain_name == name then
		self:objective_output("[OBJECTIVE CHAIN] update_objective_chain() called with name [" .. name .. "] and objective [" .. objective .. "] but there is a cached objective [" .. self.objective_chain_cached_objective .. "], using that instead");
		objective = self.objective_chain_cached_objective;
		opt_a = self.objective_chain_cached_opt_a;
		opt_b = self.objective_chain_cached_opt_b;
	else
		self:objective_output("[OBJECTIVE CHAIN] update_objective_chain() called with name [" .. name .. "] and objective [" .. objective .. "]");
	end;
	
	self:remove_all_objectives(objective);		-- remove all objectives bar the current objectives
	
	self:set_objective(objective, opt_a, opt_b);
	
	self.objective_chain_cached_objective = false;
	self.objective_chain_cached_objective_chain_name = false;
	self.objective_chain_cached_opt_a = false;
	self.objective_chain_cached_opt_b = false;
end;


--- @function end_objective_chain
--- @desc Ends an objective chain. 
--- @p string chain name, Name for the objective chain.
--- @p string objective key, Objective key, from the scripted_objectives table.
--- @p [opt=nil] number number param a, First numeric objective parameter. See documentation for @objectives_manager:set_objective.
--- @p [opt=nil] number number param b, Second numeric objective parameter. See documentation for @objectives_manager:set_objective.
function objectives_manager:end_objective_chain(name)
	if not is_string(name) then
		script_error("ERROR: end_objective_chain() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	-- only proceed if the supplied objective chain is active
	if self.objective_chain_active == name then
		self:objective_output("[OBJECTIVE CHAIN] end_objective_chain() called with name [" .. name .. "]");
		self:remove_all_objectives();
		self.objective_chain_active = "";
	else
		self:objective_output("[OBJECTIVE CHAIN] end_objective_chain() called with name [" .. name .. "] - this objective chain is not active - marking it as previous so that it cannot start without being reset");
	end;
	
	self.previous_objective_chains[name] = true;
end;


--- @function reset_objective_chain
--- @desc Removes this objective chain from the previous objective chains list, which allows it to be triggered again.
--- @p string chain name
function objectives_manager:reset_objective_chain(name)
	if not is_string(name) then
		script_error("ERROR: reset_objective_chain() called but supplied name [" .. tostring(name) .. "] is not a string");
		return false;
	end;
	
	-- remove this objective chain from the previous objective list
	self.previous_objective_chains[name] = nil;
end;










