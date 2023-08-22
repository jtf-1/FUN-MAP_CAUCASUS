env.info( "[JTF-1] ablesentry" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN ABLE SENTRY
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- XXX ## Able Sentry Convoy
-- Convoy is spawned at mission start and will advance North->South on highway B3 towards Tbilisi
-- On reaching Mtskehta it will respawn at the start of the route.

ABLESENTRY = {}

function ABLESENTRY:Start()
    _msg = "[JTF-1 ABLESENTRY] Start()"
    BASE:T(_msg)
	
    ABLESENTRY.Zone_ConvoyObjectiveAbleSentry = ZONE:FindByName( "ConvoyObjectiveAbleSentry" ) 

	ABLESENTRY.Spawn_Convoy_AbleSentry = SPAWN:New( "CONVOY_Hard_Able Sentry" )
		:InitLimit( 20, 0 )
		:OnSpawnGroup(
			function ( SpawnGroup )
				-- SpawnIndex_Convoy_AbleSentry = Spawn_Convoy_AbleSentry:GetSpawnIndexFromGroup( SpawnGroup )
				checkConvoyAbleSentry = SCHEDULER:New( SpawnGroup, 
				  function()
					  if SpawnGroup:IsPartlyInZone( ABLESENTRY.Zone_ConvoyObjectiveAbleSentry ) then
						  ABLESENTRY:Reset()
					  end
				  end,
				  {}, 0, 60
			  	)
				mapMarkConvoyAbleSentry = SCHEDULER:New( SpawnGroup, 
					function()
						if SpawnGroup.mapmarkid then
							COORDINATE:RemoveMark( SpawnGroup.mapmarkid ) -- Spawn_Convoy_AbleSentry.mapmarkid
						end    
						local coordsAbleSentry = SpawnGroup:GetCoordinate()
						local labelAbleSentry = "Able Sentry Convoy\nMost recent reported postion\n" .. coordsAbleSentry:ToStringLLDMS(_SETTINGS:SetLL_Accuracy(0)) .. "\n" .. coordsAbleSentry:ToStringLLDDM(_SETTINGS:SetLL_Accuracy(3))
						local mapMarkAbleSentry = coordsAbleSentry:MarkToAll(labelAbleSentry, true) -- add mark to map
						SpawnGroup.mapmarkid = mapMarkAbleSentry -- add mark ID to SPAWN object 
					end,
					{}, 0, 180
		  		)
			end
			)
		:SpawnScheduled( 60 , .1 )
	
	local cmdConvoyAbleSentryReset = MENU_COALITION_COMMAND:New( coalition.side.BLUE,"Able Sentry Reset",MenuConvoyAttack, ABLESENTRY.Reset )
	
end

function ABLESENTRY:Reset()
    _msg = "[JTF-1 ABLESENTRY] Reset()"
    BASE:T(_msg)

    ABLESENTRY.Spawn_Convoy_AbleSentry:ReSpawn() -- SpawnIndex_Convoy_AbleSentry
end -- function

ABLESENTRY:Start()
