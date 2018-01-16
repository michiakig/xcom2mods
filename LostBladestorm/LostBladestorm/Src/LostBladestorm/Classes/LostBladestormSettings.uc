class LostBladestormSettings extends UIScreenListener config(LostBladestormSettings);

`include(LostBladestorm/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(LostBladestorm/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config bool TRIGGER_ON_ATTACK;
var config int CONFIG_VERSION;

event OnInit(UIScreen Screen)
{
	if (MCM_API(Screen) != none)
	{
		`MCM_API_Register(Screen, ClientModCallback);
	}
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local MCM_API_SettingsGroup Group;

    LoadSavedSettings();

    Page = ConfigAPI.NewSettingsPage("Lost Bladestorm");
    Page.SetPageTitle("Lost Bladestorm");
    Page.SetSaveHandler(SaveButtonClicked);

    Group = Page.AddGroup('Group1', "Trigger On:");
    Group.AddCheckbox('checkbox', "Attacks", "Whether Lost Bladestorm should activate when a nearby unit attacks", TRIGGER_ON_ATTACK, CheckboxSaveHandler);

    Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'LostBladestorm_Defaults'.default.VERSION,CONFIG_VERSION)

simulated function LoadSavedSettings()
{
    TRIGGER_ON_ATTACK = `MCM_CH_GetValue(class'LostBladestorm_Defaults'.default.TRIGGER_ON_ATTACK,TRIGGER_ON_ATTACK);
}

`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandler, TRIGGER_ON_ATTACK)

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

defaultproperties
{
    ScreenClass = none;
}
