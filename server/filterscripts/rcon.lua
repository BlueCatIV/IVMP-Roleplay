local rconPassword = "test"
local admins = {}

addCommand("/loadscript",
	function(playerid, text)
		if(admins[playerid] ~= nil) then
			--Already authed as admin here
			local scriptName = text[1]
			print("RCON: Loading FS: " .. scriptName)
			if(isScriptLoaded(scriptName)) then
				unloadScript(scriptName)
				sendPlayerMsg(playerid, scriptName .. " was unloaded", 0xFFFFFFFF)
			end
			if(loadScript(scriptName)) then
				sendPlayerMsg(playerid, scriptName .. " was loaded", 0xFFFFFFFF)
			end
		end
	end
, "s")

addCommand("/rconlogin",
	function(playerid, text)
		local pw = text[1]
		print(getPlayerName(playerid) .. " attempted to rconlogin with pw: " .. pw)
		if(pw == rconPassword) then
			admins[playerid] = true
			sendPlayerMsg(playerid, "Admin status activated", 0xFFFF0000)
		end
	end
, "s")

addCommand("/kick",
	function(playerid, text)
		local target = text[1]
		if(target == nil or isPlayerOnline(target) ~= true) then
			return sendPlayerMsg(playerid, "Invalid player ID", 0xFFFF0000)
		end
		sendPlayerMsg(playerid, "You kicked " .. getPlayerName(target) .. " out the server", 0xFFFF0000)
		disconnectPlayer(target)
	end
, "i")

function rconPlayerLeft(playerid, reason)
	if(admins[playerid] ~= nil) then
		--Player was authed as admin, now we remove his status
		admins[playerid] = nil
		print(getPlayerName(playerid) .. " rcon was freed")
	end
end
registerEvent("rconPlayerLeft", "onPlayerLeft")