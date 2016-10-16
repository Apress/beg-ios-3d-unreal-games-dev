class JazzBullet2 extends Projectile;


simulated function Explode(vector HitLocation, vector HitNormal)
{
    SetPhysics(Phys_Falling);

}

function Init( Vector Direction )
{
    super.Init(Direction);

    RandSpin(90000);
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
}