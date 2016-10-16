class ExampleCh11PC extends SimplePC;

var Controller AllyBot;
Var Pawn AllyPawn;

var Controller GuardBot;
Var Pawn GuardPawn;

var bool BotSpawned;
var Actor BotTarget;

var float PickDistance;

var bool bBotCommandStateActive;

var int ObjectiveHealth;
var bool bGameOver;


function FindObjectiveHealth()
{
    local Generator TempGenerator;

    foreach AllActors(class'Generator', TempGenerator)
    {
        ObjectiveHealth = TempGenerator.Health;            
    }
}

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

function SetBotMarkerGraphic(vector Loc, optional vector offset)
{
    Loc = Loc + offset;

    If (BotTarget == None)
    {
        WorldInfo.Game.Broadcast(None,"Creating New Move Marker!!!!!!!!"); 
        BotTarget = Spawn(class'BotMarker2',,,Loc); 
    }
    else
    { 		
        BotTarget.SetLocation(Loc);	
    }
}

reliable server function ExecuteBotMoveCommand(Vector HitLocation)
{
    // 1. Set Marker	
    Hitlocation.z += 50; // Add offset to help bot navigate to point
    SetBotMarkerGraphic(Hitlocation);
		
    // 2. Send Move Command to bot along with target location 
    BotAllyController(AllyBot).SetCommand(Move, BotTarget);
}

function ExecuteBotAttackCommand(Actor Target)
{
    // 1. Set Marker	
    SetBotMarkerGraphic(Target.Location, vect(0,0,200));
		
    // 2. Send Attack Command to bot along with target location
    BotAllyController(AllyBot).SetCommand(Attack, Target);
}

function SelectBotAllyGraphic(vector Loc)
{	
    Loc.z += 200; // Add offset to help bot navigate to point
   
    SetBotMarkerGraphic(Loc);
}

function Actor FindSpawnPad(int PadNumber)
{
    local BotSpawnPad TempSpawnPad;
    local Actor ReturnSpawnPad;

    ReturnSpawnPad = None;
    foreach AllActors(class'BotSpawnPad', TempSpawnPad)
    {
        if(TempSpawnPad.PadNumber == PadNumber)
        {
            ReturnSpawnPad = TempSpawnPad; 
        }            
    }

    return ReturnSpawnPad;   
}

function SpawnGuardBot(Vector SpawnLocation,optional Vector Offset)
{
    SpawnLocation = SpawnLocation + Offset;

    GuardBot = Spawn(class'BotControllerGuard',,,SpawnLocation); 	
    GuardPawn = Spawn(class'GuardPawn',,,SpawnLocation); 
    GuardBot.Possess(GuardPawn,false);

    GuardPawn(GuardPawn).AddDefaultInventory();
    GuardPawn(GuardPawn).InitialLocation = SpawnLocation;

    GuardPawn.SetPhysics(PHYS_Falling);
}

function CreateNewGuardBot()
{
    local Actor TempPad;
    
    TempPad = FindSpawnPad(0);
    if (TempPad != None)
    {
        SpawnGuardBot(TempPad.Location);
    }

}

function SpawnAllyBot(Vector SpawnLocation, optional Vector Offset)
{
    SpawnLocation = SpawnLocation + Offset;

    AllyBot = Spawn(class'BotAllyController',,,SpawnLocation); 	
    AllyPawn = Spawn(class'BotPawn',,,SpawnLocation); 
    AllyBot.Possess(AllyPawn,false);
	
    BotAllyController(AllyBot).SetCommand(Follow, Pawn);
    BotAllyController(AllyBot).BotOwner = Pawn;
    
    BotPawn(AllyPawn).AddDefaultInventory();
    BotPawn(AllyPawn).InitialLocation = SpawnLocation;

    AllyPawn.SetPhysics(PHYS_Falling);
}

function bool IsActorAllyBot(Actor TestBot)
{
    local bool bretval;

    bretval = TestBot.IsA('BotPawn');
    return bretval;
}

function bool IsActorGuardBot(Actor TestBot)
{
    local bool bretval;

    bretval = TestBot.IsA('GuardPawn');
    return bretval;
}

function ProcessTouch(Actor TouchedActor, vector HitLocation)
{
    if (bBotCommandStateActive)
    {
        if (IsActorGuardBot(TouchedActor))
        {
            ExecuteBotAttackCommand(TouchedActor);
            bBotCommandStateActive = false;
        }
        else 
        if (!IsActorAllyBot(TouchedActor))
        {
            ExecuteBotMoveCommand(HitLocation);
            bBotCommandStateActive = false;
        }
    }
    else
    {
        if (IsActorAllyBot(TouchedActor))
        {
            SelectBotAllyGraphic(TouchedActor.Location);
            bBotCommandStateActive = true;
        }
        else
        {
            // Start Firing pawn's weapon
	    StartFire(0);            
        }
    }
}

function bool SwipeZoneCallback(MobileInputZone Zone, 
			        float DeltaTime, 
			        int Handle,
			        EZoneTouchEvent EventType, 
			        Vector2D TouchLocation)
{	
    local bool retval;

    local Actor TempActor;
    local Vector HitLocation;
    local TraceHitInfo HitInfo;
    
    retval = true;


    if (EventType == ZoneEvent_Touch)
    {
        //WorldInfo.Game.Broadcast(self,"You touched the screen at = " @ 
        //                             TouchLocation.x @ " , " @ TouchLocation.y @
        //                              ", Zone Touched = " @ Zone);

        // Code for Setting Bot WayPoint
        TempActor = PickActor(TouchLocation, HitLocation, HitInfo);
        ProcessTouch(TempActor, HitLocation);
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
    local vector AllyBotPos;
	 
    Super.PlayerTick(DeltaTime);

	
    if (!BotSpawned)
    {
        AllyBotPos = Pawn.Location + Normal(Vector(Pawn.Rotation)) * 100;        
        SpawnAllyBot(AllyBotPos,vect(0,0,500));
        BotSpawned = true;
	JazzPawnDamage(Pawn).InitialLocation = Pawn.Location;
        CreateNewGuardBot();
    }

    FindObjectiveHealth();
    if (ObjectiveHealth <= 0)
    {
        bGameOver = true;
    }
}

defaultproperties
{
    BotSpawned=false
    PickDistance = 10000
    bBotCommandStateActive = false
    bGameOver = false
}




