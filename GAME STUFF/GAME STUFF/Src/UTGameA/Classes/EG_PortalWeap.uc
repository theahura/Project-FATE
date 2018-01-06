class EG_PortalWeap extends UTWeapon;

/** Teleportal URL tag **/ 
var string PortalTag, SisterTag; 
/** If true - Do not spawn portal on collision **/ 
var bool bSuppressPortal;

var Actor PortalActor; 

simulated function StartFire(byte FireModeNum)
{
	
	local vector StartShot; /// World position of weapon trace start 
	local Rotator Aim; /// Player aim 
	local Vector HitLoc; 
	local Vector HitNorm; 
	local Actor HitActor; 
	local Rotator PortalRot; 
	local UTPawn PlayerPawn; 
	//local UTPlayerController PC; 
	local EG_Portal TempPortal; 
	local TraceHitInfo HitInfo; 

	//local Box Bounds;
	//local float MinHeight; 

	local box Bound;
	local float zval, yval; 


	super.StartFire(FireModeNum); ///< Call the UTWeapon start fire function 


	//trace
	StartShot = Instigator.GetWeaponStartTraceLocation(); Aim = GetAdjustedAim( StartShot ); 
	HitActor = Trace(HitLoc, HitNorm, (StartShot + (Normal(Vector(Aim)) * 4000.0)), StartShot, true, vect(0,0,0), HitInfo); 

	foreach WorldInfo.AllPawns(class'UTGame.UTPawn',PlayerPawn) 
	{ 
		//PC = UTPlayerController(PlayerPawn.Owner); 
		/** Orient floor/ceiling portals based on player orientation **/ 
		PortalRot = Rotator(HitNorm); 
		//up or down
		if( (HitNorm.Z == 1.0) ) 
		{ 
			//sets the portal rotation to the opposite of the player rotation
			PortalRot.Yaw = PlayerPawn.Rotation.Yaw - 32768;; 
		} 
		else if (HitNorm.Z == -1.0) 
		{ 
			PortalRot.Yaw = PlayerPawn.Rotation.Yaw; 
		} 
		PortalRot = Normalize(PortalRot); 

		//Don't allow portals to spawn on an interp actor... POTENTIAL?! Moving portals with grav gun! 
		//if (HitActor.IsA('PortalAttachCube') )
		PortalActor = HitActor; 

		if(!HitActor.IsA('GrapplePortalWall') && !HitActor.IsA('PortalAttachCube'))  
		bSuppressPortal=true; 

		if( bSuppressPortal ) 
		{
			`log("Wasn't a portalwall");
			bSuppressPortal=false; 
			return; 
		} 

		HitActor.GetComponentsBoundingBox(Bound); 

		zval = Bound.Max.Z - Bound.Min.Z; //heighthitactor
		yval = Bound.Max.Y - Bound.Min.Y; //widthhitactor


		if ((zval <= 128 || yval <= 128)) //128 found by value of portal mesh (256) multiplied by scale for zy (.5)
		{
			`log("Too small: " $HitActor);
			return; 
		}
		//assigns which portal you spawn ( red or blue ) based on which fire you do
		if(FireModeNum == 0) 
		{ 
			PortalTag = "BluePortal"; 
			SisterTag = "RedPortal";  
		} 
		else 
		{ 
			PortalTag = "RedPortal"; 
			SisterTag = "BluePortal"; 
		} 

		/** Destroy any old portals that match Tag **/ 
		foreach AllActors( class 'EG_Portal', TempPortal ) 
		{ 
			if( string(TempPortal.Tag) ~= PortalTag ) 
			{ 
				TempPortal.Destroy(); 				
				break; 
			} 
		} 

		//Calls the portal spawn
		if(FireModeNum == 0) 
		{ 
			SpawnLeftPortal(HitLoc, PortalRot); 
		} 
		else 
		{ 
			SpawnRightPortal(HitLoc, PortalRot); 
		} 
	} 

	PlayWeaponAnimation('WeaponFire', 0.1667);

	StopFire(FireModeNum);  ///< Prevents the weapon from continuously firing when trigger is held down
}


function EG_PortalLeft SpawnLeftPortal(Vector SpawnLoc, Rotator SpawnRot)
{
	//Doesn't know what PortalLeft is...
	local class<EG_PortalLeft> NewPortalClass;
	local EG_PortalLeft NewPortal;
	//Or portal right
	local EG_PortalRight Portal_Sister;
	local vector PointLoc; 
	//local Vector HitLoc, HitNorm, TraceEnd; 
	//local Vector X,Y,Z; 

	//Loads the portal class
	NewPortalClass = class<EG_PortalLeft>(DynamicLoadObject("UTGameA.EG_PortalLeft", class'Class'));
	
	//Spawns the class at the set location
	NewPortal = Spawn( NewPortalClass, , name(PortalTag),  SpawnLoc, SpawnRot, ,false);
		

	SpawnLoc = SpawnLoc << NewPortal.Rotation; 
	PointLoc = PortalActor.Location << NewPortal.Rotation; 
	SpawnLoc.X += 1; //makes sure the portal don't spawn in the wall
	`log("SpawnLoc: " $SpawnLoc); 
	`log("PointLoc: " $PointLoc); 
	SpawnLoc.Z = PointLoc.Z; 
	SpawnLoc.Y = PointLoc.Y; 

	SpawnLoc = SpawnLoc >> NewPortal.Rotation;
	NewPortal.SetLocation(SpawnLoc);

	NewPortal.SetBase(PortalActor); 


	//Sets the tag of the portal spawned
	NewPortal.Tag = name(PortalTag);
	//As well as the one it is heading too
	NewPortal.URL = SisterTag;

	//Searches for the sister portal
	foreach AllActors( class 'EG_PortalRight', Portal_Sister )
	{
		if( string(Portal_Sister.Tag) ~= SisterTag )
		{
			NewPortal.SisterPortal = Portal_Sister;
			break;
		}
	}


	//If the sister portal exists
	if(NewPortal.SisterPortal != none)
	{
		//A check to make sure the portal has only one sister
		NewPortal.SisterPortal.SisterPortal = NewPortal;
		//Initialize the portal imaging 
		NewPortal.SisterPortal.InitScene();

		// Both portals exist, so enable collision on both. Fix by Geist.
		NewPortal.SetCollision( true, false );
		NewPortal.SisterPortal.SetCollision( true, false );
	}


	//Initializes the imaging on this portal
	//NewPortal.CheckSides();

	NewPortal.InitScene();	
	//NewPortal.InitializePortalEffect(NewPortal.SisterPortal);
 
	NewPortal.PortalActor = PortalActor;

	return NewPortal;
}

//See above
function EG_PortalRight SpawnRightPortal(Vector SpawnLoc, Rotator SpawnRot)
{
	local class<EG_PortalRight> NewPortalClass;
	local EG_PortalRight NewPortal;
	local EG_PortalLeft Portal_Sister;
	local vector PointLoc; 
//	local vector endtraceup, endtracedown, endtraceright, endtraceleft, endtraceup1, endtracedown1, endtraceright1, endtraceleft1, HitLoc, HitNorm, Loc1, Location1;
//	local Vector HitLoc, HitNorm, TraceEnd; 
//	local Vector X,Y,Z; 

	NewPortalClass = class<EG_PortalRight>(DynamicLoadObject("UTGameA.EG_PortalRight", class'Class'));

	NewPortal = Spawn( NewPortalClass, , name(PortalTag),  SpawnLoc, SpawnRot, ,false);
	


	SpawnLoc = SpawnLoc << NewPortal.Rotation; 
	PointLoc = PortalActor.Location << NewPortal.Rotation; 
	SpawnLoc.X += 1; //makes sure the portal don't spawn in the wall
	`log("SpawnLoc: " $SpawnLoc); 
	`log("PointLoc: " $PointLoc); 
	SpawnLoc.Z = PointLoc.Z; 
	SpawnLoc.Y = PointLoc.Y; 

	SpawnLoc = SpawnLoc >> NewPortal.Rotation;
	NewPortal.SetLocation(SpawnLoc);

	NewPortal.SetBase(PortalActor); 

	NewPortal.Tag = name(PortalTag);
	NewPortal.URL = SisterTag;

	foreach AllActors( class 'EG_PortalLeft', Portal_Sister )
	{
		if( string(Portal_Sister.Tag) ~= SisterTag )
		{
			NewPortal.SisterPortal = Portal_Sister;
			break;
		}
	}

	if(NewPortal.SisterPortal != none)
	{
		NewPortal.SisterPortal.SisterPortal = NewPortal;
		NewPortal.SisterPortal.InitScene();

		// Both portals exist, so enable collision on both. Fix by Geist.
		NewPortal.SetCollision( true, false );
		NewPortal.SisterPortal.SetCollision( true, false );
	}


	//get the bounding box, min and max (http://forums.epicgames.com/archive/index.php/t-740917.html)
	//Edit the Location of the portal based on if its in a wall or not; four traces
	//NewPortal.CheckSides();

	NewPortal.InitScene();

	NewPortal.PortalActor = PortalActor;

	return NewPortal;
}

Defaultproperties
{

	/// Portal gun doesn't use ammo, so set ShotCost to 0 for both fire modes
	ShotCost(0)=0   
	ShotCost(1)=0


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
	EffectSockets(1)=MuzzleFlashSocket
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashColor=(R=120,G=120,B=120,A=255)
	MuzzleFlashDuration=0.33;
	WeaponColor=(R=255,G=255,B=0,A=255)
	PlayerViewOffset=(X=16.0,Y=-18,Z=-18.0)
	FireOffset=(X=12,Y=10,Z=-10)

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
	End Object
}