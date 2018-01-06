/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_Gravity extends UTProjectile;

var() int PullStrength;

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector x;
	if ( WorldInfo.NetMode != NM_DedicatedServer && EffectIsRelevant(Location,false,MaxEffectDistance) )
	{
		x = normal(Velocity cross HitNormal);
		x = normal(HitNormal cross x);

		WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(x));
		bSuppressExplosionFX = true;
	}

	if (ExplosionSound!=None)
	{
		PlaySound(ExplosionSound);
	}
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
    local Vehicle           PhysBall;

	// Update handle position on grabbed actor.


        /// Iterate each PhysBall in game (There should only be one)
		foreach WorldInfo.AllActors(class'Vehicle',PhysBall)
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
			}/// END PULL



		}///END FOREACH PHYSBALL

}/// END TICK

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Projectile'
	ProjExplosionTemplate=ParticleSystem'VH_Manta.Effects.PS_Manta_Gun_Impact'
	ExplosionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Shot'
    Speed=1000
    MaxSpeed=3000
    AccelRate=16000.0

    Damage=555
    DamageRadius=600
    MomentumTransfer=3000
	CheckRadius=30.0
    MyDamageType=class'UTDmgType_Gravity'
    LifeSpan=1.6

    bCollideWorld=true
    DrawScale=2.0

    PullStrength=20000
}
