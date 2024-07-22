env.info( "[JTF-1] mission_files" )
-- CORE MODULES ADMIN
env.info("[JTF-1] Load Core Modules")


-- TEMPLATES
env.info("[JTF-1] Load Templates")


-- LOCAL MODULES
env.info("[JTF-1] No Local Modules to load.")


-- DATA
env.info("[JTF-1] Load Data")


-- JTF END
env.info("Load Main End")

-- LEGACY SCRIPTS
env.info("[JTF-1] No Legacy Scripts to load")


__JTFLoader.Include( 'lib/Moose.lua' )                      -- library file
__JTFLoader.Include( 'lib/skynet-iads-compiled.lua' )       -- library file
__JTFLoader.Include( 'core/mission_init.lua' )              -- core file
__JTFLoader.Include( 'mission_init_data.lua' )
__JTFLoader.Include( 'core/devcheck.lua' )                  -- core file
--__JTFLoader.Include( 'mission_spawn.lua' )
__JTFLoader.Include( 'core/missionsrs.lua' )                -- core file
__JTFLoader.Include( 'missionsrs_data.lua' )
__JTFLoader.Include( 'core/adminmenu.lua' )                 -- core file
__JTFLoader.Include( 'adminmenu_data.lua' ) 
__JTFLoader.Include( 'core/missiontimer.lua' )              -- core file
__JTFLoader.Include( 'missiontimer_data.lua' )
__JTFLoader.Include( 'core/spawntemplates.lua' )            -- core file
__JTFLoader.Include( 'core/supportaircraft.lua' )           -- core file
__JTFLoader.Include( 'core/supportaircraft_templates.lua' ) -- core file
__JTFLoader.Include( 'supportaircraft_data.lua' )
__JTFLoader.Include( 'core/staticranges.lua' )              -- core file
__JTFLoader.Include( 'staticranges_data.lua' )
__JTFLoader.Include( 'core/missioncap.lua' )                -- core file
__JTFLoader.Include( 'missioncap_data.lua' )
__JTFLoader.Include( 'missionstrike.lua' )         
__JTFLoader.Include( 'missionstrike_data.lua' )
__JTFLoader.Include( 'core/cvncontrol.lua' )
__JTFLoader.Include( 'cvncontrol_data.lua' )
__JTFLoader.Include( 'core/dynamic_deck.lua' )              -- core file
__JTFLoader.Include( 'core/dynamic_deck_templates.lua' )    -- core file
__JTFLoader.Include( 'dynamic_deck_data.lua' )
__JTFLoader.Include( 'core/missiletrainer.lua' )            -- core file
__JTFLoader.Include( 'missiletrainer_data.lua' )
__JTFLoader.Include( 'core/markspawn.lua' )                 -- core file
--__JTFLoader.Include( 'core/markspawn_templates.lua' )       -- core file
__JTFLoader.Include( 'markspawn_data.lua' )
__JTFLoader.Include( 'core/Hercules_Cargo.lua' )            -- core file
__JTFLoader.Include( 'ablesentry.lua' )
__JTFLoader.Include( 'core/mission_end.lua' )               -- core file    