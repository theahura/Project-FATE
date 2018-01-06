class EG_PhysBallTrigger extends Actor 
	ClassGroup(MyGame)
	placeable;

var     StaticMeshComponent         TriggerSphereMesh;
var     MaterialInstanceConstant    SphereMaterial;
var     linearcolor                 ActivatedColor, DeactivatedColor;
var     Color                       ActivatedLightColor, DeactivatedLightColor;

var(PhysBallTrigger)    bool	bActive;    /// Whether or not trigger is active
var(PhysBallTrigger)    bool	bIsTimedTrigger; /// Whether or not the trigger will automatically deactivate
var(PhysBallTrigger)    float	IdleResetTime;  /// How long to wait before deactivating (if bIsTimedTrigger=true)
var(PhysBallTrigger)    PointLightComponent TriggerLightComponent;    /// Point light within the trigger
var(PhysBallTrigger)    DynamicLightEnvironmentComponent     LightEnvironment;  /// For efficient lighting

simulated event PostBeginPlay()
{
	super.PostBeginPlay();  /// Call parent PostBeginPlay

	SphereMaterial = TriggerSphereMesh.CreateAndSetMaterialInstanceConstant( 0 );
	SetCollisionType(COLLIDE_TouchAll);

	if(bActive)
	{
		TriggerLightComponent.SetLightProperties(TriggerLightComponent.Brightness, ActivatedLightColor);
		SphereMaterial.SetVectorParameterValue('SpecularColor', ActivatedColor);
		SphereMaterial.SetVectorParameterValue('DiffuseColor', ActivatedColor);
		SphereMaterial.SetVectorParameterValue('EmissiveColor', ActivatedColor);
		GoToState('Activated');
	}
	else
	{
		TriggerLightComponent.SetLightProperties(TriggerLightComponent.Brightness, DeactivatedLightColor);
		SphereMaterial.SetVectorParameterValue('SpecularColor', DeactivatedColor);
		SphereMaterial.SetVectorParameterValue('DiffuseColor', DeactivatedColor);
		SphereMaterial.SetVectorParameterValue('EmissiveColor', DeactivatedColor);
		GoToState('Deactivated');
	}
}

function FireSequenceEvent(int ActivationIndex)
{
	self.TriggerEventClass(class'SeqEvent_PhysBallTrigger',self, ActivationIndex);
}


auto state() Deactivated
{
	event BeginState(Name PreviousStateName)
	{
		//`log("EG_PhysBallTrigger::Deactivated::BeginState");

		TriggerLightComponent.SetLightProperties(TriggerLightComponent.Brightness, DeactivatedLightColor);
		SphereMaterial.SetVectorParameterValue('SpecularColor', DeactivatedColor);
		SphereMaterial.SetVectorParameterValue('DiffuseColor', DeactivatedColor);
		SphereMaterial.SetVectorParameterValue('EmissiveColor', DeactivatedColor);
		FireSequenceEvent(1);
	}

	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local   EG_PhysBall	PhysBall;

		//`log("Touching: "@Other);
		if( Other.IsA('EG_PhysBall') )
		{
			PhysBall = EG_PhysBall(Other);

			if(PhysBall.bBallCharged)
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
		SphereMaterial.SetVectorParameterValue('SpecularColor', DeactivatedColor);
		SphereMaterial.SetVectorParameterValue('DiffuseColor', DeactivatedColor);
		SphereMaterial.SetVectorParameterValue('EmissiveColor', DeactivatedColor);
		FireSequenceEvent(0);
	}

	event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
	{
		local   EG_PhysBall	PhysBall;

		//`log("Touching: "$Other);
		if( Other.IsA('EG_PhysBall') )
		{
			PhysBall = EG_PhysBall(Other);

			if(PhysBall.bBallCharged == false)
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
		StaticMesh=StaticMesh'GDC_Materials.Meshes.MeshSphere_02'
		Materials[0]=Material'MyGame.Materials.PhysBallMaterial'
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
	TriggerSphereMesh=StaticMeshComponent0
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
	SupportedEvents.Add(class'SeqEvent_PhysBallTrigger')

	ActivatedColor = (R = 8, G = 1, B = 1, A = 1)
	DeactivatedColor = (R = 1, G = 1, B = 1, A = 1)
	ActivatedLightColor = (R = 255, G = 0, B = 0)
	DeactivatedLightColor = (R = 255, G = 255, B = 255)

	bIsTimedTrigger=false
	IdleResetTime=5.0
}