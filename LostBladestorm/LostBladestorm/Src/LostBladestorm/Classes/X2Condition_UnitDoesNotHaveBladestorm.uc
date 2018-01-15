class X2Condition_UnitDoesNotHaveBladestorm extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;
	local X2CharacterTemplate CharacterTemplate;
	local Name Ability;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
	{
		`log("TargetUnit is none",,'LostBladestorm');
		return 'AA_NotAUnit';
	}

	if (TargetUnit.FindAbility('Bladestorm').ObjectId == 0)
	{
		return 'AA_Success';
	}
	return 'AA_UnitHasBladestorm';
}
