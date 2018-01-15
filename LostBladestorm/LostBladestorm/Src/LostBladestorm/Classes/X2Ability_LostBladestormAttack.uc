class X2Ability_LostBladestormAttack extends X2Ability;

/* manually expanding an MCM macro so it can be static */
static function bool GetTriggerOnAttackSetting()
{
	if (class'LostBladestorm_Defaults'.default.VERSION > class'LostBladestormMCMListener'.default.CONFIG_VERSION)
	{
		return class'LostBladestorm_Defaults'.default.TRIGGER_ON_ATTACK;
	}
	else
	{
		return class'LostBladestormMCMListener'.default.TRIGGER_ON_ATTACK;
	}
}

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.AddItem(CreateLostBladestormAttack());
	Templates.AddItem(CreateLostBladestorm());
	return Templates;
}

static function X2AbilityTemplate CreateLostBladestorm()
{
	local X2AbilityTemplate Template;
	Template = PurePassive('LostBladestorm', "img:///UILibrary_PerkIcons.UIPerk_bladestorm", false, 'eAbilitySource_Perk');
	Template.AdditionalAbilities.AddItem('LostBladestormAttack');
	return Template;
}

static function X2DataTemplate CreateLostBladestormAttack()
{
	local X2AbilityTemplate Template;
	local X2Condition_LostBladestormRange RangeCondition;
	local X2Condition_UnitDoesNotHaveBladestorm ExcludeOtherBladestormCondition;
	Template = class'X2Ability_RangerAbilitySet'.static.BladestormAttack('LostBladestormAttack');

	/* disable trigger on attack if it's been disabled */
	if (!GetTriggerOnAttackSetting())
	{
		RemoveAbilityActivatedTrigger(Template);
	}

	/* necessary to limit range to 1 tile */
	RangeCondition = new class'X2Condition_LostBladestormRange';
	Template.AbilityTargetConditions.AddItem(RangeCondition);

	/* values from Lost melee attack */
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_escape";
	Template.Hostility = eHostility_Offensive;
//	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
//	Template.MergeVisualizationFn = LostAttack_MergeVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.CustomFireAnim = 'FF_Melee';
	Template.CinescriptCameraType = "Lost_Attack";

	/* do not trigger for units with bladestorm, gets game in a bugged state */
	ExcludeOtherBladestormCondition = new class'X2Condition_UnitDoesNotHaveBladestorm';
	Template.AbilityTargetConditions.AddItem(ExcludeOtherBladestormCondition);

	return Template;
}

static function UpdateLostBladestormWithSetting(bool bTriggerOnAttack)
{
	local X2AbilityTemplate Template;
	local X2AbilityTemplateManager AbilityManager;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate('LostBladestormAttack');

	if (Template != none)
	{
		// always remove, then if it's enabled, add it back in.
		RemoveAbilityActivatedTrigger(Template);
		if (bTriggerOnAttack)
		{
			AddAbilityActivatedTrigger(Template);
		}
	}
}

static function AddAbilityActivatedTrigger(X2AbilityTemplate Template)
{
	local X2AbilityTrigger_EventListener Trigger;
//	`log("Adding ability activated trigger",,'LostBladestorm');

	/* from ranger bladestorm code: */
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'AbilityActivated';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalAttackListener;
	Template.AbilityTriggers.AddItem(Trigger);
}

static function RemoveAbilityActivatedTrigger(X2AbilityTemplate Template)
{
	local X2AbilityTrigger AbilityTrigger;
	local X2AbilityTrigger_EventListener EventListener;
	local int index;
	local bool found;

//	`log("Removing ability activated trigger",,'LostBladestorm');
	found = false;
	for (index = 0; index < Template.AbilityTriggers.Length; ++index)
	{
		AbilityTrigger = Template.AbilityTriggers[index];
		EventListener = X2AbilityTrigger_EventListener(AbilityTrigger);
		if (EventListener != none && EventListener.ListenerData.EventID == 'AbilityActivated')
		{
			found = true;
			break;
		}
	}
	if (found)
	{
		Template.AbilityTriggers.Remove(index, 1);
	}
}
