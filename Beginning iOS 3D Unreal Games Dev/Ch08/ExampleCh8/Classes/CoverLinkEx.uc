class CoverLinkEx extends CoverLink;

var() float CoverProtectionAngle;


function bool IsCoverSlotValid(int SlotIndex, vector ThreatLocation)
{
    local bool Valid;	

    local vector SlotLocation;
    local Rotator SlotRotation;
    local vector SlotNormal;

    local vector DirectionToThreat;
    local float AngleDegrees;


    Valid = false;

    SlotLocation = GetSlotLocation(SlotIndex);
    SlotRotation = GetSlotRotation(SlotIndex);

    SlotNormal = Normal(Vector(SlotRotation)); 
    DirectionToThreat = Normal(ThreatLocation - SlotLocation);

    AngleDegrees = acos(SlotNormal Dot DirectionToThreat) * RadToDeg;			
	
    if (AngleDegrees < CoverProtectionAngle)
    {
        Valid = true;
    }

    return Valid;
}

function bool IsCoverSlotAvailable(int SlotIndex)
{
    local bool SlotAvailable;

    SlotAvailable = false;

    if (Slots[SlotIndex].SlotOwner == None)
    {
        SlotAvailable = true;	
    }

    return SlotAvailable;
}

defaultproperties
{
    CoverProtectionAngle = 45.0	
}
