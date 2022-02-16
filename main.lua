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