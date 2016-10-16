class JazzCh10Pawn extends SimplePawn;


var Inventory MainGun;
var vector InitialLocation;
var SoundCue PawnHitSound;


function AddHealthBonus(int Value)
{
    Health = Health + value;
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{ 
    PlaySound(PawnHitSound); 
    Health = Health - Damage;

    //WorldInfo.Game.Broadcast(self,self @ " Has Taken Damage IN TAKEDAMAGE, HEALTH = " @ Health);	
}

function AddDefaultInventory()
{	
    MainGun = InvManager.CreateInventory(class'JazzWeaponCh10');
    MainGun.SetHidden(false);

    Weapon(MainGun).FireOffset = vect(0,0,-70);
}

defaultproperties
{
    InventoryManagerClass=class'WeaponsIM1'

    PawnHitSound = SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_Death_Cue'  
}


