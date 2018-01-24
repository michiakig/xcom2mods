class X2Photobooth_StrategyAutoGen_DRP extends X2Photobooth_StrategyAutoGen;

`include(DisableRandomPosters/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_VersionChecker(class'DisableRandomPosters_Defaults'.default.VERSION,class'DisableRandomPostersSettings'.default.VERSION)

function bool ShouldCreateMemorialPoster()
{
    return `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.MEMORIAL,class'DisableRandomPostersSettings'.default.MEMORIAL);
}

function bool ShouldCreateBondPoster()
{
    return `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.BONDED,class'DisableRandomPostersSettings'.default.BONDED);
}

function bool ShouldCreatePromotionPoster()
{
	return  `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.PROMOTED,class'DisableRandomPostersSettings'.default.PROMOTED);
}

function TakePhoto()
{
	local XComGameState_Unit Unit;
	local XComGameState_AdventChosen ChosenState;
	local SoldierBond BondData;
	local StateObjectReference BondmateRef;

	// Set things up for the next photo and queue it up to the photobooth.
	if (arrAutoGenRequests.Length > 0)
	{
		ExecutingAutoGenRequest = arrAutoGenRequests[0];

		AutoGenSettings.PossibleSoldiers.Length = 0;
		AutoGenSettings.PossibleSoldiers.AddItem(ExecutingAutoGenRequest.UnitRef);
		AutoGenSettings.TextLayoutState = ExecutingAutoGenRequest.TextLayoutState;
		AutoGenSettings.HeadShotAnimName = '';
		AutoGenSettings.CameraPOV.FOV = class'UIArmory_Photobooth'.default.m_fCameraFOV;
		AutoGenSettings.BackgroundDisplayName = class'UIPhotoboothBase'.default.m_strEmptyOption;
		SetFormation("Solo");

		switch (ExecutingAutoGenRequest.TextLayoutState)
		{
		case ePBTLS_DeadSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Full Frontal";
			break;
		case ePBTLS_PromotedSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Full Frontal";
			break;
		case ePBTLS_BondedSoldier:
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ExecutingAutoGenRequest.UnitRef.ObjectID));

			if (Unit.HasSoldierBond(BondmateRef, BondData))
			{
				AutoGenSettings.PossibleSoldiers.AddItem(BondmateRef);
				AutoGenSettings.CameraPresetDisplayName = "Full Frontal";

				SetFormation("Duo");
			}
			else
			{
				arrAutoGenRequests.Remove(0, 1);
				return;
			}
			break;
		case ePBTLS_CapturedSoldier:
			AutoGenSettings.CameraPresetDisplayName = "Captured";

			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ExecutingAutoGenRequest.UnitRef.ObjectID));
			ChosenState = XComGameState_AdventChosen(`XCOMHISTORY.GetGameStateForObjectID(Unit.ChosenCaptorRef.ObjectID));
			AutoGenSettings.BackgroundDisplayName = GetChosenBackgroundName(ChosenState);
			break;
		case ePBTLS_HeadShot:
			AutoGenSettings.CameraPresetDisplayName = "Headshot";
			AutoGenSettings.SizeX = ExecutingAutoGenRequest.SizeX;
			AutoGenSettings.SizeY = ExecutingAutoGenRequest.SizeY;
			AutoGenSettings.CameraDistance = ExecutingAutoGenRequest.CameraDistance;
			AutoGenSettings.HeadShotAnimName = ExecutingAutoGenRequest.AnimName;
			AutoGenSettings.CameraPOV.FOV = 80;
			break;
		}

		/* begin new code */
		switch (ExecutingAutoGenRequest.TextLayoutState)
		{
		case ePBTLS_DeadSoldier:
			CheckConfigAndHandle(ShouldCreateMemorialPoster(), ExecutingAutoGenRequest.UnitRef);
			break;
		case ePBTLS_PromotedSoldier:
			CheckConfigAndHandle(ShouldCreatePromotionPoster(), ExecutingAutoGenRequest.UnitRef);
			break;
		case ePBTLS_BondedSoldier:
			CheckConfigAndHandle(ShouldCreateBondPoster(), ExecutingAutoGenRequest.UnitRef);
			break;
		case ePBTLS_CapturedSoldier:
		case ePBTLS_HeadShot:
			`log("Auto-generating poster, Type=" $ AutoGenSettings.TextLayoutState $", UnitRef=" $ ExecutingAutoGenRequest.UnitRef.ObjectID $ ", FullName=" $ TryGetFullName(ExecutingAutoGenRequest.UnitRef),,'DisableRandomPosters');
			`PHOTOBOOTH.SetAutoGenSettings(AutoGenSettings, PhotoTaken);
			break;
		}
		/* end new code */
	}
	else
	{
		m_bTakePhotoRequested = false;
		Cleanup();
	}
}

private function CheckConfigAndHandle(bool Enabled, StateObjectReference UnitRef)
{
	if (Enabled)
	{
		`log("Auto-generating poster, Type=" $ AutoGenSettings.TextLayoutState $", UnitRef=" $ UnitRef.ObjectID $ ", FullName=" $ TryGetFullName(UnitRef),,'DisableRandomPosters');
		`PHOTOBOOTH.SetAutoGenSettings(AutoGenSettings, PhotoTaken);
	}
	else
	{
		`log("Skipping random poster, Type=" $ AutoGenSettings.TextLayoutState $", UnitRef=" $ UnitRef.ObjectID $ ", FullName=" $ TryGetFullName(UnitRef),,'DisableRandomPosters');
		PhotoTaken(UnitRef);
	}
}

function PhotoTaken(StateObjectReference UnitRef)
{
	super.PhotoTaken(UnitRef);
}

private function string TryGetFullName(StateObjectReference UnitRef)
{
	local XComGameState_Unit Unit;
	local string FullName;
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
	if (Unit != None)
	{
		FullName = Unit.GetFullName();
	}
	return FullName;
}
