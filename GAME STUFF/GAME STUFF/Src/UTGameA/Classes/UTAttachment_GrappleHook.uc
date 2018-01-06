class UTAttachment_GrappleHook extends UTBeamWeaponAttachment;

//var repnotify UTProj_GrappleHook GrappleHook;
var repnotify UTWeap_Grapple MyGrapple;

state CurrentlyAttached
{
	simulated function BeginState(Name PreviousStateName)
	{
		PawnOwner = UTPawn(Owner);
		if (PawnOwner==none)
		{
			return;
		}
	}
	
	simulated function Tick(float DeltaTime)
	{
		
		//If we aren't firing or the owner and its not splitscreen, hide the emitter
		if  ( (PawnOwner == None))
		{
			return;
		}
	}
}
