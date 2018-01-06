/*******************************************************************************
	FateGameType

	Creation date: 29/04/2010 16:52
	Copyright (c) 2010, Amol Kapoor
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class FateGameType extends UTGame 
	config(game);

var config vector SavePlayerLocation;

var class<UTVehicle> HoverboardClass;

var array <MyPawn> PawnArray;

exec function DoSave() 
{
    SavePlayerLocation = GetALocalPlayerController().Pawn.Location;
    SaveConfig();
}

exec function LoadSave() 
{
    GetALocalPlayerController().Pawn.SetLocation(SavePlayerLocation);
}

function SetPlayerDefaults(Pawn PlayerPawn)
{
	if ( UTPawn(PlayerPawn) != None )
	{
		UTPawn(PlayerPawn).HoverboardClass = HoverboardClass;
	}
	super.SetPlayerDefaults(PlayerPawn);
}

simulated function Tick(float DeltaTime)
{ 
	local int index; 

//	`log ("HI!");
//	`log ("Length: " $PawnArray.Length); 
	for (index = 0; index < PawnArray.Length; ++index) 
	{
//		`log ("Health: " $PawnArray[index].Health); 
		if(PawnArray[index].Health <= 0 )
			ConsoleCommand("open ?restart");
	}
}


defaultproperties
{

	Acronym="F"
	MapPrefixes[0]="F"

	bDelayedStart=false
	DefaultPawnClass=class'UTGameA.MyPawn'
	PlayerControllerClass=class'UTGameA.MyPlayerController'
	OnlineGameSettingsClass=class'UTGameA.FateGameSettings'
	HUDType=class'UDKBase.UDKHUD'

	Name = "FateGame"


	bAllowHoverboard=true

	HoverboardClass=class'UTVehicle_Hoverboard_Content'

	bRestartLevel = true;

//bTeamScoreRounds=false
}

