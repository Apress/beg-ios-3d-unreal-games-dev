class BotPawnCh10 extends BotPawn2;


var array<vector> SpawnPadLocations;

var SoundCue DeathSound;
var SoundCue HurtSound;

function vector GetRandomSpawnPosition()
{
    local int RandPad;
    local int MaxPads;
    local vector returnvec;

    MaxPads = ExampleCh10Game(WorldInfo.Game).MaxSpawnPads;
    Randpad = Rand(MaxPads);

    WorldInfo.Game.Broadcast(self,"*************** " @ self @ " RESPAWNED at pad number " @ RandPad);

    if (RandPad >= SpawnPadLocations.length)
    {
        // error
        return InitialLocation;
    }
    else
    {
        returnvec = SpawnPadLocations[RandPad];              
    }  

    return returnvec;
}

function AddHealthBonus(int Value)
{
    Health = Health + value;
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    PlaySound(HurtSound); 

    Health = Health - Damage;
    //WorldInfo.Game.Broadcast(self,self @ " Has Taken Damage IN TAKEDAMAGE, HEALTH = " @ Health);	
   
    if (Health <= 0)
    {
        PlaySound(DeathSound); 
        SetLocation(GetRandomSpawnPosition());
        
        SetPhysics(PHYS_Falling);
        Health = 100;

        BotAttackCoverController(Controller).ResetAfterSpawn();

        // Process Kill
        if (PlayerController(InstigatedBy) != None)
        {
            // Add kill to Player's Score
            ExampleCh10Game(WorldInfo.Game).Score += KillValue;
        }
    }
}

function AddDefaultInventory()
{	
    MainGun = InvManager.CreateInventory(class'BotWeaponCh10');
    MainGun.SetHidden(false);

    AddGunToSocket('Weapon_R');

    Weapon(MainGun).FireOffset = vect(0,50,-70);
}

defaultproperties
{
    DeathSound = SoundCue'KismetGame_Assets.Sounds.Jazz_Death_Cue'
    HurtSound = SoundCue'KismetGame_Assets.Sounds.Jazz_SpinStop_Cue'
}
