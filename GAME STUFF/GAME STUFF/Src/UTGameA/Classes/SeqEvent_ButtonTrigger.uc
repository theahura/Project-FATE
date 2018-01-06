/**
 *	SeqEvent_ButtonTrigger
 *
 *	Creation date: 11/06/2013 21:49
 *	Copyright 2013, Amol Kapoor
 */
class SeqEvent_ButtonTrigger extends SequenceEvent;



defaultproperties
{
	/// Kismet catagory name
	ObjCategory="MyGame Events"
	/// Name of object within catagory
	ObjName="Button"
	bPlayerOnly=false

	/// Define name of Kismet output nodes
	OutputLinks(0)=(LinkDesc="Touched")
	OutputLinks(1)=(LinkDesc="UnTouched")
}