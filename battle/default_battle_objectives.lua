-- Battle type objectives.
local player_attacker = bm:player_is_attacker();
local battle_type = effect.get_context_string_value("CcoBattleRoot", "BattleTypeState");

bm:out( "battle_type: " .. battle_type );

-- Strings
local obj_ambush_reach_extraction = "3k_main_battle_objective_ambush_reach_extraction_point";
local obj_ambush_survive = "3k_main_battle_objective_ambush_survive_until_timeout";
local obj_kill_or_rout = "3k_main_battle_objective_normal_kill_or_rout_enemy";
local obj_timeout = "3k_main_battle_objective_normal_survive_until_timeout";
local obj_capture_vp = "3k_main_battle_objective_siege_victory_point_capture";
local obj_defend_vp = "3k_main_battle_objective_siege_victory_point_defend";

local obj_display_time = 30000; -- In milliseconds.

if battle_type == "settlement_standard" then

	bm:out("Loading siege battle");

	if player_attacker then

		bm:set_objective(obj_kill_or_rout); -- Defeat all enemy units.
		bm:set_objective(obj_capture_vp); -- Capture the victory point.

		if obj_display_time > 0 then
			bm:callback(
				function()
					bm:remove_objective(obj_kill_or_rout);
					bm:remove_objective(obj_capture_vp);
				end,
				obj_display_time
			);
		else
			bm:register_victory_countdown_callback( function()
				bm:complete_objective(obj_kill_or_rout);
				bm:remove_objective(obj_capture_vp);
			end);
		end;
	else

		bm:set_objective(obj_kill_or_rout); -- Defeat all enemy units.
		bm:set_objective(obj_defend_vp); -- Defend your victory point!	

		if obj_display_time > 0 then
			bm:callback(
				function()
					bm:remove_objective(obj_kill_or_rout);
					bm:remove_objective(obj_defend_vp);
				end,
				obj_display_time
			);
		else
			bm:register_victory_countdown_callback( function()
				bm:complete_objective(obj_kill_or_rout);
				bm:complete_objective(obj_defend_vp);
			end);
		end;

	end;

elseif battle_type == "land_ambush" then

	bm:out("Loading ambush battle");

	if player_attacker then

		bm:set_objective(obj_kill_or_rout); -- Defeat all enemy units.

		if obj_display_time > 0 then
			bm:callback(
				function()
					bm:remove_objective(obj_kill_or_rout);
				end,
				obj_display_time
			);
		else
			bm:register_victory_countdown_callback( function()
				bm:complete_objective(obj_kill_or_rout);
			end);
		end;
	else

		bm:set_objective(obj_ambush_survive); -- [[img:ping_default]][[/img]]Survive the ambush!
		bm:set_objective(obj_ambush_reach_extraction); -- [[img:ping_move]][[/img]]In the face of certain defeat, try to run away through the extraction point.

		if obj_display_time > 0 then
			bm:callback(
				function()
					bm:remove_objective(obj_ambush_survive);
					bm:remove_objective(obj_ambush_reach_extraction);
				end,
				obj_display_time
			);
		else
			bm:register_victory_countdown_callback( function()
				bm:complete_objective(obj_ambush_survive);
				bm:remove_objective(obj_ambush_reach_extraction);
			end);
		end;

	end;
--elseif battle_type == "settlement_unfortified" then
else

	bm:out("Loading regular battle");

	if player_attacker then

		bm:set_objective(obj_kill_or_rout); -- Defeat all enemy units.

		if obj_display_time > 0 then
			bm:callback(
				function()
					bm:remove_objective(obj_kill_or_rout);
				end,
				obj_display_time
			);
		else
			bm:register_victory_countdown_callback( function()
				bm:complete_objective(obj_kill_or_rout);
			end);
		end;

	else

		bm:set_objective(obj_kill_or_rout); -- Defeat all enemy units.
		bm:set_objective(obj_timeout);

		if obj_display_time > 0 then
			bm:callback(
				function()
					bm:remove_objective(obj_kill_or_rout);
					bm:remove_objective(obj_timeout);
				end,
				obj_display_time
			);
		else
			bm:register_victory_countdown_callback( function()
				bm:complete_objective(obj_kill_or_rout);
				bm:complete_objective(obj_timeout);
			end);
		end;

	end;
end;

bm:register_results_callbacks(
	function() bm:out("Player Won!") end,
	function() bm:out("Player Lost!") end
);