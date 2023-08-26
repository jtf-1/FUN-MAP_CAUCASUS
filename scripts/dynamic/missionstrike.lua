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
		for index = 1, #v do
				local templatename = v[ count ]
				-- local stubname = "DEFSTUB_" .. templatename
				-- self.spawn[ stubname ] = SPAWN:New( templatename )
				self.defSpawns[templatename] = SPAWN:New( templatename )
		end
	end

	--- initialise missions and generate strike attack menus ---
	for strikeIndex, mission in pairs(self.mission) do -- step through self.mission and grab the mission data for each key ( = "location")
	
		mission.strikeIndex = strikeIndex

		local strikeType = mission.striketype
		local strikeRegion = mission.strikeregion
		local strikeName = mission.strikename
		local strikeIvo = mission.strikeivo

		-- create a count for each zone class
		-- for index, zone in pairs(mission.zones) do
		-- 	mission.zoneclass[zone.class] = mission.zoneclass[zone.class] + 1
		-- 	_msg = string.format(self.traceTitle .. "Zone Class %s count = %d", zone.class, mission.zoneclass[zone.class])
		-- 	BASE:T(_msg)
		-- end
		
		-- generate target spawn objects
		if #mission.striketargets.groups > 0 then
			for index, strikeTarget in pairs(mission.striketargets.groups) do
				_msg = self.traceTitle .. "Create Strike Target spawn"
				BASE:T({_msg, strikeTarget})
				local spawnTemplate = GROUP:FindByName(strikeTarget)
				if spawnTemplate then
					if not mission.striketargets.spawn then
						mission.striketargets.spawn = {}
					end
					mission.striketargets.spawn[strikeTarget] = SPAWN:New(strikeTarget):InitUnControlled()
				else
					_msg = string.format(self.traceTitle .. "Spawn template %s not found!", strikeTarget)
					BASE:E(_msg)
				end
			end
		end

		_msg = string.format(self.traceTitle .. "Adding Menus for Type: %s, Region: %s, Name: %s, IVO: %s", strikeType, strikeRegion, strikeName, strikeIvo)
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
		self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, strikeName .. " " .. strikeIvo, self.menu[strikeType][strikeRegion], self.SpawnStrikeAttack, self, mission ) -- add menu command to launch the mission

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

function MISSIONSTRIKE:SpawnStrikeAttack ( mission ) -- "location name"

	--local mission = self.mission[strikeIndex]

	_msg = string.format(self.traceTitle .. "SpawnStrikeAttack() Type = %s, Name = %s.", mission.striketype, mission.strikename)
	BASE:T(_msg)

	if mission.is_open then

		local strikeIndex = mission.strikeIndex
		local strikeType = mission.striketype
		local strikeRegion = mission.strikeregion
		local strikeName = mission.strikename
		local strikeIvo = mission.strikeivo

		--local medZonesCount = mission.zoneclass["medium"] -- number of medium defzones
		local medZonesCount = #mission.zones["medium"] -- number of medium defzones
		--local smallZonesCount = mission.zoneclass["small"] -- number of small defzones
		local smallZonesCount = #mission.zones["small"] -- number of small defzones
	 	_msg = string.format(self.traceTitle .. "Zone type counts; medium = %d, small = %d", medZonesCount, smallZonesCount)
		BASE:T(_msg)

		local samQty = math.random( 1, mission.defassets.sam ) or 0-- number of SAM defences min 1
		local aaaQty = math.random( 1, mission.defassets.aaa ) or 0 -- number of AAA defences min 1
		local manpadQty = math.random( 0, mission.defassets.manpad ) or 0 -- number of manpad defences min 0. Spawn in AAA zones. aaaQty + manpadQty MUST NOT exceed smallZonesCount
		local armourQty = math.random( 1, mission.defassets.armour ) or 0-- number of armour groups min 1. spawn in SAM zones. samQty + armourQty MUST NOT exceed medZonesCount
		local strikeMarkZone = ZONE:FindByName( mission.strikezone ) -- ZONE object for zone named in strikezone

        -- set threat message with threat counts
		mission.strikeThreats = string.format("%dx RADAR SAM,  %dx AAA, %dx MANPAD, %dx LIGHT ARMOUR", samQty, aaaQty, manpadQty, armourQty)
		BASE:T(self.traceTitle .. mission.strikeThreats)

		--- Check sufficient zones exist for the mission air defences ---
		if samQty + armourQty > medZonesCount then
			_msg = mission.strikename .. " Error! SAM+Armour count exceedes medium zones count"
			BASE:E(_msg)
			return
		elseif aaaQty + manpadQty > smallZonesCount then
			_msg = mission.strikename .. " Error! AAA+MANPAD count exceedes small zones count"
			BASE:E(_msg)
			return
		end

		local strikeTarget
		--- Refresh STATIC objects in case they've previously been destroyed
		if #mission.striketargets.statics > 0 then
			for index, strikeTargetName in ipairs(mission.striketargets.statics) do
				-- look for a strikeTarget static object
				strikeTarget = STATIC:FindByName(strikeTargetName)
				if strikeTarget then
					_msg = string.format(self.traceTitle .. mission.strikename .. "Respawn Static %s", strikeTargetName)
					BASE:T(_msg)
                    strikeTarget:ReSpawn( country.id.RUSSIA )
				else
					_msg = string.format(self.traceTitle .. mission.strikename .. "Strike target Static %s not found!", strikeTargetName)
					BASE:E(_msg)
				end
			end
		end
		-- spawn target groups
		if #mission.striketargets.groups > 0 then
			for index, strikeTarget in pairs(mission.striketargets.groups) do
				-- look for a strikeTarget group object
				if mission.striketargets.spawn[strikeTarget] then
					_msg = string.format(self.traceTitle .. mission.strikename .. "Spawn Target Group %s", strikeTarget)
					BASE:T(_msg)
					-- spawn strike target object
					local spawnGroup = mission.striketargets.spawn[strikeTarget]:Spawn()
					-- add spawngroup to spawnobjects list
					table.insert(mission.spawnobjects, spawnGroup )
				else
					_msg = string.format(self.traceTitle .. mission.strikename .. "Strike target %s not found!", strikeTarget)
					BASE:E(_msg)
				end
			end
		end
		
		--- Call asset spawns ---
		-- add SAM assets
		if samQty > 0 then
			self:AddStrikeAssets(mission, "sam", samQty, "medium", medZonesCount) -- AssetType ["sam", "aaa", "manpads", "armour"], AssetQty, AssetZoneType ["med", "small"], AssetZonesCount
		end
		-- add AAA assets
		if samQty > 0 then
			self:AddStrikeAssets(mission, "aaa", aaaQty, "small", smallZonesCount)
		end
		-- add Manpad assets
		if manpadQty > 0 then
			self:AddStrikeAssets(mission, "manpads", manpadQty, "small", smallZonesCount)
		end
		-- add armour assets
		if armourQty > 0 then
			self:AddStrikeAssets(mission, "armour", armourQty, "medium", medZonesCount)
		end
		
		mission.is_open = false -- mark strike mission as active
		
		--- menu: remove mission start command and add mission remove command
		self.menu[strikeType][strikeRegion][strikeIndex]:Remove()
		self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Remove ".. strikeName .. " " .. strikeIvo,  self.menu[strikeType], self.RemoveStrikeAttack, self, mission )

		MISSIONSTRIKE:Briefing(mission)
	else
		_msg = string.format("The %s %s strike attack mission is already active!", mission.strikename, mission.striketype)
		MESSAGE:New( _msg, 5, "" ):ToAll()
		_msg = self.traceTitle .. _msg
		BASE:T(_msg)
	end


end --SpawnStrikeAttack

--- add strike defence assets ---
function MISSIONSTRIKE:AddStrikeAssets(mission, AssetType, AssetQty, AssetZoneType, AssetZonesCount ) -- AssetType ["sam", "aaa", "manpads", "armour"], AssetQty, AssetZoneType ["med", "small"], AssetZonesCount
	_msg = self.traceTitle .. "AddStrikeAssets()"
	BASE:T({_msg, AssetType, AssetQty, AssetZoneType, AssetZonesCount})

	if AssetQty > 0 then
	
		local TableStrikeAssetZones = {}

		-- select indexes of zones in which to spawn assets 
		for index = 1, AssetQty do
			-- generate a random index for the zone type 
			local zoneindex = math.random( 1, AssetZonesCount )
			-- ensure selected zone has not been used
			while ( not mission.zones[AssetZoneType][zoneindex].is_open ) do 
				_msg = self.traceTitle .. "Regenerate random Zone index."
				BASE:T(_msg)
				zoneindex = math.random ( 1, AssetZonesCount )
			end
			-- close zone for selection
			mission.zones[AssetZoneType][zoneindex].is_open = false 
			-- add selected zone to list
			TableStrikeAssetZones[index] = zoneindex 
			
		end

		-- spawn assets
		for index = 1, #TableStrikeAssetZones do
			-- randomise template (MOOSE removes unit orientation in template)
			local DefTemplateIndex = math.random( 1, #TableDefTemplates[AssetType] ) -- generate random index for template
			local AssetTemplate = TableDefTemplates[AssetType][DefTemplateIndex] -- select indexed template
			-- local AssetSpawn = self.spawn["DEFSTUB_" .. AssetTemplate] -- [contenation for name of generated DEFSTUB_ spawn]
			local AssetSpawn = self.defSpawns[AssetTemplate] -- [contenation for name of generated DEFSTUB_ spawn]
			local assetzoneindex = TableStrikeAssetZones[index]
			local assetspawnzone = ZONE:FindByName( mission.zones[AssetZoneType][assetzoneindex].loc ) -- [concatenation for name of generated spawnzone]
			
			-- AssetSpawn:SpawnInZone( assetspawnzone ) -- spawn asset in zone in generated zone list
			local assetspawngroup = AssetSpawn:SpawnInZone( assetspawnzone ) -- spawn asset in zone in generated zone list
			
			--local assetspawngroup, assetspawngroupindex = AssetSpawn:GetLastAliveGroup()
			table.insert(mission.spawnobjects, assetspawngroup ) -- add spawned asset to spawnobjects list
		end

	end

end

function MISSIONSTRIKE:Briefing(mission)

	--- Create Mission Mark on F10 map ---
	local StrikeMarkZone = ZONE:FindByName( mission.strikezone ) -- ZONE object for zone named in strikezone 
	local StrikeMarkZoneCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone

	local StrikeMarkName = mission.strikename
	local StrikeMarkType = mission.striketype
	local StrikeMarkRegion = mission.strikeregion
	local StrikeMarkCoordsLLDMS = StrikeMarkZoneCoord:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) --mission.strikecoords
	local StrikeMarkCoordsLLDDM = StrikeMarkZoneCoord:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3)) --mission.strikecoords
	local StrikeMarkCoordsMGRS = StrikeMarkZoneCoord:ToStringMGRS() --mission.strikecoords

	local StrikeMarkLabel = StrikeMarkName .. " " 
	.. StrikeMarkType 
	.. " Strike " 
	.. StrikeMarkRegion 
	.. "\n" 
	.. StrikeMarkCoordsLLDMS
	.. "\n"
	.. StrikeMarkCoordsLLDDM

	mission.mapMark = StrikeMarkZoneCoord:MarkToAll(StrikeMarkLabel, true) -- add mark to map
	
	--mission.strikemarkid = mapMark -- add mark ID to table 
	
	--- Send briefing message ---
	local strikeAttackBrief = "\n\n++++++++++++++++++++++++++++++++++++\n\n"
		..	"Air Interdiction mission against " .. StrikeMarkName .. " " .. StrikeMarkType .. "\n\n"
		.. "Mission: " .. mission.strikemission .. "\n\n"
		.. "Coordinates:\n"
		.. StrikeMarkCoordsLLDMS .. "\n"
		.. StrikeMarkCoordsLLDDM .. "\n"
		.. StrikeMarkCoordsMGRS .. "\n\n"
		.. "Threats:  " .. mission.strikeThreats .. "\n\n"
		.. "++++++++++++++++++++++++++++++++++++"
		
	MESSAGE:New ( strikeAttackBrief, 5, "" ):ToAll()
end

--- Remove strike attack mission ---
function MISSIONSTRIKE:RemoveStrikeAttack ( mission )
	--local mission = self.mission[strikeIndex]

	_msg = string.format(self.traceTitle .. "RemoveStrikeAttack() Type = %s, Name = %s.", mission.striketype, mission.strikename)
	BASE:T(_msg)

	local strikeIndex = mission.strikeIndex
	local strikeType = mission.striketype
	local strikeRegion = mission.strikeregion
	local strikeName = mission.strikename
	local strikeIvo = mission.strikeivo

	if not mission.is_open then

		-- remove spawned objects
		local objectcount = #mission.spawnobjects
		for index = 1, objectcount do
			local removespawnobject = mission.spawnobjects[index]
			if removespawnobject:IsAlive() then
				_msg = string.format(self.traceTitle .. "Remove Spawned Object %s from mission %s.", removespawnobject:GetName(), mission.strikename)
				BASE:T(_msg)
				removespawnobject:Destroy() --false
			end
		end
		
		-- clear list of now despawned objects
		mission.spawnobjects = {} 

		-- reset mission zones
		for _indexZone, zoneType in pairs(mission.zones) do
			for _indexType, zone in pairs(zoneType) do
				zone.is_open = true
			end
		end

		
		-- remove map mark from map
		COORDINATE:RemoveMark( mission.mapMark )
		-- reset map
		mission.mapMark = nil 

		-- set strike mission as available
		mission.is_open = true 
		
		-- reset mission menu
		self.menu[strikeType][strikeRegion][strikeIndex]:Remove()
		self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, strikeName .. " " .. strikeIvo, self.menu[strikeType][strikeRegion], self.SpawnStrikeAttack, self, mission ) -- add menu command to launch the mission
		self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, strikeName .. " " .. strikeIvo, self.menu[strikeType][strikeRegion], self.SpawnStrikeAttack, self, mission ) -- add menu command to launch the mission

		_msg = string.format("The %s strike attack mission has been removed.", mission.strikename)
		MESSAGE:New( _msg, 5, "" ):ToAll()
		_msg = self.traceTitle .. _msg
		BASE:T(_msg)

	else
		_msg = string.format(self.traceTitle .. "Strike attack mission %s is not active!", mission.strikename)
		BASE:E(_msg)		
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
	  

	  SpawnCampsTable[ CampTableIndex ].mapMark = StrikeMarkZoneCoord:MarkToAll(StrikeMarkLabel, true) -- add mark to map

    --SpawnCampsTable[ CampTableIndex ].strikemarkid = StrikeMark -- add mark ID to table 
 
    
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