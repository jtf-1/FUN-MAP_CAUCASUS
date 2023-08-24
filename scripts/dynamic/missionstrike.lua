env.info( "[JTF-1] mission_strike" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN MISSIONSTRIKE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

MISSIONSTRIKE = {}
MISSIONSTRIKE.traceTitle = "[JTF-1 MISSIONSTRIKE] "

MISSIONSTRIKE.menu = {} -- MISSIONSTRIKE menus container
MISSIONSTRIKE.spawn = {} -- MISSIONSTRIKE spawn objects container

-- start MISSIONSTRIKE module
function MISSIONSTRIKE:Start()
	_msg = self.traceTitle .. "Start()"
	BASE:T(_msg)

	-- add main menus
	self.menu.top = MENU_COALITION:New( coalition.side.BLUE, "Strike Missions" )

	--- generate strike defence spawn stubs ---
	for k, v in pairs(TableDefTemplates) do
		for count = 1, #v do
				local templatename = v[ count ]
				local stubname = "DEFSTUB_" .. templatename
				self.spawn[ stubname ] = SPAWN:New( templatename )
		end
	end

	--- menu: generate strike attack menus ---
	for strikeIndex, mission in pairs(self.mission) do -- step through self.mission and grab the mission data for each key ( = "location")
	
		local strikeType = mission.striketype
		local strikeRegion = mission.strikeregion
		local strikeName = mission.strikename
		local StrikeIvo = mission.strikeivo

		_msg = string.format(self.traceTitle .. "Adding Menus for Type: %s, Region: %s, Name: %s, IVO: %s", strikeType, strikeRegion, strikeName, StrikeIvo)
		BASE:T(_msg)

		-- add strike type menu
		if not self.menu[strikeType] then
			self.menu[strikeType] = MENU_COALITION:New( coalition.side.BLUE, strikeType .. " Strike", self.menu.top )
		end

		-- add region menu
		if not self.menu[strikeType][strikeRegion] then
			self.menu[strikeType][strikeRegion] = MENU_COALITION:New( coalition.side.BLUE, strikeRegion .. " Region", self.menu[strikeType] )
		end

		-- add mission menu
		self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, strikeName .. " " .. StrikeIvo, self.menu[strikeType][strikeRegion], self.SpawnStrikeAttack, self, strikeIndex ) -- add menu command to launch the mission

	end

	--------------------
	--- Camp Strikes ---
	--------------------

	-- CAMP spawn stubs
	CampAttackSpawn = SPAWN:New( "CAMP_Heavy" )
	SpawnTentGroup = SPAWN:New( "CAMP_Tent_Group" )
	SpawnInfGroup = SPAWN:New( "CAMP_Inf_02" )

	--- add camp attack menus
	-- add CAMP main submenu
	if not self.menu["Camp"] then
		self.menu["Camp"] = MENU_COALITION:New( coalition.side.BLUE, "Camp Strike", self.menu.top )
	end
	
	-- add CAMP command menus
	self.menu["Camp"]["East"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Eastern Zone",self.menu["Camp"],self.SpawnCamp, self, _camp_east_args )
	self.menu["Camp"]["Central"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Central Zone",self.menu["Camp"],self.SpawnCamp, self, _camp_central_args )
	self.menu["Camp"]["West"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"West Zone",self.menu["Camp"],self.SpawnCamp, self, _camp_west_args )
	
	-- END CAMP STRIKES

	----------------------
	--- Convoy Strikes ---
	----------------------

	-- CONVOY spawn stub
	ConvoyAttackSpawn = SPAWN:New( "CONVOY_Default" )

	-- add CONVOY main submenu
	if not self.menu["Convoy"] then
		self.menu["Convoy"] = MENU_COALITION:New( coalition.side.BLUE, "Convoy" .. " Strike", self.menu.top )
	end
	
	-- add CONVOY CENTRAL command menus
	self.menu["Convoy"]["Central"] = MENU_COALITION:New( coalition.side.BLUE, "Central" .. " Region", self.menu["Convoy"] )
	self.menu["Convoy"]["Central"][1] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Armoured Convoy", self.menu["Convoy"]["Central"], self.SpawnConvoy, self, _hard_central_args )
	self.menu["Convoy"]["Central"][2] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Supply Convoy", self.menu["Convoy"]["Central"], self.SpawnConvoy, self, _soft_central_args )
	
	-- add CONVOY West command menus
	self.menu["Convoy"]["West"] = MENU_COALITION:New( coalition.side.BLUE, "West" .. " Region", self.menu["Convoy"] )
	self.menu["Convoy"]["West"][1] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Armoured Convoy", self.menu["Convoy"]["West"], self.SpawnConvoy, self, _hard_west_args )
	self.menu["Convoy"]["West"][2] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Supply Convoy", self.menu["Convoy"]["West"], self.SpawnConvoy, self, _soft_west_args )
	
end

function MISSIONSTRIKE:SpawnStrikeAttack ( strikeIndex ) -- "location name"

	local mission = self.mission[strikeIndex]

	_msg = string.format(self.traceTitle .. "SpawnStrikeAttack() Type = %s, Name = %s.", mission.striketype, mission.strikename)
	BASE:T(_msg)

	if mission.is_open then

		local MedZonesCount = #mission.medzones -- number of medium defzones
		local SmallZonesCount = #mission.smallzones -- number of small defzones
		local SamQty = math.random( 2, mission.defassets.sam ) -- number of SAM defences min 2
		local AaaQty = math.random( 2, mission.defassets.aaa ) -- number of AAA defences min 2
		local ManpadQty = math.random( 1, mission.defassets.manpad ) -- number of manpad defences 1-max spawn in AAA zones. AaaQty + ManpadQty MUST NOT exceed SmallZonesCount
		local ArmourQty = math.random( 1, mission.defassets.armour ) -- number of armour groups 1-max spawn in SAM zones. SamQty + ArmourQty MUST NOT exceed MedZonesCount
		local StrikeMarkZone = ZONE:FindByName( mission.strikezone ) -- ZONE object for zone named in strikezone

		local strikeType = mission.striketype
		local strikeRegion = mission.strikeregion
		local strikeName = mission.strikename
		local StrikeIvo = mission.strikeivo
		
		--- Check sufficient zones exist for the mission air defences ---
		if SamQty + ArmourQty > MedZonesCount then
			local msg = mission.strikename .. " Error! SAM+Armour count exceedes medium zones count"
			MESSAGE:New ( msg, 10, "" ):ToAll()
			return
		elseif AaaQty + ManpadQty > SmallZonesCount then
			local msg = mission.strikename .. " Error! AAA+MANPAD count exceedes small zones count"
			MESSAGE:New ( msg, 5, "" ):ToAll()
			return
		end

		--- Refresh static objects in case they've previously been destroyed ---
		if #mission.striketargets > 0 then 
			for index, staticname in ipairs(mission.striketargets) do
				local AssetStrikeStaticName = staticname
				local AssetStrikeStatic = STATIC:FindByName( AssetStrikeStaticName )
				AssetStrikeStatic:ReSpawn( country.id.RUSSIA )
			end
		end
		
		--- Call asset spawns ---
		-- add SAM assets
		if SamQty ~= nil then
			self:AddStrikeAssets(mission, "sam", SamQty, "med", MedZonesCount) -- AssetType ["sam", "aaa", "manpads", "armour"], AssetQty, AssetZoneType ["med", "small"], AssetZonesCount
		end
		-- add AAA assets
		if SamQty ~= nil then
			self:AddStrikeAssets(mission, "aaa", AaaQty, "small", SmallZonesCount)
		end
		-- add Manpad assets
		if ManPadQty ~= nil then
			self:AddStrikeAssets(mission, "manpads", ManpadQty, "small", SmallZonesCount)
		end
		-- add armour assets
		if ArmourQty ~= nil then
			self:AddStrikeAssets(mission, "armour", ArmourQty, "med", MedZonesCount)
		end
		
		--- Create Mission Mark on F10 map ---
		local StrikeMarkZone = ZONE:FindByName( mission.strikezone ) -- ZONE object for zone named in strikezone 
		local StrikeMarkZoneCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone

		local StrikeMarkName = mission.strikename
		local StrikeMarkType = mission.striketype
		local StrikeMarkRegion = mission.strikeregion
		local StrikeMarkCoordsLLDMS = StrikeMarkZoneCoord:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) --mission.strikecoords
		local StrikeMarkCoordsLLDDM = StrikeMarkZoneCoord:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3)) --mission.strikecoords

		local StrikeMarkLabel = StrikeMarkName .. " " 
		.. StrikeMarkType 
		.. " Strike " 
		.. StrikeMarkRegion 
		.. "\n" 
		.. StrikeMarkCoordsLLDMS
		.. "\n"
		.. StrikeMarkCoordsLLDDM

		local StrikeMark = StrikeMarkZoneCoord:MarkToAll(StrikeMarkLabel, true) -- add mark to map
		
		mission.strikemarkid = StrikeMark -- add mark ID to table 
		
		--- Send briefing message ---
		local strikeAttackBrief = "++++++++++++++++++++++++++++++++++++"
			..	"\n\nAir Interdiction mission against "
			.. StrikeMarkName
			.. " "
			.. StrikeMarkType
			.. "\n\nMission: "
			.. mission.strikemission
			.. "\n\nCoordinates:\n"
			.. StrikeMarkCoordsLLDMS
			.. "\n"
			.. StrikeMarkCoordsLLDDM
			.. "\n\nThreats:  "
			.. mission.strikethreats
			.. "\n\n++++++++++++++++++++++++++++++++++++"
			
		MESSAGE:New ( strikeAttackBrief, 5, "" ):ToAll()
		

		mission.is_open = false -- mark strike mission as active
		
		--- menu: remove mission start command and add mission remove command
		self.menu[strikeType][strikeRegion][strikeIndex]:Remove()
		self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Remove ".. strikeName .. " " .. StrikeIvo,  self.menu[strikeType], self.RemoveStrikeAttack, self, strikeIndex )
				
	else
		msg = "\n\nThe " 
			.. mission.strikename
			.. " "
			.. mission.striketype
			.. " strike attack mission is already active!"
		MESSAGE:New( msg, 5, "" ):ToAll()
	end


end --SpawnStrikeAttack

--- add strike defence assets ---
function MISSIONSTRIKE:AddStrikeAssets(mission, AssetType, AssetQty, AssetZoneType, AssetZonesCount ) -- AssetType ["sam", "aaa", "manpads", "armour"], AssetQty, AssetZoneType ["med", "small"], AssetZonesCount
	_msg = self.traceTitle .. "AddStrikeAssets()"
	BASE:T({_msg, AssetType, AssetQty, AssetZoneType, AssetZonesCount})

	if AssetQty > 0 then
	
		local TableStrikeAssetZones = {}

		-- select indexes of zones in which to spawn assets 
		for count=1, AssetQty do 
			local zoneindex = math.random( 1, AssetZonesCount )
			if AssetZoneType == "med" then
				while ( not mission.medzones[zoneindex].is_open ) do -- ensure selected zone has not been used
					_msg = self.traceTitle .. "Med Randomise Zone Do-While"
					BASE:T(_msg)
					zoneindex = math.random ( 1, AssetZonesCount )
				end
				mission.medzones[zoneindex].is_open = false -- close samzone for selection
			else
				while ( not mission.smallzones[zoneindex].is_open ) do -- ensure selected zone has not been used
					_msg = self.traceTitle .. "NOT MED Randomise Zone Do-While"
					BASE:T(_msg)
					zoneindex = math.random ( 1, AssetZonesCount )
				end
				mission.smallzones[zoneindex].is_open = false -- close aaazone for selection
			end
			TableStrikeAssetZones[count] = zoneindex -- add selected zone to list
			
		end

		-- spawn assets
		for count = 1, #TableStrikeAssetZones do
			-- randomise template (MOOSE removes unit orientation in template)
			local DefTemplateIndex = math.random( 1, #TableDefTemplates[AssetType] ) -- generate random index for template
			local AssetTemplate = TableDefTemplates[AssetType][DefTemplateIndex] -- select indexed template
			local AssetSpawnStub = self.spawn["DEFSTUB_" .. AssetTemplate] -- [contenation for name of generated DEFSTUB_ spawn]
			local assetzoneindex = TableStrikeAssetZones[count]
			if AssetZoneType == "med" then -- medzone 
				assetspawnzone = ZONE:FindByName( mission.medzones[assetzoneindex].loc ) -- [concatenation for name of generated spawnzone]
			else -- smallzone
				assetspawnzone = ZONE:FindByName( mission.smallzones[assetzoneindex].loc ) -- ["SPAWN" .. mission.smallzones[assetzoneindex].loc]
			end
			AssetSpawnStub:SpawnInZone( assetspawnzone ) -- spawn asset in zone in generated zone list
			local assetspawngroup, assetspawngroupindex = AssetSpawnStub:GetLastAliveGroup()
			table.insert(mission.spawnobjects, assetspawngroup )
		end

	end

end

--- Remove strike attack mission ---
function MISSIONSTRIKE:RemoveStrikeAttack ( strikeIndex )
	local mission = self.mission[strikeIndex]

	_msg = string.format(self.traceTitle .. "RemoveStrikeAttack() Type = %s, Name = %s.", mission.striketype, mission.strikename)
	BASE:T(_msg)

	local strikeType = mission.striketype
	local strikeRegion = mission.strikeregion
	local strikeName = mission.strikename
	local StrikeIvo = mission.strikeivo

	if not mission.is_open then
		-- remove spawned objects
		local objectcount = #mission.spawnobjects
		for count = 1, objectcount do
			local removespawnobject = mission.spawnobjects[count]
			if removespawnobject:IsAlive() then
				
				removespawnobject:Destroy() --false
			end
		end
		
		-- reset mission zones
		for _index, zone in pairs(mission.medzones) do
			zone.is_open = true
		end

		for _index, zone in pairs(mission.smallzones) do
			zone.is_open = true
		end
		
		-- remove map mark
		COORDINATE:RemoveMark( mission.strikemarkid ) -- remove mark from map
		
		mission.strikemarkid = nil -- reset map mark ID
		mission.spawnobjects = {} -- clear list of now despawned objects
		mission.is_open = true -- set strike mission as available
		
		-- reset mission menu
		-- self.menu[strikeType][strikeRegion][strikeIndex].menuCommand:Remove()
		-- self.menu[strikeType][strikeRegion][strikeIndex].menuCommand = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Start Mission", self.menu[strikeType][strikeRegion][strikeIndex], self.SpawnStrikeAttack, self, strikeIndex ) -- add menu command to launch the mission
		self.menu[strikeType][strikeRegion][strikeIndex]:Remove()
		self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, strikeName .. " " .. StrikeIvo, self.menu[strikeType][strikeRegion], self.SpawnStrikeAttack, self, strikeIndex ) -- add menu command to launch the mission

		msg = "\n\nThe " 
		.. mission.strikename
		.. " strike attack mission has been removed."
		MESSAGE:New( msg, 5, "" ):ToAll()

	else
		msg = "\n\nThe " 
			.. mission.strikename
			.. " strike attack mission is not active!"
		MESSAGE:New( msg, 5, "" ):ToAll()
	end

end --RemoveStrikeAttack

function MISSIONSTRIKE:SpawnConvoy ( _args ) -- ConvoyTemplates, SpawnHost {conv, dest, destzone, strikecoords, is_open}, ConvoyType, ConvoyThreats

	_msg = self.traceTitle .. "SpawnConvoy()"
	BASE:T({_msg, _args})
	
	local TemplateTable = _args[1]
	local SpawnHostTable = _args[2]
	local ConvoyType = _args[3]
	local ConvoyThreats = _args[4]
	
	
	local SpawnIndex = math.random ( 1, #SpawnHostTable )
	local SpawnHost = SpawnHostTable[SpawnIndex].conv
	local DestZone = SpawnHostTable[SpawnIndex].destzone

  --- Create Mission Mark on F10 map ---
  -- MissionMapMark(CampTableIndex)
  local StrikeMarkZone = SpawnHost -- ZONE object for zone named in strikezone 
  local StrikeMarkZoneCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone

  local StrikeMarkType = "Convoy"
  local StrikeMarkCoordsLLDMS = StrikeMarkZoneCoord:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) --mission.strikecoords
  local StrikeMarkCoordsLLDDM = StrikeMarkZoneCoord:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3)) --mission.strikecoords

  local StrikeMarkLabel = StrikeMarkType 
    .. " Strike\n" 
    .. StrikeMarkCoordsLLDMS
	.. "\n"
	.. StrikeMarkCoordsLLDDM

  local StrikeMark = StrikeMarkZoneCoord:MarkToAll(StrikeMarkLabel, true) -- add mark to map

  --SpawnCampsTable[ CampTableIndex ].strikemarkid = StrikeMark -- add mark ID to table 

	
	SpawnHost:InitRandomizeTemplate( TemplateTable )
		:OnSpawnGroup(
			function ( SpawnGroup )
				CheckConvoy = SCHEDULER:New( nil, 
					function()
						if SpawnGroup:IsPartlyInZone( DestZone ) then
							SpawnGroup:Destroy() --false
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
		.. "\n\nLast Known Position:\n"
		.. StrikeMarkCoordsLLDMS
		.. "\n"
		.. StrikeMarkCoordsLLDDM
		.. "\n"
		.. ConvoyThreats
		.. "\n\n++++++++++++++++++++++++++++++++++++"
		
	MESSAGE:New( ConvoyAttackBrief, 5, "" ):ToAll()
	
		
end --SpawnConvoy  
  
--XXX ## Spawning enemy camps

function MISSIONSTRIKE:SpawnCamp( _args ) --TemplateTable, CampsTable [ loc, town, coords, is_open ], Region
	_msg = self.traceTitle .. "SpawnCamp()"
	BASE:T({_msg, _args})
	
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
		MESSAGE:New( msg, 5, "" ):ToAll()
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

    --------------------------------------
    --- Create Mission Mark on F10 map ---
    --------------------------------------
    
    --MissionMapMark(CampTableIndex)
    local StrikeMarkZone = SpawnCampZone -- ZONE object for zone named in strikezone 
    local StrikeMarkZoneCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone

    local StrikeMarkName = SpawnCampsTable[ CampTableIndex ].town
    local StrikeMarkType = "Camp"
    local StrikeMarkRegion = SpawnZoneRegion
 	local StrikeMarkCoordsLLDMS = StrikeMarkZoneCoord:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) --mission.strikecoords
	local StrikeMarkCoordsLLDDM = StrikeMarkZoneCoord:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3)) --mission.strikecoords

    local StrikeMarkLabel = StrikeMarkName .. " " 
      .. StrikeMarkType 
      .. " Strike " 
      .. StrikeMarkRegion 
      .. "\n" 
      .. StrikeMarkCoordsLLDMS
	  .. "\n"
	  .. StrikeMarkCoordsLLDDM
	  

    local StrikeMark = StrikeMarkZoneCoord:MarkToAll(StrikeMarkLabel, true) -- add mark to map

    SpawnCampsTable[ CampTableIndex ].strikemarkid = StrikeMark -- add mark ID to table 
 
    
 	local CampAttackBrief = "++++++++++++++++++++++++++++++++++++" 
		.."\n\nIntelligence is reporting an insurgent camp IVO "
		.. SpawnCampsTable[ CampTableIndex ].town
		.. "\n\nMission:  LOCATE AND DESTROY THE CAMP."
		.. "\n\nCoordinates:\n"
		.. StrikeMarkCoordsLLDMS
		.. "\n"
		.. StrikeMarkCoordsLLDDM
		.. "\n\nThreats:  INFANTRY, HEAVY MG, RPG, I/R SAM, LIGHT ARMOR, AAA"
		.. "\n\n++++++++++++++++++++++++++++++++++++"
		
	MESSAGE:New( CampAttackBrief, 5, "" ):ToAll()

	SpawnCampsTable[ CampTableIndex ].is_open = false
	
end --SpawnCamp

-- TODO: integrate camp attack, convoy strike

-- ## CAMP remove spawn
function MISSIONSTRIKE:RemoveCamp( _args )
	_msg = self.traceTitle .. "RemoveCamp()"
	BASE:T({_msg, _args})

	local FirstCampGroup, Index = _args[2]:GetFirstAliveGroup()
	if FirstCampGroup then
		FirstCampGroup:Destroy() --false
	end
	
end --RemoveCamp

-- END FUNCTIONS

--[[ Strike Attack Mission Data

--- MISSIONSTRIKE.mission table 
-- @type MISSIONSTRIKE.mission
-- @field #string striketype type of strike; Airfield, Factory, Bridge, Communications, C2
-- @field #string strikeregion Region in which mission is located (East, Central, West)
-- @field #string strikename Friendly name for the location used in briefings, menus etc. Currently the same as the key, but will probably change
-- @field #string strikeivo "in the vacinity of" ("AFB" if airfield, "[TOWN/CITY]" other targets)
-- @field #string strikecoords LatLong
-- @field #string strikemission mission description
-- @field #string strikethreats threats description
-- @field #string ME zone at center of strike location
-- @field #table striketargets static objects to be respawned for object point strikes (Factory, refinery etc)
-- @field #table medzones ME zones in which medium assets will be spawned. (AAA batteries, vehicle groups, infantry groups etc)
-- @field #string loc ME defence zone at location
-- @field #boolean is_open tracks whether defence zone is occupied
-- @field #table ME zones in which small assets will be spawned
-- @field #string loc ME defence zone at location
-- @field #boolean is_open tracks whether defence zone is occupied
-- @field #table defassets max number of each defence asset. sum of zone types used must not exceed number of zone type available
-- @field #number sam uses medzones
-- @field #number aaa uses smallzones
-- @field #number manpads uses smallzones
-- @field #number armour uses medzones
-- @field #table spawnobjects table holding names of the spawned objects relating the mission
-- @field #boolean is_open mission status. true if mission is avilable for spawning. false if it is in-progress

-- XXX: MISSIONSTRIKE.mission

MISSIONSTRIKE.mission = { -- TableStrikeAttack
	{ --Beslan 
		striketype = "Airfield", 
        strikeregion = "East",                          
		strikename = "Beslan",
		strikeivo = "AFB", 
		strikecoords = "43  12  20 N | 044  36  20 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_BeslanStrike",
		striketargets = {
            "BESLAN_STATIC_01",
            "BESLAN_STATIC_02",
            "BESLAN_STATIC_03",
            "BESLAN_STATIC_04",
            "BESLAN_STATIC_05",
            "BESLAN_STATIC_06",
            "BESLAN_STATIC_07",
            "BESLAN_STATIC_08",
            "BESLAN_STATIC_09",
		},
		medzones = { 
			{ loc = "ZONE_BeslanMed_01", is_open = true },
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
		smallzones = {
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
		defassets = {
			sam = 4,
			aaa = 5,
			manpad = 3, 
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- Sochi
		striketype = "Airfield",
        strikeregion = "West",                            
		strikename = "Sochi",
		strikeivo = "AFB",
		strikecoords = "43  26  41 N | 039  56  32 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_SochiStrike",
		striketargets = {
            "SOCHI_STATIC_01",
            "SOCHI_STATIC_02",
            "SOCHI_STATIC_03",
            "SOCHI_STATIC_04",
            "SOCHI_STATIC_05",
            "SOCHI_STATIC_06",
            "SOCHI_STATIC_07",
            "SOCHI_STATIC_08",
            "SOCHI_STATIC_09",
            "SOCHI_STATIC_10",
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
	{ -- Maykop
		striketype = "Airfield",
        strikeregion = "West",                            
		strikename = "Maykop",
		strikeivo = "AFB",
		strikecoords = "44  40  54 N | 040  02  08 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MaykopStrike",
		striketargets = {
            "MAYKOP_STATIC_01",
            "MAYKOP_STATIC_02",
            "MAYKOP_STATIC_03",
            "MAYKOP_STATIC_04",
            "MAYKOP_STATIC_05",
            "MAYKOP_STATIC_06",
            "MAYKOP_STATIC_07",
            "MAYKOP_STATIC_08",
            "MAYKOP_STATIC_09",
            "MAYKOP_STATIC_10",
            "MAYKOP_STATIC_11",
            "MAYKOP_STATIC_12",
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
		defassets = {
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- Nalchik 
		striketype = "Airfield",
        strikeregion = "Central",                            
		strikename = "Nalchik",
		strikeivo = "AFB",
		strikecoords = "43  30  53 N | 043  38  17 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_NalchikStrike",
		striketargets = {
            "NALCHIK_STATIC_01",
            "NALCHIK_STATIC_02",
            "NALCHIK_STATIC_03",
            "NALCHIK_STATIC_04",
            "NALCHIK_STATIC_05",
            "NALCHIK_STATIC_06",
            "NALCHIK_STATIC_07",
            "NALCHIK_STATIC_08",
            "NALCHIK_STATIC_09",
            "NALCHIK_STATIC_10",
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
		defassets = { 
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- MN76 
		striketype = "Factory",
        strikeregion = "East",                            
		strikename = "MN76",
		strikeivo = "Vladikavkaz",
		strikecoords = "43  00  23 N | 044  39  02 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND ANCILLIARY SUPPORT INFRASTRUCTURE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MN76Strike",
		striketargets = {
            "MN76_STATIC_01",
            "MN76_STATIC_02",
            "MN76_STATIC_03",
            "MN76_STATIC_04",
            "MN76_STATIC_05",
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
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- LN83 
		striketype = "Factory",
        strikeregion = "Central",                            
		strikename = "LN83",
		strikeivo = "Chiora",
		strikecoords = "42  44  56 N | 043  32  28 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LN83Strike",
		striketargets = {
            "LN83_STATIC_01",
            "LN83_STATIC_02",
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
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- LN77 
		striketype = "Factory",
        strikeregion = "Central",                            
		strikename = "LN77",
		strikeivo = "Verh.Balkaria",
		strikecoords = "43  07  35 N | 043  27  24 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND COMMUNICATIONS INFRASTRUCTURE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LN77Strike",
		striketargets = {
            "LN77_STATIC_01",
            "LN77_STATIC_02",
            "LN77_STATIC_03",
            "LN77_STATIC_04",
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
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 1, 
			armour = 3, 
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- LP30 
		striketype = "Factory",
        strikeregion = "Central",                            
		strikename = "LP30",
		strikeivo = "Tyrnyauz",
		strikecoords = "43  23  43 N | 042  55  27 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND COMMUNICATIONS INFRASTRUCTURE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LP30Strike",
		striketargets = {
		"LP30_STATIC_01",
        "LP30_STATIC_02",
        "LP30_STATIC_03",
        "LP30_STATIC_04",
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
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- GJ38 
		striketype = "Bridge",
        strikeregion = "Central",                            
		strikename = "GJ38",
		strikeivo = "Ust Dzheguta",
		strikecoords = "DMPI A 44  04  38 N | 041  58  15 E\n\nDMPI B 44  04  23 N | 041  58  34 E",
		strikemission = "DESTROY ROAD BRIDGE DMPI A AND\nRAIL BRIDGE DMPI B",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ38Strike",
		striketargets = {
			"GJ38_STATIC_01",
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
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 3, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- MN72 
		striketype = "Bridge",
        strikeregion = "East",                            
		strikename = "MN72",
		strikeivo = "Kazbegi",
		strikecoords = "44  04  38 N | 041  58  15 E",
		strikemission = "DESTROY ROAD BRIDGE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MN72Strike",
		striketargets = {
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
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
	{ -- GJ21 
		striketype = "Bridge",
        strikeregion = "Central",                            
		strikename = "GJ21",
		strikeivo = "Teberda",
		strikecoords = "43  26  47 N | 041  44  28 E",
		strikemission = "DESTROY ROAD BRIDGE",
		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ21Strike",
		striketargets = {
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
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 1, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},
}


--- strike Defence spawn templates ---
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

--- strike Static Object spawn templates ---
TableStaticTemplates = {
	target = {
		"FACTORY_Workshop",
		"FACTORY_Techcombine",
	},
	buildings = {
		
	},
}

-- END STRIKE ATTACK DATA


-----------------------------------
--- Convoy Strike Mission Data ---
-----------------------------------

--- camp spawns per location
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
	},
}

--- Camp spawn templates ---
ArmourTemplates = {
	"CAMP_Heavy_01",
	"CAMP_Heavy_02",
	"CAMP_Heavy_03",
	"CAMP_Heavy_04",
} 

-- Camp strike spawn arguments
-- East zones
_camp_east_args = {
	ArmourTemplates,
	TableCamps.east,
	"East"
}
-- Central Zones
_camp_central_args = {
	ArmourTemplates,
	TableCamps.central,
	"Central"
}
-- West Zones
_camp_west_args = {
	ArmourTemplates,
	TableCamps.west,
	"West"
}
-- TODO: Remove oldest Camp Attack mission
_camp_remove_args = { 
	CampAttackSpawn,
	SpawnTentGroup,
	SpawnInfGroup
}

-----------------------------------
--- Convoy Strike Mission Data ---
-----------------------------------

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
			conv = SPAWN:New( "CONVOY_03" ), 
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

_soft_central_args = {
	ConvoySoftTemplates,
	SpawnConvoys.central,
	SoftType,
	SoftThreats
}

-- ## West Zones
_hard_west_args = {
	ConvoyHardTemplates,
	SpawnConvoys.west,
	HardType,
	HardThreats
}

_soft_west_args = {
	ConvoySoftTemplates,
	SpawnConvoys.west,
	SoftType,
	SoftThreats
}

-- END CONVOY ATTACK DATA

-- Start Strike Attack Module
MISSIONSTRIKE:Start() 
--]]