class JazzWeaponSound extends Weapon;

defaultproperties
{
    Begin Object Class=SkeletalMeshComponent Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'KismetGame_Assets.Anims.SK_JazzGun'
    End Object
    Mesh=FirstPersonMesh
    Components.Add(FirstPersonMesh);

    Begin Object Class=SkeletalMeshComponent Name=PickupMesh
        SkeletalMesh=SkeletalMesh'KismetGame_Assets.Anims.SK_JazzGun'
    End Object
    DroppedPickupMesh=PickupMesh
    PickupFactoryMesh=PickupMesh

    WeaponFireTypes(0)=EWFT_Projectile
    WeaponFireTypes(1)=EWFT_NONE
  
    WeaponProjectiles(0)=class'JazzBulletSound'  
    WeaponProjectiles(1)=class'JazzBulletSound'   
	
    FiringStatesArray(0)=WeaponFiring 
    FireInterval(0)=0.25
    Spread(0)=0
}