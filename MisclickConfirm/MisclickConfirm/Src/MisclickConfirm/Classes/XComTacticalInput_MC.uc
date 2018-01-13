class XComTacticalInput_MC extends XComTacticalInput dependson(X2GameRuleset) config(TacticalInput_MC);

var array<TTile> SavedPathTiles;

function bool ClickToPath()
{
	local XComGameStateHistory History;
	local XComGameState_Unit ActiveUnitState;
	local XComGameState_Ability AbilityState;
	local GameRulesCache_Unit UnitCache;
	local XComPathingPawn PathingPawn;
	local array<TTile> WaypointTiles;
	local int ActionIndex;
	local int TargetIndex;
	local string ConfirmSound;
	local XComCoverPoint CoverPoint;
	local vector vDestination;
	local bool bFoundCover;
	local TTile PathTile;

	if(`XCOMVISUALIZATIONMGR.VisualizerBlockingAbilityActivation())
	{
		return false;
	}

	PathingPawn = XComTacticalController(Outer).m_kPathingPawn;

	// try to do a melee attack
	History = `XCOMHISTORY;

	ActiveUnitState = XComGameState_Unit(History.GetGameStateForObjectID(GetActiveUnit().ObjectID));
	AbilityState = class'X2AbilityTrigger_EndOfMove'.static.GetAvailableEndOfMoveAbilityForUnit(ActiveUnitState);
	if(AbilityState != none 
		&& PathingPawn.LastTargetObject != none
		&& `TACTICALRULES.GetGameRulesCache_Unit(ActiveUnitState.GetReference(), UnitCache))
	{
		// find the melee ability's location in the action array
		ActionIndex = UnitCache.AvailableActions.Find('AbilityObjectRef', AbilityState.GetReference());
		`assert(ActionIndex != INDEX_NONE); // since GetAvailableEndOfMoveAbilityForUnit told us this was available, it had better be available

		// and the targeted unit's location
		TargetIndex = UnitCache.AvailableActions[ActionIndex].AvailableTargets.Find('PrimaryTarget', PathingPawn.LastTargetObject.GetReference());
		PathingPawn.GetWaypointTiles(WaypointTiles);
		if(TargetIndex != INDEX_NONE && class'XComGameStateContext_Ability'.static.ActivateAbility(UnitCache.AvailableActions[ActionIndex], TargetIndex,,, PathingPawn.PathTiles, WaypointTiles))
		{
			//If there is a ConfirmSound for the melee ability, play it
			ConfirmSound = AbilityState.GetMyTemplate().AbilityConfirmSound;
			if (ConfirmSound != "")
				`SOUNDMGR.PlaySoundEvent(ConfirmSound);

			XComTacticalController(Outer).m_kPathingPawn.OnMeleeAbilityActivated();
			return true;
		}
	}

	vDestination = `XWORLD.GetPositionFromTileCoordinates(PathingPawn.LastDestinationTile);
	bFoundCover = `XWORLD.GetCoverPoint(vDestination, CoverPoint);

	if (!bFoundCover) {
		// Save the path before showing the pop up
		SavedPathTiles.Length = 0;
		foreach PathingPawn.PathTiles(PathTile) {
			SavedPathTiles.AddItem(PathTile);
		}

		ShowMisclickConfirmPopup();
		return true;
	}

	// we couldn't do a melee attack, so just do a normal path
	return XComTacticalController(Outer).PerformPath(GetActiveUnit(), true /*bUserCreated*/);
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

/* copied from XComTacticalController to limit the number of classes overridden
 * same as XComTacticalController.PerformPath except takes an array<TTile> instead of using m_kPathingPawn, which is mutated on ticks, including after the modal is dismissed
 */
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
		bSuccess = XComTacticalController(Outer).GameStateMoveUnitSingle(kUnit, TilePath, bUserCreated);
		if (bSuccess)
		{
			XComTacticalController(Outer).m_kPathingPawn.ClearAllWaypoints();
			XComTacticalController(Outer).m_kPathingPawn.ShowConfirmPuckAndHide();
			kUnit.m_bIsMoving = TRUE;
		}
	}
	else
	{
		return false;
	}

	return bSuccess;
}
