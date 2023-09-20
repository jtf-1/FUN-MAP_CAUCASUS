env.info( "[JTF-1] mission_strike" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN MISSIONSTRIKE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

MISSIONSTRIKE = {}
MISSIONSTRIKE.traceTitle = "[JTF-1 MISSIONSTRIKE] "

MISSIONSTRIKE.menu = {} -- MISSIONSTRIKE menus container
--MISSIONSTRIKE.spawn = {} -- MISSIONSTRIKE spawn objects container

-- start MISSIONSTRIKE module
function MISSIONSTRIKE:Start()
	_msg = self.traceTitle .. "Start()"
	BASE:T(_msg)

	-- add main menu
	self.menu.top = MENU_COALITION:New( coalition.side.BLUE, "Strike Missions" )

	--- generate strike defence spawn templates if defined in missionstrike_data.lua
	if self.defenceTemplates then
		-- replace built-in defence templates with those listed in MISSIONSTRIKE.defenceTemplates
		self.defenceSpawns = {}
		for defIndex, defenceTemplate in pairs(self.defenceTemplates) do
			for templateIndex = 1, #defenceTemplate do
				local templateName = defenceTemplate[templateIndex]
				_msg = string.format("%sStart(). Add defence spawn object %s", self.traceTitle, templateName)
				BASE:T(_msg)
				local addSpawn = self:AddSpawnTemplate(templateName)
				if addSpawn then
					self.defenceSpawns[templateName] = addSpawn
				else
					_msg = string.format("%sError! Start(). NIL returned by AddSpawn() for template %s!", self.traceTitle, templateName)
					BASE:E(_msg)
				end
			end
		end
	end

	-- generate camp spawn objects
	if self.campTemplates then
		self.campSpawns = {}
		for type, template in pairs(self.campTemplates) do
			-- type defence contains list of templates for random selection
			if type == "defence" then
				for index, defenceName in ipairs(template) do
					_msg = string.format("%sAdd camp spawn object %s", self.traceTitle, defenceName)
					BASE:T(_msg)
					local addSpawn = self:AddSpawnTemplate(defenceName)
					if addSpawn then
						self.campSpawns[defenceName] = addSpawn
					else
						_msg = string.format("%sError! NIL returned by AddSpawn() for template %s!", self.traceTitle, defenceName)
						BASE:E(_msg)
					end
				end
			else
				_msg = string.format("%sStart(). Add camp spawn object %s", self.traceTitle, template)
				BASE:T(_msg)
				local addSpawn = self:AddSpawnTemplate(template)
				if addSpawn then
					self.campSpawns[type] = addSpawn
				else
					_msg = string.format("%sError! Start(). NIL returned by AddSpawn() for template %s!", self.traceTitle, template)
					BASE:E(_msg)
				end
			end
		end
	end

	-- generate convoy spawn templates
	if self.convoyTemplates then
		self.convoySpawn = {}
		for type, typeTemplate in pairs(self.convoyTemplates) do
			-- type convoy contains list of convoy categories for random selection
			if type == "convoy" then
				-- step through each convoy category
				for category, categoryTemplate in pairs (typeTemplate) do
					for index, template in ipairs(categoryTemplate) do
						_msg = string.format("%sStart(). Add convoy spawn object %s", self.traceTitle, template)
						BASE:T(_msg)
						local addSpawn = self:AddSpawnTemplate(template)
						if addSpawn then
							self.convoySpawn[template] = addSpawn
						else
							_msg = string.format("%sError! Start(). NIL returned by AddSpawn() for template %s!", self.traceTitle, template)
							BASE:E(_msg)
						end
					end
				end
			else
				_msg = string.format("%sStart(). Add convoy spawn object %s", self.traceTitle, typeTemplate)
				BASE:T(_msg)
				local addSpawn = self:AddSpawnTemplate(typeTemplate)
				if addSpawn then
					self.convoySpawn[typeTemplate] = addSpawn
				else
					_msg = string.format("%sError! Start(). NIL returned by AddSpawn() for template %s!", self.traceTitle, typeTemplate)
					BASE:E(_msg)
				end
			end
		end
	end

	--- initialise missions and generate strike attack menus ---
	for strikeIndex, mission in pairs(self.mission) do -- step through self.mission and grab the mission data for each key ( = "location")

		mission.strikeindex = strikeIndex

		local strikeType = mission.striketype
		local strikeRegion = mission.strikeregion
		local strikeName = mission.strikename
		local strikeIvo = mission.strikeivo
		local strikeZoneName = mission.strikezone
		local strikeOptions = mission.options
		
		-- Mission root contains a strikezone
		if mission.strikezone then
	
			-- add text for map mark and briefing message to mission
			mission.strikemarktext, mission.strikeattackbrieftext = self:AddBriefingText(mission)

			-- add a container for strikezone target spawn templates
			if not mission.striketargetspawn then
				mission.striketargetspawn = {}
			end
			
			local strikeZone = ZONE:FindByName(strikeZoneName)
			if strikeZone then
				_msg = string.format("%sStrike Zone %s found.", self.traceTitle, mission.strikezone)
				BASE:T(_msg)

				-- generate spawn templates for late activated groups in the mission.strikezone
				local strikeTargetPrefix = mission.striketargetprefix

				-- build a set of groups with names containing the mission strikeTargetPrefix
				local setStrikeTargetGroups = SET_GROUP:New()
					:FilterPrefixes(strikeTargetPrefix)
					:FilterOnce()

				if setStrikeTargetGroups == nil then
					_msg = string.format("%sNo target templates found with prefix %s in zone %s", self.traceTitle, strikeTargetPrefix, strikeZoneName)
					BASE:E(_msg)
				else
					_msg = string.format("%sStrike Target templates in zone %s", self.traceTitle, strikeZoneName)
					BASE:T({_msg, setStrikeTargetGroups})
					-- add a spawn template for each group
					setStrikeTargetGroups:ForEachGroup(
						function(group)
							local groupName = group:GetName()

							-- add spawn to mission
							mission.striketargetspawn[groupName] = SPAWN:New(groupName)
								:InitUnControlled()

							_msg = string.format("%sCreate Strike Target spawn %s", self.traceTitle, groupName)
							BASE:T(_msg)

						end
					) -- end ForEachGroup
				end

				-- add asset spawn zones on map to mission if not already explicitly defined
				if mission.zones == nil then
					_msg = string.format("%sNo mission.zones pre-defined for strike zone %s. Building list of sub-zones using prefix.", self.traceTitle, strikeZoneName)
					BASE:T(_msg)

					mission.zones = {}
					local zonePrefix = mission.zoneprefix

					if zonePrefix then
						for _, zone in pairs(zonePrefix) do
							local class = zone.class
							local prefix = zone.prefix
							mission.zones[class] = {}
							local setStrikeZone = SET_ZONE:New()
								:FilterPrefixes(prefix)
								:FilterOnce()
							if setStrikeZone == nil then
								_msg = string.format("%sNo % class zones found with prefix %s for strike zone %s", self.traceTitle, class,  prefix, strikeZoneName)
								BASE:E(_msg)
							else
								setStrikeZone:ForEachZone(
									function(zone)
										local addZone = {}
										addZone.class = class
										addZone.loc = zone:GetName()
										addZone.is_open = true
										-- add zone to mission zone table
										table.insert(mission.zones[class], addZone)
									end)
								_msg = self.traceTitle .. "Zone table"
								BASE:T({_msg, mission.zones[class]})
							end
						end
					end
				end

				-- add static objects to mission if not already explicitly defined
				-- build a SET of static object within the mission.strikezone
				if mission.statics == nil then
					mission.statics = {}
					_msg = string.format("%sAdd Statics for mission %s.", self.traceTitle, strikeName)
					BASE:T(_msg)
	
					local setStrikeTargetStatics = SET_STATIC:New()
						:FilterZones({strikeZone})
						:FilterStart()
					
					-- add each static to the mission
					setStrikeTargetStatics:ForEachStatic(
						function(static)
							local addStatic = static
							local staticName = addStatic:GetName()
							addStatic.isAlive = true
							table.insert(mission.statics, addStatic)
							_msg = string.format("%sStatic %s added to mission %s", self.traceTitle, staticName, strikeName)
							BASE:T({_msg, static})
						end
					)
				end

				-- destroy mission statics. respawn them when mission is activated
				self:RemoveStatics(mission)
			
			else
				_msg = string.format("%sError! Strike Zone %s not found in MIZ!", self.traceTitle, mission.strikezone)
				BASE:E(_msg)
			end
		elseif mission.striketargets ~= nil then
			
				for index, strikeTarget in pairs(mission.striketargets)  do
					_msg = string.format("%s",self.traceTitle)
					BASE:T({_msg, strikeTarget = strikeTarget})


					-- Create a Strike Name
					-- get coordinates of strikezone
					local strikeZone = ZONE:FindByName(strikeTarget.strikezone)
					if strikeZone == nil then
						_msg = string.format("%sError adding menus. Zone %s for strike %s type %s in region %s %s not found!", self.traceTitle, strikeZone, strikeName, strikeType, strikeRegion)
						return
					end
					local spawnZoneCoord = strikeZone:GetCoordinate()
					-- convert to MGRS
					local spawnZoneMGRS = spawnZoneCoord:ToStringMGRS(_SETTINGS:SetMGRS_Accuracy(2))
					-- remove spaces from MGRS and take use the last four characters
					local strikeName = string.sub(string.gsub(spawnZoneMGRS, "%s+", ""), -6, -1)
	
					-- add mission context to the selected target
					strikeTarget.striketype = mission.striketype
					strikeTarget.strikeregion = mission.strikeregion
					strikeTarget.strikename = strikeName
					strikeTarget.strikeindex = strikeName
					strikeTarget.strikemission = mission.strikemission

					-- add text for map mark and briefing message to mission
					_msg = string.format("%sAdd briefing text to selected target %s", self.traceTitle, strikeName)
					BASE:T(_msg)
					if mission.options then
						strikeTarget.strikeattackbrieftext = {}
						strikeTarget.strikemarktext = {}
						for _, option in ipairs(mission.options) do
							local optionText = string.format(" %s ", option)
							strikeTarget.strikemarktext[option], strikeTarget.strikeattackbrieftext[option] = self:AddBriefingText(strikeTarget, optionText)
						end						
					else
						strikeTarget.strikemarktext, strikeTarget.strikeattackbrieftext = self:AddBriefingText(strikeTarget)
					end
				end

		-- else
		-- 	_msg = string.format("%sNo strikezone defined in root of mission %s.", self.traceTitle, strikeName)
		-- 	BASE:T(_msg)
		end

		_msg = string.format("%sAdding Menus for Type: %s, Region: %s, Name: %s, IVO: %s", self.traceTitle, strikeType, strikeRegion, strikeName, strikeIvo)
		BASE:T(_msg)

		-- add strike type menu
		if not self.menu[strikeType] then
			self.menu[strikeType] = MENU_COALITION:New( coalition.side.BLUE, 
				string.format("%s Strike", strikeType), 
				self.menu.top
			)
		end

		-- add region menu
		if not self.menu[strikeType][strikeRegion] then
			self.menu[strikeType][strikeRegion] = MENU_COALITION:New( coalition.side.BLUE, 
				string.format("%s Region", strikeRegion), 
				self.menu[strikeType]
			)
		end

		-- add mission menu
		--self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, strikeName .. " " .. strikeIvo, self.menu[strikeType][strikeRegion], self.SpawnStrikeTarget, self, mission ) -- add menu command to launch the mission		

		if strikeOptions ~= nil then -- add command menu for each option
			for _, option in ipairs(strikeOptions) do
				self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, 
					string.format("%s %s %s", strikeName, option, strikeIvo), 
					self.menu[strikeType][strikeRegion], 
					self.SpawnStrikeTarget, 
					self, 
					mission, 
					option 
				) -- add menu command to launch the mission
			end
		else -- add command menu
			self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, 
				string.format("%s %s", strikeName, strikeIvo), 
				self.menu[strikeType][strikeRegion], 
				self.SpawnStrikeTarget, 
				self, 
				mission
			) -- add menu command to launch the mission
		end
		
	end

	----------------------
	--- Convoy Strikes ---
	----------------------

	-- CONVOY spawn stub
	-- ConvoyAttackSpawn = SPAWN:New( "CONVOY_Default" )

	-- -- add CONVOY main submenu
	-- if not self.menu[MISSIONSTRIKE.enums.striketype.convoy] then
	-- 	self.menu[MISSIONSTRIKE.enums.striketype.convoy] = MENU_COALITION:New( coalition.side.BLUE, MISSIONSTRIKE.enums.striketype.convoy .. " Strike", self.menu.top )
	-- end
	
	-- -- add CONVOY CENTRAL command menus
	-- self.menu[MISSIONSTRIKE.enums.striketype.convoy]["Central"] = MENU_COALITION:New( coalition.side.BLUE, "Central" .. " Region", self.menu[MISSIONSTRIKE.enums.striketype.convoy] )
	-- self.menu[MISSIONSTRIKE.enums.striketype.convoy]["Central"][1] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Armoured Convoy", self.menu[MISSIONSTRIKE.enums.striketype.convoy]["Central"], self.SpawnConvoy, self, _hard_central_args )
	-- self.menu[MISSIONSTRIKE.enums.striketype.convoy]["Central"][2] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Supply Convoy", self.menu[MISSIONSTRIKE.enums.striketype.convoy]["Central"], self.SpawnConvoy, self, _soft_central_args )
	
	-- -- add CONVOY West command menus
	-- self.menu[MISSIONSTRIKE.enums.striketype.convoy]["West"] = MENU_COALITION:New( coalition.side.BLUE, "West" .. " Region", self.menu[MISSIONSTRIKE.enums.striketype.convoy] )
	-- self.menu[MISSIONSTRIKE.enums.striketype.convoy]["West"][1] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Armoured Convoy", self.menu[MISSIONSTRIKE.enums.striketype.convoy]["West"], self.SpawnConvoy, self, _hard_west_args )
	-- self.menu[MISSIONSTRIKE.enums.striketype.convoy]["West"][2] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Supply Convoy", self.menu[MISSIONSTRIKE.enums.striketype.convoy]["West"], self.SpawnConvoy, self, _soft_west_args )
	
end

function MISSIONSTRIKE:SpawnStrikeTarget (mission, option) -- "location name"

	--local mission = self.mission[strikeIndex]
	_msg = string.format("%sSpawnStrikeTarget() Type = %s, Name = %s.", self.traceTitle, mission.striketype, mission.strikeregion)
	BASE:T(_msg)

	local strikeType = mission.striketype

	if (strikeType == MISSIONSTRIKE.enums.striketype.camp) or (strikeType == MISSIONSTRIKE.enums.striketype.convoy) then
		_msg = string.format("%sActivating mission type: %s.", self.traceTitle, mission.striketype)
		BASE:T(_msg)

		self:SpawnRandomStrikeTarget(mission, option)
		--self:SpawnCamp(mission)

	elseif UTILS.IsInTable(MISSIONSTRIKE.enums.striketype, strikeType) then -- 
		_msg = string.format("%sActivating mission type: %s.", self.traceTitle, mission.striketype)
		BASE:T(_msg)
	
		if mission.is_open then

			local strikeRegion = mission.strikeregion
			local strikeIndex = mission.strikeindex
			local strikeIvo = mission.strikeivo
			local strikeName = mission.strikename
			--local strikeZone = ZONE:FindByName(mission.strikezone)

			-- create container for spawned objects if not already present
			if not mission.spawnedobjects then
				mission.spawnedobjects = {}
			end

			--local strikeName = mission.strikename

			-- -- add briefing summary to mission
			-- if strikeType == MISSIONSTRIKE.enums.striketype.airfield then
			-- 	mission.strikesummary = string.format("Air Interdiction mission against %s %s\n\n", strikeType, strikeName)
			-- else
			-- 	mission.strikesummary = string.format("Air Interdiction mission against %s %s IVO %s\n\n", strikeType, strikeName, strikeIvo)
			-- end

			-- _msg = string.format("%smission.strikesummary = %s", MISSIONSTRIKE.traceTitle, mission.strikesummary)
			-- BASE:T(_msg)

			local medZonesCount = #mission.zones["medium"] -- number of medium defzones
			local smallZonesCount = #mission.zones["small"] -- number of small defzones

			_msg = string.format("%sZone type counts; medium = %d, small = %d", self.traceTitle, medZonesCount, smallZonesCount)
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
			
			-- spawn static objects
			_msg = string.format("%sRefresh Statics for mission %s.", self.traceTitle, strikeName)
			BASE:T(_msg)

			self:AddStatics(mission)
			
			-- spawn target groups
			_msg = string.format("%s{Spawn Target Groups for mission} %s.", self.traceTitle, strikeName)
			BASE:T(_msg)

			_msg = string.format("%sstriketargetspawn", self.traceTitle)
			BASE:T({_msg,mission.striketargetspawn})

			for spawnName, spawnData in pairs(mission.striketargetspawn) do
				_msg = string.format("%s%s Spawn Target Group %s", self.traceTitle, mission.strikename, spawnName)
				BASE:T(_msg)
				local spawnGroup = {}
				local airbase = mission.striketargetspawn[spawnName].airbase
				spawnGroup = mission.striketargetspawn[spawnName]:Spawn()
				table.insert(mission.spawnedobjects, spawnGroup )
			end
			
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
			self.menu[strikeType][strikeIndex] = MENU_COALITION_COMMAND:New(
				coalition.side.BLUE, 
				"Remove ".. strikeName .. " " .. strikeIvo, 
				self.menu[strikeType], 
				self.RemoveStrikeAttack, 
				self, 
				mission
			)
	
			MISSIONSTRIKE:Briefing(mission)
		else
			_msg = string.format("The %s %s strike attack mission is already active!", mission.strikename, mission.striketype)
			MESSAGE:New( _msg, 5, "" ):ToAll()
			_msg = self.traceTitle .. _msg
			BASE:E(_msg)
		end
	else -- unknowm mission type!
		_msg = string.format("%sError. Unknown mission type: %s!", self.traceTitle, mission.striketype)
		BASE:E(_msg)
	end

end --SpawnStrikeTarget


--- Remove strike attack mission ---
function MISSIONSTRIKE:RemoveStrikeAttack (mission)
	--local mission = self.mission[strikeIndex]

	_msg = string.format("%sRemoveStrikeAttack() %s %s.", self.traceTitle, mission.striketype, mission.strikename)
	BASE:T(_msg)

	local strikeIndex = mission.strikeindex
	local strikeType = mission.striketype
	local strikeRegion = mission.strikeregion
	local strikeName = mission.strikename
	local strikeIvo = mission.strikeivo

	if not mission.is_open then

		-- remove map mark from map
		COORDINATE:RemoveMark( mission.mapMark )
		-- reset map
		mission.mapMark = nil 
		
		-- remove spawned objects
		--local objectcount = #mission.spawnedobjects
		--for index = 1, objectcount do
		for index, spawn in ipairs(mission.spawnedobjects) do
			if spawn:IsAlive() then
				_msg = string.format("%sRemove Spawned Object %s from mission %s %s.", self.traceTitle, spawn:GetName(), mission.striketype, mission.strikename)
				BASE:T(_msg)
				spawn:Destroy() --false
			end
		end
		-- clear list of now despawned objects
		mission.spawnedobjects = {}

		-- remove statics
		self:RemoveStatics(mission)

		--reset mission zone(s)
		if not mission.striketype == "Camp" then
			for _indexZone, zoneType in pairs(mission.zones) do
				for _indexType, zone in pairs(zoneType) do
					zone.is_open = true
				end
			end
		end
		
		-- remove reset menu option
		self.menu[strikeType][strikeIndex]:Remove()
		if not mission.striketype == "Camp" then
			-- reset mission menu
			self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New(
				coalition.side.BLUE, strikeName .. " " .. strikeIvo, self.menu[strikeType][strikeRegion], 
				self.SpawnStrikeTarget, 
				self, 
				mission
			) -- add menu command to launch the mission
			self.menu[strikeType][strikeRegion][strikeIndex] = MENU_COALITION_COMMAND:New(
				coalition.side.BLUE, strikeName .. " " .. strikeIvo, 
				self.menu[strikeType][strikeRegion], 
				self.SpawnStrikeTarget, 
				self, 
				mission
			) -- add menu command to launch the mission
		end

		-- set strike mission as available
		mission.is_open = true 

		_msg = string.format("The %s %s strike attack mission has been removed.", mission.striketype, mission.strikename)
		MESSAGE:New( _msg, 5, "" ):ToAll()
		_msg = self.traceTitle .. _msg
		BASE:T(_msg)

	else
		_msg = string.format("%sStrike attack mission %s %s is not active!", self.traceTitle, mission.striketype, mission.strikename)
		BASE:E(_msg)		
	end

end --RemoveStrikeAttack


function MISSIONSTRIKE:SpawnRandomStrikeTarget(mission, option)
	-- Select a random strike target within the region
	-- spawn assets in randomly selected zones within the camp

	local strikeType = mission.striketype
	local strikeRegion = mission.strikeregion

	-- table of target camps available for activation wthin the region
	local openTargets = {}

	-- build list of open targets
	for index, strikeTarget in ipairs(mission.striketargets) do 
		if strikeTarget.is_open then
			table.insert(openTargets, strikeTarget)
		end
	end

	-- select random target from list
	local targetCount = #openTargets
	local targetIndex = 1 -- default to first entry
	
	if targetCount > 1 then -- Randomize spawn location if more than 1 available
		targetIndex = math.random ( 1, targetCount)
	elseif targetCount == 0 then -- no open targets remaining
		_msg = string.format("All %s Strike missions for the Region % are already active!", strikeType, strikeRegion)
		MESSAGE:New( _msg, 5, "" ):ToAll()
		_msg = self.traceTitle .. _msg
		BASE:E(_msg)
		return
	end

	-- select the target from the list
	local selectedTarget = openTargets[targetIndex]
	if option then
		selectedTarget.option = option
	end

	local strikeName = selectedTarget.strikename

	_msg = string.format("%s%s %s Selected Target %s.", self.traceTitle, strikeType, strikeRegion, strikeName)
	BASE:T({_msg, selectedTarget = selectedTarget})

	-- find the zone object for the selected
	local zone = ZONE:FindByName(selectedTarget.strikezone)

	if zone then

		selectedTarget.zone = zone

		if not selectedTarget.spawnedobjects then
			selectedTarget.spawnedobjects = {}
		end

		if selectedTarget.striketype == MISSIONSTRIKE.enums.striketype.camp then

			self:SpawnCamp(selectedTarget)
			
		elseif selectedTarget.striketype == MISSIONSTRIKE.enums.striketype.convoy then

			self:SpawnConvoy(selectedTarget)
			
		else
			_msg = string.format("%sstriketype %s for selected target %s not recognised!", self.traceTitle, selectedTarget.striketype, selectedTarget.strikename)
			BASE:E(_msg)
		end

		--  mark the selected target target as closed
		selectedTarget.is_open = false

		self:Briefing(selectedTarget)
		
		-- add remove menu option for the selected target
		self.menu[strikeType][strikeName] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Remove ".. strikeName,  self.menu[strikeType], self.RemoveStrikeAttack, self, selectedTarget )

	else
		_msg = string.format("%sstrikezone %s for selected target not found!", self.traceTitle, selectedTarget.strikezone)
		BASE:E(_msg)
		return
	end
	
end


function MISSIONSTRIKE:SpawnCamp(selectedTarget)

	local strikeType = selectedTarget.striketype
	local strikeName = selectedTarget.strikename
	local strikeRegion = selectedTarget.strikeregion
	local zone = selectedTarget.zone
 
	_msg = string.format("%sSpawning mission type %s for mission %s in region %s.", 
		self.traceTitle, 
		strikeType,
		strikeName,
		strikeRegion
	)
	BASE:T(_msg)

	local spawnTemplates = MISSIONSTRIKE.campTemplates.defence
	local campSpawn = MISSIONSTRIKE.campSpawns["main"]:InitRandomizeTemplate(spawnTemplates)
		:InitRandomizeUnits( true, 35, 5 )
		:InitHeading( 1,359 )
		:OnSpawnGroup(
			function(SpawnGroup)
				-- add this spawngroup to spawned objects list
				table.insert(selectedTarget.spawnedobjects, SpawnGroup)
				-- spawn tents
				MISSIONSTRIKE.campSpawns.tentGroup:InitRandomizeUnits( true, 77, 35 )
					:OnSpawnGroup(
						function(SpawnGroup)
							-- add this spawngroup to spawned objects list
							table.insert(selectedTarget.spawnedobjects, SpawnGroup)
						end
						,zone, selectedTarget)
					:SpawnInZone ( zone )
				-- spawn infantry
				MISSIONSTRIKE.campSpawns.infantryGroup:InitRandomizeUnits( true, 77, 5 )
					:OnSpawnGroup(
						function(SpawnGroup)
							-- add this spawngroup to spawned objects list
							table.insert(selectedTarget.spawnedobjects, SpawnGroup)
						end
						,zone, selectedTarget)
					:SpawnInZone(zone)
			end
			,zone, selectedTarget 
		)
	campSpawn:SpawnInZone( zone )

end

-- function MISSIONSTRIKE:SpawnCamp(mission)
-- 	-- Select a random strike target within the region
-- 	-- spawn assets in randomly selected zones within the camp

-- 	local strikeType = mission.striketype
-- 	local strikeRegion = mission.strikeregion

-- 	-- table of target camps available for activation wthin the region
-- 	local openTargets = {}

-- 	-- build list of open targets
-- 	for index, strikeTarget in ipairs(mission.striketargets) do 
-- 		if strikeTarget.is_open then
-- 			table.insert(openTargets, strikeTarget)
-- 		end
-- 	end

-- 	-- select random target from list
-- 	local targetCount = #openTargets
-- 	local targetIndex = 1 -- default to first entry
	
-- 	if targetCount > 1 then -- Randomize spawn location if more than 1 available
-- 		targetIndex = math.random ( 1, targetCount)
-- 	elseif targetCount == 0 then -- no open targets remaining
-- 		_msg = string.format("All %s Strike missions for the Region % are already active!", strikeType, strikeRegion)
-- 		MESSAGE:New( _msg, 5, "" ):ToAll()
-- 		_msg = self.traceTitle .. _msg
-- 		BASE:E(_msg)
-- 		return
-- 	end

-- 	-- select the target from the list
-- 	local selectedTarget = openTargets[targetIndex]

-- 	_msg = string.format("%s%s %s Selected Target.", self.traceTitle, strikeType, strikeRegion)
-- 	BASE:T({_msg, selectedTarget = selectedTarget})

-- 	-- find the zone object for the selected
-- 	local zone = ZONE:FindByName(selectedTarget.strikezone)

-- 	if zone then

-- 		if not selectedTarget.spawnedobjects then
-- 			selectedTarget.spawnedobjects = {}
-- 		end

-- 		local spawnTemplates = MISSIONSTRIKE.campTemplates.defence
-- 		local campSpawn = MISSIONSTRIKE.campSpawns["main"]:InitRandomizeTemplate(spawnTemplates)
-- 			:InitRandomizeUnits( true, 35, 5 )
-- 			:InitHeading( 1,359 )
-- 			:OnSpawnGroup(
-- 				function(SpawnGroup)
-- 					-- add this spawngroup to spawned objects list
-- 					table.insert(selectedTarget.spawnedobjects, SpawnGroup)
-- 					-- spawn tents
-- 					MISSIONSTRIKE.campSpawns.tentGroup:InitRandomizeUnits( true, 77, 35 )
-- 						:OnSpawnGroup(
-- 							function(SpawnGroup)
-- 								-- add this spawngroup to spawned objects list
-- 								table.insert(selectedTarget.spawnedobjects, SpawnGroup)
-- 							end
-- 							,zone, selectedTarget)
-- 						:SpawnInZone ( zone )
-- 					-- spawn infantry
-- 					MISSIONSTRIKE.campSpawns.infantryGroup:InitRandomizeUnits( true, 77, 5 )
-- 						:OnSpawnGroup(
-- 							function(SpawnGroup)
-- 								-- add this spawngroup to spawned objects list
-- 								table.insert(selectedTarget.spawnedobjects, SpawnGroup)
-- 							end
-- 							,zone, selectedTarget)
-- 						:SpawnInZone(zone)
-- 				end
-- 				,zone, selectedTarget 
-- 			)
-- 		campSpawn:SpawnInZone( zone )

-- 		--  mark the selected target target as closed
-- 		selectedTarget.is_open = false

-- 		--[[-- Create a Strike Name
-- 		-- get coordinates of strikezone
-- 		local spawnZoneCoord = zone:GetCoordinate(selectedTarget.zone) 
-- 		-- convert to MGRS
-- 		local spawnZoneMGRS = spawnZoneCoord:ToStringMGRS(_SETTINGS:SetMGRS_Accuracy(2))
-- 		-- remove spaces from MGRS and take use the last four characters
-- 		local strikeName = string.sub(string.gsub(spawnZoneMGRS, "%s+", ""), -6, -1)

-- 		-- add mission context to the selected target
-- 		selectedTarget.striketype = mission.striketype
-- 		selectedTarget.strikeregion = mission.strikeregion
-- 		selectedTarget.strikename = strikeName
-- 		selectedTarget.strikeindex = strikeName
-- 		selectedTarget.strikemission = mission.strikemission
-- 		selectedTarget.strikesummary = string.format("Air Interdiction mission against %s %s", strikeType, strikeName)


-- 		-- add text for map mark and briefing message to mission
-- 		if not (selectedTarget.strikemarktext or selectedTarget.strikeattackbrieftext) then
-- 			_msg = string.format("%sAdd briefing text to selected target %s", self.traceTitle, strikeName)
-- 			BASE:T(_msg)
-- 			selectedTarget.strikemarktext, selectedTarget.strikeattackbrieftext = self:AddBriefingText(selectedTarget)
-- 		end
--  		--]]
		
-- 		self:Briefing(selectedTarget)
		
-- 		local strikeName = selectedTarget.strikename
-- 		-- add remove menu option for the selected target
-- 		self.menu[strikeType][strikeName] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Remove ".. strikeName,  self.menu[strikeType], self.RemoveStrikeAttack, self, selectedTarget )

-- 	else
-- 		_msg = string.format("%sCamp spawn zone %s for selected target not found!", self.traceTitle, selectedTarget.strikezone)
-- 		BASE:E(_msg)
-- 		return
-- 	end
	
-- end


function MISSIONSTRIKE:SpawnConvoy(selectedTarget) -- ConvoyTemplates, SpawnHost {conv, dest, destzone, strikecoords, is_open}, ConvoyType, ConvoyThreats

	local strikeType = selectedTarget.striketype
	local strikeName = selectedTarget.strikename
	local strikeRegion = selectedTarget.strikeregion
	local zone = selectedTarget.zone

	_msg = string.format("%sSpawning mission type %s for mission %s in region %s.", 
		self.traceTitle, 
		strikeType,
		strikeName,
		strikeRegion
	)
	BASE:T(_msg)

	--[[ -- OLD SPAWNCONVOY
	select a random convoy within the region
	spawn either a supply convoy or an armoured convoy


	
	local TemplateTable = _args[1]
	local SpawnHostTable = _args[2]
	local ConvoyType = _args[3]
	local ConvoyThreats = _args[4]
	
	
	local SpawnIndex = math.random ( 1, #SpawnHostTable )
	local SpawnHost = SpawnHostTable[SpawnIndex].conv
	local DestZone = SpawnHostTable[SpawnIndex].destzone

 	SpawnHost:InitRandomizeTemplate( TemplateTable )
		:OnSpawnGroup(
			function(SpawnGroup)
				CheckConvoy = SCHEDULER:New( nil, 
					function()
						if SpawnGroup:IsPartlyInZone( DestZone ) then
							SpawnGroup:Destroy() --false
						end
					end
					,{}, 0, 60)
			end
			)
		:Spawn()

	--- Create Mission Mark on F10 map ---
	-- MissionMapMark(CampTableIndex)
	local StrikeMarkZone = SpawnHost -- ZONE object for zone named in strikezone 
	local StrikeMarkZoneCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone

	local StrikeMarkType = MISSIONSTRIKE.enums.striketype.convoy
	local StrikeMarkCoordsLLDMS = StrikeMarkZoneCoord:ToStringLLDMS(SETTINGS:SetLL_Accuracy(0)) --mission.strikecoords
	local StrikeMarkCoordsLLDDM = StrikeMarkZoneCoord:ToStringLLDDM(SETTINGS:SetLL_Accuracy(3)) --mission.strikecoords
	local StrikeMarkCoordsMGRS = StrikeMarkZoneCoord:ToStringMGRS(SETTINGS:SetMGRS_Accuracy(5)) --mission.strikecoords

	local StrikeMarkLabel = StrikeMarkType .. " Strike\n" 
		.. StrikeMarkCoordsLLDMS .. "\n"
		.. StrikeMarkCoordsLLDDM .. "\n"
		.. StrikeMarkCoordsMGRS 
	local StrikeMark = StrikeMarkZoneCoord:MarkToAll(StrikeMarkLabel, true) -- add mark to map

	--SpawnCampsTable[ CampTableIndex ].strikemarkid = StrikeMark -- add mark ID to table 


	local ConvoyAttackBrief = "\n\n++++++++++++++++++++++++++++++++++++\n\n" 
		.. "Intelligence is reporting an enemy " .. ConvoyType .. " convoy\n"
		.. "believed to be routing to "	.. SpawnHostTable[SpawnIndex].dest .. ".\n\n"
		.. "Mission:  LOCATE AND DESTROY THE CONVOY.\n\n"
		.. "Last Known Position:\n"
		.. StrikeMarkCoordsLLDMS .. "\n"
		.. StrikeMarkCoordsLLDDM .. "\n"
		.. StrikeMarkCoordsMGRS .. "\n\n"
		.. ConvoyThreats .. "\n\n"
		.. "++++++++++++++++++++++++++++++++++++"
		
	MESSAGE:New( ConvoyAttackBrief, 5, "" ):ToAll()  ]]
	
	
		
end --SpawnConvoy  


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
			local defenceTemplateIndex = math.random( 1, #self.defenceTemplates[AssetType] ) -- generate random index for template
			local assetTemplate = self.defenceTemplates[AssetType][defenceTemplateIndex] -- select indexed template
			-- local assetSpawn = self.spawn["DEFSTUB_" .. assetTemplate] -- [contenation for name of generated DEFSTUB_ spawn]
			local assetSpawn = self.defenceSpawns[assetTemplate] -- [contenation for name of generated DEFSTUB_ spawn]
			local assetzoneindex = TableStrikeAssetZones[index]
			local assetspawnzone = ZONE:FindByName( mission.zones[AssetZoneType][assetzoneindex].loc ) -- [concatenation for name of generated spawnzone]
			
			-- assetSpawn:SpawnInZone( assetspawnzone ) -- spawn asset in zone in generated zone list
			local assetSpawnGroup = assetSpawn:SpawnInZone( assetspawnzone ) -- spawn asset in zone in generated zone list
			
			--local assetspawngroup, assetspawngroupindex = assetSpawn:GetLastAliveGroup()
			table.insert(mission.spawnedobjects, assetSpawnGroup ) -- add spawned asset to spawnobjects list
		end

	end

end


function MISSIONSTRIKE:AddBriefingText(mission, option)

	--- Create Mission Mark textp ---
	local strikeMarkZone = ZONE:FindByName( mission.strikezone ) -- ZONE object for zone named in strikezone 
	local strikeMarkZoneCoord = strikeMarkZone:GetCoordinate() -- get coordinates of strikezone

	local strikeMarkName = mission.strikename
	local strikeMarkOption = option or " "
	local strikeMarkType = mission.striketype
	local strikeMarkRegion = mission.strikeregion
	local strikeMarkIvo = mission.strikeivo
	local strikeAttackMission = mission.strikemission
	local strikeMarkCoordsLLDMS = strikeMarkZoneCoord:ToStringLLDMS(SETTINGS:SetLL_Accuracy(0)) --mission.strikecoords
	local strikeMarkCoordsLLDDM = strikeMarkZoneCoord:ToStringLLDDM(SETTINGS:SetLL_Accuracy(3)) --mission.strikecoords
	local strikeMarkCoordsMGRS = strikeMarkZoneCoord:ToStringMGRS(SETTINGS:SetMGRS_Accuracy(5)) --mission.strikecoords

	-- add briefing summary to mission
	local strikeAttackSummary = ""

	if strikeMarkType == MISSIONSTRIKE.enums.striketype.airfield then
		strikeAttackSummary = string.format("Air Interdiction mission against %s %s", 
			strikeMarkType, 
			strikeMarkName
		)
	elseif strikeMarkType == MISSIONSTRIKE.enums.striketype.camp then
		strikeAttackSummary = string.format("Air Interdiction mission against %s region %s %s", 
			strikeMarkRegion, 
			strikeMarkType, 
			strikeMarkName
		)
	elseif strikeMarkType == MISSIONSTRIKE.enums.striketype.convoy then
		local destName = mission.destname
		strikeAttackSummary = string.format("Air Interdiction mission in %s region against %s%s routing to %s\n\nLast known postion shown below",
			strikeMarkRegion, 
			strikeMarkOption,
			strikeMarkType, 
			destName
		)
		strikeMarkRegion = string.format("%s\nInitial reported location", 
			strikeMarkRegion
		)
	else -- default summary
		strikeAttackSummary = string.format("Air Interdiction mission against %s %s IVO %s", 
			strikeMarkType, 
			strikeMarkName, 
			strikeMarkIvo
		)
	end

	_msg = string.format("%smission.strikesummary = %s", MISSIONSTRIKE.traceTitle, strikeAttackSummary)
	BASE:T(_msg)

	local strikeMarkText = string.format("%s%s%s Strike %s\n%s\n%s\n%s", 
		strikeMarkName,
		strikeMarkOption, 
		strikeMarkType, 
		strikeMarkRegion, 
		strikeMarkCoordsLLDMS, 
		strikeMarkCoordsLLDDM, 
		strikeMarkCoordsMGRS
	)

	local strikeAttackBriefText = string.format("\n\n++++++++++++++++++++++++++++++++++++\n\n%s\n\nMission: %s\n\nCoordinates:\n%s\n%s\n%s", 
		strikeAttackSummary, 
		strikeAttackMission, 
		strikeMarkCoordsLLDMS, 
		strikeMarkCoordsLLDDM, 
		strikeMarkCoordsMGRS 
	)

	return strikeMarkText, strikeAttackBriefText

end


function MISSIONSTRIKE:Briefing(mission)

	_msg = string.format("%sBriefing()", self.traceTitle)
	BASE:T(_msg)

	local strikeType = mission.striketype
	local strikeName = mission.strikename
	local strikeRegion = mission.strikeregion
	local strikeZone = mission.strikezone
	local strikeOption = mission.option

	local strikeAttackBrief = mission.strikeattackbrieftext
	if strikeOption then
		strikeAttackBrief = mission.strikeattackbrieftext[strikeOption]
	end

	_msg = string.format("%s", self.traceTitle)
	BASE:T({_msg, strikeAttackBrief = strikeAttackBrief})
	

	if strikeAttackBrief ~= nil then
		local strikeThreats = mission.strikeThreats
	
		if strikeThreats then
			strikeThreats = string.format("Threats: %s\n\n++++++++++++++++++++++++++++++++++++", 
				strikeThreats
			)
		else 
			strikeThreats = "++++++++++++++++++++++++++++++++++++"
		end
	
		strikeAttackBrief = string.format("%s\n\n%s",
			strikeAttackBrief,
			strikeThreats
		) 
	
		MESSAGE:New (strikeAttackBrief, 5, "" ):ToAll()
			
	else
		_msg = string.format("%sError showing briefing. Briefing text for mission %s type %s in region %s not found!", 
			self.traceTitle, 
			strikeName, 
			strikeType, 
			strikeRegion
		)
		return
	end

	--- Create Mission Mark on F10 map ---
	local strikeMarkText = mission.strikemarktext
	if strikeOption then
		strikeMarkText = mission.strikemarktext[strikeOption]
	end

	local strikeMarkZone = ZONE:FindByName( strikeZone ) -- ZONE object for zone named in strikezone

	if strikeMarkZone ~= nil then
		_msg = self.traceTitle
		BASE:T({_msg, strikeMarkZone = strikeMarkZone})

		local strikeMarkZoneCoord = strikeMarkZone:GetCoordinate() -- get coordinates of strikezone
		mission.mapMark = strikeMarkZoneCoord:MarkToAll(strikeMarkText, true) -- add mark to map
	else
		_msg = string.format("%sError showing briefing. Zone %s for mission %s type %s in region %s not found!", 
			self.traceTitle, 
			strikeMarkZone, 
			strikeName, 
			strikeType, 
			strikeRegion
		)
		return
	end

end


function MISSIONSTRIKE:AddSpawnTemplate(templateName, spawnCategory, spawnCountry, spawnCoalition)

	local category = spawnCategory or Group.Category.GROUND
	local country = spawnCountry or self.enums.default.countryidred
	local coalition = spawnCoalition or self.enums.default.coalitionred
	local addSpawn = nil

	if GROUP:FindByName(templateName) then
		_msg = string.format("%sAddSpawn(). using MIZ temaplate %s.", self.traceTitle, templateName)
		BASE:T(_msg)
		addSpawn = SPAWN:New( templateName )
	elseif self.template[templateName] then
		_msg = string.format("%sAddSpawn(). Using MISSIONSTRIKE temaplate %s.", self.traceTitle, templateName)
		BASE:T(_msg)
		addSpawn = SPAWN:NewFromTemplate(self.template[templateName],templateName)
			:InitCountry(country) -- set spawn countryid
			:InitCoalition(coalition) -- set spawn coalition
			:InitCategory(category) -- set category
	else
		_msg = string.format("%sError! AddSpawn(). Template %s not found!", self.traceTitle, templateName)
		BASE:E(_msg)
	end
	return addSpawn
end


function MISSIONSTRIKE:RemoveStatics(mission)

	if mission.statics then
		-- respawn each static objects
		for _, static in pairs(mission.statics) do
			staticName = static:GetName()
			static.isAlive = false
			_msg = string.format("%s%s Destroy Static %s", self.traceTitle, mission.strikename, staticName)
			BASE:T({_msg, static})
			static:Destroy()
		end
	else
		_msg = string.format("%sRemoveStatics(): No statics table for mission %s", self.traceTitle, mission.strikename)
		BASE:T(_msg)
	end
	
end


function MISSIONSTRIKE:AddStatics(mission)

	-- respawn each static objects
	for _, static in pairs(mission.statics) do
		staticName = static:GetName()
		static.isAlive = true
		_msg = string.format("%s%s Respawn Static %s", self.traceTitle, mission.strikename, staticName)
		BASE:T({_msg, static})
		static:ReSpawn(country.id.RUSSIA)
	end

end

-- DEFAULT DATA

-- enumerators
MISSIONSTRIKE.enums = {
	default = {
        coalitionred = coalition.side.RED,
        countryidred = country.id.RUSSIA,
	},
	region = {
		east = "East",
		central = "Central",
		west = "West",
		north = "North",
	},
	striketype = { -- strike mission types
		airfield = "Airfield",
		factory = "Factory",
		port = "Port",
		bridge = "Bridge",
		convoy = "Convoy",
		camp = "Camp",
	},
	strikemission = {
		airfield = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		factory = {
			weapons = "DESTROY WEAPONS MANUFACTURING FACILITY",
			chemical = "DESTROY CHEMICAL PRODUCTION FACILITY",
		},
		bridge = {
			road = "DESTROY ROAD BRIDGE",
			rail = "DESTROY RAIL BRIDGE",
			roadrail = "DESTROY ROAD AND RAIL BRIDGES",
		},
		port = {
			fuel = "DESTROY FUEL PROCESSING AND STORAGE FACILITIES",
			docks = "DESTROY CARGO DOCKS AND VESSELS",
			ships = "DESTROY DOCKED CARGO VESSELS",
		},
		camp = "FIND AND DESTROY INSURGENT CAMP",
		convoy = "LOCATE AND DESTROY ENEMY CONVOY",
	},
	convoy = {
		supply = "Supply",
		armoured = "Armoured"
	},
		
}

-- airfield defence asset templates
MISSIONSTRIKE.defenceTemplates = {
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
		"ARMOUR_Heavy_01",
		"ARMOUR_Heavy_02",
		"ARMOUR_Heavy_03",
		"ARMOUR_Heavy_04",
	},
}

-- camp asset templates
MISSIONSTRIKE.campTemplates = {
	main = 	"CAMP_Heavy",
	tentGroup = "CAMP_Tent_Group",
	infantryGroup = "CAMP_Inf_02",
	defence = {
		"ARMOUR_Heavy_01",
		"ARMOUR_Heavy_02",
		"ARMOUR_Heavy_03",
		"ARMOUR_Heavy_04",
	}
}

-- convoy templates
MISSIONSTRIKE.convoyTemplates = {
	main = "CONVOY_base",
	convoy = {
		light = {
			"CONVOY_light-1",
			"CONVOY_light-2",
		},
		heavy = {
			"CONVOY_heavy-1",
			"CONVOY_heavy-2",
		},
	},
}

-- pre-defined spawn templates to be used as an alternative to placing late activated templates in the miz
MISSIONSTRIKE.template = {
	-- ["SAM_Sa3Battery"] = {},
	-- ["SAM_Sa6Battery"] = {},
	-- ["AAA_Zu23Ural"] = {},
	-- ["AAA_Zu23Emplacement"] = {},
	-- ["AAA_Zu23Closed"] = {},
	-- ["AAA_Zsu23Shilka"] = {},
	-- ["SAM_Sa18Manpads"] = {},
	-- ["SAM_Sa18sManpads"] = {},
	-- ["ARMOUR_Heavy_01"] = {},
	-- ["ARMOUR_Heavy_02"] = {},
	-- ["ARMOUR_Heavy_03"] = {},
	-- ["ARMOUR_Heavy_04"] = {},
	-- ["CAMP_Heavy"] = {},
	-- ["CAMP_Tent_Group"] = {},
	-- ["CAMP_Inf_02"] = {},
	-- ["CONVOY_base"] = {},
	-- ["CONVOY_light-1"] = {},
	-- ["CONVOY_light-2"] = {},
	-- ["CONVOY_heavy-1"] = {},
	-- ["CONVOY_heavy-2"] = {},
}
