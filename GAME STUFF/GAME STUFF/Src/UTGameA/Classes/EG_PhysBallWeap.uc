/**
 * Copyright 2011, Greg Vanderpool
 */
class EG_PhysBallWeap extends UTWeapon;

/**
 * Animation names used by gun
 */
struct PhysGunAnimGroup
{
	var name    ThrowAnim;  ///< Name of throw animation
	var name    PokeAnim;   ///< Name of poke animation
	var name    PullAnim;   ///< Name of pull animation
};

/// Variables
var     bool	bBallCharged;       ///< Whether or not ball is charged
var     bool	bCanPull;           ///< Disables the gun from pulling for a moment after a throw
var     Quat	HoldOrientation;    ///< Orientation of PhysBall when initially grabbed (relative to player)
var     float	HoldDistance;       ///< How far away from the player to grab and hold PhysBall
var()   float	HoldDistanceMin;    ///< Not really used
var()   float	HoldDistanceMax;    ///< Max distance the ball can be grabbed (and hold distance)
var()   float	WeaponImpulse;      ///< Impulse when ball is pushed
var()   float	ThrowImpulse;       ///< Impulse when ball is thrown 
var()   float	PullStrength;       ///< Impulse when ball is pulled
var()   float	MaxPullDistance;    ///< Max distance that the weapon can pull the ball from
var     RB_Handle	PhysicsGrabber;	///< Responisble for updating PhysBall's position and orientation when held
var     EG_PhysBall	PhysBall;	    ///< Reference to PhysBall
var     linearcolor	RedBarrel,      ///< Color of the barrel when PhysBall is charged
					NeutralBarrel;  ///< Color of the barrel when PhysBall is not charged
var     PhysGunAnimGroup	        GunAnimations;       ///< Weapon animation names
var     SkeletalMeshComponent	    GunMesh;        ///< First person mesh
var     MaterialInstanceConstant	WeapMaterial;   ///< Material instance of the weapon for switching barrel color

simulated function PostBeginPlay()
{
	Super.PostbeginPlay();

	WeapMaterial = GunMesh.CreateAndSetMaterialInstanceConstant( 0 );

	GunAnimations.ThrowAnim='WeaponAltFire';
	GunAnimations.PokeAnim='WeaponFireInstiGib';
	GunAnimations.PullAnim='WeaponFire';
}

function ChangeCharge()
{
	if(bBallCharged)
	{
		WeapMaterial.SetVectorParameterValue('BarrelColor', NeutralBarrel);
		bBallCharged = false;
	}
	else
	{
		WeapMaterial.SetVectorParameterValue('BarrelColor', RedBarrel);
		bBallCharged = true;
	}
}

simulated function StartFire(byte FireModeNum)
{
	local vector			StartShot;  /// World position of weapon trace start
	local actor				RecastActor;/// Used to recast a PhysBall to a PATActor
	local PhysAnimTestActor PATActor;   /// Used to pre-test physics interaction
	local Rotator			Aim;        /// Player aim
	local float             BallDist;   /// Distance from ball to weapon location 
	local float             BallDot;    /// Dot product between player aim and BallToPlayerVect
	local vector            PushVector; /// Normal vector pointing from ball location towards catch location
	local Vector            CatchLocation;  /// World position of where the ball is caught and held
	local vector            BallToPlayerVect;   /// Normal vector pointing from ball location towards StartShot   

	if ( Role < ROLE_Authority )
		return;

	///< Iterate each PhysBall in game (There should only be one per level)
	foreach WorldInfo.AllActors(class'UTGameA.EG_PhysBall',PhysBall) 
	{
		// Set values for all necessary variables
		StartShot	= Instigator.GetWeaponStartTraceLocation();
		Aim			= GetAdjustedAim( StartShot );
		CatchLocation = StartShot + (HoldDistance * Vector(Aim));
		BallToPlayerVect = Normal(PhysBall.Location - StartShot);
		PushVector = Normal(PhysBall.Location - CatchLocation);
		BallDist = VSize(PhysBall.Location - Location);
		BallDot = Normal(Vector(Aim)) Dot BallToPlayerVect;

		if(FireModeNum == 1)    /// FIREMODE = PULL
		{
			if( (BallDot > 0.7) && (BallDist > HoldDistanceMax) && 
				(BallDist <= MaxPullDistance) && bCanPull) /// ATTEMPT PULL
			{
				RecastActor = PhysBall;
				/// Recast RecastActor as PhysAnimTestActor
				PATActor = PhysAnimTestActor(RecastActor);
				if(PATActor != None)    /// If recast was successful
				{
					if( !PATActor.PrePokeActor( -PushVector ) )   /// Pre-poke test
					{
						return;
					}
				}	
				
				PhysBall.ApplyImpulse(-PushVector * WeaponImpulse); /// Poke the object
				PlayWeaponAnimation(GunAnimations.PullAnim, 0.5);    /// Play pull ball animation

			}/// END ATTEMPT PULL

			else if ((BallDot > 0.7) && (BallDist >= HoldDistanceMin) && 
				(BallDist <= (HoldDistanceMax + 0.05)))   /// ATTEMPT GRAB
			{
				GrabBall(PhysBall, StartShot);
			}/// END ATTEMPT GRAB

		}///END FIREMOD = PULL

		
		if (FireModeNum == 0)   /// FIREMODE = PUSH
		{
			if ( PhysicsGrabber.GrabbedComponent == None )  /// POKE
			{
				if((BallDot > 0.985) && (BallDist >= HoldDistanceMin) && (BallDist <= MaxPullDistance)) 
				{
					RecastActor = PhysBall;
					PATActor = PhysAnimTestActor(RecastActor); /// Recast RecastActor as PhysAnimTestActor
					if(PATActor != None)    /// If recast was successful
					{
						if( !PATActor.PrePokeActor( PushVector ) )   /// Pre-poke test
						{
							return;
						}
					}	
					
					PhysBall.ApplyImpulse(Normal(Vector(Aim)) * WeaponImpulse);    /// Poke the object
					PlayWeaponAnimation(GunAnimations.PokeAnim, 0.5);    /// Play poke animation

				}
			}
			else    /// THROW
			{
				PlayWeaponAnimation(GunAnimations.ThrowAnim, 0.6);   /// Play throw animation
				/// Throw grabbed object
				PhysicsGrabber.GrabbedComponent.AddImpulse(Normal(Vector(Aim)) * 
					ThrowImpulse, , PhysicsGrabber.GrabbedBoneName);

				PhysicsGrabber.ReleaseComponent();  /// Let go of the object
				bCanPull=false;
				SetTimer(0.1, false, 'ResetCanPull');
			}/// END THROW

		}///END FIREMODE = PUSH
	
	}

	Super.StartFire(FireModeNum);
}/// END STARTFIRE

simulated function ResetCanPull()
{
	bCanPull=true;
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

		PhysicsGrabber.ReleaseComponent();  /// Drop ball
	}

	if(FireModeNum==1)
		bCanPull = true;

	Super.StopFire( FireModeNum );
}/// END STOPFIRE


simulated function Tick( float DeltaTime )
{
	local vector	        StartLoc;
	local Quat		        PawnQuat;
	local Quat		        NewHandleOrientation;
	local Rotator	        Aim;
	local actor             RecastActor;
	local PhysAnimTestActor	PATActor;
	local vector            PullVector;
	local float             BallDist;
	local float             BallDot;    /// Dot product between direction player is facing and the PhysBall's position
	local float             PullDot;    /// Dot product between the PhysBall's velocity and the direction of PullStrength
	local Vector            CatchLocation;	/// World position of where the ball is caught and held
	local vector            BallToPlayerVect;   /// Normal vector pointing from ball location towards StartLoc
	local float             PB_Speed;	/// Half of PhysBall's current velocity
	local Vector            PB_VelocityNorm;/// Normal vector of PhysBall's current velocity
	local Vector            PB_PullVector;  /// Used by the weapon to affect the direction of the PhysBall

 	if ( PhysicsGrabber.GrabbedComponent == None && !StillFiring(1))    /// Only allows us to continue if holding something or StillFiring(FIREMODE=PULL)
 	{
 		return;
 	}

	// Update handle position on grabbed actor.
	if( Instigator != None )
	{
		StartLoc		= Instigator.GetWeaponStartTraceLocation();
		Aim				= GetAdjustedAim( StartLoc );
		
		foreach WorldInfo.AllActors(class'UTGameA.EG_PhysBall',PhysBall)  /// Iterate each PhysBall in game (There should only be one)
		{
			PB_Speed = VSize(PhysBall.Velocity);
			PB_VelocityNorm = Normal(PhysBall.Velocity);
			CatchLocation = StartLoc + (HoldDistance * Vector(Aim));
			PullVector = -Normal(PhysBall.Location - CatchLocation);
			BallToPlayerVect = Normal(PhysBall.Location - StartLoc);
			BallDist = VSize(PhysBall.Location - Location);
			BallDot = Normal(Vector(Aim)) Dot BallToPlayerVect; 
			PullDot = PB_VelocityNorm dot PullVector;  
			
			if((BallDot > 0.7) && (BallDist > HoldDistanceMax) && (BallDist <= MaxPullDistance) && bCanPull)    /// PULL
			{
				RecastActor = PhysBall;
				PATActor = PhysAnimTestActor(RecastActor); /// Recast PhysBall as PhysAnimTestActor

				if(PATActor != None)    /// Pre-poke test
				{
					if( !PATActor.PrePokeActor( PullVector ) )   
					{
						return;
					}
				}/// End Pre-poke test

				if(PullDot <= 0.985)
				{
					PB_PullVector = VLerp( PB_VelocityNorm, PullVector, (6.0 * DeltaTime) );
					PB_PullVector = ( Normal(PB_PullVector) * PB_Speed ); 
					PhysBall.PhysBallMesh.SetRBLinearVelocity(PB_PullVector);
				}
	
				PhysBall.ApplyImpulse( PullVector * PullStrength * DeltaTime );    /// Pull the object
			}/// END PULL

			else if ( (BallDot > 0.7) && (BallDist <= (HoldDistanceMax + 0.05)) && (PhysicsGrabber.GrabbedComponent == None) && bCanPull )   /// GRAB
			{
				GrabBall(PhysBall, StartLoc);
			}/// END GRAB

		}///END FOREACH PHYSBALL

		if ( PhysicsGrabber.GrabbedComponent != None)   /// HOLDING
		{
			PhysicsGrabber.GrabbedComponent.WakeRigidBody( PhysicsGrabber.GrabbedBoneName );

			PhysicsGrabber.SetLocation( CatchLocation );
			// Update handle orientation on grabbed actor.
			PawnQuat = QuatFromRotator( Rotation );
			NewHandleOrientation = QuatProduct(PawnQuat, HoldOrientation);
			PhysicsGrabber.SetOrientation( NewHandleOrientation );
		}/// END HOLDING

	}
}/// END TICK

simulated function GrabBall(EG_PhysBall GrabbedBall, vector StartLocation)
{
	local Actor             RecastActor;
	local PhysAnimTestActor PATActor;
	local vector            GrabBallLoc; 
	local Quat		        PawnQuat;
	local Quat		        InvPawnQuat;
	local Quat		        ActorQuat;

	RecastActor = GrabbedBall;
	PATActor = PhysAnimTestActor(RecastActor); /// Recast RecastActor as PhysAnimTestActor

	if(PATActor != None)    /// Pre-Grab test
	{
		if( !PATActor.PreGrab() )   
		{
			return;
		}
	}/// End Pre-Grab test

	GrabBallLoc	= StartLocation + ( HoldDistance * Vector(GetAdjustedAim(StartLocation)) );
	GrabbedBall.PhysBallMesh.SetRBPosition(GrabBallLoc);
	PhysicsGrabber.GrabComponent(GrabbedBall.PhysBallMesh, '', GrabBallLoc, PlayerController(Instigator.Controller).bRun==0);

	if (PhysicsGrabber.GrabbedComponent != None)    /// Successful grab
	{
		// We store some details
		HoldDistance	= HoldDistanceMax;
		PawnQuat		= QuatFromRotator( Rotation );
		InvPawnQuat		= QuatInvert( PawnQuat );

		ActorQuat = QuatFromRotator( PhysicsGrabber.GrabbedComponent.Owner.Rotation );
	
		HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
	} /// End successful grab
}

/**
 * Toggles the charge of all active PhysBalls
 */
simulated exec function ChangeBallCharge()
{
	local   UTPawn			PlayerPawn;
	local   EG_PhysBallWeap	PlayerWeap;
	local	EG_PhysBall     PhysBall1;

	/// Iterate each PhysBall in game (There should only be one per level)
	foreach WorldInfo.AllActors(class'UTGameA.EG_PhysBall',PhysBall1)  
	{
		PhysBall.ToggleCharge();
	}	

	foreach WorldInfo.AllPawns(class'UTGame.UTPawn',PlayerPawn)
	{
		PlayerWeap = EG_PhysBallWeap(PlayerPawn.Weapon);
		PlayerWeap.ChangeCharge();
	}
}

/**
 * Console command to spawn a ball
 */
exec function SpawnBall()
{
	local   class<EG_PhysBall>	PhysBallType;
	local   UTPawn			    PlayerPawn;
	local   EG_PhysBallWeap	    PlayerWeap;
	local	EG_PhysBall         NewPhysBall;

	foreach WorldInfo.AllActors(class'UTGameA.EG_PhysBall', NewPhysBall)
	{
		NewPhysBall.Destroy();
	}

	foreach WorldInfo.AllPawns(class'UTGame.UTPawn', PlayerPawn)
	{
		PhysBallType = class<EG_PhysBall>(DynamicLoadObject("UTGameA.EG_PhysBall", class'Class'));

		NewPhysBall = Spawn(	PhysBallType,	///< Class to spawn
								,	///< Owner of new spawn
								,   ///< Tag of new spawn   
								PlayerPawn.Location + vect(0, 0, 200),    ///< Location of spawn
								);	///< Rotation of spawn

		PlayerWeap = EG_PhysBallWeap(PlayerPawn.Weapon);
		PlayerWeap.PhysBall = NewPhysBall;
	}
}

simulated exec function StopPhysBallMotion()
{
	local	EG_PhysBall PhysBall1;

	/// Iterate each PhysBall in game (There should only be one per level)
	foreach WorldInfo.AllActors(class'UTGameA.EG_PhysBall',PhysBall1)  
	{
		if(PhysBall.bBallCharged)
			PhysBall.StopPhysBall();
	}	
}


defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		Materials[0]=Material'MyGame.Materials.PlayerWeaponMat'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object
	GunMesh = FirstPersonMesh

	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
	End Object

	FireOffset=(X=20,Y=5)
	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)

	WeaponFireAnim(0)=WeaponAltFire

	MuzzleFlashSocket=MF
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	LockerRotation=(Pitch=32768,Roll=16384)

	IconCoordinates=(U=728,V=382,UL=162,VL=45)

	WeaponColor=(R=160,G=0,B=255,A=255)

	InventoryGroup=555

	IconX=400
	IconY=129
	IconWidth=22
	IconHeight=48

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=90,RightAmplitude=40,LeftFunction=WF_Constant,RightFunction=WF_LinearDecreasing,Duration=0.1200)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1

	HoldDistanceMin=0.0
	HoldDistanceMax=75.0
	MaxPullDistance=2000.0

	PullStrength=300.0
	WeaponImpulse=200.0
	ThrowImpulse=400.0

	bCanPull=true
	bBallCharged=false

	RedBarrel = (R = 10, G = 1, B = 1, A = 1)
	NeutralBarrel = (R = 5, G = 5, B = 5, A = 1)

	Begin Object Class=RB_Handle Name=RB_Handle0
		LinearDamping=1.0
		LinearStiffness=50.0
		AngularDamping=1.0
		AngularStiffness=50.0
	End Object
	Components.Add(RB_Handle0)
	PhysicsGrabber=RB_Handle0
}