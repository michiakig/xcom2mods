class X2Photobooth_TacticalAutoGen_DRP extends X2Photobooth_TacticalAutoGen;

`include(DisableRandomPosters/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_VersionChecker(class'DisableRandomPosters_Defaults'.default.VERSION,class'DisableRandomPostersSettings'.default.VERSION)

function bool ShouldCreateMissionPoster()
{
    return `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.MISSION,class'DisableRandomPostersSettings'.default.MISSION);
}

function RequestPhoto(delegate<OnPhotoTaken> inOnPhotoTaken)
{
	if (ShouldCreateMissionPoster())
	{
		super.RequestPhoto(inOnPhotoTaken);
	}
	else
	{
		inOnPhotoTaken();
	}
}
