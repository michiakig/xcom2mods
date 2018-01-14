class X2Condition_LostBladestormRange extends X2Condition;

/* Don't know why this is necessary. Without this Bladestorm was triggering 10+ tiles away. This limits it to melee range */
function name CallMeetsConditionWithSource(XComGameState_BaseObject kTarget, XComGameState_BaseObject kSource)
{
    local XComGameState_Unit Source;
    local XComGameState_Unit Target;
    local int Tiles;

    Source = XComGameState_Unit(kSource);
    Target = XComGameState_Unit(kTarget);
    Tiles = Source.TileDistanceBetween(Target);

    if (Tiles <= 1)
    {
        return 'AA_Success';
    }
	return 'AA_NotInRange';
}
