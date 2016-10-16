class Ch11HUD extends UDKHud;

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
var HUDInfo HUDAllyHealth;
var HUDInfo HUDObjectiveHealth;
var HUDInfo HUDGameOver;


simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    HUDHealth.Label = "Health:";	
    HUDHealth.TextLocation.x = 1100;
    HUDHealth.TextLocation.y = 50;
    HUDHealth.TextColor.R = 0;
    HUDHealth.TextColor.G = 0;
    HUDHealth.TextColor.B = 255;
    HUDHealth.Scale.X = 2;
    HUDHealth.Scale.Y = 4;

    HUDAllyHealth.Label = "AllyHealth:";	
    HUDAllyHealth.TextLocation.x = 600;
    HUDAllyHealth.TextLocation.y = 50;
    HUDAllyHealth.TextColor.R = 0;
    HUDAllyHealth.TextColor.G = 255;
    HUDAllyHealth.TextColor.B = 0;
    HUDAllyHealth.Scale.X = 2;
    HUDAllyHealth.Scale.Y = 4;

    HUDGameOver.Label = "Objective Killed";	
    HUDGameOver.TextLocation.x = 300;
    HUDGameOver.TextLocation.y = 300;
    HUDGameOver.TextColor.R = 255;
    HUDGameOver.TextColor.G = 0;
    HUDGameOver.TextColor.B = 255;
    HUDGameOver.Scale.X = 7;
    HUDGameOver.Scale.Y = 7;

    HUDObjectiveHealth.Label = "ObjectiveHealth:";	
    HUDObjectiveHealth.TextLocation.x = 0;
    HUDObjectiveHealth.TextLocation.y = 50;
    HUDObjectiveHealth.TextColor.R = 255;
    HUDObjectiveHealth.TextColor.G = 0;
    HUDObjectiveHealth.TextColor.B = 0;
    HUDObjectiveHealth.Scale.X = 2;
    HUDObjectiveHealth.Scale.Y = 4;
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

function DrawHUD()
{
    local int Health;

    
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

    // Objective Health
    DrawHUDItem(HUDObjectiveHealth,ExampleCh11PC(PlayerOwner).ObjectiveHealth);
   
    // Ally Bot Health
    Health = ExampleCh11PC(PlayerOwner).AllyBot.Pawn.Health;
    DrawHUDItem(HUDAllyHealth, Health);

    // Health
    DrawHUDItem(HUDHealth,PlayerOwner.Pawn.Health);
 
    // Game Over
    if (ExampleCh11PC(PlayerOwner).bGameOVer)
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

