/**
 *	FireBarrel
 *
 *	Creation date: 29/10/2012 13:10
 *	Copyright 2012, Amol Kapoor
 */
class FireBarrel extends UTKActor
	ClassGroup(MyGame)
	placeable;

var ParticleSystemComponent PoweredUpEffect;

var bool OnFire; 

event Touch (Actor Other, PrimitiveComponent OtherComp, Object.Vector HitLocation, Object.Vector HitNormal)
{

	Local JoyLight p;
	local Vector momentum; 

	momentum = vect(0,0,0); 

	if (Other.IsA('UTLavaVolume'))
	{
		if (!OnFire)
		{
			PoweredUpEffect.SetActive(true); 
			 p = Spawn(class'JoyLight',,, Location, Rotation, ,true );
			 p.setColor(255, 173, 91, 0);
			 p.setBrightness(5);
			p.SetBase(self); 
			p.SetInterpSpeed(1, 1, 1);
			OnFire = true;
		}
	}

	
	super.Touch(Other, OtherComp, HitLocation, HitNormal); 
}

event RigidBodyCollision(PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex)
{

	Local JoyLight p;

	if (OtherComponent.Owner.IsA('FireBarrel') )
	{

		if (FireBarrel(OtherComponent.Owner).OnFire && !OnFire)
		{
			//`log("Barrel On Fire"); 
	
			PoweredUpEffect.SetActive(true); 
			 p = Spawn(class'JoyLight',,, Location, Rotation, ,true );
			 p.setColor(255, 173, 91, 0);
			 p.setBrightness(5);
			p.SetBase(self); 
			p.SetInterpSpeed(1,1,1);
			OnFire = true;
		}
	}

	super.RigidBodyCollision(HitComponent,OtherComponent,RigidCollisionData,ContactIndex);
}

defaultproperties
{
	OnFire = false; 

	Begin Object Class=ParticleSystemComponent Name=PoweredUpComponent
		Template=ParticleSystem'Castle_Assets.FX.P_FX_Fire_SubUV_01'
		bAutoActivate=false
		bIsActive = false
		Scale3D=( X = 2, Y = 2, Z = 2)
	End Object
	PoweredUpEffect=PoweredUpComponent
	Components.Add(PoweredUpComponent)

	Begin Object Name=StaticMeshComponent0

		StaticMesh=StaticMesh'PhysTest_Resources.RemadePhysBarrel'
		BlockActors=true
		CollideActors=true
		WireframeColor=(R=0,G=255,B=128,A=255)
		BlockRigidBody=true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		bBlockFootPlacement=false
		bNotifyRigidBodyCollision = true
		ScriptRigidBodyCollisionThreshold = 0.01; 
	LightEnvironment=MyLightEnvironment
    end object

    CollisionComponent=StaticMeshComponent0
	    Components.Add(StaticMeshComponent0)
    bCollideActors=true
    bBlockActors=true


}
