local spawnInfo = {
	{-32.9202, -469.893, 15.641, 10, 0xFF0000FF}
}

function playerSpawnCredentials(playerid)
	print("Player " .. getPlayerName(playerid) .. "(" .. playerid .. ") credentials arrived")
	local sId = math.random(1, #spawnInfo)
	setPlayerSkin(playerid, spawnInfo[sId][4])
	spawnPlayer(playerid, spawnInfo[sId][1], spawnInfo[sId][2], spawnInfo[sId][3])
	setPlayerColor(playerid, spawnInfo[sId][5])
	setPlayerCash(playerid, 0)
	givePlayerWeapon(playerid, 15, 600)	
	sendMsgToAll(getPlayerName(playerid) .. "(" .. playerid .. ") has joined the server", 0xFFFFFFFF)
end
registerEvent("playerSpawnCredentials", "onPlayerCredential")