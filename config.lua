--------------------------------------------------
--------- SCRIPT MADE BY \~𝓥𝓞𝓡𝓣𝓔𝓧#0819 ---------
------- Feel free to message me on Discord -------
--- P.S.: Sorry for not including an en-locale ---
------------------- HAVE FUN!! -------------------
--------------------------------------------------
--[[
_____ __  __ _____   ____  _____ _______       _   _ _______ 
|_   _|  \/  |  __ \ / __ \|  __ \__   __|/\   | \ | |__   __|
  | | | \  / | |__) | |  | | |__) | | |  /  \  |  \| |  | |   
  | | | |\/| |  ___/| |  | |  _  /  | | / /\ \ | . ` |  | |   
 _| |_| |  | | |    | |__| | | \ \  | |/ ____ \| |\  |  | |   
|_____|_|  |_|_|     \____/|_|  \_\ |_/_/    \_\_| \_|  |_|   

DEPENDENCIES:
https://github.com/aymannajim/an_progBar
https://okok.tebex.io/package/4724993
If you don't have money for okokNotify just replace the exports in the client and server with your notify i.e. MythicNotify
]]--

Config = {}
Config.Locale = 'de'

Config.useEsxLegacy = true -- Are you running ESX Legacy on your server? If yes, leave on true, if not or you are not sure, turn to false.
-- If you have it on false and get a warning similar to this when starting the script: [WARNING] esx_helicopterjob used esx:getSharedObject, this method is deprecated and should not be used, On 30/11/2022 esx:getSharedObject will come to EOL and be fully removed!
-- Then set it to true.

-- Blip settings
Config.showBlip = true
Config.blipName = 'Helikopter Job'
-- Heli vehicle that spawns
Config.vehicle = "FROGGER"
Config.pickupVeh = 'DINGHY'
-- Where to go to start the job?
Config.StartPos = vector3(1757.9883, 3296.8831, 41.1471)
Config.HelipadCoords = vector3(1770.2710, 3239.7427, 42.1267) -- Coords for the heli Pad near the start location to end the job
Config.HelipadRadius = 10.0 -- don't touch this if you are not sure what it does
-- Where should the heli spawn?
Config.Spawn = vector3(1764.9888, 3271.1379, 41.3619)
Config.SpawnHeading = 76.2870
-- Where should the player fly to to deliver the cargo?
Config.Destination = vector3(-1287.2505, 6898.6641, -0.1801)
Config.Destination2 = vector3(3538.9995, -433.9965, -0.1472)
Config.Destination3 = vector3(2102.0076, 7066.0820, -0.1514)
Config.DestBlipName = 'Abwurfsort'
-- Where the player should load up new cargo once delivered.
Config.LoadDestination = vector3(1696.6011, 3265.5139, 40.9979)
-- Time to load the cargo in seconds
Config.LoadTime = 5
-- How much should the Job pay?
Config.Payment1 = 1100
Config.Payment2 = 1100
Config.Payment3 = 1100
-- How much should the player pay if the Vehicle gets destroyed during the job? Set to 0 to disable.
Config.fineAmount = 2000