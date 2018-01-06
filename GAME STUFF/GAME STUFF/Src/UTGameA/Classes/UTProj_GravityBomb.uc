/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_GravityBomb extends UTProjectile;

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local vector x;
	local UTWGravityBomb BlackHole;

	if ( WorldInfo.NetMode != NM_DedicatedServer && EffectIsRelevant(Location,false,MaxEffectDistance) )
	{
		x = normal(Velocity cross HitNormal);
		x = normal(HitNormal cross x);

		WorldInfo.MyEmitterPool.SpawnEmitter(ProjExplosionTemplate, HitLocation, rotator(x));
		bSuppressExplosionFX = true;

		//spawn the gravity bomb

		foreach WorldInfo.AllActors(class'UTWGravityBomb', BlackHole)
		{
			BlackHole.Oy();
		}
		Spawn(class'UTWGravityBomb',,,HitLocation, rotator(x));
	}

	if (ExplosionSound!=None)
	{
		PlaySound(ExplosionSound);
	}
}



defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
	ProjExplosionTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
	Speed=600
	MaxSpeed=600
	MaxEffectDistance=7000.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTShockBallLight'


    Damage=0
    DamageRadius=600
    MomentumTransfer=0
	CheckRadius=30.0
    //MyDamageType=class'UTDmgType_Gravity'
    LifeSpan=1.0

    bCollideWorld=true
    DrawScale=2.0
}
