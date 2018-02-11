class X2DownloadableContentInfo_WeaponMalfunction extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	local X2AbilityTemplateManager AbilityManager;
	local X2AbilityTemplate Template;

	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = AbilityManager.FindAbilityTemplate('StandardShot');
	if (Template == None)
	{
		`log("Couldn't find the StandardShot ability template??",,'WeaponMalfunction');
		return;
	}

	Template.BuildInterruptGameStateFn = WeaponMalfunction_BuildInterruptGameState;
}

function XComGameState WeaponMalfunction_BuildInterruptGameState(XComGameStateContext Context, int InterruptStep, EInterruptionStatus InterruptionStatus)
{
	local XComGameStateContext_Ability AbilityContext;

//	`log("WeaponMalfunction_BuildInterruptGameState(XComGameStateContext ...," $ InterruptStep $ ", " $ InterruptionStatus $ ")",,'WeaponMalfunction');

	AbilityContext = XComGameStateContext_Ability(Context);
	if (AbilityContext != None && AbilityContext.ResultContext.HitResult == eHit_Miss && DidWeaponJam())
	{
//		`log("AbilityContext.ResultContextMalfunction!",,'WeaponMalfunction');
		return Malfunction_BuildGameState(Context);
	}
	return class 'X2Ability'.static.TypicalAbility_BuildInterruptGameState(Context, InterruptStep, InterruptionStatus);
}

function bool DidWeaponJam()
{
	local int Roll;
	Roll = `SYNC_RAND_TYPED(100, ESyncRandType_Generic);
	`log("DidWeaponJam, Rand:" $ Rand,,'WeaponMalfunction');
	return Roll < 10;
}

function XComGameState Malfunction_BuildGameState(XComGameStateContext Context)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item WeaponState, NewWeaponState;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);
	AbilityContext = XComGameStateContext_Ability(Context);	
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID( AbilityContext.InputContext.AbilityRef.ObjectID ));

	WeaponState = AbilityState.GetSourceWeapon();
	NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', WeaponState.ObjectID));

	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));	

	// use an action point
	AbilityState.GetMyTemplate().ApplyCost(AbilityContext, AbilityState, UnitState, NewWeaponState, NewGameState);	

	// empty the weapon's ammo
	NewWeaponState.Ammo = 0;
	
	NewGameState.AddStateObject(UnitState);
	NewGameState.AddStateObject(NewWeaponState);

	return NewGameState;	
}
