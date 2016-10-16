class BotPawnCh12 extends BotPawn;

var string CharacterName;
var int Experience;


event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    PlaySound(JazzHitSound); 
    Health = Health - Damage;
    //WorldInfo.Game.Broadcast(self,self @ " Has Taken Damage IN TAKEDAMAGE, HEALTH = " @ Health);	
   
    if (Health <= 0)
    {
        SetLocation(InitialLocation);
        SetPhysics(PHYS_Falling);
         
        Health = 100;
        Experience = 0;
    }
}

defaultproperties
{
    CharacterName = "TeamMember1"
    Experience = 0;
}