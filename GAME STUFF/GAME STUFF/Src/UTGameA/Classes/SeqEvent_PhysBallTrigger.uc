// extend UIEvent if this event should be UI Kismet Event instead of a Level Kismet Event
class SeqEvent_PhysBallTrigger extends SequenceEvent;

event Activated()
{
	`log(self@"SeqEvent_PhysBallTrigger activated"); /// Just so we know it's working
}

defaultproperties
{
	/// Kismet catagory name
	ObjCategory="PhysBall Events"
	/// Name of object within catagory
	ObjName="PhysBallTrigger"
	bPlayerOnly=false

	/// Define name of Kismet output nodes
	OutputLinks(0)=(LinkDesc="Activated")
	OutputLinks(1)=(LinkDesc="Deactivated")
}
