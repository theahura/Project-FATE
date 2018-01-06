class UTProj_Physgun extends UTProjectile;

var vector ColorLevel;

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	SetPhysics(PHYS_None);

	Super.HitWall(HitNormal, Wall, WallComp);
}

simulated function SpawnFlightEffects()
{
	Super.SpawnFlightEffects();
	if (ProjEffects != None)
	{
		ProjEffects.SetVectorParameter('LinkProjectileColor', ColorLevel);
	}
}

defaultproperties
{
   ColorLevel=(X=1.000000,Y=1.300000,Z=1.000000)
   ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
   MaxEffectDistance=3500.000000
   AccelRate=3500.000000
   CheckRadius=26.000000
   Speed=3500.000000
   MaxSpeed=3500.000000
   Begin Object Name=CollisionCylinder ObjName=CollisionCylinder Archetype=CylinderComponent'UTGame.Default__UTProjectile:CollisionCylinder'
      ObjectArchetype=CylinderComponent'UTGame.Default__UTProjectile:CollisionCylinder'
   End Object
   CylinderComponent=CollisionCylinder
   Components(0)=CollisionCylinder
   LifeSpan=10.000000
   DrawScale=1.200000
   CollisionComponent=CollisionCylinder
   Name="Default__UTProj_GrapplingHook"
   ObjectArchetype=UTProjectile'UTGame.Default__UTProjectile'
}