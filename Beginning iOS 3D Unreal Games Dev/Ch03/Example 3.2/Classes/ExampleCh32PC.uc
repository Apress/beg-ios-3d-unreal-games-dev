class ExampleCh32PC extends SimplePC;


function bool SwipeZoneCallback(MobileInputZone Zone, 
			        float DeltaTime, 
			        int Handle,
			        EZoneTouchEvent EventType, 
			        Vector2D TouchLocation)
{	
    local 	bool 		retval;
	
 
    retval = true;


    if (EventType == ZoneEvent_Touch)
    {
        //WorldInfo.Game.Broadcast(self,"You touched the screen at = " @ 
        //                               TouchLocation.x @ " , " @ TouchLocation.y @
        //                               ", Zone Touched = " @ Zone);
	// Start Firing pawn's weapon
	StartFire(0);
    }
    else
    if(EventType == ZoneEvent_Update)
    {	
    }		
    else
    if (EventType == ZoneEvent_UnTouch)
    {	
	// Stop Firing Pawn's weapon
	StopFire(0);
    }

    return retval;
}

function SetupZones()
{
    Super.SetupZones();

    // If we have a game class, configure the zones
    if (MPI != None && WorldInfo.GRI.GameClass != none) 
    {
        LocalPlayer(Player).ViewportClient.GetViewportSize(ViewportSize);

        if (FreeLookZone != none)
        {
            FreeLookZone.OnProcessInputDelegate = SwipeZoneCallback;

        }	
    }
}

function PlaceWeapon()
{
    // First Person 	
    local vector WeaponLocation;
    local Rotator WeaponRotation,TempRot;
    local Weapon TestW;
    local vector WeaponAimVect;
	

    WeaponRotation.yaw = -16000; // 90 Degrees turn = OFFSET	


    TempRot = Pawn.GetBaseAimRotation();
    WeaponRotation.pitch = TempRot.roll;
    WeaponRotation.yaw   += TempRot.yaw; 
    WeaponRotation.roll  -= TempRot.pitch; // Swith due to weapon local axes orientation
	
    WeaponAimVect = Normal(Vector(TempRot));
    WeaponLocation = Pawn.Location + (40 * WeaponAimVect) + vect(0,0,30);

    TestW = Pawn.Weapon; //Pawn.InvManager.GetBestWeapon();
	
    if (TestW != None)
    {
        TestW.SetLocation(WeaponLocation); 
        TestW.SetRotation(WeaponRotation);
    }
    else
    {
        WorldInfo.Game.Broadcast(self,"Player has no weapon!!!!!");
    }

}

function PlayerTick(float DeltaTime)
{
    Super.PlayerTick(DeltaTime);
	
    PlaceWeapon();
}

defaultproperties
{
	
}




