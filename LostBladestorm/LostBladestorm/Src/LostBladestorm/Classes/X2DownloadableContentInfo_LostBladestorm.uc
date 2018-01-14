class X2DownloadableContentInfo_LostBladestorm extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	local X2CharacterTemplateManager CharacterManager;
	local X2ItemTemplateManager ItemManager;
	local X2CharacterTemplate CharacterTemplate;
	local array<X2DataTemplate> DataTemplates;
	local X2DataTemplate DataTemplate, DifficultyTemplate;

	CharacterManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	foreach CharacterManager.IterateTemplates(DataTemplate, None)
	{
		CharacterManager.FindDataTemplateAllDifficulties(DataTemplate.DataName, DataTemplates);
		foreach DataTemplates(DifficultyTemplate)
		{
			CharacterTemplate = X2CharacterTemplate(DifficultyTemplate);
			if (CharacterTemplate.CharacterGroupName == 'TheLost')
			{
//				`Log("Found template " $ DataTemplate.DataName $ ", adding LostBladestormAttack ability",,'LostBladestorm');
//				CharacterTemplate.Abilities.AddItem('LostBladestormAttack');
			}
		}
	}

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	AddBladestormToWeapon(ItemManager, 'TheLostTier1_MeleeAttack');
	AddBladestormToWeapon(ItemManager, 'TheLostTier2_MeleeAttack');
	AddBladestormToWeapon(ItemManager, 'TheLostTier3_MeleeAttack');
	AddBladestormToWeapon(ItemManager, 'TheLostHowlerTier1_MeleeAttack');
	AddBladestormToWeapon(ItemManager, 'TheLostHowlerTier2_MeleeAttack');
	AddBladestormToWeapon(ItemManager, 'TheLostHowlerTier3_MeleeAttack');
}

private static function AddBladestormToWeapon(X2ItemTemplateManager ItemManager, Name Item)
{
	local X2ItemTemplate ItemTemplate;
	local X2WeaponTemplate WeaponTemplate;

	ItemTemplate = ItemManager.FindItemTemplate(Item);
	if (ItemTemplate != none)
	{
		WeaponTemplate = X2WeaponTemplate(ItemTemplate);
		if (WeaponTemplate != none)
		{
			`log("Adding LostBladestormAttack to "$Item,,'LostBladestorm');
			WeaponTemplate.Abilities.AddItem('LostBladestormAttack');
		}
		else
		{
			`log("This is not a WeaponTemplate?"$Item,,'LostBladestorm');
		}
	}
	else
	{
		`log("FindItemTemplate("@Item@") returned none",,'LostBladestorm');
	}
}
