/**
 *	EmacipationGrill
 *
 *	Creation date: 10/08/2012 00:11
 *	Copyright 2012, Amol Kapoor
 */
class EmacipationGrill extends StaticMeshActor
		ClassGroup(MyGame)
	placeable;
	

simulated event Touch(actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
	local EG_Portal TempPortal;

	`log("Touched: " $Other); 

	if (Other.IsA('UTPawn'))
	{
		foreach AllActors( class 'EG_Portal', TempPortal )
		{
			TempPortal.Destroy();
		}
	}
	else if (Other.IsA('UTProj_GrappleHook'))
		Other.Destroy(); 
	else if (Other.IsA('UTProj_GravityBomb'))
		Other.Destroy(); 
	else if (Other.IsA('EnergyBall'))
		EnergyBall(Other).Explode(Other.Location, Other.Location); 
}

defaultproperties
{
	begin object name=StaticMeshComponent0
		StaticMesh=StaticMesh'EngineMeshes.Cube'
		Materials[0]=Material'WP_ShockRifle.Effects.M_Shock_colorball_mesh_sphere'
		BlockActors=false
		CollideActors=true
		BlockRigidBody=false
		Scale3D=( X = 0.001, Y = 0.5, Z = 0.5)
		//RBChannel=RBCC_GameplayPhysics
		//RBCollideWithChannels=(Default=TRUE, GameplayPhysics=TRUE, EffectPhysics=TRUE, Pawn=true)
	end object
	CollisionComponent=StaticMeshComponent0
	///TriggerMesh=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	


}
