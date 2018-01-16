class X2Ability_LostBladestormAttack extends X2Ability;

/* manually expanding an MCM macro so it can be static */
static function bool ShouldTriggerOnAttack()
{
	if (class'LostBladestorm_Defaults'.default.VERSION > class'LostBladestormSettings'.default.CONFIG_VERSION)
	{
		return class'LostBladestorm_Defaults'.default.TRIGGER_ON_ATTACK;
	}
	else
	{
		return class'LostBladestormSettings'.default.TRIGGER_ON_ATTACK;
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

	/* attach a conditional listener to make trigger on attack configurable */
	SetConditionalAttackListener(Template);

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

static function SetConditionalAttackListener(X2AbilityTemplate Template)
{
	local X2AbilityTrigger Trigger;
	local X2AbilityTrigger_EventListener EventListener;

	foreach Template.AbilityTriggers(Trigger)
	{
		EventListener = X2AbilityTrigger_EventListener(Trigger);
		if (EventListener != none && EventListener.ListenerData.EventID == 'AbilityActivated')
		{
			EventListener.ListenerData.EventFn = ConditionalAttackListener;
		}
	}
}

static function EventListenerReturn ConditionalAttackListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit TargetUnit;
	local XComGameStateContext_Ability AbilityContext;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability Ability;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext != none)
	{
		TargetUnit = XComGameState_Unit(EventSource);
		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);
		Ability = XComGameState_Ability(CallbackData);
		if (Ability != none && AbilityTemplate != none && AbilityTemplate.Hostility == eHostility_Offensive && (Ability.CanActivateAbilityForObserverEvent( TargetUnit ) == 'AA_Success'))
		{
			if (ShouldTriggerOnAttack())
			{
				Ability.AbilityTriggerAgainstSingleTarget(TargetUnit.GetReference(), false);
			}
		}
	}	

	return ELR_NoInterrupt;
}
