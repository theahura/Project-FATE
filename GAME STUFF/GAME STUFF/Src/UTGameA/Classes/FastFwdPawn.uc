/**
 *	FastFwdPawn
 *
 *	Creation date: 05/10/2012 20:29
 *	Copyright 2012, Amol Kapoor
 */
class FastFwdPawn extends MyPawn;

event PossessEvent()
{
	if (Controller.IsA('MyPlayerController'))
		MyPlayerController(Controller).FastFwd();
}

simulated event SpawnedByKismet ()
{
	super.PostBeginPlay();
    //Materials
    Mesh.SetMaterial(1, Material'MyGame.HeadMagiGirl_Mat');
    Mesh.SetMaterial(0, Material'MyGame.BodyMagiGirl_Mat');
	//`log("SUCCESS!"); 
	//SetCharacterMeshInfo(Mesh.SkeletalMesh, MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MHead01_V01_BLUE', MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MBody01_V01_BLUE');
}

defaultproperties
{
}
