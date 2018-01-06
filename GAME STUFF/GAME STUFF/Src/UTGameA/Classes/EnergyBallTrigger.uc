/**
 *	EnergyBallTrigger
 *
 *	Creation date: 06/08/2012 18:21
 *	Copyright 2012, Amol Kapoor
 */
class EnergyBallTrigger extends Actor 
	ClassGroup(MyGame)
	placeable;

var     StaticMeshComponent         TriggerMesh;
var     MaterialInstanceConstant    TriggerMaterial;
var     linearcolor                 ActivatedColor, DeactivatedColor;
var     Color                       ActivatedLightColor, DeactivatedLightColor;

var(EnergyBallTrigger)    bool	bActive;    /// Whether or not trigger is active
var(EnergyBallTrigger)    bool	bIsTimedTrigger; /// Whether or not the trigger will automatically deactivate
var(EnergyBallTrigger)    float	IdleResetTime;  /// How long to wait before deactivating (if bIsTimedTrigger=true)
var(EnergyBallTrigger)    PointLightComponent TriggerLightComponent;    /// Point light within the trigger
var(EnergyBallTrigger)    DynamicLightEnvironmentComponent     LightEnvironment;  /// For efficient lighting

simulated event PostBeginPlay()
{
	super.PostBeginPlay();  /// Call parent PostBeginPlay

	TriggerMaterial = TriggerMesh.CreateAndSetMaterialInstanceConstant( 0 );
	SetCollisionType(COLLIDE_TouchAll);

	if(bActive)
	{
		TriggerLightComponent.SetLightProperties(TriggerLightComponent.Brightness, ActivatedLightColor);
		TriggerMaterial.SetVectorParameterValue('SpecularColor', ActivatedColor);
		TriggerMaterial.SetVectorParameterValue('DiffuseColor', ActivatedColor);
		TriggerMaterial.SetVectorParameterValue('EmissiveColor', ActivatedColor);
		GoToState('Activated');
	}
	else
	{
		TriggerLightComponent.SetLightProperties(TriggerLightComponent.Brightness, DeactivatedLightColor);
		TriggerMaterial.SetVectorParameterValue('SpecularColor', DeactivatedColor);
		TriggerMaterial.SetVectorParameterValue('DiffuseColor', DeactivatedColor);
		TriggerMaterial.SetVectorParameterValue('EmissiveColor', DeactivatedColor);
		GoToState('Deactivated');
	}
}

function FireSequenceEvent(int ActivationIndex)
{
	self.TriggerEventClass(class'SeqEvent_EnergyBallTrigger',self, ActivationIndex);
}


auto state() Deactivated
{
	event BeginState(Name PreviousStateName)
	{
		//`log("EG_PhysBallTrigger::Deactivated::BeginState");

		TriggerLightComponent.SetLightProperties(TriggerLightComponent.Brightness, DeactivatedLightColor);
		TriggerMaterial.SetVectorParameterValue('SpecularColor', DeactivatedColor);
		TriggerMaterial.SetVectorParameterValue('DiffuseColor', DeactivatedColor);
		TriggerMaterial.SetVectorParameterValue('EmissiveColor', DeactivatedColor);
		TriggerEventClass(class'SeqEvent_EnergyBallTrigger',self, 1);
	}

	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
	//	local   EnergyBall	EnergyBall;

		//`log("Touching: "@Other);
		if( Other.IsA('EnergyBall') )
		{
			//EnergyBall = EnergyBall(Other);

			GoToState('Activated');
		}
	}
}


state() Activated
{
	event BeginState(Name PreviousStateName)
	{
		//`log(self@"::Activated::BeginState");

		if(bIsTimedTrigger && PreviousStateName=='Deactivated')
			SetTimer(IdleResetTime, false, 'ResetTrigger');
		
		TriggerLightComponent.SetLightProperties(TriggerLightComponent.Brightness, ActivatedLightColor);
		TriggerMaterial.SetVectorParameterValue('SpecularColor', DeactivatedColor);
		TriggerMaterial.SetVectorParameterValue('DiffuseColor', DeactivatedColor);
		TriggerMaterial.SetVectorParameterValue('EmissiveColor', DeactivatedColor);
		if (TriggerEventClass(class'SeqEvent_EnergyBallTrigger',self, 0))
		`log("Activated state fired"); 
		else
		`log("Failed");
	}

	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		//local  EnergyBall	EnergyBall;

		//`log("Touching: "$Other);
		if( Other.IsA('EnergyBall') )
		{
		//	EnergyBall = EnergyBall(Other);
			GoToState('Deactivated');
		}
	}

	function ResetTrigger()
	{
		GoToState('Deactivated');
	}
}

defaultproperties
{
	begin object class=DynamicLightEnvironmentComponent name=MyLightEnvironment
	end object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

	begin object Class=StaticMeshComponent name=StaticMeshComponent0
		StaticMesh=StaticMesh'GDC_Materials.Meshes.MeshSphere_02' //CHANGE THIS
		Materials[0]=Material'MyGame.Materials.PhysBallMaterial' //CHANGE THIS
		Scale3D=(X=0.09,Y=0.09,Z=0.09)
		WireframeColor=(R=0,G=255,B=128,A=255)
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=false
		bUsePrecomputedShadows=FALSE
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE, GameplayPhysics=TRUE, EffectPhysics=TRUE, Pawn=true)
		end object

	CollisionComponent=StaticMeshComponent0
	TriggerMesh=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightRadius0
	End Object
	Components.Add(DrawLightRadius0)

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightSourceRadius0
		SphereColor=(R=231,G=239,B=0,A=255)
	End Object
	Components.Add(DrawLightSourceRadius0)

	Begin Object Class=PointLightComponent Name=PointLightComponent0
	    LightAffectsClassification=LAC_STATIC_AFFECTING
		CastShadows=TRUE
		CastStaticShadows=TRUE
		CastDynamicShadows=FALSE
		bForceDynamicLight=FALSE
		UseDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=FALSE,bInitialized=TRUE)
		PreviewLightRadius=DrawLightRadius0
		PreviewLightSourceRadius=DrawLightSourceRadius0
		Radius=90.0     /// Smaller radius than the standard 1024
		Brightness=4.0  /// Increase the brightness
		LightmassSettings={(
			IndirectLightingSaturation=1.0,
			IndirectLightingScale=1.0,
			ShadowExponent=2.0,
			LightSourceRadius=10.0  /// Shrink the light source radius
			)}
	End Object
	TriggerLightComponent=PointLightComponent0
	Components.Add(PointLightComponent0)

	CollisionType=COLLIDE_TouchAll

	bActive=false

	/// This line is vital and associates this class to our custom Sequence Event
	SupportedEvents.Add(class'SeqEvent_EnergyBallTrigger')

	ActivatedColor = (R = 8, G = 1, B = 1, A = 1)
	DeactivatedColor = (R = 1, G = 1, B = 1, A = 1)
	ActivatedLightColor = (R = 255, G = 0, B = 0)
	DeactivatedLightColor = (R = 255, G = 255, B = 255)

	bIsTimedTrigger=false
	IdleResetTime=5.0
}