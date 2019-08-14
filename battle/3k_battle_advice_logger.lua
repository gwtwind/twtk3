---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Battle Advice Logger
----- Author: 		Leif Walter
----- Description: 	Logging helper functions for battle advisor
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- Core table
battleAdviceLogger = {};

function battleAdviceLogger:initialise(debug_status) 
    battleAdviceLogger.debug = debug_status;
end

function battleAdviceLogger:log(text)
    if (battleAdviceLogger.debug == true) then
        if not is_string(text) then 
            script_error("Script error in 3k_battle_advice_logger.lua battleAdviceLogger:log(text): text is not a string");
        end
        if text == nil then
            script_error("Script error in 3k_battle_advice_logger.lua battleAdviceLogger:log(text): text is nil");
        end
        if is_string(text) then
            out.advice("battleAdviceLogger: " .. text);
        end
    end 
end
