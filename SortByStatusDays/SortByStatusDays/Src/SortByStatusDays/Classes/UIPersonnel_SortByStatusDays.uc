class UIPersonnel_SortByStatusDays extends UIPersonnel;

simulated function int SortByStatus(StateObjectReference A, StateObjectReference B)
{
	local XComGameState_Unit UnitA, UnitB;
	local string StatusA, StatusB;
	local string TimeLabelA, TimeLabelB;
	local int TimeValueA, TimeValueB;

	UnitA = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(A.ObjectID));
	UnitB = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(B.ObjectID));

	// Sort by time remaining until available
	UnitA.GetStatusStringsSeparate(StatusA, TimeLabelA, TimeValueA);
	UnitB.GetStatusStringsSeparate(StatusB, TimeLabelB, TimeValueB);

	if( TimeValueA < TimeValueB )
	{
		return m_bFlipSort ? -1 : 1;
	}
	else if( TimeValueA > TimeValueB )
	{
		return m_bFlipSort ? 1 : -1;
	}
	return 0;
}
