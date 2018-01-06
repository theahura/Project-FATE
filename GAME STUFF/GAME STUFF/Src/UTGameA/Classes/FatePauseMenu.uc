/**
 *	FatePauseMenu
 *
 *	Creation date: 02/07/2013 22:39
 *	Copyright 2013, Amol Kapoor
 */
class FatePauseMenu extends GFxUI_PauseMenu;

function OnCloseAnimationComplete()
{
    FateHud(GetPC().MyHUD).CompletePauseMenuClose();
}

defaultproperties
{
}
