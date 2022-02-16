local weaponsDialogId = 100

local weapons = {
	{1, "Bat"},
	{2, "Pool Cue"},
	{3, "Knife"},
	{4, "Granade"},
	{7, "Pistol"},
	{9, "D Eagle"},
	{10, "Shotgun"},
	{11, "Beretta"},
	{12, "UZI"},
	{13, "SMG"},
	{14, "AK-47"},
	{15, "M4"},
	{16, "Sniper"},
	{17, "M40"},
	{18, "RPG"},
	{29, "Revolver"},
	{31, "Auto shotgun"},
	{32, "Assault SMG"},
	{34, "MG"},
	{35, "Advanced Sniper"},
	{41, "Parachute"}
}
	
local function createDialog()
	local diagLoaded = createDialogList(weaponsDialogId, "Weapons List", 1, "Get!", "Cancel")
	if(diagLoaded ~= true) then
		print("The weapons dialog wasnt created")
		return
	end
	
	for id, weapData in pairs(weapons) do
		addDialogRow(weaponsDialogId, weapData[2])
	end
end
createDialog()

addCommand("/weapons", 
	function(playerid)
		showDialogList(playerid, weaponsDialogId)
	end
, nil)

function onWeaponsDialogResponse(playerid, dialogId, buttonId, dialogRow)
	if(dialogId == weaponsDialogId and buttonId == 1 and weapons[dialogRow + 1] ~= nil) then
		givePlayerWeapon(playerid, weapons[dialogRow + 1][1], 600)
	end
end
registerEvent("onWeaponsDialogResponse", "onPlayerDialogResponse")

function weaponsUnload()
	print("Unloading weapons")
	deleteDialogList(weaponsDialogId)
	removeCommand("/weapons")
	unregisterEvent("onWeaponsDialogResponse")
end
registerScriptUnload("weapons", weaponsUnload) --Adds an unload point