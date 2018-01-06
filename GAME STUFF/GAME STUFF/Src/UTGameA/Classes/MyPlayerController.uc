/**
 *	MyPlayerController
 *
 *	Creation date: 02/08/2012 22:19
 *	Copyright 2012, Amol Kapoor
 */
class MyPlayerController extends UTPlayerController;

var int CrashingDistance; 

//var String LastLevel

/*
 * event NotifyLoadedWorld
 * iterate through 'my playerstarts'
 * find one with lastlevel == playerstart.levelvar
 * SetLocation + SetRotation
 */


//this function is called by a button press
exec function PawnSwap()
{

	local vector StartShot; /// World position of weapon trace start 
	local Rotator Aim; /// Player aim 

    local MyPawn OtherP;
	local MyPawn AllP; 
	local Vector HitLoc; 
	local Vector HitNorm; 
	local TraceHitInfo HitInfo; 
	


	//local Vector PlayerLoc;

	GetPlayerViewPoint(StartShot, Aim); 
	 

	foreach  TraceActors(class 'MyPawn', OtherP, HitLoc, HitNorm, (StartShot + (Normal(Vector(Aim)) * CrashingDistance)), StartShot, vect(0,0,0), HitInfo)   
	{ 
			foreach WorldInfo.AllPawns(class'MyPawn', AllP)
			{
				AllP.thePlayer = OtherP;
			}

			  //possess the pawn
			  UnPossess(); 
			  Possess(OtherP, false);
			  OtherP.PossessEvent();
			  `log("Swap Success!");
			  break;
	}
 //   ForEach Pawn.OverlappingActors(class'MyPawn', OtherP, CrashingDistance)
  //  {
      //  if (OtherP != None) //if there is one close enough
       // {
			
    //    }
 //   }
}

exec function TeleportZ()
{
	local Actor		HitActor;
	local vector	HitNormal, HitLocation;
	local vector	ViewLocation;
	local rotator	ViewRotation;

	if (!Pawn.IsA('JJPawn'))
		return; 

	GetPlayerViewPoint( ViewLocation, ViewRotation );

	HitActor = Trace(HitLocation, HitNormal, ViewLocation + 1000000 * vector(ViewRotation), ViewLocation, true);
	if ( HitActor != None)
		HitLocation += HitNormal * 4.0;

	ViewTarget.SetLocation( HitLocation );
}

//stay state
exec function SetStay() //bot sees player
{
		local vector StartShot; /// World position of weapon trace start 
	local Rotator Aim; /// Player aim 

    local MyPawn OtherP;
	local Vector HitLoc; 
	local Vector HitNorm; 
	local TraceHitInfo HitInfo; 
	


	//local Vector PlayerLoc;

	GetPlayerViewPoint(StartShot, Aim); 
	 

	foreach  TraceActors(class 'MyPawn', OtherP, HitLoc, HitNorm, (StartShot + (Normal(Vector(Aim)) * CrashingDistance)), StartShot, vect(0,0,0), HitInfo)   
	{
		OtherP.SetStay();
		break;
	}
}

//follow state
 exec function SetFollow() //bot sees player
{	
			local vector StartShot; /// World position of weapon trace start 
	local Rotator Aim; /// Player aim 

    local MyPawn OtherP;
	local Vector HitLoc; 
	local Vector HitNorm; 
	local TraceHitInfo HitInfo; 
	


	//local Vector PlayerLoc;

	GetPlayerViewPoint(StartShot, Aim); 
	 

	foreach  TraceActors(class 'MyPawn', OtherP, HitLoc, HitNorm, (StartShot + (Normal(Vector(Aim)) * CrashingDistance)), StartShot, vect(0,0,0), HitInfo)   
	{
		OtherP.SetFollow();
		break;
	}
}

simulated function SloMo()
{
	WorldInfo.Game.SetGameSpeed(0.1);
	Pawn.CustomTimeDilation = 10;
}


simulated function FastFwd()
{
	WorldInfo.Game.SetGameSpeed(10);
	Pawn.CustomTimeDilation = 0.1;
}

simulated function NormSpeed()
{
	WorldInfo.Game.SetGameSpeed(1);
	Pawn.CustomTimeDilation = 1;
}

defaultproperties
{
        //how close to the pawn we have to be
	CrashingDistance = 400

}
