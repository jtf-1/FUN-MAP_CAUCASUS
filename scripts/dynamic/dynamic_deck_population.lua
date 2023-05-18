-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Dynamic Deck Population
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

DYNDECK = {
    menu = {},
    templates = {},
}

DYNDECK.ship = {
    {
        name = "CVN-72 Lincoln", -- Name will be used for ship's menu entry
        id = 1137, -- unit ID in Mission Editor
        coalitionID = 2, -- 1, red, 2 blue
        fullTemplateActive = false, -- flag to denote a full deck template is active
        templates = {
            {
                name = "sc_flex4c234", -- name of template as it appears in the name of the function containing the template
                menutext = "Flex EL3 spawns cat 1234", -- text that will appear in the template's menu entry
                noClear = false, -- whether a full deck clear should not be performed prior to applying the template. True = do not clear deck (for partial templates). False = clear deck fi#rst (for full templates)
                active = false -- flag to denote template is active. True = active (do not re-apply the template if it seelcted from the menu). False = template is not active.
            },
            {
                name = "sc_cat1", 
                menutext = "F18s full Cat 1", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_cat2l", 
                menutext = "F18s full Cat 2", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_cat2r", 
                menutext = "F18s x3 Cat 2", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_corral", 
                menutext = "AC and Tech Corral", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_island", 
                menutext = "AC and Tech around Island", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_deckeq", 
                menutext = "Deck eqpt around Island", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_patio", 
                menutext = "F14s on Patio", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_fantail", 
                menutext = "F14s on Fantail", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_el1", 
                menutext = "AC and Tech on Elevator 1", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_el3", 
                menutext = "AC and Tech on Elevator 3", 
                noClear = true, 
                active = false
            }, 
            {
                name = "sc_el4", 
                menutext = "AC and Tech on Elevator 4", 
                noClear = true, 
                active = false
            }, 
        }
    },
    {
        name = "CVN-59 Forrestal",
        id = 1202,
        coalitionID = 2,
        fullTemplateActive = false,
        templates = {
            {
                name = "forrestal_flex4c234", 
                menutext = "Flex 4 spawn cat 234", 
                noClear = false, 
                active = false
            },
        }
    },
}

-- Remove template objects from the ship
function DYNDECK:clearDeck(templateName, shipID, coalitionID, shipIndex, templateIndex)
    BASE:T("[DYNDECK] clearDeck called.")

    local staticFind = templateName or ("dyndeck_" .. shipID) -- search string for identifying objects to remove
    local statObj = coalition.getStaticObjects(coalitionID) -- table of all static objects for coalition
    -- step through table to find statics with the search string in thier name
    for i, static in pairs(statObj) do
        local staticName = static:getName()
        if string.match(staticName, ".*" .. staticFind .. ".*") then
            static:destroy() -- destroy found static
        end
    end
    
    if templateName then
        -- if a template name was passed to clearDeck change its active tag to false
        DYNDECK.ship[shipIndex].templates[templateIndex].active = false
    else
        -- if no template name was provided change the active tag for all the ship's templates to false 
        for j, template in ipairs(DYNDECK.ship[shipIndex].templates) do
            DYNDECK.ship[shipIndex].templates[j].active = false
        end
        -- set the ship's fullTemplateActive tag to false
        DYNDECK.ship[shipIndex].fullTemplateActive = false
    end

end

-- Apply the selected template to the ship
function DYNDECK:applyTemplate(templateName, shipID, coalitionID, noClear, shipIndex, templateIndex)
    BASE:T("[DYNDECK] applyTemplate called.")
    -- only apply the template if it is *not* already active
    if not DYNDECK.ship[shipIndex].templates[templateIndex].active then
        BASE:T("[DYNDECK] Template not active.")
        if DYNDECK.ship[shipIndex].fullTemplateActive or (not noClear) then -- a full template is being, or has already been, applied
            -- clear deck before applying template
            DYNDECK:clearDeck(false, shipID, coalitionID, shipIndex)
        end
        BASE:T("[DYNDECK] Apply template")
        -- call function for the template
        DYNDECK[templateName](shipID, templateName)
        -- mark the template as active
        DYNDECK.ship[shipIndex].templates[templateIndex].active = true
        if not noClear then 
            -- mark ship as having a full template applied
            DYNDECK.ship[shipIndex].fullTemplateActive = true
        end
    else
        BASE:T("[DYNDECK] TEMPLATE ALREADY ACTIVE!")
    end
end

function DYNDECK:addMenu()

    -- add menu root
    DYNDECK.menu = MENU_MISSION:New("Dynamic Deck")
    -- add ship menus
    for shipIndex, menuship in ipairs(DYNDECK.ship) do
        -- add menu for ship
        DYNDECK.menu[menuship.id] = MENU_MISSION:New(menuship.name, DYNDECK.menu)
        -- add Fixed Templates submenu
        DYNDECK.menu[menuship.id].fixed = MENU_MISSION:New("Fixed Templates", DYNDECK.menu[menuship.id])
        -- add Partial Templates submenu
        DYNDECK.menu[menuship.id].partial = MENU_MISSION:New("Partial Templates", DYNDECK.menu[menuship.id])
        -- add menus for the ship's templates
        for templateIndex, template in ipairs(menuship.templates) do
            if template.noClear then -- partial template
                -- add a submenu for the partial template
                DYNDECK.menu[menuship.id].partial[template.name] = MENU_MISSION:New(template.menutext, DYNDECK.menu[menuship.id].partial)
                -- add a menu to apply the partial template
                MENU_MISSION_COMMAND:New("Add", DYNDECK.menu[menuship.id].partial[template.name], DYNDECK.applyTemplate, self, template.name, menuship.id, menuship.coalitionID, true, shipIndex ,templateIndex)
                -- add a menu to remove the partial template
                MENU_MISSION_COMMAND:New("Remove", DYNDECK.menu[menuship.id].partial[template.name], DYNDECK.clearDeck, self, template.name, menuship.id, menuship.coalitionID, shipIndex ,templateIndex)  
            else
                -- full template
                MENU_MISSION_COMMAND:New(template.menutext, DYNDECK.menu[menuship.id].fixed, DYNDECK.applyTemplate, self, template.name, menuship.id, menuship.coalitionID, false, shipIndex ,templateIndex)
            end
        end
        -- add menu to completely clear the ships deck of all statics
        MENU_MISSION_COMMAND:New("Clear Deck", DYNDECK.menu[menuship.id], DYNDECK.clearDeck, self, false, menuship.id, menuship.coalitionID, shipIndex)  
    end

end

DYNDECK:addMenu()

function DYNDECK.sc_flex4c234(shipID, templateName) 

    local namePrefix = "dyndeck_" .. shipID .. templateName

	-- Created by Redkite: https://www.youtube.com/user/RedKiteRender/

	local staticObj = {

		["groupId"] = 400,		-- ids of the unit we're spawning (will auto increment if id taken)
		["unitId"] = 401,
		["rate"] = 30,
		["name"] = namePrefix .. "4temp EL1 Hornet 1", -- unit name (Name this something identifiable if you wish to remove it later)

		["type"] = "FA-18C_hornet", 			-- unit, category and livery of unit to place.
		["category"] = "Planes",
		["livery_id"] = "VFA-37",

		["y"] = -274433.54379664,
		["heading"] = 37.55948550292,		-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -90767.765053252,

		["offsets"] = {				-- The offsets that choose where on the deck it will spawn
			["y"] = 31.035356269975,
			["angle"] = 4.7123889803847,
			["x"] = 23.392320767991
		}, -- end of ["offsets"]
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************



	local staticObj = {

		["groupId"] = 401,		-- ids of the unit we're spawning (will auto increment if id taken)
		["unitId"] = 401,
		["rate"] = 30,
		["name"] = namePrefix .. "4temp EL1 Hornet 2", -- unit name (Name this something identifiable if you wish to remove it later)

		["type"] = "FA-18C_hornet", 			-- unit, category and livery of unit to place.
		["category"] = "Planes",
		["livery_id"] = "VFA-37",

		["y"] = 274432.9647788,
		["heading"] =  4.7123889803847,		-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] =  -90757.458535686,

		["offsets"] = {				-- The offsets that choose where on the deck it will spawn
			["y"] = 31.61437411001,
			["angle"] = 4.7123889803847,
			["x"] = 33.698838333992,
		}, -- end of ["offsets"]
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************



	local staticObj = {

		["groupId"] = 403,		-- ids of the unit we're spawning (will auto increment if id taken)
		["unitId"] = 403,
		["rate"] = 30,
		["name"] = namePrefix .. "4temp EL2 S3", -- unit name (Name this something identifiable if you wish to remove it later)

		["type"] = "S-3B Tanker", 			-- unit, category and livery of unit to place.
		["category"] = "Planes",
		["livery_id"] = "usaf standard",
		
		["offsets"] = {				-- The offsets that choose where on the deck it will spawn
			["y"] = 29.84889531997,
			["angle"] =  4.4505895925855,
			["x"] = -14.761768433003,
		}, -- end of ["offsets"]

		["y"] = -274434.73025759,	-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] =  -90805.919142453,
		["heading"] =  4.4505895925855,	

		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************

	local staticObj = {
		
	-- Segment you need to change start  
		["groupId"] = 1,		-- id's of the unit we're spawning (will auto increment if id taken)
		["unitId"] = 1,
		["name"] = namePrefix .. "4temp EL2 Hornet", -- unit name (Name this something identifiable if you wish to remove it later)
		
		
	
		["livery_id"] = "VFA-37",
		["category"] = "Planes",
		["offsets"] = {				-- The offsets that choose where on the deck it will spawn
			["y"] = 31.382766969968,
			["angle"] = 4.7123889803847,
			["x"] = -25.013570722003,
		}, -- end of ["offsets"]
		["type"] = "FA-18C_hornet", 			-- unit, category and livery of unit to place.
	-- Segment you need to change end


		["x"] = -90816.170944742,			-- The initial location of the unit (required else unit will offet on origin of map)
		["y"] = -274433.19638594,
		["heading"] = 4.7123889803847,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************


	local staticObj = {

	-- Segment you need to change start  

		["name"] = namePrefix .. "4temp Finger Seahawk", -- unit name (Name this something identifiable if you wish to remove it later)


		["livery_id"] = "standard",
		["category"] = "Helicopters",
		["offsets"] = {				-- The offsets that choose where on the deck it will spawn
			["y"] = -25.023610410048,
			["angle"] = 1.7976891295542,
			["x"] = -120.511512843,
		}, -- end of ["offsets"]
		["type"] = "SH-60B",			-- unit, category and livery of unit to place.
	-- Segment you need to change end

	-- these can be left as is, but are required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************


	local staticObj = {

	-- Segment you need to change start  

		["name"] = namePrefix .. "4temp Corral Crane", -- unit name (Name this something identifiable if you wish to remove it later)


		["category"] = "ADEquipment",
		["offsets"] = {				-- The offsets that choose where on the deck it will spawn
			["y"] = 33.351427629997,
			["angle"] = 4.6600291028249,
			["x"] = -0.92642854900623,
		}, -- end of ["offsets"]
		["type"] = "AS32-36A",			-- unit, category and livery of unit to place.
	-- Segment you need to change end

	-- these can be left as is, but are required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************

	local staticObj = {

	-- Segment you need to change start  

		["name"] = namePrefix .. "4temp Point Firetruck", -- unit name (Name this something identifiable if you wish to remove it later)


		["category"] = "ADEquipment",
		["offsets"] = {				-- The offsets that choose where on the deck it will spawn
												["y"] = 32.424999079958,
												["angle"] = 5.4279739737024,
												["x"] = 72.724640796994,
		}, -- end of ["offsets"]
		["type"] = "AS32-p25",			-- unit, category and livery of unit to place.
	-- Segment you need to change end

	-- these can be left as is, but are required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************

	local staticObj = {
		
	-- Segment you need to change start  

		["name"] = namePrefix .. "4temp Junk Yard Tug", -- unit name (Name this something identifiable if you wish to remove it later)


		["category"] = "ADEquipment",
		["offsets"] = {				-- The offsets that choose where on the deck it will spawn
												["y"] = 30.242116749985,
												["angle"] = 2.4958208303519,
												["x"] = -79.610005513998,
		}, -- end of ["offsets"]
		["type"] = "AS32-31A",			-- unit, category and livery of unit to place.
	-- Segment you need to change end

	-- these can be left as is, but are required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)


	-- ********************************************************

	local staticObj = {
	-- Segment you need to change start  

		["name"] = namePrefix .. "4temp EL4 Tomcat 1", -- unit name (Name this something identifiable if you wish to remove it later)

											["livery_id"] = "VF-102 Diamondbacks",
											["category"] = "Planes",
											["offsets"] = 
											{
												["y"] = -32.180430089997,
												["angle"] = 1.9373154697137,
												["x"] = -98.393250321998,
											}, -- end of ["offsets"]
											["type"] = "F-14B",
	-- Segment you need to change end

	-- these can be left as is, but are required.
	--	["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************


	local staticObj = {

		["name"] = namePrefix .. "4temp EL4 Tomcat 2", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
										["livery_id"] = "VF-102 Diamondbacks 102",
											["category"] = "Planes",
											["offsets"] = 
											{
												["y"] = -32.924847350048,
												["angle"] = 1.7627825445143,
												["x"] = -110.574623714,
											}, -- end of ["offsets"]
											["type"] = "F-14B",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************

	local staticObj = {

		["name"] = namePrefix .. "4temp Corral E2", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
										["livery_id"] = "E-2D Demo",
											["category"] = "Planes",
											["offsets"] = 
											{
												["y"] = 30.665721859958,
												["angle"] = 4.6949356878647,
												["x"] = 8.8025239199924,
											}, -- end of ["offsets"]
											["type"] = "E-2C",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************

	local staticObj = {

		["name"] = namePrefix .. "4temp Point Hornet", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["livery_id"] = "VFA-37",
											["category"] = "Planes",
											["type"] = "FA-18C_hornet",
											["offsets"] = 
											{
												["y"] = 34.190822379955,
												["angle"] = 3.3335788713092,
												["x"] = 61.561528349994,
											}, -- end of ["offsets"]
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************


	local staticObj = {

		["name"] = namePrefix .. "4temp LSO Station 3", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = -22.370473980031,
												["angle"] = 2.4434609527921,
												["x"] = -130.61201797701,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_lso_usa",
											["type"] = "Carrier LSO Personell",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************



	local staticObj = {

		["name"] = namePrefix .. "4temp LSO Station 1", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = -21.789118479996,
												["angle"] = 4.2935099599061,
												["x"] = -129.42353100701,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_lso1_usa",
											["type"] = "Carrier LSO Personell 1",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************


	local staticObj = {

		["name"] = namePrefix .. "4temp LSO Station 2", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
										["livery_id"] = "white",
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = -22.656188270019,
												["angle"] = 1.850049007114,
												["x"] = -129.497732263,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_tech_USA",
											["type"] = "us carrier tech",
											["unitId"] = 17,
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

	-- ********************************************************

	local staticObj = {

		["name"] = namePrefix .. "4temp Point Tech 3", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["livery_id"] = "white",
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = 31.799837369996,
												["angle"] = 1.850049007114,
												["x"] = 58.869844022993,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_tech_USA",
											["type"] = "us carrier tech",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)
	-- ********************************************************
	local staticObj = {

		["name"] = namePrefix .. "4temp Point Tech 2", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["livery_id"] = "purple",
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = 36.657607259986,
												["angle"] = 5.9341194567807,
												["x"] = 60.15744568099,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_tech_USA",
											["type"] = "us carrier tech",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)
	-- ********************************************************
	local staticObj = {

		["name"] = namePrefix .. "4temp Point Tech 1", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["livery_id"] = "purple",
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = 32.502165549959,
												["angle"] = 2.460914245312,
												["x"] = 67.356309497001,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_tech_USA",
											["type"] = "us carrier tech",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)
	-- ********************************************************
	local staticObj = {

		["name"] = namePrefix .. "4temp Corral Tech 1", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["livery_id"] = "yellow",
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = 25.203805239988,
												["angle"] = 4.7472955654246,
												["x"] = 15.325497041995,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_tech_USA",
											["type"] = "us carrier tech",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)
	-- ********************************************************
	local staticObj = {

		["name"] = namePrefix .. "4temp Corral Tech 2", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["livery_id"] = "yellow",
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = 24.753144659975,
												["angle"] = 5.218534463463,
												["x"] = 13.844755134996,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_tech_USA",
											["type"] = "us carrier tech",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)
	-- ********************************************************
	local staticObj = {

		["name"] = namePrefix .. "4temp Junk Yard Seaman", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["category"] = "Personnel",
											["offsets"] = 
											{
												["y"] = 31.255831669958,
												["angle"] = 4.7472955654246,
												["x"] = -78.473079361007,
											}, -- end of ["offsets"]
											["shape_name"] = "carrier_seaman_USA",
											["type"] = "Carrier Seaman",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)
	-- ********************************************************
	local staticObj = {

		["name"] = namePrefix .. "4temp EL2 Tug", -- unit name (Name this something identifiable if you wish to remove it later)
	-- Copy and paste over this with the units information
											["category"] = "ADEquipment",
											["offsets"] = 
											{
												["y"] = 25.035044669989,
												["angle"] = 2.4958208303519,
												["x"] = -22.810439552006,
											}, -- end of ["offsets"]
											["type"] = "AS32-31A",
	-- Copy and paste over this with the units information end

	-- these can be left as is, but is required.
		["groupId"] = 33,		-- id's of the unit we're spawning (will auto increment if id taken?)
		["unitId"] = 33,
		["y"] = -00127900,			-- The initial location of the unit (required else unit will offet on origin of map)
		["x"] = -00126557,			
		["heading"] = 37.55948550292,
		["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
		["linkOffset"] = true,
		["dead"] = false,
		["rate"] = 30,
	}
	coalition.addStaticObject(country.id.USA, staticObj)

    local staticObj = {
        ["name"] = namePrefix .. "PatioR F-14 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK103",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.574397958365,
                                                ["angle"] = 12.184219274949,
                                                ["x"] = -140.22202233315,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR F-14 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK106",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.999894815472,
                                                ["angle"] = 24.27935099127,
                                                ["x"] = -126.3733451222,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR F-14 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK102",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 28.245066265035,
                                                ["angle"] = 30.230923740571,
                                                ["x"] = -115.09659159312,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-W 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.273813754869,
                                                ["angle"] = 3.701919110256,
                                                ["x"] = -131.81665467857,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-B 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 23.24388530906,
                                                ["angle"] = 3.5448394775765,
                                                ["x"] = -119.34764000727,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-B 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 23.726752809735,
                                                ["angle"] = 3.6146526476563,
                                                ["x"] = -130.88525791424,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-B 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.911959307137,
                                                ["angle"] = 6.8435117638458,
                                                ["x"] = -114.74868459558,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-Y 5", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 20.905678081278,
                                                ["angle"] = 5.2727154370509,
                                                ["x"] = -126.96371630654,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-Y 6", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 18.76100756934,
                                                ["angle"] = 6.8435117638458,
                                                ["x"] = -110.09545944759,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    

	-- ********************************************************

end

function DYNDECK.forrestal_flex4c234(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Forrestal Full Deck 3 Cats 4 Spawns

    local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)

    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 22.33673287998,
                                                ["angle"] = 4.3982297150257,
                                                ["x"] = -77.835629449983,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_MD3",
                                            ["unitId"] = 27,
                                            ["rate"] = 1,
                                            ["y"] = 469450.90816145,
                                            ["x"] = -360934.97848659,
                                            ["name"] = namePrefix .. "CV-59 MD-3 Mule 1",
                                            ["heading"] = 4.3982297150257,
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object

    local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)

    -- Copy and paste over this with the units information
                                        ["livery_id"] = "vf-33 starfighters ab201 (1988)",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 29.972092159966,
                                                ["angle"] = 4.6949356878647,
                                                ["x"] = -70.971807360009,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 34,
                                            ["rate"] = "50",
                                            ["y"] = 469458.54352073,
                                            ["x"] = -360928.1146645,
                                            ["name"] = namePrefix .. "CV-59 F14A heck 1",
                                            ["heading"] = 4.6949356878647,
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object

    local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)

    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vf-33 starfighters ab201 (1988)",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.235489899991,
                                                ["angle"] = 1.5882496193148,
                                                ["x"] = -62.675864739984,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 35,
                                            ["rate"] = "50",
                                            ["y"] = 469454.80691847,
                                            ["x"] = -360919.81872188,
                                            ["name"] = namePrefix .. "CV-59 F14A heck 2",
                                            ["heading"] = 1.5882496193148,
    -- Copy and paste over this with the units information end

    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object

    local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)

                                            ["livery_id"] = "VF-21 Freelancers 200",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 10.262743929983,
                                                ["angle"] = 3.7350045992679,
                                                ["x"] = 171.91009173996,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 2,
                                            ["rate"] = "50",
                                            ["y"] = 469438.8341725,
                                            ["x"] = -360685.2327654,
                                            ["name"] = namePrefix .. "CV-59 F14A bug 1",
                                            ["heading"] = 3.7350045992679,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object

    local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            ["livery_id"] = "VF-21 Freelancers 200",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 10.134759989975,
                                                ["angle"] = 3.7350045992679,
                                                ["x"] = 157.95984155999,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 5,
                                            ["rate"] = "50",
                                            ["y"] = 469438.70618856,
                                            ["x"] = -360699.18301558,
                                            ["name"] = namePrefix .. "CV-59 F14A bug 2",
                                            ["heading"] = 3.7350045992679,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "VF-21 Freelancers 200",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 10.817341029993,
                                                ["angle"] = 3.7350045992679,
                                                ["x"] = 143.58297822002,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 8,
                                            ["rate"] = "50",
                                            ["y"] = 469439.3887696,
                                            ["x"] = -360713.55987892,
                                            ["name"] = namePrefix .. "CV-59 F14A bug 3",
                                            ["heading"] = 3.7350045992679,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "VF-21 Freelancers 200",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 11.457260769967,
                                                ["angle"] = 3.7350045992679,
                                                ["x"] = 128.35288858,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 9,
                                            ["rate"] = "50",
                                            ["y"] = 469440.02868934,
                                            ["x"] = -360728.78996856,
                                            ["name"] = namePrefix .. "CV-59 F14A bug 4",
                                            ["heading"] = 3.7350045992679,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "USMC VMA-311 Tomcats",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 14.070305300003,
                                                ["angle"] = 5.1312680008633,
                                                ["x"] = -2.6952501999913,
                                            }, -- end of ["offsets"]
                                            ["type"] = "A-4E-C",
                                            ["unitId"] = 23,
                                            ["rate"] = 40,
                                            ["y"] = 469442.64173387,
                                            ["x"] = -360859.83810734,
                                            ["name"] = namePrefix .. "CV-59 A4 mid 1",
                                            ["heading"] = 5.1312680008633,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 28.15586408996,
                                                ["angle"] = 4.7298422729046,
                                                ["x"] = -41.413245120028,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_NS60",
                                            ["unitId"] = 26,
                                            ["rate"] = 1,
                                            ["y"] = 469456.72729266,
                                            ["x"] = -360898.55610226,
                                            ["name"] = namePrefix .. "CV-59 NS-60 Tilly 1",
                                            ["heading"] = 4.7298422729046,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 22.33673287998,
                                                ["angle"] = 4.3982297150257,
                                                ["x"] = -77.835629449983,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_MD3",
                                            ["unitId"] = 27,
                                            ["rate"] = 1,
                                            ["y"] = 469450.90816145,
                                            ["x"] = -360934.97848659,
                                            ["name"] = namePrefix .. "CV-59 MD-3 Mule 1",
                                            ["heading"] = 4.3982297150257,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 31.27796856995,
                                                ["angle"] = 5.2883476335428,
                                                ["x"] = -50.06724542001,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_Large_Forklift",
                                            ["unitId"] = 28,
                                            ["rate"] = 1,
                                            ["y"] = 469459.84939714,
                                            ["x"] = -360907.21010256,
                                            ["name"] = namePrefix .. "CV-59 Large Forklift 1",
                                            ["heading"] = -0.9948376736368,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 15.971448700002,
                                                ["angle"] = 0.2094395102393,
                                                ["x"] = 84.003947869991,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_H60",
                                            ["unitId"] = 29,
                                            ["rate"] = 1,
                                            ["y"] = 469444.54287727,
                                            ["x"] = -360773.13890927,
                                            ["name"] = namePrefix .. "CV-59 Hyster 60 1",
                                            ["heading"] = 0.2094395102393,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "VF-31 AE204 1988",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 11.447393599956,
                                                ["angle"] = 3.7350045992679,
                                                ["x"] = 113.54730550997,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 31,
                                            ["rate"] = "50",
                                            ["y"] = 469440.01882217,
                                            ["x"] = -360743.59555163,
                                            ["name"] = namePrefix .. "CV-59 F14A bug 5",
                                            ["heading"] = 3.7350045992679,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "VF-31 AE200 1988",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 13.325865889958,
                                                ["angle"] = 3.7350045992679,
                                                ["x"] = 99.885688829992,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 32,
                                            ["rate"] = "50",
                                            ["y"] = 469441.89729446,
                                            ["x"] = -360757.25716831,
                                            ["name"] = namePrefix .. "CV-59 F14A bug 6",
                                            ["heading"] = 3.7350045992679,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "vf-33 starfighters ab201 (1988)",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 29.972092159966,
                                                ["angle"] = 4.6949356878647,
                                                ["x"] = -70.971807360009,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 34,
                                            ["rate"] = "50",
                                            ["y"] = 469458.54352073,
                                            ["x"] = -360928.1146645,
                                            ["name"] = namePrefix .. "CV-59 F14A heck 1",
                                            ["heading"] = 4.6949356878647,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "vf-33 starfighters ab201 (1988)",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.235489899991,
                                                ["angle"] = 1.5882496193148,
                                                ["x"] = -62.675864739984,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14A-135-GR",
                                            ["unitId"] = 35,
                                            ["rate"] = "50",
                                            ["y"] = 469454.80691847,
                                            ["x"] = -360919.81872188,
                                            ["name"] = namePrefix .. "CV-59 F14A heck 2",
                                            ["heading"] = 1.5882496193148,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "USMC VMA-311 Tomcats",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 12.865749110002,
                                                ["angle"] = 5.1312680008633,
                                                ["x"] = 6.0377822199953,
                                            }, -- end of ["offsets"]
                                            ["type"] = "A-4E-C",
                                            ["unitId"] = 36,
                                            ["rate"] = 40,
                                            ["y"] = 469441.43717768,
                                            ["x"] = -360851.10507492,
                                            ["name"] = namePrefix .. "CV-59 A4 mid 2",
                                            ["heading"] = 5.1312680008633,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "USN VA-144 Roadrunners",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 13.123868289986,
                                                ["angle"] = 5.1312680008633,
                                                ["x"] = 14.899874229974,
                                            }, -- end of ["offsets"]
                                            ["type"] = "A-4E-C",
                                            ["unitId"] = 37,
                                            ["rate"] = 40,
                                            ["y"] = 469441.69529686,
                                            ["x"] = -360842.24298291,
                                            ["name"] = namePrefix .. "CV-59 A4 mid 3",
                                            ["heading"] = 5.1312680008633,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "USN VA-144 Roadrunners",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 12.263471009966,
                                                ["angle"] = 5.1312680008633,
                                                ["x"] = 24.837462849973,
                                            }, -- end of ["offsets"]
                                            ["type"] = "A-4E-C",
                                            ["unitId"] = 38,
                                            ["rate"] = 40,
                                            ["y"] = 469440.83489958,
                                            ["x"] = -360832.30539429,
                                            ["name"] = namePrefix .. "CV-59 A4 mid 4",
                                            ["heading"] = 5.1312680008633,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "VAW-124 BearAces",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 16.332032859966,
                                                ["angle"] = 4.2062434973063,
                                                ["x"] = 76.439462339971,
                                            }, -- end of ["offsets"]
                                            ["type"] = "E-2C",
                                            ["unitId"] = 40,
                                            ["rate"] = "100",
                                            ["y"] = 469444.90346143,
                                            ["x"] = -360780.7033948,
                                            ["name"] = namePrefix .. "CV-59 E2D bug 1",
                                            ["heading"] = 4.2062434973063,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.159426649974,
                                                ["angle"] = 4.7298422729046,
                                                ["x"] = 66.45111609,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_NS60",
                                            ["unitId"] = 41,
                                            ["rate"] = 1,
                                            ["y"] = 469452.73085522,
                                            ["x"] = -360790.69174105,
                                            ["name"] = namePrefix .. "CV-59 NS-60 Tilly 2",
                                            ["heading"] = 4.7298422729046,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 1500,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 16.458585369983,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = 88.506038529973,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "ammo_box_cargo",
                                            ["type"] = "ammo_cargo",
                                            ["unitId"] = 43,
                                            ["rate"] = 100,
                                            ["y"] = 469445.03001394,
                                            ["x"] = -360768.63681861,
                                            ["name"] = namePrefix .. "CV-59 Ammo 1",
                                            ["heading"] = -1.6406094968747,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 1500,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 16.453315379971,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = 89.827295569994,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "ammo_box_cargo",
                                            ["type"] = "ammo_cargo",
                                            ["unitId"] = 44,
                                            ["rate"] = 100,
                                            ["y"] = 469445.02474395,
                                            ["x"] = -360767.31556157,
                                            ["name"] = namePrefix .. "CV-59 Ammo 2",
                                            ["heading"] = -1.6406094968747,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 1500,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 29.497724729998,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = 62.634507059993,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "ammo_box_cargo",
                                            ["type"] = "ammo_cargo",
                                            ["unitId"] = 45,
                                            ["rate"] = 100,
                                            ["y"] = 469458.0691533,
                                            ["x"] = -360794.50835008,
                                            ["name"] = namePrefix .. "CV-59 Ammo 3",
                                            ["heading"] = -1.6406094968747,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 1500,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 30.737726669991,
                                                ["angle"] = 4.8345620280243,
                                                ["x"] = 61.212707380007,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "ammo_box_cargo",
                                            ["type"] = "ammo_cargo",
                                            ["unitId"] = 46,
                                            ["rate"] = 100,
                                            ["y"] = 469459.30915524,
                                            ["x"] = -360795.93014976,
                                            ["name"] = namePrefix .. "CV-59 Ammo 4",
                                            ["heading"] = -1.4486232791553,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 1500,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.599187659973,
                                                ["angle"] = 0.0174532925199,
                                                ["x"] = -45.894397350028,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "ammo_box_cargo",
                                            ["type"] = "ammo_cargo",
                                            ["unitId"] = 47,
                                            ["rate"] = 100,
                                            ["y"] = 469453.17061623,
                                            ["x"] = -360903.03725449,
                                            ["name"] = namePrefix .. "CV-59 Ammo 5",
                                            ["heading"] = 0.0174532925199,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 1500,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 23.251629469974,
                                                ["angle"] = 0.0174532925199,
                                                ["x"] = -45.874063010036,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "ammo_box_cargo",
                                            ["type"] = "ammo_cargo",
                                            ["unitId"] = 48,
                                            ["rate"] = 100,
                                            ["y"] = 469451.82305804,
                                            ["x"] = -360903.01692015,
                                            ["name"] = namePrefix .. "CV-59 Ammo 6",
                                            ["heading"] = 0.0174532925199,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.196566589992,
                                                ["angle"] = 1.4835298641951,
                                                ["x"] = -48.328411909984,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 49,
                                            ["rate"] = 100,
                                            ["y"] = 469452.76799516,
                                            ["x"] = -360905.47126905,
                                            ["name"] = namePrefix .. "CV-59 Bombs 1",
                                            ["heading"] = 1.4835298641951,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 16.106317459955,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = 91.922479700006,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 50,
                                            ["rate"] = 100,
                                            ["y"] = 469444.67774603,
                                            ["x"] = -360765.22037744,
                                            ["name"] = namePrefix .. "CV-59 Bombs 2",
                                            ["heading"] = -1.6406094968747,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 16.031181099999,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = 93.406567899976,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 51,
                                            ["rate"] = 100,
                                            ["y"] = 469444.60260967,
                                            ["x"] = -360763.73628924,
                                            ["name"] = namePrefix .. "CV-59 Bombs 3",
                                            ["heading"] = -1.6406094968747,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 15.933522039966,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = 94.803157570015,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 52,
                                            ["rate"] = 100,
                                            ["y"] = 469444.50495061,
                                            ["x"] = -360762.33969957,
                                            ["name"] = namePrefix .. "CV-59 Bombs 4",
                                            ["heading"] = -1.6406094968747,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 21.045754369989,
                                                ["angle"] = 4.7298422729046,
                                                ["x"] = 62.761577569996,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 53,
                                            ["rate"] = 100,
                                            ["y"] = 469449.61718294,
                                            ["x"] = -360794.38127957,
                                            ["name"] = namePrefix .. "CV-59 Bombs 5",
                                            ["heading"] = -1.553343034275,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 21.37175436999,
                                                ["angle"] = 0,
                                                ["x"] = 26.183162770001,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 54,
                                            ["rate"] = 100,
                                            ["y"] = 469449.94318294,
                                            ["x"] = -360830.95969437,
                                            ["name"] = namePrefix .. "CV-59 Bombs 6",
                                            ["heading"] = 0,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 20.893985959992,
                                                ["angle"] = 0,
                                                ["x"] = 23.123464139993,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 56,
                                            ["rate"] = 100,
                                            ["y"] = 469449.46541453,
                                            ["x"] = -360834.019393,
                                            ["name"] = namePrefix .. "CV-59 Bombs 8",
                                            ["heading"] = 0,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.439851770003,
                                                ["angle"] = 0,
                                                ["x"] = 23.309999260004,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 57,
                                            ["rate"] = 100,
                                            ["y"] = 469448.01128034,
                                            ["x"] = -360833.83285788,
                                            ["name"] = namePrefix .. "CV-59 Bombs 9",
                                            ["heading"] = 0,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 1500,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 21.212431159976,
                                                ["angle"] = 4.7298422729046,
                                                ["x"] = 28.729959079996,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "ammo_box_cargo",
                                            ["type"] = "ammo_cargo",
                                            ["unitId"] = 58,
                                            ["rate"] = 100,
                                            ["y"] = 469449.78385973,
                                            ["x"] = -360828.41289806,
                                            ["name"] = namePrefix .. "CV-59 Ammo 7",
                                            ["heading"] = -1.553343034275,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.728229369968,
                                                ["angle"] = 1.2740903539558,
                                                ["x"] = -54.847454730014,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_MD3",
                                            ["unitId"] = 59,
                                            ["rate"] = 1,
                                            ["y"] = 469455.29965794,
                                            ["x"] = -360911.99031187,
                                            ["name"] = namePrefix .. "CV-59 MD-3 Mule 2",
                                            ["heading"] = 1.274090353955,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 11.97817606997,
                                                ["angle"] = 2.8797932657906,
                                                ["x"] = 90.446121620014,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_MD3",
                                            ["unitId"] = 60,
                                            ["rate"] = 1,
                                            ["y"] = 469440.54960464,
                                            ["x"] = -360766.69673552,
                                            ["name"] = namePrefix .. "CV-59 MD-3 Mule 3",
                                            ["heading"] = 2.8797932657906,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.195021889987,
                                                ["angle"] = 5.7246799465414,
                                                ["x"] = 28.489813330001,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 65,
                                            ["rate"] = 20,
                                            ["y"] = 469447.76645046,
                                            ["x"] = -360828.65304381,
                                            ["name"] = namePrefix .. "CV-59 Technician 1",
                                            ["heading"] = -0.5585053606382,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 17.918418669957,
                                                ["angle"] = 6.1959188445799,
                                                ["x"] = 28.31462095998,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 66,
                                            ["rate"] = 20,
                                            ["y"] = 469446.48984724,
                                            ["x"] = -360828.82823618,
                                            ["name"] = namePrefix .. "CV-59 Technician 2",
                                            ["heading"] = -0.0872664625997,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 21.632032659953,
                                                ["angle"] = 4.3633231299858,
                                                ["x"] = 30.092285580002,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 67,
                                            ["rate"] = 20,
                                            ["y"] = 469450.20346123,
                                            ["x"] = -360827.05057156,
                                            ["name"] = namePrefix .. "CV-59 Technician 3",
                                            ["heading"] = -1.9198621771938,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 31.081593789975,
                                                ["angle"] = 4.3458698374659,
                                                ["x"] = 62.348933589994,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 68,
                                            ["rate"] = 20,
                                            ["y"] = 469459.65302236,
                                            ["x"] = -360794.79392355,
                                            ["name"] = namePrefix .. "CV-59 Technician 4",
                                            ["heading"] = -1.9373154697137,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.131282319955,
                                                ["angle"] = 3.2463124087094,
                                                ["x"] = -44.513802300033,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 69,
                                            ["rate"] = 20,
                                            ["y"] = 469452.70271089,
                                            ["x"] = -360901.65665944,
                                            ["name"] = namePrefix .. "CV-59 Technician 5",
                                            ["heading"] = -3.0368728984702,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.487857559987,
                                                ["angle"] = 4.1713369122664,
                                                ["x"] = -47.165706939995,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 70,
                                            ["rate"] = 20,
                                            ["y"] = 469454.05928613,
                                            ["x"] = -360904.30856408,
                                            ["name"] = namePrefix .. "CV-59 Technician 6",
                                            ["heading"] = -2.1118483949132,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 29.100804699992,
                                                ["angle"] = 0.9424777960769,
                                                ["x"] = 61.324876810017,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 71,
                                            ["rate"] = 20,
                                            ["y"] = 469457.67223327,
                                            ["x"] = -360795.81798033,
                                            ["name"] = namePrefix .. "CV-59 Technician 7",
                                            ["heading"] = 0.9424777960769,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 27.730528499989,
                                                ["angle"] = 1.3439035240356,
                                                ["x"] = 62.48927043,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 72,
                                            ["rate"] = 20,
                                            ["y"] = 469456.30195707,
                                            ["x"] = -360794.65358671,
                                            ["name"] = namePrefix .. "CV-59 Technician 8",
                                            ["heading"] = 1.3439035240356,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 11.66171458998,
                                                ["angle"] = 2.9496064358704,
                                                ["x"] = -5.2636686500045,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 73,
                                            ["rate"] = 20,
                                            ["y"] = 469440.23314316,
                                            ["x"] = -360862.40652579,
                                            ["name"] = namePrefix .. "CV-59 Technician 9",
                                            ["heading"] = 2.9496064358704,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 14.806669440004,
                                                ["angle"] = 4.7123889803847,
                                                ["x"] = 88.081767519994,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 74,
                                            ["rate"] = 20,
                                            ["y"] = 469443.37809801,
                                            ["x"] = -360769.06108962,
                                            ["name"] = namePrefix .. "CV-59 Technician 10",
                                            ["heading"] = -1.5707963267949,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "blue",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 6.6044085899484,
                                                ["angle"] = 3.9444441095072,
                                                ["x"] = 22.162760849984,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 75,
                                            ["rate"] = 20,
                                            ["y"] = 469435.17583716,
                                            ["x"] = -360834.98009629,
                                            ["name"] = namePrefix .. "CV-59 Technician 11",
                                            ["heading"] = -2.3387411976724,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 5.6825801399536,
                                                ["angle"] = 0.907571211037,
                                                ["x"] = 21.009934830014,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 76,
                                            ["rate"] = 20,
                                            ["y"] = 469434.25400871,
                                            ["x"] = -360836.13292231,
                                            ["name"] = namePrefix .. "CV-59 Technician 12",
                                            ["heading"] = 0.907571211037,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "blue",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 12.482483859989,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = -6.3519227600191,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 77,
                                            ["rate"] = 20,
                                            ["y"] = 469441.05391243,
                                            ["x"] = -360863.4947799,
                                            ["name"] = namePrefix .. "CV-59 Technician 13",
                                            ["heading"] = -1.6406094968747,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "blue",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 9.8248471499537,
                                                ["angle"] = 3.700098014228,
                                                ["x"] = 76.027643800015,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 78,
                                            ["rate"] = 20,
                                            ["y"] = 469438.39627572,
                                            ["x"] = -360781.11521334,
                                            ["name"] = namePrefix .. "CV-59 Technician 14",
                                            ["heading"] = -2.5830872929516,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "blue",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 8.5271150099579,
                                                ["angle"] = 1.6057029118347,
                                                ["x"] = 75.335432389984,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 79,
                                            ["rate"] = 20,
                                            ["y"] = 469437.09854358,
                                            ["x"] = -360781.80742475,
                                            ["name"] = namePrefix .. "CV-59 Technician 15",
                                            ["heading"] = 1.6057029118347,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 9.5831095199683,
                                                ["angle"] = 5.7944931166212,
                                                ["x"] = 74.820895490004,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 80,
                                            ["rate"] = 20,
                                            ["y"] = 469438.15453809,
                                            ["x"] = -360782.32196165,
                                            ["name"] = namePrefix .. "CV-59 Technician 16",
                                            ["heading"] = -0.4886921905584,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 9.395204159955,
                                                ["angle"] = 5.235987755983,
                                                ["x"] = 89.386125179997,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 81,
                                            ["rate"] = 20,
                                            ["y"] = 469437.96663273,
                                            ["x"] = -360767.75673196,
                                            ["name"] = namePrefix .. "CV-59 Technician 17",
                                            ["heading"] = -1.0471975511966,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 7.5748663699487,
                                                ["angle"] = 4.6425758103049,
                                                ["x"] = 20.888940159988,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 82,
                                            ["rate"] = 20,
                                            ["y"] = 469436.14629494,
                                            ["x"] = -360836.25391698,
                                            ["name"] = namePrefix .. "CV-59 Technician 18",
                                            ["heading"] = -1.6406094968747,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 13.475844899949,
                                                ["angle"] = 1.3962634015954,
                                                ["x"] = 28.803845649993,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 83,
                                            ["rate"] = 20,
                                            ["y"] = 469442.04727347,
                                            ["x"] = -360828.33901149,
                                            ["name"] = namePrefix .. "CV-59 Technician 19",
                                            ["heading"] = 1.3962634015954,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 9.4500615699799,
                                                ["angle"] = 3.4382986264288,
                                                ["x"] = 90.874154079997,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 84,
                                            ["rate"] = 20,
                                            ["y"] = 469438.02149014,
                                            ["x"] = -360766.26870306,
                                            ["name"] = namePrefix .. "CV-59 Technician 20",
                                            ["heading"] = -2.8448866807508,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 28.252880869957,
                                                ["angle"] = 5.3930673886625,
                                                ["x"] = 32.270201759995,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 85,
                                            ["rate"] = 20,
                                            ["y"] = 469456.82430944,
                                            ["x"] = -360824.87265538,
                                            ["name"] = namePrefix .. "CV-59 Technician 21",
                                            ["heading"] = -0.8901179185171,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 23.989666519978,
                                                ["angle"] = 3.7699111843077,
                                                ["x"] = -53.761342699989,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 86,
                                            ["rate"] = 20,
                                            ["y"] = 469452.56109509,
                                            ["x"] = -360910.90419984,
                                            ["name"] = namePrefix .. "CV-59 Technician 22",
                                            ["heading"] = -2.5132741228719,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 7.5537387600052,
                                                ["angle"] = 5.7770398241012,
                                                ["x"] = 19.452221489977,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 87,
                                            ["rate"] = 20,
                                            ["y"] = 469436.12516733,
                                            ["x"] = -360837.69063565,
                                            ["name"] = namePrefix .. "CV-59 Technician 24",
                                            ["heading"] = -0.5061454830784,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 11.661630999995,
                                                ["angle"] = 4.7123889803847,
                                                ["x"] = 87.133109899994,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
                                            ["unitId"] = 88,
                                            ["rate"] = 20,
                                            ["y"] = 469440.23305957,
                                            ["x"] = -360770.00974724,
                                            ["name"] = namePrefix .. "CV-59 Technician 23",
                                            ["heading"] = -1.5707963267949,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -2.7689845300047,
                                                ["angle"] = 3.8397243543875,
                                                ["x"] = 98.852623810002,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_shooter",
                                            ["type"] = "us carrier shooter",
                                            ["unitId"] = 89,
                                            ["rate"] = 20,
                                            ["y"] = 469425.80244404,
                                            ["x"] = -360758.29023333,
                                            ["name"] = namePrefix .. "CV-59 Shooter 1",
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -2.6633533000131,
                                                ["angle"] = 4.904375198104,
                                                ["x"] = 97.342026819999,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_shooter",
                                            ["type"] = "us carrier shooter",
                                            ["unitId"] = 90,
                                            ["rate"] = 20,
                                            ["y"] = 469425.90807527,
                                            ["x"] = -360759.80083032,
                                            ["name"] = namePrefix .. "CV-59 Shooter 2",
                                            ["heading"] = -1.378810109075,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "green",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -2.104307260015,
                                                ["angle"] = 3.682644721708,
                                                ["x"] = 88.38926252001,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_shooter",
                                            ["type"] = "us carrier shooter",
                                            ["unitId"] = 91,
                                            ["rate"] = 20,
                                            ["y"] = 469426.46712131,
                                            ["x"] = -360768.75359462,
                                            ["name"] = namePrefix .. "CV-59 Shooter 3",
                                            ["heading"] = -2.6005405854716,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -1.142018720042,
                                                ["angle"] = 5.0440015382636,
                                                ["x"] = 89.373070589965,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_shooter",
                                            ["type"] = "us carrier shooter",
                                            ["unitId"] = 92,
                                            ["rate"] = 20,
                                            ["y"] = 469427.42940985,
                                            ["x"] = -360767.76978655,
                                            ["name"] = namePrefix .. "CV-59 Shooter 5",
                                            ["heading"] = -1.239183768916,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["mass"] = 840,
                                            ["category"] = "Cargos",
                                            ["canCargo"] = false,
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.73112368997,
                                                ["angle"] = 4.7298422729046,
                                                ["x"] = 62.647827629989,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "m117_cargo",
                                            ["type"] = "m117_cargo",
                                            ["unitId"] = 95,
                                            ["rate"] = 100,
                                            ["y"] = 469453.30255226,
                                            ["x"] = -360794.49502951,
                                            ["name"] = namePrefix .. "CV-59 Bombs 10",
                                            ["heading"] = -1.553343034275,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["livery_id"] = "green",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -2.0484931700048,
                                                ["angle"] = 3.8048177693476,
                                                ["x"] = 90.597058320011,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_shooter",
                                            ["type"] = "us carrier shooter",
                                            ["unitId"] = 93,
                                            ["rate"] = 20,
                                            ["y"] = 469426.5229354,
                                            ["x"] = -360766.54579882,
                                            ["name"] = namePrefix .. "CV-59 Shooter 4",
                                            ["heading"] = -2.478367537832,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
                                            
                                            local staticObj = {
        ["name"] = namePrefix .. "dDeck_forrestal", -- unit name (Name this something identifiable if you wish to remove it later)
                                            
                                                                                    ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 21.043987939949,
                                                ["angle"] = 4.6949356878647,
                                                ["x"] = -7.95861625002,
                                            }, -- end of ["offsets"]
                                            ["type"] = "CV_59_H60",
                                            ["unitId"] = 94,
                                            ["rate"] = 1,
                                            ["y"] = 469449.61541651,
                                            ["x"] = -360865.10147339,
                                            ["name"] = namePrefix .. "CV-59 Hyster 60 3",
                                            ["heading"] = -1.5882496193149,
                                            
                                            -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object

end

function DYNDECK.sc_cat2l(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. "_" .. templateName .. "_"

    -- Creates 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 400 Paul 'Greekbull' Tsaras CO",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -0.56539029044469,
                                                ["angle"] = 435.79308202651,
                                                ["x"] = 49.037352753452,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vfa-25 generic",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -1.9165360388852,
                                                ["angle"] = 435.79308202651,
                                                ["x"] = 60.08834944242,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vmfa-122 high visibility",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -3.3698449825059,
                                                ["angle"] = 435.79308202651,
                                                ["x"] = 70.985443953678,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- *******************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 426 Matt 'Gannon' Wayne",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -4.7172584559018,
                                                ["angle"] = 435.79308202651,
                                                ["x"] = 82.042290909375,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 5", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vmfa-122",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -5.6807811134881,
                                                ["angle"] = 435.79308202651,
                                                ["x"] = 92.660709237033,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 6", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vmfa-122",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -6.9761561406201,
                                                ["angle"] = 435.79308202651,
                                                ["x"] = 104.14295655801,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 7", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 Clean",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -7.9935357811509,
                                                ["angle"] = 435.79308202651,
                                                ["x"] = 115.02702279532,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 8", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 Clean",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -8.8622980860768,
                                                ["angle"] = 435.79308202651,
                                                ["x"] = 125.99653280804,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 9", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vmfa-122",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -8.4189546313416,
                                                ["angle"] = 429.73678952209,
                                                ["x"] = 136.63282885359,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L F-18 10", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 Clean",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -9.0716331338308,
                                                ["angle"] = 354.47819217609,
                                                ["x"] = 149.78327421946,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L Tech-Y 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 5.3374882673047,
                                                ["angle"] = 116.13602952373,
                                                ["x"] = 42.777801593228,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L Tech-B 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 5.5495708687677,
                                                ["angle"] = 117.65446597297,
                                                ["x"] = 47.052935840525,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L Tech-B 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 0.22348151799788,
                                                ["angle"] = 117.65446597297,
                                                ["x"] = 90.125866213387,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L Tech-B 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -1.4497604680265,
                                                ["angle"] = 117.65446597297,
                                                ["x"] = 102.70969022384,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats 9 F-18s on Carrier Bow Catapult 2.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2L Tech-W 5", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -0.86790735153088,
                                                ["angle"] = 115.90913672097,
                                                ["x"] = 107.96544928822,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_cat2r(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. "_" .. templateName .. "_"

    -- Creats aircraft and techs on Catapult 2 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2R F-18 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 400 Paul 'Greekbull' Tsaras CO",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -0.42373331700052,
                                                ["angle"] = 479.77537917677,
                                                ["x"] = 48.801296065951,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Catapult 2 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2R F-18 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vfa-25 generic",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -1.9165360388852,
                                                ["angle"] = 479.77537917677,
                                                ["x"] = 60.08834944242,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Catapult 2 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2R F-18 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vmfa-122 high visibility",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -3.3698449825059,
                                                ["angle"] = 479.77537917677,
                                                ["x"] = 70.985443953678,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Catapult 2 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2R Tech-Y 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 5.4478270146218,
                                                ["angle"] = 160.11832667399,
                                                ["x"] = 42.31126245152,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Catapult 2 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2R Tech-B 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 5.6211179625298,
                                                ["angle"] = 161.63676312323,
                                                ["x"] = 47.1192869069,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Catapult 2 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2R Tech-B 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 3.0795751066997,
                                                ["angle"] = 2.0089497358215,
                                                ["x"] = 58.878521974936,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Catapult 2 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2R Tech-B 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -1.1587672360767,
                                                ["angle"] = 5.1330890968913,
                                                ["x"] = 72.452471779597,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Catapult 2 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat2R Tech-Y 5", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 0.51246658829964,
                                                ["angle"] = 5.5170615323301,
                                                ["x"] = 72.529540910213,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_corral(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. "_" .. templateName .. "_"

    -- Creates aircraft and techs on Corral on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Corral F-18 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 Clean",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 32.777470310288,
                                                ["angle"] = 224.62569582771,
                                                ["x"] = 5.9309357552636,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Corral on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Corral Tech-B 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 29.62261911384,
                                                ["angle"] = 118.85874315684,
                                                ["x"] = 2.1943722273475,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Corral on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Corral Tech-W 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.854273797478,
                                                ["angle"] = 116.27565586389,
                                                ["x"] = 7.4119005094149,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_cat1(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Creates F-18s on Catapult 1 Nimitz Carrier.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat1 F-18 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 402 Alex 'Red Sky' Jonischskies Hi Viz",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 28.108140050537,
                                                ["angle"] = 10.159637342635,
                                                ["x"] = 75.492905602964,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats F-18s on Catapult 1 Nimitz Carrier.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat1 F-18 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 402 Alex 'Red Sky' Jonischskies Hi Viz",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 22.10437053479,
                                                ["angle"] = 10.159637342635,
                                                ["x"] = 83.262039503581,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats F-18s on Catapult 1 Nimitz Carrier.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat1 F-18 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 402 Alex 'Red Sky' Jonischskies Hi Viz",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 15.950453495473,
                                                ["angle"] = 3.6495592326962,
                                                ["x"] = 91.559690927119,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats F-18s on Catapult 1 Nimitz Carrier.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat1 F-18 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 402 Alex 'Red Sky' Jonischskies Hi Viz",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 13.854390702424,
                                                ["angle"] = 3.6495592326962,
                                                ["x"] = 102.95885426481,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats F-18s on Catapult 1 Nimitz Carrier.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat1 F-18 5", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 402 Alex 'Red Sky' Jonischskies Hi Viz",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 13.202562667095,
                                                ["angle"] = 3.6495592326962,
                                                ["x"] = 118.26254908461,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats F-18s on Catapult 1 Nimitz Carrier.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat1 F-18 6", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 402 Alex 'Red Sky' Jonischskies Hi Viz",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 11.614878866904,
                                                ["angle"] = 3.5273861850565,
                                                ["x"] = 131.18367415037,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats F-18s on Catapult 1 Nimitz Carrier.
    
    local staticObj = {
        ["name"] = namePrefix .. "Cat1 F-18 7", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 402 Alex 'Red Sky' Jonischskies Hi Viz",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 10.388253750276,
                                                ["angle"] = 3.4575730149768,
                                                ["x"] = 145.08093209201,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_island(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Creats aircraft and techs around island on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Island E-2Cx", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vaw-125 tigertails",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 15.467359055958,
                                                ["angle"] = 557.61706381573,
                                                ["x"] = -35.289777030018,
                                            }, -- end of ["offsets"]
                                            ["type"] = "E-2C",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs around island on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Island Tech-Y 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 7.0412458731262,
                                                ["angle"] = 160.11832667399,
                                                ["x"] = -37.131948660666,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs around island on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "Island Tech-P 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 21.632701538063,
                                                ["angle"] = 162.52688104174,
                                                ["x"] = -33.324470195337,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_deckeq(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Creats deck equipment around island on Nimitz class carrier.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq Tow 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.179609650167,
                                                ["angle"] = 545.06814649389,
                                                ["x"] = -34.726986137793,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq Tow 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 34.074706103411,
                                                ["angle"] = 546.01062428996,
                                                ["x"] = 71.571823411897,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq Tow 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 14.835235254354,
                                                ["angle"] = 375.47450307759,
                                                ["x"] = -54.859983171871,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq Tow 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -34.290094792497,
                                                ["angle"] = 507.63083403861,
                                                ["x"] = -119.2372580741,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-31A",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq Mover-1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 22.11354181959,
                                                ["angle"] = 523.07699791876,
                                                ["x"] = -48.306093823847,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-32A",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq Mover-2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 21.835171682406,
                                                ["angle"] = 523.07699791876,
                                                ["x"] = -42.875676980416,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-32A",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq Crain", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.547575156325,
                                                ["angle"] = 585.8914032757,
                                                ["x"] = -69.02095322825,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-36A",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq Rescue", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["category"] = "ADEquipment",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 20.684031571391,
                                                ["angle"] = 545.01578661633,
                                                ["x"] = -72.889667764425,
                                            }, -- end of ["offsets"]
                                            ["type"] = "AS32-p25",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq SH-60B-1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "standard",
                                            ["category"] = "Helicopters",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 21.156945293163,
                                                ["angle"] = 561.0030025646,
                                                ["x"] = -63.23041749546,
                                            }, -- end of ["offsets"]
                                            ["type"] = "SH-60B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq SH-60B-2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "standard",
                                            ["category"] = "Helicopters",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.992908088869,
                                                ["angle"] = 561.0030025646,
                                                ["x"] = -51.334443322704,
                                            }, -- end of ["offsets"]
                                            ["type"] = "SH-60B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats a UH-60 on the helipad of a Hazard perry.
    
    local staticObj = {
        ["name"] = namePrefix .. "Deckeq E-2D", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vaw-125 tigertails",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 24.709702325664,
                                                ["angle"] = 557.61706381573,
                                                ["x"] = -79.053240272477,
                                            }, -- end of ["offsets"]
                                            ["type"] = "E-2C",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_fantail(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT F-14B 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK100",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 18.179512487887,
                                                ["angle"] = 496.26874060812,
                                                ["x"] = -154.54050081595,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT F-14B 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-31 F-14B NK207",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 6.7391817566416,
                                                ["angle"] = 496.30364719316,
                                                ["x"] = -155.27503906218,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT F-14B 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK101_NPD",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -5.0029690814996,
                                                ["angle"] = 496.30364719316,
                                                ["x"] = -155.87628096397,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT F-14B 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-31 F-14B NK207",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -13.005046297121,
                                                ["angle"] = 497.1239519416,
                                                ["x"] = -146.66496187523,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT F-14B 5", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK102_NPD",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -15.307549672268,
                                                ["angle"] = 491.24219236238,
                                                ["x"] = -135.97118197623,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT F-14B 6", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-31 F-14B NK201 CO",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -21.875030227257,
                                                ["angle"] = 491.22473906986,
                                                ["x"] = -120.15838880036,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT Tech-Y 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 14.618622991992,
                                                ["angle"] = 149.85579067227,
                                                ["x"] = -143.34737720138,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT Tech-R 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 3.8587904552019,
                                                ["angle"] = 150.3270295703,
                                                ["x"] = -148.39389397052,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT Tech-R 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 2.9951744287039,
                                                ["angle"] = 150.60628225062,
                                                ["x"] = -148.6959220144,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT Tech-B 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -3.2820572675681,
                                                ["angle"] = 148.33735422303,
                                                ["x"] = -146.46714599295,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT Tech-W 5", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -5.4176867628193,
                                                ["angle"] = 146.87127765135,
                                                ["x"] = -135.06168999672,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on fan tail on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "FT Tech-Y 6", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -11.185698655444,
                                                ["angle"] = 151.70583967938,
                                                ["x"] = -117.66135621609,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_patio(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR F-14 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK103",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.574397958365,
                                                ["angle"] = 12.184219274949,
                                                ["x"] = -140.22202233315,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR F-14 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK106",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.999894815472,
                                                ["angle"] = 24.27935099127,
                                                ["x"] = -126.3733451222,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR F-14 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VF-2 F-14B NK102",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 28.245066265035,
                                                ["angle"] = 30.230923740571,
                                                ["x"] = -115.09659159312,
                                            }, -- end of ["offsets"]
                                            ["type"] = "F-14B",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-W 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.273813754869,
                                                ["angle"] = 3.701919110256,
                                                ["x"] = -131.81665467857,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-B 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 23.24388530906,
                                                ["angle"] = 3.5448394775765,
                                                ["x"] = -119.34764000727,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-B 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 23.726752809735,
                                                ["angle"] = 3.6146526476563,
                                                ["x"] = -130.88525791424,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-B 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 19.911959307137,
                                                ["angle"] = 6.8435117638458,
                                                ["x"] = -114.74868459558,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-Y 5", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 20.905678081278,
                                                ["angle"] = 5.2727154370509,
                                                ["x"] = -126.96371630654,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Patio on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "PatioR Tech-Y 6", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 18.76100756934,
                                                ["angle"] = 6.8435117638458,
                                                ["x"] = -110.09545944759,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_el1(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Creats aircraft and techs on Elevator 1.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL1 F-18 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vmfa-122",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 33.421244398461,
                                                ["angle"] = 224.62569582771,
                                                ["x"] = 23.527064339876,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Elevator 1.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL1 F-18 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vmfa-122",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 33.553319932144,
                                                ["angle"] = 224.62569582771,
                                                ["x"] = 34.459724906861,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Elevator 1.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL1 Tech-Y 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "yellow",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 25.408732227881,
                                                ["angle"] = 117.41011987769,
                                                ["x"] = 33.100003646528,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_el3(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Creats aircraft and techs on Elevator 3 on Nimitz Carriers
    
    local staticObj = {
        ["name"] = namePrefix .. "EL3 F-18 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "vmfa-122",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 33.21480070767,
                                                ["angle"] = 224.62569582771,
                                                ["x"] = -101.46372616621,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Elevator 3 on Nimitz Carriers
    
    local staticObj = {
        ["name"] = namePrefix .. "EL3 F-18 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 Clean",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 33.275586055124,
                                                ["angle"] = 224.62569582771,
                                                ["x"] = -90.506253749648,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Elevator 3 on Nimitz Carriers
    
    local staticObj = {
        ["name"] = namePrefix .. "EL3 Tech-R 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 32.838770595401,
                                                ["angle"] = 120.27245985096,
                                                ["x"] = -103.85624140846,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Elevator 3 on Nimitz Carriers
    
    local staticObj = {
        ["name"] = namePrefix .. "EL3 Tech-W 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.443518892345,
                                                ["angle"] = 118.9111030344,
                                                ["x"] = -95.772647928271,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Elevator 3 on Nimitz Carriers
    
    local staticObj = {
        ["name"] = namePrefix .. "EL3 Tech-B 3", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 26.163495978953,
                                                ["angle"] = 120.25500655844,
                                                ["x"] = -92.537165392662,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft and techs on Elevator 3 on Nimitz Carriers
    
    local staticObj = {
        ["name"] = namePrefix .. "EL3 Tech-P 4", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = 32.372135214934,
                                                ["angle"] = 114.94920563238,
                                                ["x"] = -88.080092987373,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
end

function DYNDECK.sc_el4(shipID, templateName)

    local namePrefix = "dyndeck_" .. shipID .. templateName

    -- Creats aircraft the techs on Elevator 4 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL4 F-18 1", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 Generic",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -33.344235799775,
                                                ["angle"] = 234.05047378848,
                                                ["x"] = -107.29391769261,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft the techs on Elevator 4 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL4 F-18 2", -- unit name (Name this something identifiable if you wish to remove it later)
    
    -- Copy and paste over this with the units information
                                            ["livery_id"] = "VFA-25 Clean",
                                            ["category"] = "Planes",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -33.406129444774,
                                                ["angle"] = 234.05047378848,
                                                ["x"] = -95.604236622335,
                                            }, -- end of ["offsets"]
                                            ["type"] = "FA-18C_hornet",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft the techs on Elevator 4 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL4 Tech-B 1", -- unit name (Name this something identifiable if you wish to remove it later)
                                            ["livery_id"] = "purple",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -31.964097133702,
                                                ["angle"] = 118.54458389148,
                                                ["x"] = -110.23901828911,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft the techs on Elevator 4 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL4 Tech-R 2", -- unit name (Name this something identifiable if you wish to remove it later)
                                            ["livery_id"] = "red",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -29.671642155997,
                                                ["angle"] = 120.1328335108,
                                                ["x"] = -103.49094182992,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft the techs on Elevator 4 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL4 Tech-B 3", -- unit name (Name this something identifiable if you wish to remove it later)
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -25.072092217455,
                                                ["angle"] = 116.97378756469,
                                                ["x"] = -105.05066039867,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft the techs on Elevator 4 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL4 Tech-W 4", -- unit name (Name this something identifiable if you wish to remove it later)
                                            ["livery_id"] = "white",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -27.725434969865,
                                                ["angle"] = 119.50451498008,
                                                ["x"] = -98.238166449895,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    -- Creats aircraft the techs on Elevator 4 on Nimitz Carriers.
    
    local staticObj = {
        ["name"] = namePrefix .. "EL4 Tech-B 5", -- unit name (Name this something identifiable if you wish to remove it later)
                                            ["livery_id"] = "brown",
                                            ["category"] = "Personnel",
                                            ["offsets"] = 
                                            {
                                                ["y"] = -26.717017857683,
                                                ["angle"] = 116.86906780957,
                                                ["x"] = -93.431793780025,
                                            }, -- end of ["offsets"]
                                            ["shape_name"] = "carrier_tech_USA",
                                            ["type"] = "us carrier tech",
    -- Copy and paste over this with the units information end
    
    -- these can be left as is, but is required.
        ["groupId"] = 1,		-- id's of the group/unit we're spawning (will auto increment if id taken?)
        ["unitId"] = 1,
        ["y"] = 0,			-- The initial location of the unit (required else unit will offset on origin of map)
        ["x"] = 0,			
        ["heading"] = 0,
        ["linkUnit"] = shipID, -- This value must be set Via 'shipID = #' where # is the id of the ship you wish to spawn on
        ["linkOffset"] = true,
        ["dead"] = false,
    }
    coalition.addStaticObject(country.id.USA, staticObj) -- makes the object
    
    -- ********************************************************
    
end

-- END Dynamic Deck Population