/**
 *	MyAI
 *
 *	Creation date: 09/09/2012 18:20
 *	Copyright 2012, Amol Kapoor
 */
class MyAI extends GameAIController;

var MyPawn thePlayer1;

//simulated event PostBeginPlay()
//{
//	super.PostBeginPlay();
//	GoToState('Stay'); 
//}

state Stay
{
	Begin: 
	`log("State Stay: " $Pawn);
}

state Follow
{

	Begin:
		`log("State Follow: " $Pawn); 

		if (thePlayer1 != None)  // If we seen a player
		{
			if (VSize(thePlayer1.Location - Pawn.Location) > 100)
				MoveTo(thePlayer1.Location,,100); // Move directly to the players location
			
            GoToState('Looking'); //when we get there
		}

}

state Looking
{
	simulated function Tick(float DeltaTime)
	{
		`log("State Looking: " $Pawn); 
		if (VSize(thePlayer1.Location - Pawn.Location) > 100)
		GoToState('Follow');  // when we get there
	}
}

defaultproperties
{
}
