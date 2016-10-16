class ExampleCh8PC extends SimplePC;

var Controller FollowBot;
Var Pawn FollowPawn;
var bool BotSpawned;
var Actor BotTarget;

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

function SpawnBot(Vector SpawnLocation, optional Vector Offset)
{
    SpawnLocation = SpawnLocation + Offset;

    FollowBot = Spawn(class'BotCoverController',,,SpawnLocation); 	
    FollowPawn = Spawn(class'BotCoverPawn',,,SpawnLocation); 
    FollowBot.Possess(FollowPawn,false);
	
    BotCoverController(FollowBot).BotThreat = Pawn;
    BotCoverpawn(FollowPawn).AddDefaultInventory();
    BotCoverPawn(Followpawn).InitialLocation = SpawnLocation;

    FollowPawn.SetPhysics(PHYS_Falling);
}

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

function PlayerTick(float DeltaTime)
{	 
    Super.PlayerTick(DeltaTime);

	
    if (!BotSpawned)
    {
        SpawnBot(Pawn.Location,vect(0,0,500));
        SpawnBot(Pawn.Location,vect(0,0,1000));
        SpawnBot(Pawn.Location,vect(0,0,1500));
        SpawnBot(Pawn.Location,vect(0,0,2000));
        SpawnBot(Pawn.Location,vect(0,0,2500));

        BotSpawned = true;

	JazzPawnDamage(Pawn).InitialLocation = Pawn.Location;
    }
}

defaultproperties
{
    BotSpawned=false
    PickDistance = 10000
}




