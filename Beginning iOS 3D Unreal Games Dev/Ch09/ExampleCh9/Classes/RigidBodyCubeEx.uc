class RigidBodyCubeEx extends RigidBodyCube;

var SoundCue ExplosionSound;
var() float ItemValue; 


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
    super.RigidBodyCollision(HitComponent, OtherComponent, RigidCollisionData, ContactIndex);

    if (bDestroyed)
    {
        PlaySound(ExplosionSound);
        ExampleCh9Game(WorldInfo.Game).Score += ItemValue;
    }
}

defaultproperties
{
    ExplosionSound = SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_ComboExplosionCue'
    ItemValue = 10;
}

