 /**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_GravityRifle extends UTWeapon;

var class<UTDamageType> HeadShotDamageType;
var float HeadShotDamageMult;

var Texture2D HudMaterial;

var array<MaterialInterface> TeamSkins;

/** headshot scale factor when moving slowly or stopped */
var float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var float RunningHeadshotScale;

/** Zoom minimum time*/
var bool bAbortZoom;

/** sound while the zoom is in progress */
var audiocomponent ZoomLoop;
var soundcue ZoomLoopCue;

/** Whether the standard crosshair should be displayed */
var bool bDisplayCrosshair;

/** tracks number of zoom started calls before zoom is ended */
var int ZoomCount;

var float	FadeTime;


simulated function StartFire(byte FireModeNum)
{
	local UTWGravityBomb BlackHole;

	if(FireModeNum == 1)
	{
		foreach WorldInfo.AllActors(class'UTWGravityBomb', BlackHole)
		{
			//Spawn particle effect at BlackHoleLocation
				BlackHole.Oy();
		}
	}
	else 
		super.StartFire(FireModeNum); 
}


//-----------------------------------------------------------------
// AI Interface

function float SuggestAttackStyle()
{
    return -0.4;
}

function float SuggestDefenseStyle()
{
    return 0.2;
}

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{

	if( (Role == Role_Authority) && !bUsingAimingHelp )
	{
		// HeadDamage = InstantHitDamage[FiringMode]* HeadShotDamageMult;
		if ( UTPawn(Impact.HitActor) != None )
		{
			SetFlashLocation(Impact.HitLocation);
			return;
		}
	}

	super.ProcessInstantHit( FiringMode, Impact );
}



simulated function DrawWeaponCrosshair( Hud HUD )
{
	local UTPlayerController PC;

	if( bDisplayCrosshair )
	{
		PC = UTPlayerController(Instigator.Controller);
		if ( (PC == None) || PC.bNoCrosshair )
		{
			return;
		}
		super.DrawWeaponCrosshair(HUD);
	}
}

simulated function PreloadTextures(bool bForcePreload)
{
	Super.PreloadTextures(bForcePreload);

	if (HUDMaterial != None)
	{
		HUDMaterial.bForceMiplevelsToBeResident = bForcePreload;
	}
}


simulated function EndFire(Byte FireModeNum)
{

	super.EndFire(FireModeNum);
}


simulated function ChangeVisibility(bool bIsVisible)
{
	super.Changevisibility(bIsvisible);
	if(bIsVisible)
	{
		//PlayArmAnimation('WeaponZoomOut',0.00001); // to cover zooms ended while in 3p
	}
	if(!Instigator.IsFirstPerson()) // to be consistent with not allowing zoom from 3p
	{
		//LeaveZoom();
	}

}
simulated function RestartCrosshair()
{
	bDisplayCrosshair = true;
}

simulated function PutDownWeapon()
{
	super.PutDownWeapon();
}

simulated function HolderEnteredVehicle()
{
	local UTPawn UTP;

	// clear timers and reset anims


	// partially copied from PlayArmAnimation() - we don't want to abort if third person here because they definitely will
	// since they just got in a vehicle
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		UTP = UTPawn(Instigator);
		if (UTP != None)
		{
			// Check we have access to mesh and animations
			if (UTP.ArmsMesh[0] != None && ArmsAnimSet != None && GetArmAnimNodeSeq() != None)
			{
				//UTP.ArmsMesh[0].PlayAnim('WeaponZoomOut', 0.3, false);
			}
		}
	}
}


simulated function PlayWeaponPutDown()
{

	super.PlayWeaponPutDown();
}


simulated event CauseMuzzleFlash()
{

		super.CauseMuzzleFlash();
}

function byte BestMode()
{
	return 0;
}

simulated function vector GetEffectLocation()
{
	// tracer comes from center if zoomed in
	return Super.GetEffectLocation();
}

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
	WeaponColor=(R=255,G=0,B=64,A=255)
	PlayerViewOffset=(X=0,Y=0,Z=-0)

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_1P'
		PhysicsAsset=None
		AnimTreeTemplate=AnimTree'WP_RocketLauncher.Anims.AT_WP_RocketLauncher_1P_Base'
		AnimSets(0)=AnimSet'WP_RocketLauncher.Anims.K_WP_RocketLauncher_1P_Base'
		Translation=(X=0,Y=0,Z=0)
		Rotation=(Yaw=0)
		scale=1.0
		FOV=60.0
		bUpdateSkelWhenNotRendered=true
	End Object

	//SkeletonFirstPersonMesh = FirstPersonMesh;
	AttachmentClass=class'UTAttachment_GravityRifle'

    FireOffset=(X=0,Y=0,Z=0)

	// Pickup staticmesh
	//Components.Remove(PickupMesh)
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
        Scale=1.0
	End Object

	FireInterval(0)=+1.06
	FireInterval(1)=+1.06

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Custom
	//WeaponProjectiles(0)=class'UTProj_Gravity'
	WeaponProjectiles(0)=class'UTProj_GravityBomb'


	LockerRotation=(pitch=0,yaw=0,roll=-16384)

	MaxDesireability=0.63
	AIRating=+0.7
	CurrentRating=+0.7
	bInstantHit=true
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true

	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	InventoryGroup=9
	GroupWeight=0.5
	AimError=600


	AmmoCount=0
	LockerAmmoCount=0
	MaxAmmoCount=0

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=WP_RocketLauncher.Effects.P_WP_RockerLauncher_Muzzle_Flash
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'

	IconX=400
	IconY=129
	IconWidth=22
	IconHeight=48

	EquipTime=+0.6
	PutDownTime=+0.45
	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)

	bDisplaycrosshair = true;

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=30,RightAmplitude=50,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.200)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}
