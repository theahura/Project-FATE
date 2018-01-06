/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_Gravity extends UTDamageType
      abstract;

      var() int PullStrength;

/** SpawnHitEffect()
 * Possibly spawn a custom hit effect
 */
static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	local UTEmit_VehicleHit BF;

	if ( Vehicle(P) != None )
	{
		BF = P.spawn(class'UTEmit_VehicleHit',P,, HitLocation, rotator(Momentum));
		BF.AttachTo(P, BoneName);
	}
	else
	{
		Super.SpawnHitEffect(P, Damage, Momentum, BoneName, HitLocation);
	}
}



defaultproperties
{
	KillStatsName=KILLS_ROCKETLAUNCHER
	DeathStatsName=DEATHS_ROCKETLAUNCHER
	SuicideStatsName=SUICIDES_ROCKETLAUNCHER
	RewardCount=15
	RewardEvent=REWARD_ROCKETSCIENTIST
	RewardAnnouncementSwitch=2
	DamageWeaponClass=class'UTWeap_RocketLauncher'
	DamageWeaponFireMode=0
	KDamageImpulse=2000
	KDeathUpKick=400
	VehicleMomentumScaling=8.0
	VehicleDamageScaling=8.8
	NodeDamageScaling=1.1
	bThrowRagdoll=true
	GibPerterbation=0.15
	AlwaysGibDamageThreshold=99
	CustomTauntIndex=7

	PullStrength=20000
}
