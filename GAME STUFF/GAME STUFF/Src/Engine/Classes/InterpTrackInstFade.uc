/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class InterpTrackInstFade extends InterpTrackInst
	native(Interpolation);


cpptext
{
	// InterpTrackInst interface
	virtual void TermTrackInst(UInterpTrack* Track);
}
