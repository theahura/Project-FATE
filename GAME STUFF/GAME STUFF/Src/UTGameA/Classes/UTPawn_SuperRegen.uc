/*******************************************************************************
	UTPawn_SuperRegen

	Creation date: 27/04/2010 17:54
	Copyright (c) 2010, Amol Kapoor
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class UTPawn_SuperRegen extends UTPawn;

var Int RegenPerSecond;

simulated function PostBeginPlay()
{
   Super.PostBeginPlay();

   SetTimer(1.0,true);
}

function Timer()
{
   if (Controller.IsA('PlayerController') && !IsInPain() && Health<SuperHealthMax)
   {
      Health = Min(Health+RegenPerSecond, SuperHealthMax);
   }
}

defaultproperties
{
   RegenPerSecond=5
}