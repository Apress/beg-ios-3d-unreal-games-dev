class LoadMarker extends Actor
placeable;

var SoundCue SaveSound;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    if (!Other.IsA('PlayerPawnCh12'))
    {
        return;
    }
	
    PlaySound(SaveSound);

    ExampleCh12PC(Pawn(Other).Controller).LoadSquadInfo();
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'HU_Deco_Statues.SM.Mesh.S_HU_Deco_Statues_SM_Statue03_01'
        Scale3D=(X=2.0000,Y=2.0000,Z=2.000)
       
        //bAllowApproximateOcclusion=True
        //bForceDirectLightMap=True
        //bCastDynamicShadow=False
        //LightingChannels=(Dynamic=False,Static=True)
    End Object
    Components.Add(StaticMeshComponent0)

    Begin Object Class=CylinderComponent NAME=CollisionCylinder
        CollideActors=true
        BlockActors=false
        CollisionRadius=+0140.000000
        CollisionHeight=+0240.000000
    End Object
    Components.Add(CollisionCylinder)
    CollisionComponent = CollisionCylinder
  
    bCollideActors=true
    bBlockActors = false

    SaveSound = SoundCue'A_Interface.menu.UT3MenuAcceptCue'


}