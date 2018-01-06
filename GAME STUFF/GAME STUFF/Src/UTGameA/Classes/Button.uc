/**
 *	Button
 *
 *	Creation date: 11/06/2013 21:13
 *	Copyright 2013, Amol Kapoor
 */
class Button extends Actor
	ClassGroup(MyGame)
	placeable;

var(Button)    bool	bActive;    /// Whether or not trigger is active 

event Touch (Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	if (bActive)
	{
		if (Other.IsA('KActor') || Other.IsA('Pawn'))
		{
			`log("TOUCHED");
		//	TriggerEventClass(class'SeqEvent_ButtonTrigger',self, 0);
		}
	}
} 

event UnTouch(Actor Other)
{
	if (bActive && Touching.Length == 0) //creates 'empty' effect
	{
		if (Other.IsA('KActor') || Other.IsA('Pawn'))
		{
			`log("TOUCHED");
		//	TriggerEventClass(class'SeqEvent_ButtonTrigger',self, 0);
		}
	}
} 

simulated function bool StopsProjectile(Projectile P)
{
	return false;
}

//function FireSequenceEvent(int ActivationIndex)
//{
//	self.TriggerEventClass(class'SeqEvent_ButtonTrigger',self, ActivationIndex);
//}

defaultproperties
{

	begin object Class=StaticMeshComponent name=StaticMeshComponent0
		StaticMesh=StaticMesh'EditorMeshes.TexPropCylinder' 
		Materials[0]=Material'HU_Base.BSP.M_HU_Base_BSP_Bronze01' 
		AlwaysCheckCollision=true
		Scale3D=(X=0.6797,Y=0.6797,Z=0.0744)
		WireframeColor=(R=0,G=255,B=128,A=255)
	end object
	Components.Add(StaticMeshComponent0)

	Begin Object Class=CylinderComponent NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
		CollideActors=true
		CollisionRadius=+0060.000000
		CollisionHeight=+0020.000000
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

//	bCollideActors = true;
//	bBlockActors = true;

	//SupportedEvents.Add(class'SeqEvent_ButtonTrigger')
	SupportedEvents(0)=class'SeqEvent_Touch'

	bActive = false
}
