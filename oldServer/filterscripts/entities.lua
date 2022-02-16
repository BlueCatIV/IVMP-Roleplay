function onEntitySpawn(playerid, spawned, entityType, entityId)
	--[[
		0-player
		1-vehicle
		2-checkpoint
		3-object
		4-NPC
	--]]

	if(entityType == 0) then
		entityType = "Player"
		if spawned then
			--setPlayerDraw(playerid, entityId, true, true)
		end
	elseif(entityType == 1) then
		entityType = "Vehicle"
	elseif(entityType == 4) then
		entityType = "NPC"
	end
	
	if(spawned) then
		spawned = "spawned"
	else
		spawned = "despawned"
	end	
	
	sendPlayerMsg(playerid, string.format("%s (%d) %s", entityType, entityId, spawned), 0xFFFF0000)
end
registerEvent("onEntitySpawn", "onPlayerSpawnEntity")