---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
----- Name:			Battle Advice Timing Manager
----- Author: 		Leif Walter
----- Description: 	Three Kingdoms auxiliary system to manage counters in battle.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- Core table
timing_manager = {};
timing_manager.timers = {};

function timing_manager:startTimer(timer_id)
    battleAdviceLogger:log("[INFO] timing_manager:startTimer(timer_id): Starting timer for " .. timer_id);

    count = table_length(timing_manager.timers);
    timing_manager.timers[count+1] = { "key", "start_time" };
    timing_manager.timers[count+1].key = timer_id;
    local current_time = os.clock();
    timing_manager.timers[count+1].start_time = current_time;
end

function timing_manager:checkTime(timer_id)
    timing_manager.timer = timing_manager:getTimer(timer_id);
    if (timing_manager.timer == nil) then
        battleAdviceLogger:log("[WARNING] timing_manager:checkTime(timer_id): No timer found for id: " .. timer_id);
        return 0;
    end
    out.advice("Start time: " .. timing_manager.timer.start_time);
    out.advice("Current ti: " .. os.clock());
    time = os.clock()-timing_manager.timer.start_time;
    out.advice("Difference: " .. time);
    return os.clock()-timing_manager.timer.start_time;
end

function timing_manager:getTimer(timer_id) 
    battleAdviceLogger:log("checking for timer_id: " .. timer_id);
    for index in ipairs(timing_manager.timers) 
    do 
        if (timing_manager.timers[index].key == timer_id) then 
            return timing_manager.timers[index]; 
        end
    end
    battleAdviceLogger:log("[ERROR] timing_manager:getTimer(timer_id): Did not find key id: " .. timer_id);
    return nil;
end

function timing_manager:timerExistsForKey(timer_id) 
    for index in ipairs(timing_manager.timers) 
    do 
        if (timing_manager.timers[index].key == timer_id) then 
            return true;
        end
    end
    return false;
end 
