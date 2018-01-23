class DisableRandomPostersSettings extends UIScreenListener config(DisableRandomPostersSettings);

`include(DisableRandomPosters/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(DisableRandomPosters/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config int VERSION;
var config bool MEMORIAL;
var config bool PROMOTED;
var config bool BONDED;
var config bool CAPTURED;
var config bool MISSION;

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

    Page = ConfigAPI.NewSettingsPage("Disable Random Posters");
    Page.SetPageTitle("Disable Random Posters");
    Page.SetSaveHandler(SaveButtonClicked);

    Group = Page.AddGroup('Group1', "Generate random posters for:");
    Group.AddCheckbox('checkbox', "Soldier KIA",      "If checked will generate random poster when high ranking soldiers are killed",             MEMORIAL, CheckboxSaveHandlerMemorial);
    Group.AddCheckbox('checkbox', "Soldier Promoted", "If checked will generate random poster when soldiers are promoted to Sergeant or Captain", PROMOTED, CheckboxSaveHandlerPromoted);
    Group.AddCheckbox('checkbox', "Soldiers Bonded",  "If checked will generate random poster when soldiers bond",                                BONDED,   CheckboxSaveHandlerBonded);
    Group.AddCheckbox('checkbox', "Soldier Captured", "If checked will generate random poster when soldiers are captured",                        CAPTURED, CheckboxSaveHandlerCaptured);
    Group.AddCheckbox('checkbox', "Mission finished", "If checked will generate random poster at the end of a mission",                           MISSION,  CheckboxSaveHandlerMission);

    Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'DisableRandomPosters_Defaults'.default.VERSION,VERSION)

simulated function LoadSavedSettings()
{
    MEMORIAL = `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.MEMORIAL,MEMORIAL);
    PROMOTED = `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.PROMOTED,PROMOTED);
    BONDED   = `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.BONDED,  BONDED);
    CAPTURED = `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.CAPTURED,CAPTURED);
    MISSION  = `MCM_CH_GetValue(class'DisableRandomPosters_Defaults'.default.MISSION, MISSION);
}

`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandlerMemorial, MEMORIAL)
`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandlerPromoted, PROMOTED)
`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandlerBonded,   BONDED)
`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandlerCaptured, CAPTURED)
`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandlerMission,  MISSION)

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.VERSION = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

defaultproperties
{
    ScreenClass = none;
}
