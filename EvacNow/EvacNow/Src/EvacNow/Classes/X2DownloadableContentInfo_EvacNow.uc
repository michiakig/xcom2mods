class X2DownloadableContentInfo_EvacNow extends X2DownloadableContentInfo;

static event OnLoadedSavedGame() {}
static event InstallNewCampaign(XComGameState StartState) {}

static event OnPostTemplatesCreated() {
	local X2AbilityTemplateManager Manager;
	local X2AbilityTemplate Template;

	Manager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Template = Manager.FindAbilityTemplate('PlaceEvacZone');
	if (Template != None)
		Template.TargetingMethod = class'X2TargetingMethod_EvacZone_EN';
	else
		`log("!! Failed to find AbilityTemplate PlaceEvacZone !!",,'EvacNow');
}
