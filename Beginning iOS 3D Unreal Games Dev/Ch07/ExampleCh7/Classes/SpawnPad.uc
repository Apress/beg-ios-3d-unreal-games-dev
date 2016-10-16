class SpawnPad extends Actor
placeable;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    WorldInfo.Game.Broadcast(self,"SpawnPad Has Been Touched");
}


defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'HU_Deco.SM.Mesh.S_HU_Deco_SM_Metalbase01'
        Scale3D=(X=0.250000,Y=0.250000,Z=0.25000)
    End Object
    Components.Add(StaticMeshComponent0)
	
    Begin Object Class=CylinderComponent NAME=CollisionCylinder
        CollideActors=true
        CollisionRadius=+0040.000000
        CollisionHeight=+0040.000000
    End Object
    CollisionComponent=CollisionCylinder
    Components.Add(CollisionCylinder)
	
    bCollideActors=true
}