/**
 *	EG_PortalLeft
 *
 *	Creation date: 08/05/2012 23:28
 *	Copyright 2012, Amol Kapoor
 */
class EG_PortalLeft extends EG_Portal;



defaultproperties
{
	Begin Object Name=PortalMesh
		BlockActors=false
		CollideActors=true
		BlockRigidBody=false
		StaticMesh=StaticMesh'MyGame.Meshes.PortalCube'
		//StaticMesh=StaticMesh'MyGame.Meshes.S_BluePortal'
		//Materials[0]=Material'MyGame.Base_Teleporter.Material.DensePortalMat'
		Materials[0]=Material'MyGame.Materials.Mat_PortalSceneMatBlue'
		Translation=(X=-1, Y=0, Z=0.0)
		Scale3D=( X = 0.001, Y = 0.5, Z = 0.5)
	End Object
	Mesh=PortalMesh
	CollisionComponent=PortalMesh
	Components.Add(PortalMesh)

}
