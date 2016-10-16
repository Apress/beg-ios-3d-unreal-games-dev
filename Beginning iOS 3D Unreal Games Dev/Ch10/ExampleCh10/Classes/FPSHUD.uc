class FPSHUD extends UDKHud;

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
var HUDInfo HUDEnemyHealth;
var HUDInfo HUDGameOver;
var HUDInfo HUDScore;


simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    HUDHealth.Label = "Health:";	
    HUDHealth.TextLocation.x = 1100;
    HUDHealth.TextLocation.y = 0;
    HUDHealth.TextColor.R = 255;
    HUDHealth.TextColor.G = 0;
    HUDHealth.TextColor.B = 0;
    HUDHealth.Scale.X = 2;
    HUDHealth.Scale.Y = 4;

    HUDEnemyHealth.Label = "Enemy Health:";	
    HUDEnemyHealth.TextLocation.x = 500;
    HUDEnemyHealth.TextLocation.y = 0;
    HUDEnemyHealth.TextColor.R = 255;
    HUDEnemyHealth.TextColor.G = 0;
    HUDEnemyHealth.TextColor.B = 0;
    HUDEnemyHealth.Scale.X = 2;
    HUDEnemyHealth.Scale.Y = 4;

    HUDGameOver.Label = "GAME OVER";	
    HUDGameOver.TextLocation.x = 400;
    HUDGameOver.TextLocation.y = 300;
    HUDGameOver.TextColor.R = 255;
    HUDGameOver.TextColor.G = 0;
    HUDGameOver.TextColor.B = 255;
    HUDGameOver.Scale.X = 7;
    HUDGameOver.Scale.Y = 7;

    HUDScore.Label = "Score:";	
    HUDScore.TextLocation.x = 0;
    HUDScore.TextLocation.y = 0;
    HUDScore.TextColor.R = 255;
    HUDScore.TextColor.G = 0;
    HUDScore.TextColor.B = 0;
    HUDScore.Scale.X = 2;
    HUDScore.Scale.Y = 4;
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

    // Score
    DrawHUDItem(HUDScore,ExampleCh10Game(WorldInfo.Game).Score);
   
    // Enemy Health
    DrawHUDItem(HUDEnemyHealth, ExampleCh10PC(PlayerOwner).EnemyPawn.Health);

    // Health
    DrawHUDItem(HUDHealth,PlayerOwner.Pawn.Health);
 
    // Game Over
    if (ExampleCh10Game(WorldInfo.Game).bGameOver)
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

