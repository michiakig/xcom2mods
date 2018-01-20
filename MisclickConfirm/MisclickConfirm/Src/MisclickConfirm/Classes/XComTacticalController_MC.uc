class XComTacticalController_MC extends XComTacticalController;

var array<TTile> SavedPathTiles;

private function bool AnyVisibleEnemiesNotLost(XComPathingPawn PathingPawn)
{
	local array<StateObjectReference> VisibleEnemies;
	local StateObjectReference EnemyRef;
	local XComGameState_Unit EnemyState;
	local XComGameState_Unit ActiveUnitState;

	ActiveUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(GetActiveUnit().ObjectID));
	class'X2TacticalVisibilityHelpers'.static.GetAllVisibleEnemyTargetsForUnit(ActiveUnitState.ObjectID, VisibleEnemies);

	if (VisibleEnemies.Length == 0)
	{
		return false;
	}

	foreach VisibleEnemies(EnemyRef) {
		EnemyState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EnemyRef.ObjectID));
		if (EnemyState.GetMyTemplate().CharacterGroupName != 'TheLost')
		{
			// Found a visible enemy that is not a Lost
			return true;
		}
	}
	// No visible enemies or only Lost
	return false;
}

private function bool DoesPathEndInCover(XComPathingPawn PathingPawn)
{
	local XComCoverPoint CoverPoint;
	local vector vDestination;

	vDestination = `XWORLD.GetPositionFromTileCoordinates(PathingPawn.LastDestinationTile);
	return `XWORLD.GetCoverPoint(vDestination, CoverPoint);
}

private function bool DoesPathEndInEvacZone(XComPathingPawn PathingPawn)
{
	local XComGameState_EvacZone EvacZoneState;
	local TTile Destination;
	local TTile EvacMin;
	local TTile EvacMax;

	Destination = PathingPawn.LastDestinationTile;
	EvacZoneState = class'XComGameState_EvacZone'.static.GetEvacZone(eTeam_XCom);
	class'XComGameState_EvacZone'.static.GetEvacMinMax(EvacZoneState.CenterLocation, EvacMin, EvacMax);

	return	Destination.X >= EvacMin.X &&
			Destination.Y >= EvacMin.Y &&
			Destination.Z >= EvacMin.Z &&
			Destination.X <= EvacMax.X &&
			Destination.Y <= EvacMax.Y &&
			Destination.Z <= EvacMax.Z ;
}

private function ShowMisclickConfirmPopup()
{
	local TDialogueBoxData dialog;
	local XComPresentationLayerBase presentationLayer;

	presentationLayer = XComPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController()).Pres;

	dialog.eType = eDialog_Warning;
	dialog.strTitle = "Misclick Confirm";
	dialog.strText = "Are you sure you want to move out of cover?";
	dialog.strAccept = "Yes";
	dialog.strCancel = "No";
	dialog.fnCallback = DialogCallback;

	presentationLayer.UIRaiseDialog(dialog);
}

simulated function bool PerformPath(XGUnit kUnit, optional bool bUserCreated=false)
{
	local TTile PathTile;

	if (AnyVisibleEnemiesNotLost(m_kPathingPawn) && !DoesPathEndInCover(m_kPathingPawn) && !DoesPathEndInEvacZone(m_kPathingPawn))
	{
		// Save the path before showing the pop up
		SavedPathTiles.Length = 0;
		foreach m_kPathingPawn.PathTiles(PathTile) {
			SavedPathTiles.AddItem(PathTile);
		}

		ShowMisclickConfirmPopup();
		return true;
	}

	return PerformPathWithTilePath(kUnit, m_kPathingPawn.PathTiles, bUserCreated);
}

simulated function bool PerformPathWithTilePath(XGUnit kUnit, array<TTile> TilePath, optional bool bUserCreated=false)
{
	local bool bSuccess;
	// Prevent adding a second move for a unit already in motion
	//if (`XCOMVISUALIZATIONMGR.IsSelectedActorMoving())
	if (kUnit.m_bIsMoving)
	{
		return false;
	}

	if(TilePath.Length > 1)
	{
		bSuccess = GameStateMoveUnitSingle(kUnit, TilePath, bUserCreated);
		if (bSuccess)
		{
			m_kPathingPawn.ClearAllWaypoints();
			m_kPathingPawn.ShowConfirmPuckAndHide();
			kUnit.m_bIsMoving = TRUE;
		}
	}
	else
	{
		return false;
	}

	return bSuccess;
}

`if(`isdefined(WOTC))
simulated private function DialogCallback(Name eAction)
`else
simulated private function DialogCallback(eUIAction eAction)
`endif
{
`if(`isdefined(WOTC))
	if (eAction == 'eUIAction_Accept')
`else
	if (eAction == eUIAction_Accept)
`endif
	{
		PerformPathWithTilePath(GetActiveUnit(), SavedPathTiles, true);
		// we're done with the saved path, so empty the array
		SavedPathTiles.Length = 0;
	}
}
