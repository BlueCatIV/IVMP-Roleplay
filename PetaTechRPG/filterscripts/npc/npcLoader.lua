local lNpcs = {}

function npcLoaderUnload()
	removeCommand("/vnpc")
	removeCommand("/fnpc")
	
	for i, o in pairs(lNpcs) do
		if(o ~= -1) then 
			deleteVehicle(o)
		end
		npcDelete(i)
	end
end
registerScriptUnload("npc/npcLoader", npcLoaderUnload) --Adds an unload point

addCommand("/vnpc",
	function(playerid, text)
		if(text == nil) then
			sendPlayerMsg(playerid, "Usage: /vnpc [vehicle model] [file name]", 0xFFFF0000)
			do return end
		end
		
		text[1] = text[1]:upper()
		local modelId = getVehicleModelId(text[1])
		if(modelId == -1) then
			sendPlayerMsg(playerid, "'" .. text[1] .. "' is an invalid vehicle name", 0xFFFF0000)
			do return end
		end
		
		local x, y, z = getPlayerPos(playerid)
		local rColor = math.random(0, 170)

		local carId = createVehicle(modelId, x, y, z, 0.0, 0.0, 0.0, rColor, rColor, rColor, rColor, getPlayerWorld(playerid))
		local npc = npcCreate(text[2], 1, x, y, z, carId, text[2], getPlayerWorld(playerid))
		
		lNpcs[npc] = carId
	
		sendPlayerMsg(playerid, text[2] .. " started", 0xFFFF0000)
	end
, "ss")

addCommand("/fnpc",
	function(playerid, text)
		if(text == nil) then
			sendPlayerMsg(playerid, "Usage: /fnpc [file name]", 0xFFFF0000)
			do return end
		end
		
		local x, y, z = getPlayerPos(playerid)
		local npc = npcCreate(text[1], 1, x, y, z, -1, text[1], getPlayerWorld(playerid))
		
		lNpcs[npc] = -1
		sendPlayerMsg(playerid, text[1] .. " started", 0xFFFF0000)
	end
, "s")