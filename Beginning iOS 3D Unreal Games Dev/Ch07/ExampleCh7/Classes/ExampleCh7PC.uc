class ExampleCh7PC extends SimplePC;

var Controller FollowBot;
Var Pawn FollowPawn;
var bool BotSpawned;


var bool GameOver;
var int Score;


function vector FindSpawnPadLocation()
{
    local SpawnPad TempSpawnPad;
    local vector TempLocation;
	
    foreach AllActors (class 'SpawnPad', TempSpawnPad )
    {
         TempLocation = TempSpawnPad.Location;		 
    }

    return TempLocation;
}

function SpawnBot(Vector SpawnLocation)
{
    SpawnLocation.z = SpawnLocation.z + 500;
    WorldInfo.Game.Broadcast(self,"SPAWNING A BOT AT LOCATION " @ Spawnlocation);

    FollowBot = Spawn(class'BotControllerAttack',,,SpawnLocation); 	
    FollowPawn = Spawn(class'BotPawn2',,,SpawnLocation); 
    FollowBot.Possess(FollowPawn,false);
	
    BotControllerAttack(FollowBot).CurrentGoal = Pawn;
    Botpawn2(FollowPawn).AddDefaultInventory();
    BotPawn2(Followpawn).InitialLocation = SpawnLocation;

    FollowPawn.SetPhysics(PHYS_Falling);
    
    BotSpawned = true;
}

function ResetGame()
{
    GameoVer = false;
    Jazz3Pawn(Pawn).Lives = 3;
    Score = 0;
    Pawn.Health = 100;

    Pawn.SetHidden(false);
    Pawn.Weapon.SetHidden(false);
    Pawn.SetLocation(Jazz3Pawn(Pawn).InitialLocation);
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

        // Reset Game 
        if (GameOver)
        {   
            ResetGame();            
        } 
        else
        {
            // Start Firing pawn's weapon
	    StartFire(0);
        }

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
        SpawnBot(FindSpawnPadLocation());
        BotSpawned = true;

	Jazz3Pawn(Pawn).InitialLocation = Pawn.Location;
        Jazz3Pawn(Pawn).Lives = 3;
    }

    If (Jazz3Pawn(Pawn).Lives <= 0)
    {
        GameoVer = true;

        // Disable Player Input 
	//MPI.bDisableTouchInput = true;
    }

    if (GameOver)
    {
        Pawn.SetHidden(true);
        Pawn.Weapon.SetHidden(true);
        Pawn.Velocity = vect(0,0,0);
    }
}

defaultproperties
{
    GameOver = false;
    BotSpawned = false;
}




