Welcome to the JTF-1 Caucasus Fun Map!
Please make yourself aware of the following information:

ATIS
====

- Vaziani 122.7
- Tbilisi-Lochini 132.8

AWACS
=====

Magic 1-1, 367.575

Bullseye 42'11'11 N | 041'40'44 E

TANKERS
=======

Track LM;
- Arco 1-1  [KC130] 36Y, 276.5, FL160
- Shell 1-1 [KC135MPRS] 115Y, 317.5, FL200
- Texaco 1-1 [KC135] 105Y, 317.75, FL240

Track EH;
- Shell 2-1 [KC135MPRS] 116Y, 317.6, FL200
- Texaco 1-1 [KC135] 106Y, 317.65, FL240

Lincoln Hawk;
- Texaco 6-1 [S-3B] 38Y, 317.775, FL060

Tarawa Hawk;
- Arco 2-1 [KC-130] 39Y, 276.1, FL100

NAVAL OPERATIONS
================

Carriers will cruise North/South. Use the Carrier Control menu to start or stop recovery/lanuch windows.

Strike: 357.775
Marshal: 285.675

CVN-72 Abraham Lincoln:
- TACAN 72X 
- ILCS: Channel 4
- LINK 4 372.0 Mhz
- Tower/Paddles: 308.475 AM
 
(Use CV Deck freq 274.075 to call AI Tower to request landing. This also activates lights at night)

Dynamic Deck Templates are available for this carrier.

Tarawa:
- TACAN 1X
- ILCS Channel 1
- Tower/Paddles: 255.725

(Use LHA TWR alt freq 278.325 to call AI Tower for landing)

FARPS
=====

Dublin:
- COORDS 42 19 47 N | 043 26 08 E
- Airboss 250.775 AM

(Use Airboss for AI ATC and to activate FARP lights)

ABLE SENTRY CONVOY
==================

A strike attack against an armoured convoy is present throughout the mission run time. The convoy originates in grid MN50 and will follow the MSR South for approximately 40NM to Misaktsieli in grid MM74. It consists of MTBs and BTRs, and is protected by mobile AAA and SAM. The convoy will respwan at its origin if it is completely destroyed or if it reaches its destination. It can also be respawned, on demand, via the F10 menu. A mark, with a label listing the last known coordinates of the convoy, will be placed on the F10 map and updated every three minutes.

ON DEMAND ENEMY CAP
===================

Enemy CAP flights are available on demand. CAP flights can be managed for locations at which they are available through the F10 menu. A maximum of 8x concurrent CAP flights may be alive at each location. A menu option is also available to remove the oldest spawned CAP flight at each location.

ON DEMAND GROUND ATTACK MISSIONS
================================

Insurgent Camp Attack:  
----------------------

Strike missions are available, on-demand, via the F-10 menu. Camps can be spawned at a series of random locations, South of the Russian border, within the Eastern, Central and Western portions of the map (8x potential locations in each). A mission brief will be displayed with the location of the camp (nearest town and coordinates). A mark, with a label listing the strike name and its coordinates, will be placed on the F10 map at the strike location. A menu option is also available to remove the oldest spawned insurgent camp.

Convoy Attack: 
--------------

Strike missions against enemy convoys are available, on-demand, via the F-10 menu. Options are available to spawn both armoured and soft convoys, at a series of random locations within the Central and Western portions of the map. A mission brief will be displayed indicating the last known location of the convoy, its anticipated destination and the threats within it. A mark, with a label listing the strike name and its coordinates, will be placed on the F10 map at the strike location.

Strategic Strike Attacks: 
-------------------------

Strike missions are available, on demand, via the F10 menu. Air defences can be spawned at a series of target locations North of the Russian border. A mission brief will be displayed confirming the name of the chosen location, the coordinates of the main target center, and the anticipated threats. A mark, with a label listing the strike name and its coordinates, will be placed on the F10 map at the strike location. A menu option is also available to remove the mission after it has been spawned. The following target categories are selectable;

- Airfield
- Factory
- Bridge
- Port
- Naval (WiP)

AI BFM/ACM
==========

On-demand single or pair adversary spawns are available via the F10 menu while aircraft are within the BFM/ACM zone in grid ML (see F10 map for zone). Adversaries will be spawned ahead of you at the selected distance (5NM, 10NM, 20NM). If the adversary aircraft depart the zone they will be removed.

Notifications relating to target activation, reset and deactivation will be broadcast on 377.8 UHF.

RANGE COMPLEXES
===============

- GG33
- NL24
- Range Control: 250.000

Ranges are script scored and have an F10 menu system you can use to manage them.

Bomb targets are scored on the proximity of the last round to the target. Smoke will be used to mark the round's impact.

Strafe Pits, where available, are configured with two targets. Aircraft must be below 3000ft AGL and within 500ft either side of the inbound heading to the target to avoid a foul pass. Rounds fired after the foul line will not count.


CARRIER CONTROL
===============

Launch and Recovery windows can be requested from the F10|Other|Carrier Control menu. The carrier will cruise West/East to hold station and will turn into wind when a window is requested. The following window lengths are available;

- 15 minutes
- 30 minutes
- 60 minutes
- 90 mninutes

The current window can also be cancelled from the menu. After a window has been cancelled the carrier will retun to the point at which the window was requested and continue holding station.

Deck lighting can be controlled via the Change Lights submenu. By default, the carrier lights mode is set to Navigation when cruising and will change to Recovery mode at the start of a recovery window. The mode can be changed to Launch, or back to Recovery, via the menu.


DYNAMIC DECK TEMPLATES
======================

Application and removal of Dynamic Deck Templates is available in the F10|Other|JTF-1 menu under "Dynamic Deck". Complete and partial templates can be applied to supported ships. 

Complete templates contain a full set of static objects for Launch or Recovery. If a Complete template is applied all existing statics will be cleared from the deck first.

Partial templates can be added to or subtracted from a clear deck or a deck containing other partial templates. Partial templates cannot be added to, or removed from, a Complete template that has already been applied.

The "Clear Deck" command will remove all statics from the deck.


MAP MARK SPAWNING
=================

(Originally sourced from Virtual 57th and refactored for JTF-1)


Use F10 map marks to spawn BVR opponents or ground threats anywhere on the map. Add mark to map then type the CMD syntax below in the map mark text field. The command will execute on mouse-clicking out of the text box.

NOTE: currently no syntax error feedback if you get it wrong.

COMMANDS
--------

- ASPAWN: = Spawn Air Group
- GSPAWN: = Spawn Ground Group
- NSPAWN: = Spawn Navy Group
- WXREPORT: = Adds a weather report to the placed mark
- DELETE: = Delete one, or more, Group(s)

Airspawn syntax
---------------

CMD ASPAWN: [type][, [option]: [value]][...]


Airspawn Types
--------------

- F4
- SU25
- SU27
- MIG29
- SU25
- MIG23
- F16
- F18
- F16SEAD
- F18SEAD
- OPTIONS	(will list the types available for this command)


Airspawn Options
----------------

- HDG: [degrees] - default 000
- ALT: [flight level] - default 280 (28,000ft)
- DIST:[nm] - default 0 (spawn on mark point)
- NUM: [1-4] - default 1
- SPD: [knots] - default 425
- SKILL: [AVERAGE, GOOD, HIGH, EXCELLENT, RANDOM] - default AVERAGE
- TASK: [CAP] - default NOTHING
- SIDE: [RED, BLUE, NEUTRAL] - default RED (Russia)
- OPTIONS	(will list the types available for this command)


Example
-------

CMD ASPAWN: MIG29, NUM: 2, HDG: 180, SKILL: GOOD

Will spawn 2x Red MiG29 at the default speed of 425 knots, with heading 180 and skill level GOOD.



Groundspawn Syntax
------------------

CMD GSPAWN: [groundspawn type][, [option]: [value]][...]


Groundspawn Types
-----------------

- SA2		(battery)
- SA3		{battery)
- SA6		(battery)
- SA8		(single)
- SA10		(battery)
- SA11		(battery)
- SA15		(single)
- SA19		(single)
- ZSU23		(ZSU23 Shilka)
- ZU23EMP	(ZU23 fixed emplacement)
- ZU23URAL	(ZU23 mounted on Ural)
- CONLIGHT      (Supply convoy)
- CONHEAVY	(Armoured convoy) 
- OPTIONS	(will list the types available for this command)


Groundspawn Options
----------------

- ALERT: [GREEN, AUTO, RED] - default RED 
- SKILL: [AVERAGE, GOOD, HIGH, EXCELLENT, RANDOM] - default AVERAGE


Example
-------

CMD GSPAWN: SA6, ALERT: GREEN, SKILL: HIGH

Will spawn an SA6 Battery on the location of the map mark, in alert state GREEN and with skill level HIGH.



Weather Report Syntax
---------------------

CMD WXREPORT: [QFE, METRIC]


Weather Report Options
----------------------

- QFE   (Pressure displayed as QFE) - default QNH
- METRIC  (Produces the report in Metric format (mp/s, hPa) - default Imperial


Example
-------

CMD WXREPORT:

Will report Wind in knots, QNH in inHg, temperature in centigrade at the mark's position

CMD WXREPORT: QFE

Will report wind in knots, QFE in inHg, temperature in centigrade at the mark's position



Delete Spawn Syntax
-------------------

CMD DELETE: [object] [object option[s]]


Delete Spawn Objects
--------------------

- GROUP [requires name of Command Spawned Group in F10 map]
- KIND [requires option CAT and/or TYPE and/or ROLE] [SIDE]
- AREA  [Zone radius defined by RAD option] [CAT, TYPE, ROLE, SIDE]
- NEAREST [CAT, TYPE, ROLE, SIDE]
- ALL


Delete Spawn Options
--------------------

- CAT: [AIR, GROUND] - default ALL
- TYPE: [the spawned object Type] - default ALL
- ROLE: [CAS, SEAD, SAM, AAA, CVY] - default ALL
- SIDE: [RED, BLUE, NEUTRAL, ALL] - default RED
- RAD: [radius from mark in NM] - default 5NM


Example
-------

CMD DELETE: GROUP MIG29#001 

- Will remove the spawned group named MIG29#001

CMD DELETE: KIND TYPE: SA15

- will remove all SA15 groups

CMD DELETE: KIND ROLE: SAM

- will remove all groups with the SAM role

CMD DELETE: AREA TYPE: SA8

- will remove all SA8 groups within 5NM of mark

CMD DELETE: AREA RAD: 1 ROLE: SAM SIDE: ALL

- will remove all groups within 1NM of the mark, with the SAM role, on Red, Blue and Neutral sides 


Cut-n-Paste Command Examples
----------------------------

CMD GSPAWN: SA8, ALERT: RED, SKILL: HIGH

CMD GSPAWN: SA15, ALERT: RED, SKILL: HIGH

CMD ASPAWN: MIG29, NUM: 2, HDG: 90, SKILL: GOOD, ALT: 280, TASK: CAP, SIDE: RED

CMD DELETE: GROUP MIG29A#001