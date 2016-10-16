class GameBall extends KActorSpawnable;

var SoundCue BallImpact;
var float MinimumForceForSound;


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

    local float CollisionForce;
 

    CollisionForce = VSize(RigidCollisionData.TotalNormalForceVector);
    if (CollisionForce >= MinimumForceForSound)
    { 
        PlaySound(BallImpact);
    }
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    WorldInfo.Game.Broadcast(self,"GameBall Has Been Touched");
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=GameBallMesh
        StaticMesh=StaticMesh'EngineMeshes.Sphere'
        Translation=(X=0.000000,Y=0.000000,Z=0.000000)
        Scale3D=(X=0.10000,Y=0.10000,Z=0.1000)
        
        CollideActors=true
        BlockActors=true
        BlockRigidBody=true
        bNotifyRigidBodyCollision=true 
        ScriptRigidBodyCollisionThreshold=0.001		
        RBChannel=RBCC_GameplayPhysics
        RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
    End Object
    Components.Add(GameBallMesh)
    CollisionComponent = GameBallMesh


    BallImpact = SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_GibLarge_Cue'
    MinimumForceForSound = 50;
}

