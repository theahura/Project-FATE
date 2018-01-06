   class UTWGravityBomb extends Actor
    placeable;

var() const editconst LightEnvironmentComponent LightEnvironment;

var() int PullStrength;

var Vehicle PhysBall;

var KActor Objects;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    //destroy after 2 seconds
    //SetTimer(2.0, false, 'Oy');
}

simulated function Oy()
{
	PullStrength=0;

	SetPhysics(PHYS_None);
	SetHidden(True);
	SetCollision(false,false);
	Destroy();
}



simulated function Tick( float DeltaTime )
{
	local vector	        StartLoc;
	//local Quat		        PawnQuat;
	//local Quat		        NewHandleOrientation;
	//local Rotator	        Aim;
	local actor             RecastActor;
	local PhysAnimTestActor	PATActor;
	local vector            PullVector;
	local float             BallDist;
	local float             BallDot;    /// Dot product between direction player is facing and the PhysBall's position
	local float             PullDot;    /// Dot product between the PhysBall's velocity and direction of PullStrength
	local Vector            CatchLocation;	/// World position of where the ball is caught and held
	local vector            BallToPlayerVect;   /// Normal vector pointing from ball location towards StartLoc
	local float             PB_Speed;	/// Half of PhysBall's current velocity
	local Vector            PB_VelocityNorm;/// Normal vector of PhysBall's current velocity
	local Vector            PB_PullVector;  /// Used by the weapon to affect the direction of the PhysBall


	// Update handle position on grabbed actor.


        /// Iterate each PhysBall in game (There should only be one)
		foreach WorldInfo.DynamicActors(class'Vehicle',PhysBall)
		{
				if (VSize(PhysBall.Location - Location) <= 5000)
				{
					PB_Speed = VSize(PhysBall.Velocity);
					PB_VelocityNorm = Normal(PhysBall.Velocity);
					CatchLocation = Location;
					PullVector = -Normal(PhysBall.Location - CatchLocation);
					BallToPlayerVect = Normal(PhysBall.Location - StartLoc);
					BallDist = VSize(PhysBall.Location - Location);
					BallDot = Normal(Location) Dot BallToPlayerVect;
					PullDot = PB_VelocityNorm dot PullVector;

					if((BallDot > 0.7) && (BallDist > 100) &&
						(BallDist <= 90000))	/// PULL
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
							PhysBall.Mesh.SetRBLinearVelocity(PB_PullVector);
						}

						PhysBall.Mesh.AddImpulse( PullVector * PullStrength * DeltaTime );    /// Pull the object
					}
				}/// END PULL
			
		}

		foreach WorldInfo.DynamicActors(class'KActor', Objects)
		{
			PB_Speed = VSize(Objects.Velocity);
			PB_VelocityNorm = Normal(Objects.Velocity);
			CatchLocation = Location;
			PullVector = -Normal(Objects.Location - CatchLocation);
			BallToPlayerVect = Normal(Objects.Location - StartLoc);
			BallDist = VSize(Objects.Location - Location);
			BallDot = Normal(Location) Dot BallToPlayerVect;
			PullDot = PB_VelocityNorm dot PullVector;

			if((BallDot > 0.7) && (BallDist > 50) &&
				(BallDist <= 50000))	/// PULL
			{
				RecastActor = Objects;
				PATActor = PhysAnimTestActor(RecastActor); /// Recast Objects as PhysAnimTestActor

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
					Objects.StaticMeshComponent.SetRBLinearVelocity(PB_PullVector);
				}

				Objects.StaticMeshComponent.AddImpulse( PullVector * PullStrength * DeltaTime);    /// Pull the object
			}/// END PULL

		}///END FOREACH PHYSBALL

}/// END TICK

simulated event Touch(actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{
	Other.Velocity.Z /= 2; 
	Other.Velocity.X /= 2; 
	Other.Velocity.Y /=2;
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

DefaultProperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	bEnabled=TRUE
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

    begin object class=StaticMeshComponent Name=BaseMesh
			BlockActors=false
		CollideActors=true
		BlockRigidBody=false
		StaticMesh=StaticMesh'MyGame.Meshes.BallSphere'
		//StaticMesh=StaticMesh'MyGame.Meshes.S_BluePortal'
		//Materials[0]=Material'MyGame.Base_Teleporter.Material.DensePortalMat'
		Materials[0]=Material'MyGame.Materials.BlackHoleMat'
		Translation=(X=0, Y=0, Z=0.0)
		Scale3D=( X = 1, Y = 1, Z = 1)
	LightEnvironment=MyLightEnvironment
    end object
    Components.Add(BaseMesh)


    CollisionComponent=BaseMesh
    bCollideActors=true
    bBlockActors=true

    //TheSound=SoundCue'MenuButtons.Sounds.SC_Blip'
    PullStrength=10000
}