class MouseInterfaceKActor extends InterpActor
	Implements(MouseInterfaceInteractionInterface)
	Implements(SaveGameStateInterface)
	placeable;

var Vector CachedMouseHitLocation;
var Vector CachedMouseHitNormal;
var Vector CachedMouseWorldOrigin;
var Vector CachedMouseWorldDirection;

// ===
// MouseInterfaceInteractionInterface implementation
// ===
function MouseLeftPressed(Vector MouseWorldOrigin, Vector MouseWorldDirection, Vector HitLocation, Vector HitNormal)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = HitLocation;
	CachedMouseHitNormal = HitNormal;
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 0);
}

function MouseLeftReleased(Vector MouseWorldOrigin, Vector MouseWorldDirection)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = Vect(0.f, 0.f, 0.f);
	CachedMouseHitNormal = Vect(0.f, 0.f, 0.f);
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 1);
}

function MouseRightPressed(Vector MouseWorldOrigin, Vector MouseWorldDirection, Vector HitLocation, Vector HitNormal)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = HitLocation;
	CachedMouseHitNormal = HitNormal;
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 2);
}

function MouseRightReleased(Vector MouseWorldOrigin, Vector MouseWorldDirection)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = Vect(0.f, 0.f, 0.f);
	CachedMouseHitNormal = Vect(0.f, 0.f, 0.f);
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 3);
}

function MouseMiddlePressed(Vector MouseWorldOrigin, Vector MouseWorldDirection, Vector HitLocation, Vector HitNormal)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = HitLocation;
	CachedMouseHitNormal = HitNormal;
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 4);
}

function MouseMiddleReleased(Vector MouseWorldOrigin, Vector MouseWorldDirection)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = Vect(0.f, 0.f, 0.f);
	CachedMouseHitNormal = Vect(0.f, 0.f, 0.f);
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 5);
}

function MouseScrollUp(Vector MouseWorldOrigin, Vector MouseWorldDirection)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = Vect(0.f, 0.f, 0.f);
	CachedMouseHitNormal = Vect(0.f, 0.f, 0.f);
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 6);
}

function MouseScrollDown(Vector MouseWorldOrigin, Vector MouseWorldDirection)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = Vect(0.f, 0.f, 0.f);
	CachedMouseHitNormal = Vect(0.f, 0.f, 0.f);
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 7);
}

function MouseOver(Vector MouseWorldOrigin, Vector MouseWorldDirection)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = Vect(0.f, 0.f, 0.f);
	CachedMouseHitNormal = Vect(0.f, 0.f, 0.f);
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 8);
}

function MouseOut(Vector MouseWorldOrigin, Vector MouseWorldDirection)
{
	CachedMouseWorldOrigin = MouseWorldOrigin;
	CachedMouseWorldDirection = MouseWorldDirection;
	CachedMouseHitLocation = Vect(0.f, 0.f, 0.f);
	CachedMouseHitNormal = Vect(0.f, 0.f, 0.f);
	TriggerEventClass(class'SeqEvent_MouseInput', Self, 9);
}

function Vector GetHitLocation()
{
	return CachedMouseHitLocation;
}

function Vector GetHitNormal()
{
	return CachedMouseHitNormal;
}

function Vector GetMouseWorldOrigin()
{
	return CachedMouseWorldOrigin;
}

function Vector GetMouseWorldDirection()
{
	return CachedMouseWorldDirection;
}

//SAVE INFORMATION

function String Serialize()
{
	local JSonObject JSonObject;

	// Instance the JSonObject, abort if one could not be created
	JSonObject = new () class'JSonObject';
	if (JSonObject == None)
	{
		`Warn(Self$" could not be serialized for saving the game state.");
		return "";
	}

	// Serialize the path name so that it can be looked up later
	JSonObject.SetStringValue("Name", PathName(Self));

	// Serialize the object archetype, in case this needs to be spawned
	JSonObject.SetStringValue("ObjectArchetype", PathName(ObjectArchetype));

	// Save the location
	JSonObject.SetFloatValue("Location_X", Location.X);
	JSonObject.SetFloatValue("Location_Y", Location.Y);
	JSonObject.SetFloatValue("Location_Z", Location.Z);

	// Save the rotation
	JSonObject.SetIntValue("Rotation_Pitch", Rotation.Pitch);
	JSonObject.SetIntValue("Rotation_Yaw", Rotation.Yaw);
	JSonObject.SetIntValue("Rotation_Roll", Rotation.Roll);
	
	//SAVE MATERIAL
	JSonObject.SetStringValue("Material", PathName(StaticMeshComponent.GetMaterial(0)));
	
	//SAVE COLLISION INFO
	JSonObject.SetIntValue("Collision", (bCollideActors) ? 1 : 0);

	// Send the encoded JSonObject
	return class'JSonObject'.static.EncodeJson(JSonObject);
}

/**
 * Deserializes the actor from the data given
 *
 * @param		Data		JSon data representing the differential state of this actor
 */
function Deserialize(JSonObject Data)
{
	local Vector SavedLocation;
	local Rotator SavedRotation;
	local Material MyMaterial;


	// Deserialize the location and set it
	SavedLocation.X = Data.GetFloatValue("Location_X");
	SavedLocation.Y = Data.GetFloatValue("Location_Y");
	SavedLocation.Z = Data.GetFloatValue("Location_Z");

	// Deserialize the rotation and set it
	SavedRotation.Pitch = Data.GetIntValue("Rotation_Pitch");
	SavedRotation.Yaw = Data.GetIntValue("Rotation_Yaw");
	SavedRotation.Roll = Data.GetIntValue("Rotation_Roll");

	//LOAD MATERIAL]
	MyMaterial = Material(DynamicLoadObject(Data.GetStringValue("Material"), class'Material'));
	StaticMeshComponent.SetMaterial(0, MyMaterial);
	
	//LOAD COLLISION
	if (Data.GetIntValue("Collision") == 1)
		SetCollisionType(COLLIDE_BlockAll);
	
	if (StaticMeshComponent != None)
	{
		StaticMeshComponent.SetRBPosition(SavedLocation);
		StaticMeshComponent.SetRBRotation(SavedRotation);
	}
}


defaultproperties
{
	SupportedEvents(4)=class'SeqEvent_MouseInput'
}