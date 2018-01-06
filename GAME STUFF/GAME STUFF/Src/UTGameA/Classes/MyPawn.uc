/**
 *	MyPawn
 *
 *	Creation date: 18/07/2012 16:18
 *	Copyright 2012, Amol Kapoor
 */
class MyPawn extends UTPawn;

var MyPawn thePlayer; 

var bool GoToFollow;

var bool GoToStay; 

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (WorldInfo.Game.IsA('FateGameType'))
	{
		`log("Added"); 
		FateGameType(WorldInfo.Game).PawnArray.InsertItem(0, self); 
	}
	else
		`log("What? " $WorldInfo.Game); 
}

simulated function SetFirstPersonArmsInfo(SkeletalMesh  FirstPersonArmMesh, MaterialInterface ArmMaterial)
{
	//NOTHING
}

simulated function Tick(float DeltaTime)
{
	if (Controller == none )
	{
		SpawnDefaultController();
	}

	if (MyAI(Controller) != none)
	{
		MyAI(Controller).thePlayer1 = thePlayer; 
		
		if (GoToStay == true && !MyAI(Controller).IsInState('Stay'))
		{
			MyAI(Controller).GoToState('Stay'); 
			`log("Pawn Set to Stay: " $self);
		}
		else if (GoToFollow == true && !MyAI(Controller).IsInState('Follow'))
		{
			MyAI(Controller).GoToState('Follow');		
			`log("Pawn Set to Follow: " $self);
		}
	}
}

simulated function SetFollow()
{
	GoToFollow = true; 
	GoToStay = false;
	`log("Follow Recieved");
}

simulated function SetStay()
{
	GoToStay = true;
	GoToFollow = false; 
	`log("Stay Recieved");
}

event PossessEvent()
{
if (Controller.IsA('MyPlayerController'))
		MyPlayerController(Controller).NormSpeed();
}

defaultproperties
{
	GoToStay = true
	GoToFollow = false
	ControllerClass = class'MyAI'

	MaxStepHeight = 60
}