addCommand("/skin", 
	function(playerid, params)
		if(params == nil) then
			sendPlayerMsg(playerid, "Usage: /skin [skin id]", 0xFFFF0000)
			do return end
		end
		setPlayerSkin(playerid, params[1])
		setDoorStatus(playerid, 4119540397, -468.057, 152.635, 10.1434, true)
	end
, "i")