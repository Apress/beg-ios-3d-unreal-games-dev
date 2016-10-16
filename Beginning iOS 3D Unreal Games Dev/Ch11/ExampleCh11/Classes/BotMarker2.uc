class BotMarker2 extends Actor;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    //WorldInfo.Game.Broadcast(self,"BotMarker Has Been Touched");	
}

function Tick(FLOAT DeltaTime)
{
    local Rotator TempRot;

      
    TempRot = Rotation;
    TempRot.yaw = Rotation.yaw + (15000 * DeltaTime);
    SetRotation(TempRot);
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
        StaticMesh=StaticMesh'CastleEffects.TouchToMoveArrow'
        Scale3D=(X=2.0000,Y=2.0000,Z=2.000)
       
        //bAllowApproximateOcclusion=True
        //bForceDirectLightMap=True
        //bCastDynamicShadow=False
        //LightingChannels=(Dynamic=False,Static=True)
    End Object
    Components.Add(StaticMeshComponent0)
}