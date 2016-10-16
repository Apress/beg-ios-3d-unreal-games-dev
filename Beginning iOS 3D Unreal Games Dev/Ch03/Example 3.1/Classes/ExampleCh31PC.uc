class ExampleCh31PC extends SimplePC;


function bool SwipeZoneCallback(MobileInputZone Zone, 
			        float DeltaTime, 
			        int Handle,
			        EZoneTouchEvent EventType, 
			        Vector2D TouchLocation)
{	
    local bool retval;
	
 
    retval = true;


    if (EventType == ZoneEvent_Touch)
    {
        WorldInfo.Game.Broadcast(self,"You touched the screen at = " @ 
                                       TouchLocation.x @ " , " @ TouchLocation.y @
                                       ", Zone Touched = " @ Zone);


	// Start Firing pawn's weapon
	StartFire(0);
    }
    else
    if(EventType == ZoneEvent_Update)
    {	

    }		
    else
    if (EventType == ZoneEvent_UnTouch)
    {	
	// Stop Firing Pawn's weapon
	StopFire(0);
    }

	
    return retval;
}

function SetupZones()
{
    Super.SetupZones();

    // If we have a game class, configure the zones
    if (MPI != None && WorldInfo.GRI.GameClass != none) 
    {
        LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);

        if (FreeLookZone != none)
        {
            FreeLookZone.OnProcessInputDelegate = SwipeZoneCallback;

        }	
    }
}


defaultproperties
{
	
}




