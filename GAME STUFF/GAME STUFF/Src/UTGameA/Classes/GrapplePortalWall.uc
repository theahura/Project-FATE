/**
 *	NoGrapplePortalWall
 *
 *	Creation date: 09/08/2012 21:06
 *	Copyright 2012, Amol Kapoor
 */
class GrapplePortalWall extends StaticMeshActor
	ClassGroup(MyGame)
	placeable;


defaultproperties
{
		begin object name=StaticMeshComponent0
		StaticMesh=StaticMesh'EditorMeshes.TexPropCube'
		Materials[0]=Material'NEC_Base2.BSP.Materials.M_NEC_Base2_BSP_TileColors_01'
		Scale3D=(X=.5,Y=.5,Z=.5)
		WireframeColor=(R=0,G=255,B=128,A=255)
		BlockRigidBody=true
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
		RBChannel=RBCC_GameplayPhysics
		bUsePrecomputedShadows = true;
		RBCollideWithChannels=(Default=TRUE, GameplayPhysics=TRUE, EffectPhysics=TRUE, Pawn=true)
		end object
		CollisionComponent=StaticMeshComponent0
	///TriggerMesh=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)
	

}
