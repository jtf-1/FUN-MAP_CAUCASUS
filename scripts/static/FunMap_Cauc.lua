env.info( '*** MISSION FILE BUILD DATE: 2023-01-24T16:50:39.22Z ***') 
env.info( "*** JTF-1 MOOSE MISSION SCRIPT START ***" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN INIT
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---- remove default MOOSE player menu
_SETTINGS:SetPlayerMenuOff()

--- debug on/off
BASE:TraceOnOff(false) 

JTF1 = {
    missionRestart = "ADMIN9999", -- Message to trigger mission restart via jtf1-hooks
    flagLoadMission = 9999, -- flag for load misison trigger
}
--- END INIT

-- ---- remove default MOOSE player menu
-- _SETTINGS:SetPlayerMenuOff()

-- --- debug on/off
-- BASE:TraceOnOff(false) 
-- if BASE:IsTrace() then
--   BASE:TraceLevel(1)
--   --BASE:TraceAll(true)
--   BASE:TraceClass("setGroupGroundActive")
-- end

-- JTF = {}
-- --- activate admin menu option in admin slots if true
-- JtfAdmin = true 

-- -- mission flag for triggering reload/loading of missions
-- flagLoadMission = 9999

-- -- value for triggering loading of base mission
-- flagBaseMissionValue = 1

-- -- value for triggering loading of dev mission
-- flagDevMissionValue = 99

-- --- Name of client unit used for admin control
-- adminUnitName = "XX_" -- string to locate within unit name for admin slots

-- --- Dynamic list of all clients
-- --JTF.SetClient = SET_CLIENT:New():FilterStart()

-- -- flag value to trigger reloading of DEV mission
-- devMission = 99

-- --- END INIT
 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Check for Static or Dynamic mission file loading flag
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- mission flag for setting dev mode
local devFlag = 8888

-- If missionflag is true, mission file will load from filesystem with an assert
local devState = trigger.misc.getUserFlag(devFlag)

if devState == 1 then
  env.warning('[JTF-1] *** JTF-1 - DEV flag is ON! ***')
  MESSAGE:New("Dev Mode is ON!"):ToAll()
  DEV_MENU = {
    traceOn = true, -- default tracestate false == trace off, true == trace on.
    flagLoadMission = (JTF1.flagLoadMission and JTF1.flagLoadMission or 9999), -- flag for load misison trigger
    missionRestartMsg = (JTF1.missionRestartMsg and JTF1.missionRestartMsg or "ADMIN9999"), -- Message to trigger mission restart via jtf1-hooks
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
                        env.info( "[JTF-1] Mission Loader: test.lua dynamically loaded." )
                        --return f()
                end
  end

  function DEV_MENU:restartMission()
    trigger.action.setUserFlag(ADMIN.flagLoadMission, 99)
  end

  -- Add Dev submenu to F10 Other
  DEV_MENU.topmenu = MENU_MISSION:New("DEVMENU")
  MENU_MISSION_COMMAND:New("Toggle TRACE.", DEV_MENU.topmenu, DEV_MENU.toggleTrace, DEV_MENU, DEV_MENU.traceOn)
  MENU_MISSION_COMMAND:New("Reload Test LUA.", DEV_MENU.topmenu, DEV_MENU.testLua)
  MENU_MISSION_COMMAND:New("Restart Mission", DEV_MENU.topmenu, DEV_MENU.restartMission)

  -- trace all events
  BASE:TraceAll(true)

  if DEV_MENU.traceOn then
    BASE:TraceOn()
  end  

else
  env.info('[JTF-1] *** JTF-1 - DEV flag is OFF. ***')
end

--- END DEVCHECK
 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Default SRS Text-to-Speech
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Send messages through SRS using STTS
-- Script will try to load the file specified with LocalServerConfigFile [name of settings file] 
-- and LocalServerConfigPath [path to file]. This file should define the path to the SRS installation 
-- directory and the port used by the DCS server instance running the mission. 
--
-- If the settings file is not found, the defaults for srs_path and srs_port will be used.
--
-- Message text will be formatted as a SOUNDTEXT object.
-- 
-- Use MISSIONSRS:SendRadio() to transmit on SRS
--
-- msgText        - [required] STRING. Text of message. Can be plain text or a MOOSE SOUNDTEXT obkect
-- msfFreqs       - [optional] STRING. frequency, or table of frequencies (without any spaces). Default freqs AND modulations will be applied if this is not specified.
-- msgModulations - [optional] STRING. modulation, or table of modulations (without any spaces) if multiple freqs passed. Ignored if msgFreqs is not defined. Default modulations will be applied if this is not specified
--


MISSIONSRS = {
  fileName = "ServerLocalSettings.lua",                           -- name of file containing local server settings
  LocalServerConfigPath = nil,                                    -- path to server srs settings. nil if file is in root of server's savedgames profile.
  LocalServerConfigFile = "LocalServerSettings.txt",              -- srs server settings file name
  defaultSrsPath = "C:/Program Files/DCS-SimpleRadio-Standalone", -- default path to SRS install directory if setting file is not avaialable "C:/Program Files/DCS-SimpleRadio-Standalone"
  defaultSrsPort = 5002,                                          -- default SRS port to use if settings file is not available
  defaultText = "No Message Defined!",                            -- default message if text is nil
  defaultFreqs = "243,251,30",                          -- transmit on guard, CTAF, NTTR TWR and NTTR BLACKJACK as default frequencies
  defaultModulations = "AM,AM,FM",                          -- default modulation (count *must* match qty of freqs)
  defaultVol = "1.0",                                             -- default to full volume
  defaultName = "Server",                                         -- default to server as sender
  defaultCoalition = 0,                                           -- default to spectators
  defaultVec3 = nil,                                              -- point from which transmission originates
  defaultSpeed = 2,                                               -- speed at which message should be played
  defaultGender = "female",                                       -- default gender of sender
  defaultCulture = "en-US",                                       -- default culture of sender
  defaultVoice = "",                                              -- default voice to use
}

function MISSIONSRS:LoadSettings()
  local loadFile  = self.LocalServerConfigFile
  if UTILS.CheckFileExists(self.LocalServerConfigPath, self.LocalServerConfigFile) then
    local loadFile, serverSettings = UTILS.LoadFromFile(self.LocalServerConfigPath, self.LocalServerConfigFile)
    BASE:T({"[MISSIONSRS] Load Server Settings",{serverSettings}})
    if not loadFile then
      BASE:E(string.format("[MISSIONSRS] ERROR: Could not load %s", loadFile))
    else
      self.SRS_DIRECTORY = serverSettings[1] or self.defaultSrsPath
      self.SRS_PORT = serverSettings[2] or self.defaultSrsPort
      self:AddRadio()
      BASE:T({"[MISSIONSRS]",{self}})
    end
  else
    BASE:E(string.format("[MISSIONSRS] ERROR: Could not find %s", loadFile))
  end
end

function MISSIONSRS:AddRadio()
  self.Radio = MSRS:New(self.SRS_DIRECTORY, self.defaultFreqs, self.defaultModulations)
  self.Radio:SetPort(self.SRS_PORT)
  self.Radio:SetGender(self.defaultGender)
  self.Radio:SetCulture(self.defaultCulture)
  self.Radio.name = self.defaultName
end

function MISSIONSRS:SendRadio(msgText, msgFreqs, msgModulations)

  BASE:T({"[MISSIONSRS] SendRadio", {msgText}, {msgFreqs}, {msgModulations}})
  if msgFreqs then
    BASE:T("[MISSIONSRS] tx with freqs change.")
    if msgModulations then
      BASE:T("[MISSIONSRS] tx with mods change.")
    end
  end
  if msgText == (nil or "") then 
    msgText = self.defaultText
  end
  local text = msgText
  local tempFreqs = (msgFreqs or self.defaultFreqs)
  local tempModulations = (msgModulations or self.defaultModulations)
  if not msgText.ClassName then
    BASE:T("[MISSIONSRS] msgText NOT SoundText object.")
    text = SOUNDTEXT:New(msgText) -- convert msgText to SOundText object
  end
  self.Radio:SetFrequencies(tempFreqs)
  self.Radio:SetModulations(tempModulations)
  self.Radio:PlaySoundText(text)
  self.Radio:SetFrequencies(self.defaultFreqs) -- reset freqs to default
  self.Radio:SetModulations(self.defaultModulations) -- rest modulation to default

end


MISSIONSRS:LoadSettings()

 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN ADMIN MENU SECTION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Admin menu
--
-- Add F10 command menus for selecting a mission to load, or restarting the current mission.
--
-- In the Mission Editor, add (a) switched condition trigger(s) with a 
-- FLAG EQUALS condition, where flag number is ADMIN.flagLoadMission value
-- and flag value is the ADMIN.missionList[x].missionFlagValue (see below).
-- A missionFlagValue == 0 is used to trigger restart of the current
-- mission using jtf1-hooks.lua.
--
-- If the menu should only appear for restricted client slots, set
-- ADMIN.menuAllSlots to FALSE and add a client slot with the group name
-- *prefixed* with the value set in ADMIN.adminMenuName.
--
-- If the menu should be available in all mission slots, set ADMIN.menuAllSlots
-- to TRUE.
--
-- 

ADMIN = EVENTHANDLER:New()
ADMIN:HandleEvent(EVENTS.PlayerEnterAircraft)

ADMIN.adminUnitName = "XX_" -- String to locate within unit name for admin slots
ADMIN.missionRestart = (JTF1.missionRestart and JTF1.missionRestart or "ADMIN9999") -- Message to trigger mission restart via jtf1-hooks
ADMIN.flagLoadMission = 9999
ADMIN.menuAllSlots = false -- Set to true for admin menu to appear for all players

ADMIN.missionList = { -- List of missions for load mission menu commands
  {menuText = "Restart current mission", missionFlagValue = 0},
  {menuText = "Load DAY", missionFlagValue = 1},
  {menuText = "Load NIGHT", missionFlagValue = 2},
  {menuText = "Load WEATHER", missionFlagValue = 3},
  {menuText = "Load NIGHT WEATHER", missionFlagValue = 4},
}

function ADMIN:GetPlayerUnitAndName(unitName)
  if unitName ~= nil then
    -- Get DCS unit from its name.
    local DCSunit = Unit.getByName(unitName)
    if DCSunit then
      local playername=DCSunit:getPlayerName()
      local unit = UNIT:Find(DCSunit)
      if DCSunit and unit and playername then
        return unit, playername
      end
    end
  end
  -- Return nil if we could not find a player.
  return nil,nil
end

function ADMIN:OnEventPlayerEnterAircraft(EventData)
  if not ADMIN.menuAllSlots then
    local unitName = EventData.IniUnitName
    local unit, playername = ADMIN:GetPlayerUnitAndName(unitName)
    if unit and playername then
      local adminCheck = (string.find(unitName, ADMIN.adminUnitName) and "true" or "false")
      if string.find(unitName, ADMIN.adminUnitName) then
        SCHEDULER:New(nil, ADMIN.BuildAdminMenu, {self, unit, playername}, 0.5)
      end
    end
  end
end

--- Set mission flag to load a new mission.
--- If mapFlagValue is current mission, restart the mission via jtf1-hooks
-- @param #string playerName Name of client calling restart command.
-- @param #number mapFlagValue Mission number to which flag should be set.
function ADMIN:LoadMission(playerName, mapFlagValue)
  if playerName then
    env.info("[JTF-1] ADMIN Restart player name: " .. playerName)
  end
  if mapFlagValue == 0 then -- use jtf1-hooks to restart current mission
    MESSAGE:New(ADMIN.missionRestart):ToAll()
  else
    trigger.action.setUserFlag(ADMIN.flagLoadMission, mapFlagValue)
  end
end

--- Add admin menu and commands if client is in an ADMIN spawn
-- @param #object unit Unit of player.
-- @param #string playername Name of player
function ADMIN:BuildAdminMenu(unit,playername)
  if not (unit or playername) then
    -- create menu at Mission level
    local adminMenu = MENU_MISSION:New("Admin")
    for i, menuCommand in ipairs(ADMIN.missionList) do
      MENU_MISSION_COMMAND:New( menuCommand.menuText, adminMenu, ADMIN.LoadMission, self, playername, menuCommand.missionFlagValue )
    end
  else
    -- Create menu for admin slot
    local adminGroup = unit:GetGroup()
    local adminMenu = MENU_GROUP:New(adminGroup, "Admin")
    local testMenu = MENU_GROUP:New(adminGroup, "Test", adminMenu)
    for i, menuCommand in ipairs(ADMIN.missionList) do
      MENU_GROUP_COMMAND:New( adminGroup, menuCommand.menuText, adminMenu, ADMIN.LoadMission, self, playername, menuCommand.missionFlagValue )
      MENU_GROUP_COMMAND:New( adminGroup, "SRS Broadcast test", testMenu, MISSIONSRS.SendRadio, MISSIONSRS, "All Players, test broadcast over default radio.")
    end
  end
end

if ADMIN.menuAllSlots then
  ADMIN:BuildAdminMenu()
end

--- END ADMIN MENU SECTION
 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN MISSION TIMER
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Mission Timer
--
-- Add schedules to display messages at set intervals prior to restarting the base mission.
-- ME switched triggers should be set to a FLAG EQUALS condition for the flag flagLoadMission
-- value (defined in script header). Sending missionRestart text will trigger restarting the
-- current mission via jtf1-hooks.lua.
--

MISSIONTIMER = {
  durationHrs = 9, -- Mission run time in HOURS
  msgSchedule = {60, 30, 10, 5}, -- Schedule for mission restart warning messages. Time in minutes.
  msgWarning = {}, -- schedule container
  missionRestart = ( JTF1.missionRestart and JTF1.missionRestart or "ADMIN9999" ), -- Message to trigger mission restart via jtf1-hooks
  restartDelay =  4, -- time in minutes to delay restart if active clients are present.
}

MISSIONTIMER.durationSecs = MISSIONTIMER.durationHrs * 3600 -- Mission run time in seconds

BASE:T({"[MISSIONTIMER]",{MISSIONTIMER}})

--- add scheduled messages for mission restart warnings and restart at end of mission duration
function MISSIONTIMER:AddSchedules()
  if self.msgSchedule ~= nil then
    for i, msgTime in ipairs(self.msgSchedule) do
      self.msgWarning[i] = SCHEDULER:New( nil, 
        function()
          BASE:T("[MISSIONTIMER] TIMER WARNING CALLED at " .. tostring(msgTime) .. " minutes remaining.")
          local msg = "All Players, mission is scheduled to restart in  " .. msgTime .. " minutes!"
          if MISSIONSRS.Radio then -- if MISSIONSRS radio object has been created, send message via default broadcast.
            MISSIONSRS:SendRadio(msg)
          else -- otherwise, send in-game text message
            MESSAGE:New(msg):ToAll()
          end
        end,
      {msgTime}, self.durationSecs - (msgTime * 60))
    end
  end
  self.msgWarning["restart"] = SCHEDULER:New( nil,
    function()
      MISSIONTIMER:Restart()
    end,
    { }, self.durationSecs)
end

function MISSIONTIMER:Restart()
  if not self.clientList then
    self.clientList = SET_CLIENT:New()
    self.clientList:FilterActive()
    self.clientList:FilterStart()
  end
  if self.clientList:CountAlive() > 0 then
    local delayTime = self.restartDelay
    local msg  = "All Players, mission will restart when no active clients are present. Next check will be in " .. tostring(delayTime) .." minutes." 
    if MISSIONSRS.Radio then -- if MISSIONSRS radio object has been created, send message via default broadcast.
      MISSIONSRS:SendRadio(msg)
    else -- otherwise, send in-game text message
      MESSAGE:New(msg):ToAll()
    end
    self.msgWarning["restart"] = SCHEDULER:New( nil,
      function()
        MISSIONTIMER:Restart()
      end,
      { }, (self.restartDelay * 60))
  else
    BASE:T("[MISSIONTIMER] RESTART MISSION")
    MESSAGE:New(self.missionRestart):ToAll()
  end
end

MISSIONTIMER:AddSchedules()

--- END MISSION TIMER
 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN MISSILE TRAINER
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create event handler
MissileTrainer = EVENTHANDLER:New()
MissileTrainer:HandleEvent(EVENTS.PlayerEnterAircraft)   --(EVENTS.Birth)
MissileTrainer:HandleEvent(EVENTS.PlayerLeaveUnit)  -- (EVENTS.Dead)


-- Create MissileTrainer container and defaults
MissileTrainer.menuadded = {}
MissileTrainer.MenuF10   = {}
MissileTrainer.safeZone = "ZONE_FOX"
MissileTrainer.launchZone = "ZONE_FOX"


function MissileTrainer:GetPlayerUnitAndName(unitName)
  if unitName ~= nil then
    -- Get DCS unit from its name.
    local DCSunit = Unit.getByName(unitName)
    if DCSunit then
      local playername=DCSunit:getPlayerName()
      local unit = UNIT:Find(DCSunit)
      if DCSunit and unit and playername then
        return unit, playername
      end
    end
  end
  -- Return nil if we could not find a player.
  return nil,nil
end

MissileTrainer.fox = FOX:New() -- add new FOX class to the Missile Trainer

--- FOX Default Settings
MissileTrainer.fox:SetDefaultLaunchAlerts(false) -- launcher alerts OFF
  :SetDefaultMissileDestruction(false) -- missile destruction off
  :SetDefaultLaunchMarks(false) -- launch map marks OFF
  :SetExplosionDistance(300) -- distance from uit at which to destroy incoming missiles
  :SetDebugOnOff() -- set debug on if true
  :SetDisableF10Menu() -- remove default F10 menu as a custom menu will be used
  -- :AddSafeZone(ZONE:New(MissileTrainer.safeZone)) -- zone in which players will be protected
  -- :AddLaunchZone(ZONE:New(MissileTrainer.launchZone)) -- zone in which launches will be tracked
  :Start() -- start the missile trainer

--- Toggle Launch Alerts and Destroy Missiles on/off
-- @param #MissileTrainer self
-- @param #string unitName name of client unit
function MissileTrainer:ToggleMissileTrainer(unitName)
  self.fox:_ToggleLaunchAlert(unitName)
  self.fox:_ToggleDestroyMissiles(unitName)
end

--- Add Missile Trainer F10 root menu.
-- @param #MissileTrainer self
-- @param #wrapper.Unit unit Unit object occupied by client
-- @param #string unitName Name of unit occupied by client
function MissileTrainer:AddMenu(unit, unitName, state)
  local group = unit:GetGroup()
  local gid = group:GetID()

  if state then
    if not self.MenuF10[gid] then
      self.MenuF10[gid] = missionCommands.addSubMenuForGroup(gid, "Missile Trainer")
      local rootPath = self.MenuF10[gid]
      missionCommands.addCommandForGroup(gid, "Missile Trainer On/Off", rootPath, self.ToggleMissileTrainer, MissileTrainer, unitName)
    end
  else
    self.MenuF10[gid]:Remove()
    self.MenuF10[gid] = nil
  end
end

function MissileTrainer:OnEventPlayerEnterAircraft(EventData)
  local unitName = EventData.IniUnitName
  local unit, playername = MissileTrainer:GetPlayerUnitAndName(unitName)
  
  if unit and playername then
    SCHEDULER:New(nil, MissileTrainer.AddMenu, {MissileTrainer, unit, unitName, true},0.1)
  end
end

function MissileTrainer:OnEventPlayerLeaveUnit(EventData)
  local unitName = EventData.IniUnitName
  local unit, playername = MissileTrainer:GetPlayerUnitAndName(unitname)

  if unit and playername then
    MissileTrainer:AddMenu(unit, unitname, false)
  end
end

--- END MISSILE TRAINER
 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN HERCULES CARGO SUPPORT SECTION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Hercules Cargo Drop Events by Anubis Yinepu

-- This script will only work for the Herculus mod by Anubis
-- Payloads carried by pylons 11, 12 and 13 need to be declared in the Herculus_Loadout.lua file
-- Except for Ammo pallets, this script will spawn whatever payload gets launched from pylons 11, 12 and 13
-- Pylons 11, 12 and 13 are moveable within the Herculus cargobay area
-- Ammo pallets can only be jettisoned from these pylons with no benefit to DCS world
-- To benefit DCS world, Ammo pallets need to be off/on loaded using DCS arming and refueling window
-- Cargo_Container_Enclosed = true: Cargo enclosed in container with parachute, need to be dropped from 100m (300ft) or more, except when parked on ground
-- Cargo_Container_Enclosed = false: Open cargo with no parachute, need to be dropped from 10m (30ft) or less

Hercules_Cargo = {}
Hercules_Cargo.Hercules_Cargo_Drop_Events = {}
local GT_DisplayName = ""
local GT_Name = ""
local Cargo_Drop_initiator = ""
local Cargo_Container_Enclosed = false
local SoldierGroup = false
local ParatrooperCount = 1
local ParatrooperGroupSpawnInit = false
local ParatrooperGroupSpawn = false

local Herc_j = 0
local Herc_Cargo = {}
Herc_Cargo.Cargo_Drop_Direction = 0
Herc_Cargo.Cargo_Contents = ""
Herc_Cargo.Cargo_Type_name = ""
Herc_Cargo.Cargo_over_water = false
Herc_Cargo.Container_Enclosed = false
Herc_Cargo.offload_cargo = false
Herc_Cargo.all_cargo_survive_to_the_ground = false
Herc_Cargo.all_cargo_gets_destroyed = false
Herc_Cargo.destroy_cargo_dropped_without_parachute = false
Herc_Cargo.scheduleFunctionID = 0

local CargoHeading = 0
local Cargo_Drop_Position = {}

local SoldierUnitID = 12000
local SoldierGroupID = 12000
local GroupSpacing = 0
--added by wrench
Hercules_Cargo.types = {
        ["ATGM M1045 HMMWV TOW Air [7183lb]"] = {['name'] = "M1045 HMMWV TOW", ['container'] = true},
        ["ATGM M1045 HMMWV TOW Skid [7073lb]"] = {['name'] = "M1045 HMMWV TOW", ['container'] = false},
        ["APC M1043 HMMWV Armament Air [7023lb]"] = {['name'] = "M1043 HMMWV Armament", ['container'] = true},
        ["APC M1043 HMMWV Armament Skid [6912lb]"] = {['name'] = "M1043 HMMWV Armament", ['container'] = false},
        ["SAM Avenger M1097 Air [7200lb]"] = {['name'] = "M1097 Avenger", ['container'] = true},
        ["SAM Avenger M1097 Skid [7090lb]"] = {['name'] = "M1097 Avenger", ['container'] = false},
        ["APC Cobra Air [10912lb]"] = {['name'] = "Cobra", ['container'] = true},
        ["APC Cobra Skid [10802lb]"] = {['name'] = "Cobra", ['container'] = false},
        ["APC M113 Air [21624lb]"] = {['name'] = "M-113", ['container'] = true},
        ["APC M113 Skid [21494lb]"] = {['name'] = "M-113", ['container'] = false},
        ["Tanker M978 HEMTT [34000lb]"] = {['name'] = "M978 HEMTT Tanker", ['container'] = false},
        ["HEMTT TFFT [34400lb]"] = {['name'] = "HEMTT TFFT", ['container'] = false},
        ["SPG M1128 Stryker MGS [33036lb]"] = {['name'] = "M1128 Stryker MGS", ['container'] = false},
        ["AAA Vulcan M163 Air [21666lb]"] = {['name'] = "Vulcan", ['container'] = true},
        ["AAA Vulcan M163 Skid [21577lb]"] = {['name'] = "Vulcan", ['container'] = false},
        ["APC M1126 Stryker ICV [29542lb]"] = {['name'] = "M1126 Stryker ICV", ['container'] = false},
        ["ATGM M1134 Stryker [30337lb]"] = {['name'] = "M1134 Stryker ATGM", ['container'] = false},
        ["APC LAV-25 Air [22520lb]"] = {['name'] = "LAV-25", ['container'] = true},
        ["APC LAV-25 Skid [22514lb]"] = {['name'] = "LAV-25", ['container'] = false},
        ["M1025 HMMWV Air [6160lb]"] = {['name'] = "Hummer", ['container'] = true},
        ["M1025 HMMWV Skid [6050lb]"] = {['name'] = "Hummer", ['container'] = false},
        ["IFV M2A2 Bradley [34720lb]"] = {['name'] = "M-2 Bradley", ['container'] = false},
        ["IFV MCV-80 [34720lb]"] = {['name'] = "MCV-80", ['container'] = false},
        ["IFV BMP-1 [23232lb]"] = {['name'] = "BMP-1", ['container'] = false},
        ["IFV BMP-2 [25168lb]"] = {['name'] = "BMP-2", ['container'] = false},
        ["IFV BMP-3 [32912lb]"] = {['name'] = "BMP-3", ['container'] = false},
        ["ARV BRDM-2 Air [12320lb]"] = {['name'] = "BRDM-2", ['container'] = true},
        ["ARV BRDM-2 Skid [12210lb]"] = {['name'] = "BRDM-2", ['container'] = false},
        ["APC BTR-80 Air [23936lb]"] = {['name'] = "BTR-80", ['container'] = true},
        ["APC BTR-80 Skid [23826lb]"] = {['name'] = "BTR-80", ['container'] = false},
        ["APC BTR-82A Air [24998lb]"] = {['name'] = "BTR-82A", ['container'] = true},
        ["APC BTR-82A Skid [24888lb]"] = {['name'] = "BTR-82A", ['container'] = false},
        ["SAM ROLAND ADS [34720lb]"] = {['name'] = "Roland Radar", ['container'] = false},
        ["SAM ROLAND LN [34720b]"] = {['name'] = "Roland ADS", ['container'] = false},
        ["SAM SA-13 STRELA [21624lb]"] = {['name'] = "Strela-10M3", ['container'] = false},
        ["AAA ZSU-23-4 Shilka [32912lb]"] = {['name'] = "ZSU-23-4 Shilka", ['container'] = false},
        ["SAM SA-19 Tunguska 2S6 [34720lb]"] = {['name'] = "2S6 Tunguska", ['container'] = false},
        ["Transport UAZ-469 Air [3747lb]"] = {['name'] = "UAZ-469", ['container'] = true},
        ["Transport UAZ-469 Skid [3630lb]"] = {['name'] = "UAZ-469", ['container'] = false},
        ["AAA GEPARD [34720lb]"] = {['name'] = "Gepard", ['container'] = false},
        ["SAM CHAPARRAL Air [21624lb]"] = {['name'] = "M48 Chaparral", ['container'] = true},
        ["SAM CHAPARRAL Skid [21516lb]"] = {['name'] = "M48 Chaparral", ['container'] = false},
        ["SAM LINEBACKER [34720lb]"] = {['name'] = "M6 Linebacker", ['container'] = false},
        ["Transport URAL-375 [14815lb]"] = {['name'] = "Ural-375", ['container'] = false},
        ["Transport M818 [16000lb]"] = {['name'] = "M 818", ['container'] = false},
        ["IFV MARDER [34720lb]"] = {['name'] = "Marder", ['container'] = false},
        ["Transport Tigr Air [15900lb]"] = {['name'] = "Tigr_233036", ['container'] = true},
        ["Transport Tigr Skid [15730lb]"] = {['name'] = "Tigr_233036", ['container'] = false},
        ["IFV TPZ FUCH [33440lb]"] = {['name'] = "TPZ", ['container'] = false},
        ["IFV BMD-1 Air [18040lb]"] = {['name'] = "BMD-1", ['container'] = true},
        ["IFV BMD-1 Skid [17930lb]"] = {['name'] = "BMD-1", ['container'] = false},
        ["IFV BTR-D Air [18040lb]"] = {['name'] = "BTR_D", ['container'] = true},
        ["IFV BTR-D Skid [17930lb]"] = {['name'] = "BTR_D", ['container'] = false},
        ["EWR SBORKA Air [21624lb]"] = {['name'] = "Dog Ear radar", ['container'] = true},
        ["EWR SBORKA Skid [21624lb]"] = {['name'] = "Dog Ear radar", ['container'] = false},
        ["ART 2S9 NONA Air [19140lb]"] = {['name'] = "SAU 2-C9", ['container'] = true},
        ["ART 2S9 NONA Skid [19030lb]"] = {['name'] = "SAU 2-C9", ['container'] = false},
        ["ART GVOZDIKA [34720lb]"] = {['name'] = "SAU Gvozdika", ['container'] = false},
        ["APC MTLB Air [26400lb]"] = {['name'] = "MTLB", ['container'] = true},
        ["APC MTLB Skid [26290lb]"] = {['name'] = "MTLB", ['container'] = false},
        --["Generic Crate [20000lb]"] = {['name'] =  "Hercules_Container_Parachute", ['container'] = true}
}
function Hercules_Cargo.Soldier_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country, GroupSpacing)
        SoldierUnitID = SoldierUnitID + 30
        SoldierGroupID = SoldierGroupID + 1
        local Herc_Soldier_Spawn = 
        {
                ["visible"] = false,
                ["tasks"] = 
                {
                }, -- end of ["tasks"]
                ["uncontrollable"] = false,
                ["task"] = "Ground Nothing",
                ["taskSelected"] = true,
                ["groupId"] = SoldierGroupID,
                ["hidden"] = false,
                ["units"] = 
                {
                        [1] = 
                        {
                                ["type"] = Cargo_Type_name,
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 0.5 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 0.5 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [1]
                        [2] = 
                        {
                                ["type"] = Cargo_Type_name,
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 1.0 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 1.0 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [2]
                        [3] = 
                        {
                                ["type"] = Cargo_Type_name,
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 1.5 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 1.0 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [3]
                        [4] = 
                        {
                                ["type"] = Cargo_Type_name,
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 2.0 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 2.0 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [4]
                        [5] = 
                        {
                                ["type"] = Cargo_Type_name,
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 2.5 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 2.5 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [5]
                        [6] = 
                        {
                                ["type"] = Cargo_Type_name,
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 3.0 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 3.0 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [6]
                        [7] = 
                        {
                                ["type"] = "Soldier M249",
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 3.5 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 3.5 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [7]
                        [8] = 
                        {
                                ["type"] = "Soldier M249",
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 4.0 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 4.0 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [8]
                        [9] = 
                        {
                                ["type"] = Cargo_Type_name,
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 4.5 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 4.5 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [9]
                        [10] = 
                        {
                                ["type"] = "Paratrooper RPG-16",
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = true,
                                }, -- end of ["transportable"]
                                ["unitId"] = SoldierUnitID + 1,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z + 5.0 + GroupSpacing,
                                ["x"] = Cargo_Drop_Position.x + 5.0 + GroupSpacing,
                                ["name"] = "Soldier Unit "..SoldierUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = false,
                        }, -- end of [10]
                }, -- end of ["units"]
                ["y"] = Cargo_Drop_Position.z,
                ["x"] = Cargo_Drop_Position.x,
                ["name"] = "Soldier_Group_"..SoldierGroupID,
                ["start_time"] = 0,
        }
        coalition.addGroup(Cargo_Country, Group.Category.GROUND, Herc_Soldier_Spawn)
end

local CargoUnitID = 10000
local CargoGroupID = 10000
local CargoStaticGroupID = 11000

function Hercules_Cargo.Cargo_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country)
        CargoUnitID = CargoUnitID + 1
        CargoGroupID = CargoGroupID + 1
        local Herc_Cargo_Spawn = 
        {
                ["visible"] = false,
                ["tasks"] = 
                {
                }, -- end of ["tasks"]
                ["uncontrollable"] = false,
                ["task"] = "Ground Nothing",
                ["groupId"] = CargoGroupID,
                ["hidden"] = false,
                ["units"] = 
                {
                        [1] = 
                        {
                                ["type"] = Cargo_Type_name,
                                ["transportable"] = 
                                {
                                        ["randomTransportable"] = false,
                                }, -- end of ["transportable"]
                                ["unitId"] = CargoUnitID,
                                ["skill"] = "Excellent",
                                ["y"] = Cargo_Drop_Position.z,
                                ["x"] = Cargo_Drop_Position.x,
                                ["name"] = "Cargo Unit "..CargoUnitID,
                                ["heading"] = CargoHeading,
                                ["playerCanDrive"] = true,
                        }, -- end of [1]
                }, -- end of ["units"]
                ["y"] = Cargo_Drop_Position.z,
                ["x"] = Cargo_Drop_Position.x,
                ["name"] = "Cargo Group "..CargoUnitID,
                ["start_time"] = 0,
        }
        coalition.addGroup(Cargo_Country, Group.Category.GROUND, Herc_Cargo_Spawn)
end

function Hercules_Cargo.Cargo_SpawnStatic(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, dead, Cargo_Country)
        CargoStaticGroupID = CargoStaticGroupID + 1
        local Herc_CargoObject_Spawn = 
        {
                ["type"] = Cargo_Type_name,
                ["y"] = Cargo_Drop_Position.z,
                ["x"] = Cargo_Drop_Position.x,
                ["name"] = "Cargo Static Group "..CargoStaticGroupID,
                ["heading"] = CargoHeading,
                ["dead"] = dead,
        }
        coalition.addStaticObject(Cargo_Country, Herc_CargoObject_Spawn)
end

function Hercules_Cargo.Cargo_SpawnObjects(Cargo_Drop_Direction, Cargo_Content_position, Cargo_Type_name, Cargo_over_water, Container_Enclosed, ParatrooperGroupSpawn, offload_cargo, all_cargo_survive_to_the_ground, all_cargo_gets_destroyed, destroy_cargo_dropped_without_parachute, Cargo_Country)
        if offload_cargo == true then
                ------------------------------------------------------------------------------
                if CargoHeading >= 3.14 then
                        CargoHeading = 0
                        Cargo_Drop_Position = {["x"] = Cargo_Content_position.x - (30.0 * math.cos(Cargo_Drop_Direction - 1.0)),
                                                                   ["z"] = Cargo_Content_position.z - (30.0 * math.sin(Cargo_Drop_Direction - 1.0))}
                else
                        if CargoHeading >= 1.57 then
                                CargoHeading = 3.14
                                Cargo_Drop_Position = {["x"] = Cargo_Content_position.x - (20.0 * math.cos(Cargo_Drop_Direction + 0.5)),
                                                                           ["z"] = Cargo_Content_position.z - (20.0 * math.sin(Cargo_Drop_Direction + 0.5))}
                        else
                                if CargoHeading >= 0 then
                                        CargoHeading = 1.57
                                        Cargo_Drop_Position = {["x"] = Cargo_Content_position.x - (10.0 * math.cos(Cargo_Drop_Direction + 1.5)),
                                                                                   ["z"] = Cargo_Content_position.z - (10.0 * math.sin(Cargo_Drop_Direction + 1.5))}
                                end
                        end
                end
                ------------------------------------------------------------------------------
                if ParatrooperGroupSpawn == true then
                        Hercules_Cargo.Soldier_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country, 0)
                        Hercules_Cargo.Soldier_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country, 5)
                        Hercules_Cargo.Soldier_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country, 10)
                else
                        Hercules_Cargo.Cargo_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country, 0)
                end
        else
                ------------------------------------------------------------------------------
                CargoHeading = 0
                Cargo_Drop_Position = {["x"] = Cargo_Content_position.x - (20.0 * math.cos(Cargo_Drop_Direction)),
                                                           ["z"] = Cargo_Content_position.z - (20.0 * math.cos(Cargo_Drop_Direction))}
                ------------------------------------------------------------------------------
                if all_cargo_gets_destroyed == true or Cargo_over_water == true then
                        if Container_Enclosed == true then
                                Hercules_Cargo.Cargo_SpawnStatic(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, true, Cargo_Country)
                                if ParatrooperGroupSpawn == false then
                                        Hercules_Cargo.Cargo_SpawnStatic(Cargo_Drop_Position, "Hercules_Container_Parachute_Static", CargoHeading, true, Cargo_Country)
                                end
                        else
                                Hercules_Cargo.Cargo_SpawnStatic(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, true, Cargo_Country)
                        end
                else
                        ------------------------------------------------------------------------------
                        if all_cargo_survive_to_the_ground == true then
                                if ParatrooperGroupSpawn == true then
                                        Hercules_Cargo.Cargo_SpawnStatic(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, true, Cargo_Country)
                                else
                                        Hercules_Cargo.Cargo_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country)
                                end
                                if Container_Enclosed == true then
                                        if ParatrooperGroupSpawn == false then
                                                Hercules_Cargo.Cargo_SpawnStatic({["z"] = Cargo_Drop_Position.z + 10.0,["x"] = Cargo_Drop_Position.x + 10.0}, "Hercules_Container_Parachute_Static", CargoHeading, false, Cargo_Country)
                                        end
                                end
                        end
                        ------------------------------------------------------------------------------
                        if destroy_cargo_dropped_without_parachute == true then
                                if Container_Enclosed == true then
                                        if ParatrooperGroupSpawn == true then
                                                Hercules_Cargo.Soldier_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country, 0)
                                        else
                                                Hercules_Cargo.Cargo_SpawnGroup(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, Cargo_Country)
                                                Hercules_Cargo.Cargo_SpawnStatic({["z"] = Cargo_Drop_Position.z + 10.0,["x"] = Cargo_Drop_Position.x + 10.0}, "Hercules_Container_Parachute_Static", CargoHeading, false, Cargo_Country)
                                        end
                                else
                                        Hercules_Cargo.Cargo_SpawnStatic(Cargo_Drop_Position, Cargo_Type_name, CargoHeading, true, Cargo_Country)
                                end
                        end
                        ------------------------------------------------------------------------------
                end
        end
end

function Hercules_Cargo.Calculate_Object_Height_AGL(object)
        return object:getPosition().p.y - land.getHeight({x = object:getPosition().p.x, y = object:getPosition().p.z})
end

function Hercules_Cargo.Check_SurfaceType(object)
   -- LAND,--1 SHALLOW_WATER,--2 WATER,--3 ROAD,--4 RUNWAY--5
        return land.getSurfaceType({x = object:getPosition().p.x, y = object:getPosition().p.z})
end

function Hercules_Cargo.Cargo_Track(Arg, time)
        local status, result = pcall(
                function()
                local next = next
                if next(Arg[1].Cargo_Contents) ~= nil then
                        if Hercules_Cargo.Calculate_Object_Height_AGL(Arg[1].Cargo_Contents) < 5.0 then--pallet less than 5m above ground before spawning
                                if Hercules_Cargo.Check_SurfaceType(Arg[1].Cargo_Contents) == 2 or Hercules_Cargo.Check_SurfaceType(Arg[1].Cargo_Contents) == 3 then
                                        Arg[1].Cargo_over_water = true--pallets gets destroyed in water
                                end
                                Arg[1].Cargo_Contents:destroy()--remove pallet+parachute before hitting ground and replace with Cargo_SpawnContents
                                Hercules_Cargo.Cargo_SpawnObjects(Arg[1].Cargo_Drop_Direction, Object.getPoint(Arg[1].Cargo_Contents), Arg[1].Cargo_Type_name, Arg[1].Cargo_over_water, Arg[1].Container_Enclosed, Arg[1].ParatrooperGroupSpawn, Arg[1].offload_cargo, Arg[1].all_cargo_survive_to_the_ground, Arg[1].all_cargo_gets_destroyed, Arg[1].destroy_cargo_dropped_without_parachute, Arg[1].Cargo_Country)
                                timer.removeFunction(Arg[1].scheduleFunctionID)
                                Arg[1] = {}
                        end
                        return time + 0.1
                end
        end) -- pcall
        if not status then
                -- env.error(string.format("Cargo_Spawn: %s", result))
        else
                return result
        end
end

function Hercules_Cargo.Calculate_Cargo_Drop_initiator_NorthCorrection(point)   --correction needed for true north
        if not point.z then --Vec2; convert to Vec3
                point.z = point.y
                point.y = 0
        end
        local lat, lon = coord.LOtoLL(point)
        local north_posit = coord.LLtoLO(lat + 1, lon)
        return math.atan2(north_posit.z - point.z, north_posit.x - point.x)
end

function Hercules_Cargo.Calculate_Cargo_Drop_initiator_Heading(Cargo_Drop_initiator)
        local Heading = math.atan2(Cargo_Drop_initiator:getPosition().x.z, Cargo_Drop_initiator:getPosition().x.x)
        Heading = Heading + Hercules_Cargo.Calculate_Cargo_Drop_initiator_NorthCorrection(Cargo_Drop_initiator:getPosition().p)
        if Heading < 0 then
                Heading = Heading + (2 * math.pi)-- put heading in range of 0 to 2*pi
        end
        return Heading + 0.06 -- rad
end

function Hercules_Cargo.Cargo_Initialize(initiator, Cargo_Contents, Cargo_Type_name, Container_Enclosed)
        local status, result = pcall(
                function()
                Cargo_Drop_initiator = Unit.getByName(initiator:getName())
                local next = next
                if next(Cargo_Drop_initiator) ~= nil then
                        if ParatrooperGroupSpawnInit == true then
                                if (ParatrooperCount == 1 or ParatrooperCount == 2 or ParatrooperCount == 3) then
                                        Herc_j = Herc_j + 1
                                        Herc_Cargo[Herc_j] = {}
                                        Herc_Cargo[Herc_j].Cargo_Drop_Direction = Hercules_Cargo.Calculate_Cargo_Drop_initiator_Heading(Cargo_Drop_initiator)
                                        Herc_Cargo[Herc_j].Cargo_Contents = Cargo_Contents
                                        Herc_Cargo[Herc_j].Cargo_Type_name = Cargo_Type_name
                                        Herc_Cargo[Herc_j].Container_Enclosed = Container_Enclosed
                                        Herc_Cargo[Herc_j].ParatrooperGroupSpawn = ParatrooperGroupSpawnInit
                                        Herc_Cargo[Herc_j].Cargo_Country = initiator:getCountry()
                                ------------------------------------------------------------------------------
                                        if Hercules_Cargo.Calculate_Object_Height_AGL(Cargo_Drop_initiator) < 5.0 then--aircraft on ground
                                                Herc_Cargo[Herc_j].offload_cargo = true
                                                ParatrooperCount = 0
                                                ParatrooperGroupSpawnInit = false
                                        else
                                ------------------------------------------------------------------------------
                                                if Hercules_Cargo.Calculate_Object_Height_AGL(Cargo_Drop_initiator) < 10.0 then--aircraft less than 10m above ground
                                                        Herc_Cargo[Herc_j].all_cargo_survive_to_the_ground = true
                                                else
                                ------------------------------------------------------------------------------
                                                        if Hercules_Cargo.Calculate_Object_Height_AGL(Cargo_Drop_initiator) < 152.4 then--aircraft more than 30ft but less than 500ft above ground
                                                                Herc_Cargo[Herc_j].all_cargo_gets_destroyed = true
                                                        else
                                ------------------------------------------------------------------------------
                                                                Herc_Cargo[Herc_j].destroy_cargo_dropped_without_parachute = true--aircraft more than 152.4m (500ft)above ground
                                                        end
                                                end
                                        end
                                ------------------------------------------------------------------------------
                                        Herc_Cargo[Herc_j].scheduleFunctionID = timer.scheduleFunction(Hercules_Cargo.Cargo_Track, {Herc_Cargo[Herc_j]}, timer.getTime() + 0.1)
                                        ParatrooperCount = ParatrooperCount + 1.0
                                else
                                        if (ParatrooperCount == 30) then
                                                ParatrooperGroupSpawnInit = false
                                                ParatrooperCount = 1
                                        else
                                                ParatrooperCount = ParatrooperCount + 1.0
                                        end
                                end
                        else
                                Herc_j = Herc_j + 1
                                Herc_Cargo[Herc_j] = {}
                                Herc_Cargo[Herc_j].Cargo_Drop_Direction = Hercules_Cargo.Calculate_Cargo_Drop_initiator_Heading(Cargo_Drop_initiator)
                                Herc_Cargo[Herc_j].Cargo_Contents = Cargo_Contents
                                Herc_Cargo[Herc_j].Cargo_Type_name = Cargo_Type_name
                                Herc_Cargo[Herc_j].Container_Enclosed = Container_Enclosed
                                Herc_Cargo[Herc_j].ParatrooperGroupSpawn = ParatrooperGroupSpawnInit
                                Herc_Cargo[Herc_j].Cargo_Country = initiator:getCountry()
                        ------------------------------------------------------------------------------
                                if Hercules_Cargo.Calculate_Object_Height_AGL(Cargo_Drop_initiator) < 5.0 then--aircraft on ground
                                        Herc_Cargo[Herc_j].offload_cargo = true
                                else
                        ------------------------------------------------------------------------------
                                        if Hercules_Cargo.Calculate_Object_Height_AGL(Cargo_Drop_initiator) < 10.0 then--aircraft less than 10m above ground
                                                Herc_Cargo[Herc_j].all_cargo_survive_to_the_ground = true
                                        else
                        ------------------------------------------------------------------------------
                                                if Hercules_Cargo.Calculate_Object_Height_AGL(Cargo_Drop_initiator) < 100.0 then--aircraft more than 10m but less than 100m above ground
                                                        Herc_Cargo[Herc_j].all_cargo_gets_destroyed = true
                                                else
                        ------------------------------------------------------------------------------
                                                        Herc_Cargo[Herc_j].destroy_cargo_dropped_without_parachute = true--aircraft more than 100m above ground
                                                end
                                        end
                                end
                        ------------------------------------------------------------------------------
                                Herc_Cargo[Herc_j].scheduleFunctionID = timer.scheduleFunction(Hercules_Cargo.Cargo_Track, {Herc_Cargo[Herc_j]}, timer.getTime() + 0.1)
                        end
                end
        end) -- pcall
        if not status then
                -- env.error(string.format("Cargo_Initialize: %s", result))
        else
                return result
        end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        -- EventHandlers
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function Hercules_Cargo.Hercules_Cargo_Drop_Events:onEvent(Cargo_Drop_Event)
        if Cargo_Drop_Event.id == world.event.S_EVENT_SHOT then
                GT_DisplayName = Weapon.getDesc(Cargo_Drop_Event.weapon).typeName:sub(15, -1)--Remove "weapons.bombs." from string
                 -- trigger.action.outTextForCoalition(coalition.side.BLUE, string.format("Cargo_Drop_Event: %s", Weapon.getDesc(Cargo_Drop_Event.weapon).typeName), 10)
                 -- trigger.action.outTextForCoalition(coalition.side.RED, string.format("Cargo_Drop_Event: %s", Weapon.getDesc(Cargo_Drop_Event.weapon).typeName), 10)
                         ---------------------------------------------------------------------------------------------------------------------------------
                        if (GT_DisplayName == "Squad 30 x Soldier [7950lb]") then
                                GT_Name = "Soldier M4 GRG"
                                SoldierGroup = true
                                ParatrooperGroupSpawnInit = true
                                Hercules_Cargo.Cargo_Initialize(Cargo_Drop_Event.initiator, Cargo_Drop_Event.weapon, GT_Name, SoldierGroup)
                        end
                         ---------------------------------------------------------------------------------------------------------------------------------
                        if Hercules_Cargo.types[GT_DisplayName] then
                                local GT_Name = Hercules_Cargo.types[GT_DisplayName]['name']
                                local Cargo_Container_Enclosed = Hercules_Cargo.types[GT_DisplayName]['container']
                                Hercules_Cargo.Cargo_Initialize(Cargo_Drop_Event.initiator, Cargo_Drop_Event.weapon, GT_Name, Cargo_Container_Enclosed)
                        end
        end
end
world.addEventHandler(Hercules_Cargo.Hercules_Cargo_Drop_Events)

-- trigger.action.outTextForCoalition(coalition.side.BLUE, string.format("Cargo_Drop_Event.weapon: %s", Weapon.getDesc(Cargo_Drop_Event.weapon).typeName), 10)
-- trigger.action.outTextForCoalition(coalition.side.BLUE, tostring('Calculate_Object_Height_AGL: ' .. aaaaa), 10)
-- trigger.action.outTextForCoalition(coalition.side.BLUE, string.format("Speed: %.2f", Calculate_Object_Speed(Cargo_Drop_initiator)), 10)
-- trigger.action.outTextForCoalition(coalition.side.BLUE, string.format("Russian Interceptor Patrol scrambled from Nalchik"), 10)

-- function basicSerialize(var)
        -- if var == nil then
                -- return "\"\""
        -- else
                -- if ((type(var) == 'number') or
                                -- (type(var) == 'boolean') or
                                -- (type(var) == 'function') or
                                -- (type(var) == 'table') or
                                -- (type(var) == 'userdata') ) then
                        -- return tostring(var)
                -- else
                        -- if type(var) == 'string' then
                                -- var = string.format('%q', var)
                                -- return var
                        -- end
                -- end
        -- end
-- end
        
-- function tableShow(tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
        -- tableshow_tbls = tableshow_tbls or {} --create table of tables
        -- loc = loc or ""
        -- indent = indent or ""
        -- if type(tbl) == 'table' then --function only works for tables!
                -- tableshow_tbls[tbl] = loc
                -- local tbl_str = {}
                -- tbl_str[#tbl_str + 1] = indent .. '{\n'
                -- for ind,val in pairs(tbl) do -- serialize its fields
                        -- if type(ind) == "number" then
                                -- tbl_str[#tbl_str + 1] = indent
                                -- tbl_str[#tbl_str + 1] = loc .. '['
                                -- tbl_str[#tbl_str + 1] = tostring(ind)
                                -- tbl_str[#tbl_str + 1] = '] = '
                        -- else
                                -- tbl_str[#tbl_str + 1] = indent
                                -- tbl_str[#tbl_str + 1] = loc .. '['
                                -- tbl_str[#tbl_str + 1] = basicSerialize(ind)
                                -- tbl_str[#tbl_str + 1] = '] = '
                        -- end
                        -- if ((type(val) == 'number') or (type(val) == 'boolean')) then
                                -- tbl_str[#tbl_str + 1] = tostring(val)
                                -- tbl_str[#tbl_str + 1] = ',\n'
                        -- elseif type(val) == 'string' then
                                -- tbl_str[#tbl_str + 1] = basicSerialize(val)
                                -- tbl_str[#tbl_str + 1] = ',\n'
                        -- elseif type(val) == 'nil' then -- won't ever happen, right?
                                -- tbl_str[#tbl_str + 1] = 'nil,\n'
                        -- elseif type(val) == 'table' then
                                -- if tableshow_tbls[val] then
                                        -- tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
                                -- else
                                        -- tableshow_tbls[val] = loc .. '[' .. basicSerialize(ind) .. ']'
                                        -- tbl_str[#tbl_str + 1] = tostring(val) .. ' '
                                        -- tbl_str[#tbl_str + 1] = tableShow(val,       loc .. '[' .. basicSerialize(ind).. ']', indent .. '            ', tableshow_tbls)
                                        -- tbl_str[#tbl_str + 1] = ',\n'
                                -- end
                        -- elseif type(val) == 'function' then
                                -- if debug and debug.getinfo then
                                        -- local fcnname = tostring(val)
                                        -- local info = debug.getinfo(val, "S")
                                        -- if info.what == "C" then
                                                -- tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
                                        -- else
                                                -- if (string.sub(info.source, 1, 2) == [[./]]) then
                                                        -- tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) ..',\n'
                                                -- else
                                                        -- tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..',\n'
                                                -- end
                                        -- end
                                -- else
                                        -- tbl_str[#tbl_str + 1] = 'a function,\n'
                                -- end
                        -- else
                                -- tbl_str[#tbl_str + 1] = 'unable to serialize value type ' .. basicSerialize(type(val)) .. ' at index ' .. tostring(ind)
                        -- end
                -- end
                -- tbl_str[#tbl_str + 1] = indent .. '}'
                -- return table.concat(tbl_str)
        -- end
-- end




-- function F10CargoDrop(GroupId, Unitname)
        -- local rootPath = missionCommands.addSubMenuForGroup(GroupId, "Cargo Drop")
        -- missionCommands.addCommandForGroup(GroupId, "Drop direction", rootPath, CruiseMissilesMessage, {GroupId, Unitname})
        -- missionCommands.addCommandForGroup(GroupId, "Drop distance", rootPath, ForwardConvoy, nil)
        -- local measurementsSetPath = missionCommands.addSubMenuForGroup(GroupId,"Set measurement units",rootPath)
        -- missionCommands.addCommandForGroup(GroupId, "Set to Imperial (feet, knts)",measurementsSetPath,setMeasurements,{GroupId, "imperial"})
        -- missionCommands.addCommandForGroup(GroupId, "Set to Metric (meters, km/h)",measurementsSetPath,setMeasurements,{GroupId, "metric"})
-- end

-- function Calculate_Object_Speed(object)
        -- return math.sqrt(object:getVelocity().x^2 + object:getVelocity().y^2 + object:getVelocity().z^2) * 3600 / 1852 -- knts
-- end

-- function vecDotProduct(vec1, vec2)
        -- return vec1.x*vec2.x + vec1.y*vec2.y + vec1.z*vec2.z
-- end

-- function Calculate_Aircraft_ForwardVelocity(Drop_initiator)
        -- return vecDotProduct(Drop_initiator:getPosition().x, Drop_initiator:getVelocity())
-- end

--- END HERCULES CARGO SUPPORT SECTION



 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN MAIN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- XXX BEGIN MENU DEFINITIONS



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
    MenuAirfieldAttackEast = MENU_COALITION:New( coalition.side.BLUE, " East Region", MenuAirfieldAttack )
    MenuAirfieldAttackCentral = MENU_COALITION:New( coalition.side.BLUE, " Central Region", MenuAirfieldAttack )
    MenuAirfieldAttackWest = MENU_COALITION:New( coalition.side.BLUE, " West Region", MenuAirfieldAttack )
        MenuFactoryAttack = MENU_COALITION:New(coalition.side.BLUE, " Factory Strike", MenuGroundTop )
    MenuFactoryAttackEast = MENU_COALITION:New( coalition.side.BLUE, " East Region", MenuFactoryAttack )
    MenuFactoryAttackCentral = MENU_COALITION:New( coalition.side.BLUE, " Central Region", MenuFactoryAttack )
    MenuFactoryAttackWest = MENU_COALITION:New( coalition.side.BLUE, " West Region", MenuFactoryAttack )
        MenuBridgeAttack = MENU_COALITION:New(coalition.side.BLUE, " Bridge Strike", MenuGroundTop )
    MenuBridgeAttackEast = MENU_COALITION:New( coalition.side.BLUE, " East Region", MenuBridgeAttack )
    MenuBridgeAttackCentral = MENU_COALITION:New( coalition.side.BLUE, " Central Region", MenuBridgeAttack )
    MenuBridgeAttackWest = MENU_COALITION:New( coalition.side.BLUE, " West Region", MenuBridgeAttack )
        MenuCommunicationsAttack = MENU_COALITION:New(coalition.side.BLUE, " WiP Communications Strike", MenuGroundTop )
        MenuC2Attack = MENU_COALITION:New(coalition.side.BLUE, " WiP C2 Strike", MenuGroundTop )

-- ## ANTI-SHIP MISSIONS
MenuAntiShipTop = MENU_COALITION:New(coalition.side.BLUE, " WiP ANTI-SHIP MISSIONS" ) -- WiP

-- ## STRIKE PACKAGE MISSIONS
--MenuStrikePackageTop = MENU_COALITION:New(coalition.side.BLUE, " WiP STRIKE PACKAGE MISSIONS" ) -- WiP

-- ## FLEET DEFENCE MISSIONS
--MenuFleetDefenceTop = MENU_COALITION:New(coalition.side.BLUE, " WiP FLEET DEFENCE MISSIONS" ) -- WiP
 

-- END MENU DEFINITIONS
-- BEGIN FUNCTIONS


-- XXX Message displayed if WiP menu options are selected
function MenuWip( _arg )
          MESSAGE:New( "The " .. _arg .. " menu option is currently under construction. " ,5,"" ):ToAll()
end --function

-- XXX Spawn Support aircraft
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

--XXX ## Spawning CAP flights
-- max 8x CAP aircraft can be spawned at each location
function SpawnCap( _args ) -- spawnobject, spawntable { spawn, spawnzone, templates, patrolzone, aicapzone, engagerange }

  local SpawnCapTable = _args[1]
  
  SpawnCapTable.spawn:InitLimit( 8,9999 ) -- max 8x cap sections alive   
    :InitCleanUp( 60 ) -- remove aircraft that have landed
    :OnSpawnGroup(
      function ( SpawnGroup )
        AICapZone = AI_CAP_ZONE:New( SpawnCapTable.patrolzone , 1000, 6000, 500, 600 )
        AICapZone:SetControllable( SpawnGroup )
        AICapZone:SetEngageZone( SpawnCapTable.engagezone ) -- AICapZone:SetEngageRange( SpawnCapTable.engagerange )
        AICapZone:__Start( 1 ) -- start patrolling in the PatrolZone.
      end
    )
    :SpawnInZone( SpawnCapTable.spawnzone, true, 3000, 6000 )
    
end --function
  
--XXX ## Spawning enemy convoys
--  ( Central, West ) 
function SpawnConvoy ( _args ) -- ConvoyTemplates, SpawnHost {conv, dest, destzone, strikecoords, is_open}, ConvoyType, ConvoyThreats

        local TemplateTable = _args[1]
        local SpawnHostTable = _args[2]
        local ConvoyType = _args[3]
        local ConvoyThreats = _args[4]
        
        
        local SpawnIndex = math.random ( 1, #SpawnHostTable )
        local SpawnHost = SpawnHostTable[SpawnIndex].conv
        local DestZone = SpawnHostTable[SpawnIndex].destzone

  --------------------------------------
  --- Create Mission Mark on F10 map ---
  --------------------------------------
  
  --MissionMapMark(CampTableIndex)
  local StrikeMarkZone = SpawnHost -- ZONE object for zone named in strikezone 
  local StrikeMarkZoneCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone

  local StrikeMarkType = "Convoy"
  local StrikeMarkCoordsLLDMS = StrikeMarkZoneCoord:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) --TableStrikeAttack[StrikeIndex].strikecoords
  local StrikeMarkCoordsLLDDM = StrikeMarkZoneCoord:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3)) --TableStrikeAttack[StrikeIndex].strikecoords

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
                .. "\n\nLast Known Position:\n"
                .. StrikeMarkCoordsLLDMS
                .. "\n"
                .. StrikeMarkCoordsLLDDM
                .. "\n"
                .. ConvoyThreats
                .. "\n\n++++++++++++++++++++++++++++++++++++"
                
        MESSAGE:New( ConvoyAttackBrief, 30, "" ):ToAll()
        
                
end --function  
  
--XXX ## Spawning enemy camps 
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

    --------------------------------------
    --- Create Mission Mark on F10 map ---
    --------------------------------------
    
    --MissionMapMark(CampTableIndex)
    local StrikeMarkZone = SpawnCampZone -- ZONE object for zone named in strikezone 
    local StrikeMarkZoneCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone

    local StrikeMarkName = SpawnCampsTable[ CampTableIndex ].town
    local StrikeMarkType = "Camp"
    local StrikeMarkRegion = SpawnZoneRegion
        local StrikeMarkCoordsLLDMS = StrikeMarkZoneCoord:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) --TableStrikeAttack[StrikeIndex].strikecoords
        local StrikeMarkCoordsLLDDM = StrikeMarkZoneCoord:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3)) --TableStrikeAttack[StrikeIndex].strikecoords

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
                
        MESSAGE:New( CampAttackBrief, 30, "" ):ToAll()

        SpawnCampsTable[ CampTableIndex ].is_open = false
        
end --function

-- TODO: integrate camp attack, convoy strike
function SpawnStrikeAttack ( StrikeIndex ) -- "location name"
  -- TableStrikeAttack { { striketype [Airfield, Factory, Bridge, Communications, C2], strikeivo, strikecoords, strikemission, strikethreats, strikezone, striketargets, medzones { zone, is_open }, smallzones { zone, is_open }, defassets { sam, aaa, manpad, armour}, spawnobjects {}, is_open } 
  local FuncDebug = false

        BASE:TraceOnOff( false )
        BASE:TraceAll( true )

        if TableStrikeAttack[StrikeIndex].is_open then

                local MedZonesCount = #TableStrikeAttack[StrikeIndex].medzones -- number of medium defzones
                local SmallZonesCount = #TableStrikeAttack[StrikeIndex].smallzones -- number of small defzones
                local SamQty = math.random( 2, TableStrikeAttack[StrikeIndex].defassets.sam ) -- number of SAM defences min 2
                local AaaQty = math.random( 2, TableStrikeAttack[StrikeIndex].defassets.aaa ) -- number of AAA defences min 2
                local ManpadQty = math.random( 1, TableStrikeAttack[StrikeIndex].defassets.manpad ) -- number of manpad defences 1-max spawn in AAA zones. AaaQty + ManpadQty MUST NOT exceed SmallZonesCount
                local ArmourQty = math.random( 1, TableStrikeAttack[StrikeIndex].defassets.armour ) -- number of armour groups 1-max spawn in SAM zones. SamQty + ArmourQty MUST NOT exceed MedZonesCount
                local StrikeMarkZone = ZONE:FindByName( TableStrikeAttack[StrikeIndex].strikezone ) -- ZONE object for zone named in strikezone 
                
                -----------------------------------------------------------------
                --- Check sufficient zones exist for the mission air defences ---
                -----------------------------------------------------------------
                
                if SamQty + ArmourQty > MedZonesCount then
                        local msg = TableStrikeAttack[StrikeIndex].strikename .. " Error! SAM+Armour count exceedes medium zones count"
                        MESSAGE:New ( msg, 10, "" ):ToAll()
                        return
                elseif AaaQty + ManpadQty > SmallZonesCount then
                        local msg = TableStrikeAttack[StrikeIndex].strikename .. " Error! AAA+MANPAD count exceedes small zones count"
                        MESSAGE:New ( msg, 10, "" ):ToAll()
                        return
                end

    ------------------------------------------------------------------------
    --- Refresh static objects in case they've previously been destroyed ---
    ------------------------------------------------------------------------
                if #TableStrikeAttack[StrikeIndex].striketargets > 0 then 
                        for index, staticname in ipairs(TableStrikeAttack[StrikeIndex].striketargets) do
                                local AssetStrikeStaticName = staticname
                                local AssetStrikeStatic = STATIC:FindByName( AssetStrikeStaticName )
                                AssetStrikeStatic:ReSpawn( country.id.RUSSIA )
                        end
                end
                
                ---------------------------------
                --- add strike defence assets ---
                ---------------------------------
                
                function AddStrikeAssets (AssetType, AssetQty, AssetZoneType, AssetZonesCount ) -- AssetType ["sam", "aaa", "manpads", "armour"], AssetQty, AssetZoneType ["med", "small"], AssetZonesCount

                        if AssetQty > 0 then
                        
                        local TableStrikeAssetZones = {}
  
                        -- select indexes of zones in which to spawn assets 
                        for count=1, AssetQty do 
                                local zoneindex = math.random( 1, AssetZonesCount )
                                if AssetZoneType == "med" then
                                        while ( not TableStrikeAttack[StrikeIndex].medzones[zoneindex].is_open ) do -- ensure selected zone has not been used
                                                zoneindex = math.random ( 1, AssetZonesCount )
                                        end
                                        TableStrikeAttack[StrikeIndex].medzones[zoneindex].is_open = false -- close samzone for selection
                                else
                                        while ( not TableStrikeAttack[StrikeIndex].smallzones[zoneindex].is_open ) do -- ensure selected zone has not been used
                                                zoneindex = math.random ( 1, AssetZonesCount )
                                        end
                                        TableStrikeAttack[StrikeIndex].smallzones[zoneindex].is_open = false -- close aaazone for selection
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
                                        assetspawnzone = ZONE:FindByName( TableStrikeAttack[StrikeIndex].medzones[assetzoneindex].loc ) -- _G[concatenation for name of generated spawnzone]
                                else -- smallzone
                                        assetspawnzone = ZONE:FindByName( TableStrikeAttack[StrikeIndex].smallzones[assetzoneindex].loc ) -- _G["SPAWN" .. TableStrikeAttack[StrikeIndex].smallzones[assetzoneindex].loc]
                                end
                                AssetSpawnStub:SpawnInZone( assetspawnzone ) -- spawn asset in zone in generated zone list
                                local assetspawngroup, assetspawngroupindex = AssetSpawnStub:GetLastAliveGroup()
                                table.insert(TableStrikeAttack[StrikeIndex].spawnobjects, assetspawngroup )
                        end

      end

                end
                
    -------------------------
    --- Call asset spawns ---
    -------------------------
  
                -- add SAM assets
                if SamQty ~= nil then
                  AddStrikeAssets( "sam", SamQty, "med", MedZonesCount ) -- AssetType ["sam", "aaa", "manpads", "armour"], AssetQty, AssetZoneType ["med", "small"], AssetZonesCount
                end
                -- add AAA assets
                if SamQty ~= nil then
                  AddStrikeAssets( "aaa", AaaQty, "small", SmallZonesCount )
                end
                -- add Manpad assets
                if ManPadQty ~= nil then
                                AddStrikeAssets( "manpads", ManpadQty, "small", SmallZonesCount )
                end
                -- add armour assets
                if ArmourQty ~= nil then
                  AddStrikeAssets( "armour", ArmourQty, "med", MedZonesCount )
    end
    
    --------------------------------------
    --- Create Mission Mark on F10 map ---
    --------------------------------------
    
    local StrikeMarkZone = ZONE:FindByName( TableStrikeAttack[StrikeIndex].strikezone ) -- ZONE object for zone named in strikezone 
    local StrikeMarkZoneCoord = StrikeMarkZone:GetCoordinate() -- get coordinates of strikezone

    local StrikeMarkName = TableStrikeAttack[StrikeIndex].strikename
    local StrikeMarkType = TableStrikeAttack[StrikeIndex].striketype
    local StrikeMarkRegion = TableStrikeAttack[StrikeIndex].strikeregion
    local StrikeMarkCoordsLLDMS = StrikeMarkZoneCoord:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) --TableStrikeAttack[StrikeIndex].strikecoords
    local StrikeMarkCoordsLLDDM = StrikeMarkZoneCoord:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3)) --TableStrikeAttack[StrikeIndex].strikecoords

    local StrikeMarkLabel = StrikeMarkName .. " " 
      .. StrikeMarkType 
      .. " Strike " 
      .. StrikeMarkRegion 
      .. "\n" 
      .. StrikeMarkCoordsLLDMS
          .. "\n"
      .. StrikeMarkCoordsLLDDM

    local StrikeMark = StrikeMarkZoneCoord:MarkToAll(StrikeMarkLabel, true) -- add mark to map
    
    TableStrikeAttack[StrikeIndex].strikemarkid = StrikeMark -- add mark ID to table 
    
                -----------------------------
                --- Send briefing message ---
                -----------------------------
                
                local strikeAttackBrief = "++++++++++++++++++++++++++++++++++++"
                        ..      "\n\nAir Interdiction mission against "
                        .. StrikeMarkName
                        .. " "
                        .. StrikeMarkType
                        .. "\n\nMission: "
                        .. TableStrikeAttack[StrikeIndex].strikemission
                        .. "\n\nCoordinates:\n"
                        .. StrikeMarkCoordsLLDMS
                        .. "\n"
                        .. StrikeMarkCoordsLLDDM
                        .. "\n\nThreats:  "
                        .. TableStrikeAttack[StrikeIndex].strikethreats
                        .. "\n\n++++++++++++++++++++++++++++++++++++"
                        
                MESSAGE:New ( strikeAttackBrief, 30, "" ):ToAll()
                
        
                TableStrikeAttack[StrikeIndex].is_open = false -- mark strike mission as active
                
                ------------------------------------------------------------------------------
                --- menu: add mission remove command and remove mission start command ---
                ------------------------------------------------------------------------------
                
    _G["Cmd" .. StrikeIndex .. "Attack"]:Remove()
                _G["Cmd" .. StrikeIndex .. "AttackRemove"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Remove Mission", _G["Menu" .. TableStrikeAttack[StrikeIndex].striketype .. "Attack" .. StrikeIndex], RemoveStrikeAttack, StrikeIndex )
                        
        else
                msg = "\n\nThe " 
                        .. TableStrikeAttack[StrikeIndex].strikename
                        .. " "
                        .. TableStrikeAttack[StrikeIndex].striketype
                        .. " strike attack mission is already active!"
                MESSAGE:New( msg, 10, "" ):ToAll()
        end

BASE:TraceOnOff( false )

end --function

------------------------------------
--- Remove strike attack mission ---
------------------------------------

function RemoveStrikeAttack ( StrikeIndex )
BASE:TraceOnOff( false )
BASE:TraceAll( true )

        if not TableStrikeAttack[StrikeIndex].is_open then
                local objectcount = #TableStrikeAttack[StrikeIndex].spawnobjects
                for count = 1, objectcount do
                        local removespawnobject = TableStrikeAttack[StrikeIndex].spawnobjects[count]
                        if removespawnobject:IsAlive() then
                                
                                removespawnobject:Destroy( false )
                        end
                end
                
                COORDINATE:RemoveMark( TableStrikeAttack[StrikeIndex].strikemarkid ) -- remove mark from map
                
                TableStrikeAttack[StrikeIndex].strikemarkid = nil -- reset map mark ID
                TableStrikeAttack[StrikeIndex].spawnobjects = {} -- clear list of now despawned objects
                TableStrikeAttack[StrikeIndex].is_open = true -- set strike mission as available
                
                -- ## menu: add mission start menu command and remove mission remove command
    _G["Cmd" .. StrikeIndex .. "AttackRemove"]:Remove()
                _G["Cmd" .. StrikeIndex .. "Attack"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Start Mission", _G["Menu" .. TableStrikeAttack[StrikeIndex].striketype .. "Attack" .. StrikeIndex], SpawnStrikeAttack, StrikeIndex )

    msg = "\n\nThe " 
      .. TableStrikeAttack[StrikeIndex].strikename
      .. " strike attack mission has been removed."
    MESSAGE:New( msg, 10, "" ):ToAll()

        else
                msg = "\n\nThe " 
                        .. TableStrikeAttack[StrikeIndex].strikename
                        .. " strike attack mission is not active!"
                MESSAGE:New( msg, 10, "" ):ToAll()
        end
BASE:TraceOnOff( false )

end --function


----------------------------------------
--- Remove oldest spawn in a mission ---
----------------------------------------

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


-- END FUNCTIONS
-- -- XXX BEGIN ATIS

-- atisVaziani=ATIS:New(AIRBASE.Caucasus.Vaziani, 122.7)
-- atisVaziani:SetRadioRelayUnitName("Radio Relay Vaziani")
-- atisVaziani:AddILS(108.75, "31")
-- atisVaziani:SetTACAN(22)
-- atisVaziani:SetTowerFrequencies({269.1, 140.1})
-- atisVaziani:Start()


-- atisTbilisi=ATIS:New(AIRBASE.Caucasus.Tbilisi_Lochini, 132.8)
-- atisTbilisi:SetRadioRelayUnitName("Radio Relay Tbilisi")
-- atisTbilisi:AddILS(108.9, "31")
-- atisTbilisi:SetVOR(113.7)
-- atisTbilisi:SetTowerFrequencies({267.1, 138.1})
-- atisTbilisi:SetActiveRunway("L")
-- atisTbilisi:Start()


-- -- END ATIS
-- XXX BEGIN SUPPORT AC SECTION


---------------------------------------------------
--- Define spawn zones with trigger zones in ME ---
---------------------------------------------------

Zone_AAR_1 = ZONE:FindByName( "AAR_1_Zone" ) 
Zone_AAR_2 = ZONE:FindByName( "AAR_2_Zone" ) 
Zone_AWACS_1 = ZONE:FindByName( "AWACS_1_Zone" )
Zone_Red_AWACS_1 = ZONE:FindByName( "RED_AWACS_1_Zone" ) 

------------------------------------------------------
--- define table of support aircraft to be spawned ---
------------------------------------------------------

TableSpawnSupport = { -- {spawnobjectname, spawnzone}
        {spawnobject = "Tanker_C130_Arco1", spawnzone = Zone_AAR_1},
        {spawnobject = "Tanker_KC135_Shell1", spawnzone = Zone_AAR_1},
  {spawnobject = "Tanker_KC135_Shell2", spawnzone = Zone_AAR_2},
  {spawnobject = "Tanker_KC135_Texaco1", spawnzone = Zone_AAR_1},
        {spawnobject = "AWACS_Magic", spawnzone = Zone_AWACS_1},
        {spawnobject = "RED_AWACS_108", spawnzone = Zone_Red_AWACS_1},
}

------------------------------
--- spawn support aircraft ---
------------------------------

for i, v in ipairs( TableSpawnSupport ) do
        SpawnSupport ( v )
        
end


-- END SUPPORT AC SECTION
-- XXX BEGIN BOAT SECTION


-----------------------
--- Airboss Lincoln ---
-----------------------

-- -- Create AIRBOSS object for Lincoln
-- airbossLincoln=AIRBOSS:New( "CSG_CarrierGrp_Lincoln", "Lincoln" )

-- -- Set load and save path/name for persistent LSO grades
-- airbossLincoln:Load(nil, "Cauc_Airboss-USS Lincoln_LSOgrades.csv")
-- airbossLincoln:SetAutoSave(nil, "Cauc_Airboss-USS Lincoln_LSOgrades.csv")

-- local lincolnOffset_deg = 0 -- Marshal offset
-- local lincolnDefaultPlayerSkill = AIRBOSS.Difficulty.Normal -- default skill level
-- local lincolnRadioRelayMarshall = UNIT:FindByName("RadioRelayMarshall_Lincoln") -- radio relay unit for Marshal
-- local lincolnRadioRelayPaddles = UNIT:FindByName("RadioRelayPaddles_Lincoln") -- radio relay unit for LSO
-- local lincolnClouds, lincolnVisibility, lincolnFog, lincolnDust = airbossLincoln:_GetStaticWeather() -- get mission weather (assumes static weather is used)

-- --- Determine Daytime Case
-- -- adjust case according to weather state

-- local lincolnCase = 1 -- default to Case I

-- if (lincolnClouds.base < 305 and lincolnClouds.density > 8) or lincolnVisibility < 8000 then -- cloudbase < 1000' or viz < 5 miles, Case III
  -- lincolnCase = 3
-- elseif lincolnFog and lincolnFog.thickness > 60 and lincolnFog.visibility < 8000 then -- visibility in fog < 5nm, Case III
  -- lincolnCase = 3
-- elseif (lincolnClouds.base < 915 and lincolnClouds.density > 8) and lincolnVisibility >= 8000 then -- cloudbase < 3000', viz > 5 miles, Case II
  -- lincolnCase = 2
-- end     
 
-- -- Lincoln AIRBOSS configuration
-- airbossLincoln:SetMenuRecovery(30, 25, false, 30)
-- airbossLincoln:SetSoundfilesFolder("Airboss Soundfiles/")
-- airbossLincoln:SetTACAN(74,"X","STN")
-- airbossLincoln:SetICLS( 4,"STN" )
-- airbossLincoln:SetCarrierControlledArea( 50 )
-- airbossLincoln:SetDespawnOnEngineShutdown( true )
-- airbossLincoln:SetRecoveryTanker( Spawn_Tanker_S3B_Texaco1 )
-- airbossLincoln:SetMarshalRadio( 285.675, "AM" )
-- airbossLincoln:SetLSORadio( 308.475, "AM" )
-- airbossLincoln:SetRadioRelayLSO( lincolnRadioRelayPaddles )
-- airbossLincoln:SetRadioRelayMarshal( lincolnRadioRelayMarshall )
-- airbossLincoln:SetAirbossNiceGuy(true) -- allow direct to commence
-- airbossLincoln:SetDefaultPlayerSkill(lincolnDefaultPlayerSkill)
-- airbossLincoln:SetRespawnAI()
-- airbossLincoln:SetMenuMarkZones(false) -- disable marking zones using smoke or flares

-- --- Fun Map Recovery Windows 
-- -- sunrise and sunset dependant on mission date
-- -- https://www.timeanddate.com/sun/united-arab-emirates/abu-dhabi?month=4&year=2011
-- -- Sunrise @ 08:00, Sunset @ 19:00, recovery @ sunrise+10 and sunset-10
-- -- otherwise, intiate recovery through F10 menu
-- airbossLincoln:AddRecoveryWindow( "8:10", "18:50", lincolnCase, lincolnOffset_deg, true, 30 ) -- sunrise to sunset
-- airbossLincoln:AddRecoveryWindow( "18:50", "8:10+1", 3, lincolnOffset_deg, true, 30 ) -- sunset to sunrise D+1
-- airbossLincoln:AddRecoveryWindow( "8:10+1", "18:50+1", lincolnCase, lincolnOffset_deg, true, 30 ) -- sunrise D+1 to sunset D+1

-- -- Start AIRBOSS Lincoln
-- airbossLincoln:Start()

-- Recovery Tanker Lincoln ---

Spawn_Tanker_S3B_Texaco6 = RECOVERYTANKER:New( UNIT:FindByName( "CSG_CarrierGrp_Lincoln"), "Tanker_S3B_Texaco6" )

Spawn_Tanker_S3B_Texaco6:SetCallsign(CALLSIGN.Tanker.Texaco, 6)
Spawn_Tanker_S3B_Texaco6:SetTACAN(38, "TEX")
Spawn_Tanker_S3B_Texaco6:SetRadio(317.775)
Spawn_Tanker_S3B_Texaco6:SetModex(049)
Spawn_Tanker_S3B_Texaco6:SetTakeoffAir()
Spawn_Tanker_S3B_Texaco6:SetAltitude(6000)
Spawn_Tanker_S3B_Texaco6:SetRespawnInAir()
Spawn_Tanker_S3B_Texaco6:Start()

Spawn_Tanker_S3B_Texaco6:SetRecoveryAirboss( false )

-- Rescue Helo Lincoln ---

Spawn_Rescuehelo_Lincoln = RESCUEHELO:New(UNIT:FindByName("CSG_CarrierGrp_Lincoln"), "RescueHelo_Lincoln")

Spawn_Rescuehelo_Lincoln:SetTakeoffAir()
Spawn_Rescuehelo_Lincoln:SetRespawnInAir()
Spawn_Rescuehelo_Lincoln:SetHomeBase(AIRBASE:FindByName("CSG_CarrierGrp_Lincoln_03"))
Spawn_Rescuehelo_Lincoln:SetRescueStopBoatOff()
Spawn_Rescuehelo_Lincoln:SetOffsetZ(800)
--Spawn_Rescuehelo_Lincoln:Start()

-- Rescue Helo Tarawa ---

Spawn_Rescuehelo_Tarawa = RESCUEHELO:New(UNIT:FindByName("CSG_CarrierGrp_Tarawa"), "RescueHelo_Tarawa")

Spawn_Rescuehelo_Tarawa:SetTakeoffAir()
Spawn_Rescuehelo_Tarawa:SetRespawnInAir()
Spawn_Rescuehelo_Tarawa:SetHomeBase(AIRBASE:FindByName("CSG_CarrierGrp_Tarawa_03"))
Spawn_Rescuehelo_Tarawa:SetRescueStopBoatOff()
Spawn_Rescuehelo_Tarawa:SetOffsetZ(800)
--Spawn_Rescuehelo_Tarawa:Start()

-----------------------
--- Airboss Tarawa ---
-----------------------

airbossTarawa=AIRBOSS:New( "CSG_CarrierGrp_Tarawa", "Tarawa" )

airbossTarawa:Load(nil, "Cauc_Airboss-USS Tarawa_LSOgrades.csv")
airbossTarawa:SetAutoSave(nil, "Cauc_Airboss-USS Tarawa_LSOgrades.csv")

local tarawaCase = lincolnCase -- set daytime case according to weather, determined in Lincoln section. assumes statc weather accross whole map.
local tarawaOffset_deg = 0
local tarawaRadioRelayMarshall = UNIT:FindByName("RadioRelayMarshall_Tarawa")
local tarawaRadioRelayPaddles = UNIT:FindByName("RadioRelayPaddles_Tarawa")
 
airbossTarawa:SetMenuRecovery(30, 25, false, 30)
airbossTarawa:SetSoundfilesFolder("Airboss Soundfiles/")
airbossTarawa:SetTACAN(1,"X","TAR")
airbossTarawa:SetICLS( 1,"TAR" )
airbossTarawa:SetCarrierControlledArea( 50 )
airbossTarawa:SetDespawnOnEngineShutdown( true )
airbossTarawa:SetMarshalRadio( 285.675, "AM" )
airbossTarawa:SetLSORadio( 255.725, "AM" )
airbossTarawa:SetRadioRelayLSO( tarawaRadioRelayPaddles )
airbossTarawa:SetRadioRelayMarshal( tarawaRadioRelayMarshall  )
airbossTarawa:SetAirbossNiceGuy( true )
airbossTarawa:SetDefaultPlayerSkill(AIRBOSS.Difficulty.Normal)
airbossTarawa:SetRespawnAI()
airbossTarawa:SetMenuMarkZones( false ) -- disable marking zones using smoke or flares

--- Fun Map Recovery Windows 
-- dependent on mission start and finish times
-- Sunrise @ 08:00, Sunset @ 19:00, recovery @ sunrise+10 and sunset-10
-- otherwise, intiate recovery through F10 menu
airbossTarawa:AddRecoveryWindow( "8:10", "18:50", tarawaCase, tarawaOffset_deg, true, 30 ) -- sunrise to sunset 
airbossTarawa:AddRecoveryWindow( "18:50", "8:10+1", 3, tarawaOffset_deg, true, 30 ) -- sunset to sunrise D+1
airbossTarawa:AddRecoveryWindow( "8:10+1", "18:50+1", tarawaCase, tarawaOffset_deg, true, 30 ) -- sunrise D+1 to sunset D+1

-- Start AIRBOSS Tarawa
airbossTarawa:Start()

-- Recovery Tanker Tarawa ---

Spawn_Tanker_C130_Arco2 = RECOVERYTANKER:New( UNIT:FindByName( "CSG_CarrierGrp_Tarawa"), "Tanker_C130_Arco2" )

Spawn_Tanker_C130_Arco2:SetCallsign(CALLSIGN.Tanker.Arco, 2)
  :SetTACAN(39, "ARC")
  :SetRadio(276.1)
  :SetModex(999)
  :SetAltitude(10000)
  :SetTakeoffAir()
  :SetRespawnInAir()
  :SetHomeBase(AIRBASE:FindByName("Kobuleti"))
  :Start()

-- END BOAT SECTION
-- XXX BEGIN RANGE SECTION



------------------
--- GG33 Range ---
------------------

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

------------------
--- NL24 Range ---
------------------

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


-----------------------
--- CAP spawn stubs ---
-----------------------

MaykopCapSpawn = SPAWN:New( "MaykopCap" )
BeslanCapSpawn = SPAWN:New( "BeslanCap" )

-----------------------
--- CAP spawn zones ---
-----------------------

MaykopCapSpawnZone = ZONE:FindByName( "ZONE_MaykopCapSpawn" )
BeslanCapSpawnZone = ZONE:FindByName( "ZONE_BeslanCapSpawn" )

---------------------------
--- CAP spawn templates ---
---------------------------

CapTemplates = {
        "Russia_Mig29",
        "Russia_Mig21",
        "Russia_Su27"
}

-----------------------------------------
--- AICapzone patrol and engage zones ---
-----------------------------------------

WestCapPatrolGroup = GROUP:FindByName( "PolyPatrolWest" )
WestCapPatrolZone = ZONE_POLYGON:New( "ZONE_PatrolWest", WestCapPatrolGroup )
WestCapEngageGroup = GROUP:FindByName( "PolyEngageWest" )
WestCapEngageZone = ZONE_POLYGON:New( "ZONE_EngageWest", WestCapEngageGroup )

EastCapPatrolGroup = GROUP:FindByName( "PolyPatrolEast" )
EastCapPatrolZone = ZONE_POLYGON:New( "ZONE_PatrolEast", EastCapPatrolGroup )
EastCapEngageGroup = GROUP:FindByName( "PolyEngageEast" )
EastCapEngageZone = ZONE_POLYGON:New( "ZONE_EngageEast", EastCapEngageGroup )

------------------------------------------------------
--- table containing CAP spawn config per location ---
------------------------------------------------------

CapTable = { -- spawn location, { spawn, spawnzone, templates, patrolzone, engagerange } ...
  maykop = { 
    spawn = MaykopCapSpawn, 
    spawnzone = MaykopCapSpawnZone, 
    templates = CapTemplates, 
    patrolzone = WestCapPatrolZone, 
    engagerange = 60000,
    engagezone = WestCapEngageZone,
  },
  beslan = { 
    spawn = BeslanCapSpawn, 
    spawnzone = BeslanCapSpawnZone, 
    templates = CapTemplates, 
    patrolzone = EastCapPatrolZone, 
    engagerange = 60000,
    engagezone = EastCapEngageZone,
  },
}

------------------
--- Maykop CAP ---
------------------

_maykop_args = { -- args passed to spawn menu option
        CapTable.maykop,
}

CmdMaykopCap = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Spawn Maykop CAP", MenuCapMaykop, SpawnCap, _maykop_args ) -- Spawn CAP flight
CmdMaykopCapRemove = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Remove Oldest Maykop CAP", MenuCapMaykop, RemoveSpawn, _maykop_args ) -- Remove the oldest CAP flight for location

------------------
--- Beslan CAP ---
------------------

_beslan_args = { 
        CapTable.beslan,
}

CmdBeslanCap = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Spawn Beslan CAP", MenuCapBeslan, SpawnCap, _beslan_args ) 
CmdBeslanCapRemove = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Remove oldest Beslan CAP", MenuCapBeslan, RemoveSpawn, _beslan_args )




-- END CAP SECTION
-- BEGIN CAMP ATTACK SECTION


-------------------------------------------------
--- table containing camp spawns per location ---
-------------------------------------------------

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

------------------------
--- Camp spawn stubs ---
------------------------

--[[ SpawnTent = SPAWN:New( "CAMP_Tent_01" )
SpawnHouse01 = SPAWN:New( "CAMP_House_01" )
SpawnHouse02 = SPAWN:New( "CAMP_House_02" )
SpawnHouse03 = SPAWN:New( "CAMP_House_03" )
SpawnHouse04 = SPAWN:New( "CAMP_House_04" )
SpawnHouse05 = SPAWN:New( "CAMP_House_05" )  
SpawnTower = SPAWN:New( "CAMP_Tower_01" )
SpawnInfSingle = SPAWN:New( "CAMP_Inf_01" )
 ]]
CampAttackSpawn = SPAWN:New( "CAMP_Heavy" )
SpawnTentGroup = SPAWN:New( "CAMP_Tent_Group" )
SpawnInfGroup = SPAWN:New( "CAMP_Inf_02" )

----------------------------
--- Camp spawn templates ---
----------------------------

ArmourTemplates = {
        "CAMP_Heavy_01",
        "CAMP_Heavy_02",
        "CAMP_Heavy_03",
        "CAMP_Heavy_04"
} 

-------------------------
--- Add menu commands ---
-------------------------

-- East zones
_east_args = {
        ArmourTemplates,
        TableCamps.east,
        "East"
}

cmdCampAttackEast = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Eastern Zone",MenuCampAttack,SpawnCamp, _east_args )

-- Central Zones
_central_args = {
        ArmourTemplates,
        TableCamps.central,
        "Central"
}
cmdCampAttackCentral = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Central Zone",MenuCampAttack,SpawnCamp, _central_args )

-- West Zones
 _West_args = {
        ArmourTemplates,
        TableCamps.west,
        "West"
}
cmdCampAttackWest = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Western Zone",MenuCampAttack,SpawnCamp, _West_args )

-- TODO: Remove oldest Camp Attack mission
_campattackremove_args = { 
        CampAttackSpawn,
        SpawnTentGroup,
        SpawnInfGroup
}
--cmdCampAttackRemove = MENU_COALITION_COMMAND:New( coalition.side.BLUE, " Remove oldest mission", MenuCampAttack, RemoveSpawnGroup, _campattackremove_args )



-- END CAMP ATTACK SECTION
-- BEGIN CONVOY ATTACK SECTION

-- XXX ## Able Sentry Convoy
-- Convoy is spawned at mission start and will advance North->South on highway B3 towards Tbilisi
-- On reaching Mtskehta it will respawn at the start of the route.

function ResetAbleSentry()
  Spawn_Convoy_AbleSentry:ReSpawn(SpawnIndex_Convoy_AbleSentry) 
end -- function

Zone_ConvoyObjectiveAbleSentry = ZONE:FindByName( "ConvoyObjectiveAbleSentry" ) 

Spawn_Convoy_AbleSentry = SPAWN:New( "CONVOY_Hard_Able Sentry" )
        :InitLimit( 20, 50 )
        :OnSpawnGroup(
                function ( SpawnGroup )
                        -- SpawnIndex_Convoy_AbleSentry = Spawn_Convoy_AbleSentry:GetSpawnIndexFromGroup( SpawnGroup )
                        checkConvoyAbleSentry = SCHEDULER:New( SpawnGroup, 
                        function()
                                if SpawnGroup:IsPartlyInZone( Zone_ConvoyObjectiveAbleSentry ) then
                                        ResetAbleSentry()
                                end
                        end,
                        {}, 0, 60
                )
                  mapMarkConvoyAbleSentry = SCHEDULER:New( SpawnGroup, 
        function()
          if Spawn_Convoy_AbleSentry.mapmarkid then
            COORDINATE:RemoveMark( Spawn_Convoy_AbleSentry.mapmarkid )
          end    
          local coordsAbleSentry = SpawnGroup:GetCoordinate()
          local labelAbleSentry = "Able Sentry Convoy\nMost recent reported postion\n" .. coordsAbleSentry:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) .. "\n" .. coordsAbleSentry:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3))
          local mapMarkAbleSentry = coordsAbleSentry:MarkToAll(labelAbleSentry, true) -- add mark to map
          Spawn_Convoy_AbleSentry.mapmarkid = mapMarkAbleSentry -- add mark ID to SPAWN object 
        end,
        {}, 0, 180
      )
                end
        )
        :SpawnScheduled( 60 , .1 )

    


cmdConvoyAbleSentryReset = MENU_COALITION_COMMAND:New( coalition.side.BLUE," Able Sentry Reset",MenuConvoyAttack, ResetAbleSentry )

---------------------------------
--- On-demand convoy missions ---
---------------------------------

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



--- TableStrikeAttack table 
-- @type TableStrikeAttack
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

-- XXX: TableStrikeAttack

TableStrikeAttack = {
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


--------------------------------------
--- strike Defence spawn templates ---
--------------------------------------

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

-------------------------------------------
--- generate strike defence spawn stubs ---
-------------------------------------------

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

------------------------------------------
--- menu: generate strike attack menus ---
------------------------------------------

for strikeIndex, strikeValue in pairs(TableStrikeAttack) do -- step through TableStrikeAttack and grab the mission data for each key ( = "location")

        local strikeType = strikeValue.striketype
        local strikeRegion = strikeValue.strikeregion
        local strikeName = strikeValue.strikename
        local StrikeIvo = strikeValue.strikeivo

        _G["Menu" .. strikeType .. "Attack" .. strikeIndex] = MENU_COALITION:New( coalition.side.BLUE, strikeName .. " " .. StrikeIvo, _G["Menu" .. strikeType .. "Attack" .. strikeRegion] ) -- add menu for each mission location in the correct strike type sub menu
        _G["Cmd" .. strikeIndex .. "Attack"] = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Start Mission", _G["Menu" .. strikeType .. "Attack" .. strikeIndex], SpawnStrikeAttack, strikeIndex ) -- add menu command to launch the mission

end



-- END strike ATTACK SECTION    


--- END MAIN
 
env.info( '*** JTF-1 MOOSE MISSION SCRIPT END ***' )
 
