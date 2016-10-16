class BotControllerGuard extends UDKBot;

var Actor CurrentGoal;
var Vector TempDest;
var Actor TempGoal;

var float GuardDistance;
var float AttackDistance;
var float GuardRadius;

var Actor GuardedStructure;

var Pawn Threat;				


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

function Actor FindUnguardedGenerator()
{
    local Generator TempGenerator;
    local Actor ReturnGenerator;

    ReturnGenerator = None;
    foreach AllActors(class'Generator', TempGenerator)
    {
        if(TempGenerator.Guard == None)
        { 
            ReturnGenerator = TempGenerator; 
        }            
    }

    return ReturnGenerator;   
}

state Guarding
{
    event BeginState( Name PreviousStateName )
    {
        // Put code here that is to only be executed when the state is first entered 
        CurrentGoal = GuardedStructure; 
        Threat = None; 
    }

    event EndState( Name NextStateName )
    {
        // Put code here that is to be executed only when exiting this state		
    }


    Begin:

    //WorldInfo.Game.Broadcast(self,"BotControllerGuard-USING NAVMESH FOR FOLLOWTARGET STATE");

    // Move Bot to Target
    if (CurrentGoal != None)
    {
        if(GeneratePathTo(CurrentGoal))
        {
            NavigationHandle.SetFinalDestination(CurrentGoal.Location);				
            if( NavigationHandle.ActorReachable(CurrentGoal) )
            {			
                // then move directly to the actor	
                MoveTo(CurrentGoal.Location, CurrentGoal,GuardDistance);	
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
            WorldInfo.Game.Broadcast(self,"GUARDING - FindNavMeshPath failed to find a path!, CurrentGoal = " @ CurrentGoal);
            MoveTo(Pawn.Location);
        }   
    }
    LatentWhatToDoNext();
}

function bool IsInPatrolRange()
{
    local bool retval;
    local float Distance;


    Distance = VSize(Pawn.Location - GuardedStructure.Location);
 
    if (Distance <= GuardRadius)
    {
        retval = true;   
    }
    else
    {
        retval = false;  
    }

    return retval;  
}

state Attacking
{

   event BeginState( Name PreviousStateName )
    {
        // Put code here that is to only be executed when the state is first entered 
        CurrentGoal = Threat;
        Pawn.StartFire(0);	 
        
    }

    event EndState( Name NextStateName )
    {
        // Put code here that is to be executed only when exiting this state	
        Pawn.StopFire(0);	
    }


    Begin:

    //WorldInfo.Game.Broadcast(self,"BotControllerGuard-USING NAVMESH FOR FOLLOWTARGET STATE");

    // Move Bot to Target
    if (CurrentGoal != None)
    {
        if(GeneratePathTo(CurrentGoal))
        {
            NavigationHandle.SetFinalDestination(CurrentGoal.Location);				
            if( NavigationHandle.ActorReachable(CurrentGoal) )
            {			
                // then move directly to the actor	
                MoveTo(CurrentGoal.Location, CurrentGoal,AttackDistance);	
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
            WorldInfo.Game.Broadcast(self,"GUARDING - FindNavMeshPath failed to find a path!, CurrentGoal = " @ CurrentGoal);
            MoveTo(Pawn.Location);
        }   
    }

    if (!IsInPatrolRange())
    {
         GotoState('Guarding', 'Begin');
    }

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
    local Actor TempGenerator;

    if (IsInState('Initial'))
    {     
        TempGenerator = FindUnguardedGenerator();
        if (TempGenerator != None)
        {
            Generator(TempGenerator).Guard = Pawn; 
            GuardedStructure = TempGenerator; 
            GotoState('Guarding', 'Begin');
        }
        else
        {
            GotoState('Inital', 'Begin');
        }
    }
    else
    if (IsInState('Guarding'))
    {
        if (Threat != None)
        {
            GotoState('Attacking', 'Begin');
        }     
        else
        {
            GotoState('Guarding', 'Begin');
        }
    }
    else 
    if (IsInState('Attacking'))
    {
       GotoState('Attacking', 'Begin');
    }  
}

defaultproperties
{
    CurrentGoal = None
    GuardDistance = 300
    AttackDistance = 200
    Threat = None
    GuardRadius = 1000;		
}
