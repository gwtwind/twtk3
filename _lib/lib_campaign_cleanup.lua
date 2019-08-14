

-------------------------------------------------------
-------------------------------------------------------
--	CAMPAIGN CLEANUP HANDLER
-------------------------------------------------------
-------------------------------------------------------


__campaign_cleanup_actions = {};


function add_campaign_cleanup_action(callback)
	if not is_function(callback) then
		script_error("add_campaign_cleanup_action called but supplied callback [" .. tostring(callback) .. "] is not a function");
		return false;
	end;
	
	table.insert(__campaign_cleanup_actions, callback);
end;




-- this function gets called when the campaign gets destroyed
function CleanupFinal()
	local count = 0;
	
	for i = 1, #__campaign_cleanup_actions do
		local current_action = __campaign_cleanup_actions[i];
		
		if is_function(current_action) then
			count = count + 1;
			current_action();
		end;
	end;
	
	if count == 1 then
		count = "1 callback";
	else
		count = tostring(count) .. " callbacks";
	end;
	
	output("CleanupFinal() called " .. count);
end;




