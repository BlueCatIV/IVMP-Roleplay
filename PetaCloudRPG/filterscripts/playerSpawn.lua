local spawnInfo = {
	{22.32389831543, -35.859519958496, 20.557668685913, 11, 0xFF0000FF}
}

PlayerListTable = {
["Bruce"] = {
LoggedIn = false,
chosenSkin = 10,
},
}

function addPlayerListTable(Name)
	if PlayerListTable[Name] then
		return end
	PlayerListTable[Name] = {
	LoggedIn = false,
	chosenSkin = 10,
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
	if(PlayerTable[getPlayerName(playerid)] == nil) then
		setPlayerSkin(playerid, 10)
	else
		setPlayerSkin(playerid, PlayerTable[getPlayerName(playerid)].chosenSkin)
	end
	spawnPlayer(playerid, spawnInfo[sId][1], spawnInfo[sId][2], spawnInfo[sId][3])
	setPlayerColor(playerid, spawnInfo[sId][5])
	setPlayerCash(playerid, 0)
	givePlayerWeapon(playerid, 15, 600)
	sendMsgToAll(getPlayerName(playerid) .. "(" .. playerid .. ") has joined the server", 0xFFFFFFFF)
	if(PlayerTable[getPlayerName(playerid)] == nil) then
		sendPlayerMsg(playerid, "Welcome! Please use /register [Password] to create a new account on the server.", 0xFF009BFF)
		sendPlayerMsg(playerid, "To change your skin, type /lskin or /rskin into the chat. You can only do this now, before you are registered.", 0xFF009BFF)
	else
		sendPlayerMsg(playerid, "Welcome! Please use /login [Password] to log into your existing account.", 0xFF009BFF)
	end
end

registerEvent("playerSpawnCredentials", "onPlayerCredential")
