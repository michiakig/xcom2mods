class X2DownloadableContentInfo_LostBladestorm extends X2DownloadableContentInfo;

static event OnPostTemplatesCreated()
{
	local X2CharacterTemplateManager Manager;
	local X2CharacterTemplate CharacterTemplate;
	local array<X2DataTemplate> DataTemplates;
	local X2DataTemplate DataTemplate, DifficultyTemplate;

	Manager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	foreach Manager.IterateTemplates(DataTemplate, None)
	{
		Manager.FindDataTemplateAllDifficulties(DataTemplate.DataName, DataTemplates);
		foreach DataTemplates(DifficultyTemplate)
		{
			CharacterTemplate = X2CharacterTemplate(DifficultyTemplate);
			if (CharacterTemplate.CharacterGroupName == 'TheLost')
			{
				`Log("Found template " $ DataTemplate.DataName $ ", adding LostBladestormAttack ability",,'LostBladestorm');
				CharacterTemplate.Abilities.AddItem('LostBladestormAttack');
			}
		}
	}
}
