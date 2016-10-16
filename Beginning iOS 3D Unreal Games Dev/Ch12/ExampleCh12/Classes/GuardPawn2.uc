class GuardPawn2 extends BotPawnCh10;

var int ExperienceValue;

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    PlaySound(HurtSound); 
    Health = Health - Damage;	
   
    if (Health <= 0)
    {
        PlaySound(DeathSound); 


        // Add experience points to player or member of player's group if this pawn is killed by one of them
        if (InstigatedBy.IsA('ExampleCh12PC'))
        {
            PlayerPawnCh12(InstigatedBy.Pawn).Experience += ExperienceValue;
        }
        else 
        if (InstigatedBy.IsA('BotAllyController'))
        {       
            BotPawnCh12(InstigatedBy.Pawn).Experience += ExperienceValue;
        }

        //destroy();
        SetLocation(InitialLocation);
        SetPhysics(PHYS_Falling);
        Health = 100;


    }

    BotControllerGuard(Controller).Threat = InstigatedBy.Pawn;

}

defaultproperties
{
    ExperienceValue = 100;
}