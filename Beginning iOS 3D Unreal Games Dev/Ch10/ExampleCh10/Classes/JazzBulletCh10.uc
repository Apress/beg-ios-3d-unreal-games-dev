class JazzBulletCh10 extends Projectile;

var SoundCue FireSound;
var bool ImpactSoundPlayed;



simulated singular event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    Other.TakeDamage(33, InstigatorController, HitLocation, -HitNormal, None);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    if (!ImpactSoundPlayed)
    {
        PlaySound(ImpactSound);
        ImpactSoundPlayed = true;
    }

    SetPhysics(Phys_Falling);
}

function Init( Vector Direction )
{
    super.Init(Direction);
    RandSpin(90000);


    PlaySound(SpawnSound);
    PlaySound(FireSound, , , true,,);

}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=Bullet	
        StaticMesh=StaticMesh'Castle_Assets.Meshes.SM_RiverRock_01'
        Scale3D=(X=0.300000,Y=0.30000,Z=0.3000)
    End Object
    Components.Add(Bullet)

    Begin Object Class=ParticleSystemComponent  Name=BulletTrail
        Template=ParticleSystem'Castle_Assets.FX.P_FX_Fire_SubUV_01'
    End Object
    Components.Add(BulletTrail)

    MaxSpeed=+05000.000000
    Speed=+05000.000000


    FireSound = SoundCue'A_Vehicle_Generic.Vehicle.Vehicle_Damage_FireLoop_Cue'
    ImpactSound = SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_HeadshotRoll_Cue'
    SpawnSound = SoundCue'KismetGame_Assets.Sounds.S_WeaponRespawn_01_Cue'

    ImpactSoundPlayed = false

}