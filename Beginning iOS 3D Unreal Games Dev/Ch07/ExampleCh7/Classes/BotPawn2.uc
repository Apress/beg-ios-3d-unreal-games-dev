class BotPawn2 extends SimplePawn;

var Inventory MainGun;
var SoundCue JazzHitSound;
var vector InitialLocation;

var int KillValue;


event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    PlaySound(JazzHitSound); 
    Health = Health - Damage;
    WorldInfo.Game.Broadcast(self,self @ " Has Taken Damage IN TAKEDAMAGE, HEALTH = " @ Health);	
   
    if (Health <= 0)
    {
        SetLocation(InitialLocation);
        SetPhysics(PHYS_Falling);
        Health = 100;

        // Process Kill
        if (PlayerController(InstigatedBy) != None)
        {
            // Add kill to Player's Score
            ExampleCh7PC(InstigatedBy).Score += KillValue; 
        }
    }

  
}

function AddGunToSocket(Name SocketName)
{
    local Vector SocketLocation;
    local Rotator SocketRotation;

    if (Mesh != None)
    {
        if (Mesh.GetSocketByName(SocketName) != None)
        {
            Mesh.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SocketRotation);
            MainGun.SetRotation(SocketRotation);
            MainGun.SetBase(Self,, Mesh, SocketName);
        }
        else
        {
            WorldInfo.Game.Broadcast(self,"!!!!!!SOCKET NAME NOT FOUND!!!!!");
        }
    }
    else
    {
        WorldInfo.Game.Broadcast(self,"!!!!!!MESH NOT FOUND!!!!!");
    }

}

function AddDefaultInventory()
{	
    MainGun = InvManager.CreateInventory(class'JazzWeapon2Damage');
    MainGun.SetHidden(false);
    AddGunToSocket('Weapon_R');
    Weapon(MainGun).FireOffset = vect(0,13,-70);
}

defaultproperties
{
    // Jazz Mesh Object	
    Begin Object Class=SkeletalMeshComponent Name=JazzMesh     
        SkeletalMesh=SkeletalMesh'KismetGame_Assets.Anims.SK_Jazz'
        AnimSets(0)=AnimSet'KismetGame_Assets.Anims.SK_Jazz_Anims'
        AnimTreeTemplate=AnimTree'KismetGame_Assets.Anims.Jazz_AnimTree'
        BlockRigidBody=true
        CollideActors=true
    End Object
    Mesh = JazzMesh;
    Components.Add(JazzMesh);
	
    // Collision Component for This actor	
    Begin Object Class=CylinderComponent NAME=CollisionCylinder2
        CollideActors=true
        CollisionRadius=+25.000000
        //CollisionHeight=+45.000000 // Path Nodes
        CollisionHeight=+60.000000 //Nav Mesh
    End Object
    CollisionComponent=CollisionCylinder2
    CylinderComponent=CollisionCylinder2
    Components.Add(CollisionCylinder2)
		
    JazzHitSound = SoundCue'KismetGame_Assets.Sounds.Jazz_Death_Cue'
  
    InventoryManagerClass=class'WeaponsIM1'


    KillValue = 50;
}


