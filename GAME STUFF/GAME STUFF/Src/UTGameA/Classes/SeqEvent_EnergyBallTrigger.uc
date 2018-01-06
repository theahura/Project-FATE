/**
 *	SeqEvent_EnergyBallTrigger
 *
 *	Creation date: 06/08/2012 18:25
 *	Copyright 2012, Amol Kapoor
 */
class SeqEvent_EnergyBallTrigger extends SequenceEvent;


defaultproperties
{
	/// Kismet catagory name
	ObjCategory="PhysBall Events"
	/// Name of object within catagory
	ObjName="EnergyBallTrigger"
	bPlayerOnly=false

	/// Define name of Kismet output nodes
	OutputLinks(0)=(LinkDesc="Activated")
	OutputLinks(1)=(LinkDesc="Deactivated")
}