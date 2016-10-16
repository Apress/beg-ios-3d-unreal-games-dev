class ExampleCh32Game extends FrameworkGame;

 
event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh32Game Type Active - Engine Has Loaded !!!!");
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
    PlayerControllerClass=class'ExampleCh32.ExampleCh32PC'
    
    DefaultPawnClass=class'Jazz2Pawn'
    HUDType=class'UDKBase.UDKHUD'
  
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false
}



