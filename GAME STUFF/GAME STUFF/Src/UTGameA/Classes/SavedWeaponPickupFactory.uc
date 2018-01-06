/**
 *	SavedWeaponPickupFactory
 *
 *	Creation date: 03/08/2013 00:34
 *	Copyright 2013, Amol Kapoor
 */
class SavedWeaponPickupFactory extends UTWeaponPickupFactory
	Implements(SaveGameStateInterface);

/**
 * Serializes the actor's data into JSon
 *
 * @return		JSon data representing the state of this actor
 */
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
	
	//Enabled?
	JSonObject.SetIntValue("Enabled", (bIsActive) ? 1 : 0);

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

	// Deserialize the location and set it
	SavedLocation.X = Data.GetFloatValue("Location_X");
	SavedLocation.Y = Data.GetFloatValue("Location_Y");
	SavedLocation.Z = Data.GetFloatValue("Location_Z");

	// Deserialize the rotation and set it
	SavedRotation.Pitch = Data.GetIntValue("Rotation_Pitch");
	SavedRotation.Yaw = Data.GetIntValue("Rotation_Yaw");
	SavedRotation.Roll = Data.GetIntValue("Rotation_Roll");
	
	if (Data.GetIntValue("Enabled") == 0)
		bIsActive = false;

	if (BaseMesh != None)
	{
		BaseMesh.SetRBPosition(SavedLocation);
		BaseMesh.SetRBRotation(SavedRotation);
	}
}
