/**
 *	JumpPawn
 *
 *	Creation date: 08/09/2012 12:44
 *	Copyright 2012, Amol Kapoor
 */
class JumpPawn extends MyPawn;

simulated event SpawnedByKismet ()
{
	super.PostBeginPlay();
    //Materials
    Mesh.SetMaterial(1, MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MHead01_V01_RED');
    Mesh.SetMaterial(0, MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MBody01_V01_RED');
	//`log("SUCCESS!"); 
	//SetCharacterMeshInfo(Mesh.SkeletalMesh, MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MHead01_V01_BLUE', MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MBody01_V01_BLUE');
}


defaultproperties
{
	JumpZ = 1000;
}
