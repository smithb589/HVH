(function () {

	$( "#EnableTutorialRadio_Yes" ).checked = true;
	$( "#NeutralCreepsRadio_2" ).checked = true;
	$( "#NotEnoughPlayersRadio_Hounds" ).checked = true;

	GameEvents.Subscribe("save_host_options", SaveHostOptions );
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

	GameEvents.SendCustomGameEventToServer("load_host_options", {
		"HostOptionsEnabled" : wasClickedOn,
		"EnableTutorial": $( "#EnableTutorialRadio_Yes" ).IsSelected(),
		"NeutralCreeps"	: neutralCreeps,
		"DisableMegacreepsSolo" 	: $( "#DisableMegacreepsSolo" ).IsSelected(),
		"DisableMegacreepsWarparty" : $( "#DisableMegacreepsWarparty" ).IsSelected(),
		"DisableUrsaAndRoshan" 		: $( "#DisableUrsaAndRoshan" ).IsSelected(),
		"DisableEnigma" 	: $( "#DisableEnigma" ).IsSelected(),
		"DisableHellbears" 	: $( "#DisableHellbears" ).IsSelected(),					
		"DisableTiny" 		: $( "#DisableTiny" ).IsSelected(),
		"DisableTechies" 	: $( "#DisableTechies" ).IsSelected(),
		"SpawnExtraHounds"	: $( "#NotEnoughPlayersRadio_Hounds").IsSelected(),
	})
}