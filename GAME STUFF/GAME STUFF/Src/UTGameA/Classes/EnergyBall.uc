/**
 *	EnergyBall
 *
 *	Creation date: 06/08/2012 12:36
 *	Copyright 2012, Amol Kapoor
 */
class EnergyBall extends UTProjectile;

simulated event CreateProjectileLight()
{
	ProjectileLight = new(Outer) ProjectileLightClass;
	AttachComponent(ProjectileLight);
}

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	bBlockedByInstigator = true;

	// check to make sure we didn't hit a pawn
	if (Wall.IsA('EnergyBallTrigger'))
		super.HitWall(HitNormal, Wall, WallComp);
	else
	{
		Velocity = (( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);
	}
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
	ProjExplosionTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
	Speed=500
	MaxSpeed=500
	MaxEffectDistance=7000.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGameA.EnergyLightComponent'

	Damage=0
	LifeSpan = 0.0 
	CustomGravityScaling=0.0
}
