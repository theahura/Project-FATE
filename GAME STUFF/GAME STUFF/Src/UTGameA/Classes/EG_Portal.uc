class EG_Portal extends UTTeleporterCustomMesh
	placeable;

/** destination portal */
var EG_Portal SisterPortal;

/** component that renders the scene to a texture */
var SceneCapturePortalComponent SceneCapture;

/** Material to use for the capture screen */
var MaterialInstanceConstant MeshMaterial;

/** Used to identify portal. 0 - Blue, 1 - Red */
var byte PortalNum;

/** Used to identify when the player is standing on a portal **/
var float PlayerHeightOffset;

var bool towall, tofloor;

var private TextureRenderTarget2D pTexturePortrait;

var private SceneCapture2DComponent pCaptureComponent;



var private float ReverseZ;

var private float bXYtoZ;

var private float bZtoXY;

var vector VelocityStore, VelocSet;

var float LastPortalTime;

var Vector LateralVelocity, AngularVelocity1;

var Rotator RotStore; 

var Actor PortalActor; 

simulated function PostBeginPlay()
{
	/**
	 * Thanks Geist for finding and fixing the collision
	 * issue that was preventing proper calls to super.PostBeginPlay();
	 */
	
	super.PostBeginPlay();

	MeshMaterial = Mesh.CreateAndSetMaterialInstanceConstant( 0 );

}

function TextureRenderTarget2D getPortrait(){
	if( pTexturePortrait == none )
	{
		pCaptureComponent = new class'SceneCapture2DComponent';
		pTexturePortrait = class'TextureRenderTarget2D'.static.Create(1024, 1024);
		pCaptureComponent.SetCaptureParameters( pTexturePortrait,100,1,10000000000);
		pCaptureComponent.SetView( self.Location, self.Rotation );
		AttachComponent(pCaptureComponent);
	}

	return pTexturePortrait;
}

simulated function InitScene()
{
	if(SisterPortal != none)
	{
		MeshMaterial.SetTextureParameterValue( 'ScreenTex', SisterPortal.getPortrait());  
	}
	else
	{
		MeshMaterial.SetTextureParameterValue( 'ScreenTex', Texture2D'EditorLandscapeResources.GizmoTexture' );
	}
}

/**  Accept an actor that has teleported in. **/
simulated event bool Accept( actor Incoming, Actor Source )
{
	//Location to look
	local rotator NewRot;
	//The incoming and outgoing views
	local Rotator IncViewRot, OutViewRot;
	//the new locations
	local Vector IncViewLoc;
	local Vector NewLocation;	
	local UTPlayerController PC;

	local float Radius, Height;
	//////`log("Accepted"); 


	local RB_BodyInstance PhysicsBody;


	//Makes sure something is actually entering
	if ( Incoming == None )
		return false;	

	// Move the actor here.
	Disable('Touch');
	//Sets the rotation equal to the incoming rotation
	NewRot = Incoming.Rotation;
	
	//if the rotation for one tele to the other is different...
	if (bChangesYaw) 
	{
		//set the yaw to the new one
		NewRot.Yaw = Rotation.Yaw;
		//If there is a source, add to the new yaw equal to the incoming yaw minus the yaw of the source +180 degrees; allows 'moving through' portal at angles
		if ( Source != None )
			NewRot.Yaw += (32768 + Incoming.Rotation.Yaw - Source.Rotation.Yaw);
	}
	

	
	//If theres an incoming pawn
	if ( Pawn(Incoming) != None )
	{
		if (Incoming.IsA('MyPawn'))
		{
			//MyPawn(Incoming).JustTeled = true;
			//////`log("MyPawn JustTeled = true");
		}
		//with a controller
		if(Pawn(Incoming).Controller != none)
		{
			PC = UTPlayerController(Pawn(Incoming).Controller);
			//get the player viewpoint, sets the location to incviewloc and the rotation to incviewrot
			if( PC != none)
			{
				PC.GetPlayerViewPoint(IncViewLoc, IncViewRot);
			}
		}
		
		NewLocation = Location;
		//checks for floor ceiling collision
		if ( Vector(Rotation).Z == -1.0 ) //ceiling
		{
			NewLocation.Z += (Pawn(Incoming).GetCollisionHeight() * Normal(Vector(Rotation)).Z - 20);
		}
		else if ( Vector(Rotation).Z == 1.0 ) //floor
		{
			NewLocation.Z += (75.0 * Normal(Vector(Rotation)).Z);
		}
		else if (Vector(Rotation).Z == 0.0 ) //wall
		{
			NewLocation += (Pawn(Incoming).GetCollisionRadius() * Normal(Vector(Rotation)));
		}
		else //if ( Vector(Rotation).Z != 0.0 ) ; if it equals anything other than one, neg one, or zero, i.e. any other angle
		{
			NewLocation.Z += (45.0 * Normal(Vector(Rotation)).Z);
		}
		
		//if it can't set the location, stop the action
		if ( !Pawn(Incoming).SetLocation(NewLocation) )
			return false;
		
		//Sets all the new info for the player
		if ( (Role == ROLE_Authority)
			//makes sure the portal didn't JUST spawn, and has time to spawn first
			|| (WorldInfo.TimeSeconds - LastFired > 0.5) )
		{ 
			NewRot.Roll = 0;
			NewRot.Pitch = Rotation.Pitch;
			Pawn(Incoming).SetRotation(NewRot);
			Pawn(Incoming).SetViewRotation(NewRot);
			Pawn(Incoming).ClientSetRotation(NewRot);
			//Pawn(Incoming).Velocity += VelocityStore; 
			LastFired = WorldInfo.TimeSeconds;
		}
		
		if ( Pawn(Incoming).Controller != None )
		{
			//???
			Pawn(Incoming).Controller.MoveTimer = -1.0;
			Pawn(Incoming).SetAnchor(self);
			Pawn(Incoming).SetMoveTarget(self);
		
			if(PC != none)
			{
				//sets the 'out going' view
				OutViewRot = NewRot;
				OutViewRot.Pitch = IncViewRot.Pitch;
				OutViewRot.Yaw = (IncViewRot.Yaw + 32768) + (Rotation.Yaw - SisterPortal.Rotation.Yaw);

				//if the one you came from is on the ground
				if (SisterPortal.getVectRot().Z == 1.0 )
				{
					//if both are on the ground
					if (Vector(Rotation).Z == 1.0)
					{
						OutViewRot.Pitch = OutViewRot.Pitch * -1; //Flips rotations
						SisterPortal.ReverseZ = 1; //Flips the Z speed so that it goes up and down
						////`log("ReverseZVeloc: " $Incoming.Velocity);
					}
					else if (Vector(Rotation).Z != -1.0) //the current is on the ceiling, so we don't want the rot to be changed then; otherwise, change it
					{
						OutViewRot = Rotation; //if floor to wall, always comes out facing outward
						SisterPortal.bZtoXY = 1;	//converts the velocity
						////`log("bZtoXY: " $bZtoXY);
						////////`log("Wall set to true"); 
					}
				}
				//if the one you are going to is on the ground
				else if (Vector(Rotation).Z == 1.0 && !towall)
				{
					OutViewRot.Pitch += 16383.996; //Default to looking straight up
					SisterPortal.bXYtoZ = 1;		  //converts the velocity		
					////`log("bXYtoZ: " $bXYtoZ);
				}
				else if (Vector(Rotation).Z == -1.0 &&  !towall) //Ceiling
				{
					OutViewRot.Pitch += -16383.996; //or straight down
					SisterPortal.bXYtoZ = 1;
					////`log("bXYtoZ: " $bXYtoZ);
				}


				if (Vector(Rotation).X == SisterPortal.getVectRot().X && Vector(Rotation).Y == SisterPortal.getVectRot().Y)
				{
					//////`log("On same wall");
				}
				PC.Pawn.SetViewRotation(OutViewRot);
				PC.Pawn.SetRotation(OutViewRot);
			}		
		}
	}
	else if (Incoming.IsA('KActor'))
	{
		KActor(Incoming).bJustPortaled = true; 
		//`log("Rotation: " $Incoming.Rotation);
		//Incoming.SetPhysics(PHYS_None);
		Incoming.GetBoundingCylinder(Radius,Height);
		NewLocation = Location;
		//checks for floor ceiling collision
		if ( Vector(Rotation).Z == -1.0 ) //ceiling
		{
			NewLocation.Z += (Height * Normal(Vector(Rotation)).Z - 20);
		}
		else if ( Vector(Rotation).Z == 1.0 ) //floor
		{
			NewLocation.Z += (75.0 * Normal(Vector(Rotation)).Z);
		}
		else if (Vector(Rotation).Z == 0.0 ) //wall
		{
			NewLocation += (Radius * Normal(Vector(Rotation)));
		}
		else //if ( Vector(Rotation).Z != 0.0 ) ; if it equals anything other than one, neg one, or zero, i.e. any other angle
		{
			NewLocation.Z += (45.0 * Normal(Vector(Rotation)).Z);
		}
		
		KActor(Incoming).StaticMeshComponent.SetRBPosition(NewLocation);
		////`log("Changed Loc");
		
		PhysicsBody = KActor(Incoming).CollisionComponent.GetRootBodyInstance(); //get the physx-simulated body of the mesh component
		if(PhysicsBody != none)
		{
			//PhysicsBody.StaticMeshComponent.WakeRigidBody();
			RotStore = Incoming.Rotation; 
			LateralVelocity = PhysicsBody.GetUnrealWorldVelocity();
			AngularVelocity1 = PhysicsBody.GetUnrealWorldAngularVelocity();
		}
		
		Incoming.SetLocation(NewLocation);

		//KActor(Incoming).StaticMeshComponent.SetRBRotation(rotator(SisterPortal.Location - Incoming.Location));
		
		OutViewRot = rotator(Incoming.Velocity); 
		OutViewRot.Pitch = Rotation.Pitch;
		////`log("Incoming yaw: " $OutViewRot.Yaw);
		OutViewRot.Yaw = (OutViewRot.Yaw + 32768) + (Rotation.Yaw - SisterPortal.Rotation.Yaw);
		////`log("Outgoing yaw: " $OutViewRot.Yaw); 

		if (SisterPortal.getVectRot().Z == 1.0 )
		{
			//if both are on the ground
			if (Vector(Rotation).Z == 1.0)
			{
				`log("REVERSEZ!"); 
				OutViewRot.Pitch = OutViewRot.Pitch * -1; //Flips rotations
				SisterPortal.ReverseZ = 1; //Flips the Z speed so that it goes up and down
				//`log("ReverseZ active");
			}
			else if (Vector(Rotation).Z != -1.0) //the current is on the ceiling, so we don't want the rot to be changed then; otherwise, change it
			{
				OutViewRot = Rotation; //if floor to wall, always comes out facing outward
				SisterPortal.bZtoXY = 1;	//converts the velocity
				//`log("bZtoXY active");
				////////`log("Wall set to true"); 
			}
		}
		//if the one you are going to is on the ground
		else if (Vector(Rotation).Z == 1.0 && !towall)
		{
			OutViewRot.Pitch = 16383.996; //Default to looking straight up
			SisterPortal.bXYtoZ = 1;		  //converts the velocity	
			//`log("bXYtoZ active");
		}
		else if (Vector(Rotation).Z == -1.0 &&  !towall) //Ceiling
		{
			OutViewRot.Pitch = -16383.996; //or straight down
			SisterPortal.bXYtoZ = 1;
			//`log("bXYtoZ active");
		}


		if (Vector(Rotation).X == SisterPortal.getVectRot().X && Vector(Rotation).Y == SisterPortal.getVectRot().Y)
		{
			//////`log("On same wall");
		}
		
		//OutViewRot = Rotation; 

		KActor(Incoming).StaticMeshComponent.SetRBRotation(OutViewRot);
		//Incoming.SetRotation(OutViewRot); 
		//Incoming.SetPhysics(PHYS_RigidBody); 

		//`log("Rotation1: " $Incoming.Rotation);
	}

	Enable('Touch');
	
	Incoming.PostTeleport(self);
	
	return true;

}

simulated event Touch(actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
	`log("Touched: " $Tag); 
	`log("LastPortal: " $WorldInfo.TimeSeconds - LastPortalTime); 
	if (WorldInfo.TimeSeconds - LastPortalTime > 0.05 || WorldInfo.TimeSeconds - SisterPortal.LastPortalTime > 0.05)
	{
		`log("LastPortal: " $WorldInfo.TimeSeconds - LastPortalTime); 
		VelocityStore = Other.Velocity; 
		VelocSet = Other.Velocity; 
		////`log("Starting Veloc : " $VelocityStore);

		PendingTouch = Other.PendingTouch;
		Other.PendingTouch = self;
		LastPortalTime = WorldInfo.TimeSeconds;
		SisterPortal.LastPortalTime = LastPortalTime; 
	//super.Touch(Other, OtherComp, HitLocation, HitNormal); 
	}
}


//Teleporter was touched by an actor.
simulated event PostTouch( actor Other )
{
	local Vector X,Y,Z; 
	local rotator RotRoll; 
	//local UTPlayerController PC; 
	////`log("Touched by (PT): " $Other);
	if (Other.IsA('MyPawn'))
	{
		////`log("mypawn");
		if( SisterPortal != none)
		{
			//call the accept function on it
			SisterPortal.Accept( Other, self );	
			////`log("ReverseZ2.5: " $ReverseZ); 
			////`log("bXYtoZ2.5: " $bXYtoZ);
			////`log("bZtoXY2.5: " $bZtoXY);
		}
	}
	else if( SisterPortal != none && !Other.IsA('MyPawn') && !Other.IsA('PortalAttachCube'))
	{
		////`log("Not mypawn");
		//call the accept function on it
		SisterPortal.Accept( Other, self );
	}


	Other.Velocity = VelocityStore; 
	////`log("After Veloc" $Other.Velocity); 

	if (Other.IsA('MyPawn'))
	{	
		RotRoll = Other.Rotation; 
		RotRoll.Roll = 0; 
		MyPawn(Other).SetViewRotation(RotRoll);
		Other.SetRotation(RotRoll);

		//MyPawn(Other).SetZVeloc(); 

		if  (bXYtoZ == 1)//(MyPawn(Other).bXYtoZ)
		{
			//MyPawn(Other).XYtoZ();
			//`log("Pawn Old Veloc: "$Other.Velocity);
			if (SisterPortal.getVectRot().Z == 1.0) //floor
				VelocSet.Z = Abs(Other.Velocity.Z) + Abs(Other.Velocity.Y) + Abs(Other.Velocity.X);
			else //ceiling
			{
				VelocSet.Z = (Abs(Other.Velocity.Z) + Abs(Other.Velocity.Y) + Abs(Other.Velocity.X)) * -1;				
			}
			VelocSet.Y = 0;
			VelocSet.X= 0;

			//`log("Pawn New Veloc: "$Other.Velocity); 

			Other.SetPhysics(PHYS_Falling); 
			Other.Velocity = VelocSet; 
			bXYtoZ = 0; 
		}
		else if (bZtoXY == 1)//(MyPawn(Other).bZtoXY)
		{	
			//MyPawn(Other).ZtoXY();
			//`log("Pawn Old Veloc: "$Other.Velocity);
			Other.GetAxes(Other.Rotation, X,Y,Z); 

			X *= (Abs(Other.Velocity.X) + Abs(Other.Velocity.Y) + Abs(Other.Velocity.Z));

			Other.Velocity = X; 

			Other.SetPhysics(PHYS_Falling); 

			bZtoXY = 0;
			//`log("Pawn New Veloc: "$Other.Velocity);
		}
		else if (ReverseZ == 1)
		{
			`log("Pawn Old Veloc: "$Other.Velocity);

			Other.Velocity.Z *= -1.0; 

			ReverseZ = 0;

			Other.SetPhysics(PHYS_Falling); 

			`log("Pawn New Veloc: "$Other.Velocity);
		}
		else if ((Vector(Rotation).Z == 1.0 && SisterPortal.getVectRot().Z == -1.0) || (Vector(Rotation).Z == -1.0 && SisterPortal.getVectRot().Z == 1.0)) //infinite loop
		{
			Other.SetPhysics(PHYS_Falling); 
		}
		else
		{
			Other.Velocity = Vector(Other.Rotation) * VSize(Other.Velocity);
		}//MyPawn(Other).SetVelocity();
 
	}
	else if (Other.IsA('KActor'))
	{

		if  (bXYtoZ == 1)
		{
			if (SisterPortal.getVectRot().Z == 1.0)
			VelocSet.Z = Abs(Other.Velocity.Z) + Abs(Other.Velocity.Y) + Abs(Other.Velocity.X);
			else
			VelocSet.Z = (Abs(Other.Velocity.Z) + Abs(Other.Velocity.Y) + Abs(Other.Velocity.X)) * -1;

			KActor(Other).StaticMeshComponent.SetRBLinearVelocity(VelocSet,false);
			KActor(Other).StaticMeshComponent.SetRBAngularVelocity(SisterPortal.AngularVelocity1,false);

			bXYtoZ = 0; 
		}
		else if (bZtoXY == 1)
		{	
			//`log("Pawn Old Veloc: "$Other.Velocity);
			Other.GetAxes(Other.Rotation, X,Y,Z); 

			X *= (Abs(Other.Velocity.X) + Abs(Other.Velocity.Y) + Abs(Other.Velocity.Z));

			KActor(Other).StaticMeshComponent.SetRBLinearVelocity(X,false);
			KActor(Other).StaticMeshComponent.SetRBAngularVelocity(SisterPortal.AngularVelocity1,false);

			bZtoXY = 0;
			//`log("Pawn New Veloc: "$Other.Velocity);
		}
		else if (ReverseZ == 1)
		{
			`log("Pawn Old Veloc: "$Other.Velocity);
	
			`log("VelocSet: "$VelocSet.Z);
			VelocSet.Z *= -1.0; 
			`log("VelocSet1: "$VelocSet.Z);

			ReverseZ = 0;

			KActor(Other).StaticMeshComponent.SetRBLinearVelocity(VelocSet, false);
			KActor(Other).StaticMeshComponent.SetRBAngularVelocity(SisterPortal.AngularVelocity1,false);

			`log("Pawn New Veloc: "$Other.Velocity);
		}
		else if ((Vector(Rotation).Z == 1.0 && SisterPortal.getVectRot().Z == -1.0) || (Vector(Rotation).Z == -1.0 && SisterPortal.getVectRot().Z == 1.0)) //infinite loop
		{
			if (VelocSet.Z > 1000)
				VelocSet.Z = 1000;
			else if (VelocSet.Z < -1000)
				VelocSet.Z = -1000;
			KActor(Other).StaticMeshComponent.SetRBLinearVelocity(VelocSet,false);
			KActor(Other).StaticMeshComponent.SetRBAngularVelocity(SisterPortal.AngularVelocity1,false);
		}
		else
		{
		//	//`log("Pawn Old Veloc: "$Other.Velocity);

			VelocSet = Vector(Other.Rotation) * VSize(VelocSet);			
			KActor(Other).StaticMeshComponent.SetRBLinearVelocity(VelocSet, false);
			KActor(Other).StaticMeshComponent.SetRBAngularVelocity(SisterPortal.AngularVelocity1,false);

			////`log("Pawn New Veloc: "$Other.Velocity);
		}
	
		//`log("Angularveloc: " $SisterPortal.AngularVelocity); 
		KActor(Other).StaticMeshComponent.SetRBAngularVelocity(SisterPortal.AngularVelocity1,false);
		KActor(Other).StaticMeshComponent.SetRBRotation(SisterPortal.RotStore);
	}
	
	`log("Velocity: " $Other.Velocity);
	//`log("Finally..." $Other.Velocity);
}

simulated function Vector getVectRot ()
{
	return Vector(Rotation); 
}

//Allows ammo to go through
simulated function bool StopsProjectile(Projectile P)
{
	local vector offset;
	local Rotator mirrorRotation;

	if ( !Super.StopsProjectile( P ) )
		return false;

	if( bBlockActors )
		return true;

	if( P.IsA( 'UTProj_Portal' ) )
		return false;

	// Teleport projectile

	// First, get the mirrored rotation of this portal, 
	// since shots ENTER this portal and EXIT the sister portal
	mirrorRotation = Rotation + rotator(vect(-1,0,0));

	// Transform projectile's location offset (relative to portal's location) to new basis
	offset = ( ( P.Location - Location ) << mirrorRotation );
	P.SetLocation( SisterPortal.Location + ( offset >> SisterPortal.Rotation ) );

	// Transform projectile's velocity to new basis
	P.Velocity = ( P.Velocity << mirrorRotation ) >> SisterPortal.Rotation;
	P.Acceleration = P.Velocity;

	// Transform projectile's rotation to new basis
	P.SetRotation( SisterPortal.Rotation + ( P.Rotation - mirrorRotation ) );

	return false;
}



Defaultproperties
{
	///< Setup the portal mesh using a simple plane mesh
	///< and specifying our custom material in it's properties
	///< We also setup the mesh's collision properties here so
	///< that actors can collide but are not blocked by portals
	Begin Object Name=PortalMesh
		BlockActors=false
		CollideActors=true
		BlockRigidBody=false
		StaticMesh=StaticMesh'MyGame.Meshes.PortalCube'
		//StaticMesh=StaticMesh'MyGame.Meshes.S_BluePortal'
		//Materials[0]=Material'MyGame.Base_Teleporter.Material.DensePortalMat'
		Materials[0]=Material'MyGame.Materials.Mat_PortalSceneMat'
		Translation=(X=-1, Y=0, Z=0.0)
		Scale3D=( X = 0.001, Y = 0.5, Z = 0.5)
	End Object
	Mesh=PortalMesh
	CollisionComponent=PortalMesh
	Components.Add(PortalMesh)

	///< These booleans MUST be set to false in order to spawn/destroy at runtime
	///< This is because Epic portals are derived from path node classes, which
	///< cannot be spawned/destroyed at runtime.
	bStatic=false
	bNoDelete=false

	bProjTarget=true

	/// Found by taking difference between player location.z and a floor portal position.z
	PlayerHeightOffset=46.63

	//bChangesVelocity = false
	tofloor = false
	towall = false
	
	ReverseZ = 0
	bZtoXY = 0
	bXYtoZ = 0

	LastPortalTime = 0

	bHardAttach = true

}
