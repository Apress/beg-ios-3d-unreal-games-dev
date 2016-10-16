class Jazz1Pawn extends SimplePawn;


var float CamOffsetDistance;
var int CamAngle; 

var Inventory MainGun;


simulated singular event Rotator GetBaseAimRotation()
{
   local rotator TempRot;

   TempRot = Rotation;
   TempRot.Pitch = 0;  

   SetRotation(TempRot);
   

   return TempRot;
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
    MainGun = InvManager.CreateInventory(class'JazzWeapon1');
    MainGun.SetHidden(false);

    AddGunToSocket('Weapon_R');

    Weapon(MainGun).FireOffset = vect(0,0,-70);
}

// Iso Cam
/*
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   out_CamLoc = Location;
   out_CamLoc.X += Cos(CamAngle * UnrRotToRad) * CamOffsetDistance;
   out_CamLoc.Z += Sin(CamAngle * UnrRotToRad) * CamOffsetDistance;

   out_CamRot.Pitch = -1 * CamAngle;   
   out_CamRot.Yaw = 32000;
   out_CamRot.Roll = 0;

   return true;
}
*/

/////////////////////////////////////////////// Third Person View /////////////////////////////////////////////////////

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
    local vector BackVector;
    local vector UpVector;

    local float  CamDistanceHorizontal;
    local float  CamDistanceVertical;

	

    // Set Camera Location
    CamDistanceHorizontal = CamOffsetDistance * cos(CamAngle * UnrRotToRad);
    CamDistanceVertical   = CamOffsetDistance * sin(CamAngle * UnrRotToRad);
 
    BackVector = -Normal(Vector(Rotation)) * CamDistanceHorizontal;
    UpVector   =  vect(0,0,1) * CamDistanceVertical;

    out_CamLoc = Location + BackVector + UpVector;

    // Set Camera Rotation
    out_CamRot.pitch = -CamAngle;
    out_CamRot.yaw   = Rotation.yaw;
    out_CamRot.roll  = Rotation.roll;

    return true;
}


defaultproperties
{
	
    Begin Object Class=SkeletalMeshComponent Name=JazzMesh     
        SkeletalMesh=SkeletalMesh'KismetGame_Assets.Anims.SK_Jazz'
        AnimSets(0)=AnimSet'KismetGame_Assets.Anims.SK_Jazz_Anims'
        AnimTreeTemplate=AnimTree'KismetGame_Assets.Anims.Jazz_AnimTree'
        BlockRigidBody=true
        CollideActors=true
    End Object

    Mesh = JazzMesh; // Set The mesh for this object
    Components.Add(JazzMesh); // Attach this mesh to this Actor
				 
	
    CamAngle=3000;
    CamOffsetDistance= 484.0


    InventoryManagerClass=class'WeaponsIM1'   
}




