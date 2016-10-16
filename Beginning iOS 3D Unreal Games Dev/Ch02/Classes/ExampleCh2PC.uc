class ExampleCh2PC extends SimplePC;


var float PickDistance;


function Actor PickActor(Vector2D PickLocation, out Vector HitLocation, out TraceHitInfo HitInfo)
{
    local Vector TouchOrigin, TouchDir;
    local Vector HitNormal;
    local Actor  PickedActor;
    local vector Extent;

    //Transform absolute screen coordinates to relative coordinates
    PickLocation.X = PickLocation.X / ViewportSize.X;
    PickLocation.Y = PickLocation.Y / ViewportSize.Y;
   
    //Transform to world coordinates to get pick ray
    LocalPlayer(Player).Deproject(PickLocation, TouchOrigin, TouchDir);
   
    //Perform trace to find touched actor
    Extent = vect(0,0,0);
    PickedActor = Trace(HitLocation, 
                        HitNormal, 
                        TouchOrigin + (TouchDir * PickDistance), 
                        TouchOrigin, 
                        True, 
                        Extent, 
                        HitInfo);

   
    //Return the touched actor for good measure
    return PickedActor;
}


// OnProcessInputDelegate [Zone] [DeltaTime] [Handle] [EventType] [TouchLocation] - 
// Called when any input event occurs within the zone allowing completely custom input handling for any 
// zone or for input in a zone to be handled by other classes. Return TRUE to acknowledge the input as 
// being handled. Returning FALSE will pass the input on, processing it in the ProcessTouch() function 
// according to the type of zone.
// 
//	Zone - A reference to the Zone the delegate belongs to.
//	DeltaTime - The amount of time since the last input event for the zone.
//	Handle - The unique identifier of the touch responsible for the input event.
//	EventType - The EZoneTouchEvent type of the input event.
//	TouchLocation - The Vector2D specifying the horizontal and vertical location of the touch event in pixel screen coordinates.

function bool SwipeZoneCallback(MobileInputZone Zone, 
			        float DeltaTime, 
			        int Handle,
			        EZoneTouchEvent EventType, 
			        Vector2D TouchLocation)
{	
    local bool retval;
	
    local Actor PickedActor;
    local Vector HitLocation;
    local TraceHitInfo HitInfo;


    retval = true;


    if (EventType == ZoneEvent_Touch)
    {
        // If screen touched then pick actor
        PickedActor = PickActor(TouchLocation,HitLocation,HitInfo);
		
        WorldInfo.Game.Broadcast(self,"PICKED ACTOR = " @ 
                                 PickedActor @ 
                                 ", HitLocation = " @ HitLocation @
                                 ", Zone Touched = " @ Zone);
    } 
    else
    if(EventType == ZoneEvent_Update)
    {	

    }		
    else
    if (EventType == ZoneEvent_UnTouch)
    {	
	
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
    PickDistance = 10000;
}




