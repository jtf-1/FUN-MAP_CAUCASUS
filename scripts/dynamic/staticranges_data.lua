env.info( "[JTF-1] staticranges_data" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- STATIC RANGES SETTINGS FOR MIZ
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- This file MUST be loaded AFTER staticranges.lua
--
-- These values are specific to the miz and will override the default values in STATICRANGES.default
--

-- Error prevention. Create empty container if module core lua not loaded.
if not STATICRANGES then 
	STATICRANGES = {}
	STATICRANGES.traceTitle = "[JTF-1 STATICRANGES] "
	_msg = self.traceTitle .. "CORE FILE NOT LOADED!"
	BASE:E(_msg)
	end

-- These values will overrides the default values in staticranges.lua
STATICRANGES.strafeMaxAlt             = 1530 -- [5000ft] in metres. Height of strafe box.
STATICRANGES.strafeBoxLength          = 3000 -- [10000ft] in metres. Length of strafe box.
STATICRANGES.strafeBoxWidth           = 300 -- [1000ft] in metres. Width of Strafe pit box (from 1st listed lane).
STATICRANGES.strafeFoullineDistance   = 610 -- [2000ft] in metres. Min distance for from target for rounds to be counted.
STATICRANGES.strafeGoodPass           = 20 -- Min hits for a good pass.

-- Range targets table
STATICRANGES.Ranges = {
	{ --GG23
		rangeId               = "GG33",
		rangeName             = "Range GG33",
		rangeZone             = "ZONE_GG33",
		rangeControlFrequency = 250,
		groups = {
		},
		units = {
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
		},
		strafepits = {
			{ 
				"RANGE_GG33_Strafepit_A",
				"RANGE_GG33_Strafepit_B"
			},
		},
	},--GG23 END
	{ --NL24
		rangeId               = "NL24",
		rangeName             = "Range NL24",
		rangeZone             = "ZONE_NL24",
		rangeControlFrequency = 250,
		groups = {
		},
		units = {
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
		},
		strafepits = {
			{ -- strafepit North
				"RANGE_NL24_strafepit_A",
				"RANGE_NL24_strafepit_B"
			},
			{ -- strafepit South
				"RANGE_NL24_strafepit_C",
				"RANGE_NL24_strafepit_D"
			},
		},
	},--NL24 END
}
  
-- Start the STATICRANGES module
if STATICRANGES.Start then
	_msg = STATICRANGES.traceTitle .. "Call Start()"
	BASE:T(_msg)

	STATICRANGES:Start()
end