
-------------------------------------------------------------------------------------------------
----------------------------------- LOAD BEHAVIOUR SCRIPT ---------------------------------------
-------------------------------------------------------------------------------------------------

load_script_libraries();
bm = battle_manager:new(empire_battle:new());

local file_name, file_path = get_file_name_and_path();

package.path = file_path .. "_romance/?.lua;" .. package.path;

require("battle_script_behaviour")