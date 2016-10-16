class ExampleCh11Game extends FrameworkGame;


event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh11Game Type Active - Engine Has Loaded !!!!");
}

function bool PreventDeath(Pawn KilledPawn, Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    return true;
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    return super.SetGameType(MapName, Options, Portal);
}

defaultproperties
{
    PlayerControllerClass=class'ExampleCh11.ExampleCh11PC'	
    DefaultPawnClass=class'JazzPawnDamage'
    HUDType=class'Ch11HUD'
 
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false
}

