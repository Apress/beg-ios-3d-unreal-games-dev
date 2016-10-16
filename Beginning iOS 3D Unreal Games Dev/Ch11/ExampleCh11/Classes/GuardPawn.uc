class GuardPawn extends BotPawnCh10;

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    PlaySound(HurtSound); 
    Health = Health - Damage;	
   
    if (Health <= 0)
    {
        PlaySound(DeathSound); 
        destroy();
    }

    BotControllerGuard(Controller).Threat = InstigatedBy.Pawn;
}
