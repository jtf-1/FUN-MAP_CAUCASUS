::
:: Copy Mission Files from dynmic to static
::

@ECHO OFF
SETLOCAL ENABLEEXTENSIONS

:: name of this file for message output
SET me=%~n0
:: folder in which this file is being executed
SET parent=%~dp0
:: log file to output build results
SET log=%parent%logs\%me%.log

SET destination_path=%parent%static\
ECHO Static file output path:    %destination_path%

:: path to dynamic files to be concatenated
SET source_path=%parent%dynamic\
ECHO Dynamic file source path:   %source_filepath%
SET source_path_core=%parent%dynamic\core\
ECHO Core file source path:   %source_filepath_core%

ECHO.

:: Initialise build file & log
ECHO STATIC FILE COPY STARTED: %DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%T%TIME% > %log%
ECHO. >> %log%

ECHO.

:: Copy dynamic files
copy %source_path_core%mission_init.lua %destination_path%mission_init.lua
copy %source_path_core%devcheck.lua %destination_path%devcheck.lua
copy %source_path_core%missionsrs.lua %destination_path%missionsrs.lua
copy %source_path%missionsrs_data.lua %destination_path%missionsrs_data.lua
copy %source_path_core%adminmenu.lua %destination_path%adminmenu.lua
copy %source_path_core%missiontimer.lua %destination_path%missiontimer.lua
copy %source_path%missiontimer_data.lua %destination_path%missiontimer_data.lua
copy %source_path_core%supportaircraft.lua %destination_path%supportaircraft.lua
copy %source_path%supportaircraft_data.lua %destination_path%supportaircraft_data.lua
copy %source_path_core%staticranges.lua %destination_path%staticranges.lua
copy %source_path%staticranges_data.lua %destination_path%staticranges_data.lua
copy %source_path_core%missioncap.lua %destination_path%missioncap.lua
copy %source_path%missioncap_data.lua %destination_path%missioncap_data.lua
copy %source_path%missionstrike.lua %destination_path%missionstrike.lua
copy %source_path%missionstrike_data.lua %destination_path%missionstrike_data.lua
copy %source_path%ablesentry.lua %destination_path%ablesentry.lua
copy %source_path%recoverytanker.lua %destination_path%recoverytanker.lua
copy %source_path%dynamic_deck_population.lua %destination_path%dynamic_deck_population.lua
copy %source_path%dynamic_deck_templates.lua %destination_path%dynamic_deck_templates.lua
copy %source_path%missiletrainer.lua %destination_path%missiletrainer.lua
copy %source_path%markspawn.lua %destination_path%markspawn.lua
copy %source_path_core%Hercules_Cargo.lua %destination_path%Hercules_Cargo.lua
copy %source_path_core%mission_end.lua %destination_path%mission_end.lua

ECHO.

:: Close log
ECHO. >> %log%
ECHO STATIC FILE COPY FINISHED: %DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%T%TIME% >> %log%
ECHO Copy complete.

PAUSE
EXIT /B %ERRORLEVEL%