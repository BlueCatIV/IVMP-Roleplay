localChat = { }

function chat_connectEvent(playerid)
    setPlayerKeyHook(playerid, 0x55, true) --U key
    setPlayerKeyHook(playerid, 0x59, true) --Y key
    localChat[playerid] = false
    drawText(playerid, 4, 0.09, 0.001, 0.2, 0.54, "Chat - ~b~Global", 5000, 0xFFFFFFFF)
    drawText(playerid, 5, 0.001, 0.925, 0.15, 0.54, "~w~IV:MP RPG", 5000, 0xFFFFFFFF)
	drawText(playerid, 6, 0.001, 0.96, 0.15, 0.54, "~w~Developed by ~r~Bruce ~w~and ~b~BlueCat", 5000, 0xFFFFFFFF)
    sendPlayerMsg(playerid, "Press U for local chat", 0xFFFFFFFF)
    sendPlayerMsg(playerid, "Press Y for global chat", 0xFFFFFFFF)
end
registerEvent("chat_connectEvent", "onPlayerCredential")

function ts_keyEvent(playerid, keyCode, isUp)
    if(keyCode == 0x55) then --U key
            localChat[playerid] = true -- player request local chat set to true
            wipeDrawClass(playerid, 4) -- remove chat display
            drawText(playerid, 4, 0.09, 0.001, 0.2, 0.54, "Chat - ~b~Local", 5000, 0xFFFFFFFF)
    end
    if(keyCode == 0x59) then --Y key
            localChat[playerid] = false -- player request global chat set to false
            wipeDrawClass(playerid, 4) -- remove chat display
            drawText(playerid, 4, 0.09, 0.001, 0.2, 0.54, "Chat - ~b~Global", 5000, 0xFFFFFFFF)
    end
end
registerEvent("ts_keyEvent", "onPlayerKeyPress")


function myChatFunction(playerid, text)
    if(localChat[playerid] == true) then
            sendPlayerMsg(playerid, "Local: " .. text, 0xFFFFFFFF)
            local players = getPlayers()
            for i, id in ipairs(players) do
                if(id ~= playerid and isInRange(playerid, id, 20.0)) then
                   sendPlayerMsg(id, getPlayerName(playerid) .. " Local: " .. text, 0xFFFFFFFF)
                end
            end
        return false
    end
    return true
end
registerEvent("myChatFunction", "onPlayerChat")

function isInRange(p1, p2, range) 
    local p1x, p1y, p1z = getPlayerPos(p1)
    local p2x, p2y, p2z = getPlayerPos(p2)

    local newx = (p1x - p2x);
    local newy = (p1y - p2y);
    local newz = (p1z - p2z);
    return math.sqrt(newx * newx + newy * newy + newz * newz) < range;
end