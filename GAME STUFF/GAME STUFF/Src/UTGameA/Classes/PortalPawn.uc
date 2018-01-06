/**
 *	PortalPawn
 *
 *	Creation date: 07/10/2012 21:33
 *	Copyright 2012, Amol Kapoor
 */
class PortalPawn extends MyPawn;

simulated event SpawnedByKismet ()
{
	local Weapon NewWeapon;

	NewWeapon = Spawn(Class'EG_PortalWeap');
	NewWeapon.GiveTo(Self);
	
	super.PostBeginPlay();
    //Materials
	Mesh.SetMaterial(1, Material'MyGame.HeadGrey_Mat');
    Mesh.SetMaterial(0, Material'MyGame.BodyGrey_Mat');
	//`log("SUCCESS!"); 
	//SetCharacterMeshInfo(Mesh.SkeletalMesh, MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MHead01_V01_BLUE', MaterialInstanceConstant'MyGame.Materials.MI_CH_Corrupt_MBody01_V01_BLUE');
}



defaultproperties
{
}
