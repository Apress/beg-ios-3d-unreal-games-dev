class BotSpawnPad extends Actor
placeable;

var() int PadNumber;

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'Pickups.jump_pad.S_Pickups_Jump_Pad'
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

    PadNumber = 0
}