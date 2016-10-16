class JazzBulletSound extends Projectile;

var SoundCue FireSound;
var bool ImpactSoundPlayed;


simulated singular event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    Other.TakeDamage(33, InstigatorController, HitLocation, -HitNormal, None);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    if (!ImpactSOundPlayed)
    {
        PlaySound(ImpactSound);
        ImpactSoundPlayed = true;
    }
}

function Init( Vector Direction )
{
    local vector NewDir;

    NewDir = Normal(Vector(InstigatorController.Pawn.Rotation));
    Velocity = Speed * NewDir;	

    PlaySound(SpawnSound);
    PlaySound(FireSound, , , true,,);
}

defaultproperties
{	
    Begin Object Class=StaticMeshComponent Name=Bullet
        StaticMesh=StaticMesh'EngineMeshes.Sphere'	
        Scale3D=(X=0.050000,Y=0.050000,Z=0.05000)
    End Object
    Components.Add(Bullet)
	
    Begin Object Class=ParticleSystemComponent  Name=BulletTrail
        Template=ParticleSystem'Castle_Assets.FX.P_FX_Fire_SubUV_01'
    End Object
    Components.Add(BulletTrail)
	
    MaxSpeed=+05000.000000
    Speed=+05000.000000


    FireSound = SoundCue'A_Vehicle_Generic.Vehicle.Vehicle_Damage_FireLoop_Cue'
    ImpactSound = SoundCue'KismetGame_Assets.Sounds.S_BulletImpact_01_Cue'
    SpawnSound = SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_UDamage_SpawnCue'

    ImpactSoundPlayed = false
}


