env.info( "[JTF-1] mission_spawn" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN MISSION SPAWN SOURCE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

MISSIONSPAWN = {}

MISSIONSPAWN.templates = {
	-- ["SEAD_F18"] = {
	-- 	["category"] = Group.Category.AIRPLANE,
	-- 	["lateActivation"] = true,
	-- 	["tasks"] = 
	-- 	{
	-- 	}, -- end of ["tasks"]
	-- 	["radioSet"] = false,
	-- 	["task"] = "SEAD",
	-- 	["uncontrolled"] = false,
	-- 	["taskSelected"] = true,
	-- 	["route"] = 
	-- 	{
	-- 		["routeRelativeTOT"] = true,
	-- 		["points"] = 
	-- 		{
	-- 			[1] = 
	-- 			{
	-- 				["alt"] = 151.17015748595,
	-- 				["action"] = "Turning Point",
	-- 				["alt_type"] = "BARO",
	-- 				["speed"] = 179.86111111111,
	-- 				["task"] = 
	-- 				{
	-- 					["id"] = "ComboTask",
	-- 					["params"] = 
	-- 					{
	-- 						["tasks"] = 
	-- 						{
	-- 							[1] = 
	-- 							{
	-- 								["enabled"] = true,
	-- 								["key"] = "SEAD",
	-- 								["id"] = "EngageTargets",
	-- 								["number"] = 1,
	-- 								["auto"] = true,
	-- 								["params"] = 
	-- 								{
	-- 									["targetTypes"] = 
	-- 									{
	-- 										[1] = "Air Defence",
	-- 									}, -- end of ["targetTypes"]
	-- 									["priority"] = 0,
	-- 								}, -- end of ["params"]
	-- 							}, -- end of [1]
	-- 							[2] = 
	-- 							{
	-- 								["enabled"] = true,
	-- 								["auto"] = true,
	-- 								["id"] = "WrappedAction",
	-- 								["number"] = 2,
	-- 								["params"] = 
	-- 								{
	-- 									["action"] = 
	-- 									{
	-- 										["id"] = "Option",
	-- 										["params"] = 
	-- 										{
	-- 											["value"] = 2,
	-- 											["name"] = 1,
	-- 										}, -- end of ["params"]
	-- 									}, -- end of ["action"]
	-- 								}, -- end of ["params"]
	-- 							}, -- end of [2]
	-- 							[3] = 
	-- 							{
	-- 								["enabled"] = true,
	-- 								["auto"] = true,
	-- 								["id"] = "WrappedAction",
	-- 								["number"] = 3,
	-- 								["params"] = 
	-- 								{
	-- 									["action"] = 
	-- 									{
	-- 										["id"] = "Option",
	-- 										["params"] = 
	-- 										{
	-- 											["value"] = 2,
	-- 											["name"] = 13,
	-- 										}, -- end of ["params"]
	-- 									}, -- end of ["action"]
	-- 								}, -- end of ["params"]
	-- 							}, -- end of [3]
	-- 							[4] = 
	-- 							{
	-- 								["enabled"] = true,
	-- 								["auto"] = true,
	-- 								["id"] = "WrappedAction",
	-- 								["number"] = 4,
	-- 								["params"] = 
	-- 								{
	-- 									["action"] = 
	-- 									{
	-- 										["id"] = "Option",
	-- 										["params"] = 
	-- 										{
	-- 											["value"] = true,
	-- 											["name"] = 19,
	-- 										}, -- end of ["params"]
	-- 									}, -- end of ["action"]
	-- 								}, -- end of ["params"]
	-- 							}, -- end of [4]
	-- 							[5] = 
	-- 							{
	-- 								["enabled"] = true,
	-- 								["auto"] = true,
	-- 								["id"] = "WrappedAction",
	-- 								["number"] = 5,
	-- 								["params"] = 
	-- 								{
	-- 									["action"] = 
	-- 									{
	-- 										["id"] = "Option",
	-- 										["params"] = 
	-- 										{
	-- 											["targetTypes"] = 
	-- 											{
	-- 												[1] = "Air Defence",
	-- 											}, -- end of ["targetTypes"]
	-- 											["name"] = 21,
	-- 											["value"] = "Air Defence;",
	-- 											["noTargetTypes"] = 
	-- 											{
	-- 												[1] = "Fighters",
	-- 												[2] = "Multirole fighters",
	-- 												[3] = "Bombers",
	-- 												[4] = "Helicopters",
	-- 												[5] = "UAVs",
	-- 												[6] = "Infantry",
	-- 												[7] = "Fortifications",
	-- 												[8] = "Tanks",
	-- 												[9] = "IFV",
	-- 												[10] = "APC",
	-- 												[11] = "Artillery",
	-- 												[12] = "Unarmed vehicles",
	-- 												[13] = "Aircraft Carriers",
	-- 												[14] = "Cruisers",
	-- 												[15] = "Destroyers",
	-- 												[16] = "Frigates",
	-- 												[17] = "Corvettes",
	-- 												[18] = "Light armed ships",
	-- 												[19] = "Unarmed ships",
	-- 												[20] = "Submarines",
	-- 												[21] = "Cruise missiles",
	-- 												[22] = "Antiship Missiles",
	-- 												[23] = "AA Missiles",
	-- 												[24] = "AG Missiles",
	-- 												[25] = "SA Missiles",
	-- 											}, -- end of ["noTargetTypes"]
	-- 										}, -- end of ["params"]
	-- 									}, -- end of ["action"]
	-- 								}, -- end of ["params"]
	-- 							}, -- end of [5]
	-- 							[6] = 
	-- 							{
	-- 								["enabled"] = true,
	-- 								["auto"] = true,
	-- 								["id"] = "WrappedAction",
	-- 								["number"] = 6,
	-- 								["params"] = 
	-- 								{
	-- 									["action"] = 
	-- 									{
	-- 										["id"] = "EPLRS",
	-- 										["params"] = 
	-- 										{
	-- 											["value"] = true,
	-- 											["groupId"] = 32,
	-- 										}, -- end of ["params"]
	-- 									}, -- end of ["action"]
	-- 								}, -- end of ["params"]
	-- 							}, -- end of [6]
	-- 							[7] = 
	-- 							{
	-- 								["enabled"] = true,
	-- 								["auto"] = false,
	-- 								["id"] = "WrappedAction",
	-- 								["number"] = 7,
	-- 								["params"] = 
	-- 								{
	-- 									["action"] = 
	-- 									{
	-- 										["id"] = "Option",
	-- 										["params"] = 
	-- 										{
	-- 											["value"] = 0,
	-- 											["name"] = 0,
	-- 										}, -- end of ["params"]
	-- 									}, -- end of ["action"]
	-- 								}, -- end of ["params"]
	-- 							}, -- end of [7]
	-- 						}, -- end of ["tasks"]
	-- 					}, -- end of ["params"]
	-- 				}, -- end of ["task"]
	-- 				["type"] = "Turning Point",
	-- 				["ETA"] = 0,
	-- 				["ETA_locked"] = true,
	-- 				["y"] = 527051.30724566,
	-- 				["x"] = 159560.4321624,
	-- 				["formation_template"] = "",
	-- 				["speed_locked"] = true,
	-- 			}, -- end of [1]
	-- 		}, -- end of ["points"]
	-- 	}, -- end of ["route"]
	-- 	["groupId"] = 679,
	-- 	["hidden"] = false,
	-- 	["units"] = 
	-- 	{
	-- 		[1] = 
	-- 		{
	-- 			["alt"] = 151.17015748595,
	-- 			["hardpoint_racks"] = true,
	-- 			["alt_type"] = "BARO",
	-- 			["livery_id"] = "nawdc black",
	-- 			["skill"] = "Random",
	-- 			["speed"] = 179.86111111111,
	-- 			["AddPropAircraft"] = 
	-- 			{
	-- 			}, -- end of ["AddPropAircraft"]
	-- 			["type"] = "FA-18C_hornet",
	-- 			["unitId"] = 1780,
	-- 			["psi"] = 0,
	-- 			["y"] = 527051.30724566,
	-- 			["x"] = 159560.4321624,
	-- 			["name"] = "SEAD_F18-1",
	-- 			["payload"] = 
	-- 			{
	-- 				["pylons"] = 
	-- 				{
	-- 					[1] = 
	-- 					{
	-- 						["CLSID"] = "{5CE2FF2A-645A-4197-B48D-8720AC69394F}",
	-- 					}, -- end of [1]
	-- 					[2] = 
	-- 					{
	-- 						["CLSID"] = "{B06DD79A-F21E-4EB9-BD9D-AB3844618C93}",
	-- 					}, -- end of [2]
	-- 					[3] = 
	-- 					{
	-- 						["CLSID"] = "{B06DD79A-F21E-4EB9-BD9D-AB3844618C93}",
	-- 					}, -- end of [3]
	-- 					[4] = 
	-- 					{
	-- 						["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}",
	-- 					}, -- end of [4]
	-- 					[5] = 
	-- 					{
	-- 						["CLSID"] = "{FPU_8A_FUEL_TANK}",
	-- 					}, -- end of [5]
	-- 					[6] = 
	-- 					{
	-- 						["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}",
	-- 					}, -- end of [6]
	-- 					[7] = 
	-- 					{
	-- 						["CLSID"] = "{B06DD79A-F21E-4EB9-BD9D-AB3844618C93}",
	-- 					}, -- end of [7]
	-- 					[8] = 
	-- 					{
	-- 						["CLSID"] = "{B06DD79A-F21E-4EB9-BD9D-AB3844618C93}",
	-- 					}, -- end of [8]
	-- 					[9] = 
	-- 					{
	-- 						["CLSID"] = "{5CE2FF2A-645A-4197-B48D-8720AC69394F}",
	-- 					}, -- end of [9]
	-- 				}, -- end of ["pylons"]
	-- 				["fuel"] = 4900,
	-- 				["flare"] = 60,
	-- 				["ammo_type"] = 1,
	-- 				["chaff"] = 60,
	-- 				["gun"] = 100,
	-- 			}, -- end of ["payload"]
	-- 			["heading"] = 2.6040783413585,
	-- 			["callsign"] = 
	-- 			{
	-- 				[1] = 9,
	-- 				[2] = 1,
	-- 				["name"] = "Hornet11",
	-- 				[3] = 1,
	-- 			}, -- end of ["callsign"]
	-- 			["onboard_num"] = "018",
	-- 		}, -- end of [1]
	-- 	}, -- end of ["units"]
	-- 	["y"] = 527051.30724566,
	-- 	["x"] = 159560.4321624,
	-- 	["name"] = "SEAD_F18",
	-- 	["communication"] = true,
	-- 	["start_time"] = 0,
	-- 	["modulation"] = 0,
	-- 	["frequency"] = 305,
	-- }, -- end of ["SEAD_F18"]

}