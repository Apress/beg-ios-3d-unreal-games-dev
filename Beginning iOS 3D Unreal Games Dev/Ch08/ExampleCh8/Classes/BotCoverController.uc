class BotCoverController extends UDKBot;

// Navigation 
var Actor CurrentGoal;
var Vector TempDest;
var Actor TempGoal;
 
// Cover Link 
var CoverLink CurrentCover;
var bool BotInCover; 

// Bot's Enemy 
var Pawn BotThreat;



function UnclaimAllSlots()
{
    local CoverLink CoverNodePointer;
    local CoverLink TempNodePointer;
    local bool done;

    CoverNodePointer = WorldInfo.Coverlist;

    done = false;
    while (!done)
    {
        CoverNodePointer.Unclaim(Pawn, 0, true); 
		
        if (CoverNodePointer.NextCoverLink != None)
        {
            TempNodePointer = CoverNodePointer.NextCoverLink;
            CoverNodePointer = TempNodePointer;
        }
        else
        {	
            done = true;
        }		
    }

    Pawn.ShouldCrouch(false);
    BotInCover = false;
}

function FindEnemyLocation(out vector EnemyLocation)
{	
    EnemyLocation = BotThreat.Location;
}

function CoverLink FindClosestEmptyCoverNodeWithinRange(Vector ThreatLocation, vector Position, float Radius)
{
    local CoverLink CoverNodePointer;
    local CoverLink TempNodePointer;
    local bool done;

    local CoverLink ValidCoverNode;
    local bool SlotValid;
    local bool SlotAvailable;
    local bool NodeFound;
    local int DefaultSlot;
	
    local float Dist2Cover;
    local float ClosestCoverNode;


    CoverNodePointer = WorldInfo.Coverlist;
    DefaultSlot = 0;  // Assume only 1 slot per cover node.
    ClosestCoverNode = 999999999;

    ValidCoverNode = None;
    NodeFound = false;

    done = false;
    while (!done)
    {	
        SlotValid = CoverLinkEx(CoverNodePointer).IsCoverSlotValid(0,ThreatLocation);
        SlotAvailable = CoverLinkEx(CoverNodePointer).IsCoverSlotAvailable(0);
       
        Dist2Cover =  VSize(CoverNodePointer.GetSlotLocation(DefaultSlot) - Position);
         
        if (SlotValid && SlotAvailable && (Dist2Cover < ClosestCoverNode)) 
        {
            ValidCoverNode = CoverNodePointer;
            ClosestCoverNode = Dist2Cover;
            NodeFound = true;
        }
       
        // Goto Next CoverNode
        if (CoverNodePointer.NextCoverLink != None)
        {
            TempNodePointer = CoverNodePointer.NextCoverLink;
            CoverNodePointer = TempNodePointer;
        }
        else
        {	
            // No more Cover Nodes
            done = true;
        }			
    }		
	
    if (!NodeFound)
    {
        WorldInfo.Game.Broadcast(self,"!!! Can Not Find Valid CoverNode");
    }

    return ValidCoverNode;
}

function bool IsCurrentCoverValid()
{
    local bool RetVal;
    local vector ThreatLoc;	


    RetVal = false;

    FindEnemyLocation(ThreatLoc);
    RetVal = CoverLinkEx(CurrentCover).IsCoverSlotValid(0, ThreatLoc);	
	
    return Retval;
}

function PrepMoveToCover()
{
    local vector ThreatLoc;
    local CoverLink NextCover;
	

    FindEnemyLocation(ThreatLoc);
    NextCover = FindClosestEmptyCoverNodeWithinRange(ThreatLoc, Pawn.Location, 9999999);
   

    if (NextCover != None)
    {
        WorldInfo.Game.Broadcast(self, self @ " moving to Next Cover " @ NextCover);
        CurrentCover = NextCover;
        CurrentGoal = CurrentCover;
        BotInCover = false;					
        UnclaimAllSlots();	
        CurrentCover.Claim(Pawn, 0);
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

state TakeCover
{
    Begin:

    //WorldInfo.Game.Broadcast(self,"NAVMESH, CurrentGoal = " @ CurrentGoal @ " , BotInCover = " @ BotInCover);

    if (CurrentGoal != None)
    {
        if(GeneratePathTo(CurrentGoal))
        {
            NavigationHandle.SetFinalDestination(CurrentGoal.Location);				
            if( NavigationHandle.ActorReachable(CurrentGoal) )
            {			
                // then move directly to the actor
                MoveTo(CurrentGoal.Location, BotThreat);
                BotInCover = true;	
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
                        MoveTo(TempDest, BotThreat);						
                    }
                }
            }	
        }
        else
        {
            //give up because the nav mesh failed to find a path	
            WorldInfo.Game.Broadcast(self,"FindNavMeshPath failed to find a path!, CurrentGoal = " @ CurrentGoal);
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

event WhatToDoNext()
{
    DecisionComponent.bTriggered = true;
}

protected event ExecuteWhatToDoNext()
{
    if (IsInState('Initial'))
    {
        PrepMoveToCover();
        GotoState('TakeCover', 'Begin');
    }
    else
    if (IsInState('TakeCover'))
    {
        if (BotInCover)
        {
            //Pawn.StopFire(0);
            if (IsCurrentCoverValid())
            {
                GotoState('TakeCover', 'Begin');
            }
            else
            {
                PrepMoveToCover();
                GotoState('TakeCover', 'Begin');
                //Pawn.StartFire(0);
            }
        }
        else
        {
            GotoState('TakeCover', 'Begin');
        }
    }
}

defaultproperties
{
    CurrentGoal = None;
    BotInCover = false;	
}
