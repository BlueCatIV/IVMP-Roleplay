require("/filterscripts/utility/utilis")
require("/filterscripts/utility/scriptLoader")
require("/filterscripts/utility/commandsHandler")

--I load the following scripts like this so I can reload them whenever using the rcon script
loadScript("rcon")
loadScript("playerSpawn")
loadScript("carSpawning")
loadScript("weapons")
loadScript("skins")
loadScript("TeamSpeak")
loadScript("npc/npcRecorder")
loadScript("npc/npcLoader")
loadScript("entities")

setWorldMinuteDuration(1, 0)

-- Loading salt, a thing that allows me to save and load tables to save player data as seen below
salt = assert(require("salt"))

-- Basic table for player stats (for reference for salt and as a base)
PlayerTable = {
["Bruce"] = {
Money = 25,
Garage = {},
ownHouse = "0",
JobId = "0",
Job = "0",
hasJob = false,
Password = "admin",
},
["TestPlayer"] = {
Money = 25,
Garage = {},
ownHouse = "0",
JobId = "0",
Job = "0",
hasJob = false,
Password = "123",
},
}

-- Table for all vehicles currently spawned
AllVehicles = {}

-- Function to add fuel system to car as soon as its spawned
function addToFuel(playerid, spawned, entityType, entityId)
	if(spawned == true and entityType == 1) then
		AllVehicles[entityId] = 100
	end
end

registerEvent("addToFuel", "onPlayerSpawnEntity")

-- Fuel system, does stuff I dont remember
function fuel(playerid)
	if(isPlayerOnline(playerid) == true) then
		if(AllVehicles[getPlayerDriving(playerid)] <= 0) then
			setVehicleEngineFlags(getPlayerDriving(playerid), 0)
			endFuel()
		else
			local vX, vY, vZ = getVehicleVelocity(getPlayerDriving(playerid))
			local mph = math.ceil(math.sqrt(vX * vX + vY * vY + vY * vY) * 1.609)
			if(mph > 0) then
				AllVehicles[getPlayerDriving(playerid)] = AllVehicles[getPlayerDriving(playerid)] - 1
			end
		end
	else
		endFuel()
	end
end

-- Function to see if something is already in a table / check for duplicates I guess
function containsTable(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

-- Function to save a table with salt, used for player stats
function saveTable()
	salt.save(PlayerTable, "tableSave.txt")
end

-- Function to load a table with salt, used for player stats
function loadTable()
	PlayerTable, err = salt.load("tableSave.txt")
	if err then
		print("Noch nix da")
	elseif (PlayerTable ~= nil) then
		print("Wurde geladen")
	end
end

-- Function to split strings, used to retrieve login data etc. from chat input
function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

-- Function to check whether something contains something, used to check for commands in chat
function contains(str, prefix)
	i, j = string.find(str, prefix)
	if(i ~= nil and j ~= nil) then
		if(j - i + 1 == string.len(prefix)) then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- Function to register a user, creates account and table entry
function register(text, playerid)
	stringhere = mysplit(text)
	user = getPlayerName(playerid)
	createPlayerEntry(user)
	PlayerTable[user].Password = stringhere[2]
	saveTable()
	sendPlayerMsg(playerid, "You successfully registered! Please do /login [Password] now.", 0xFFFF0000)
end

-- Variable for hunger (test only)
hunger = 100

-- Function to start fuel system as soon as player enters vehicle
function startFuel(playerid)
	fuelTimer = setTimer("fuel", 1000, 0, playerid)
end

registerEvent("startFuel", "onPlayerEnteredVehicle")

-- Function to end fuel system / stop using fuel
function endFuel()
	deleteTimer(fuelTimer)
end

registerEvent("endFuel", "onPlayerExitVehicle")

-- Function to set keybinds when player joins
function onPlayerJoin(playerid)
	setPlayerKeyHook(playerid, 0x50, true)
	setPlayerKeyHook(playerid, 0x51, true)
end

registerEvent("onPlayerJoin", "onPlayerCredential")

-- Function to check what key the player presses and what to do, e.g. open profile window, car window...
function onPlayerBindKey(playerid, Bind, IsBindUp)
	if(IsBindUp) then
		if(Bind == 0x50) then -- P key
			clearDialogRows(1)
			if(PlayerTable[getPlayerName(playerid)].ownHouse == "HEA1") then
				Apartment = "High End Apartment"
			elseif(PlayerTable[getPlayerName(playerid)].ownHouse == "LEA1") then
				Apartment = "Low End Apartment"
			else
				Apartment = "None"
			end
			addDialogRow(1, "Money:~$" .. PlayerTable[getPlayerName(playerid)].Money)
			-- cars
			addDialogRow(1, "Apartment:~" .. Apartment)
			x, y, z = getPlayerPos(playerid)
			x = round(x, 3)
			y = round(y, 3)
			z = round(z, 3)
			addDialogRow(1, "Location:~" .. x .. ", " .. y .. ", " .. z)
			showDialogList(playerid, 1)
		elseif(Bind == 0x51) then -- Q key
			if(isPlayerInAnyVehicle(playerid) == 0) then
				sendPlayerMsg(playerid, "You are currently not in a vehicle.", 0xFFFFFF00)
			else
				clearDialogRows(99)
				addDialogRow(99, "Start Engine")
				addDialogRow(99, "Stop Engine")
				addDialogRow(99, "Fuel:~" .. AllVehicles[getPlayerDriving(playerid)])
				showDialogList(playerid, 99)
			end
		end
	end
end

registerEvent("onPlayerBindKey", "onPlayerKeyPress")

-- Function to login a player, checks password, loads stats from table into the player
function login(text, playerid)
	test = mysplit(text)
	if(not PlayerTable[getPlayerName(playerid)]) then
		sendPlayerMsg(playerid, "You don't have an account yet. Please create one with /register [Password]", 0xFFFF0000)
	elseif(test[2] == PlayerTable[getPlayerName(playerid)].Password) then
		PlayerListTable[getPlayerName(playerid)].LoggedIn = true
		sendPlayerMsg(playerid, "You successfully logged in!", 0xFFFF0000)
		setPlayerWorld(playerid, 1)
		setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money)
		setPlayerFrozen(playerid, false)
		ProfileDialog(playerid)
		VehicleDialog(playerid)
		OwnVehiclesDialog()
	else
		sendPlayerMsg(playerid, "Incorrect password! Please try again.", 0xFFFF0000)
	end
end

-- Calling load and save functions of salt table
loadTable()
saveTable()

-- Function to create new player in player table to keep stats etc.
function createPlayerEntry(Name)
	if PlayerTable[Name] then
		return end
	PlayerTable[Name] = {
	Money = 0,
	Garage = {},
	ownHouse = "0",
	JobId = "0",
	Job = "0",
	hasJob = false,
	Password = "",
	}
	saveTable()
return end

-- Variable to see whether or not player is already logged in
loggedIn = false

-- Function that handles commands in chat and what to do
function Command(playerid, text)
	if(text == "/hi") then
		sendPlayerMsg(playerid, "Hello!", 0xFFFF0000)
		print(PlayerTable[getPlayerName(playerid)])
	elseif(PlayerListTable[getPlayerName(playerid)].LoggedIn == false) then
		if(contains(text, "/register") == true and PlayerTable[getPlayerName(playerid)]) then
			sendPlayerMsg(playerid, "You are already registered. Please use /login [Password]", 0xFFFF0000)
		elseif(contains(text, "/register") == true) then
			register(text, playerid)
		elseif(contains(text, "/login") == true) then
			login(text, playerid)
		end
	elseif(text == "/pos") then
		getPos()
	elseif(text == "/tp") then
		setPlayerPos(playerid, -1488.5852050781, 1130.9370117188, 22.012754440308)
	elseif(text == "/controls") then
		sendPlayerMsg(playerid, "P - Profile Menu\nQ - Vehicle Menu\n", 0xFFFFFF00)
	elseif(text == "/garage") then
		if(PlayerTable[getPlayerName(playerid)].Garage == nil) then
			showDialogList(playerid, 18)
		else
			clearDialogRows(18)
			for i, name in ipairs(PlayerTable[getPlayerName(playerid)].Garage) do
				addDialogRow(18, name)
			end
			showDialogList(playerid, 18)
		end
	elseif(text == "/quit") then
		if(PlayerTable[getPlayerName(playerid)].Job == "Bus") then
			deleteCheck()
			deleteBlips()
			sendPlayerMsg(playerid, "Job successfully cancelled.", 0xFFFFFF00)
			PlayerTable[getPlayerName(playerid)].JobId = "0"
			PlayerTable[getPlayerName(playerid)].hasJob = false
			PlayerTable[getPlayerName(playerid)].Job = "0"
			removePlayerFromVehicle(playerid)
			wait(5)
			deleteVehicle(Bus)
			saveTable()
		elseif(PlayerTable[getPlayerName(playerid)].Job == "FastFood") then
			sendPlayerMsg(playerid, "Job successfully cancelled.", 0xFFFFFF00)
			setPlayerFrozen(playerid, false)
			PlayerTable[getPlayerName(playerid)].hasJob = false
			PlayerTable[getPlayerName(playerid)].Job = "0"
			PlayerTable[getPlayerName(playerid)].JobId = "0"
			saveTable()
		end
	end
end

registerEvent("Command", "onPlayerCommand")

-- Function to get the position of a player
function getPos()
	local x, y, z = getPlayerPos(1)
	print(x)
	print(y)
	print(z)
	sendPlayerMsg(1, "Koordinaten werden angezeigt", 0xFFFF0000)
end

-- Wait/Sleep function for certain stuff
function wait(seconds)
	local start = os.time()
	repeat until os.time() > start + seconds
end

-- Function to hide a checkpoint, so that players that are not in a job do not see the checkpoints the job creates (dunno if it works)
function hideCheck(playerid, CheckpointId)
	players = getPlayers()
	table.remove(players, playerid)
	for i, id in ipairs(players) do
		setCheckPointShowingForPlayer(CheckpointId, id, false) -- 1 is Checkpoint Id
	end
end

-- Function to see whether player enters a checkpoint, which one and what to do then
function onPlayerEnterCheckPoint(playerid, checkpointId)
	if(checkpointId == busDepotCP) then
		showDialogList(playerid, 1337)
	elseif(checkpointId == CB1 or checkpointId == CB2) then
		showDialogList(playerid, 45)
	elseif(checkpointId == GasCP11 or checkpointId == GasCP12) then
		showDialogList(playerid, 77)
	elseif(checkpointId == car11CP) then
		car11Info(playerid)
	elseif(checkpointId == car12CP) then
		car12Info(playerid)
	elseif(checkpointId == car13CP) then
		car13Info(playerid)
	elseif(checkpointId == car21CP) then
		car21Info(playerid)
	elseif(checkpointId == car22CP) then
		car22Info(playerid)
	elseif(checkpointId == car23CP) then
		car23Info(playerid)
	elseif(checkpointId == buy1CP) then
		showDialogList(playerid, 15)
	elseif(checkpointId == buy2CP) then
		showDialogList(playerid, 25)
	elseif(checkpointId == LEA1CP) then
		if(PlayerTable[getPlayerName(playerid)].ownHouse ~= "LEA1") then
			showDialogList(playerid, 150)
		else
			showDialogList(playerid, 155)
		end
	elseif(checkpointId == LEA1ExitCP) then
		showDialogList(playerid, 151)
	elseif(checkpointId == HEA1CP) then
		if(PlayerTable[getPlayerName(playerid)].ownHouse ~= "HEA1") then
			showDialogList(playerid, 110)
		else
			showDialogList(playerid, 111)
		end
	elseif(checkpointId == HEA1ExitCP) then
		showDialogList(playerid, 112)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR11") then
		BR12(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR12") then
		BR13(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR13") then
		BR14(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR14") then
		BR1End(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR21") then
		BR22(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR22") then
		BR23(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR23") then
		BR24(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR24") then
		BR2End(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR31") then
		BR32(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR32") then
		BR33(playerid)
	elseif(PlayerTable[getPlayerName(playerid)].JobId == "BR33") then
		BR3End(playerid)
	end
end

registerEvent("onPlayerEnterCheckPoint", "onPlayerEnterCheckPoint")

-- Function to delete a checkpoint
function deleteCheck()
	deleteCheckPoint(CheckpointId)
end

-- Function to delete a blip
function deleteBlips()
	deleteBlip(BlipId)
end

-- Function to generate a random number
function mathRand(a, b)
	math.randomseed(os.time())
	c = math.random(a, b)
	return c
end

-- Function to round numbers
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Function to spawn the bus depot with its checkpoint and blip
function busDepot()
	busDepotCP = createCheckPoint(1009.325378418, 290.64385986328, 30.512239456177, 2.0, 0xFFFF00FF, 1, 0, 1)
	createBlip(1009.325378418, 290.64385986328, 30.512239456177, 30, 0xFFFFFFFF, 1, 0, true, "Bus Depot")
end

busDepot()

-- Function to create the dialog for the bus job
function busDialog()
	createDialogList(1337,  "Bus Routes", 2, "Choose", "Cancel")
	setDialogListHeaders(1337, "Route~Payment")
	addDialogRow(1337, "Broker / Dukes~$350 - $500", 1)
	addDialogRow(1337, "Algonquin~$500 - $750", 2)
	addDialogRow(1337, "Alderney~$750 - $1000", 3)
end

busDialog()

-- Function to create the dialog for the cluckin bell job
function CBDialog()
	createDialogList(45, "Fast Food Store", 1, "Yes", "No")
	setDialogListHeaders(45, "Cluckin' Bell")
	addDialogRow(45, "Do you want to start working here?")
end

CBDialog()

-- Function to create the menu for cluckin bell job when youre working
function FFMenuDialog()
	createDialogList(55, "Fast Food Menu", 1, "Make", "Cancel")
	setDialogListHeaders(55, "Item")
	addDialogRow(55, "Burger")
	addDialogRow(55, "French Fries")
	addDialogRow(55, "Chicken Nuggets")
	addDialogRow(55, "Special Burger")
	addDialogRow(55, "Soda")
end

FFMenuDialog()

-- Function to create the menu for buying a car at dealership 1
function CD1Dialog()
	createDialogList(15, "Auto Eroticar", 2, "Buy", "Cancel")
	setDialogListHeaders(15, "Car~Price")
	addDialogRow(15, "Admiral~$2500")
	addDialogRow(15, "Intruder~$3000")
	addDialogRow(15, "Premier~$3500")
end

CD1Dialog()

-- Function to create the menu for buying a car at dealership 2
function CD2Dialog()
	createDialogList(25, "Grotti Automobile", 2, "Buy", "Cancel")
	setDialogListHeaders(25, "Car~Price")
	addDialogRow(25, "Banshee~$7500")
	addDialogRow(25, "Cognoscenti~$12500")
	addDialogRow(25, "Infernus~$15000")
end

CD2Dialog()

-- Function to create the menu for buying the low end apartment 1
function LEA1Dialog()
	createDialogList(150, "Apartment", 1, "Yes", "No")
	setDialogListHeaders(150, "Low End Apartment")
	addDialogRow(150, "Do you want to buy this Apartment for $50000?")
end

LEA1Dialog()

-- Function to create the menu for entering the low end apartment 1
function LEA1EnterDialog()
	createDialogList(155, "Apartment", 1, "Yes", "No")
	setDialogListHeaders(155, "Low End Apartment")
	addDialogRow(155, "Do you want to enter your apartment?")
end

LEA1EnterDialog()

-- Function to create the menu for exiting the low end apartment 1
function LEA1ExitDialog()
	createDialogList(151, "Apartment", 1, "Yes", "No")
	setDialogListHeaders(151, "Low End Apartment")
	addDialogRow(151, "Do you want to leave your apartment?")
end

LEA1ExitDialog()

-- same stuff just for High End apartments and so on now
function HEA1Dialog()
	createDialogList(110, "Apartment", 1, "Yes", "No")
	setDialogListHeaders(110, "High End Apartment")
	addDialogRow(110, "Do you want to buy this Apartment for $100000?")
end

HEA1Dialog()

function HEA1EnterDialog()
	createDialogList(111, "Apartment", 1, "Yes", "No")
	setDialogListHeaders(111, "High End Apartment")
	addDialogRow(111, "Do you want to enter your apartment?")
end

HEA1EnterDialog()

function HEA1ExitDialog()
	createDialogList(112, "Apartment", 1, "Yes", "No")
	setDialogListHeaders(112, "High End Apartment")
	addDialogRow(112, "Do you want to leave your apartment?")
end

HEA1ExitDialog()

-- Function to create profile info menu
function ProfileDialog(playerid)
	createDialogList(1, "Profile", 2, "Ok", "Cancel")
	setDialogListHeaders(1, "Name: " .. getPlayerName(playerid))
	if(PlayerTable[getPlayerName(playerid)].ownHouse == "HEA1") then
		Apartment = "High End Apartment"
	elseif(PlayerTable[getPlayerName(playerid)].ownHouse == "LEA1") then
		Apartment = "Low End Apartment"
	else
		Apartment = "None"
	end
	addDialogRow(1, "Money:~$" .. PlayerTable[getPlayerName(playerid)].Money)
	-- cars
	addDialogRow(1, "Apartment:~" .. Apartment)
	x, y, z = getPlayerPos(playerid)
	x = round(x, 3)
	y = round(y, 3)
	z = round(z, 3)
	addDialogRow(1, "Location:~" .. x .. ", " .. y .. ", " .. z)
end

-- Function to create vehicle menu
function VehicleDialog(playerid)
	createDialogList(99, "Vehicle", 2, "Confirm", "Cancel")
	setDialogListHeaders(99, "Vehicle")
	addDialogRow(99, "Start Engine")
	addDialogRow(99, "Stop Engine")
end

-- Function to create "garage" menu, see what vehicles you own
function OwnVehiclesDialog()
	createDialogList(18, "Garage", 1, "Get", "Cancel")
	setDialogListHeaders(18, "Vehicles")
end

-- Function to create menu when you drive into a gas station
function GasStationDialog()
	createDialogList(77, "Gas Station", 1, "Yes", "No")
	setDialogListHeaders(77, "Fuel")
	addDialogRow(77, "Do you want to refuel your vehicle?")
end

GasStationDialog()

-- Function to handle interaction with every dialog created (bus job, fast food job, apartment...)
function busDialogResponse(playerid, dialogId, buttonId, rowId)
	if(dialogId == 1337 and buttonId == 1 and rowId == 0 and PlayerTable[getPlayerName(playerid)].hasJob == false) then
		sendPlayerMsg(playerid, "You are now driving the Route \"Broker / Dukes\".", 0xFFFFFF00)
		PlayerTable[getPlayerName(playerid)].hasJob = true
		PlayerTable[getPlayerName(playerid)].Job = "Bus"
		BR11(playerid)
		Bus = createVehicle(13, 1031.873046875, 264.12274169922, 30.961814880371, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
		warpPlayerIntoVehicle(playerid, Bus, 0)
	elseif(dialogId == 1337 and buttonId == 1 and rowId == 1 and PlayerTable[getPlayerName(playerid)].hasJob == false) then
		sendPlayerMsg(playerid, "You are now driving the Route \"Algonquin\".", 0xFFFFFF00)
		PlayerTable[getPlayerName(playerid)].hasJob = true
		BR21(playerid)
		Bus = createVehicle(13, 1031.873046875, 264.12274169922, 30.961814880371, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
		warpPlayerIntoVehicle(playerid, Bus, 0)
	elseif(dialogId == 1337 and buttonId == 1 and rowId == 2 and PlayerTable[getPlayerName(playerid)].hasJob == false) then
		sendPlayerMsg(playerid, "You are now driving the Route \"Alderney\".", 0xFFFFFF00)
		PlayerTable[getPlayerName(playerid)].hasJob = true
		BR31(playerid)
		Bus = createVehicle(13, 1031.873046875, 264.12274169922, 30.961814880371, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
		warpPlayerIntoVehicle(playerid, Bus, 0)
	elseif(dialogId == 45 and buttonId == 1 and PlayerTable[getPlayerName(playerid)].hasJob == false) then
		sendPlayerMsg(playerid, "You are now working at Cluckin' Bell.", 0xFFFFFF00)
		FF1(playerid)
	elseif(dialogId == 55 and buttonId == 1 and PlayerTable[getPlayerName(playerid)].JobId == "FF1") then
		if(rowId == 0) then
			sendPlayerMsg(playerid, "Customer: Thank you!", 0xFFFFFF00)
			FF2(playerid)
		else
			sendPlayerMsg(playerid, "Customer: That's not what I wanted.", 0xFFFFFF00)
			showDialogList(playerid, 55)
		end
	elseif(dialogId == 55 and buttonId == 1 and PlayerTable[getPlayerName(playerid)].JobId == "FF2") then
		if(rowId == 4) then
			sendPlayerMsg(playerid, "Customer: Thanks!", 0xFFFFFF00)
			FF3(playerid)
		else
			sendPlayerMsg(playerid, "Customer: I wanted something else.", 0xFFFFFF00)
			showDialogList(playerid, 55)
		end
	elseif(dialogId == 55 and buttonId == 1 and PlayerTable[getPlayerName(playerid)].JobId == "FF3") then
		if(rowId == 3) then
			sendPlayerMsg(playerid, "Customer: Nice!", 0xFFFFFF00)
			FF4(playerid)
		else
			sendPlayerMsg(playerid, "Customer: Oh, you got my order wrong!", 0xFFFFFF00)
			showDialogList(playerid, 55)
		end
	elseif(dialogId == 55 and buttonId == 1 and PlayerTable[getPlayerName(playerid)].JobId == "FF4") then
		if(rowId == 1) then
			sendPlayerMsg(playerid, "Customer: Finally, that took long.", 0xFFFFFF00)
			FF5(playerid)
		else
			sendPlayerMsg(playerid, "Customer: How can you fuck this up? Hurry up!", 0xFFFFFF00)
			showDialogList(playerid, 55)
		end
	elseif(dialogId == 55 and buttonId == 1 and PlayerTable[getPlayerName(playerid)].JobId == "FF5") then
		if(rowId == 2) then
			sendPlayerMsg(playerid, "Customer: Oh, thank you!", 0xFFFFFF00)
			FFEnd(playerid)
		else
			sendPlayerMsg(playerid, "Customer: Wait, I think I wanted something else?", 0xFFFFFF00)
			showDialogList(playerid, 55)
		end
	elseif(dialogId == 15 and buttonId == 1) then
		if(rowId == 0 and #PlayerTable[getPlayerName(playerid)].Garage <= 4) then
			if(containsTable(PlayerTable[getPlayerName(playerid)].Garage, "Admiral") == true) then
				sendPlayerMsg(playerid, "You already own this vehicle.", 0xFFFFFF00)
			else
				if(PlayerTable[getPlayerName(playerid)].Money >= 2500) then
					sendPlayerMsg(playerid, "You bought \"Admiral\"!", 0xFFFFFF00)
					createVehicle(1, -1480.1287841797, 1111.4613037109, 22.587392807007, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
					table.insert(PlayerTable[getPlayerName(playerid)].Garage, "Admiral")
					setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - 2500)
					PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - 2500
					saveTable()
				else
					sendPlayerMsg(playerid, "You don't have enough money for this purchase.", 0xFFFFFF00)
				end
			end
		elseif(rowId == 1 and #PlayerTable[getPlayerName(playerid)].Garage <= 4) then
			if(containsTable(PlayerTable[getPlayerName(playerid)].Garage, "Intruder") == true) then
				sendPlayerMsg(playerid, "You already own this vehicle.", 0xFFFFFF00)
			else
				if(PlayerTable[getPlayerName(playerid)].Money >= 3000) then
					sendPlayerMsg(playerid, "You bought \"Intruder\"!", 0xFFFFFF00)
					createVehicle(43, -1480.1287841797, 1111.4613037109, 22.587392807007, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
					table.insert(PlayerTable[getPlayerName(playerid)].Garage, "Intruder")
					setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - 3000)
					PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - 3000
					saveTable()
				else
					sendPlayerMsg(playerid, "You don't have enough money for this purchase.", 0xFFFFFF00)
				end
			end
		elseif(rowId == 2 and #PlayerTable[getPlayerName(playerid)].Garage <= 4) then
			if(containsTable(PlayerTable[getPlayerName(playerid)].Garage, "Premier") == true) then
				sendPlayerMsg(playerid, "You already own this vehicle.", 0xFFFFFF00)
			else
				if(PlayerTable[getPlayerName(playerid)].Money >= 3500) then
					sendPlayerMsg(playerid, "You bought \"Premier\"!", 0xFFFFFF00)
					createVehicle(68, -1480.1287841797, 1111.4613037109, 22.587392807007, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
					table.insert(PlayerTable[getPlayerName(playerid)].Garage, "Premier")
					setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - 3500)
					PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - 3500
					saveTable()
				else
					sendPlayerMsg(playerid, "You don't have enough money for this purchase.", 0xFFFFFF00)
				end
			end
		else
			sendPlayerMsg(playerid, "You can't own more than 5 vehicles.", 0xFFFFFF00)
		end
	elseif(dialogId == 25 and buttonId == 1) then
		if(rowId == 0 and #PlayerTable[getPlayerName(playerid)].Garage <= 4) then
			if(containsTable(PlayerTable[getPlayerName(playerid)].Garage, "Banshee") == true) then
				sendPlayerMsg(playerid, "You already own this vehicle.", 0xFFFFFF00)
			else
				if(PlayerTable[getPlayerName(playerid)].Money >= 7500) then
					sendPlayerMsg(playerid, "You bought \"Banshee\"!", 0xFFFFFF00)
					createVehicle(4, 46.406497955322, 814.59869384766, 14.049596786499, 0.0, 0.0, 140.0, 1, 1, 1, 1, 1)
					table.insert(PlayerTable[getPlayerName(playerid)].Garage, "Banshee")
					setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - 7500)
					PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - 7500
					saveTable()
				else
					sendPlayerMsg(playerid, "You don't have enough money for this purchase.", 0xFFFFFF00)
				end
			end
		elseif(rowId == 1 and #PlayerTable[getPlayerName(playerid)].Garage <= 4) then
			if(containsTable(PlayerTable[getPlayerName(playerid)].Garage, "Cognoscenti") == true) then
				sendPlayerMsg(playerid, "You already own this vehicle.", 0xFFFFFF00)
			else
				if(PlayerTable[getPlayerName(playerid)].Money >= 12500) then
					sendPlayerMsg(playerid, "You bought \"Cognoscenti\"!", 0xFFFFFF00)
					createVehicle(17, 46.406497955322, 814.59869384766, 14.049596786499, 0.0, 0.0, 140.0, 1, 1, 1, 1, 1)
					table.insert(PlayerTable[getPlayerName(playerid)].Garage, "Cognoscenti")
					setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - 12500)
					PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - 12500
					saveTable()
				else
					sendPlayerMsg(playerid, "You don't have enough money for this purchase.", 0xFFFFFF00)
				end
			end
		elseif(rowId == 2 and #PlayerTable[getPlayerName(playerid)].Garage <= 4) then
			if(containsTable(PlayerTable[getPlayerName(playerid)].Garage, "Infernus") == true) then
				sendPlayerMsg(playerid, "You already own this vehicle.", 0xFFFFFF00)
			else
				if(PlayerTable[getPlayerName(playerid)].Money >= 15000) then
					sendPlayerMsg(playerid, "You bought \"Infernus\"!", 0xFFFFFF00)
					createVehicle(41, 46.406497955322, 814.59869384766, 14.049596786499, 0.0, 0.0, 140.0, 1, 1, 1, 1, 1)
					table.insert(PlayerTable[getPlayerName(playerid)].Garage, "Infernus")
					setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - 15000)
					PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - 15000
					saveTable()
				else
					sendPlayerMsg(playerid, "You don't have enough money for this purchase.", 0xFFFFFF00)
				end
			end
		else
			sendPlayerMsg(playerid, "You can't own more than 5 vehicles.", 0xFFFFFF00)
		end
	elseif(dialogId == 150 and buttonId == 1) then
		if(PlayerTable[getPlayerName(playerid)].Money >= 50000) then
			sendPlayerMsg(playerid, "You bought this Apartment!", 0xFFFFFF00)
			setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - 50000)
			PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - 50000
			PlayerTable[getPlayerName(playerid)].ownHouse = "LEA1"
			saveTable()
		else
			sendPlayerMsg(playerid, "You don't have enough money for this purchase.", 0xFFFFFF00)
		end
	elseif(dialogId == 155 and buttonId == 1) then
		setPlayerWorld(playerid, LoginWorldId)
		setPlayerPos(playerid, 893.14520263672, -495.33276367188, 18.430086135864)
		LEA1ExitCP = createCheckPoint(892.57818603516, -500.7278137207, 18.407358169556, 2.0, 0xFFFF00FF, 1, 0, LoginWorldId)
	elseif(dialogId == 151 and buttonId == 1) then
		setPlayerWorld(playerid, 1)
		setPlayerPos(playerid, 897.78088378906, -504.98333740234, 14.064782142639)
		deleteCheckPoint(LEA1ExitCP)
	elseif(dialogId == 110 and buttonId == 1) then
		if(PlayerTable[getPlayerName(playerid)].Money >= 100000) then
			sendPlayerMsg(playerid, "You bought this Apartment!", 0xFFFFFF00)
			setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - 100000)
			PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - 100000
			PlayerTable[getPlayerName(playerid)].ownHouse = "HEA1"
			saveTable()
		else
			sendPlayerMsg(playerid, "You don't have enough money for this purchase.", 0xFFFFFF00)
		end
	elseif(dialogId == 111 and buttonId == 1) then
		setPlayerWorld(playerid, LoginWorldId)
		setPlayerPos(playerid, 98.80, 859.49, 45.05)
		HEA1ExitCP = createCheckPoint(96.294769287109, 851.91412353516, 44.050926208496, 2.0, 0xFFFF00FF, 1, 0, LoginWorldId)
	elseif(dialogId == 112 and buttonId == 1) then
		setPlayerWorld(playerid, 1)
		setPlayerPos(playerid, 113.20606994629, 844.96362304688, 13.716341972351)
		deleteCheckPoint(HEA1ExitCP)
	elseif(dialogId == 99 and buttonId == 1) then
		if(rowId == 0 and AllVehicles[getPlayerDriving(playerid)] > 0) then
			if(getVehicleEngineFlags(getPlayerDriving(playerid)) == 0) then
				setVehicleEngineFlags(getPlayerDriving(playerid), 2)
			elseif(getVehicleEngineFlags(getPlayerDriving(playerid)) == 1 or getVehicleEngineFlags(getPlayerDriving(playerid)) == 2) then
				sendPlayerMsg(playerid, "The engine is already turned on.", 0xFFFFFF00)
			end
		elseif(rowId == 1 and AllVehicles[getPlayerDriving(playerid)] > 0) then
			if(getVehicleEngineFlags(getPlayerDriving(playerid)) == 1 or getVehicleEngineFlags(getPlayerDriving(playerid)) == 2) then
				setVehicleEngineFlags(getPlayerDriving(playerid), 0)
			elseif(getVehicleEngineFlags(getPlayerDriving(playerid)) == 0) then
				sendPlayerMsg(playerid, "The engine is already turned off.", 0xFFFFFF00)
			end
		elseif(rowId == 0 and AllVehicles[getPlayerDriving(playerid)] <= 0 or rowId == 1 and AllVehicles[getPlayerDriving(playerid)] <= 0) then
			sendPlayerMsg(playerid, "Your vehicle is out of fuel.", 0xFFFFFF00)
		end
	elseif(dialogId == 18 and buttonId == 1) then
		if(rowId == 0) then
			x, y, z = getPlayerPos(playerid)
			model = PlayerTable[getPlayerName(playerid)].Garage[1]
			modelid = getVehicleModelId(string.upper(model))
			createVehicle(modelid, x, y, z, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
			sendPlayerMsg(playerid, "Your vehicle arrived!", 0xFFFFFF00)
		elseif(rowId == 1) then
			x, y, z = getPlayerPos(playerid)
			model = PlayerTable[getPlayerName(playerid)].Garage[2]
			modelid = getVehicleModelId(string.upper(model))
			createVehicle(modelid, x, y, z, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
			sendPlayerMsg(playerid, "Your vehicle arrived!", 0xFFFFFF00)
		elseif(rowId == 2) then
			x, y, z = getPlayerPos(playerid)
			model = PlayerTable[getPlayerName(playerid)].Garage[3]
			modelid = getVehicleModelId(string.upper(model))
			createVehicle(modelid, x, y, z, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
			sendPlayerMsg(playerid, "Your vehicle arrived!", 0xFFFFFF00)
		elseif(rowId == 3) then
			x, y, z = getPlayerPos(playerid)
			model = PlayerTable[getPlayerName(playerid)].Garage[4]
			modelid = getVehicleModelId(string.upper(model))
			createVehicle(modelid, x, y, z, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
			sendPlayerMsg(playerid, "Your vehicle arrived!", 0xFFFFFF00)
		elseif(rowId == 4) then
			x, y, z = getPlayerPos(playerid)
			model = PlayerTable[getPlayerName(playerid)].Garage[5]
			modelid = getVehicleModelId(string.upper(model))
			createVehicle(modelid, x, y, z, 0.0, 0.0, 0.0, 1, 1, 1, 1, 1)
			sendPlayerMsg(playerid, "Your vehicle arrived!", 0xFFFFFF00)
		end
	elseif(dialogId == 77 and buttonId == 1) then
		fuelNeeded = 100 - AllVehicles[getPlayerDriving(playerid)]
		price = fuelNeeded * 2
		setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money - price)
		PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money - price
		AllVehicles[getPlayerDriving(playerid)] = 100
		sendPlayerMsg(playerid, "You refueled your vehicle!", 0xFFFFFF00)
	elseif(dialogId == 1337 and PlayerTable[getPlayerName(playerid)].hasJob == true or dialogId == 45 and PlayerTable[getPlayerName(playerid)].hasJob == true) then
		sendPlayerMsg(playerid, "You are currently unable to start this job.", 0xFFFFFF00)
	elseif(dialogId == 55 and buttonId == 0) then
		sendPlayerMsg(playerid, "Leaveee", 0xFFFFFF00)
		showDialogList(playerid, 55)
	end
end

registerEvent("busDialogResponse", "onPlayerDialogResponse")

-- Function to create checkpoint for a route of the bus job
function BR11(playerid)
	CheckpointId = createCheckPoint(973.84851074219, -143.06121826172, 22.943145751953, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(974.22967529297, -142.29943847656, 23.49111366272, 85, 0xFFFFFFFF, 1, 0, false, "1. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR11"
	hideCheck(playerid, CheckpointId)
end

-- Same stuff, just different bus routes and more checkpoints
function BR21(playerid)
	CheckpointId = createCheckPoint(135.71165466309, -332.89593505859, 13.193890571594, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(135.71165466309, -332.89593505859, 14.193890571594, 85, 0xFFFFFFFF, 1, 0, false, "1. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR21"
	hideCheck(playerid, CheckpointId)
end

function BR31(playerid)
	CheckpointId = createCheckPoint(-1175.1861572266, 1331.6634521484, 21.343858718872, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(-1175.1861572266, 1331.6634521484, 22.343858718872, 85, 0xFFFFFFFF, 1, 0, false, "1. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR31"
	hideCheck(playerid, CheckpointId)
end

function BR12(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(350, 500)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	CheckpointId = createCheckPoint(1247.3278808594, -81.603172302246, 26.877897262573, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(1246.9666748047, -81.823600769043, 27.431922912598, 86, 0xFFFFFFFF, 1, 0, false, "2. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR12"
	hideCheck(playerid, CheckpointId)
end

function BR22(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(500, 750)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	CheckpointId = createCheckPoint(128.57147216797, 15.260237693787, 13.183264732361, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(128.57147216797, 15.260237693787, 14.183264732361, 86, 0xFFFFFFFF, 1, 0, false, "2. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR22"
	hideCheck(playerid, CheckpointId)
end

function BR32(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(750, 1000)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	CheckpointId = createCheckPoint(-1343.3532714844, 1098.6936035156, 18.015712738037, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(-1343.3532714844, 1098.6936035156, 19.015712738037, 86, 0xFFFFFFFF, 1, 0, false, "2. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR32"
	hideCheck(playerid, CheckpointId)
end

function BR13(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(350, 500)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	CheckpointId = createCheckPoint(1814.1390380859, 638.45764160156, 27.187509536743, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(1814.1390380859, 638.45764160156, 28.187509536743, 87, 0xFFFFFFFF, 1, 0, false, "3. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR13"
	hideCheck(playerid, CheckpointId)
end

function BR23(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(500, 750)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	CheckpointId = createCheckPoint(127.57033538818, 163.38909912109, 13.282990455627, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(127.57033538818, 163.38909912109, 14.282990455627, 87, 0xFFFFFFFF, 1, 0, false, "3. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR23"
	hideCheck(playerid, CheckpointId)
end

function BR33(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(500, 1000)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	CheckpointId = createCheckPoint(-1742.6109619141, 418.69320678711, 23.868848800659, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(-1742.6109619141, 418.69320678711, 24.868848800659, 87, 0xFFFFFFFF, 1, 0, false, "3. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR33"
	hideCheck(playerid, CheckpointId)
end

function BR14(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(350, 500)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	CheckpointId = createCheckPoint(2335.8232421875, 368.96716308594, 4.4409923553467, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(2335.8232421875, 368.96716308594, 5.4409923553467, 88, 0xFFFFFFFF, 1, 0, false, "4. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR14"
	hideCheck(playerid, CheckpointId)
end

function BR24(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(500, 750)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	CheckpointId = createCheckPoint(-374.38119506836, 1113.1014404297, 13.180121421814, 3.0, 0xFFFF00FF, 1, 0, 1)
	BlipId = createBlip(-374.38119506836, 1113.1014404297, 14.180121421814, 87, 0xFFFFFFFF, 1, 0, false, "4. Stop")
	showBlipForPlayer(playerid, BlipId, true)
	PlayerTable[getPlayerName(playerid)].JobId = "BR24"
	hideCheck(playerid, CheckpointId)
end

-- Function to end the bus job as soon as you passed the last checkpoint
function BR1End(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(350, 500)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	sendPlayerMsg(playerid, "You successfully completed the Route \"Broker / Dukes\".", 0xFFFFFF00)
	PlayerTable[getPlayerName(playerid)].JobId = "0"
	PlayerTable[getPlayerName(playerid)].hasJob = false
	PlayerTable[getPlayerName(playerid)].Job = "0"
	removePlayerFromVehicle(playerid)
	wait(5)
	deleteVehicle(Bus)
	saveTable()
end

-- Same stuff
function BR2End(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(500, 750)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	sendPlayerMsg(playerid, "You successfully completed the Route \"Algonquin\".", 0xFFFFFF00)
	PlayerTable[getPlayerName(playerid)].JobId = "0"
	PlayerTable[getPlayerName(playerid)].hasJob = false
	PlayerTable[getPlayerName(playerid)].Job = "0"
	removePlayerFromVehicle(playerid)
	wait(5)
	deleteVehicle(Bus)
	saveTable()
end

function BR3End(playerid)
	deleteCheck()
	deleteBlips()
	earnedCash = mathRand(750, 1000)
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	sendPlayerMsg(playerid, "You successfully completed the Route \"Alderney\".", 0xFFFFFF00)
	PlayerTable[getPlayerName(playerid)].JobId = "0"
	PlayerTable[getPlayerName(playerid)].hasJob = false
	PlayerTable[getPlayerName(playerid)].Job = "0"
	removePlayerFromVehicle(playerid)
	wait(5)
	deleteVehicle(Bus)
	saveTable()
end

-- Function to handle what happens when you exit a vehicle (not used ig)
function onExitVehicle(playerid, vehicleId, seatId)
	if(PlayerTable[getPlayerName(playerid)].JobId == "BR11" or PlayerTable[getPlayerName(playerid)].JobId == "BR12"
	or PlayerTable[getPlayerName(playerid)].JobId == "BR13" or PlayerTable[getPlayerName(playerid)].JobId == "BR14"
	or PlayerTable[getPlayerName(playerid)].JobId == "BR21" or PlayerTable[getPlayerName(playerid)].JobId == "BR22"
	or PlayerTable[getPlayerName(playerid)].JobId == "BR23" or PlayerTable[getPlayerName(playerid)].JobId == "BR24"
	or PlayerTable[getPlayerName(playerid)].JobId == "BR31" or PlayerTable[getPlayerName(playerid)].JobId == "BR32"
	or PlayerTable[getPlayerName(playerid)].JobId == "BR33" and vehicleId == Bus) then
		sendPlayerMsg(1, "Don't leave!", 0xFFFFFF00) -- when bus left then end job
	end
end

registerEvent("onExitVehicle", "onPlayerExitVehicle")

-- Function to create fast food stores with their checkpoints and blips
function FastFoodStores()
	CB1 = createCheckPoint(-121.8881149292, 69.914100646973, 13.808049201965, 1.0, 0xFFFF00FF, 1, 0, 1)
	createBlip(-121.8881149292, 69.914100646973, 13.808049201965, 22, 0xFFFFFFFF, 1, 0, true, "Cluckin' Bell")
	CB2 = createCheckPoint(1184.5009765625, 359.93240356445, 24.112752914429, 1.0, 0xFFFF00FF, 1, 0, 1)
	createBlip(1184.5009765625, 359.93240356445, 24.112752914429, 22, 0xFFFFFFFF, 1, 0, true, "Cluckin' Bell")
end

FastFoodStores()

-- Function to handle what happens when you do a fast food job
function FF1(playerid)
	setPlayerFrozen(playerid, true)
	PlayerTable[getPlayerName(playerid)].hasJob = true
	PlayerTable[getPlayerName(playerid)].Job = "FastFood"
	PlayerTable[getPlayerName(playerid)].JobId = "FF1"
	sendPlayerMsg(playerid, "Customer: Hello, I'd like one burger.", 0xFFFFFF00)
	showDialogList(playerid, 55)
end

-- Same stuff
function FF2(playerid)
	earnedCash = 25
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	PlayerTable[getPlayerName(playerid)].JobId = "FF2"
	sendPlayerMsg(playerid, "Customer: Hello, I'd like one soda.", 0xFFFFFF00)
	showDialogList(playerid, 55)
end

function FF3(playerid)
	earnedCash = 20
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	PlayerTable[getPlayerName(playerid)].JobId = "FF3"
	sendPlayerMsg(playerid, "Customer: Hi, could I get a Special Burger?", 0xFFFFFF00)
	showDialogList(playerid, 55)
end

function FF4(playerid)
	earnedCash = 75
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	PlayerTable[getPlayerName(playerid)].JobId = "FF4"
	sendPlayerMsg(playerid, "Customer: Give me some French Fries, I'm in a hurry.", 0xFFFFFF00)
	showDialogList(playerid, 55)
end

function FF5(playerid)
	earnedCash = 50
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	PlayerTable[getPlayerName(playerid)].JobId = "FF5"
	sendPlayerMsg(playerid, "Customer: Mmm...I guess...I'll take some...uhh...Chicken Nuggets, yeah.", 0xFFFFFF00)
	showDialogList(playerid, 55)
end

-- Function to finish the fast food job
function FFEnd(playerid)
	earnedCash = 500
	setPlayerCash(playerid, PlayerTable[getPlayerName(playerid)].Money + earnedCash)
	PlayerTable[getPlayerName(playerid)].Money = PlayerTable[getPlayerName(playerid)].Money + earnedCash
	sendPlayerMsg(playerid, "You successfully completed your shift at Cluckin' Bell!", 0xFFFFFF00)
	setPlayerFrozen(playerid, false)
	PlayerTable[getPlayerName(playerid)].hasJob = false
	PlayerTable[getPlayerName(playerid)].Job = "0"
	PlayerTable[getPlayerName(playerid)].JobId = "0"
	saveTable()
end

-- Function to create first car dealership with cars etc.
function CarDealership1()
	createBlip(-1488.5852050781, 1130.9370117188, 22.012754440308, 79, 0xFFFFFFFF, 1, 0, true, "Auto Eroticar")
	car11 = createVehicle(1, -1496.0268554688, 1124.3966064453, 22.744379043579, 0.0, 0.0, -90.0, 1, 1, 1, 1, 1)
	car12 = createVehicle(43, -1496.0268554688, 1130.6478271484, 22.746042251587, 0.0, 0.0, -90.0, 1, 1, 1, 1, 1)
	car13 = createVehicle(68, -1496.0268554688, 1137.884765625, 22.74388885498, 0.0, 0.0, -90.0, 1, 1, 1, 1, 1)
	car11CP = createCheckPoint(-1492.1573486328, 1124.3966064453, 21.744379043579, 1.5, 0xFFFF00FF, 1, 0, 1)
	car12CP = createCheckPoint(-1492.1573486328, 1130.6478271484, 21.746042251587, 1.5, 0xFFFF00FF, 1, 0, 1)
	car13CP = createCheckPoint(-1492.1573486328, 1137.884765625, 21.74388885498, 1.5, 0xFFFF00FF, 1, 0, 1)
	buy1CP = createCheckPoint(-1496.3796386719, 1118.8771972656, 22.213747024536, 1.0, 0xFFFF00FF, 1, 0, 1)
end

CarDealership1()

registerEvent("RequestVehicleEntry", "onPlayerRequestVehicleEntry")

-- Function to handle what happens when you try to enter a car (you wont be able to enter cars on showcase in the dealerships)
function RequestVehicleEntry(playerid, vehicleId)
	if (vehicleId == car11 or vehicleId == car21) then
		removePlayerFromVehicle(playerid)
	elseif (vehicleId == car12 or vehicleId == car22) then
		removePlayerFromVehicle(playerid)
	elseif (vehicleId == car13 or vehicleId == car23) then
		removePlayerFromVehicle(playerid)
	end
end

-- Function to draw text when player walks near the cars on showcase in a dealership to get info about them
function car11Info(playerid)
	drawInfoText(playerid, "~y~Admiral", 2000)
end

-- Same stuff
function car12Info(playerid)
	drawInfoText(playerid, "~y~Intruder", 2000)
end

function car13Info(playerid)
	drawInfoText(playerid, "~y~Premier", 2000)
end

-- Function to create the second car dealership with cars etc.
function CarDealership2()
	createBlip(56.823192596436, 804.44287109375, 13.765069007874, 79, 0xFFFFFFFF, 1, 0, true, "Grotti Automobile")
	car21 = createVehicle(4, 67.15404510498, 805.86199951172, 14.694367408752, 0.0, 0.0, 180.0, 1, 1, 1, 1, 1)
	car22 = createVehicle(17, 72.405418395996, 805.86199951172, 14.69543838501, 0.0, 0.0, 180.0, 1, 1, 1, 1, 1)
	car23 = createVehicle(41, 77.609550476074, 805.86199951172, 14.694947242737, 0.0, 0.0, 180.0, 1, 1, 1, 1, 1)
	car21CP = createCheckPoint(67.18724822998, 802.00915527344, 14.163144111633, 1.5, 0xFFFF00FF, 1, 0, 1)
	car22CP = createCheckPoint(72.399360656738, 802.00915527344, 14.163142204285, 1.5, 0xFFFF00FF, 1, 0, 1)
	car23CP = createCheckPoint(77.571922302246, 802.00915527344, 14.163148880005, 1.5, 0xFFFF00FF, 1, 0, 1)
	buy2CP = createCheckPoint(54.538272857666, 801.11724853516, 14.163130760193, 1.0, 0xFFFF00FF, 1, 0, 1)
end

CarDealership2()

-- Same stuff like before but for second dealership
function car21Info(playerid)
	drawInfoText(playerid, "~y~Banshee", 2000)
end

function car22Info(playerid)
	drawInfoText(playerid, "~y~Cognoscenti", 2000)
end

function car23Info(playerid)
	drawInfoText(playerid, "~y~Infernus", 2000)
end

-- Function to create Low end apartment 1, its checkpoint etc.
function LEA1()
	LEA1CP = createCheckPoint(897.78088378906, -504.98333740234, 14.064782142639, 2.0, 0xFFFF00FF, 1, 0, 1)
	createBlip(897.78088378906, -504.98333740234, 14.064782142639, 29, 0xFFFFFFFF, 1, 0, true, "Apartment")
end

LEA1()

-- Same stuff but high end apartment 1
function HEA1()
	HEA1CP = createCheckPoint(113.20606994629, 844.96362304688, 13.716341972351, 2.0, 0xFFFF00FF, 1, 0, 1)
	createBlip(113.20606994629, 844.96362304688, 13.716341972351, 29, 0xFFFFFFFF, 1, 0, true, "Apartment")
end

HEA1()

-- Function to create the gas station with checkpoint etc.
function Gas1()
	createBlip(-479.74600219727, -209.23097229004, 6.7489099502563, 91, 0xFFFFFFFF, 1, 0, true, "Gas Station")
	GasCP11 = createCheckPoint(-477.51477050781, -213.97120666504, 6.7486009597778, 3.0, 0xFFFF00FF, 1, 0, 1)
	GasCP12 = createCheckPoint(-481.75671386719, -204.71183776855, 6.7486944198608, 3.0, 0xFFFF00FF, 1, 0, 1)
end

Gas1()