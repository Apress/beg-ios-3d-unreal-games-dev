class BotControllerAttack extends UDKBot;

var Actor CurrentGoal;
var Vector TempDest;
var float FollowDistance;			
var Actor TempGoal;


////////////////////////////////////////// PAthnode Related Functions //////////////////////////////////////////////////
/*
state FollowTarget
{
    Begin:
	
    //WorldInfo.Game.Broadcast(self,"BotController-USING PATHNODES FOR FOLLOWTARGET STATE");

    // Move Bot to Target
    if (CurrentGoal != None)
    {
        TempGoal = FindPathToward(CurrentGoal); 

        if (ActorReachable(CurrentGoal))
        {
            MoveTo(CurrentGoal.Location, ,FollowDistance);	
        }
        else
        if (TempGoal != None)
        {
            MoveToward(TempGoal);
        } 
        else
        {
            //give up because the nav mesh failed to find a path
            `warn("PATCHNODES failed to find a path!");	
            WorldInfo.Game.Broadcast(self,"PATHNODES failed to find a path!, CurrentGoal = " @ CurrentGoal);
            MoveTo(Pawn.Location);
        }   
    }
    LatentWhatToDoNext();
}
*/

////////////////////////////////////////// Navigation Mesh Related Functions //////////////////////////////////////////////

event bool GeneratePathTo(Actor Goal, optional float WithinDistance, optional bool bAllowPartialPath)
{
    if( NavigationHandle == None )
    return FALSE;

    // Clear cache and constraints (ignore recycling for the moment)
    NavigationHandle.PathConstraintList = none;
    NavigationHandle.PathGoalList = none;

    class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Goal );
    class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Goal, WithinDistance, bAllowPartialPath );

    return NavigationHandle.FindPath();
}

state FollowTarget
{
    Begin:

    WorldInfo.Game.Broadcast(self,"BotController-USING NAVMESH FOR FOLLOWTARGET STATE");

    // Move Bot to Target
    if (CurrentGoal != None)
    {
        if(GeneratePathTo(CurrentGoal))
        {
            NavigationHandle.SetFinalDestination(CurrentGoal.Location);				
            if( NavigationHandle.ActorReachable(CurrentGoal) )
            {			
                // then move directly to the actor	
                MoveTo(CurrentGoal.Location, CurrentGoal,FollowDistance);	
                GotoState('Firing', 'Begin');	
            }
            else
            {
                // move to the first node on the path
                if( NavigationHandle.GetNextMoveLocation(TempDest, Pawn.GetCollisionRadius()) )
                {
                    // suggest move preparation will return TRUE when the edge's
                    // logic is getting the bot to the edge point
                    // FALSE if we should run there ourselves
                    if (!NavigationHandle.SuggestMovePreparation(TempDest,self))
                    {
                        MoveTo(TempDest);						
                    }
                }
            }	
        }
        else
        {
            //give up because the nav mesh failed to find a path
            `warn("FindNavMeshPath failed to find a path!");	
            WorldInfo.Game.Broadcast(self,"FindNavMeshPath failed to find a path!, CurrentGoal = " @ CurrentGoal);
            MoveTo(Pawn.Location);
        }   
    }
    LatentWhatToDoNext();
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

state Firing
{

    Begin:

    WorldInfo.Game.Broadcast(self,"BotController-IN Firing State");
    
    Sleep(3);
    Pawn.StartFire(0);	          
    Sleep(0.5);
  
    LatentWhatToDoNext();
}

auto state Initial
{
    Begin:

    LatentWhatToDoNext();
}

/** triggers ExecuteWhatToDoNext() to occur during the next tick
 * this is also where logic that is unsafe to do during the physics tick should be added
 * @note: in state code, you probably want LatentWhatToDoNext() so the state is paused while waiting for ExecuteWhatToDoNext() to be called
 */
event WhatToDoNext()
{
    DecisionComponent.bTriggered = true;
}

/** entry point for AI decision making
 * this gets executed during the physics tick so actions that could change the physics state (e.g. firing weapons) are not allowed
 */
protected event ExecuteWhatToDoNext()
{
    if (IsInState('Initial'))
    {
        GotoState('FollowTarget', 'Begin');
    }
    else 
    if (IsInState('Firing'))
    {
        Pawn.StopFire(0);
        GotoState('FollowTarget', 'Begin');
    }
    else
    {
        GotoState('FollowTarget', 'Begin');
    }
   
}

defaultproperties
{
    CurrentGoal = None;
    FollowDistance = 700;		
}
