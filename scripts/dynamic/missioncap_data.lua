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
		name = "Maykop", -- mission name. Used for menu grouping
		spawnZone = "ZONE_MaykopCapSpawn", -- zone in which CAP aircraft will spawn
		patrolZone = "zonePatrolWest", -- zone in which CAP aircraft will patrol
		engageZone = "zoneEngageWest", -- zone in which CAP will engage enemy aircraft. Ange zone allows creation of a buffer zone between the CAP and approaching enemy
		engageRange = 60000, -- range at which CAP will engage enemy aircraft if enageZone is NOT defined/found
		spawnTemplate = "MaykopCap",
	},
	{
		name = "Beslan",
		spawnZone = "ZONE_BeslanCapSpawn",
		patrolZone = "zonePatrolEast",
		engageZone = "zoneEngageEast",
		engageRange = 60000,
		spawnTemplate = "BeslanCap",
	},
}

-- start mission cap
if MISSIONCAP.Start then
	_msg = MISSIONCAP.traceTitle .. "Call Start()"
	BASE:T(_msg)
	MISSIONCAP:Start()
end
