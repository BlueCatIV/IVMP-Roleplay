local commandList = {}

function addCommand(cmdName, cmdFunction, cmdParams)
	local scn = nil
	if(type(cmdParams) == 'string' and cmdParams:len() > 0) then
		scn = {sql = cmdParams, sqsize = cmdParams:len()}
	end
	
	commandList[cmdName] = {
		fn = cmdFunction,
		scfn = scn
	}
end 

function removeCommand(cmdName)
	if(commandList[cmdName] ~= nil) then
		commandList[cmdName] = nil
	end
end

function onCommandsHandlerCommand(playerid, text)
    local result = {}
    for match in (text.." "):gmatch("(.-)".." ") do
        table.insert(result, match)
    end
	
	local buf = commandList[result[1]:lower()]
	if(buf == nil) then
		sendPlayerMsg(playerid, "Command '" .. result[1] .. "' is unknown", 0xFFFF0000)
	else
		table.remove(result, 1)
		text = #result;
		
		if(buf.scfn == nil) then
			buf.fn(playerid, result)
		elseif(text == 0 or text ~= buf.scfn.sqsize) then
			buf.fn(playerid, nil)
		else
			local out = {}
			for i, k in ipairs(result) do
				text = buf.scfn.sql:sub(i, i)
				if(text == 'i') then
					text = tonumber(k)
					if(text ~= nil) then 
						table.insert(out, math.floor(text))
					else break end
				elseif(text == 'f') then
					text = tonumber(k)
					if(text ~= nil) then 
						table.insert(out, text)
					else break end
				else
					table.insert(out, k)
				end
			end

			if(#out == buf.scfn.sqsize) then
				buf.fn(playerid, out)
			else
				buf.fn(playerid, nil)
			end
		end
	end
end
registerEvent("onCommandsHandlerCommand", "onPlayerCommand")