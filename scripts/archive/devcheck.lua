-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Check for Static or Dynamic mission file loading flag
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- mission flag for setting dev mode
local devFlag = 8888

-- If missionflag is true, mission file will load from filesystem with an assert
local devState = trigger.misc.getUserFlag(devFlag)

if devState == 1 then
  env.warning('[JTF1] *** JTF-1 - DEV flag is ON! ***')
  MESSAGE:New("Dev Mode is ON!"):ToAll()
  DEV_MENU = {
    traceOn = true, -- default tracestate false == trace off, true == trace on.
  }
  
  function DEV_MENU:toggleTrace(traceOn)
    if traceOn then
      BASE:TraceOff()
    else
      BASE:TraceOn()
    end
    self.traceOn = not traceOn
  end

  function DEV_MENU:testLua()
    local base = _G
    local f = assert( base.loadfile( 'E:/GitHub/FUN-MAP_CAUCASUS/scripts/dynamic/test.lua' ) )
    if f == nil then
			error ("Mission Loader: could not load test.lua." )
		else
			env.info( "[JTF1] Mission Loader: test.lua dynamically loaded." )
			--return f()
		end
  end

  -- Add Dev submenu to F10 Other
  DEV_MENU.topmenu = MENU_MISSION:New("DEVMENU")
  MENU_MISSION_COMMAND:New("Toggle TRACE.", DEV_MENU.topmenu, DEV_MENU.toggleTrace, DEV_MENU, DEV_MENU.traceOn)
  MENU_MISSION_COMMAND:New("Reload Test LUA.", DEV_MENU.topmenu, DEV_MENU.testLua)
  
  -- trace all events
  BASE:TraceAll(true)

  if DEV_MENU.traceOn then
    BASE:TraceOn()
  end  

else
  env.info('[JTF1] *** JTF-1 - DEV flag is OFF. ***')
end

--- END DEVCHECK