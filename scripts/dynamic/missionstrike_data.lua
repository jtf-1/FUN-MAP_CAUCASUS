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

-- MISSIONSTRIKE.mission = { -- TableStrikeAttack
-- 	{ --Beslan Airfield-East
-- 		striketype = "Airfield", --type of strike; Airfield, Factory, Bridge, Communications, C2
--         strikeregion = "East", -- Region in which mission is located (East, Central, West)                       
-- 		strikename = "Beslan", -- Friendly name for the location used in briefings, menus etc. Currently the same as the key, but will probably change
-- 		strikeivo = "AFB", -- "in the vacinity of" ("AFB" if airfield, "[TOWN/CITY]" other targets)
-- 		strikecoords = "43  12  20 N | 044  36  20 E", -- text LatLong
-- 		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND", -- text mission description
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR", -- text threats description
-- 		strikezone = "ZONE_BeslanStrike", -- ME zone at center of strike location
-- 		striketargets = {
--             "BESLAN_STATIC_01",
--             "BESLAN_STATIC_02",
--             "BESLAN_STATIC_03",
--             "BESLAN_STATIC_04",
--             "BESLAN_STATIC_05",
--             "BESLAN_STATIC_06",
--             "BESLAN_STATIC_07",
--             "BESLAN_STATIC_08",
--             "BESLAN_STATIC_09",
-- 		},
-- 		medzones = { 
-- 			{ loc = "ZONE_BeslanMed_01", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_02", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_03", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_04", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_05", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_06", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_07", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_08", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_09", is_open = true },
-- 			{ loc = "ZONE_BeslanMed_10", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_BeslanSmall_01", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_02", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_03", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_04", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_05", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_06", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_07", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_08", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_09", is_open = true },
-- 			{ loc = "ZONE_BeslanSmall_10", is_open = true },
-- 		},
-- 		defassets = {
-- 			sam = 4,
-- 			aaa = 5,
-- 			manpad = 3, 
-- 			armour = 3,
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- Sochi Airfield-West
-- 		striketype = "Airfield",
--         strikeregion = "West",                            
-- 		strikename = "Sochi",
-- 		strikeivo = "AFB",
-- 		strikecoords = "43  26  41 N | 039  56  32 E",
-- 		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_SochiStrike",
-- 		striketargets = {
--             "SOCHI_STATIC_01",
--             "SOCHI_STATIC_02",
--             "SOCHI_STATIC_03",
--             "SOCHI_STATIC_04",
--             "SOCHI_STATIC_05",
--             "SOCHI_STATIC_06",
--             "SOCHI_STATIC_07",
--             "SOCHI_STATIC_08",
--             "SOCHI_STATIC_09",
--             "SOCHI_STATIC_10",
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_SochiMed_01", is_open = true },
-- 			{ loc = "ZONE_SochiMed_02", is_open = true },
-- 			{ loc = "ZONE_SochiMed_03", is_open = true },
-- 			{ loc = "ZONE_SochiMed_04", is_open = true },
-- 			{ loc = "ZONE_SochiMed_05", is_open = true },
-- 			{ loc = "ZONE_SochiMed_06", is_open = true },
-- 			{ loc = "ZONE_SochiMed_07", is_open = true },
-- 			{ loc = "ZONE_SochiMed_08", is_open = true },
-- 			{ loc = "ZONE_SochiMed_09", is_open = true },
-- 			{ loc = "ZONE_SochiMed_10", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_SochiSmall_01", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_02", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_03", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_04", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_05", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_06", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_07", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_08", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_09", is_open = true },
-- 			{ loc = "ZONE_SochiSmall_10", is_open = true },
-- 		},
-- 		defassets = { -- max number of each defence asset
-- 			sam = 4,
-- 			aaa = 5,
-- 			manpad = 3,
-- 			armour = 3,
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- Maykop Airfield-West
-- 		striketype = "Airfield",
--         strikeregion = "West",                            
-- 		strikename = "Maykop",
-- 		strikeivo = "AFB",
-- 		strikecoords = "44  40  54 N | 040  02  08 E",
-- 		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_MaykopStrike",
-- 		striketargets = {
--             "MAYKOP_STATIC_01",
--             "MAYKOP_STATIC_02",
--             "MAYKOP_STATIC_03",
--             "MAYKOP_STATIC_04",
--             "MAYKOP_STATIC_05",
--             "MAYKOP_STATIC_06",
--             "MAYKOP_STATIC_07",
--             "MAYKOP_STATIC_08",
--             "MAYKOP_STATIC_09",
--             "MAYKOP_STATIC_10",
--             "MAYKOP_STATIC_11",
--             "MAYKOP_STATIC_12",
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_MaykopMed_01", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_02", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_03", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_04", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_05", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_06", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_07", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_08", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_09", is_open = true },
-- 			{ loc = "ZONE_MaykopMed_10", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_MaykopSmall_01", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_02", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_03", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_04", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_05", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_06", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_07", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_08", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_09", is_open = true },
-- 			{ loc = "ZONE_MaykopSmall_10", is_open = true },
-- 		},
-- 		defassets = {
-- 			sam = 4,
-- 			aaa = 5,
-- 			manpad = 3,
-- 			armour = 3,
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- Nalchik Airfield-Central
-- 		striketype = "Airfield",
--         strikeregion = "Central",                            
-- 		strikename = "Nalchik",
-- 		strikeivo = "AFB",
-- 		strikecoords = "43  30  53 N | 043  38  17 E",
-- 		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_NalchikStrike",
-- 		striketargets = {
--             "NALCHIK_STATIC_01",
--             "NALCHIK_STATIC_02",
--             "NALCHIK_STATIC_03",
--             "NALCHIK_STATIC_04",
--             "NALCHIK_STATIC_05",
--             "NALCHIK_STATIC_06",
--             "NALCHIK_STATIC_07",
--             "NALCHIK_STATIC_08",
--             "NALCHIK_STATIC_09",
--             "NALCHIK_STATIC_10",
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_NalchikMed_01", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_02", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_03", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_04", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_05", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_06", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_07", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_08", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_09", is_open = true },
-- 			{ loc = "ZONE_NalchikMed_10", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_NalchikSmall_01", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_02", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_03", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_04", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_05", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_06", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_07", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_08", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_09", is_open = true },
-- 			{ loc = "ZONE_NalchikSmall_10", is_open = true },
-- 		},
-- 		defassets = { 
-- 			sam = 4,
-- 			aaa = 5,
-- 			manpad = 3,
-- 			armour = 3,
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- MN76 
-- 		striketype = "Factory",
--         strikeregion = "East",                            
-- 		strikename = "MN76",
-- 		strikeivo = "Vladikavkaz",
-- 		strikecoords = "43  00  23 N | 044  39  02 E",
-- 		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND ANCILLIARY SUPPORT INFRASTRUCTURE",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_MN76Strike",
-- 		striketargets = {
--             "MN76_STATIC_01",
--             "MN76_STATIC_02",
--             "MN76_STATIC_03",
--             "MN76_STATIC_04",
--             "MN76_STATIC_05",
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_MN76Med_01", is_open = true },
-- 			{ loc = "ZONE_MN76Med_02", is_open = true },
-- 			{ loc = "ZONE_MN76Med_03", is_open = true },
-- 			{ loc = "ZONE_MN76Med_04", is_open = true },
-- 			{ loc = "ZONE_MN76Med_05", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_MN76Small_01", is_open = true },
-- 			{ loc = "ZONE_MN76Small_02", is_open = true },
-- 			{ loc = "ZONE_MN76Small_03", is_open = true },
-- 			{ loc = "ZONE_MN76Small_04", is_open = true },
-- 			{ loc = "ZONE_MN76Small_05", is_open = true },
-- 		},
-- 		defassets = { 
-- 			sam = 2, 
-- 			aaa = 3, 
-- 			manpad = 2, 
-- 			armour = 2, 
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- LN83 
-- 		striketype = "Factory",
--         strikeregion = "Central",                            
-- 		strikename = "LN83",
-- 		strikeivo = "Chiora",
-- 		strikecoords = "42  44  56 N | 043  32  28 E",
-- 		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_LN83Strike",
-- 		striketargets = {
--             "LN83_STATIC_01",
--             "LN83_STATIC_02",
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_LN83Med_01", is_open = true },
-- 			{ loc = "ZONE_LN83Med_02", is_open = true },
-- 			{ loc = "ZONE_LN83Med_03", is_open = true },
-- 			{ loc = "ZONE_LN83Med_04", is_open = true },
-- 			{ loc = "ZONE_LN83Med_05", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_LN83Small_01", is_open = true },
-- 			{ loc = "ZONE_LN83Small_02", is_open = true },
-- 			{ loc = "ZONE_LN83Small_03", is_open = true },
-- 			{ loc = "ZONE_LN83Small_04", is_open = true },
-- 			{ loc = "ZONE_LN83Small_05", is_open = true },
-- 		},
-- 		defassets = { 
-- 			sam = 2, 
-- 			aaa = 3, 
-- 			manpad = 2, 
-- 			armour = 2, 
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- LN77 
-- 		striketype = "Factory",
--         strikeregion = "Central",                            
-- 		strikename = "LN77",
-- 		strikeivo = "Verh.Balkaria",
-- 		strikecoords = "43  07  35 N | 043  27  24 E",
-- 		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND COMMUNICATIONS INFRASTRUCTURE",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_LN77Strike",
-- 		striketargets = {
--             "LN77_STATIC_01",
--             "LN77_STATIC_02",
--             "LN77_STATIC_03",
--             "LN77_STATIC_04",
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_LN77Med_01", is_open = true },
-- 			{ loc = "ZONE_LN77Med_02", is_open = true },
-- 			{ loc = "ZONE_LN77Med_03", is_open = true },
-- 			{ loc = "ZONE_LN77Med_04", is_open = true },
-- 			{ loc = "ZONE_LN77Med_05", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_LN77Small_01", is_open = true },
-- 			{ loc = "ZONE_LN77Small_02", is_open = true },
-- 			{ loc = "ZONE_LN77Small_03", is_open = true },
-- 			{ loc = "ZONE_LN77Small_04", is_open = true },
-- 			{ loc = "ZONE_LN77Small_05", is_open = true },
-- 		},
-- 		defassets = { 
-- 			sam = 2, 
-- 			aaa = 3, 
-- 			manpad = 1, 
-- 			armour = 3, 
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- LP30 
-- 		striketype = "Factory",
--         strikeregion = "Central",                            
-- 		strikename = "LP30",
-- 		strikeivo = "Tyrnyauz",
-- 		strikecoords = "43  23  43 N | 042  55  27 E",
-- 		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND COMMUNICATIONS INFRASTRUCTURE",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_LP30Strike",
-- 		striketargets = {
-- 		"LP30_STATIC_01",
--         "LP30_STATIC_02",
--         "LP30_STATIC_03",
--         "LP30_STATIC_04",
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_LP30Med_01", is_open = true },
-- 			{ loc = "ZONE_LP30Med_02", is_open = true },
-- 			{ loc = "ZONE_LP30Med_03", is_open = true },
-- 			{ loc = "ZONE_LP30Med_04", is_open = true },
-- 			{ loc = "ZONE_LP30Med_05", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_LP30Small_01", is_open = true },
-- 			{ loc = "ZONE_LP30Small_02", is_open = true },
-- 			{ loc = "ZONE_LP30Small_03", is_open = true },
-- 			{ loc = "ZONE_LP30Small_04", is_open = true },
-- 			{ loc = "ZONE_LP30Small_05", is_open = true },
-- 			{ loc = "ZONE_LP30Small_06", is_open = true },
-- 			{ loc = "ZONE_LP30Small_07", is_open = true },
-- 		},
-- 		defassets = { 
-- 			sam = 2, 
-- 			aaa = 3, 
-- 			manpad = 2, 
-- 			armour = 2, 
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- GJ38 
-- 		striketype = "Bridge",
--         strikeregion = "Central",                            
-- 		strikename = "GJ38",
-- 		strikeivo = "Ust Dzheguta",
-- 		strikecoords = "DMPI A 44  04  38 N | 041  58  15 E\n\nDMPI B 44  04  23 N | 041  58  34 E",
-- 		strikemission = "DESTROY ROAD BRIDGE DMPI A AND\nRAIL BRIDGE DMPI B",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_GJ38Strike",
-- 		striketargets = {
-- 			"GJ38_STATIC_01",
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_GJ38Med_01", is_open = true },
-- 			{ loc = "ZONE_GJ38Med_02", is_open = true },
-- 			{ loc = "ZONE_GJ38Med_03", is_open = true },
-- 			{ loc = "ZONE_GJ38Med_04", is_open = true },
-- 			{ loc = "ZONE_GJ38Med_05", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_GJ38Small_01", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_02", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_03", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_04", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_05", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_06", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_07", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_08", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_09", is_open = true },
-- 			{ loc = "ZONE_GJ38Small_10", is_open = true },
-- 		},
-- 		defassets = { 
-- 			sam = 2, 
-- 			aaa = 4, 
-- 			manpad = 3, 
-- 			armour = 2, 
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- MN72 
-- 		striketype = "Bridge",
--         strikeregion = "East",                            
-- 		strikename = "MN72",
-- 		strikeivo = "Kazbegi",
-- 		strikecoords = "44  04  38 N | 041  58  15 E",
-- 		strikemission = "DESTROY ROAD BRIDGE",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_MN72Strike",
-- 		striketargets = {
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_MN72Med_01", is_open = true },
-- 			{ loc = "ZONE_MN72Med_02", is_open = true },
-- 			{ loc = "ZONE_MN72Med_03", is_open = true },
-- 			{ loc = "ZONE_MN72Med_04", is_open = true },
-- 			{ loc = "ZONE_MN72Med_05", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_MN72Small_01", is_open = true },
-- 			{ loc = "ZONE_MN72Small_02", is_open = true },
-- 			{ loc = "ZONE_MN72Small_03", is_open = true },
-- 			{ loc = "ZONE_MN72Small_04", is_open = true },
-- 			{ loc = "ZONE_MN72Small_05", is_open = true },
-- 			{ loc = "ZONE_MN72Small_06", is_open = true },
-- 			{ loc = "ZONE_MN72Small_07", is_open = true },
-- 			{ loc = "ZONE_MN72Small_08", is_open = true },
-- 			{ loc = "ZONE_MN72Small_09", is_open = true },
-- 			{ loc = "ZONE_MN72Small_10", is_open = true },
-- 		},
-- 		defassets = { 
-- 			sam = 2, 
-- 			aaa = 4, 
-- 			manpad = 2, 
-- 			armour = 2, 
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- 	{ -- GJ21 
-- 		striketype = "Bridge",
--         strikeregion = "Central",                            
-- 		strikename = "GJ21",
-- 		strikeivo = "Teberda",
-- 		strikecoords = "43  26  47 N | 041  44  28 E",
-- 		strikemission = "DESTROY ROAD BRIDGE",
-- 		strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
-- 		strikezone = "ZONE_GJ21Strike",
-- 		striketargets = {
-- 		},
-- 		medzones = {
-- 			{ loc = "ZONE_GJ21Med_01", is_open = true },
-- 			{ loc = "ZONE_GJ21Med_02", is_open = true },
-- 			{ loc = "ZONE_GJ21Med_03", is_open = true },
-- 			{ loc = "ZONE_GJ21Med_04", is_open = true },
-- 			{ loc = "ZONE_GJ21Med_05", is_open = true },
-- 		},
-- 		smallzones = {
-- 			{ loc = "ZONE_GJ21Small_01", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_02", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_03", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_04", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_05", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_06", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_07", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_08", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_09", is_open = true },
-- 			{ loc = "ZONE_GJ21Small_10", is_open = true },
-- 		},
-- 		defassets = { 
-- 			sam = 2, 
-- 			aaa = 4, 
-- 			manpad = 1, 
-- 			armour = 2, 
-- 		},
-- 		spawnobjects = {},
-- 		is_open = true,
-- 	},
-- }

MISSIONSTRIKE.mission = { -- TableStrikeAttack
	{ -- Beslan Airfield-East
		striketype = "Airfield", --type of strike; Airfield, Factory, Bridge, Communications, C2
        strikeregion = "East", -- Region in which mission is located (East, Central, West)                       
		strikename = "Beslan", -- Friendly name for the location used in briefings, menus etc. Currently the same as the key, but will probably change
		strikeivo = "AFB", -- "in the vacinity of" ("AFB" if airfield, "[TOWN/CITY]" other targets)
		strikecoords = "43  12  20 N | 044  36  20 E", -- text LatLong
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND", -- text mission description
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR", -- text threats description
		strikezone = "ZONE_BeslanStrike", -- ME zone at center of strike location
		striketargets = {
            statics= {
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
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_BeslanMed_01", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_02", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_03", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_04", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_05", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_06", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_07", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_08", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_09", is_open = true },
				{ class = "medium", loc = "ZONE_BeslanMed_10", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_BeslanSmall_01", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_02", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_03", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_04", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_05", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_06", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_07", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_08", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_09", is_open = true },
				{ class = "small", loc = "ZONE_BeslanSmall_10", is_open = true },
			},
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
	{ -- Nalchik Airfield-Central
		striketype = "Airfield",
        strikeregion = "Central",                            
		strikename = "Nalchik",
		strikeivo = "AFB",
		strikecoords = "43  30  53 N | 043  38  17 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_NalchikStrike",
		striketargets = {
			statics = {
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
			groups = {},
		},
		zones = {
			medium ={
				{ class = "medium", loc = "ZONE_NalchikMed_01", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_02", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_03", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_04", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_05", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_06", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_07", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_08", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_09", is_open = true },
				{ class = "medium", loc = "ZONE_NalchikMed_10", is_open = true },
			}, 
			small = {
				{ class = "small", loc = "ZONE_NalchikSmall_01", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_02", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_03", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_04", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_05", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_06", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_07", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_08", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_09", is_open = true },
				{ class = "small", loc = "ZONE_NalchikSmall_10", is_open = true },
			},
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
	{ -- Mineralnye Airfield-Central
		striketype = "Airfield",
        strikeregion = "Central",                            
		strikename = "Mineralnye",
		strikeivo = "AFB",
		strikecoords = "43  30  53 N | 043  38  17 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MineralnyeStrike",
		striketargets = {
			statics = {
				"MINERALNYE_STATIC_01",
				"MINERALNYE_STATIC_02",
				"MINERALNYE_STATIC_03",
				"MINERALNYE_STATIC_04",
				"MINERALNYE_STATIC_05",
				"MINERALNYE_STATIC_06",
				"MINERALNYE_STATIC_07",
				"MINERALNYE_STATIC_08",
				"MINERALNYE_STATIC_09",
				"MINERALNYE_STATIC_10",
			},
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_MineralnyeMed_01", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_02", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_03", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_04", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_05", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_06", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_07", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_08", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_09", is_open = true },
				{ class = "medium", loc = "ZONE_MineralnyeMed_10", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_MineralnyeSmall_01", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_02", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_03", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_04", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_05", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_06", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_07", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_08", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_09", is_open = true },
				{ class = "small", loc = "ZONE_MineralnyeSmall_10", is_open = true },
			},
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
	{ -- Sochi Airfield-West
		striketype = "Airfield",
        strikeregion = "West",                            
		strikename = "Sochi",
		strikeivo = "AFB",
		strikecoords = "43  26  41 N | 039  56  32 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_SochiStrike",
		striketargets = {
			statics = {            
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
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_SochiMed_01", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_02", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_03", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_04", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_05", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_06", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_07", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_08", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_09", is_open = true },
				{ class = "medium", loc = "ZONE_SochiMed_10", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_SochiSmall_01", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_02", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_03", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_04", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_05", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_06", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_07", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_08", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_09", is_open = true },
				{ class = "small", loc = "ZONE_SochiSmall_10", is_open = true },
			},
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
	{ -- Maykop Airfield-West
		striketype = "Airfield",
        strikeregion = "West",                            
		strikename = "Maykop",
		strikeivo = "AFB",
		strikecoords = "44  40  54 N | 040  02  08 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MaykopStrike",
		striketargets = {
			statics = {            
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
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_MaykopMed_01", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_02", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_03", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_04", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_05", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_06", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_07", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_08", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_09", is_open = true },
				{ class = "medium", loc = "ZONE_MaykopMed_10", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_MaykopSmall_01", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_02", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_03", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_04", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_05", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_06", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_07", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_08", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_09", is_open = true },
				{ class = "small", loc = "ZONE_MaykopSmall_10", is_open = true },
			},
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
	{ -- Gudauta Airfield-West
		striketype = "Airfield",
        strikeregion = "West",                            
		strikename = "Gudauta",
		strikeivo = "AFB",
		--strikecoords = "44  40  54 N | 040  02  08 E",
		strikemission = "CRATER RUNWAY AND ATTRITE AVIATION ASSETS ON THE GROUND",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_Strike_Gudauta",
		striketargets = {
            statics= {},
			groups = {
				"TARGET_GUDAUTA_01",
				"TARGET_GUDAUTA_02",
				"TARGET_GUDAUTA_03",
				"TARGET_GUDAUTA_04",
				"TARGET_GUDAUTA_05",
				"TARGET_GUDAUTA_06",
				"TARGET_GUDAUTA_07",
				"TARGET_GUDAUTA_08",
			},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_Med_Gudauta_01", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_02", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_03", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_04", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_05", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_06", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_07", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_08", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_09", is_open = true },
				{ class = "medium", loc = "ZONE_Med_Gudauta_10", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_Small_Gudauta_01", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_02", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_03", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_04", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_05", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_06", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_07", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_08", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_09", is_open = true },
				{ class = "small", loc = "ZONE_Small_Gudauta_10", is_open = true },
			},
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
	{ -- LN83 Factory-Central
		striketype = "Factory",
        strikeregion = "Central",                            
		strikename = "LN83",
		strikeivo = "Chiora",
		strikecoords = "42  44  56 N | 043  32  28 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LN83Strike",
		striketargets = {
			statics = {
				"LN83_STATIC_01",
				"LN83_STATIC_02",
			},
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_LN83Med_01", is_open = true },
				{ class = "medium", loc = "ZONE_LN83Med_02", is_open = true },
				{ class = "medium", loc = "ZONE_LN83Med_03", is_open = true },
				{ class = "medium", loc = "ZONE_LN83Med_04", is_open = true },
				{ class = "medium", loc = "ZONE_LN83Med_05", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_LN83Small_01", is_open = true },
				{ class = "small", loc = "ZONE_LN83Small_02", is_open = true },
				{ class = "small", loc = "ZONE_LN83Small_03", is_open = true },
				{ class = "small", loc = "ZONE_LN83Small_04", is_open = true },
				{ class = "small", loc = "ZONE_LN83Small_05", is_open = true },
			},
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
		striketype = "Factory",
        strikeregion = "Central",                            
		strikename = "LN77",
		strikeivo = "Verh.Balkaria",
		strikecoords = "43  07  35 N | 043  27  24 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND COMMUNICATIONS INFRASTRUCTURE",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LN77Strike",
		striketargets = {
			statics = {
				"LN77_STATIC_01",
				"LN77_STATIC_02",
				"LN77_STATIC_03",
				"LN77_STATIC_04",
			},
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_LN77Med_01", is_open = true },
				{ class = "medium", loc = "ZONE_LN77Med_02", is_open = true },
				{ class = "medium", loc = "ZONE_LN77Med_03", is_open = true },
				{ class = "medium", loc = "ZONE_LN77Med_04", is_open = true },
				{ class = "medium", loc = "ZONE_LN77Med_05", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_LN77Small_01", is_open = true },
				{ class = "small", loc = "ZONE_LN77Small_02", is_open = true },
				{ class = "small", loc = "ZONE_LN77Small_03", is_open = true },
				{ class = "small", loc = "ZONE_LN77Small_04", is_open = true },
				{ class = "small", loc = "ZONE_LN77Small_05", is_open = true },
			},
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
		striketype = "Factory",
        strikeregion = "Central",                            
		strikename = "LP30",
		strikeivo = "Tyrnyauz",
		strikecoords = "43  23  43 N | 042  55  27 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND COMMUNICATIONS INFRASTRUCTURE",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_LP30Strike",
		striketargets = {
			statics = {			
				"LP30_STATIC_01",
				"LP30_STATIC_02",
				"LP30_STATIC_03",
				"LP30_STATIC_04",
			},
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_LP30Med_01", is_open = true },
				{ class = "medium", loc = "ZONE_LP30Med_02", is_open = true },
				{ class = "medium", loc = "ZONE_LP30Med_03", is_open = true },
				{ class = "medium", loc = "ZONE_LP30Med_04", is_open = true },
				{ class = "medium", loc = "ZONE_LP30Med_05", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_LP30Small_01", is_open = true },
				{ class = "small", loc = "ZONE_LP30Small_02", is_open = true },
				{ class = "small", loc = "ZONE_LP30Small_03", is_open = true },
				{ class = "small", loc = "ZONE_LP30Small_04", is_open = true },
				{ class = "small", loc = "ZONE_LP30Small_05", is_open = true },
				{ class = "small", loc = "ZONE_LP30Small_06", is_open = true },
				{ class = "small", loc = "ZONE_LP30Small_07", is_open = true },
			},
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
	{ -- MN76 Factory-West
		striketype = "Factory",
        strikeregion = "East",                            
		strikename = "MN76",
		strikeivo = "Vladikavkaz",
		strikecoords = "43  00  23 N | 044  39  02 E",
		strikemission = "DESTROY WEAPONS MANUFACTURING FACILITY\nAND ANCILLIARY SUPPORT INFRASTRUCTURE",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MN76Strike",
		striketargets = {
			statics = {
				"MN76_STATIC_01",
				"MN76_STATIC_02",
				"MN76_STATIC_03",
				"MN76_STATIC_04",
				"MN76_STATIC_05",
			},
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_MN76Med_01", is_open = true },
				{ class = "medium", loc = "ZONE_MN76Med_02", is_open = true },
				{ class = "medium", loc = "ZONE_MN76Med_03", is_open = true },
				{ class = "medium", loc = "ZONE_MN76Med_04", is_open = true },
				{ class = "medium", loc = "ZONE_MN76Med_05", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_MN76Small_01", is_open = true },
				{ class = "small", loc = "ZONE_MN76Small_02", is_open = true },
				{ class = "small", loc = "ZONE_MN76Small_03", is_open = true },
				{ class = "small", loc = "ZONE_MN76Small_04", is_open = true },
				{ class = "small", loc = "ZONE_MN76Small_05", is_open = true },
			},
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
	{ -- MN72 Bridge-East
		striketype = "Bridge",
        strikeregion = "East",                            
		strikename = "MN72",
		strikeivo = "Kazbegi",
		strikecoords = "44  04  38 N | 041  58  15 E",
		strikemission = "DESTROY ROAD BRIDGE",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_MN72Strike",
		striketargets = {
			statics = {},
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_MN72Med_01", is_open = true },
				{ class = "medium", loc = "ZONE_MN72Med_02", is_open = true },
				{ class = "medium", loc = "ZONE_MN72Med_03", is_open = true },
				{ class = "medium", loc = "ZONE_MN72Med_04", is_open = true },
				{ class = "medium", loc = "ZONE_MN72Med_05", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_MN72Small_01", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_02", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_03", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_04", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_05", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_06", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_07", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_08", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_09", is_open = true },
				{ class = "small", loc = "ZONE_MN72Small_10", is_open = true },
			},
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
	{ -- GJ38 Bridge-Central
		striketype = "Bridge",
        strikeregion = "Central",                            
		strikename = "GJ38",
		strikeivo = "Ust Dzheguta",
		strikecoords = "DMPI A 44  04  38 N | 041  58  15 E\n\nDMPI B 44  04  23 N | 041  58  34 E",
		strikemission = "DESTROY ROAD BRIDGE DMPI A AND\nRAIL BRIDGE DMPI B",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ38Strike",
		striketargets = {
			statics = {},
			groups = {},
			"GJ38_STATIC_01",
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_GJ38Med_01", is_open = true },
				{ class = "medium", loc = "ZONE_GJ38Med_02", is_open = true },
				{ class = "medium", loc = "ZONE_GJ38Med_03", is_open = true },
				{ class = "medium", loc = "ZONE_GJ38Med_04", is_open = true },
				{ class = "medium", loc = "ZONE_GJ38Med_05", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_GJ38Small_01", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_02", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_03", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_04", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_05", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_06", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_07", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_08", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_09", is_open = true },
				{ class = "small", loc = "ZONE_GJ38Small_10", is_open = true },
			},
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
		striketype = "Bridge",
        strikeregion = "Central",                            
		strikename = "GJ21",
		strikeivo = "Teberda",
		strikecoords = "43  26  47 N | 041  44  28 E",
		strikemission = "DESTROY ROAD BRIDGE",
		--strikethreats = "RADAR SAM, I/R SAM, AAA, LIGHT ARMOUR",
		strikezone = "ZONE_GJ21Strike",
		striketargets = {
			statics = {},
			groups = {},
		},
		zones = {
			medium = {
				{ class = "medium", loc = "ZONE_GJ21Med_01", is_open = true },
				{ class = "medium", loc = "ZONE_GJ21Med_02", is_open = true },
				{ class = "medium", loc = "ZONE_GJ21Med_03", is_open = true },
				{ class = "medium", loc = "ZONE_GJ21Med_04", is_open = true },
				{ class = "medium", loc = "ZONE_GJ21Med_05", is_open = true },
			},
			small = {
				{ class = "small", loc = "ZONE_GJ21Small_01", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_02", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_03", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_04", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_05", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_06", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_07", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_08", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_09", is_open = true },
				{ class = "small", loc = "ZONE_GJ21Small_10", is_open = true },
			},
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
		"ARMOUR_Heavy_01",
		"ARMOUR_Heavy_02",
		"ARMOUR_Heavy_03",
		"ARMOUR_Heavy_04",
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


--------------------------------
--- Camp Strike Mission Data ---
--------------------------------

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
	"ARMOUR_Heavy_01",
	"ARMOUR_Heavy_02",
	"ARMOUR_Heavy_03",
	"ARMOUR_Heavy_04",
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
if MISSIONSTRIKE.Start then
	_msg = MISSIONSTRIKE.traceTitle .. "Call Start()"
	BASE:T(_msg)

	MISSIONSTRIKE:Start()
end