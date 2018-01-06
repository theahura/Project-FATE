/**
 * Copyright 2011, Greg Vanderpool
 */
class EG_PhysBall extends UDKPawn 
	ClassGroup(PhysBall)
	placeable;

var(PhysBall)   const StaticMeshComponent           PhysBallMesh;       ///< Static mesh for PhysBall
var(PhysBall)   bool                                bBallCharged;       ///< Whether or not PhysBall is charged
var(PhysBall)   const PointLightComponent           PhysBallLight;      ///< Light source within the physics ball
var(PhysBall)   DynamicLightEnvironmentComponent    LightEnvironment;	///< For efficient lighting

var     MaterialInstanceConstant    PhysBallMaterial;       ///< Used to change PhysBall color
var     Color                       ChargeLightColor,       ///< Color of PhysBallLight when charged 
									NeutralLightColor;      ///< Color of PhysBallLight when neutral
var     linearcolor                 ChargedSpecularColor,   ///< Specular color and power of PhysBallMaterial when charged
									ChargedDiffuseColor,    ///< Diffuse color of PhysBallMaterial when charged
									ChargedEmissiveColor,   ///< Emissive color of PhysBallMaterial when charged
									NeutralSpecularColor,   ///< Specular color and power of PhysBallMaterial when neutral
									NeutralDiffuseColor,    ///< Diffuse color of PhysBallMaterial when neutral
									NeutralEmissiveColor;   ///< Emissive color of PhysBallMaterial when neutral
var     float                       ChargedGravity,         ///< Gravity scale when charged
									NeutralGravity,         ///< Gravity scale when neutral
									Radius;                 ///< Used to adjust CylinderComponent size

simulated event PostBeginPlay()
{
	super.PostBeginPlay();  /// Call parent PostBeginPlay

	Radius = CollisionComponent.Bounds.SphereRadius;    ///< Get radius information from collision component
	CylinderComponent.SetCylinderSize(Radius, Radius/4);///< Set CylinderComponent size based on this

	PhysBallMaterial = PhysBallMesh.CreateAndSetMaterialInstanceConstant( 0 );  ///< Create material instance

	/// Using RBCC_Untitled3 used for PhysBall specific collisions that are NOT state specific
	PhysBallMesh.SetRBCollidesWithChannel(RBCC_Untitled3, true);   
	PhysBallMesh.WakeRigidBody();   ///< Wakes rigid body to begin physics simulations
}

/**
 * Neutral state - Default state
 * 
 * Experiences normal gravity
 * Turns off switches
 * Emits white light
 */
auto state() Neutral
{
	event BeginState(Name PreviousStateName)
	{
		/// Set the all important bBallCharged
		bBallCharged = false;

		/// Set color and light properties
		PhysBallMaterial.SetVectorParameterValue('EmissiveColor', NeutralEmissiveColor);
		PhysBallMaterial.SetVectorParameterValue('SpecularColor', NeutralSpecularColor);
		PhysBallMaterial.SetVectorParameterValue('DiffuseColor', NeutralDiffuseColor);
		PhysBallLight.SetLightProperties(PhysBallLight.Brightness, NeutralLightColor);

		/// Set Neutral physics and wake rigid body
		CustomGravityScaling = NeutralGravity;
		PhysBallMesh.WakeRigidBody();

		/// Set collision channels for Neutral state
		PhysBallMesh.SetRBCollidesWithChannel(RBCC_Untitled1, true);    /// RBCC_Untitled1 used for Neutral specific collisions (turn ON)
		PhysBallMesh.SetRBCollidesWithChannel(RBCC_Untitled2, false);   /// RBCC_Untitled2 used for Charged specific collisions (turn OFF)
	}
}

/**
 * Charged state
 * 
 * Experiences no gravity
 * Turns on switches
 * Emits red light
 */
state() Charged
{
	event BeginState(Name PreviousStateName)
	{
		/// Set the all important bBallCharged
		bBallCharged = true;

		/// Set color and light properties
		PhysBallMaterial.SetVectorParameterValue('EmissiveColor', ChargedEmissiveColor);
		PhysBallMaterial.SetVectorParameterValue('SpecularColor', ChargedSpecularColor);
		PhysBallMaterial.SetVectorParameterValue('DiffuseColor', ChargedDiffuseColor);
		PhysBallLight.SetLightProperties(PhysBallLight.Brightness, ChargeLightColor);

		/// Set charged physics and wake rigid body
		CustomGravityScaling = ChargedGravity;
		PhysBallMesh.WakeRigidBody();

		/// Set collision channels for charged state
		/// RBCC_Untitled1 used for Neutral specific collisions (turn OFF)
		PhysBallMesh.SetRBCollidesWithChannel(RBCC_Untitled1, false);   
		/// RBCC_Untitled2 used for Charged specific collisions (turn ON)
		PhysBallMesh.SetRBCollidesWithChannel(RBCC_Untitled2, true);    
	}
}

simulated function ApplyImpulse(vector Impulse)
{
	if(!PhysBallMesh.RigidBodyIsAwake())    ///< Check to see if rigid body can accept impulses
	{
		PhysBallMesh.WakeRigidBody();   ///< Wake rigid body to allow impulses
	}
	PhysBallMesh.AddImpulse(Impulse);   ///< Apply the impulse to the PhysBall
}

simulated function StopPhysBall()
{
	PhysBallMesh.SetRBLinearVelocity(vect(0,0,0));  ///< Sets rigid body's linear velocity to zero
}

simulated function ResetGravity()
{
	if(bBallCharged)
	{
		CustomGravityScaling = ChargedGravity;		
	}
	else
	{
		CustomGravityScaling = NeutralGravity;		
	}
}

function ToggleCharge()
{
	local EG_PhysBallTrigger BallTrigger;

	if(bBallCharged)
		GoToState('Neutral');
	else
		GoToState('Charged');

	foreach TouchingActors(class'EG_PhysBallTrigger', BallTrigger)
	{
		BallTrigger.Touch(self, PhysBallMesh, Location, vect(0,0,0));
	}
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	return;
}

defaultproperties
{
	//Components.Remove(CollisionCylinder)
	Components.Remove(Arrow)
	Components.Remove(Sprite)

	begin object class=DynamicLightEnvironmentComponent name=MyLightEnvironment
	end object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

	begin object Class=StaticMeshComponent name=StaticMeshComponent0
		StaticMesh=StaticMesh'MyGame.Meshes.BallSphere'
		Materials[0]=Material'MyGame.Materials.PhysBallMaterial'
		Scale3D=(X=0.15,Y=0.15,Z=0.15)
		WireframeColor=(R=0,G=255,B=128,A=255)
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=true
		bUsePrecomputedShadows=FALSE
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE, GameplayPhysics=TRUE, EffectPhysics=TRUE, Untitled3=true)
		end object
	CollisionComponent=StaticMeshComponent0
	PhysBallMesh=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	Begin Object Name=CollisionCylinder
		CollisionRadius=2.0
		CollisionHeight=2.0
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightRadius0
	End Object
	Components.Add(DrawLightRadius0)

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightSourceRadius0
		SphereColor=(R=231,G=239,B=0,A=255)
	End Object
	Components.Add(DrawLightSourceRadius0)

	Begin Object Class=PointLightComponent Name=PointLightComponent0
	    LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING

		CastShadows=TRUE
	    CastStaticShadows=TRUE
	    CastDynamicShadows=TRUE
	    bForceDynamicLight=FALSE
	    UseDirectLightMap=FALSE

		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=FALSE,bInitialized=TRUE)
		PreviewLightRadius=DrawLightRadius0
		PreviewLightSourceRadius=DrawLightSourceRadius0
		Radius=128.0   
		Brightness=1.0 
		FalloffExponent=5
		LightmassSettings={(
			IndirectLightingSaturation=1.0,
			IndirectLightingScale=1.0,
			ShadowExponent=1.5,
			LightSourceRadius=10.0  /// Shrink the light source radius
			)}
	End Object
	PhysBallLight=PointLightComponent0
	Components.Add(PointLightComponent0)

	Physics=PHYS_RigidBody
	ChargedGravity=0.0 
	NeutralGravity=1.0
	bBallCharged=false


	ChargeLightColor = (R = 255, G = 75, B = 75)
	NeutralLightColor = (R = 255, G = 255, B = 255)
	ChargedDiffuseColor = (R = 0.15, G = 0.0, B = 0.0, A = 1)
	NeutralDiffuseColor = (R = 0.2, G = 0.2, B = 0.2, A = 1)
	ChargedSpecularColor = (R = 0.8, G = 0.0, B = 0.0, A = 20)
	NeutralSpecularColor = (R = 0.7, G = 0.7, B = 0.7, A = 20)
	ChargedEmissiveColor = (R = 0.15, G = 0.0, B = 0.0, A = 1)
	NeutralEmissiveColor = (R = 0.1, G = 0.1, B = 0.1, A = 1)
}