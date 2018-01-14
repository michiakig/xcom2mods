class X2Ability_LostBladestormAttack extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.AddItem(CreateLostBladestormAttack());
	return Templates;
}

static function X2DataTemplate CreateLostBladestormAttack()
{
	local X2AbilityTemplate							Template;
	local X2AbilityToHitCalc_StandardMelee			ToHitCalc;
	local X2Effect_ApplyWeaponDamage_LB				PhysicalDamageEffect;
	local X2Condition_Visibility					TargetVisibilityCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LostBladestormAttack');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_escape";
	Template.Hostility = eHostility_Offensive;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	ToHitCalc.bReactionFire = true;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityTargetStyle = default.SimpleSingleMeleeTarget;

	AddBladestormTriggers(Template);

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bRequireBasicVisibility = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true; //Don't use peek tiles for over watch shots	
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	AddRangeCondition(Template);
	AddBladestormTargetEffect(Template);

	PhysicalDamageEffect = new class'X2Effect_ApplyWeaponDamage_LB';
	Template.AddTargetEffect(PhysicalDamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

//	Template.MergeVisualizationFn = LostAttack_MergeVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	Template.CustomFireAnim = 'FF_Melee';

	Template.CinescriptCameraType = "Lost_Attack";
	Template.bFrameEvenWhenUnitIsHidden = true;
	
	return Template;
}

/* from ranger bladestorm attack code: */
static function AddBladestormTriggers(X2AbilityTemplate Template)
{
	local X2AbilityTrigger_EventListener Trigger;
	//  trigger on movement
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);
	//  trigger on an attack
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'AbilityActivated';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalAttackListener;
	Template.AbilityTriggers.AddItem(Trigger);
}

/* necessary to limit range to 1 tile */
static function AddRangeCondition(X2AbilityTemplate Template)
{
	local X2Condition_LostBladestormRange RangeCondition;
	RangeCondition = new class'X2Condition_LostBladestormRange';
	Template.AbilityTargetConditions.AddItem(RangeCondition);
}

/* from ranger bladestorm attack code: */
static function AddBladestormTargetEffect(X2AbilityTemplate Template)
{
	local X2Effect_Persistent BladestormTargetEffect;
	local X2Condition_UnitEffectsWithAbilitySource BladestormTargetCondition;

	//Prevent repeatedly hammering on a unit with Bladestorm triggers.
	//(This effect does nothing, but enables many-to-many marking of which Bladestorm attacks have already occurred each turn.)
	BladestormTargetEffect = new class'X2Effect_Persistent';
	BladestormTargetEffect.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnEnd);
	BladestormTargetEffect.EffectName = 'LostBladestormTarget';
	BladestormTargetEffect.bApplyOnMiss = true; //Only one chance, even if you miss (prevents crazy flailing counter-attack chains with a Muton, for example)
	Template.AddTargetEffect(BladestormTargetEffect);
	
	BladestormTargetCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	BladestormTargetCondition.AddExcludeEffect('LostBladestormTarget', 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(BladestormTargetCondition);
}
