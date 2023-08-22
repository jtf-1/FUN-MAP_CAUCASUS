env.info( "[JTF-1] supportaircraft_data" )
--------------------------------------------
--- Support Aircraft Defined in this file
--------------------------------------------
--
-- **NOTE**: SUPPORTAIRCRAFT.LUA MUST BE LOADED BEFORE THIS FILE IS LOADED!
--
-- This file contains the config data specific to the miz in which it will be used.
-- All functions and key values are in SUPPORTAIRCRAFT.LUA, which should be loaded first
--
-- Load order in miz MUST be;
--     1. supportaircraft.lua
--     2. supportaircraft_data.lua
--

-- Error prevention. Create empty container if SUPPORTAIRCRAFT.LUA is not loaded or has failed.
if not SUPPORTAC then 
	_msg = "[JTF-1 SUPPORTAC] CORE FILE NOT LOADED!"
	BASE:E(_msg)
	SUPPORTAC = {}
end

SUPPORTAC.useSRS = true

-- Support aircraft missions. Each mission block defines a support aircraft mission. Each block is processed
-- and an aircraft will be spawned for the mission. When the mission is cancelled, eg after RTB or if it is destroyed,
-- a new aircraft will be spawned and a fresh AUFTRAG created.
--
-- See SUPPORTAC.missionDefault in supportaircraft.lua for all mission options.
--
SUPPORTAC.mission = {
	{
		name = "ARLM",
		category = SUPPORTAC.category.tanker,
		type = SUPPORTAC.type.tankerProbeC130,
		zone = "ARLM",
		callsign = CALLSIGN.Tanker.Arco,
		callsignNumber = 1,
		tacan = 36,
		tacanid = "ARC",
		radio = 276.5,
		flightLevel = 160,
		speed = 315,
		heading = 81,
		leg = 30,
		fuelLowThreshold = 30,
		activateDelay = 5,
		despawnDelay = 10,
	},
	{
		name = "ARLM",
		category = SUPPORTAC.category.tanker,
		type = SUPPORTAC.type.tankerProbe,
		zone = "ARLM",
		callsign = CALLSIGN.Tanker.Shell,
		callsignNumber = 1,
		tacan = 115,
		tacanid = "SHL",
		radio = 317.5,
		flightLevel = 200,
		speed = 315,
		heading = 81,
		leg = 30,
		fuelLowThreshold = 30,
		activateDelay = 5,
		despawnDelay = 10,
	},
	{
		name = "ARLM",
		category = SUPPORTAC.category.tanker,
		type = SUPPORTAC.type.tankerBoom,
		zone = "ARLM",
		callsign = CALLSIGN.Tanker.Texaco,
		callsignNumber = 1,
		tacan = 105,
		tacanid = "TEX",
		radio = 317.75,
		flightLevel = 240,
		speed = 315,
		heading = 81,
		leg = 30,
		fuelLowThreshold = 30,
		activateDelay = 5,
		despawnDelay = 10,
	},
	{
		name = "AREH",
		category = SUPPORTAC.category.tanker,
		type = SUPPORTAC.type.tankerProbe,
		zone = "AREH",
		callsign = CALLSIGN.Tanker.Shell,
		callsignNumber = 2,
		tacan = 116,
		tacanid = "SHL",
		radio = 317.6,
		flightLevel = 200,
		speed = 315,
		heading = 266,
		leg = 30,
		fuelLowThreshold = 30,
		activateDelay = 5,
		despawnDelay = 10,
	},
    {
        name = "AWACSSOUTH",
        category = SUPPORTAC.category.awacs,
        type = SUPPORTAC.type.awacsE3a,
        zone = "AWACSSOUTH",
        callsign = CALLSIGN.AWACS.Magic,
        callsignNumber = 1,
        tacan = nil,
        tacanid = nil,
        radio = 367.575,
        flightLevel = 300,
        speed = 400,
        heading = 100,
        leg = 60,
        activateDelay = 5,
        despawnDelay = 10,
        fuelLowThreshold = 15,
      },
      {
        name = "REDAWACS",
        category = SUPPORTAC.category.awacs,
        type = SUPPORTAC.type.awacsA50,
        zone = "REDAWACS",
        callsign = "666",
        callsignNumber = 1,
        tacan = nil,
        tacanid = nil,
        radio = 251,
        flightLevel = 360,
        speed = 400,
        heading = 102,
        leg = 70,
        activateDelay = 5,
        despawnDelay = 10,
        fuelLowThreshold = 15,
        coalition = coalition.side.RED,
        countryid = country.id.RUSSIA,
      },
    }

-- call the function that initialises the SUPPORTAC module
if SUPPORTAC.Start ~= nil then
  _msg = "[JTF-1 SUPPORTAC] SUPPORTAIRCRAFT_DATA - call SUPPORTAC:Start()."
  BASE:I(_msg)
  SUPPORTAC:Start()
end


