class ExampleCh9PC extends SimplePC;

var float PickDistance;


var int KickAngle;
var int BallCreationDist;
 
var float GameTime;
var bool bGameOVer;

var Actor Ball;

var bool bInitDone;
var bool bInputDelayFinished;

var int GameTimeDelta;

var SoundCue BallHitSound;
var SoundCue BallSpawnSound;


function InputDelayTimer()
{
    bInputDelayFinished = true;
}

function ProcessLookUpInput()
{
    local float TimerDelta;



    if (!bInputDelayFinished)
    return;   


    if (PlayerInput.aLookUp > 0)
    {
        KickAngle++;
    }
    else 
    if (PlayerInput.aLookUp < 0)
    {
        KickAngle--;
    }

    KickAngle = Clamp(KickAngle,0,90);

    TimerDelta = 0.05;
    bInputDelayFinished = false;
    SetTimer(TimerDelta, false, 'InputDelayTimer');    
}

function UpdateRotation( float DeltaTime )
{
    local Rotator	DeltaRot, newRotation, ViewRotation;

    ViewRotation = Rotation;
    if (Pawn!=none)
    {
        Pawn.SetDesiredRotation(ViewRotation);
    }

    // Calculate Delta to be applied on ViewRotation
    DeltaRot.Yaw	= PlayerInput.aTurn;

    //DeltaRot.Pitch	= PlayerInput.aLookUp;
    ProcessLookUpInput();


    ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
    SetRotation(ViewRotation);

    ViewShake( deltaTime );

    NewRotation = ViewRotation;
    NewRotation.Roll = Rotation.Roll;

    if ( Pawn != None )
        Pawn.FaceRotation(NewRotation, deltatime);
}

function GameTimer()
{
    if (bGameOVer) 
    {
        return;
    }

    GameTime = GameTime + GameTimeDelta;	
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    SetTimer(GameTimeDelta, true, 'GameTimer');    
}

function ApplyForceRigidBody(Actor SelectedActor, Vector ImpulseDir,float ImpulseMag, Vector HitLocation)
{
    if (SelectedActor.IsA('KActor'))
    {
        WorldInfo.Game.Broadcast(self,"*** Thrown object " @ SelectedActor @ 
                                 ", ImpulseDir = " @ ImpulseDir @
                                 ", ImpulseMag = " @ ImpulseMag @
                                 ", HitLocation = " @ HitLocation);
        KActor(SelectedActor).ApplyImpulse(ImpulseDir,ImpulseMag, HitLocation);
    }
    else
    if (SelectedActor.IsA('KAsset'))
    {
        WorldInfo.Game.Broadcast(self,"*** Thrown object " @ SelectedActor @ 
                                 ", ImpulseDir = " @ ImpulseDir @
                                 ", ImpulseMag = " @ ImpulseMag @
                                 ", HitLocation = " @ HitLocation);
        KAsset(SelectedActor).SkeletalMeshComponent.AddImpulse(ImpulseDir* ImpulseMag, ,'Bone06');
    }
    else
    {
        WorldInfo.Game.Broadcast(self,"!!!ERROR Selected Actor " @ SelectedActor @ 
                                 " is not a KActor or KAsset, you can not apply an impulse to this object!!!");
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


function CreateNewGameBall()
{
    local vector FrontVec;        
    local vector BallLocation;

    local Vector HitLocation;
    local Vector ImpulseDir; 
    local float ImpulseMag; 

    FrontVec = Normal(Vector(Pawn.Rotation));
    BallLocation = Pawn.Location + (FrontVec * BallCreationDist);

    Ball = Spawn(class'GameBall',,,BallLocation);  
    PlaySound(BallSpawnSound);
 
    ImpulseDir = Vect(0,0,1);
    ImpulseMag = 5;
    HitLocation = Vect(0,0,0);
    ApplyForceRigidBody(Ball, ImpulseDir, ImpulseMag, HitLocation); 
}

function ResetGame()
{
    LoadLevel("ExampleCh9Map");
}

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


    // Variables for physics
    local Vector ImpulseDir; 
    local float ImpulseMag; 
    local float RadKickAngle;


    retval = true;


    if (EventType == ZoneEvent_Touch)
    {
        // If screen touched then pick actor
        PickedActor = PickActor(TouchLocation,HitLocation,HitInfo);
		
        //WorldInfo.Game.Broadcast(self,"PICKED ACTOR = " @ 
        //                         PickedActor @ 
        //                         ", HitLocation = " @ HitLocation @
        //                         ", Zone Touched = " @ Zone @ 
        //                         ", Touch Location = " @ TouchLocation.x @ "," @ TouchLocation.y);


        // Reset Game 
        if (bGameOver)
        {   
            ResetGame();
            return retval;            
        } 


        if (PickedActor.IsA('GameBall'))
        {             
            RadKickAngle = KickAngle * DegToRad; 
         
            ImpulseDir = (Normal(Vector(Pawn.Rotation)) * cos(RadKickAngle)) + (vect(0,0,1) * sin(RadKickAngle)); 
            ImpulseMag = 500;

            ApplyForceRigidBody(PickedActor,ImpulseDir,ImpulseMag,HitLocation);
            PlaySound(BallHitSound);
        }    
        else
        {
            CreateNewGameBall();   
        }
		
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

function bool AllBlocksDestroyed()
{
    local RigidBodyCube TempBlock;
    local bool bAllBlocksDestroyed;


    bAllBlocksDestroyed = true;

    foreach AllActors(class'RigidBodyCube', TempBlock)
    {
        if (!TempBlock.bDestroyed)
        {
            bAllBlocksDestroyed = false;
        } 
    }

    return bAllBlocksDestroyed;
}

function LoadLevel(string LevelName)
{
    local string Command;


    Command = "open " @ LevelName; 		
    ConsoleCommand(Command);
}

function InitKickBallGame()
{  
    bInitDone = true;
}

function PlayerTick(float DeltaTime)
{	 
    Super.PlayerTick(DeltaTime);


    if (!bInitDone)
    {
        InitKickBallGame();
    }   

    if (AllBlocksDestroyed())
    {
        bGameOver = true;
    }
  
    if (bGameOver)
    {
        Pawn.SetHidden(true);
        Pawn.Velocity = vect(0,0,0);
    }


}

defaultproperties
{
    PickDistance = 10000  
    KickAngle = 45

    bInitDone = false;
 
    bInputDelayFinished = true
    BallCreationDist = 500

    GameTime=0
    GameTimeDelta = 1
    bGameOver = false;

    BallHitSound = SoundCue'A_Weapon_BioRifle.Weapon.A_BioRifle_FireImpactFizzle_Cue'
    BallSpawnSound = SoundCue'A_Pickups.Generic.Cue.A_Pickups_Generic_ItemRespawn_Cue'
}


