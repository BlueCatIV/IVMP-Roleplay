function chat_connectEvent(playerid)
	drawText(playerid, 5, 0.001, 0.925, 0.15, 0.54, "~r~P~w~e~b~t~r~a~b~C~r~l~w~o~b~u~r~d ~r~R~b~P~w~G", 5000, 0xFFFFFFFF)
	drawText(playerid, 6, 0.001, 0.96, 0.15, 0.54, "~w~Developed by ~r~Bruce ~w~and ~b~BlueCat", 5000, 0xFFFFFFFF)
end
registerEvent("chat_connectEvent", "onPlayerCredential")
