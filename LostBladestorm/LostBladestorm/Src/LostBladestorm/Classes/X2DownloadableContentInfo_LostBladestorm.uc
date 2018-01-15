class X2DownloadableContentInfo_LostBladestorm extends X2DownloadableContentInfo;

/* Adds the ability LostBladestorm to all weapons with the ability LostAttack */
static event OnPostTemplatesCreated()
{
	local X2ItemTemplateManager ItemManager;
	local array<X2WeaponTemplate> WeaponTemplates;
	local X2WeaponTemplate WeaponTemplate;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	WeaponTemplates = ItemManager.GetAllWeaponTemplates();
	foreach WeaponTemplates(WeaponTemplate)
	{
		if (WeaponTemplate.Abilities.Find('LostAttack') != INDEX_NONE)
		{
//			`log("Adding LostBladestormAttack to " $ WeaponTemplate.DataName,,'LostBladestorm');
			WeaponTemplate.Abilities.AddItem('LostBladestorm');
		}
	}
}
