class Bonus1 extends Actor
 placeable;

var() float Value;
var SoundCue PickupSound;
var int SoundCueLength;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{    
    WorldInfo.Game.Broadcast(self,"Health Bonus1 Has Been Touched by " @ Other @ ", Bonus Value = " @ Value);


    if (Other.IsA('JazzCh10Pawn'))
    {
        JazzCh10Pawn(Other).AddHealthBonus(Value);  
        PlaySound(PickUpSound); 
        destroy(); 
    }
    else 
    if (Other.IsA('BotPawnCh10'))
    {
        BotPawnCh10(Other).AddHealthBonus(Value); 
        PlaySound(PickUpSound);   
        destroy(); 
    }     
}

function Tick(FLOAT DeltaTime)
{
    local Rotator TempRot;
 
    
    //WorldInfo.Game.Broadcast(self,"TICKING BONUS1 - DeltaTime = " @ DeltaTime);
      
    TempRot = Rotation;
    TempRot.yaw = Rotation.yaw + (15000 * DeltaTime);
    SetRotation(TempRot);
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=HealthMesh
        //StaticMesh=StaticMesh'EngineMeshes.Sphere'
        StaticMesh=StaticMesh'Pickups.Health_Large.Mesh.S_Pickups_Health_Large_Keg'

        //Scale3D=(X=0.250000,Y=0.250000,Z=0.25000)
    End Object
    Components.Add(HealthMesh)

	
    Begin Object Class=CylinderComponent NAME=CollisionCylinder
        CollideActors=true
        CollisionRadius=+0040.000000
        CollisionHeight=+0040.000000
    End Object
    CollisionComponent=CollisionCylinder
    Components.Add(CollisionCylinder)

	
    bCollideActors=true
    bEdShouldSnap=True
  
    value = 25
    PickupSound = SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Super_Cue'
    SoundCueLength = 3   
}