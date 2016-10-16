class Ch12HUD extends UDKHud;

var Texture DefaultTexture1;
var Texture DefaultTexture2;
var Texture DefaultTexture3;
var Texture DefaultTexture4;
var Texture DefaultTexture5;

struct HUDInfo
{
    var string Label;
    var Vector2D TextLocation;
    var Color TextColor;
    var Vector2D Scale;
};

// HUD 
var HUDInfo HUDHealth;
var HUDInfo HUDName;
var HUDInfo HUDExperience;
var HUDInfo HUDGameOver;


simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    HUDHealth.Label = "HitPoints:";	
    HUDHealth.TextLocation.x = 1100;
    HUDHealth.TextLocation.y = 50;
    HUDHealth.TextColor.R = 0;
    HUDHealth.TextColor.G = 0;
    HUDHealth.TextColor.B = 255;
    HUDHealth.Scale.X = 2;
    HUDHealth.Scale.Y = 4;

    HUDName.Label = "Name:";	
    HUDName.TextLocation.x = 600;
    HUDName.TextLocation.y = 50;
    HUDName.TextColor.R = 0;
    HUDName.TextColor.G = 255;
    HUDName.TextColor.B = 0;
    HUDName.Scale.X = 2;
    HUDName.Scale.Y = 4;

    HUDGameOver.Label = "Objective Killed";	
    HUDGameOver.TextLocation.x = 300;
    HUDGameOver.TextLocation.y = 300;
    HUDGameOver.TextColor.R = 255;
    HUDGameOver.TextColor.G = 0;
    HUDGameOver.TextColor.B = 255;
    HUDGameOver.Scale.X = 7;
    HUDGameOver.Scale.Y = 7;

    HUDExperience.Label = "Experience:";	
    HUDExperience.TextLocation.x = 0;
    HUDExperience.TextLocation.y = 50;
    HUDExperience.TextColor.R = 255;
    HUDExperience.TextColor.G = 0;
    HUDExperience.TextColor.B = 0;
    HUDExperience.Scale.X = 2;
    HUDExperience.Scale.Y = 4;
}

function DrawHUDItem(HUDInfo Info, coerce string Value)
{
    local Vector2D TextSize;

    Canvas.SetDrawColor(Info.TextColor.R, Info.TextColor.G, Info.TextColor.B);	
    Canvas.SetPos(Info.TextLocation.X, Info.TextLocation.Y);
    Canvas.DrawText(Info.Label, ,Info.Scale.X,Info.Scale.Y);
    Canvas.TextSize(Info.Label, TextSize.X, TextSize.Y);
    Canvas.SetPos(Info.TextLocation.X + (TextSize.X * Info.Scale.X), Info.TextLocation.Y);
    Canvas.DrawText(Value, , Info.Scale.X, Info.Scale.Y);
}



function DrawPlayerHUD(Pawn HUDPawn)
{
    local string CharacterName;
    local int Experience;
    local int HitPoints;

    CharacterName = PlayerPawnCh12(HUDPawn).CharacterName;
    Experience = PlayerPawnCh12(HUDPawn).Experience;
    HitPoints = HUDPawn.Health;

    DrawHUDItem(HUDExperience, Experience);
    DrawHUDItem(HUDName, CharacterName);
    DrawHUDItem(HUDHealth, HitPoints);
}

function DrawAllyHUD(Pawn HUDPawn)
{
    local string CharacterName;
    local int Experience;
    local int HitPoints;


    CharacterName = BotPawnCh12(HUDPawn).CharacterName;
    Experience = BotPawnCh12(HUDPawn).Experience;
    HitPoints = HUDPawn.Health;

    DrawHUDItem(HUDExperience, Experience);
    DrawHUDItem(HUDName, CharacterName);
    DrawHUDItem(HUDHealth, HitPoints);   
}


function DrawHUD()
{
    local Pawn HUDPawn;

    
    super.DrawHUD();

    /*
    // Blend Modes = BLEND_Opaque, BLEND_Additive, and BLEND_Modulate modes
    Canvas.SetPos(0,0);
    Canvas.DrawTextureBlended(DefaultTexture1, 1, BLEND_Opaque);

    Canvas.SetPos(150,0);
    Canvas.DrawTextureBlended(DefaultTexture2, 1, BLEND_Additive);

    Canvas.SetPos(300,0);
    Canvas.DrawTextureBlended(DefaultTexture3, 1, BLEND_Masked);

    Canvas.SetPos(450,0);
    Canvas.DrawTextureBlended(DefaultTexture4, 1,BLEND_Masked);

    Canvas.SetPos(600,0);
    Canvas.DrawTextureBlended(DefaultTexture5, 1, BLEND_Masked);

    */

    Canvas.Font = class'Engine'.static.GetLargeFont();


    HUDPawn = ExampleCh12PC(PlayerOwner).HUDPawn;
    if (HUDPawn.IsA('PlayerPawnCh12'))
    {
       DrawPlayerHUD(HUDPawn);
    }
    else 
    if (HUDPawn.IsA('BotPawnCh12')) 
    {
       DrawAllyHUD(HUDPawn);
    }
 
    // Game Over
    if (ExampleCh12PC(PlayerOwner).bGameOVer)
    {
         DrawHUDItem(HUDGameOver, "");
    }  

}

defaultProperties
{
    DefaultTexture1= Texture2D'EditorResources.Ambientcreatures' // Yellow Chick 32 by 32
    DefaultTexture2= Texture2D'EditorResources.Ammo'             // Ammo Icon 32 by 32
    DefaultTexture3= Texture2D'EditorResources.LookTarget'       // Target 32 by 32
    DefaultTexture4= Texture2D'EditorMaterials.Tick'             // Green Check 32 by 32
    DefaultTexture5= Texture2D'EditorMaterials.GreyCheck'        // Grey Check 32 by 32

}

