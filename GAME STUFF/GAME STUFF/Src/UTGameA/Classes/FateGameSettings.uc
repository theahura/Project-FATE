/**
 *	FateGameSettings
 *
 *	Creation date: 17/06/2011 12:21
 *	Copyright 2011, Amol Kapoor
 */
class FateGameSettings extends UTGameSettingsCommon;



defaultproperties
{
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_CUSTOM,AdvertisementType=ODAT_OnlineService)

Properties(2)=(PropertyId=PROPERTY_GOALSCORE,Data=(Type=SDT_Int32,Value1=0),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(2)=(Id=PROPERTY_GOALSCORE,Name="GoalScore",MappingType=PVMT_PredefinedValues,PredefinedValues=((Type=SDT_Int32, Value1=0), (Type=SDT_Int32, Value1=5),(Type=SDT_Int32, Value1=10),(Type=SDT_Int32, Value1=15),(Type=SDT_Int32, Value1=20),(Type=SDT_Int32, Value1=25),(Type=SDT_Int32, Value1=30),(Type=SDT_Int32, Value1=35),(Type=SDT_Int32, Value1=40),(Type=SDT_Int32, Value1=45),(Type=SDT_Int32, Value1=50),(Type=SDT_Int32, Value1=55),(Type=SDT_Int32, Value1=60)))

	Properties(3)=(PropertyId=PROPERTY_TIMELIMIT,Data=(Type=SDT_Int32,Value1=0),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(3)=(Id=PROPERTY_TIMELIMIT,Name="TimeLimit",MappingType=PVMT_PredefinedValues,PredefinedValues=((Type=SDT_Int32, Value1=0), (Type=SDT_Int32, Value1=5),(Type=SDT_Int32, Value1=10),(Type=SDT_Int32, Value1=15),(Type=SDT_Int32, Value1=20),(Type=SDT_Int32, Value1=30),(Type=SDT_Int32, Value1=45),(Type=SDT_Int32, Value1=60)))

	Properties(4)=(PropertyId=PROPERTY_NUMBOTS,Data=(Type=SDT_Int32,Value1=0),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(4)=(Id=PROPERTY_NUMBOTS,Name="NumBots",MappingType=PVMT_PredefinedValues,PredefinedValues=((Type=SDT_Int32, Value1=0),(Type=SDT_Int32, Value1=1),(Type=SDT_Int32, Value1=2),(Type=SDT_Int32, Value1=3),(Type=SDT_Int32, Value1=4),(Type=SDT_Int32, Value1=5),(Type=SDT_Int32, Value1=6),(Type=SDT_Int32, Value1=7),(Type=SDT_Int32, Value1=8),(Type=SDT_Int32, Value1=9),(Type=SDT_Int32, Value1=10),(Type=SDT_Int32, Value1=11),(Type=SDT_Int32, Value1=12),(Type=SDT_Int32, Value1=13),(Type=SDT_Int32, Value1=14),(Type=SDT_Int32, Value1=15),(Type=SDT_Int32, Value1=16)))

}
