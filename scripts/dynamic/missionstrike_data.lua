env.info( "[JTF-1] staticranges_data" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- STRIKE MISSION SETTINGS FOR MIZ
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- This file MUST be loaded AFTER missionstrike.lua
--
-- These values are specific to the miz and will override the default values in MISSIONSTRIKE.default
--

-- Error prevention. Create empty container if module core lua not loaded.
if not MISSIONSTRIKE then 
	MISSIONSTRIKE = {}
	MISSIONSTRIKE.traceTitle = "[JTF-1 MISSIONSTRIKE] "
	_msg = self.traceTitle .. "CORE FILE NOT LOADED!"
	BASE:E(_msg)
	-- EXIT MODULE DATA
	return
end

----------------------------------
--- Strike Attack Mission Data ---
----------------------------------

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


MISSIONSTRIKE.missions = { -- TableStrikeAttack
	------------ AIRFIELD ------------
	{ -- Gelendzhik Airfield-North
		striketype = MISSIONSTRIKE.enums.striketype.airfield,
        strikeregion = MISSIONSTRIKE.enums.region.north,                            
		strikename = "Novorossiysk",
		strikeivo = "AFB",
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		strikezone = "ZONE_NovorossiyskStrike",
		striketargetprefix = "TARGET_NOVOROSSIYSK",
		zoneprefix = {
			{class = "small", prefix = "ZONE_NovorossiyskSmall"},
			{class = "medium", prefix = "ZONE_NovorossiyskMed"},
		},
		defassets = {
			sam = 2,
			aaa = 4,
			manpad = 2,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Sukhumi
	{ -- Gelendzhik Airfield-North
		striketype = MISSIONSTRIKE.enums.striketype.airfield,
        strikeregion = MISSIONSTRIKE.enums.region.north,                            
		strikename = "Gelendzhik",
		strikeivo = "AFB",
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		strikezone = "ZONE_Strike_Gelendzhik",
		striketargetprefix = "TARGET_GELENDZHIK",
		zoneprefix = {
			{class = "small", prefix = "ZONE_Small_Gelendzhik"},
			{class = "medium", prefix = "ZONE_Med_Gelendzhik"},
		},
		defassets = {
			sam = 2,
			aaa = 4,
			manpad = 2,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Sukhumi
	{ -- Maykop Airfield-West
		striketype = MISSIONSTRIKE.enums.striketype.airfield,
        strikeregion = MISSIONSTRIKE.enums.region.west,                            
		strikename = "Maykop",
		strikeivo = "AFB",
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MaykopStrike",
		striketargetprefix = "TARGET_MAYKOP",
		zoneprefix = {
			{class = "small", prefix = "ZONE_MaykopSmall"},
			{class = "medium", prefix = "ZONE_MaykopMed"},
		},
		defassets = {
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Maykop
	{ -- Sochi Airfield-West
		striketype = MISSIONSTRIKE.enums.striketype.airfield,
        strikeregion = MISSIONSTRIKE.enums.region.west,                            
		strikename = "Sochi",
		strikeivo = "AFB",
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_SochiStrike",
		striketargetprefix = "TARGET_SOCHI",
		zoneprefix = {
			{class = "small", prefix = "ZONE_SochiSmall"},
			{class = "medium", prefix = "ZONE_SochiMed"},
		},
		defassets = { -- max number of each defence asset
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Sochi
	{ -- Gudauta Airfield-West
		striketype = MISSIONSTRIKE.enums.striketype.airfield,
        strikeregion = MISSIONSTRIKE.enums.region.west,                            
		strikename = "Gudauta",
		strikeivo = "AFB",
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_Strike_Gudauta",
		striketargetprefix = "TARGET_GUDAUTA",
		zoneprefix = {
			{class = "small", prefix = "ZONE_Small_Gudauta"},
			{class = "medium", prefix = "ZONE_Med_Gudauta"},
		},
		defassets = {
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Gudauta
	{ -- Sukhumi Airfield-West
		striketype = MISSIONSTRIKE.enums.striketype.airfield,
        strikeregion = MISSIONSTRIKE.enums.region.west,                            
		strikename = "Sukhumi",
		strikeivo = "AFB",
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		strikezone = "ZONE_Strike_Sukhumi",
		striketargetprefix = "TARGET_SUKHUMI",
		zoneprefix = {
			{class = "small", prefix = "ZONE_Small_Sukhumi"},
			{class = "medium", prefix = "ZONE_Med_Sukhumi"},
		},
		defassets = {
			sam = 2,
			aaa = 4,
			manpad = 1,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Sukhumi
	{ -- Mineralnye Airfield-Central
		striketype = MISSIONSTRIKE.enums.striketype.airfield,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "Mineralnye",
		strikeivo = "AFB",
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MineralnyeStrike",
		striketargetprefix = "TARGET_Mineralnye",
		zoneprefix = {
			{class = "small", prefix = "ZONE_MineralnyeSmall"},
			{class = "medium", prefix = "ZONE_MineralnyeMed"},
		},
		defassets = { 
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Mineralnye
	{ -- Nalchik Airfield-Central
		striketype = MISSIONSTRIKE.enums.striketype.airfield,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "Nalchik",
		strikeivo = "AFB",
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_NalchikStrike",
		striketargetprefix = "TARGET_Nalchik",
		zoneprefix = {
			{class = "small", prefix = "ZONE_NalchikSmall"},
			{class = "medium", prefix = "ZONE_NalchikMed"},
		},
		defassets = { 
			sam = 4,
			aaa = 5,
			manpad = 3,
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Nalchik
	{ -- Mozdok Airfield-East
		striketype = MISSIONSTRIKE.enums.striketype.airfield, --type of strike; Airfield, Factory, Bridge, Communications, C2
		strikeregion = MISSIONSTRIKE.enums.region.east, -- Region in which mission is located (East, Central, West)                       
		strikename = "Mozdok", -- Friendly name for the location used in briefings, menus etc. Currently the same as the key, but will probably change
		strikeivo = "AFB", -- "in the vacinity of" ("AFB" if airfield, "[TOWN/CITY]" other targets)
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR", -- text threats description
		strikezone = "ZONE_MozdokStrike", -- ME zone at center of strike location
		striketargetprefix = "TARGET_MOZDOK",
		zoneprefix = {
			{class = "small", prefix = "ZONE_MozdokSmall"},
			{class = "medium", prefix = "ZONE_MozdokMed"},
		},
		defassets = {
			sam = 4,
			aaa = 5,
			manpad = 3, 
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Mozdok
	{ -- Beslan Airfield-East
		striketype = MISSIONSTRIKE.enums.striketype.airfield, --type of strike; Airfield, Factory, Bridge, Communications, C2
        strikeregion = MISSIONSTRIKE.enums.region.east, -- Region in which mission is located (East, Central, West)                       
		strikename = "Beslan", -- Friendly name for the location used in briefings, menus etc. Currently the same as the key, but will probably change
		strikeivo = "AFB", -- "in the vacinity of" ("AFB" if airfield, "[TOWN/CITY]" other targets)
		strikemission = MISSIONSTRIKE.enums.strikemission.airfield, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR", -- text threats description
		strikezone = "ZONE_BeslanStrike", -- ME zone at center of strike location
		striketargetprefix = "TARGET_BESLAN`",
		zoneprefix = {
			{class = "small", prefix = "ZONE_BeslanSmall"},
			{class = "medium", prefix = "ZONE_BeslanMed"},
		},
		defassets = {
			sam = 4,
			aaa = 5,
			manpad = 3, 
			armour = 3,
		},
		spawnobjects = {},
		is_open = true,
	},-- End Beslan
	------------ FACTORY ------------
	{ -- LN83 Factory-Central
		striketype = MISSIONSTRIKE.enums.striketype.factory,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "LN83",
		strikeivo = "Chiora",
		strikemission = MISSIONSTRIKE.enums.strikemission.factory.weapons, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LN83Strike",
		striketargetprefix = "TARGET_CHIORA",
		zoneprefix = {
			{class = "small", prefix = "ZONE_LN83Small"},
			{class = "medium", prefix = "ZONE_LN83Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End LN83
	{ -- LN77 Factory-Central
		striketype = MISSIONSTRIKE.enums.striketype.factory,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "LN77",
		strikeivo = "Verh.Balkaria",
		strikemission = MISSIONSTRIKE.enums.strikemission.factory.weapons, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LN77Strike",
		striketargetprefix = "TARGET_LN77",
		zoneprefix = {
			{class = "small", prefix = "ZONE_LN77Small"},
			{class = "medium", prefix = "ZONE_LN77Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 1, 
			armour = 3, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End LN77
	{ -- LP30 Factory-Central
		striketype = MISSIONSTRIKE.enums.striketype.factory,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "LP30",
		strikeivo = "Tyrnyauz",
		strikemission = MISSIONSTRIKE.enums.strikemission.factory.weapons, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LP30Strike",
		striketargetprefix = "TARGET_LP30",
		zoneprefix = {
			{class = "small", prefix = "ZONE_LP30Small"},
			{class = "medium", prefix = "ZONE_LP30Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End LP30
	{ -- MN76 Factory-East
		striketype = MISSIONSTRIKE.enums.striketype.factory,
        strikeregion = MISSIONSTRIKE.enums.region.east,                            
		strikename = "MN76",
		strikeivo = "Vladikavkaz",
		strikemission = MISSIONSTRIKE.enums.strikemission.factory.weapons, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MN76Strike",
		striketargetprefix = "TARGET_MN76",
		zoneprefix = {
			{class = "small", prefix = "ZONE_MN76Small"},
			{class = "medium", prefix = "ZONE_MN76Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End MN76
	------------ PORT ------------
	{ -- DK05 Port-North
		striketype = MISSIONSTRIKE.enums.striketype.port,
        strikeregion = MISSIONSTRIKE.enums.region.north,                            
		strikename = "DK05",
		strikeivo = "Novorossiysk",
		strikemission = MISSIONSTRIKE.enums.strikemission.port.docks, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_DK05Strike",
		striketargetprefix = "TARGET_DK05",
		zoneprefix = {
			{class = "small", prefix = "ZONE_DK05Small"},
			{class = "medium", prefix = "ZONE_DK05Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End DK05
	{ -- EJ08 Port-North
		striketype = MISSIONSTRIKE.enums.striketype.port,
        strikeregion = MISSIONSTRIKE.enums.region.north,                            
		strikename = "EJ08",
		strikeivo = "Tuapse",
		strikemission = MISSIONSTRIKE.enums.strikemission.port.fuel, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_EJ08Strike",
		striketargetprefix = "TARGET_EJ08",
		zoneprefix = {
			{class = "small", prefix = "ZONE_EJ08Small"},
			{class = "medium", prefix = "ZONE_EJ08Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End EJ08
	{ -- EJ52 Port-North
		striketype = MISSIONSTRIKE.enums.striketype.port,
        strikeregion = MISSIONSTRIKE.enums.region.north,                            
		strikename = "EJ52",
		strikeivo = "Sochi",
		strikemission = MISSIONSTRIKE.enums.strikemission.port.fuel, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_EJ52Strike",
		striketargetprefix = "TARGET_EJ52",
		zoneprefix = {
			{class = "small", prefix = "ZONE_EJ52Small"},
			{class = "medium", prefix = "ZONE_EJ52Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 3, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End EJ52
	------------ BRIDGE ------------
	{ -- GJ22 Bridge-West
		striketype = MISSIONSTRIKE.enums.striketype.bridge,
        strikeregion = MISSIONSTRIKE.enums.region.west,                            
		strikename = "GJ22",
		strikeivo = "Verkhnyaya Teberda",
		strikemission = MISSIONSTRIKE.enums.strikemission.bridge.road, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ22Strike",
		striketargetprefix = "TARGET_GJ22",
		zoneprefix = {
			{class = "small", prefix = "ZONE_GJ22Small"},
			{class = "medium", prefix = "ZONE_GJ22Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 1, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End GJ22
	{ -- GJ18 Bridge-West
		striketype = MISSIONSTRIKE.enums.striketype.bridge,
        strikeregion = MISSIONSTRIKE.enums.region.west,                            
		strikename = "GJ18",
		strikeivo = "Ispravnaya",
		strikemission = MISSIONSTRIKE.enums.strikemission.bridge.road, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ18Strike",
		striketargetprefix = "TARGET_GJ18",
		zoneprefix = {
			{class = "small", prefix = "ZONE_GJ18Small"},
			{class = "medium", prefix = "ZONE_GJ18Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 1, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End GJ18
	{ -- GJ38 Bridge-Central
		striketype = MISSIONSTRIKE.enums.striketype.bridge,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "GJ38",
		strikeivo = "Ust Dzheguta",
		strikemission = MISSIONSTRIKE.enums.strikemission.bridge.roadrail, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ38Strike",
		striketargetprefix = "TARGET_GJ38",
		zoneprefix = {
			{class = "small", prefix = "ZONE_GJ38Small"},
			{class = "medium", prefix = "ZONE_GJ38Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 3, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End GJ38
	{ -- GJ21 Bridge-Central
		striketype = MISSIONSTRIKE.enums.striketype.bridge,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "GJ21",
		strikeivo = "Teberda",
		strikemission = MISSIONSTRIKE.enums.strikemission.bridge.road, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ21Strike",
		striketargetprefix = "TARGET_GJ21",
		zoneprefix = {
			{class = "small", prefix = "ZONE_GJ21Small"},
			{class = "medium", prefix = "ZONE_GJ21Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 1, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End GJ21
	{ -- MN72 Bridge-East
		striketype = MISSIONSTRIKE.enums.striketype.bridge,
        strikeregion = MISSIONSTRIKE.enums.region.east,                            
		strikename = "MN72",
		strikeivo = "Kazbegi",
		strikemission = MISSIONSTRIKE.enums.strikemission.bridge.road, -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MN72Strike",
		striketargetprefix = "TARGET_MN72",
		zoneprefix = {
			{class = "small", prefix = "ZONE_MN72Small"},
			{class = "medium", prefix = "ZONE_MN72Med"},
		},
		defassets = { 
			sam = 2, 
			aaa = 4, 
			manpad = 2, 
			armour = 2, 
		},
		spawnobjects = {},
		is_open = true,
	},-- End MN72
	------------ CAMP ------------
	{ -- Camp-West
		striketype = MISSIONSTRIKE.enums.striketype.camp,
        strikeregion = MISSIONSTRIKE.enums.region.west,                            
		strikename = "Add",
		strikeivo = "Mission",
		strikemission = MISSIONSTRIKE.enums.strikemission.camp, -- text mission description
		striketargets = {
			{ 
				strikezone = "ZONE_Camp-21", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-22", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-23", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-24", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-25", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-26", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-27", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-28", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-29", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-30", 
				is_open = true 
			},
		},
	},-- End Camp-West
	{ -- Camp-Central
		striketype = MISSIONSTRIKE.enums.striketype.camp,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "Add",
		strikeivo = "Mission",
		strikemission = MISSIONSTRIKE.enums.strikemission.camp, -- text mission description
		striketargets = {
			{ 
				strikezone = "ZONE_Camp-11", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-12", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-13", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-14", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-15", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-16", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-17", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-18", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-19", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-20", 
				is_open = true 
			},
		},
	},-- End Camp-Central
	{ -- Camp-East
		striketype = MISSIONSTRIKE.enums.striketype.camp,
        strikeregion = MISSIONSTRIKE.enums.region.east,                            
		strikename = "Add",
		strikeivo = "Mission",
		strikemission = MISSIONSTRIKE.enums.strikemission.camp, -- text mission description
		striketargets = {
			{ 
				strikezone = "ZONE_Camp-1", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-2", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-3", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-4", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-5", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-6", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-7", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-8", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-9", 
				is_open = true 
			},
			{ 
				strikezone = "ZONE_Camp-10", 
				is_open = true 
			},
		},
	},-- End Camp-East
	------------ CONVOY ------------
	{ -- Convoy-West
		striketype = MISSIONSTRIKE.enums.striketype.convoy,
        strikeregion = MISSIONSTRIKE.enums.region.west,                            
		strikename = "Add",
		strikeivo = "Convoy Mission",
		strikemission = MISSIONSTRIKE.enums.strikemission.convoy, -- text mission description
		striketargets = {
			{ 
				strikezone = "ZONE_Convoy_Start-1",
				endzone = "ZONE_Convoy_End-1",
				destname = "Gudauta Airfield",
				is_open = true
			},
			{ 
				strikezone = "ZONE_Convoy_Start-2",
				endzone = "ZONE_Convoy_End-2",
				destname = "Gudauta Airfield",
				is_open = true
			},
			{ 
				strikezone = "ZONE_Convoy_Start-3",
				endzone = "ZONE_Convoy_End-3",
				destname = "Sukhumi Airfield",
				is_open = true
			},
			{ 
				strikezone = "ZONE_Convoy_Start-4",
				endzone = "ZONE_Convoy_End-4",
				destname = "Sukhumi Airfield",
				is_open = true
			},
		},
		options = {
			MISSIONSTRIKE.enums.convoy.supply,
			MISSIONSTRIKE.enums.convoy.armoured,
		},
	},-- End Convoy-West
	{ -- Convoy-Central
		striketype = MISSIONSTRIKE.enums.striketype.convoy,
        strikeregion = MISSIONSTRIKE.enums.region.central,                            
		strikename = "Add",
		strikeivo = "Convoy Mission",
		strikemission = MISSIONSTRIKE.enums.strikemission.convoy, -- text mission description
		striketargets = {
			{ 
				strikezone = "ZONE_Convoy_Start-5",
				endzone = "ZONE_Convoy_End-5",
				destname = "Kutaisi Airfield",
				is_open = true
			},
			{ 
				strikezone = "ZONE_Convoy_Start-6",
				endzone = "ZONE_Convoy_End-5",
				destname = "Kutaisi Airfield",
				is_open = true
			},
			{ 
				strikezone = "ZONE_Convoy_Start-7",
				endzone = "ZONE_Convoy_End-7",
				destname = "Khashuri",
				is_open = true
			},
		},
		options = {
			MISSIONSTRIKE.enums.convoy.supply,
			MISSIONSTRIKE.enums.convoy.armoured,
		},
	},-- End Convoy-Central
	{ -- Convoy-East
		striketype = MISSIONSTRIKE.enums.striketype.convoy,
        strikeregion = MISSIONSTRIKE.enums.region.east,                            
		strikename = "Add",
		strikeivo = "Convoy Mission",
		strikemission = MISSIONSTRIKE.enums.strikemission.convoy, -- text mission description
		striketargets = {
			{ 
				strikezone = "ZONE_Convoy_Start-8",
				endzone = "ZONE_Convoy_End-8",
				destname = "Khashuri",
				is_open = true
			},
			{ 
				strikezone = "ZONE_Convoy_Start-9",
				endzone = "ZONE_Convoy_End-9",
				destname = "Gori",
				is_open = true
			},
			{ 
				strikezone = "ZONE_Convoy_Start-10",
				endzone = "ZONE_Convoy_End-10",
				destname = "Misaktsieli",
				is_open = true
			},
		},
		options = {
			MISSIONSTRIKE.enums.convoy.supply,
			MISSIONSTRIKE.enums.convoy.armoured,
		},
	},-- End Convoy-Central
}



-- Start Strike Attack Module
if MISSIONSTRIKE.Start then
	_msg = MISSIONSTRIKE.traceTitle .. "Call Start() from missionstrike_data."
	BASE:T(_msg)
	MISSIONSTRIKE:Start()
end

-- END STRIKE ATTACK DATA