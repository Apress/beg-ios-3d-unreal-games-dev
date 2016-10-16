class Generator extends Actor
placeable;

var ParticleSystem ExplosionTemplate;
var ParticleSystemComponent Explosion;
var SoundCue HitSound;

var int Health;
var Pawn Guard;


event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    //WorldInfo.Game.Broadcast(self,"Generator Has Been Damaged by " @ InstigatedBy);	
   
    PlaySound(HitSound);
    Explosion = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionTemplate, HitLocation); 
    BotControllerGuard(Guard.Controller).Threat = InstigatedBy.Pawn; 

    if (InstigatedBy.IsA('ExampleCh11PC'))
    {
        Health = Health - Damage;
    }
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    WorldInfo.Game.Broadcast(self,"Generator Has Been Touched by " @ Other );	
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'Pickups.Health_Large.Mesh.S_Pickups_Health_Large_Keg'
        Scale3D=(X=5.0000,Y=5.0000,Z=5.000)
        CollideActors=true
        BlockActors=true
        //bAllowApproximateOcclusion=True
        //bForceDirectLightMap=True
        //bCastDynamicShadow=False
        //LightingChannels=(Dynamic=False,Static=True)
    End Object
    Components.Add(StaticMeshComponent0)
 	
    Begin Object Class=CylinderComponent NAME=CollisionCylinder
        CollideActors=true
        BlockActors=true
        CollisionRadius=+0140.000000
        CollisionHeight=+0140.000000
    End Object
    Components.Add(CollisionCylinder)
    CollisionComponent = CollisionCylinder
  
    bCollideActors=true
    bBlockActors = true

    HitSound = SoundCue'A_Gameplay.Gameplay.A_Gameplay_ArmorHitCue'
    ExplosionTemplate = ParticleSystem'Castle_Assets.FX.P_FX_Fire_SubUV_01'

    Guard = None;
    Health = 300;
			
}




