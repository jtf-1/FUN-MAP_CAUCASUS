env.info( "[JTF-1] ablesentry" )
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- BEGIN ABLE SENTRY
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- XXX ## Able Sentry Convoy
-- Convoy is spawned at mission start and will advance North->South on highway B3 towards Tbilisi
-- On reaching Mtskehta it will respawn at the start of the route.

ABLESENTRY = {}
ABLESENTRY.traceTitle = "[JTF-1 ABLESENTRY] "
ABLESENTRY.menu = {}
ABLESENTRY.zoneName = "ConvoyObjectiveAbleSentry"

function ABLESENTRY:Start()
    _msg = self.traceTitle .. "Start()"
    BASE:T(_msg)
	
    self.zone = ZONE:FindByName( self.zoneName ) 

	self.spawn = SPAWN:New( "CONVOY_Hard_Able Sentry" )
		:InitLimit( 20, 0 )
		:OnSpawnGroup(
			function ( SpawnGroup )
				-- SpawnIndex_Convoy_AbleSentry = spawn:GetSpawnIndexFromGroup( SpawnGroup )
				checkConvoyAbleSentry = SCHEDULER:New( SpawnGroup, 
				  function()
					  if SpawnGroup:IsPartlyInZone( ABLESENTRY.zone ) then
						  ABLESENTRY:Reset()
					  end
				  end,
				  {}, 0, 60
			  	)
				mapMarkConvoyAbleSentry = SCHEDULER:New( SpawnGroup, 
					function()
						if SpawnGroup.mapmarkid then
							COORDINATE:RemoveMark( SpawnGroup.mapmarkid ) -- spawn.mapmarkid
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
	
	self.menu = MENU_MISSION_COMMAND:New( "Able Sentry Reset",nil, self.Reset, self )
	
end

function ABLESENTRY:Reset()
    _msg = self.traceTitle .. "Reset()"
    BASE:T(_msg)

    self.spawn:ReSpawn() -- SpawnIndex_Convoy_AbleSentry
end -- function

ABLESENTRY:Start()
