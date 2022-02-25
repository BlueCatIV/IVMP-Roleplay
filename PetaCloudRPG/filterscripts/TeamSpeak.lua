function ts_connectEvent(playerid)
	tsConnect(playerid, "174.49.138.18:9987")
end
registerEvent("ts_connectEvent", "onPlayerCredential")

function ts_responseEvent(playerid, msgType, rs)
	if(msgType == 1 and rs == playerid) then
		--All elements of the connection are ok
		setPlayerKeyHook(playerid, 0x4C, true) --L key
		sendPlayerMsg(playerid, "Press L to talk", 0xFFFFFFFF)
	end
end
registerEvent("ts_responseEvent", "onPlayerTeamSpeakResponse")

function isInRange(p1, p2, range)
	local p1x, p1y, p1z = getPlayerPos(p1)
	local p2x, p2y, p2z = getPlayerPos(p2)
	
	local newx = (p1x - p2x);
	local newy = (p1y - p2y);
	local newz = (p1z - p2z);
	return math.sqrt(newx * newx + newy * newy + newz * newz) < range;
end

function ts_keyEvent(playerid, keyCode, isUp)
	if(keyCode == 0x4C) then
		if(isUp) then
			tsToggleVoice(playerid, false)
			tsAllowVoiceTo(playerid, -1, false) --Clears all
			sendPlayerMsg(playerid, "No longer talking", 0xFFFFFFFF)
		else
			local players = getPlayers()
			for i, id in ipairs(players) do
				if(id ~= playerid and isInRange(playerid, id, 30.0)) then
				
					sendPlayerMsg(playerid, "Talking to: " .. getPlayerName(id), 0xFFFFFFFF)
					tsAllowVoiceTo(playerid, id, true)
				end
			end
			tsToggleVoice(playerid, true)
		end
	end
end
registerEvent("ts_keyEvent", "onPlayerKeyPress")
