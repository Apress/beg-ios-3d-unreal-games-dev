class ExampleCh9Game extends FrameworkGame;

var int Score;


event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh9Game Type Active - Engine Has Loaded !!!!");
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
    PlayerControllerClass=class'ExampleCh9.ExampleCh9PC'

    DefaultPawnClass=class'UDKBase.SimplePawn'
    HUDType=class'KickBallHUD'
 
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false
}



