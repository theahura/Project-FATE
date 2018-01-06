/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTAttachment_GravityRifle extends UTWeaponAttachment;

var ParticleSystem TracerTemplate;
var array<MaterialInterface> TeamSkins;

simulated function SpawnTracer(vector EffectLocation, vector HitLocation)
{
	local ParticleSystemComponent E;
	local vector Dir;

	Dir = HitLocation - EffectLocation;
	if ( VSizeSq(Dir) > 14400.0 )
	{
		E = WorldInfo.MyEmitterPool.SpawnEmitter(TracerTemplate, EffectLocation, rotator(Dir));
		E.SetVectorParameter('Sniper_Endpoint', HitLocation);
	}
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	SpawnTracer(UTWeapon(PawnWeapon).GetEffectLocation(), HitLocation);
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	Super.ThirdPersonFireEffects(HitLocation);

	SpawnTracer(GetEffectLocation(), HitLocation);
}

simulated function SetSkin(Material NewMaterial)
{
	local int TeamIndex;

	if ( NewMaterial == None ) 	// Clear the materials
	{
		TeamIndex = Instigator.GetTeamNum();
		if ( TeamIndex == 255 )
			TeamIndex = 0;
		Mesh.SetMaterial(0,TeamSkins[TeamIndex]);
	}
	else
	{
		Super.SetSkin(NewMaterial);
	}
}


defaultproperties
{
	bMakeSplash=true

	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
		CullDistance=5000
		Scale=1.0
	end Object

 //   DefaultImpactEffect=(Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(0)=(MaterialType=Dirt,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(1)=(MaterialType=Gravel,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(2)=(MaterialType=Sand,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(3)=(MaterialType=Dirt_Wet,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(4)=(MaterialType=Energy,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(5)=(MaterialType=WorldBoundary,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(6)=(MaterialType=Flesh,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(7)=(MaterialType=Flesh_Human,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(8)=(MaterialType=Kraal,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(9)=(MaterialType=Necris,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(10)=(MaterialType=Robot,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(11)=(MaterialType=Foliage,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(12)=(MaterialType=Glass,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(13)=(MaterialType=Liquid,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(14)=(MaterialType=Water,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(15)=(MaterialType=ShallowWater,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(16)=(MaterialType=Lava,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(17)=(MaterialType=Slime,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(18)=(MaterialType=Metal,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(19)=(MaterialType=Snow,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(20)=(MaterialType=Wood,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)
	//ImpactEffects(21)=(MaterialType=NecrisVehicle,Sound=SoundCue'PF_SR_TUT.Sound.AR_Impacct',ParticleTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Surface_Impact',DecalMaterials=(),DecalWidth=16.0,DecalHeight=16.0)

 //   TracerTemplate=ParticleSystem'PF_SR_TUT.Particles.P_WP_SniperRifle_Beam'
	//BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'

	MuzzleFlashSocket=MuzzleFlashSocket
	//MuzzleFlashPSCTemplate=ParticleSystem'PF_SR_TUT.Particles.P_SniperRifle_MuzzleFlash'
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'
	WeaponClass=class'UTWeap_GravityRifle'

	// TeamSkins[0]=Material'PF_SR_TUT.Materials.MAT_Hands'
	//TeamSkins[1]=Material'PF_SR_TUT.Materials.MAT_Hands'

}