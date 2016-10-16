class ExampleCh43Game extends FrameworkGame;


event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh43Game Type Active - Engine Has Loaded !!!!");
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
    PlayerControllerClass=class'ExampleCh43.ExampleCh43PC'

    DefaultPawnClass=class'UDKBase.SimplePawn'
    HUDType=class'UDKBase.UDKHUD'
 
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false
}



