class ExampleCh10PC extends SimplePC;


var Controller EnemyBot;
Var Pawn EnemyPawn;

var bool BotSpawned;
var Actor BotTarget;

var bool bGameOver;

var array<vector> SpawnPadLocations;



function ResetGame()
{
    ExampleCh10Game(WorldInfo.Game).bGameOver = false;
    ExampleCh10Game(WorldInfo.Game).Score = 0;
    Pawn.Health = 100;

    Pawn.SetHidden(false);
    Pawn.Weapon.SetHidden(false);
    Pawn.SetLocation(JazzCh10Pawn(Pawn).InitialLocation);

}

function Actor FindSpawnPad(int PadNumber)
{
    local BotSpawnPad TempSpawnPad;
    local Actor ReturnSpawnPad;

    ReturnSpawnPad = None;
    foreach AllActors(class'BotSpawnPad', TempSpawnPad)
    {
        SpawnPadLocations.Additem(TempSpawnPad.Location);
        if(TempSpawnPad.PadNumber == PadNumber)
        {
            ReturnSpawnPad = TempSpawnPad; 
        }            
    }

    return ReturnSpawnPad;   
}

function SpawnBot(Vector SpawnLocation, optional Vector Offset)
{
    SpawnLocation = SpawnLocation + Offset;

    EnemyBot = Spawn(class'BotAttackCoverController',,,SpawnLocation); 	
    EnemyPawn = Spawn(class'BotPawnCh10',,,SpawnLocation); 
    EnemyBot.Possess(EnemyPawn,false);
	
    BotAttackCoverController(EnemyBot).BotThreat = Pawn;
    BotPawnCh10(EnemyPawn).AddDefaultInventory();
    BotPawnCh10(EnemyPawn).InitialLocation = SpawnLocation;
 
    BotPawnCh10(EnemyPawn).SpawnPadLocations = SpawnPadLocations;


    EnemyPawn.SetPhysics(PHYS_Falling);
}

function SpawnBotOnRandomPad(vector AlternateLocation, vector offset)
{
    local int RandomPadNumber;
    local Actor SpawnPad;
    local int MaxPads;

    MaxPads = ExampleCh10Game(WorldInfo.Game).MaxSpawnPads;
    RandomPadNumber = Rand(MaxPads);// Number from 0 to Max-1.

    WorldInfo.Game.Broadcast(self,"RANDOMPADNUMBER = " @ RandomPadNumber);

    SpawnPad = FindSpawnPad(RandomPadNumber);
    if (SpawnPad != None)
    {
        SpawnBot(SpawnPad.Location, offset);
    }    
    else
    {
        SpawnBot(AlternateLocation, Offset);           
    }
}

function bool SwipeZoneCallback(MobileInputZone Zone, 
			        float DeltaTime, 
			        int Handle,
			        EZoneTouchEvent EventType, 
			        Vector2D TouchLocation)
{	
    local 	bool 		retval;
	
 
    retval = true;


    if (EventType == ZoneEvent_Touch)
    {
        //WorldInfo.Game.Broadcast(self,"You touched the screen at = " @ 
        //                               TouchLocation.x @ " , " @ TouchLocation.y @
        //                               ", Zone Touched = " @ Zone);
	

        // Reset Game 
        if (ExampleCh10Game(WorldInfo.Game).bGameOver)
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

function PlaceWeapon()
{
    // First Person 	
    local vector WeaponLocation;
    local Rotator WeaponRotation,TempRot;
    local Weapon TestW;
    local vector WeaponAimVect;
	

    WeaponRotation.yaw = -16000; // 90 Degrees turn = OFFSET	


    TempRot = Pawn.GetBaseAimRotation();
    WeaponRotation.pitch = TempRot.roll;
    WeaponRotation.yaw   += TempRot.yaw; 
    WeaponRotation.roll  -= TempRot.pitch; // Swith due to weapon local axes orientation
	
    WeaponAimVect = Normal(Vector(TempRot));
    WeaponLocation = Pawn.Location + (40 * WeaponAimVect) + vect(0,0,30);

    TestW = Pawn.Weapon; //Pawn.InvManager.GetBestWeapon();
	
    if (TestW != None)
    {
        TestW.SetLocation(WeaponLocation); 
        TestW.SetRotation(WeaponRotation);
    }
    else
    {
        WorldInfo.Game.Broadcast(self,"Player has no weapon!!!!!");
    }

}

function PlayerTick(float DeltaTime)
{
    Super.PlayerTick(DeltaTime);
	
    PlaceWeapon();


    if (!BotSpawned)
    {
        SpawnBotOnRandomPad(Pawn.Location, vect(0,0,500));
        BotSpawned = true;
	JazzCh10Pawn(Pawn).InitialLocation = Pawn.Location;
    }

    if (Pawn.Health <= 0)
    {
        ExampleCh10Game(WorldInfo.Game).bGameOver = true;
    }

    if (ExampleCh10Game(WorldInfo.Game).bGameOver)
    {
        Pawn.Health = 0;
        StopFire(0);
        Pawn.SetHidden(true);
        Pawn.Weapon.SetHidden(true);
        Pawn.Velocity = vect(0,0,0);
    }
}

defaultproperties
{
    BotSpawned = false;
}




