class BotAllyController extends UDKBot;

var Vector TempDest;

var float FollowDistanceTarget;
var float FollowDistanceMarker; 
			
var Actor TempGoal;

var float AttackOffsetDist;
var bool bAttackDone;

var Pawn BotOwner;

var Actor FollowTarget;
var Actor MoveToTarget;
var Actor AttackTarget;

enum BotCommand
{
    Follow,
    Move,
    Attack
};

var BotCommand Command;


function SetCommand(BotCommand Order, Actor Target)
{
    Command = Order;
    
    if (Command == Follow)
    {
       FollowTarget = Target;
    }
    else
    if (Command == Move)
    {
        MoveToTarget = Target;
    }
    else
    if (Command == Attack)
    {
        AttackTarget = Target;
        bAttackDone = false;
    }
}

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


state FollowingTarget
{
    event BeginState( Name PreviousStateName )
    {
        // Put code here that is to only be executed when the state is first entered  
       
    }

    event EndState( Name NextStateName )
    {
        // Put code here that is to be executed only when exiting this state
       	
    }


    Begin:

    WorldInfo.Game.Broadcast(self,"************** IN State FollowTarget ");

    // Move Bot to Target
    if (FollowTarget != None)
    {
        if(GeneratePathTo(FollowTarget))
        {
            NavigationHandle.SetFinalDestination(FollowTarget.Location);				
            if( NavigationHandle.ActorReachable(FollowTarget) )
            {			
                // then move directly to the actor	
                MoveTo(FollowTarget.Location, ,FollowDistanceTarget);		
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
            WorldInfo.Game.Broadcast(self,"FindNavMeshPath failed to find a path!, FollowTarget= " @ FollowTarget);
            MoveTo(Pawn.Location);
        }   
    }
    LatentWhatToDoNext();
}

state MovingToMarker
{
    event BeginState( Name PreviousStateName )
    {
        // Put code here that is to only be executed when the state is first entered  
       
    }

    event EndState( Name NextStateName )
    {
        // Put code here that is to be executed only when exiting this state
       	
    }


    Begin:

    WorldInfo.Game.Broadcast(self,"************** IN State MoveToMarker ");

    // Move Bot to Target
    if (MoveToTarget != None)
    {
        if(GeneratePathTo(MoveToTarget))
        {
            NavigationHandle.SetFinalDestination(MoveToTarget.Location);				
            if( NavigationHandle.ActorReachable(MoveToTarget) )
            {			
                // then move directly to the actor	
                MoveTo(MoveToTarget.Location, ,FollowDistanceMarker);		
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
            WorldInfo.Game.Broadcast(self,"FindNavMeshPath failed to find a path!, MoveToTarget= " @ MoveToTarget);
            MoveTo(Pawn.Location);
        }   
    }
    LatentWhatToDoNext();
}

state AttackingEnemy
{
    event BeginState( Name PreviousStateName )
    {
        // Put code here that is to only be executed when the state is first entered  
        Pawn.StartFire(0);  
        bAttackDone = false;       
    }

    event EndState( Name NextStateName )
    {
        // Put code here that is to be executed only when exiting this state
        Pawn.StopFire(0);    	
    }


    Begin:

    WorldInfo.Game.Broadcast(self,"############# In State AttackingEnemy");
    
    if (AttackTarget != None)
    {
        if(GeneratePathTo(AttackTarget))
        {
            NavigationHandle.SetFinalDestination(AttackTarget.Location);				
            if( NavigationHandle.ActorReachable(AttackTarget) )
            {			
                // then move directly to the actor 
                MoveTo(AttackTarget.Location, AttackTarget, AttackOffsetDist); 
                bAttackDone = true;           	
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
                        MoveTo(TempDest, AttackTarget);						
                    }
                }
            }	
        }
        else
        {
            //give up because the nav mesh failed to find a path	
            WorldInfo.Game.Broadcast(self,"FindNavMeshPath failed to find a path!,AttackTarget = " @ AttackTarget);
            MoveTo(Pawn.Location);
        }   
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
    if (IsInState('Initial'))
    {
        GotoState('FollowingTarget', 'Begin');
    }
    else 
    if (Command == Follow)
    {
        GotoState('FollowingTarget', 'Begin');
    }
    else 
    if (Command == Move)
    {
        GotoState('MovingToMarker', 'Begin');
    }
    else 
    if (Command == Attack)
    {   
        if (!bAttackDone)
        {
            GotoState('AttackingEnemy', 'Begin');
        }
        else
        {
            Command = Follow;
            GotoState('FollowingTarget', 'Begin');          
        }
    }  
}

defaultproperties
{
    FollowDistanceTarget = 250;
    FollowDistanceMarker = 75;

    AttackOffsetDist = 500;	
    bAttackDone = false	
}
