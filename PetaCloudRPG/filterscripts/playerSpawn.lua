local spawnInfo = {
	{-32.9202, -469.893, 15.641, 10, 0xFF0000FF}
}

PlayerListTable = {
["Bruce"] = {
LoggedIn = false,
},
}

function addPlayerListTable(Name)
	if PlayerListTable[Name] then
		return end
	PlayerListTable[Name] = {
	LoggedIn = false,
	}
return end

function playerSpawnCredentials(playerid)
	addPlayerListTable(getPlayerName(playerid))
	LoginWorldId = 1 + playerid
	createWorld(LoginWorldId, 8, 0, 0, 0)
	setPlayerWorld(playerid, LoginWorldId)
	setPlayerFrozen(playerid, true)
	print("Player " .. getPlayerName(playerid) .. "(" .. playerid .. ") credentials arrived")
	local sId = math.random(1, #spawnInfo)
	setPlayerSkin(playerid, spawnInfo[sId][4])
	spawnPlayer(playerid, spawnInfo[sId][1], spawnInfo[sId][2], spawnInfo[sId][3])
	setPlayerColor(playerid, spawnInfo[sId][5])
	setPlayerCash(playerid, 0)
	givePlayerWeapon(playerid, 15, 600)	
	sendMsgToAll(getPlayerName(playerid) .. "(" .. playerid .. ") has joined the server", 0xFFFFFFFF)
	sendPlayerMsg(playerid, "Welcome! Please use /login [Password] or /register [Password] to access the server.", 0xFF009BFF)
end

registerEvent("playerSpawnCredentials", "onPlayerCredential")