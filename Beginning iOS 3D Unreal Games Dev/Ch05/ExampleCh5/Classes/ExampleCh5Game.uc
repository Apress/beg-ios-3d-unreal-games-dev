class ExampleCh5Game extends FrameworkGame;


event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh5Game Type Active - Engine Has Loaded !!!!");
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
    PlayerControllerClass=class'ExampleCh5.ExampleCh5PC'
	
    DefaultPawnClass=class'ExampleCh5.JazzPawnDamage'
    HUDType=class'UDKBase.UDKHUD'
 
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false
}

