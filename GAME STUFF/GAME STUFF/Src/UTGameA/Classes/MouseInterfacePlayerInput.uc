class MouseInterfacePlayerInput extends PlayerInput within MyPlayerController;

var PrivateWrite IntPoint MousePosition;

var float LastDuckTime;
var bool  bHoldDuck;

event PlayerInput(float DeltaTime)
{
	local FateHud MouseInterfaceHUD;

	// Handle mouse movement
	// Check that we have the appropriate HUD class
	MouseInterfaceHUD = FateHud(MyHUD);
	if (MouseInterfaceHUD != None)
	{
		if (!MouseInterfaceHUD.UsingScaleForm)
		{
			// If we are not using ScaleForm, then read the mouse input directly
			// Add the aMouseX to the mouse position and clamp it within the viewport width
			MousePosition.X = Clamp(MousePosition.X + aMouseX, 0, MouseInterfaceHUD.SizeX);
			// Add the aMouseY to the mouse position and clamp it within the viewport height
			MousePosition.Y = Clamp(MousePosition.Y - aMouseY, 0, MouseInterfaceHUD.SizeY);
		}
	}

	Super.PlayerInput(DeltaTime);
}

function SetMousePosition(int X, int Y)
{
    if (MyHUD != None)
	{


		MousePosition.X = Clamp(X, 0, MyHUD.SizeX);
		MousePosition.Y = Clamp(Y, 0, MyHUD.SizeY);
	}
}

simulated exec function Duck()
{
	if ( UTPawn(Pawn)!= none )
	{
		if (bHoldDuck)
		{
			bHoldDuck=false;
			bDuck=0;
			return;
		}

		bDuck=1;

		if ( WorldInfo.TimeSeconds - LastDuckTime < DoubleClickTime )
		{
			bHoldDuck = true;
		}

		LastDuckTime = WorldInfo.TimeSeconds;
	}
}

simulated exec function UnDuck()
{
	if (!bHoldDuck)
	{
		bDuck=0;
	}
}


defaultproperties
{
}