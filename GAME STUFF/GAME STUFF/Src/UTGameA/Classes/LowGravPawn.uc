/**
 *	LowGravPawn
 *
 *	Creation date: 08/09/2012 15:09
 *	Copyright 2012, Amol Kapoor
 */
class LowGravPawn extends MyPawn;

simulated event SpawnedByKismet ()
{
	super.PostBeginPlay();
    //Materials
    Mesh.SetMaterial(1, MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MHead01_V01_BLACK');
    Mesh.SetMaterial(0, MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MBody01_V01_BLACK');
	//`log("SUCCESS!"); 
	//SetCharacterMeshInfo(Mesh.SkeletalMesh, MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MHead01_V01_BLUE', MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MBody01_V01_BLUE');
}
defaultproperties
{
	CustomGravityScaling = 0.5 
}
