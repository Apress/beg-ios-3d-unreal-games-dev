class BotMarker extends Actor;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    //WorldInfo.Game.Broadcast(self,"BotMarker Has Been Touched");	
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        //StaticMesh=StaticMesh'EngineMeshes.Cube'
        StaticMesh=StaticMesh'EngineMeshes.Sphere'
        //Translation=(X=0.000000,Y=0.000000,Z=0.000000)
        Scale3D=(X=0.250000,Y=0.250000,Z=0.25000)
        //CollideActors=false
        //bAllowApproximateOcclusion=True
        //bForceDirectLightMap=True
        //bCastDynamicShadow=False
        //LightingChannels=(Dynamic=False,Static=True)
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
    //bStatic=false	
    //bMovable=true
    //bEdShouldSnap=True
}