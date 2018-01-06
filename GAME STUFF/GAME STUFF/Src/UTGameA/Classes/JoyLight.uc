/**
 *	JoyLight
 *
 *	Creation date: 29/10/2012 13:30
 *	Copyright 2012, Amol Kapoor
 */
class JoyLight extends PointLightMovable;

var float BrightStep; 
var float LightStartBrightness;
var float TimesToInterp; 
var float KillTimer;
var float HowOftenToInterp; 
var float DefaultLightBrightness;

function turnOn() {
	LightComponent.SetEnabled(true);
}

function turnOff() {

	LightComponent.SetEnabled(false);
}

function setBrightness(float f) {
	LightComponent.SetLightProperties(f);
	LightStartBrightness = f; 
}

function setColor(byte ir, byte ig, byte ib, byte ia) {
	local color c;
	
	c.R = ir;
	c.G = ig;
	c.B = ib;
	c.A = ia;

	LightComponent.SetLightProperties(,c); 
}

//default 1024.0
function setRadius(float r) {
	PointLightComponent(LightComponent).Radius = r;
}

//default 2.0
function setFallOffExponent(float e) {
	PointLightComponent(LightComponent).FalloffExponent = e;
}

//default 2.0
function setShadowFalloffExponent(float e) {
	PointLightComponent(LightComponent).ShadowFalloffExponent = e;
}

//default 1.1
function setShadowRadiusMultiplier(float f) {
	PointLightComponent(LightComponent).ShadowRadiusMultiplier = f;
}

function setCastDynamicShadows(bool b) {
	LightComponent.CastDynamicShadows = b;
}

//below is showing how to move the light
//every light you spawn will gradually rise
//if you uncomment this function
//use similar code where/how you actually want
//to move the light
/*
function tick(Float DT) {
	super.tick(DT);
	move(vect(0, 0, 1));
}
*/

function SetInterpSpeed(Float InterpTime, Byte FrameRate, float TotalChange)
{

	HowOftenToInterp = 1 / FrameRate; // turns fps into a frame duration
	TimesToInterp = InterpTime / HowOftenToInterp;
	BrightStep = TotalChange / TimesToInterp;
	//resulting set timer call
	SetTimer(HowOftenToInterp,True,'LightPulseInterp');
}



//Actual interpolating function
function LightPulseInterp()
{
	LightStartBrightness+=BrightStep; //Increments LightStartBrightness Variable
	LightComponent.SetLightProperties(LightStartBrightness); //Sets brightness of light to new value
	KillTimer+=1; //increments killtimer

	if(KillTimer==TimesToInterp)
	{
		ClearTimer('LightPulseInterp');
		KillTimer=0; //resetting KillTimer For Further use 
		BrightStep = BrightStep *-1; //Switches Sign before restarting timer
		SetTimer(HowOftenToInterp,True,'LightPulseInterp'); //Calling itself with inverse value of brightstep
	}
}

//shuts the light off
function KillLight()
{
	ClearTimer('LightPulseInterp');
	KillTimer=0;
	LightComponent.SetLightProperties(0.0);
	LightStartBrightness = DefaultLightBrightness;
}


DefaultProperties
{
        bNoDelete = false
	
        //for use with actor.move()
        bCollideActors = false
	bCollideWorld = false

	        LightStartBrightness= 0.5;
	DefaultLightBrightness = 0.5;
}