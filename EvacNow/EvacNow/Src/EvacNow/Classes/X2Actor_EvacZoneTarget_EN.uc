class X2Actor_EvacZoneTarget_EN extends X2Actor_EvacZoneTarget;

var const string UnsafeMeshPath;
var private StaticMesh UnsafeMesh;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	UnsafeMesh = StaticMesh(`CONTENT.RequestGameArchetype(default.UnsafeMeshPath));
	`assert(UnsafeMesh != none);
}

simulated function ShowGoodMesh()
{
	if (CanEveryoneReachEvacArea())
	{
		super.ShowGoodMesh();
	}
	else if (StaticMeshComponent.StaticMesh != UnsafeMesh)
	{
		StaticMeshComponent.SetStaticMesh(UnsafeMesh);
	}
}

/* Returns true if all units can reach the evac zone this turn */
function bool CanEveryoneReachEvacArea()
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference SquadRef;
	local XComGameState_Unit XComUnitState;
	local XGUnit Unit;

	local XComWorldData WorldData;
	local XCom3DCursor Cursor;
	local vector TargetLocation;
	local TTile CursorTile;

	WorldData = `XWORLD;
	Cursor = `Cursor;
	TargetLocation = Cursor.GetCursorFeetLocation();
	WorldData.GetFloorTileForPosition(TargetLocation, CursorTile);

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));

	foreach XComHQ.Squad(SquadRef)
	{
		XComUnitState = XComGameState_Unit(History.GetGameStateForObjectID(SquadRef.ObjectID));

		if( !XComUnitState.bRemovedFromPlay )
		{
			Unit = XGUnit(XComUnitState.GetVisualizer());
			if (Unit != None && !CanUnitReachEvacArea(Unit, CursorTile))
			{
				`log(XComUnitState.GetFullName() $ ", cannot reach evac area.",,'EvacNow');
				return false;
			}
		}
	}

	return true;
}

/* Returns true if the unit can reach at least one tile in the evac zone */
function bool CanUnitReachEvacArea(XGUnit Unit, TTile EvacCenterLoc)
{
	local TTile EvacMin, EvacMax, TestTile;

	class'XComGameState_EvacZone'.static.GetEvacMinMax2D( EvacCenterLoc, EvacMin, EvacMax );

	TestTile = EvacMin;
	while (TestTile.X <= EvacMax.X)
	{
		while (TestTile.Y <= EvacMax.Y)
		{
			if (Unit.m_kReachableTilesCache.IsTileReachable(TestTile))
			{
				return true;
			}
			TestTile.Y++;
		}
		TestTile.Y = EvacMin.Y;
		TestTile.X++;
	}

	return false;
}

DefaultProperties
{
	UnsafeMeshPath = "UI_3D_EvacNow.Evacuation.EvacLocation_Unsafe"
}
