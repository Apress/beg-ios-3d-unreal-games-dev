class PlayerPawnCh12 extends JazzPawnDamage;

var bool bFollowPlayerRotation;
var string CharacterName;
var int Experience;

//////////////////////////////////////// Top Down View /////////////////////////////////////////////

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
  	out_CamLoc = Location;
	out_CamLoc.Z += CamOffsetDistance;

   	if(!bFollowPlayerRotation)
   	{
      		out_CamRot.Pitch = -16384;
      		out_CamRot.Yaw = 0;
      		out_CamRot.Roll = 0;
   	}
   	else
   	{
      		out_CamRot.Pitch = -16384;
     	 	out_CamRot.Yaw = Rotation.Yaw;
      		out_CamRot.Roll = 0;
   	}

   	return true;
}

simulated singular event Rotator GetBaseAimRotation()
{
	local rotator   POVRot, tempRot;

   	tempRot = Rotation;
   	tempRot.Pitch = 0;
   	SetRotation(tempRot);
   	POVRot = Rotation;
   	POVRot.Pitch = 0; 

   	return POVRot;
}   


defaultproperties
{
    bFollowPlayerRotation = false
    CamOffsetDistance= 1500.0

    CharacterName = "Player"
    Experience = 0
}



