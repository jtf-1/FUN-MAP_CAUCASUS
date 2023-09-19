env.info( "[JTF-1] missioncap_data" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- MISSION CAP SETTINGS FOR MIZ
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- This file MUST be loaded AFTER missioncap.lua
--
-- These values are specific to the miz and will override the default values in MISSIONCAP.default
--

-- Error prevention. Create empty container if module core lua not loaded.
if not MISSIONCAP then 
	MISSIONCAP = {}
	MISSIONCAP.traceTitle = "[JTF-1 MISSIONTIMER] "
	_msg = MISSIONCAP.traceTitle .. "CORE FILE NOT LOADED!"
	BASE:E(_msg)
end

------------------------------------------------------
--- table containing CAP spawn config per location ---
------------------------------------------------------

-- CAP Missions
MISSIONCAP.capMission = { -- spawn location, { spawn, spawnZone, templates, patrolzone, engagerange } ...
	{
		name = "Region West & North", -- mission name. Used for menu grouping
		spawnZone = "ZONE_WestNorthCapSpawn", -- zone in which CAP aircraft will spawn
		patrolZone = "zonePatrolWest", -- zone in which CAP aircraft will patrol
		engageZone = "zoneEngageWest", -- zone in which CAP will engage enemy aircraft. Ange zone allows creation of a buffer zone between the CAP and approaching enemy
		engageRange = 60000, -- range at which CAP will engage enemy aircraft if enageZone is NOT defined/found
		spawnTemplate = "WestCap",
	},
	{
		name = "Region Central & East",
		spawnZone = "ZONE_CentralEastCapSpawn",
		patrolZone = "zonePatrolEast",
		engageZone = "zoneEngageEast",
		engageRange = 60000,
		spawnTemplate = "EastCap",
	},
}

-- start mission cap
if MISSIONCAP.Start then
	_msg = MISSIONCAP.traceTitle .. "Call Start()"
	BASE:T(_msg)
	MISSIONCAP:Start()
end
