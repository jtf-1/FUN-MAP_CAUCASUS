---
-- Blue GCI CVN Ops Caucasus map
BASE:I("Blue CVN CAP Starting")

local airboss=AIRBOSS:New("Forrestal","CVN-59")
airboss:SetAirbossNiceGuy(true)
airboss:SetHandleAION()
airboss:SetICLS(5,"FOR")
airboss:SetTACAN(59,"X","FOR")
airboss:SetRadioRelayLSO("LSO Radio")
airboss:SetRadioRelayMarshal("Marshal Radio")
airboss:SetRefuelAI(0.15)
airboss:__Start(2)

local rescueheli = RESCUEHELO:New("Forrestal","Rescue Heli")
rescueheli:SetRescueOff()
rescueheli:__Start(2)

local recoverytanker = RECOVERYTANKER:New("Forrestal","Tanker FOR")
recoverytanker:SetTACAN(61,"TKR")
recoverytanker:SetCallsign(CALLSIGN.Tanker.Arco,1)
recoverytanker:SetRadio(244,"AM")
recoverytanker:SetSpeed(220)
recoverytanker:Start()
airboss:SetRecoveryTanker(recoverytanker)

local carrierawacs = RECOVERYTANKER:New("Forrestal","Blue Awacs CVN")
carrierawacs:SetAWACS(true,true)
carrierawacs:SetCallsign(CALLSIGN.AWACS.Magic,1)
carrierawacs:SetRadio(272,"AM")
carrierawacs:SetAltitude(15000)
carrierawacs:Start()

-- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
-- Here we build the network with all the groups that have a name starting with DF CCCP AWACS and DF CCCP EWR.
local Blue_DetectionSetGroup = SET_GROUP:New()
Blue_DetectionSetGroup:FilterPrefixes( { "CVN-59" } )
Blue_DetectionSetGroup:FilterOnce()

local Blue_Detection = DETECTION_AREAS:New( Blue_DetectionSetGroup, 30000 )

-- Setup the A2A dispatcher, and initialize it.
local Blue_A2ADispatcher = AI_A2A_DISPATCHER:New( Blue_Detection )

-- Setup the border zone. 
-- In this case the border is a zone surrounding the carrier
-- Any enemy crossing this border will be engaged.
local Blue_BorderZone = ZONE_UNIT:New("CVN Zone",UNIT:FindByName("Forrestal"),50000)
Blue_A2ADispatcher:SetBorderZone( Blue_BorderZone )

Blue_A2ADispatcher:SetTacticalDisplay( false )

Blue_A2ADispatcher:SetDefaultCapLimit(2)
Blue_A2ADispatcher:SetDefaultFuelThreshold(0.2)
Blue_A2ADispatcher:SetDefaultLandingAtEngineShutdown()
Blue_A2ADispatcher:SetDefaultTakeoffFromParkingHot()
Blue_A2ADispatcher:SetSquadron( "CVN-59", "Forrestal", "Blue Sq1 F-14B" )
Blue_A2ADispatcher:SetSquadronCap( "CVN-59", Blue_BorderZone, UTILS.FeetToMeters(15000), UTILS.FeetToMeters(30000), UTILS.KnotsToKmph(250), UTILS.KnotsToKmph(350), UTILS.KnotsToKmph(500), UTILS.KnotsToKmph(1000), "BARO")
Blue_A2ADispatcher:SetSquadronLandingNearAirbase("CVN-59")
Blue_A2ADispatcher:SetSquadronCapRacetrack("CVN-59")
Blue_A2ADispatcher:SetIntercept( 30 )
Blue_A2ADispatcher:SetDisengageRadius( 125000 )
Blue_A2ADispatcher:SetEngageRadius( 75000 )
Blue_A2ADispatcher:SetGciRadius( 125000 )
Blue_A2ADispatcher:SetDefaultOverhead( 0.5 )
Blue_A2ADispatcher:Start()

BASE:I("Blue CVN CAP Started")