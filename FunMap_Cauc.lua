--CSG-1 Caucasus Fun Map MOOSE Mission Script



env.info( '*** CSG-1 Caucasus Fun Map MOOSE script ***' )
env.info( '*** CSG-1 MOOSE MISSION SCRIPT START ***' )

GlobalDebug = false

-- BEGIN MENU DEFINITIONS



-- ## CAP CONTROL
MenuCapTop = MENU_COALITION:New( coalition.side.BLUE, " ENEMY CAP CONTROL" )
	MenuCapMaykop = MENU_COALITION:New( coalition.side.BLUE, "MAYKOP", MenuCapTop )
	MenuCapBeslan = MENU_COALITION:New( coalition.side.BLUE, "BESLAN", MenuCapTop )

-- ## GROUND ATTACK MISSIONS
MenuGroundTop = MENU_COALITION:New( coalition.side.BLUE, " GROUND ATTACK MISSIONS" )
	MenuCampAttack = MENU_COALITION:New( coalition.side.BLUE, " Camp Strike", MenuGroundTop )
	MenuConvoyAttack = MENU_COALITION:New( coalition.side.BLUE, " Convoy Strike", MenuGroundTop )
		MenuConvoyAttackWest = MENU_COALITION:New( coalition.side.BLUE, " West Region", MenuConvoyAttack )
		MenuConvoyAttackCentral = MENU_COALITION:New( coalition.side.BLUE, " Central Region", MenuConvoyAttack )
	MenuAirfieldAttack = MENU_COALITION:New(coalition.side.BLUE, " Airfield Strike", MenuGroundTop )
	MenuFactoryAttack = MENU_COALITION:New(coalition.side.BLUE, " Factory Strike", MenuGroundTop )
	MenuBridgeAttack = MENU_COALITION:New(coalition.side.BLUE, " Bridge Strike", MenuGroundTop )
	MenuCommunicationsAttack = MENU_COALITION:New(coalition.side.BLUE, "   WiP Communications Strike", MenuGroundTop )
	MenuC2Attack = MENU_COALITION:New(coalition.side.BLUE, "   WiP C2 Strike", MenuGroundTop )

-- ## STRIKE PACKAGE MISSIONS
MenuStrikePackageTop = MENU_COALITION:New(coalition.side.BLUE, "   WiP STRIKE PACKAGE MISSIONS" ) -- WiP

-- ## ANTI-SHIP MISSIONS
MenuAntiShipTop = MENU_COALITION:New(coalition.side.BLUE, "   WiP ANTI-SHIP MISSIONS" ) -- WiP

-- ## FLEET DEFENCE MISSIONS
MenuFleetDefenceTop = MENU_COALITION:New(coalition.side.BLUE, "   WiP FLEET DEFENCE MISSIONS" ) -- WiP

  


-- END MENU DEFINITIONS
-- BEGIN UTILITY FUNCTIONS



-- ## Message displayed if WiP menu options are selected
function MenuWip( _arg )
	  MESSAGE:New( "The " .. _arg .. " menu option is currently under construction. " ,5,"" ):ToAll()
end --function

-- ## Spawn Support aircraft
-- Scheduled function on spawn to check for presence of the support aircraft in its spawn zone. Repeat check every 60 seconds. Respawn if ac has left zone. 
-- also respawn on engine shutdown if an airfield is within the support zone.
function SpawnSupport (SupportSpawn) -- spawnobject, spawnzone

	--local SupportSpawn = _args[1]
	local SupportSpawnObject = SPAWN:New( SupportSpawn.spawnobject )

	SupportSpawnObject:InitLimit( 1, 50 )
		:OnSpawnGroup(
			function ( SpawnGroup )
				local SpawnIndex = SupportSpawnObject:GetSpawnIndexFromGroup( SpawnGroup )
				local CheckTanker = SCHEDULER:New( nil, 
				function()
					if SpawnGroup:IsNotInZone( SupportSpawn.spawnzone ) then
						SupportSpawnObject:ReSpawn( SpawnIndex )
					end
				end,
				{}, 0, 60 )
			end
		)
		:InitRepeatOnEngineShutDown()
		:Spawn()


end -- function

-- ## Spawning CAP flights
-- max 8x CAP aircraft can be spawned at each location
function SpawnCap( _args ) --	spawnobject, spawntable { spawn, spawnzone, templates, patrolzone, aicapzone, engagerange }

	local SpawnCapTable = _args[1]
	
	SpawnCapTable.spawn:InitLimit( 8,9999 ) -- max 8x cap sections alive   
		:InitRandomizeTemplate( SpawnCapTable.templates )
		:InitCleanUp( 60 ) -- remove aircraft that have landed
		:OnSpawnGroup(
			function ( SpawnGroup )
				local AICapZone = AI_CAP_ZONE:New( SpawnCapTable.patrolzone , 1000, 6000, 500, 600 )
				AICapZone:SetControllable( SpawnGroup )
				AICapZone:SetEngageRange( SpawnCapTable.engagerange ) -- The AI won't engage when the enemy is beyond the range defined in the cap table.  Zone detection not working :SetEngageZone( SpawnCapTable.engagezone )
				AICapZone:__Start( 1 ) -- start patrolling in the PatrolZone.
			end
		)
		:SpawnInZone( SpawnCapTable.spawnzone, true, 3000, 6000 )
		
end --function
  
-- ## Spawning enemy convoys
--  ( Central, West ) 
function SpawnConvoy ( _args ) -- ConvoyTemplates, SpawnHost {conv, dest, destzone, strikecoords, is_open}, ConvoyType, ConvoyThreats

	local TemplateTable = _args[1]
	local SpawnHostTable = _args[2]
	local ConvoyType = _args[3]
	local ConvoyThreats = _args[4]
	
	
	local SpawnIndex = math.random ( 1, #SpawnHostTable )
	local SpawnHost = SpawnHostTable[SpawnIndex].conv
	local DestZone = SpawnHostTable[SpawnIndex].destzone
	
	SpawnHost:InitRandomizeTemplate( TemplateTable )
		:OnSpawnGroup(
			function ( SpawnGroup )
				CheckConvoy = SCHEDULER:New( nil, 
					function()
						if SpawnGroup:IsPartlyInZone( DestZone ) then
							SpawnGroup:Destroy( false )
						end
					end,
					{}, 0, 60 
				)
			end
		)
		:Spawn()

	local ConvoyAttackBrief = "++++++++++++++++++++++++++++++++++++" 
		.."\n\nIntelligence is reporting an enemy "
		.. ConvoyType
		.. " convoy\nbelieved to be routing to "
		.. SpawnHostTable[SpawnIndex].dest .. "."
		.. "\n\nMission:  LOCATE AND DESTROY THE CONVOY."
		.. "\n\nLast Known Position:  "
		.. SpawnHostTable[SpawnIndex].coords
		.. ConvoyThreats
		.. "\n\n++++++++++++++++++++++++++++++++++++"
		
	MESSAGE:New( ConvoyAttackBrief, 30, "" ):ToAll()
	
		
end --function  
  
-- ## Spawning enemy camps 
function SpawnCamp( _args ) --TemplateTable, CampsTable [ loc, town, coords, is_open ], Region
	
	local SpawnTemplateTable = _args[1]
	local SpawnCampsTable = _args[2]
	local SpawnZoneRegion = _args[3]
	
	local count = 0
	for CampIndex, CampValue in ipairs(SpawnCampsTable) do -- Count number of unsed camp spawns available in region
		if CampValue.is_open then
			count = count + 1
			CampTableIndex = CampIndex -- default index is last open zone found
		end
	end
	
	if count > 1 then -- Randomize spawn location if more than 1 remaining
		CampTableIndex = math.random ( 1, #SpawnCampsTable )
		while ( not SpawnCampsTable[CampTableIndex].is_open ) do
			CampTableIndex = math.random ( 1, #SpawnCampsTable )
		end
	elseif count == 0 then -- no open zones remaining
		msg = "++++++++++++++++++++++++++++++++++++" 
			.. "\n\nMaximum number of camp strike missions for the " 
			.. SpawnZoneRegion 
			.. " region of the map has been reached. Please try a different one."
			.. "\n\n++++++++++++++++++++++++++++++++++++"
		MESSAGE:New( msg, 10, "" ):ToAll()
		return
	end
	
	local SpawnCampZone = SpawnCampsTable[ CampTableIndex ].loc
	
	CampAttackSpawn:InitRandomizeTemplate( SpawnTemplateTable )
		:InitRandomizeUnits( true, 35, 5 )
		:InitHeading( 1,359 )
		:OnSpawnGroup(
			function( SpawnGroup )
				--local ZonePointVec2 = SpawnGroup:GetPointVec2()
				SpawnTentGroup:InitRandomizeUnits( true, 77, 35 )
					:SpawnInZone ( SpawnCampZone )
				SpawnInfGroup:InitRandomizeUnits( true, 77, 5 )
					:SpawnInZone ( SpawnCampZone )
			end 
		)
	:SpawnInZone( SpawnCampZone )

	local CampAttackBrief = "++++++++++++++++++++++++++++++++++++" 
		.."\n\nIntelligence is reporting an insurgent camp IVO "
		.. SpawnCampsTable[ CampTableIndex ].town
		.. "\n\nMission:  LOCATE AND DESTROY THE CAMP."
		.. "\n\nCoordinates:  "
		.. SpawnCampsTable[ CampTableIndex ].coords
		.. "\n\nThreats:  INFANTRY, HEAVY MG, RPG, I/R SAM, LIGHT ARMOR, AAA"
		.. "\n\n++++++++++++++++++++++++++++++++++++"
		
	MESSAGE:New( CampAttackBrief, 30, "" ):ToAll()

	SpawnCampsTable[ CampTableIndex ].is_open = false
	
end --function

function SpawnStrikeAttack ( StrikeLocation ) -- "location name"
-- TableStrikeAttack { location { striketype {Airfield, Factory, Bridge, Communications, C2}, strikeivo, strikecoords, strikemission, strikethreats, strikezone, striketargets, medzones { zone, is_open }, smallzones { zone, is_open }, defassets { sam, aaa, manpad, armour}, spawnobjects {}, is_open } 
local FuncDebug = false

	BASE:TraceOnOff( false )
	BASE:TraceAll( true )

	if TableStrikeAttack[StrikeLocation].is_open then

		local MedZonesCount = #TableStrikeAttack[StrikeLocation].medzones -- number of medium defzones
		local SmallZonesCount = #TableStrikeAttack[StrikeLocation].smallzones -- number of small defzones
		local SamQty = math.random( 2, TableStrikeAttack[StrikeLocation].defassets.sam ) -- number of SAM defences min 2
		local AaaQty = math.random( 2, TableStrikeAttack[StrikeLocation].defassets.aaa ) -- number of AAA defences min 2
		local ManpadQty = math.random( 1, TableStrikeAttack[StrikeLocation].defassets.manpad ) -- number of manpad defences 1-max spawn in AAA zones. AaaQty + ManpadQty MUST NOT exceed SmallZonesCount
		local ArmourQty = math.random( 1, TableStrikeAttack[StrikeLocation].defassets.armour ) -- number of armour groups 1-max spawn in SAM zones. SamQty + ArmourQty MUST NOT exceed MedZonesCount
		local StrikeMarkZone = ZONE:FindByName( TableStrikeAttack[StrikeLocation].strikezone ) -- ZONE object for zone named in strikezone 
		
		-- ## Check sufficient zones exist for the mission air defences
		if SamQty + ArmourQty > MedZonesCount then
			local msg = TableStrikeAttack[StrikeLocation].strikename .. " Error! SAM+Armour count exceedes medium zones count"
			MESSAGE:New ( msg, 10, "" ):ToAll()
			return
		elseif AaaQty + ManpadQty > SmallZonesCount then
			local msg = TableStrikeAttack[StrikeLocation].strikename .. " Error! AAA+MANPAD count exceedes small zones count"
			MESSAGE:New ( msg, 10, "" ):ToAll()
			return
		end

		if TableStrikeAttack[StrikeLocation].striketype == "Factory" then -- refresh the static objects in case they've been detroyed
			for index, staticname in ipairs(TableStrikeAttack[StrikeLocation].striketargets) do
				local AssetStrikeStaticName = staticname
				local AssetStrikeStatic = STATIC:FindByName( AssetStrikeStaticName )
				AssetStrikeStatic:ReSpawn( country.id.RUSSIA )
			end
		end
		
		-- ## add strike defence assets
		function AddStrikeAssets (AssetType, AssetQty, AssetZoneType, AssetZonesCount ) -- AssetType ["sam", "aaa", "manpads", "armour"], AssetQty, AssetZoneType ["med", "small"], AssetZonesCount

			local TableStrikeAssetZones = {}

			-- select indexes of zones in which to spawn assets 
			for count=1, AssetQty do 
				local zoneindex = math.random( 1, AssetZonesCount )
				if AssetZoneType == "med" then
					while ( not TableStrikeAttack[StrikeLocation].medzones[zoneindex].is_open ) do -- ensure selected zone has not been used
						zoneindex = math.random ( 1, AssetZonesCount )
					end
					TableStrikeAttack[StrikeLocation].medzones[zoneindex].is_open = false -- close samzone for selection
				else
					while ( not TableStrikeAttack[StrikeLocation].smallzones[zoneindex].is_open ) do -- ensure selected zone has not been used
						zoneindex = math.random ( 1, AssetZonesCount )
					end
					TableStrikeAttack[StrikeLocation].smallzones[zoneindex].is_open = false -- close aaazone for selection
				end
				TableStrikeAssetZones[count] = zoneindex -- add selected zone to list
				
			end

			-- spawn assets
			for count = 1, #TableStrikeAssetZones do
				-- randomise template (MOOSE removes unit orientation in template)
				local DefTemplateIndex = math.random( 1, #TableDefTemplates[AssetType] ) -- generate random index for template
				local AssetTemplate = TableDefTemplates[AssetType][DefTemplateIndex] -- select indexed template
				local AssetSpawnStub = _G["DEFSTUB_" .. AssetTemplate] -- _G[contenation for name of generated DEFSTUB_ spawn]
				local assetzoneindex = TableStrikeAssetZones[count]
				if AssetZoneType == "med" then -- medzone 
					assetspawnzone = ZONE:FindByName( TableStrikeAttack[StrikeLocation].medzones[assetzoneindex].loc ) -- _G[concatenation for name of generated spawnzone]
				else -- smallzone
					assetspawnzone = ZONE:FindByName( TableStrikeAttack[StrikeLocation].smallzones[assetzoneindex].loc ) -- _G["SPAWN" .. TableStrikeAttack[StrikeLocation].smallzones[assetzoneindex].loc]
				end
				AssetSpawnStub:SpawnInZone( assetspawnzone ) -- spawn asset in zone in generated zone list
				local assetspawngroup, assetspawngroupindex = AssetSpawnStub:GetLastAliveGroup()
				table.insert(TableStrikeAttack[StrikeLocation].spawnobjects, assetspawngroup )
			end
		end
		
		-- ## add SAM assets
		AddStrikeAssets( "sam", SamQty, "med", MedZonesCount ) -- AssetType ["sam", "aaa", "manpads", "armour"], AssetQty, AssetZoneType ["med", "small"], AssetZonesCount
		
		-- ## add AAA assets
		AddStrikeAssets( "aaa", AaaQty, "small", SmallZonesCount )
		
		-- ## add Manpad assets
		AddStrikeAssets( "manpads", ManpadQty, "small", SmallZonesCount )
		
		-- ## add armour assets
		AddStrikeAssets( "armour", ArmourQty, "med", MedZonesCount )

    -- ## Create Mission Mark on F10 map
    local StrikeMarkCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone
    local StrikeMarkLabel = TableStrikeAttack[StrikeLocation].strikename -- create label for map mark
      .. " "
      .. TableStrikeAttack[StrikeLocation].striketype
      .. " Strike" 
      .. "\n" .. TableStrikeAttack[StrikeLocation].strikecoords
    local StrikeMark = StrikeMarkCoord:MarkToAll(StrikeMarkLabel, true) -- add mark to map
    TableStrikeAttack[StrikeLocation].strikemarkid = StrikeMark -- add mark ID to table 
      		
		-- ## Send briefing message
		local strikeAttackBrief = "++++++++++++++++++++++++++++++++++++"
			..	"\n\nAir Interdiction mission against "
			.. TableStrikeAttack[StrikeLocation].strikename
			.. " "
			.. TableStrikeAttack[StrikeLocation].striketype
			.. "\n\nMission: "
			.. TableStrikeAttack[StrikeLocation].strikemission
			.. "\n\nCoordinates: "
			.. TableStrikeAttack[StrikeLocation].strikecoords
			.. "\n\nThreats:  "
			.. "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR"
			.. "\n\n++++++++++++++++++++++++++++++++++++"
			
		MESSAGE:New ( strikeAttackBrief, 30, "" ):ToAll()
		
	
		TableStrikeAttack[StrikeLocation].is_open = false -- mark strike mission as active
		
		-- ## menu: add mission remove menu command and remove mission start command
		_G["Cmd" .. StrikeLocation .. "AttackRemove"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Remove Mission", _G["Menu" .. TableStrikeAttack[StrikeLocation].striketype .. "Attack" .. StrikeLocation], RemoveStrikeAttack, StrikeLocation )
		_G["Cmd" .. StrikeLocation .. "Attack"]:Remove()
		
	else
		msg = "++++++++++++++++++++++++++++++++++++" 
			.. "\n\nThe " 
			.. TableStrikeAttack[StrikeLocation].strikename
			.. " "
			.. TableStrikeAttack[StrikeLocation].striketype
			.. " strike attack mission is already active."
			.. "\n\n++++++++++++++++++++++++++++++++++++"
		MESSAGE:New( msg, 10, "" ):ToAll()
	end

BASE:TraceOnOff( false )

end --function

-- ## Remove strike attack mission
function RemoveStrikeAttack ( StrikeLocation )
BASE:TraceOnOff( false )
BASE:TraceAll( true )

	if not TableStrikeAttack[StrikeLocation].is_open then
		local objectcount = #TableStrikeAttack[StrikeLocation].spawnobjects
		for count = 1, objectcount do
			local removespawnobject = TableStrikeAttack[StrikeLocation].spawnobjects[count]
			if removespawnobject:IsAlive() then
				
				removespawnobject:Destroy( false )
			end
		end
		
		COORDINATE:RemoveMark( TableStrikeAttack[StrikeLocation].strikemarkid ) -- remove mark from map
		
		TableStrikeAttack[StrikeLocation].strikemarkid = nil -- reset map mark ID
		TableStrikeAttack[StrikeLocation].spawnobjects = {} -- clear list of now despawned objects
		TableStrikeAttack[StrikeLocation].is_open = true -- set strike mission as available
		
		-- ## menu: add mission start menu command and remove mission remove command
		_G["Cmd" .. StrikeLocation .. "Attack"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Start Mission", _G["Menu" .. TableStrikeAttack[StrikeLocation].striketype .. "Attack" .. StrikeLocation], SpawnStrikeAttack, StrikeLocation )
		_G["Cmd" .. StrikeLocation .. "AttackRemove"]:Remove()

	else
		msg = "++++++++++++++++++++++++++++++++++++" 
			.. "\n\nThe " 
			.. StrikeLocation
			.. " strike attack mission is not active."
			.. "\n\n++++++++++++++++++++++++++++++++++++"
		MESSAGE:New( msg, 10, "" ):ToAll()
	end
BASE:TraceOnOff( false )

end --function


-- ## Remove oldest spawn in a mission
function RemoveSpawn( _args )

	local RemoveSpawnGroupTable = _args[1]

	local FirstSpawnGroup, Index = RemoveSpawnGroupTable.spawn:GetFirstAliveGroup()
	if FirstSpawnGroup then
		FirstSpawnGroup:Destroy( false )
	end
	
end --function

-- ## Remove oldest spawned group in a mission
function RemoveSpawnGroup( _args )

	for index, SpawnObject in pairs( _args ) do
		local FirstSpawnGroup, FirstSpawnIndex = SpawnObject:GetFirstAliveGroup()
		if FirstSpawnGroup then
			FirstSpawnGroup:Destroy( false )
		end
	end
	
end --function

-- ## CAMP remove spawn
function RemoveCamp( _args )

	local FirstCampGroup, Index = _args[2]:GetFirstAliveGroup()
	if FirstCampGroup then
		FirstCampGroup:Destroy( false )
	end
	
end --function


local function InList( tbl, val )

    for index, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end

    return false	

end --function


-- END UTILITY FUNCTIONS
-- BEGIN BOAT SECTION



stennisgroup = GROUP:FindByName( "CSG_CarrierGrp_Stennis" )
stennisgroup:PatrolRoute()

tarawagroup = GROUP:FindByName( "CSG_CarrierGrp_Tarawa" )
tarawagroup:PatrolRoute()



-- END BOAT SECTION
-- BEGIN SUPPORT AC SECTION



-- ## Define spawn zones with trigger zones in ME
Zone_AAR_1 = ZONE:FindByName( "AAR_1_Zone" ) 
Zone_AWACS_1 = ZONE:FindByName( "AWACS_1_Zone" )
Zone_Red_AWACS_1 = ZONE:FindByName( "RED_AWACS_1_Zone" ) 

-- ## define table of support aircraft to be spawned
-- [spawnobjectname, spawnstub, spawnzone}
TableSpawnSupport = {
	{spawnobject = "Tanker_C130_Arco1", spawnzone = Zone_AAR_1},
	{spawnobject = "Tanker_KC135_Shell1", spawnzone = Zone_AAR_1},
	{spawnobject = "AWACS_Magic", spawnzone = Zone_AWACS_1},
	{spawnobject = "RED_AWACS_108", spawnzone = Zone_Red_AWACS_1},
}

-- ## spawn support aircraft
for i, v in ipairs( TableSpawnSupport ) do
	SpawnSupport ( v )
	
end

-- ## Recovery Tanker Stennis
Spawn_Tanker_S3B_Texaco1 = RECOVERYTANKER:New( UNIT:FindByName( "CSG_CarrierGrp_Stennis"), "Tanker_S3B_Texaco1" )

Spawn_Tanker_S3B_Texaco1:SetCallsign(CALLSIGN.Tanker.Texaco, 1)
	:SetTACAN(15, "TEX")
	:SetRadio(317.775)
	:SetModex(049)
	:SetTakeoffAir()
	:Start()

-- ## Resuce Helo Stennis

Spawn_Rescuehelo_Stennis = RESCUEHELO:New(UNIT:FindByName("CSG_CarrierGrp_Stennis"), "RescueHelo_Stennis")

Spawn_Rescuehelo_Stennis:SetRespawnInAir()
  :SetHomeBase(AIRBASE:FindByName("CSG_CarrierGrp_Stennis_03"))
	:Start()

	

	
-- END SUPPORT AC SECTION
-- BEGIN RANGE SECTION



-- ## GG33 Range
local bombtarget_GG33 = {
	"RANGE_GG33_bombing_01", 
	"RANGE_GG33_bombing_02",
	"RANGE_GG33_bombing_03",
	"RANGE_GG33_bombing_04",
	"RANGE_GG33_TAC_01",
	"RANGE_GG33_TAC_02",
	"RANGE_GG33_TAC_03",
	"RANGE_GG33_TAC_04",
	"RANGE_GG33_TAC_05",
	"RANGE_GG33_TAC_06",
	"RANGE_GG33_TAC_07",
	"RANGE_GG33_TAC_08",
	"RANGE_GG33_TAC_09",
	"RANGE_GG33_TAC_10",
	"RANGE_GG33_TAC_11",
	"RANGE_GG33_TAC_12",
	"RANGE_GG33_TAC_13",
	"RANGE_GG33_TAC_14",
	"RANGE_GG33_TAC_15"
}

local strafepit_GG33 = {
	"RANGE_GG33_Strafepit_A",
	"RANGE_GG33_Strafepit_B"
}

Range_GG33 = RANGE:New( "GG33 Range" )
fouldist_GG33 = Range_GG33:GetFoullineDistance( "RANGE_GG33_Strafepit_A", "RANGE_GG33_FoulLine_AB" )
Range_GG33:AddStrafePit( strafepit_GG33, 3000, 300, nil, true, 20, fouldist_GG33 )
Range_GG33:AddBombingTargets( bombtarget_GG33, 50 )
Range_GG33:Start()

-- ## NL24 Range
local bombtarget_NL24={
	"RANGE_NL24_NORTH_bombing", 
	"RANGE_NL24_SOUTH_bombing",
	"RANGE_NL24_TAC_01",
	"RANGE_NL24_TAC_02",
	"RANGE_NL24_TAC_03",
	"RANGE_NL24_TAC_04",
	"RANGE_NL24_TAC_05",
	"RANGE_NL24_TAC_06",
	"RANGE_NL24_TAC_07",
	"RANGE_NL24_TAC_08",
	"RANGE_NL24_TAC_09",
	"RANGE_NL24_TAC_10"
}

local strafepit_NL24_NORTH={
	"RANGE_NL24_strafepit_A",
	"RANGE_NL24_strafepit_B"
}

local strafepit_NL24_SOUTH={
	"RANGE_NL24_strafepit_C",
	"RANGE_NL24_strafepit_D"
}

Range_NL24 = RANGE:New( "NL24 Range" )
fouldist_NL24 = Range_NL24:GetFoullineDistance( "RANGE_NL24_strafepit_A", "RANGE_NL24_FoulLine_AB" )
Range_NL24:AddStrafePit( strafepit_NL24_NORTH, 3000, 300, nil, true, 20, fouldist_NL24 )
Range_NL24:AddStrafePit( strafepit_NL24_SOUTH, 3000, 300, nil, true, 20, fouldist_NL24 )
Range_NL24:AddBombingTargets( bombtarget_NL24, 50 )
Range_NL24:Start()



-- END RANGE SECTION
-- BEGIN CAP SECTION



-- Each CAP Location requires a Zone
-- CAP objects will be spawned at a random postion within the zone
-- A host aircraft ( late activation ) must be placed at each location
-- AICapZone is used to set the patrol and engage zones
-- On Spawning, the host will be replaced with a goup selected radomly from a list of templates


-- ## CAP spawn stubs
MaykopCapSpawn = SPAWN:New( "MaykopCap" )
BeslanCapSpawn = SPAWN:New( "BeslanCap" )

-- ## CAP spawn zones
MaykopCapSpawnZone = ZONE:New( "ZONE_MaykopCapSpawn" )
BeslanCapSpawnZone = ZONE:New( "ZONE_BeslanCapSpawn" )

-- ## CAP spawn templates
CapTemplates = {
	"Russia_Mig29",
	"Russia_Mig21",
	"Russia_Su27"
}

-- ## AICapzone patrol and engage zones
WestCapPatrolGroup = GROUP:FindByName( "PolyPatrolWest" )
WestCapPatrolZone = ZONE_POLYGON:New( "ZONE_PatrolWest", WestCapPatrolGroup )
WestCapEngageGroup = GROUP:FindByName( "PolyEngageWest" )
WestCapEngageZone = ZONE_POLYGON:New( "ZONE_EngageWest", WestCapEngageGroup )

EastCapPatrolGroup = GROUP:FindByName( "PolyPatrolEast" )
EastCapPatrolZone = ZONE_POLYGON:New( "ZONE_PatrolEast", WestCapPatrolGroup )
EastCapEngageGroup = GROUP:FindByName( "PolyEngageEast" )
EastCapEngageZone = ZONE_POLYGON:New( "ZONE_EngageEast", EastCapEngageGroup )

-- ## table containing CAP spawn config per location 
CapTable = { -- spawn location, { spawn, spawnzone, templates, patrolzone, engagerange } ...
	maykop = { 
		spawn = MaykopCapSpawn, spawnzone = MaykopCapSpawnZone, templates = CapTemplates, patrolzone = WestCapPatrolZone, engagerange = 100000
	},
	beslan = { 
		spawn = BeslanCapSpawn, spawnzone = BeslanCapSpawnZone, templates = CapTemplates, patrolzone = EastCapPatrolZone, engagerange = 100000
	},
}

-- ## Maykop CAP
-- spawn, spawnzone, templates, patrolzone, aicapzone, engagerange 
_maykop_args = { -- args passed to spawn menu option
	CapTable.maykop,
}

CmdMaykopCap = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Spawn Maykop CAP", MenuCapMaykop, SpawnCap, _maykop_args ) -- Spawn CAP flight
CmdMaykopCapRemove = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Remove Oldest Maykop CAP", MenuCapMaykop, RemoveSpawn, _maykop_args ) -- Remove the oldest CAP flight for location

-- ## Beslan CAP
_beslan_args = { 
	CapTable.beslan,
}

CmdBeslanCap = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Spawn Beslan CAP", MenuCapBeslan, SpawnCap, _beslan_args ) 
CmdBeslanCapRemove = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Remove oldest Beslan CAP", MenuCapBeslan, RemoveSpawn, _beslan_args )




-- END CAP SECTION
-- BEGIN CAMP ATTACK SECTION



-- ## table containing camp spawns per location
TableCamps = { -- map portion, { camp zone, nearest town, Lat Long, spawned status } ...
	east = {
		{ 
			loc = ZONE:New("ZoneCampEast01"), 
			town = "Kvemo-Sba", 
			coords = "42  34  02 N | 044  10  20 E", 
			is_open = true 
		},
		{ 
			loc = ZONE:New("ZoneCampEast02"), 
			town = "Kvemo-Roka", 
			coords = "42  32  48 N | 044  07  01 E", 
			is_open = true 
		}, 
		{ 
			loc = ZONE:New("ZoneCampEast03"), 
			town = "Edisa", 
			coords = "42  32  21 N | 044  12  10 E", 
			is_open = true 
		},
		{ 
			loc = ZONE:New("ZoneCampEast04"), 
			town = "Kvemo-Khoshka", 
			coords = "42  27  07 N | 044  03  25 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampEast05"), 
			town = "Elbakita", 
			coords = "42  25  24 N | 044  00  40 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampEast06"), 
			town = "Tsru", 
			coords = "42  22  50 N | 044  01  55 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampEast07"), 
			town = "Didi-Gupta", 
			coords = "42  21 11 N | 043  54  18 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampEast08"), 
			town = "Kekhvi", 
			coords = "42  19  10 N | 043  56  09 E", 
			is_open = true
		}
	},
	central = {
		{ 
			loc = ZONE:New("ZoneCampCentral01"), 
			town = "Oni", 
			coords = "42  35  53 N | 043  27  13 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampCentral02"), 
			town = "Kvashkhieti", 
			coords = "42  32  49 N | 043  23  10 E", 
			is_open = true
		}, 
		{ 
			loc = ZONE:New("ZoneCampCentral03"), 
			town = "Haristvala", 
			coords = "42  23  46 N | 043  02  27 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampCentral04"), 
			town = "Ahalsopeli", 
			coords = "42  18  11 N | 042  56  57 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampCentral05"), 
			town = "Mohva", 
			coords = "42  22  35 N | 043  21  24 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampCentral06"), 
			town = "Sadmeli", 
			coords = "42  32  05 N | 043  06  36 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampCentral07"), 
			town = "Zogishi", 
			coords = "42  33  36 N | 042  51  18 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampCentral08"), 
			town = "Namohvani", 
			coords = "42  41  39 N | 042  41  39 E", 
			is_open = true
		},
	},
	west = {
		{ 
			loc = ZONE:New("ZoneCampWest01"), 
			town = "Dzhvari", 
			coords = "42  43  01 N | 042  02  08 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampWest02"), 
			town = "Tkvarcheli", 
			coords = "42  51  45 N | 041  46  29 E", 
			is_open = true
		}, 
		{ 
			loc = ZONE:New("ZoneCampWest03"), 
			town = "Zemo-Azhara", 
			coords = "43 06 26 N | 041  44 04 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampWest04"), 
			town = "Amtkel", 
			coords = "43  02  05 N | 041  27  16 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampWest05"), 
			town = "Gora Mukhursha", 
			coords = "43  19  16 N | 040  52  24 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampWest06"), 
			town = "Ozero Ritsa", 
			coords = "43  28  17 N | 040  32  01 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampWest07"), 
			town = "Salhino", 
			coords = "43  31  37 N | 040  05  31 E", 
			is_open = true
		},
		{ 
			loc = ZONE:New("ZoneCampWest08"), 
			town = "Leselidze", 
			coords = "43  23  56 N | 040  00  35 E", 
			is_open = true
		},
	}
}


-- ## Camp spawn stubs
CampAttackSpawn = SPAWN:New( "CAMP_Heavy" )
SpawnTent = SPAWN:New( "CAMP_Tent_01" )
SpawnHouse01 = SPAWN:New( "CAMP_House_01" )
SpawnHouse02 = SPAWN:New( "CAMP_House_02" )
SpawnHouse03 = SPAWN:New( "CAMP_House_03" )
SpawnHouse04 = SPAWN:New( "CAMP_House_04" )
SpawnHouse05 = SPAWN:New( "CAMP_House_05" )  
SpawnTower = SPAWN:New( "CAMP_Tower_01" )
SpawnInfSingle = SPAWN:New( "CAMP_Inf_01" )

SpawnTentGroup = SPAWN:New( "CAMP_Tent_Group" )
SpawnInfGroup = SPAWN:New( "CAMP_Inf_02" )

-- ## Camp spawn templates
ArmourTemplates = {
	"CAMP_Heavy_01",
	"CAMP_Heavy_02",
	"CAMP_Heavy_03",
	"CAMP_Heavy_04"
} 

-- ## East Zones
_east_args = {
	ArmourTemplates,
	TableCamps.east,
	"East"
}

cmdCampAttackEast = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Eastern Zone",MenuCampAttack,SpawnCamp, _east_args )

-- ## Central Zones
_central_args = {
	ArmourTemplates,
	TableCamps.central,
	"Central"
}
cmdCampAttackCentral = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Central Zone",MenuCampAttack,SpawnCamp, _central_args )

-- ## West Zones
 _West_args = {
	ArmourTemplates,
	TableCamps.west,
	"West"
}
cmdCampAttackWest = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Western Zone",MenuCampAttack,SpawnCamp, _West_args )


-- ## To Do Remove oldest Camp Attack mission
_campattackremove_args = { 
	CampAttackSpawn,
	SpawnTentGroup,
	SpawnInfGroup
}

--cmdCampAttackRemove = MENU_COALITION_COMMAND:New( coalition.side.BLUE, " Remove oldest mission", MenuCampAttack, RemoveSpawnGroup, _campattackremove_args )



-- END CAMP ATTACK SECTION
-- BEGIN CONVOY ATTACK SECTION

-- ## Able Sentry Convoy
-- Convoy is spawned at mission start and will advance North->South on highway B3 towards Tbilisi
-- On reaching Mtskehta it will respawn at the start of the route.
Zone_ConvoyObjectiveAbleSentry = ZONE:New( "ConvoyObjectiveAbleSentry" ) 

Spawn_Convoy_AbleSentry = SPAWN:New( "CONVOY_Hard_Able Sentry" )
	:InitLimit( 20, 50 )
	:OnSpawnGroup(
		function ( SpawnGroup )
			SpawnIndex_Convoy_AbleSentry = Spawn_Convoy_AbleSentry:GetSpawnIndexFromGroup( SpawnGroup )
			Check_Convoy_AbleSentry = SCHEDULER:New( nil, 
			function()
				if SpawnGroup:IsPartlyInZone( Zone_ConvoyObjectiveAbleSentry ) then
					Spawn_Convoy_AbleSentry:ReSpawn( SpawnIndex_Convoy_AbleSentry )
				end
			end,
			{}, 0, 60 )
		end
	)
	:SpawnScheduled( 60 , .1 )

function ResetAbleSentry()
	Spawn_Convoy_AbleSentry:ReSpawn(SpawnIndex_Convoy_AbleSentry)	
end -- function

cmdConvoyAbleSentryReset = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Able Sentry Reset",MenuConvoyAttack, ResetAbleSentry )


-- ## On-demand convoy missions 


SpawnConvoys = { -- map portion, { spawn host, nearest town, Lat Long, destination zone, spawned status } ...
	west = {
		{ 
			conv = SPAWN:New( "CONVOY_01" ), 
			dest = "Gudauta Airfield", 
			destzone = ZONE:New("ConvoyObjective_01"), 
			coords = "43  21  58 N | 040  06  31 E", 
			is_open = true
		},
		{ 
			conv = SPAWN:New( "CONVOY_02" ), 
			dest = "Gudauta Airfield", 
			destzone = ZONE:New("ConvoyObjective_01"), 
			coords = "43  27  58 N | 040  32  34 E", 
			is_open = true
		},
		{ 
			conv = 
			SPAWN:New( "CONVOY_03" ), 
			dest = "Sukhumi Airfield", 
			destzone = ZONE:New("ConvoyObjective_02"), 
			coords = "43  02  07 N | 041  27  14 E", 
			is_open = true
		},
		{ 
			conv = SPAWN:New( "CONVOY_04" ), 
			dest = "Sukhumi Airfield", 
			destzone = ZONE:New("ConvoyObjective_02"), 
			coords = "42  51  35 N | 041  46  39 E", 
			is_open = true
		},
	},
	central = {
		{ 
			conv = SPAWN:New( "CONVOY_05" ), 
			dest = "Kutaisi Airfield", 
			destzone = ZONE:New("ConvoyObjective_03"), 
			coords = "42  33  39 N | 042  51  17 E", 
			is_open = true
		},
		{ 
			conv = SPAWN:New( "CONVOY_06" ), 
			dest = "Kutaisi Airfield", 
			destzone = ZONE:New("ConvoyObjective_03"), 
			coords = "42  23  52 N | 043  02  27 E", 
			pen = true
		},
		{ 
			conv = SPAWN:New( "CONVOY_07" ), 
			dest = "Khashuri", 
			destzone = ZONE:New("ConvoyObjective_04"), 
			coords = "42  19  59 N | 043  23  08 E", 
			is_open = true
		},
		{ 
			conv = SPAWN:New( "CONVOY_08" ), 
			dest = "Khashuri", 
			destzone = ZONE:New("ConvoyObjective_04"), 
			coords = "42  19  05 N | 043  56  01 E", 
			is_open = true
		},
	}
}

ConvoyAttackSpawn = SPAWN:New( "CONVOY_Default" )

ConvoyHardTemplates = {
	"CONVOY_Hard_01",
	"CONVOY_Hard_02",
}
ConvoySoftTemplates = {
	"CONVOY_Soft_01",
	"CONVOY_Soft_02",
}

HardType = "Armoured"
SoftType = "Supply"
HardThreats = "\n\nThreats:  MBT, Radar SAM, I/R SAM, LIGHT ARMOR, AAA"
SoftThreats = "\n\nThreats:  LIGHT ARMOR, Radar SAM, I/R SAM, AAA"

-- ## Central Zones
_hard_central_args = {
	ConvoyHardTemplates,
	SpawnConvoys.central,
	HardType,
	HardThreats
}
cmdConvoyAttackHardCentral = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Armoured Convoy",MenuConvoyAttackCentral, SpawnConvoy, _hard_central_args )

_soft_central_args = {
	ConvoySoftTemplates,
	SpawnConvoys.central,
	SoftType,
	SoftThreats
}
cmdConvoyAttackSoftCentral = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Supply Convoy",MenuConvoyAttackCentral, SpawnConvoy, _soft_central_args )

-- ## West Zones
_hard_west_args = {
	ConvoyHardTemplates,
	SpawnConvoys.west,
	HardType,
	HardThreats
}
cmdConvoyAttackHardWest = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Armoured Convoy",MenuConvoyAttackWest, SpawnConvoy, _hard_west_args )

_soft_west_args = {
	ConvoySoftTemplates,
	SpawnConvoys.west,
	SoftType,
	SoftThreats
}
cmdConvoyAttackSoftWest = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Supply Convoy",MenuConvoyAttackWest, SpawnConvoy, _soft_west_args )



	
-- END CONVOY ATTACK SECTION
--BEGIN STRIKE ATTACK SECTION	



-- TableStrikeAttack { location { striketype {Airfield, Factory, Bridge}, strikename, strikeivo, strikecoords, strikemission, strikethreats, strikezone, striketargets, medzones { zone, is_open }, smallzones { zone, is_open }, defassets { sam, aaa, manpad, armour}, spawnobjects {}, is_open } 
TableStrikeAttack = {
	Beslan = { 																		-- location key
		striketype = "Airfield", 													-- (Airfield, Factory, Bridge, Communications, C2)
		strikename = "Beslan",														-- Firendly name for the locaiton used in briefings, menus etc. Currently the same as the key, but will probably change
		strikeivo = "AFB",															-- "in the vacinity of" ("AFB" if airfield, "[TOWN/CITY]" other targets)
		strikecoords = "43  12  20 N | 044  36  20 E", 								-- LatLong
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND", 	-- text mission
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",					-- text threats
		strikezone = "ZONE_BeslanStrike",											-- zone at center of strike location
		striketargets = {															-- static objects to be respawned for object point strikes (Factory, refinery etc)
		},
		medzones = {																-- ME zones in which medium assets will be spawned. (AAA batteries, vehicle groups, infantry groups etc) 
			{ loc = "ZONE_BeslanMed_01", is_open = true },							-- loc = name of mission defence ME zone. is-open tracks whether zone is occupied
			{ loc = "ZONE_BeslanMed_02", is_open = true },
			{ loc = "ZONE_BeslanMed_03", is_open = true },
			{ loc = "ZONE_BeslanMed_04", is_open = true },
			{ loc = "ZONE_BeslanMed_05", is_open = true },
			{ loc = "ZONE_BeslanMed_06", is_open = true },
			{ loc = "ZONE_BeslanMed_07", is_open = true },
			{ loc = "ZONE_BeslanMed_08", is_open = true },
			{ loc = "ZONE_BeslanMed_09", is_open = true },
			{ loc = "ZONE_BeslanMed_10", is_open = true },
		},
		smallzones = {																-- ME zones in which small assets will be spawned
			{ loc = "ZONE_BeslanSmall_01", is_open = true },
			{ loc = "ZONE_BeslanSmall_02", is_open = true },
			{ loc = "ZONE_BeslanSmall_03", is_open = true },
			{ loc = "ZONE_BeslanSmall_04", is_open = true },
			{ loc = "ZONE_BeslanSmall_05", is_open = true },
			{ loc = "ZONE_BeslanSmall_06", is_open = true },
			{ loc = "ZONE_BeslanSmall_07", is_open = true },
			{ loc = "ZONE_BeslanSmall_08", is_open = true },
			{ loc = "ZONE_BeslanSmall_09", is_open = true },
			{ loc = "ZONE_BeslanSmall_10", is_open = true },
		},
		defassets = { 																-- max number of each defence asset. sum of zone types used must not exceed number of zone type available
			sam = 4,																-- uses medzones
			aaa = 5,																-- uses smallzones
			manpad = 3,																-- uses smallzones
			armour = 3,																-- uses medzones
		},
		spawnobjects = {},															-- table holding names of the spawned objects relating the mission.
		is_open = true,																-- mission status. true if mission is avilable for spawning. false if it is in-progress
	},
	Sochi = { -- Airfield
		striketype = "Airfield",
		strikename = "Sochi",
		strikeivo = "AFB",
		strikecoords = "43  26  41 N | 039  56  32 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_SochiStrike",
		striketargets = {
		},
		medzones = {
			{ loc = "ZONE_SochiMed_01", is_open = true },
			{ loc = "ZONE_SochiMed_02", is_open = true },
			{ loc = "ZONE_SochiMed_03", is_open = true },
			{ loc = "ZONE_SochiMed_04", is_open = true },
			{ loc = "ZONE_SochiMed_05", is_open = true },
			{ loc = "ZONE_SochiMed_06", is_open = true },
			{ loc = "ZONE_SochiMed_07", is_open = true },
			{ loc = "ZONE_SochiMed_08", is_open = true },
			{ loc = "ZONE_SochiMed_09", is_open = true },
			{ loc = "ZONE_SochiMed_10", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_SochiSmall_01", is_open = true },
			{ loc = "ZONE_SochiSmall_02", is_open = true },
			{ loc = "ZONE_SochiSmall_03", is_open = true },
			{ loc = "ZONE_SochiSmall_04", is_open = true },
			{ loc = "ZONE_SochiSmall_05", is_open = true },
			{ loc = "ZONE_SochiSmall_06", is_open = true },
			{ loc = "ZONE_SochiSmall_07", is_open = true },
			{ loc = "ZONE_SochiSmall_08", is_open = true },
			{ loc = "ZONE_SochiSmall_09", is_open = true },
			{ loc = "ZONE_SochiSmall_10", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},
	Maykop = { -- Airfield
		striketype = "Airfield",
		strikename = "Maykop",
		strikeivo = "AFB",
		strikecoords = "44  40  54 N | 040  02  08 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MaykopStrike",
		striketargets = {
		},
		medzones = {
			{ loc = "ZONE_MaykopMed_01", is_open = true },
			{ loc = "ZONE_MaykopMed_02", is_open = true },
			{ loc = "ZONE_MaykopMed_03", is_open = true },
			{ loc = "ZONE_MaykopMed_04", is_open = true },
			{ loc = "ZONE_MaykopMed_05", is_open = true },
			{ loc = "ZONE_MaykopMed_06", is_open = true },
			{ loc = "ZONE_MaykopMed_07", is_open = true },
			{ loc = "ZONE_MaykopMed_08", is_open = true },
			{ loc = "ZONE_MaykopMed_09", is_open = true },
			{ loc = "ZONE_MaykopMed_10", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_MaykopSmall_01", is_open = true },
			{ loc = "ZONE_MaykopSmall_02", is_open = true },
			{ loc = "ZONE_MaykopSmall_03", is_open = true },
			{ loc = "ZONE_MaykopSmall_04", is_open = true },
			{ loc = "ZONE_MaykopSmall_05", is_open = true },
			{ loc = "ZONE_MaykopSmall_06", is_open = true },
			{ loc = "ZONE_MaykopSmall_07", is_open = true },
			{ loc = "ZONE_MaykopSmall_08", is_open = true },
			{ loc = "ZONE_MaykopSmall_09", is_open = true },
			{ loc = "ZONE_MaykopSmall_10", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},
	Nalchik = { -- Airfield
		striketype = "Airfield",
		strikename = "Nalchik",
		strikeivo = "AFB",
		strikecoords = "43  30  53 N | 043  38  17 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_NalchikStrike",
		striketargets = {
		},
		medzones = {
			{ loc = "ZONE_NalchikMed_01", is_open = true },
			{ loc = "ZONE_NalchikMed_02", is_open = true },
			{ loc = "ZONE_NalchikMed_03", is_open = true },
			{ loc = "ZONE_NalchikMed_04", is_open = true },
			{ loc = "ZONE_NalchikMed_05", is_open = true },
			{ loc = "ZONE_NalchikMed_06", is_open = true },
			{ loc = "ZONE_NalchikMed_07", is_open = true },
			{ loc = "ZONE_NalchikMed_08", is_open = true },
			{ loc = "ZONE_NalchikMed_09", is_open = true },
			{ loc = "ZONE_NalchikMed_10", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_NalchikSmall_01", is_open = true },
			{ loc = "ZONE_NalchikSmall_02", is_open = true },
			{ loc = "ZONE_NalchikSmall_03", is_open = true },
			{ loc = "ZONE_NalchikSmall_04", is_open = true },
			{ loc = "ZONE_NalchikSmall_05", is_open = true },
			{ loc = "ZONE_NalchikSmall_06", is_open = true },
			{ loc = "ZONE_NalchikSmall_07", is_open = true },
			{ loc = "ZONE_NalchikSmall_08", is_open = true },
			{ loc = "ZONE_NalchikSmall_09", is_open = true },
			{ loc = "ZONE_NalchikSmall_10", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},
	MN76 = { -- Factory strike
		striketype = "Factory",
		strikename = "MN76",
		strikeivo = "Vladikavkaz",
		strikecoords = "43  00  23 N | 044  39  02 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND ANCILLIARY SUPPORT INFRASTRUCTURE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MN76Strike",
		striketargets = {
			"FACTORY_MN76_01",
			"FACTORY_MN76_02",
			"FACTORY_MN76_03",
			"FACTORY_MN76_04",
			"FACTORY_MN76_05",
		},
		medzones = {
			{ loc = "ZONE_MN76Med_01", is_open = true },
			{ loc = "ZONE_MN76Med_02", is_open = true },
			{ loc = "ZONE_MN76Med_03", is_open = true },
			{ loc = "ZONE_MN76Med_04", is_open = true },
			{ loc = "ZONE_MN76Med_05", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_MN76Small_01", is_open = true },
			{ loc = "ZONE_MN76Small_02", is_open = true },
			{ loc = "ZONE_MN76Small_03", is_open = true },
			{ loc = "ZONE_MN76Small_04", is_open = true },
			{ loc = "ZONE_MN76Small_05", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	LN83 = { -- Factory strike
		striketype = "Factory",
		strikename = "LN83",
		strikeivo = "Chiora",
		strikecoords = "42  44  56 N | 043  32  28 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LN83Strike",
		striketargets = {
			"FACTORY_LN83_01",
			"FACTORY_LN83_02",
		},
		medzones = {
			{ loc = "ZONE_LN83Med_01", is_open = true },
			{ loc = "ZONE_LN83Med_02", is_open = true },
			{ loc = "ZONE_LN83Med_03", is_open = true },
			{ loc = "ZONE_LN83Med_04", is_open = true },
			{ loc = "ZONE_LN83Med_05", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_LN83Small_01", is_open = true },
			{ loc = "ZONE_LN83Small_02", is_open = true },
			{ loc = "ZONE_LN83Small_03", is_open = true },
			{ loc = "ZONE_LN83Small_04", is_open = true },
			{ loc = "ZONE_LN83Small_05", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	LN77 = { -- Factory strike
		striketype = "Factory",
		strikename = "LN77",
		strikeivo = "Verh.Balkaria",
		strikecoords = "43  07  35 N | 043  27  24 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND COMMUNICATIONS INFRASTRUCTURE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LN77Strike",
		striketargets = {
      "FACTORY_LN77_01",
      "FACTORY_LN77_02",
      "FACTORY_LN77_03",
      "FACTORY_LN77_04",
		},
		medzones = {
			{ loc = "ZONE_LN77Med_01", is_open = true },
			{ loc = "ZONE_LN77Med_02", is_open = true },
			{ loc = "ZONE_LN77Med_03", is_open = true },
			{ loc = "ZONE_LN77Med_04", is_open = true },
			{ loc = "ZONE_LN77Med_05", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_LN77Small_01", is_open = true },
			{ loc = "ZONE_LN77Small_02", is_open = true },
			{ loc = "ZONE_LN77Small_03", is_open = true },
			{ loc = "ZONE_LN77Small_04", is_open = true },
			{ loc = "ZONE_LN77Small_05", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 2, 
			aaa = 3, 
			manpad = 1, 
			armour = 3, 
		},
		spawnobjects = {},
		is_open = true,
	},
	LP30 = { -- Factory strike
		striketype = "Factory",
		strikename = "LP30",
		strikeivo = "Tyrnyauz",
		strikecoords = "43  23  43 N | 042  55  27 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND COMMUNICATIONS INFRASTRUCTURE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LP30Strike",
		striketargets = {
			"FACTORY_LP30_01",
			"FACTORY_LP30_02",
			"FACTORY_LP30_03",
			"FACTORY_LP30_04",
		},
		medzones = {
			{ loc = "ZONE_LP30Med_01", is_open = true },
			{ loc = "ZONE_LP30Med_02", is_open = true },
			{ loc = "ZONE_LP30Med_03", is_open = true },
			{ loc = "ZONE_LP30Med_04", is_open = true },
			{ loc = "ZONE_LP30Med_05", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_LP30Small_01", is_open = true },
			{ loc = "ZONE_LP30Small_02", is_open = true },
			{ loc = "ZONE_LP30Small_03", is_open = true },
			{ loc = "ZONE_LP30Small_04", is_open = true },
			{ loc = "ZONE_LP30Small_05", is_open = true },
			{ loc = "ZONE_LP30Small_06", is_open = true },
			{ loc = "ZONE_LP30Small_07", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	GJ38 = { -- Bridge strike
		striketype = "Bridge",
		strikename = "GJ38",
		strikeivo = "Ust Dzheguta",
		strikecoords = "DMPI A 44  04  38 N | 041  58  15 E\n\nDMPI B 44  04  23 N | 041  58  34 E",
		strikemission = "DESTROY ROAD BRIDGE DMPI A AND\nRAIL BRIDGE DMPI B",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ38Strike",
		striketargets = {
			"FACTORY_GJ38_01",
			"FACTORY_GJ38_02",
			"FACTORY_GJ38_03",
			"FACTORY_GJ38_04",
		},
		medzones = {
			{ loc = "ZONE_GJ38Med_01", is_open = true },
			{ loc = "ZONE_GJ38Med_02", is_open = true },
			{ loc = "ZONE_GJ38Med_03", is_open = true },
			{ loc = "ZONE_GJ38Med_04", is_open = true },
			{ loc = "ZONE_GJ38Med_05", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_GJ38Small_01", is_open = true },
			{ loc = "ZONE_GJ38Small_02", is_open = true },
			{ loc = "ZONE_GJ38Small_03", is_open = true },
			{ loc = "ZONE_GJ38Small_04", is_open = true },
			{ loc = "ZONE_GJ38Small_05", is_open = true },
			{ loc = "ZONE_GJ38Small_06", is_open = true },
			{ loc = "ZONE_GJ38Small_07", is_open = true },
			{ loc = "ZONE_GJ38Small_08", is_open = true },
			{ loc = "ZONE_GJ38Small_09", is_open = true },
			{ loc = "ZONE_GJ38Small_10", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 2, 
			aaa = 4, 
			manpad = 3, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	MN72 = { -- Bridge strike
		striketype = "Bridge",
		strikename = "MN72",
		strikeivo = "Kazbegi",
		strikecoords = "44  04  38 N | 041  58  15 E",
		strikemission = "DESTROY ROAD BRIDGE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MN72Strike",
		striketargets = {
			"FACTORY_LP30_01",
			"FACTORY_LP30_02",
			"FACTORY_LP30_03",
			"FACTORY_LP30_04",
		},
		medzones = {
			{ loc = "ZONE_MN72Med_01", is_open = true },
			{ loc = "ZONE_MN72Med_02", is_open = true },
			{ loc = "ZONE_MN72Med_03", is_open = true },
			{ loc = "ZONE_MN72Med_04", is_open = true },
			{ loc = "ZONE_MN72Med_05", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_MN72Small_01", is_open = true },
			{ loc = "ZONE_MN72Small_02", is_open = true },
			{ loc = "ZONE_MN72Small_03", is_open = true },
			{ loc = "ZONE_MN72Small_04", is_open = true },
			{ loc = "ZONE_MN72Small_05", is_open = true },
			{ loc = "ZONE_MN72Small_06", is_open = true },
			{ loc = "ZONE_MN72Small_07", is_open = true },
			{ loc = "ZONE_MN72Small_08", is_open = true },
			{ loc = "ZONE_MN72Small_09", is_open = true },
			{ loc = "ZONE_MN72Small_10", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 2, 
			aaa = 4, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	GJ21 = { -- Bridge strike
		striketype = "Bridge",
		strikename = "GJ21",
		strikeivo = "Teberda",
		strikecoords = "43  26  47 N | 041  44  28 E",
		strikemission = "DESTROY ROAD BRIDGE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ21Strike",
		striketargets = {
			"FACTORY_LP30_01",
			"FACTORY_LP30_02",
			"FACTORY_LP30_03",
			"FACTORY_LP30_04",
		},
		medzones = {
			{ loc = "ZONE_GJ21Med_01", is_open = true },
			{ loc = "ZONE_GJ21Med_02", is_open = true },
			{ loc = "ZONE_GJ21Med_03", is_open = true },
			{ loc = "ZONE_GJ21Med_04", is_open = true },
			{ loc = "ZONE_GJ21Med_05", is_open = true },
		},
		smallzones = {
			{ loc = "ZONE_GJ21Small_01", is_open = true },
			{ loc = "ZONE_GJ21Small_02", is_open = true },
			{ loc = "ZONE_GJ21Small_03", is_open = true },
			{ loc = "ZONE_GJ21Small_04", is_open = true },
			{ loc = "ZONE_GJ21Small_05", is_open = true },
			{ loc = "ZONE_GJ21Small_06", is_open = true },
			{ loc = "ZONE_GJ21Small_07", is_open = true },
			{ loc = "ZONE_GJ21Small_08", is_open = true },
			{ loc = "ZONE_GJ21Small_09", is_open = true },
			{ loc = "ZONE_GJ21Small_10", is_open = true },
		},
		defassets = { -- max number of each defence asset
			sam = 2, 
			aaa = 4, 
			manpad = 1, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
}

-- ## generate defence zones
-- for strikekey, strikevalue in pairs(TableStrikeAttack) do
--[[
    -- Strike zone
    --local strikezonename = strikevalue.strikezone
    --local zonestrikezonename = "ZONE" .. strikezonename
    --_G[ zonestrikezonename ] = ZONE:New( strikezonename )
		--
		 
		-- SAM zones
		for count = 1, #strikevalue.medzones do
				local samzonename = strikevalue.medzones[ count ].loc
				local samspawnzonename = "SPAWN" .. samzonename
				_G[ samspawnzonename ] = ZONE:New( samzonename )
		end

		-- AAA zones
		for count = 1, #strikevalue.smallzones do
				local aaazonename = strikevalue.smallzones[ count ].loc
				local aaaspawnzonename = "SPAWN" .. aaazonename
				_G[ aaaspawnzonename ] = ZONE:New( aaazonename )
		end
end
--]]

-- ## strike Defence spawn templates
TableDefTemplates = {
	sam = {
		"SAM_Sa3Battery",
		"SAM_Sa6Battery",
	},
	aaa = {
		"AAA_Zu23Ural",
		"AAA_Zu23Emplacement",
		"AAA_Zu23Closed",
		"AAA_Zsu23Shilka",
	},
	manpads = {
		"SAM_Sa18Manpads",
		"SAM_Sa18sManpads",
	},
	armour = {
		"CAMP_Heavy_01",
		"CAMP_Heavy_02",
		"CAMP_Heavy_03",
		"CAMP_Heavy_04",
	},
}

-- ## generate strike defence spawn stubs
StrikeAttackSpawn = SPAWN:New( "DEF_Stub" )

for k, v in pairs(TableDefTemplates) do
	for count = 1, #v do
			local templatename = v[ count ]
			local stubname = "DEFSTUB_" .. templatename
			_G[ stubname ] = SPAWN:New( templatename )
	end
end

TableStaticTemplates = {
	target = {
		"FACTORY_Workshop",
		"FACTORY_Techcombine",
	},
	buildings = {
		
	},
}

-- ## generate strike attack sub menus

for strikekey, strikevalue in pairs(TableStrikeAttack) do -- step through TableStrikeAttack and grab the mission data for each key ( = "location")

	local StrikeType = strikevalue.striketype
	local StrikeLocation = strikevalue.strikename
	local StrikeIvo = strikevalue.strikeivo

	_G["Menu" .. StrikeType .. "Attack" .. StrikeLocation] = MENU_COALITION:New( coalition.side.BLUE, StrikeLocation .. " " .. StrikeIvo, _G["Menu" .. StrikeType .. "Attack"] ) -- add menu for each mission location in the correct strike type sub menu
	_G["Cmd" .. StrikeLocation .. "Attack"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Start Mission", _G["Menu" .. StrikeType .. "Attack" .. StrikeLocation], SpawnStrikeAttack, StrikeLocation ) -- add menu command to launch the mission

end



-- END strike ATTACK SECTION	



env.info( '*** CSG-1 MOOSE MISSION SCRIPT END *** ' )
