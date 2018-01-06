/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// GenericBrowserType_LensFlare: LensFlare
//=============================================================================

class GenericBrowserType_LensFlare
	extends GenericBrowserType
	native;

cpptext
{
	virtual void Init();
	virtual UBOOL ShowObjectEditor( UObject* InObject );

	/**
	 * Returns a list of commands that this object supports (or the object type supports, if InObject is NULL)
	 *
	 * @param	InObjects		The objects to query commands for (if NULL, query commands for all objects of this type.)
	 * @param	OutCommands		The list of custom commands to support
	 */
	virtual void QuerySupportedCommands( class USelection* InObjects, TArray< FObjectSupportedCommandType >& OutCommands ) const;
}
	
defaultproperties
{
	Description="Lens Flares"
}