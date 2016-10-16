class RigidBodyCube extends KActor
placeable;

var ParticleSystem ExplosionTemplate;
var ParticleSystemComponent Explosion;

var vector OutOfViewLocation;
var float MinimumForceToExplode;
var bool bDestroyed;

/** Called when a PrimitiveComponent this Actor owns has:
 *     -bNotifyRigidBodyCollision set to true
 *     -ScriptRigidBodyCollisionThreshold > 0
 *     -it is involved in a physics collision where the relative velocity exceeds ScriptRigidBodyCollisionThreshold
 *
 * @param HitComponent the component of this Actor that collided
 * @param OtherComponent the other component that collided
 * @param RigidCollisionData information on the collision itslef, including contact points
 * @param ContactIndex the element in each ContactInfos' ContactVelocity and PhysMaterial arrays that corresponds
 *			to this Actor/HitComponent
 */
event RigidBodyCollision(PrimitiveComponent HitComponent, 
                         PrimitiveComponent OtherComponent,
                         const out CollisionImpactData RigidCollisionData, 
                         int ContactIndex)
{
    local	vector	ExplosionLocation;
    local	float	CollisionForce;



    WorldInfo.Game.Broadcast(self,"RigidBodyCube COLLISION!!!! - " @ self @
                                  ", HitComponent =  " @ Hitcomponent @ 
                                  " Has Collided with " @ OtherComponent @
                                  " With FOrce " @ VSize(RigidCollisionData.TotalNormalForceVector));


    CollisionForce = VSize(RigidCollisionData.TotalNormalForceVector);


    if (CollisionForce >= MinimumForceToExplode)
    { 
        // Spawn Explosion Emitter
        ExplosionLocation = HitComponent.Bounds.Origin;
        Explosion = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionTemplate, ExplosionLocation);

        // Object has been Destroyed
        bDestroyed = true;

        // Move Rigid Body out of view
        HitComponent.SetRBPosition(OutOfViewLocation);
        SetPhysics(Phys_None);	
    }

}

defaultproperties
{	
    Begin Object Class=StaticMeshComponent Name=RigidBodyCubeMesh
        StaticMesh=StaticMesh'EngineMeshes.Cube'		
        CollideActors=true
        BlockActors=true
        BlockRigidBody=true
        bNotifyRigidBodyCollision=true 
        ScriptRigidBodyCollisionThreshold=0.001		
        RBChannel=RBCC_GameplayPhysics
        RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
    End Object
    StaticMeshComponent=RigidBodyCubeMesh
    Components.Add(RigidBodyCubeMesh)

    CollisionComponent = RigidBodyCubeMesh

					
    bWakeOnLevelStart = true
    bEdShouldSnap = false
	
    Physics = PHYS_RigidBody
    BlockRigidBody = true	
    bBlockActors = true
    bCollideActors = true

    MinimumForceToExplode = 370;
    bDestroyed = false
    OutOfViewLocation = (X = 0, Y = 0, Z = -5000)

    ExplosionTemplate = ParticleSystem'Castle_Assets.FX.P_FX_Fire_SubUV_01'
}

