class ExampleCh10Game extends FrameworkGame;

var int Score;
var int MaxSpawnPads;
var bool bGameOver;

 
event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh10Game Type Active - Engine Has Loaded !!!!");
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
    PlayerControllerClass=class'ExampleCh10.ExampleCh10PC'
    
    DefaultPawnClass=class'JazzCh10Pawn'
    HUDType=class'FPSHUD'
  
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false

    Score = 0
    MaxSpawnPads = 4
    bGameOver = false;
}



