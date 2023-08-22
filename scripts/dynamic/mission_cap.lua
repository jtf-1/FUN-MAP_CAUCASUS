env.info( "[JTF-1] mission_cap" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN CAP
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

MISSIONCAP = {}
MISSIONCAP.menu = {}

MISSIONCAP.default = {
	engageRange = 60000,
	capTemplates = {
		"CAP_Mig29",
		"CAP_Mig21",
		"CAP_Su27",
	},
}

function MISSIONCAP:Start()
	_msg = "[JTF-1 MISSIONCAP] AddMission()"
	BASE:T(_msg)
	
	-- Add main menu for CAP Missions
	MISSIONCAP.menu = MENU_COALITION:New( coalition.side.BLUE, "ENEMY CAP CONTROL" )

	-- Instantiate CAP Missions
	for index, capMission in ipairs(MISSIONCAP.capMission) do
		_msg = string.format("[JTF-1 MISSIONCAP] Start - mission %s", capMission.name)
		BASE:T({_msg, capMission})

		MISSIONCAP:AddMission(capMission)
	end

end

-- Add CAP mission to main menu
function MISSIONCAP:AddMission(capMission)

	local capName = capMission.name

	_msg = string.format("[JTF-1 MISSIONCAP] AddMission() %s.", capName)
	BASE:T({_msg, capMission})

	capMission.spawn = SPAWN:New( capMission.spawnTemplate )
	capMission.spawnZone = ZONE:FindByName(capMission.spawnZone)
	capMission.patrolZone = ZONE:FindByName(capMission.patrolZone) or ZONE_POLYGON:FindByName(capMission.patrolZone)
	capMission.engageZone = ZONE:FindByName(capMission.engageZone) or ZONE_POLYGON:FindByName(capMission.engageZone) -- nil if an engage zone is not defined
	capMission.engageRange = capMission.engageRange or MISSIONCAP.default.engageRange

	-- if trace is on, draw the zones on the map
	if BASE:IsTrace() and capMission.engageZone then 
		_msg = string.format("[JTF-1 MISSIONCAP] Draw engage zone %s.", capMission.engageZone:GetName())
		BASE:T(_msg)
		-- draw mission zone on map
		capMission.engageZone:DrawZone()
	else
		_msg = string.format("[JTF-1 MISSIONCAP] No engage zone for mission %s defined.", capName)
		BASE:T(_msg)
	end

	_msg = string.format("[JTF-1 MISSIONCAP] Add Menus for mission %s.", capName)
	BASE:T(_msg)
	
	capMission.menu = MENU_COALITION:New( coalition.side.BLUE, capName, MISSIONCAP.menu )
	capMission.menu[1] = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Add Single", capMission.menu, MISSIONCAP.SpawnCap, capMission, 1) -- Spawn CAP 1 aircraft
	capMission.menu[2] = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Add Pair", capMission.menu, MISSIONCAP.SpawnCap, capMission, 2) -- Spawn CAP 2 aircraft
	capMission.menu[3] = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Add Four", capMission.menu, MISSIONCAP.SpawnCap, capMission, 4) -- Spawn CAP 4 aircraft
	capMission.menu[4] = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Remove Oldest " .. capName .. " CAP", capMission.menu, MISSIONCAP.RemoveSpawn, capMission ) -- Remove the oldest CAP flight for location

end

--XXX ## Spawning CAP flights
-- max 8x CAP aircraft can be spawned at each location
function MISSIONCAP.SpawnCap( capMission, qty ) -- spawnobject, spawntable { spawn, spawnZone, templates, patrolzone, aicapzone, engagerange }
	_msg = "[JTF-1 MISSIONCAP] SpawnCap()"
	BASE:T({_msg, qty, capMission})

	if capMission.patrolZone then
		if capMission.spawnZone then
			capMission.spawn:InitLimit(8,0) -- max 8x cap sections alive   
			:InitGrouping(qty)
			:InitCleanUp(60) -- remove aircraft that have landed
			:OnSpawnGroup(
				function ( SpawnGroup )
					AICapZone = AI_CAP_ZONE:New( capMission.patrolZone , 3000, 9000)
					AICapZone:SetControllable( SpawnGroup )
					if capMission.engageZone then
						AICapZone:SetEngageZone( capMission.engageZone )
					elseif capMission.engageRange then -- use engage range if engage zone is not defined
						AICapZone:SetEngageRange( capMission.engageRange )
					end
					AICapZone:__Start( 1 ) -- start patrolling in the PatrolZone.
				end
				,capMission.patrolZone, capMission.engageZone, capMission.engageRange
			)
			:SpawnInZone( capMission.spawnZone, true, 3000, 6000 )
		else
			_msg = string.format("[JTF-1 MISSIONCAP] SpawnCap(). Spawn zone %s for CAP Mission %s is not found", capMission.spawnZone:GetName(), capMission.name)
			BASE:E(_msg)
		end
	else
		_msg = string.format("[JTF-1 MISSIONCAP] SpawnCap(). Patrol zone %s for CAP Mission %s is not found", capMission.patrolZone:GetName(), capMission.name)
		BASE:E(_msg)

	end

end --function

-- Remove oldest spawn in a mission
function MISSIONCAP.RemoveSpawn( capMission )
	_msg = "[JTF-1 MISSIONCAP] RemoveSpawn()"
	BASE:T({_msg, capMission})

	--local RemoveSpawnGroupTable = _args[1]

	local FirstSpawnGroup, Index = capMission.spawn:GetFirstAliveGroup()
	if FirstSpawnGroup then
		FirstSpawnGroup:Destroy( false )
	else
		_msg = string.format("[JTF-1 MISSIONCAP] RemoveSpawn(). No spawn found for CAP Mission %s.", capMission.name)
		BASE:E(_msg)
	end

end --function

-- ## Remove oldest spawned group in a mission
function RemoveSpawnGroup( _args )
	_msg = "[JTF-1 MISSIONCAP] RemoveSpawnGroup()"
	BASE:T({_msg, _args})

	for index, SpawnObject in pairs( _args ) do
		local FirstSpawnGroup, FirstSpawnIndex = SpawnObject:GetFirstAliveGroup()
		if FirstSpawnGroup then
			FirstSpawnGroup:Destroy( false )
		end
	end

end --function

------------------------------------------------------
--- table containing CAP spawn config per location ---
------------------------------------------------------

-- CAP spawn templates for random spawns
MISSIONCAP.CapTemplates = {
	"Russia_Mig29",
	"Russia_Mig21",
	"Russia_Su27"
}

-- CAP Missions
MISSIONCAP.capMission = { -- spawn location, { spawn, spawnZone, templates, patrolzone, engagerange } ...
	{
		name = "Maykop", -- mission name. Used for menu grouping
		spawnZone = "ZONE_MaykopCapSpawn", -- zone in which CAP aircraft will spawn
		patrolZone = "zonePatrolWest", -- zone in which CAP aircraft will patrol
		engageZone = "zoneEngageWest", -- zone in which CAP will engage enemy aircraft. Ange zone allows creation of a buffer zone between the CAP and approaching enemy
		engageRange = 60000, -- range at which CAP will engage enemy aircraft if enageZone is NOT defined/found
		templates = CapTemplates,
		spawnTemplate = "MaykopCap",
	},
	{
		name = "Beslan",
		spawnZone = "ZONE_BeslanCapSpawn",
		patrolZone = "zonePatrolEast",
		engageZone = "zoneEngageEast",
		engageRange = 60000,
		templates = CapTemplates,
		spawnTemplate = "BeslanCap",
	},
}

MISSIONCAP:Start()

-- END CAP SECTION