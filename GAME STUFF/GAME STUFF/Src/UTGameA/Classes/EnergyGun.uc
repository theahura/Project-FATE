/**
 *	EnergyGun
 *
 *	Creation date: 06/08/2012 12:49
 *	Copyright 2012, Amol Kapoor
 */
class EnergyGun extends UTWeapon;

var float LastFireTime;

simulated function StartFire(byte FireModeNum)
{
	local EnergyBall LightBall; 
	if (FireModeNum == 0)
	{
		foreach WorldInfo.AllActors(class'EnergyBall', LightBall)
		{
			LightBall.Explode(LightBall.Location, LightBall.Location);
		}
		super.StartFire(FireModeNum);
	}
	
	StopFire(FireModeNum);
}

//function ConsumeAmmo( byte FireModeNum )
//{
//	SetTimer(60, false, 'RechargeAmmo');
//	super.ConsumeAmmo(FireModeNum);
//}

//function RechargeAmmo()
//{
//	if ( AmmoCount < MaxAmmoCount )
//	{
//		AmmoCount += 1;
//	}
//}

simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	return true; 
}

simulated function bool HasAnyAmmo()
{
	return true; 
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'EnergyBall'

	 ///< The rest of this simply copies the meshes, attachements, muzzle effects,
	///< etc.. from the UTWeap_LinkGun class so that we don't have to worry about
	///< needing to create any custom assets for the weapon.
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
		AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
		Animations=MeshSequenceA
		Scale=0.9
		FOV=60.0
	End Object

	///< Change MuzzleFlashAlEGSCTemplate because we changed the alt-fire behavior
	///< away from the UTWeap_LinkGun alt-fire.
	//MuzzleFlashAlEGSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'
	MuzzleFlashPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'
	bMuzzleFlashPSCLoops=false
	MuzzleFlashLightClass=class'UTGame.UTLinkGunMuzzleFlashLight'
	AttachmentClass=class'UTAttachment_Linkgun'
	EffectSockets(0)=MuzzleFlashSocket
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashColor=(R=120,G=120,B=120,A=255)
	MuzzleFlashDuration=0.33;
	WeaponColor=(R=255,G=255,B=0,A=255)
	PlayerViewOffset=(X=16.0,Y=-18,Z=-18.0)
	FireOffset=(X=12,Y=10,Z=-10)

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
	End Object

	AmmoCount=1
	LockerAmmoCount=1
	MaxAmmoCount=1

	//LastFireTime = -30 
}
