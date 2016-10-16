class BotAttackCoverController extends UDKBot;

// Navigation 
var Actor CurrentGoal;
var Vector TempDest;
var Actor TempGoal;
 
// Cover Link 
var CoverLink CurrentCover;
var bool BotInCover; 

// Bot's Enemy 
var Pawn BotThreat;

// Health Pickups
var bool bGotHealthPickup;
var int HealthPickupTrigger;

// Respawn
var bool bJustRespawned;

// Attack State 
var int AttackOffsetDist;
var bool bAttackDone;
var int AttackTimeInterval;
var bool bStartAttackEnemy;

 

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

    if (CurrentCover != None)
    {
        FindEnemyLocation(ThreatLoc);
        RetVal = CoverLinkEx(CurrentCover).IsCoverSlotValid(0, ThreatLoc);	
    }
	
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

    //Pawn.StopFire(0);

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


function AttackEnemyTimer()
{
    bStartAttackEnemy = true;
}

state TakeCover
{

    event BeginState( Name PreviousStateName )
    {
        // Put code here that is to only be executed when the state is first entered 
        bStartAttackEnemy = false;
        SetTimer(AttackTimeInterval, false, 'AttackEnemyTimer');  
    }

    event EndState( Name NextStateName )
    {
        // Put code here that is to be executed only when exiting this state		
    }


    Begin:

    //WorldInfo.Game.Broadcast(self,"BOTATTACKCOVERCONTROLLER - NAVMESH, CurrentGoal = " @ CurrentGoal @ 
    //                              ", CurrentCover = " @ CurrentCover @ " , BotInCover = " @ BotInCover @
    //                              ",bStartAttackEnemy = " @ bStartAttackEnemy);
    WorldInfo.Game.Broadcast(self,"*********** In State TAKECOVER");

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

function bool NeedHealthPickup()
{
    local bool bresult;

    if (Pawn.Health < HealthPickupTrigger)
    {
        bresult = true;
    }
    else 
    {
        bresult = false;
    }

    return bresult;
}

function Actor HealthPickupAvailable()
{
    local Bonus1 TempBonus;
    local Actor ReturnActor;
    local float ClosestDist;
    local float TempDist;

    ReturnActor = None;
    ClosestDist = 999999;

    foreach AllActors(class'Bonus1', TempBonus)
    {    
        TempDist = VSize(Pawn.Location - TempBonus.Location);
        If (TempDist < ClosestDist)
        {        
            ReturnActor = TempBonus;
            ClosestDist = TempDist;
        }
    }

    return ReturnActor;
}

function PrepGettingHealthPickup(Actor Pickup)
{
    UnclaimAllSlots();   
    CurrentGoal = Pickup;
    CurrentCover = None;
    bGotHealthPickup = false; 
}

state GettingHealthPickup
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

    WorldInfo.Game.Broadcast(self,"-----------> In state GettingHealthPickup");

    if (CurrentGoal != None)
    {
        if(GeneratePathTo(CurrentGoal))
        {
            NavigationHandle.SetFinalDestination(CurrentGoal.Location);				
            if( NavigationHandle.ActorReachable(CurrentGoal) )
            {			
                // then move directly to the actor
                //MoveTo(CurrentGoal.Location, BotThreat);
                MoveTo(CurrentGoal.Location);
                bGotHealthPickup = true;   	
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
            //WorldInfo.Game.Broadcast(self,"FindNavMeshPath failed to find a path!, CurrentGoal = " @ CurrentGoal);
            MoveTo(Pawn.Location);
        }   
    }

    LatentWhatToDoNext();
}

function PrepAttackingEnemy()
{
    bAttackDone = false;
 
    UnclaimAllSlots();   
    CurrentGoal = BotThreat;
    CurrentCover = None;

    Pawn.StartFire(0);
}

state AttackingEnemy
{
    event BeginState( Name PreviousStateName )
    {
        // Put code here that is to only be executed when the state is first entered  
        PrepAttackingEnemy();     
    }

    event EndState( Name NextStateName )
    {
        // Put code here that is to be executed only when exiting this state
        Pawn.StopFire(0);		
    }


    Begin:

    WorldInfo.Game.Broadcast(self,"############# In State AttackingEnemy");

   
    if (CurrentGoal != None)
    {
        if(GeneratePathTo(CurrentGoal))
        {
            NavigationHandle.SetFinalDestination(CurrentGoal.Location);				
            if( NavigationHandle.ActorReachable(CurrentGoal) )
            {			
                // then move directly to the actor
                MoveTo(CurrentGoal.Location, BotThreat, AttackOffsetDist);
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
                        MoveTo(TempDest, BotThreat);						
                    }
                }
            }	
        }
        else
        {
            //give up because the nav mesh failed to find a path	
            //WorldInfo.Game.Broadcast(self,"FindNavMeshPath failed to find a path!, CurrentGoal = " @ CurrentGoal);
            MoveTo(Pawn.Location);
        }   
    }

    LatentWhatToDoNext();
}

function ResetAfterSpawn()
{
    bJustRespawned = true;
}

function ExecuteResetAfterSpawn()
{
    UnclaimAllSlots();
    CurrentCover = None;
    CurrentGoal = None;
    bGotHealthPickup = false; 
    BotInCover = false;

    PrepMoveToCover();
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
    local Actor TempActor;


    if (bJustRespawned)
    {
        bJustRespawned = false;
        ExecuteResetAfterSpawn();
        GotoState('TakeCover', 'Begin');       
    }
    else
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
            TempActor = HealthPickupAvailable();
            if (NeedHealthPickup() && (TempActor != None))
            {
                // Health Pickup available and needed
                PrepGettingHealthPickup(TempActor);
                GotoState('GettingHealthPickup','Begin');                
            }
            else
            if (IsCurrentCoverValid())
            {
               if (bStartAttackEnemy)
               {               
                   GotoState('AttackingEnemy', 'Begin');
               } 
               else
               {
                   GotoState('TakeCover', 'Begin');
               }
            }
            else
            {
                PrepMoveToCover();
                GotoState('TakeCover', 'Begin');
            }
        }
        else
        {
            GotoState('TakeCover', 'Begin');
        }
    }
    else
    if (IsInState('GettingHealthPickup'))
    {
        if (!bGotHealthPickup)
        {
            GotoState('GettingHealthPickup','Begin');    
        }
        else
        {
            // Got Pickup Now Take Cover
            PrepMoveToCover();
            GotoState('TakeCover', 'Begin');
        }  
    }
    else
    if (IsInState('AttackingEnemy'))
    {
        if (!bAttackDone)
        {
            GotoState('AttackingEnemy', 'Begin');     
        }
        else 
        {
            PrepMoveToCover();
            GotoState('TakeCover', 'Begin');
        }
    }

}

defaultproperties
{
    CurrentGoal = None
    CurrentCover = None
    BotInCover = false

    bGotHealthPickup = false
    HealthPickupTrigger = 49
    bJustRespawned = false

    AttackOffsetDist = 700
    bAttackDone = false
    AttackTimeInterval = 3
    bStartAttackEnemy = false
}
