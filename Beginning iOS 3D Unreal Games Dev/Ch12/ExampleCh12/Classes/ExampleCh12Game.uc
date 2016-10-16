class ExampleCh12Game extends FrameworkGame;


event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh12Game Type Active - Engine Has Loaded !!!!");
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
    PlayerControllerClass=class'ExampleCh12.ExampleCh12PC'	
    DefaultPawnClass=class'PlayerPawnCh12'
    HUDType=class'Ch12HUD'
 
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false
}

