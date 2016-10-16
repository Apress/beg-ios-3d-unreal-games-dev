class ExampleCh7Game extends FrameworkGame;


event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh7Game Type Active - Engine Has Loaded !!!!");
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
    PlayerControllerClass=class'ExampleCh7.ExampleCh7PC'
	
    DefaultPawnClass=class'Jazz3Pawn'
    HUDType=class'ExtendedHUD' 
   
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false
}

