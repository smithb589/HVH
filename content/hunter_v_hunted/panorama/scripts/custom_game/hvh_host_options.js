(function () {
	// defaults
	$( "#EnableTutorialRadio_Yes" ).checked = true;
	$( "#NeutralCreepsRadio_2" ).checked = true;
	$( "#NotEnoughPlayersRadio_Hounds" ).checked = true;
	$( "#EnableMinimapRadio_Yes" ).checked = true;
	$( "#CameraSettingsRadio_Default" ).checked = true;

	GameEvents.Subscribe("save_host_options", SaveHostOptions );
	GameEvents.Subscribe("disable_minimap", DisableMinimap );
})();

function ToggleOptionsVisibility (  ) {
	var panel = $( "#HVHHostOptions" );
	panel.ToggleClass( "menu_visible" );

	panel.wasClickedOn = true;
}

function SaveHostOptions () {
	// if Options button was clicked on, enable host options and override defaults
	var wasClickedOn = $( "#HVHHostOptions" ).wasClickedOn;

	var neutralCreeps = null;
	if ($("#NeutralCreepsRadio_0").IsSelected())
		neutralCreeps = "none";
	else if ($("#NeutralCreepsRadio_1").IsSelected())
		neutralCreeps = "low";
	else if ($("#NeutralCreepsRadio_2").IsSelected())
		neutralCreeps = "medium";
	else if ($("#NeutralCreepsRadio_3").IsSelected())
		neutralCreeps = "high";
	else if ($("#NeutralCreepsRadio_4").IsSelected())
		neutralCreeps = "extreme";

	var cameraSettings = null;
	if ($("#CameraSettingsRadio_Default").IsSelected())
		cameraSettings = "default";
	else if ($("#CameraSettingsRadio_Locked").IsSelected())
		cameraSettings = "locked";
	else if ($("#CameraSettingsRadio_Showcase").IsSelected())
		cameraSettings = "showcase";

	GameEvents.SendCustomGameEventToServer("load_host_options", {
		"HostOptionsEnabled" : wasClickedOn,
		"EnableTutorial": $( "#EnableTutorialRadio_Yes" ).IsSelected(),
		"NeutralCreeps"	: neutralCreeps,
		"DisablePhoenix" 	: $( "#DisablePhoenix" ).IsSelected(),
		"DisableMegacreepsSolo" 	: $( "#DisableMegacreepsSolo" ).IsSelected(),
		"DisableMegacreepsWarparty" : $( "#DisableMegacreepsWarparty" ).IsSelected(),
		"DisableUrsaAndRoshan" 		: $( "#DisableUrsaAndRoshan" ).IsSelected(),
		"DisableEnigma" 	: $( "#DisableEnigma" ).IsSelected(),
		"DisableHellbears" 	: $( "#DisableHellbears" ).IsSelected(),					
		"DisableTiny" 		: $( "#DisableTiny" ).IsSelected(),
		"DisableTechies" 	: $( "#DisableTechies" ).IsSelected(),
		"SpawnExtraHounds"	: $( "#NotEnoughPlayersRadio_Hounds").IsSelected(),
		"EnableMinimap"		: $( "#EnableMinimapRadio_Yes" ).IsSelected(),
		"CameraSettings"	: cameraSettings,
	})
}

// TODO: fix DC'd players and make this animated
function DisableMinimap () {
	GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false );     //Minimap.
}