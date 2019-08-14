---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			YT Ancillaries
----- Author: 		Laura Kampis + Simon Mann
----- Description: 	Yellow Turban trait system script
----- Comments: 	N/A
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

output("3k_ytr_campaign_ancillaries.lua: Loaded");


yt_ancillaries = {
	armour_rank_1 = 4,
	armour_rank_2 = 7,
	armour_rank_3 = 10
}

function yt_ancillaries:initialise()
    output("yt_ancillaries.lua:initialise()")
	
	-- Ancillaries.
	core:add_listener(
		"yt_ancillaries_rank_gained",
		"CharacterRank",
		function (context) 
			return self:query_character_can_have_armours( context:query_character() );
		end, --Conditions for firing
		function(context) 
			self:LevelUpYellowTurbanArmour(context) 
		end,
		true
	);
end


-- Level Up Yellow Turban Armours when the character 'ranks' up. Also brings the armour level up to where it should be if the character starts at a higher level.
function yt_ancillaries:LevelUpYellowTurbanArmour ( context )
	local query_character = context:query_character();
	local modify_character = context:modify_character();
	local rank = query_character:rank();

	if not modify_character or modify_character:is_null_interface() then
		script_error( "yt_ancillaries:LevelUpYellowTurbanArmour(): Modify character is null interface.");
		return;
	end;

	local query_ceo_management = query_character:ceo_management();

	-- HEALERS
	if query_character:character_subtype("3k_general_water") then
		-- Rank 3
		if rank >= self.armour_rank_1 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_healer_yellow_turban_common") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_healer_yellow_turban_common", "3k_ytr_ancillary_armour_healer_yellow_turban_refined");

		-- Rank 6
		elseif rank >= self.armour_rank_2 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_healer_yellow_turban_refined") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_healer_yellow_turban_refined", "3k_ytr_ancillary_armour_healer_yellow_turban_exceptional");

		-- Rank 9
		elseif rank >= self.armour_rank_3 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_healer_yellow_turban_exceptional") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_healer_yellow_turban_exceptional", "3k_ytr_ancillary_armour_healer_yellow_turban_unique");
		end;

	-- SCHOLARS
	elseif query_character:character_subtype("3k_general_metal") then
		-- Rank 3
		if rank >= self.armour_rank_1 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_scholar_medium_yellow_turban_common") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_scholar_medium_yellow_turban_common", "3k_ytr_ancillary_armour_scholar_medium_yellow_turban_refined");

		-- Rank 6
		elseif rank >= self.armour_rank_2 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_scholar_medium_yellow_turban_refined") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_scholar_medium_yellow_turban_refined", "3k_ytr_ancillary_armour_scholar_medium_yellow_turban_exceptional");

		-- Rank 9
		elseif rank >= self.armour_rank_3 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_scholar_medium_yellow_turban_exceptional") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_scholar_medium_yellow_turban_exceptional", "3k_ytr_ancillary_armour_scholar_medium_yellow_turban_unique");
		end;

	-- VETERANS
	elseif query_character:character_subtype("3k_general_wood") then
		-- Rank 3
		if rank >= self.armour_rank_1 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_veteran_medium_yellow_turban_common") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_veteran_medium_yellow_turban_common", "3k_ytr_ancillary_armour_veteran_medium_yellow_turban_refined");

		-- Rank 6
		elseif rank >= self.armour_rank_2 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_veteran_medium_yellow_turban_refined") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_veteran_medium_yellow_turban_refined", "3k_ytr_ancillary_armour_veteran_medium_yellow_turban_exceptional");

		-- Rank 9
		elseif rank >= self.armour_rank_3 and query_ceo_management:has_ceo_equipped("3k_ytr_ancillary_armour_veteran_medium_yellow_turban_exceptional") then
			self:level_up_armour(modify_character, "3k_ytr_ancillary_armour_veteran_medium_yellow_turban_exceptional", "3k_ytr_ancillary_armour_veteran_medium_yellow_turban_unique");
		end;
	end;

	output("yt_ancillaries: Yellow turban armour level up");
end;


function yt_ancillaries:level_up_armour( modify_character, ceo_to_remove, ceo_to_add )
	modify_character:ceo_management():add_ceo(ceo_to_add);
	modify_character:ceo_management():remove_ceos(ceo_to_remove);
	output("yt_ancillaries: Armour Level Up: Went from " .. ceo_to_remove .. " to " .. ceo_to_add);
end;


-- Generic tests for whether the character can even have armours. Can be a query
function yt_ancillaries:query_character_can_have_armours( query_character )

	-- Exit if character is null.
	if not query_character or query_character:is_null_interface() then
		return false;
	end;

	-- Exit if not general.
	if not char_is_general( query_character ) then
		return false;
	end;
		
	-- Exit if no CEO management.
	if not query_character:ceo_management() or query_character:ceo_management():is_null_interface() then
		return false;
	end;

	-- Only YT characters allowed.
	if query_character:faction():subculture() ~= "3k_main_subculture_yellow_turban" then
		return false;
	end;

	return true;
end;