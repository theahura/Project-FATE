/**
 *	PortalAttachCube
 *
 *	Creation date: 04/09/2012 20:20
 *	Copyright 2012, Amol Kapoor
 */
class PortalAttachCube extends KActor
ClassGroup(MyGame)
	placeable;


defaultproperties
{
	 Begin Object Name=MyLightEnvironment
	bEnabled=TRUE
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

	Begin Object Name=StaticMeshComponent0
		BlockActors=true
		CollideActors=true
		WireframeColor=(R=0,G=255,B=128,A=255)
		BlockRigidBody=true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		bBlockFootPlacement=false
		StaticMesh=StaticMesh'EditorMeshes.TexPropCube'
		//StaticMesh=StaticMesh'MyGame.Meshes.S_BluePortal'
		//Materials[0]=Material'MyGame.Base_Teleporter.Material.DensePortalMat'
		Materials[0]=Material'GDC_Materials.Materials.M_ChromeSurface_01_Bright'
		Translation=(X=0, Y=0, Z=0.0)
		Scale3D=( X = .5, Y = .5, Z = .5)
	LightEnvironment=MyLightEnvironment
    end object

    Components.Add(StaticMeshComponent0)
    CollisionComponent=StaticMeshComponent0
    bCollideActors=true
    bBlockActors=true

}
