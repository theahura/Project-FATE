/**
 *	UTWeap_PhysicsGun2
 *
 *	Creation date: 19/06/2012 16:08
 *	Copyright 2012, Amol Kapoor
 */
class UTWeap_PhysicsGun2 extends UTBeamWeapon;
/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */

var()				float			WeaponImpulse;
var()				float			HoldDistanceMin;
var()				float			HoldDistanceMax;
var()				float			ThrowImpulse;
var()				float			ChangeHoldDistanceIncrement;

var					RB_Handle		PhysicsGrabber;
var					float			HoldDistance;
var					Quat			HoldOrientation;

var                 bool            grabbed;

var                 bool            Poked;

//---------------------------------------------------------


var bool bCoolingoff;
var bool bHooked;
var vector HookLocation, Force;
var float GrappleLength, Omega, CForce;
var int Counter;
var float CoolDowntime;

var KActor GrabbedActor;

var bool DontUpdate; 

simulated function PostBeginPlay()
{
	Super.PostbeginPlay();
}

/**
 * This function is called from the pawn when the visibility of the weapon changes
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	Super.ChangeVisibility(bIsVisible);
}

simulated function StartFire(byte FireModeNum)
{
	local vector					StartShot, EndShot, PokeDir;
	local vector					HitLocation, HitNormal, Extent;
	local actor						HitActor;
	local float						HitDistance;
	local Quat						PawnQuat, InvPawnQuat, ActorQuat;
	local TraceHitInfo				HitInfo;
	local SkeletalMeshComponent		SkelComp;
	local Rotator					Aim;
	local PhysAnimTestActor			PATActor;
	local StaticMeshComponent HitComponent;
	local KActorFromStatic NewKActor;

	if ( Role < ROLE_Authority )
		return;

	DontUpdate = false; 

	KillBeamEmitter(); 
	// Do ray check and grab actor
	StartShot	= Instigator.GetWeaponStartTraceLocation();
	Aim			= GetAdjustedAim( StartShot );
	EndShot		= StartShot + (10000.0 * Vector(Aim));
	Extent		= vect(0,0,0);
	HitActor	= Trace(HitLocation, HitNormal, EndShot, StartShot, True, Extent, HitInfo, TRACEFLAG_Bullet);
	if (HitActor.IsA('KActor'))
	GrabbedActor = KActor(HitActor);
	HitDistance = VSize(HitLocation - StartShot);

	HitComponent = StaticMeshComponent(HitInfo.HitComponent);
	if ( (HitComponent != None) ) 
	{
		if(HitInfo.PhysMaterial != none)
		{
			if(HitInfo.PhysMaterial.ImpactSound != none)
			{
				PlaySound(HitInfo.PhysMaterial.ImpactSound,,,,HitLocation);
			}

			if(HitInfo.PhysMaterial.ImpactEffect != none)
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(HitInfo.PhysMaterial.ImpactEffect, HitLocation, rotator(HitNormal), none);
			}
		}

		if( HitComponent.CanBecomeDynamic() )
		{
			NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitComponent);
			if ( NewKActor != None )
			{
				HitActor = NewKActor; 
			}
		}
	}

	// POKE
	if(FireModeNum == 0)
	{
		Poked = true; 
		PokeDir = Vector(Aim);

		if ( PhysicsGrabber.GrabbedComponent == None )
		{
			// `log("HitActor:"@HitActor@"Hit Bone:"@HitInfo.BoneName);
			if( HitActor != None &&
				HitActor != WorldInfo &&
				HitInfo.HitComponent != None )
			{
				PATActor = PhysAnimTestActor(HitActor);
				if(PATActor != None)
				{
					if( !PATActor.PrePokeActor(PokeDir) )
					{
						return;
					}
				}

				HitInfo.HitComponent.AddImpulse(PokeDir * WeaponImpulse, HitLocation, HitInfo.BoneName);
			}
		}
		else
		{
			PhysicsGrabber.GrabbedComponent.AddImpulse(PokeDir * ThrowImpulse, , PhysicsGrabber.GrabbedBoneName);
			PhysicsGrabber.ReleaseComponent();
		}
	}
	// GRAB
	else
	{
		Poked = false; 
		if( HitActor != None &&
			HitActor != WorldInfo &&
			HitInfo.HitComponent != None &&
			HitDistance > HoldDistanceMin &&
			HitDistance < HoldDistanceMax )
		{
			PATActor = PhysAnimTestActor(HitActor);
			if(PATActor != None)
			{
				if( !PATActor.PreGrab() )
				{
					return;
				}
			}

			// If grabbing a bone of a skeletal mesh, dont constrain orientation.
			SkelComp = SkeletalMeshComponent(HitInfo.HitComponent);
			PhysicsGrabber.GrabComponent(HitInfo.HitComponent, HitInfo.BoneName, HitLocation, (SkelComp == None) && (PlayerController(Instigator.Controller).bRun==0));

			// If we succesfully grabbed something, store some details.
			if (PhysicsGrabber.GrabbedComponent != None)
			{
				HoldDistance	= HitDistance;
				PawnQuat		= QuatFromRotator( Rotation );
				InvPawnQuat		= QuatInvert( PawnQuat );

				if ( HitInfo.BoneName != '' )
				{
					ActorQuat = SkelComp.GetBoneQuaternion(HitInfo.BoneName);
				}
				else
				{
					ActorQuat = QuatFromRotator( PhysicsGrabber.GrabbedComponent.Owner.Rotation );
				}

				HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
				grabbed = true;
			}
		}
	}

	Super.StartFire( FireModeNum );

	GoToState('WeaponBeamFiring');
}

simulated function StopFire(byte FireModeNum)
{
	local PhysAnimTestActor	PATActor;

	if ( PhysicsGrabber.GrabbedComponent != None )
	{
		PATActor = PhysAnimTestActor(PhysicsGrabber.GrabbedComponent.Owner);
		if(PATActor != None)
		{
			PATActor.EndGrab();
		}

		PhysicsGrabber.ReleaseComponent();
	}

	Super.StopFire( FireModeNum );
	grabbed = false;
}

simulated function bool DoOverridePrevWeapon()
{
	if (grabbed)
	{
		HoldDistance += ChangeHoldDistanceIncrement;
		HoldDistance = FMin(HoldDistance, HoldDistanceMax);
		return true;
	}
	return false;
}

simulated function bool DoOverrideNextWeapon()
{
	if (grabbed)
	{
		HoldDistance -= ChangeHoldDistanceIncrement;
		HoldDistance = FMax(HoldDistance, HoldDistanceMin);
		return true;
	}
	return false;
}

simulated function Tick( float DeltaTime )
{
	local vector	NewHandlePos, StartLoc;
	local Quat		PawnQuat, NewHandleOrientation;
	local Rotator	Aim;

 	if ( PhysicsGrabber.GrabbedComponent == None )
 	{
		grabbed = false;
 		return;
 	}
	grabbed = true;
	PhysicsGrabber.GrabbedComponent.WakeRigidBody( PhysicsGrabber.GrabbedBoneName );

	// Update handle position on grabbed actor.
	if( Instigator != None )
	{
		StartLoc		= Instigator.GetWeaponStartTraceLocation();
		Aim				= GetAdjustedAim( StartLoc );
		NewHandlePos	= StartLoc + (HoldDistance * Vector(Aim));
		PhysicsGrabber.SetLocation( NewHandlePos );

		// Update handle orientation on grabbed actor.
		PawnQuat				= QuatFromRotator( Rotation );
		NewHandleOrientation	= QuatProduct(PawnQuat, HoldOrientation);
		PhysicsGrabber.SetOrientation( NewHandleOrientation );
	}
}

/**
 * Consumes some of the ammo
 */
function ConsumeAmmo( byte FireModeNum )
{
	// dont consume ammo
}


// THE BEAM EFFECT

simulated function UpdateBeam(float DeltaTime)
{
	local Vector		StartTrace, EndTrace, AimDir, RealStartLoc;
	local ImpactInfo	RealImpact;
	local Projectile	SpawnedProjectile;


	// define range to use for CalcWeaponFire()
	StartTrace	= Instigator.GetWeaponStartTraceLocation();
	AimDir = Vector(GetAdjustedAim( StartTrace ));
	EndTrace	= StartTrace + (2500 * Vector(GetAdjustedAim( Owner.Location )));
	
	
	// Trace a shot
	RealImpact = CalcWeaponFire( StartTrace, EndTrace );
	bUsingAimingHelp = false;

	// Allow children to process the hit
	ProcessBeamHit(StartTrace, AimDir, RealImpact, DeltaTime);
	UpdateBeamEmitter(RealImpact.HitLocation, RealImpact.HitNormal, RealImpact.HitActor);
	
	// Grappling
	
	// Don't start grappling if we're already grappling
	if (bHooked)
		return;
	
	if (RealImpact.HitActor == None)
		return;

	if (!RealImpact.HitActor.IsA('Pawn') && !RealImpact.HitActor.IsA('Projectile') && !RealImpact.HitActor.IsA('Decoration'))
	{
		bHooked = True;
		HookLocation = RealImpact.HitLocation;
		GrappleLength = VSize(HookLocation - Owner.Location);

               //Projectile spawn
               IncrementFlashCount();
		if( Role == ROLE_Authority )
		{
			// this is the location where the projectile is spawned.
			RealStartLoc = GetPhysicalFireStartLoc();
			// Spawn projectile	
			SpawnedProjectile = Spawn(class'UTProj_Physgun',,, RealStartLoc);

			if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
			{
				SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc )) );
			}
		}
		
		//Kick player
		//SetTimer(0.01,True,'UpdateGrappleStatus');
	}

}

simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo TestImpact, float DeltaTime)
{
	SetFlashLocation(TestImpact.HitLocation);
}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	if (BeamEmitter[CurrentFireMode] != none)
	{
		SetBeamEmitterHidden( !UTPawn(Instigator).IsFirstPerson() );
		if (PhysicsGrabber.GrabbedComponent != none)
		BeamEmitter[CurrentFireMode].SetVectorParameter(EndPointParamName,GrabbedActor.Location);
		else
		BeamEmitter[CurrentFireMode].SetVectorParameter(EndPointParamName,FlashLocation);
	}
}

// WEAPONBEAMFIRING


simulated state WeaponBeamFiring
{
	// view shaking for the beam mode is handled in RefireCheckTimer() 
	simulated function ShakeView();

	

	// When done firing, we have to make sure we unlink the weapon.
	simulated function EndFire(byte FireModeNum)
	{
		Global.EndFire(FireModeNum);

		if ( bWeaponPutDown )
		{
			// if switched to another weapon, put down right away
			GotoState('WeaponPuttingDown');
			return;
		}
		else
		{
			GotoState('Active');
		}
	}

	// Update the beam and handle the effects
	simulated function Tick(float DeltaTime)
	{
		local vector	NewHandlePos, StartLoc;
		local Quat		PawnQuat, NewHandleOrientation;
		local Rotator	Aim;

 		if (PhysicsGrabber.GrabbedComponent == None )
		{
			grabbed = false;	
		}
		else
		{
			grabbed = true;
			PhysicsGrabber.GrabbedComponent.WakeRigidBody( PhysicsGrabber.GrabbedBoneName );
			
			//`log("Distance: " $VSize(GrabbedActor.Location - Location)); 

			if (VSize(GrabbedActor.Location - Location) < HoldDistanceMin || GrabbedActor.bJustPortaled == true)
			{
				`log("Released"); 
				PhysicsGrabber.ReleaseComponent(); 
				KillBeamEmitter(); 
				GrabbedActor.bJustPortaled = false;
				return; 
			}

			// Update handle position on grabbed actor.
			 if( Instigator != None )
			{
				StartLoc		= Instigator.GetWeaponStartTraceLocation();
				Aim				= GetAdjustedAim( StartLoc );
				NewHandlePos	= StartLoc + (HoldDistance * Vector(Aim));
				PhysicsGrabber.SetLocation( NewHandlePos );

				// Update handle orientation on grabbed actor.
				PawnQuat				= QuatFromRotator( Rotation );
				NewHandleOrientation	= QuatProduct(PawnQuat, HoldOrientation);
				PhysicsGrabber.SetOrientation( NewHandleOrientation );
			}
		}
		


		// Retrace everything and see if there is a new LinkedTo or if something has changed.
				

		if ((Poked || (GrabbedActor != none && VSize(GrabbedActor.Location - Location) < HoldDistanceMin)) && !DontUpdate)
		{
			UpdateBeam(DeltaTime);
			SetTimer(0.1, false, 'KillBeamEmitter'); 
			DontUpdate = true;
			Poked = false; 
		}
		else if (!DontUpdate)
			UpdateBeam(DeltaTime); 
	}

	simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
	{
		// Start muzzle flash effect
		CauseMuzzleFlash();

		ShakeView();
	}

	event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		if ((SeqNode == None || SeqNode.AnimSeqName != BeamFireAnim[CurrentFireMode]) && BeamFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation(BeamFireAnim[CurrentFireMode],1.0,true);
		}
	}

	simulated function BeginState( Name PreviousStateName )
	{
		local UTPawn POwner;

		// Fire the first shot right away
		RefireCheckTimer();
		TimeWeaponFiring( CurrentFireMode );

		if (BeamPreFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation( BeamPreFireAnim[CurrentFireMode], 1.0);
		}
		else if (BeamFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation( BeamFireAnim[CurrentFireMode], 1.0);
		}

		POwner = UTPawn(Instigator);
		if (POwner != None)
		{
			AddBeamEmitter();
			POwner.SetWeaponAmbientSound(WeaponFireSnd[CurrentFireMode]);
		}
	}

	// When leaving the state, shut everything down
	simulated function EndState(Name NextStateName)
	{
		local UTPawn POwner;
		
		Poked = false; 

		POwner = UTPawn(Instigator);
		if (POwner != None)
		{
			POwner.SetWeaponAmbientSound(None);
		}

		ClearTimer('RefireCheckTimer');
		ClearFlashLocation();

		if (BeamPostFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation( BeamPostFireAnim[CurrentFireMode], 1.0);
		}

		super.EndState(NextStateName);
		
		KillBeamEmitter();

		//StopGrapple() equivalent
		bHooked = False;
		//SetTimer(0.01,False,'UpdateGrappleStatus');
		if (bCoolingOff == True)
		{
			//Do nothing and let it pass to CoolOff;
		}
		//GotoState('CoolOff');
	}

	simulated function bool IsFiring()
	{
		return true;
	}

	simulated function bool TryPutDown()
	{
		bWeaponPutDown = true;
		return false;
	}

}


// MISC


simulated function KillBeamEmitter()
{
	if (BeamEmitter[CurrentFireMode] != none)
	{
		BeamEmitter[CurrentFireMode].SetHidden(true);
		BeamEmitter[CurrentFireMode].DeactivateSystem();
	}
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	if (BeamEmitter[CurrentFireMode] != none)
		BeamEmitter[CurrentFireMode].SetHidden(bHide);
}

simulated function bool bReadyToFire()
{
	return true;
}



// Defaults.

defaultproperties
{
	HoldDistanceMin=100.0
	HoldDistanceMax=700.0
	WeaponImpulse=1000.0
	ThrowImpulse=1000.0
	ChangeHoldDistanceIncrement=25.0

	Begin Object Class=RB_Handle Name=RB_Handle0
		LinearDamping=1.0
		LinearStiffness=50.0
		AngularDamping=1.0
		AngularStiffness=50.0
	End Object
	Components.Add(RB_Handle0)
	PhysicsGrabber=RB_Handle0

	WeaponColor=(R=255,G=255,B=128,A=255)
	//FireInterval(0)=+1.0
	//FireInterval(1)=+1.0
	//PlayerViewOffset=(X=16.0,Y=-18,Z=-18.0)//(X=0.0,Y=7.0,Z=-9.0)

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Projectile

	//FireOffset=(X=12,Y=10,Z=-10)//(X=16,Y=10)

	AIRating=+0.75
	CurrentRating=+0.75
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	bCanThrow=false

	InventoryGroup=666
	GroupWeight=0.5

	AmmoCount=0
	LockerAmmoCount=0
	MaxAmmoCount=0

	bExportMenuData=false


	//MuzzleFlashAltPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'
	//MuzzleFlashPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'
	//bMuzzleFlashPSCLoops=false
	//MuzzleFlashLightClass=class'UTGame.UTLinkGunMuzzleFlashLight'
	
	grabbed = false

	 WeaponProjectiles(0)=Class'UTProj_Physgun'
         Counter=0
	 CoolDowntime=0.50000
	 BeamTemplate(0)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Red'
	 BeamSockets(0)="MuzzleFlashSocket02"
	 EndPointParamName="LinkBeamEnd"
         ShotCost(0)=0
	 AttachmentClass=Class'UTAttachment_GrappleHook'
	 PlayerViewOffset=(X=16.000000,Y=-18.000000,Z=-18.000000)
	 FiringStatesArray(0)="WeaponBeamFiring"
	 FireOffset=(X=12.000000,Y=10.000000,Z=-10.000000)
	 BeamPreFireAnim(0)="WeaponAltFireStart"
     BeamFireAnim(0)="WeaponAltFire"
     BeamPostFireAnim(0)="WeaponAltFireEnd"

	WeaponProjectiles(1)=Class'UTProj_Physgun'

	 BeamTemplate(1)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Blue'
	 BeamSockets(1)="MuzzleFlashSocket02"
         ShotCost(1)=0
	 FiringStatesArray(1)="WeaponBeamFiring"
	 BeamPreFireAnim(1)="WeaponAltFireStart"
     BeamFireAnim(1)="WeaponAltFire"
     BeamPostFireAnim(1)="WeaponAltFireEnd"

	 bFastRepeater=True
	 FireInterval(1)=0.350000
     Begin Object Name=FirstPersonMesh ObjName=FirstPersonMesh Archetype=UTSkeletalMeshComponent'UTGame.Default__UTBeamWeapon:FirstPersonMesh'
      FOV=60.000000
      SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
      AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
	  Scale=0.700000
     // ObjectArchetype=UTSkeletalMeshComponent'UTGame.Default__UTBeamWeapon:FirstPersonMesh'
	 End Object
	 Begin Object Name=PickupMesh ObjName=PickupMesh Archetype=SkeletalMeshComponent'UTGame.Default__UTBeamWeapon:PickupMesh'
      SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTBeamWeapon:PickupMesh'
     End Object
     DroppedPickupMesh=PickupMesh
     PickupFactoryMesh=PickupMesh

	DontUpdate = false; 
}
