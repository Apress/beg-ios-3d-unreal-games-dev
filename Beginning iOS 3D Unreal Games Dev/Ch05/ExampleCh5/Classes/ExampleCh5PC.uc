class ExampleCh5PC extends SimplePC;

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

reliable server function ExecuteBotMoveCommand(Vector HitLocation)
{
    // 1. Set AttackMove Target Marker	
    Hitlocation.z += 50; // Add offset to help bot navigate to point
    If (BotTarget == None)
    {
        WorldInfo.Game.Broadcast(None,"Creating New Move Marker!!!!!!!!"); 
        BotTarget = Spawn(class'BotMarker',,,HitLocation); 
    }
    else
    { 		
        BotTarget.SetLocation(HitLocation);	
    }
		
    // 2. Send Move Command to bot along with target location
    BotController(FollowBot).CurrentGoal = BotTarget; 
    BotController(FollowBot).FollowDistance = 75; 
}



function SpawnBot(Vector SpawnLocation)
{
    SpawnLocation.z = SpawnLocation.z + 500;
    //WorldInfo.Game.Broadcast(self,"SPAWNING A BOT AT LOCATION " @ Spawnlocation);

    FollowBot = Spawn(class'BotController',,,SpawnLocation); 	
    FollowPawn = Spawn(class'BotPawn',,,SpawnLocation); 
    FollowBot.Possess(FollowPawn,false);
	
    BotController(FollowBot).CurrentGoal = Pawn;
    Botpawn(FollowPawn).AddDefaultInventory();
    BotPawn(Followpawn).InitialLocation = SpawnLocation;

    FollowPawn.SetPhysics(PHYS_Falling);
    
    BotSpawned = true;
}

function bool SwipeZoneCallback(MobileInputZone Zone, 
			        float DeltaTime, 
			        int Handle,
			        EZoneTouchEvent EventType, 
			        Vector2D TouchLocation)
{	
    local bool retval;

    local Vector HitLocation;
    local TraceHitInfo HitInfo;
 
    retval = true;


    if (EventType == ZoneEvent_Touch)
    {
        WorldInfo.Game.Broadcast(self,"You touched the screen at = " @ 
                                       TouchLocation.x @ " , " @ TouchLocation.y @
                                       ", Zone Touched = " @ Zone);


	// Start Firing pawn's weapon
	StartFire(0);
       
        // Start Firing the Bot's Weapon
        FollowBot.Pawn.StartFire(0);

        // Code for Setting Bot WayPoint
        PickActor(TouchLocation, HitLocation, HitInfo);
        ExecuteBotMoveCommand(HitLocation);
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

        // Stop Firing the Bot's weapon
        FollowBot.Pawn.StopFire(0);
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
        SpawnBot(Pawn.Location);
        BotSpawned = true;

	JazzPawnDamage(Pawn).InitialLocation = Pawn.Location;

    }
}

defaultproperties
{
    BotSpawned=false
    PickDistance = 10000
}




