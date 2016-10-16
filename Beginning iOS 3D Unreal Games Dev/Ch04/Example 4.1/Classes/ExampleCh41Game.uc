class ExampleCh41Game extends FrameworkGame;


// UDKEngine.ini
//[UnrealEd.EditorEngine]
//ModEditPackages=Example2


// Mobile-UDKGame.ini
//[Example2.Example2Game]
//RequiredMobileInputConfigs=(GroupName="UberGroup",RequireZoneNames=("UberStickMoveZone","UberStickLookZone","UberLookZone"))



event OnEngineHasLoaded()
{
    WorldInfo.Game.Broadcast(self,"ExampleCh41Game Type Active - Engine Has Loaded !!!!");
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
    PlayerControllerClass=class'ExampleCh41.ExampleCh41PC'
	
    DefaultPawnClass=class'UDKBase.SimplePawn'
    HUDType=class'UDKBase.UDKHUD'
 
    bRestartLevel=false
    bWaitingToStartMatch=true
    bDelayedStart=false
}



