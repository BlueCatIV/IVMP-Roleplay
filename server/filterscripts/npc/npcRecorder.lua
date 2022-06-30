local recordings = {}

local function stopRecording(playerid)
	local o = recordings[playerid]
	print(string.format("Stopping record for player %d, timer: %d", playerid, o.timerId))
	deleteTimer(o.timerId)
	o.file:close()
	recordings[playerid] = nil
end

function npcRecorder(playerid)
	if(recordings[playerid] == nil) then
		--big problem
		do return end
	end
	
	if(isPlayerOnline(playerid) == false) then
		stopRecording(playerid)
		do return end
	end
	
	local vid = getPlayerDriving(playerid)
	if(vid ~= recordings[playerid].typ) then
		stopRecording(playerid)		
	elseif(vid ~= 0) then
		local x, y, z = getVehiclePos(vid)
		local rx, ry, rz = getVehicleRotation(vid)
		local vx, vy, vz = getVehicleVelocity(vid)
		local vtx, vty, vtz = getVehicleTurnVelocity(vid)
		
		local ctime = os.clock()
		recordings[playerid].file:write(string.format("%.5f %.5f %.5f %.5f %.5f %.5f 0.0 %d %.2f %d %.2f %.5f %.5f %.5f %.5f %.5f %.5f\n",
			x, y, z, rx, ry, rz, math.ceil(ctime - recordings[playerid].lastPulse) * 100, getVehicleSteer(vid), getVehicleAnim(vid),
			getVehicleGasPedal(vid), vx, vy, vz, vtx, vty, vtz))
			
		recordings[playerid].lastPulse = ctime
	else
		local x, y, z = getPlayerPos(playerid)
		local anim = getPlayerAnim(playerid)
		
		local ctime = os.clock()
		local str = string.format("%.3f %.3f %.3f %.3f %d %d %d", x, y, z, getPlayerHeading(playerid), anim, 
			math.ceil(ctime - recordings[playerid].lastPulse) * 100, getPlayerWeapon(playerid))
			
		if(anim > 0 and anim < 5) then
			x, y, z = getPlayerAim(playerid)
			str = str .. " " .. x .. " " .. y .. " " .. z .. " " .. getPlayerAmmo(playerid)
			--drawInfoText(playerid, string.format("%.2f %.2f %.2f", x, y, z), 500)
		end
		recordings[playerid].file:write(str .. "\n")
		recordings[playerid].lastPulse = ctime
	end
	
end

function stopNpcRecord(playerid)
	if(recordings[playerid] ~= nil) then
		stopRecording(playerid)
		sendPlayerMsg(playerid, "Recording stopped", 0xFFFF0000)
	end
end

function npcRecorderUnload()
	removeCommand("/recordnpc")
	removeCommand("/srecord")
	
	for i, o in pairs(recordings) do
		stopRecording(i)
	end
end
registerScriptUnload("npc/npcRecorder", npcRecorderUnload) --Adds an unload point

addCommand("/recordnpc",
	function(playerid, text)
		if(text == nil) then
			sendPlayerMsg(playerid, "Usage: /recordnpc [output file name]", 0xFFFF0000)
			do return end
		end	
		
		recordings[playerid] = {
			file = io.open (text[1], "w+"),
			timerId = setTimer("npcRecorder", 100, 0, playerid),
			lastPulse = os.clock(),
			typ = getPlayerDriving(playerid)
		}
		sendPlayerMsg(playerid, text[1] .. " started", 0xFFFF0000)
	end
, "s")

addCommand("/srecord",
	function(playerid, text)
		if(recordings[playerid] ~= nil) then
			stopRecording(playerid)
			sendPlayerMsg(playerid, "Recording stopped", 0xFFFF0000)
		end
	end
, nil)

addCommand("/goxy",
	function(playerid, text)
		if(text == nil) then
			sendPlayerMsg(playerid, "Usage: /goxy x y z", 0xFFFF0000)
			do return end
		end
		setPlayerPos(playerid, text[1], text[2], text[3])
	end
, "fff")