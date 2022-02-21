local spawnedCars = {}

local function deletePlayerVehicles(playerid)
	if(spawnedCars[playerid] ~= nil) then
		local carId = spawnedCars[playerid]
		if(isVehicle(carId)) then
			deleteVehicle(carId)
		end
	end 
end

function speedometer()
	local players = getPlayers()
		
	for i, id in ipairs(players) do
		local vehicleId = isPlayerInAnyVehicle(id)
		if(vehicleId ~= 0 and isVehicle(vehicleId)) then
		
			local velocityX, velocityY, velocityZ = getVehicleVelocity(vehicleId)
			local speed = math.ceil(math.sqrt(velocityX^2 + velocityY^2 + velocityZ^2) * 3.7);
			
			drawInfoText(id, "~R~Speed:~w~ " .. speed .. " KPH", 600)
		end
	end
end
local speedoTimer = setTimer("speedometer", 150, 0)

addCommand("/v",
	function(playerid, param)
		if(param == nil) then
			sendPlayerMsg(playerid, "Usage: /v [vehicle name]" , 0xFFFF0000)
			do return end
		end
		param[1] = param[1]:upper()
		local modelId = getVehicleModelId(param[1])
		if(modelId == -1) then
			sendPlayerMsg(playerid, "'" .. param[1] .. "' is an invalid vehicle name", 0xFFFF0000)
			do return end
		end
		local x, y, z = getPlayerPos(playerid)
		local rColor = math.random(0, 170)
		deletePlayerVehicles(playerid)
		local carId = createVehicle(modelId, x, y, z, 0.0, 0.0, 0.0, rColor, rColor, rColor, rColor, getPlayerWorld(playerid))
		spawnedCars[playerid] = carId
		--setVehicleHood(carId, true)
		sendPlayerMsg(playerid, param[1] .. " spawned with id " .. carId .. " with color " .. rColor, 0xFFFFFFFF)
	end
, "s")

function carSpawningUnload()
	print("Unloading carSpawning")
	removeCommand("/v")
	unregisterEvent("carSpawningPlayerLeft")
	deleteTimer(speedoTimer)
	
	for spawnerId, carId in pairs(spawnedCars) do
		if(isVehicle(carId)) then
			deleteVehicle(carId)
		end
	end
end
registerScriptUnload("carSpawning", carSpawningUnload) --Adds an unload point

function carSpawningPlayerLeft(playerid, reason)
	if(spawnedCars[playerid] ~= nil and isVehicle(spawnedCars[playerid])) then
		deleteVehicle(spawnedCars[playerid])
		spawnedCars[playerid] = nil
	end
end
registerEvent("carSpawningPlayerLeft", "onPlayerLeft")
