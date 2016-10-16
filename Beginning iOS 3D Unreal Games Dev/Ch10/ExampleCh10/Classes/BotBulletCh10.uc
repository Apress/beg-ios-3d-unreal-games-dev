class BotBulletCh10 extends JazzBulletSound; 

simulated singular event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    Other.TakeDamage(2, InstigatorController, HitLocation, -HitNormal, None);
}

