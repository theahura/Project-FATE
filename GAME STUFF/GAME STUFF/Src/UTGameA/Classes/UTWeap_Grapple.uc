class UTWeap_Grapple extends UTBeamWeapon;

var bool bHooked;
var vector HookLocation, Force;
var float GrappleLength, Omega, CForce;
var int Counter;
var float CoolDowntime;

//var repnotify UTProj_GrappleHook GrappleHook;

var vector Destination, MyWallNormal, MyGrabbedNormal;
var float InRange;
var actor MyWallActor, MyGrabbedActor;

var bool bEmitter, bUseEmit, bDontPull;

var GrappleBuddy   Pullspot;

var float AirCont; 

/*THE FIRING SECTION */


simulated function StartFire(byte FireModeNum)
{
	
	local vector StartShot; /// World position of weapon trace start 
	local Rotator Aim; /// Player aim 
	local Vector HitLoc; 
	local Vector HitNorm; 
	local Actor HitActor; 
	
	local TraceHitInfo HitInfo; 

	AirCont = Instigator.AirControl; 

	bDontPull = false;
	bUseEmit = true;
	bHooked = false; 

	super.StartFire(FireModeNum); ///< Call the UTWeapon start fire function 


	//trace
	StartShot = Instigator.GetWeaponStartTraceLocation(); 
	Aim = GetAdjustedAim( StartShot ); 
	HitActor = Trace(HitLoc, HitNorm, (StartShot + (Normal(Vector(Aim)) * 2500.0)), StartShot, true, vect(0,0,0), HitInfo); 
	
	if (!HitActor.IsA('GrapplePortalWall') && !HitActor.IsA('KActor'))
	{
		bDontPull = true; 
		bUseEmit = true;
	}
	else if (HitActor == none)
	{
		bUseEmit = false;
		bDontPull = true;
	}

	
	PullSpot = SpawnBud(HitLoc);
	
	PullSpot.SetBase(HitActor);

	if (!bDontPull)
	{
		bHooked = true;
	}
	else 
		bHooked = false;
}

simulated function GrappleBuddy SpawnBud(vector HitLoc)
{
	local class<GrappleBuddy> NewBud;

	NewBud = class<GrappleBuddy>(DynamicLoadObject("UTGameA.GrappleBuddy", class'Class'));

	return Spawn( NewBud, , ,  HitLoc, , ,false);
}

simulated function UpdateBeam(float DeltaTime)
{
	local Vector		StartTrace, EndTrace, AimDir;
	local ImpactInfo	RealImpact;

	`log("Updatebeam");
	/* define range to use for CalcWeaponFire() */
	StartTrace	= Instigator.GetWeaponStartTraceLocation();
	AimDir = Vector(GetAdjustedAim( StartTrace ));
	EndTrace	= StartTrace + (2500 * Vector(GetAdjustedAim( Owner.Location )));
	
	/* Trace a shot*/
	RealImpact = CalcWeaponFire( StartTrace, EndTrace );
	bUsingAimingHelp = false;

	if (!RealImpact.HitActor.IsA('GrapplePortalWall') && !RealImpact.HitActor.IsA('PortalAttachCube'))
		return; 

	/* Grappling*/
	
	/* Don't start grappling if we're already grappling*/
	
	if (RealImpact.HitActor == None)
		return;


	ProcessBeamHit(StartTrace, AimDir, RealImpact, DeltaTime);
	UpdateBeamEmitter(RealImpact.HitLocation, RealImpact.HitNormal, RealImpact.HitActor);
	
}

simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo TestImpact, float DeltaTime)
{
	SetFlashLocation(TestImpact.HitLocation);
}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	if (BeamEmitter[CurrentFireMode] != none)
	{
		SetBeamEmitterHidden( !UTPawn(Instigator).IsFirstPerson());
		BeamEmitter[CurrentFireMode].SetVectorParameter(EndPointParamName,PullSpot.Location);
		/*subtract a bit from hookloc z?*/
	}
}



simulated state WeaponBeamFiring
{
	/* view shaking for the beam mode is handled in RefireCheckTimer() */
	simulated function ShakeView();

	simulated function Tick(float DeltaTime)
	{
		`log("bHooked: " $bHooked);
		if (bHooked)
		{
			Destination = PullSpot.Location;
			GrappleLength = VSize(Instigator.Location - Destination);

			if (GrappleLength < 30)
			{
				Instigator.SetPhysics(PHYS_Flying);
				Instigator.AirControl = 0.000000;
				Instigator.Velocity = Normal(Instigator.Velocity);
			}
			else
			{
				if (GrappleLength > 2000)
				{
					/**This is effectively the "refire", where we need to reset everything*/

					//ClearFlashLocation();


					/**This "pops" the player up after releasing the grapple, to allow for getting over ledges more easily*/
					Instigator.SetPhysics(PHYS_Falling);
					Instigator.AirControl = 0.350000;
					//GrappleHook = none;
					GrappleLength = 0;
				}
		
				Omega = VSize(Instigator.Velocity / GrappleLength) * DeltaTime;
				CForce = Instigator.Mass * GrappleLength * Omega ^ 2;
				Force = Normal(Destination - Instigator.Location);
				Force *= CForce;
				if (Instigator.Physics != PHYS_Falling)
				{
					Instigator.SetPhysics(PHYS_Falling);
				/*	Instigator.SetPhysics(PHYS_RigidBody); /*try me*/*/
					/*Pop player up slightly to ensure a smooth "pull" and not revert to Walking*/
					Instigator.Velocity += vect(0,0,200) + VRand() * 64;
				}
				if 	(Instigator.Physics == PHYS_Falling)
				{
					Instigator.AirSpeed = 900;
					Instigator.AirControl = 0.000000;
					Instigator.Velocity += DeltaTime * Force * 9;
					
					/**Clamp maximum velocity (creates a more floaty feel)*/
					if (VSize(Instigator.Velocity) > 10000)
						Instigator.Velocity = Normal(Instigator.Velocity) * 10000;
					else if (VSize(Instigator.Velocity) < -10000)
						Instigator.Velocity = - (Normal(Instigator.Velocity) * 10000);
				}
			}
		}
		/* Retrace everything and see if there is a new LinkedTo or if something has changed.*/
		if (bUseEmit)
		UpdateBeam(DeltaTime);
	}
	
	simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
	{
		/* Start muzzle flash effect*/
		CauseMuzzleFlash();

		ShakeView();
	}

	simulated function BeginState( Name PreviousStateName )
	{
		local UTPawn POwner;
		`log("Made it to BeginState"); 
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
		StartFire(CurrentFireMode); 
	}

	/* When leaving the state, shut everything down */
	simulated function EndState(Name NextStateName)
	{
		ClearTimer('RefireCheckTimer');
		ClearFlashLocation();

		if (BeamPostFireAnim[CurrentFireMode] != '')
		{
			PlayWeaponAnimation( BeamPostFireAnim[CurrentFireMode], 1.0);
		}

		super.EndState(NextStateName);
		
		Instigator.SetPhysics(PHYS_Falling);

		KillBeamEmitter();
		/*StartFire(FireModeNum); */

		Pullspot.Destroy();

		Instigator.AirControl = AirCont; 
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

function ConsumeAmmo( byte FireModeNum )
{
	/* dont consume ammo */
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
	WeaponFireTypes(0)=EWFT_InstantHit
	/*WeaponProjectiles(0)=class'UTProj_GrappleHook' */
	WeaponRange= 100
         Counter=0
	 CoolDowntime=0.50000
	 BeamTemplate(0)=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Gold'
	 BeamSockets(0)="MuzzleFlashSocket02"
	 EndPointParamName="LinkBeamEnd"
         AmmoCount=0
	 MaxAmmoCount=0
         ShotCost(0)=0
	 AttachmentClass=Class'UTAttachment_GrappleHook'
     InventoryGroup=1
	 PlayerViewOffset=(X=16.000000,Y=-18.000000,Z=-18.000000)
	 FiringStatesArray(0)="WeaponBeamFiring"
	 FireOffset=(X=12.000000,Y=10.000000,Z=-10.000000)
	 BeamPreFireAnim(0)="WeaponAltFireStart"
     BeamFireAnim(0)="WeaponAltFire"
     BeamPostFireAnim(0)="WeaponAltFireEnd"
	 /*WeaponFireSnd(0)=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_AltFireCue'*/
	 bFastRepeater=True
	 FireInterval(1)=0.350000
     Begin Object Name=FirstPersonMesh ObjName=FirstPersonMesh Archetype=UTSkeletalMeshComponent'UTGame.Default__UTBeamWeapon:FirstPersonMesh'
      FOV=60.000000
      SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_Linkgun_1P'
      AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
	  Scale=0.700000
     /* ObjectArchetype=UTSkeletalMeshComponent'UTGame.Default__UTBeamWeapon:FirstPersonMesh'*/
	 End Object
	 Begin Object Name=PickupMesh ObjName=PickupMesh Archetype=SkeletalMeshComponent'UTGame.Default__UTBeamWeapon:PickupMesh'
      SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
      ObjectArchetype=SkeletalMeshComponent'UTGame.Default__UTBeamWeapon:PickupMesh'
     End Object
     DroppedPickupMesh=PickupMesh
     PickupFactoryMesh=PickupMesh
	
	GrappleLength = 0
	bEmitter = false 

	bDontPull = false
	bUseEmit = true
}
