"use strict";

var SNIPER_SELECT_REASON_KILLED = 0;
var SNIPER_SELECT_REASON_FREEBIE = 1;

function ChooseSniperAbility ( args ) {
	var character = args
	var playerID = Players.GetLocalPlayer()
	GameEvents.SendCustomGameEventToServer("sniper_select_choose_ability",
		{ "playerID" : playerID, "character" : character } )
	HideMenu()
}

function MakeButtonEnabled(buttonName) {
	$(buttonName).enabled = true;
}

function MakeButtonDisabled(args) {
	var buttonName = "#"+args.character+"Button";
	$(buttonName).enabled = false;
}

function MakeMenuVisible ( args ) {
	//var iPlayerID = Players.GetLocalPlayer()
	$.GetContextPanel().SetHasClass( "menu_visible", true );

	var reason = args.reason;
	var reasonText = "";
	if (reason == SNIPER_SELECT_REASON_KILLED){
		reasonText = $.Localize("#hvh_sniper_select_header_reason_kill")
	}
	else if (reason == SNIPER_SELECT_REASON_FREEBIE){
		reasonText = $.Localize("#hvh_sniper_select_header_reason_freebie")
	}

	$("#ReasonText").text = reasonText
}

function HideMenu() {
	$.GetContextPanel().SetHasClass( "menu_visible", false );
}

(function () {
	$.Msg("Subscribe");
	GameEvents.Subscribe("sniper_select_make_visible", MakeMenuVisible );
	GameEvents.Subscribe("sniper_select_disable_choice", MakeButtonDisabled)

	//MakeMenuVisible({"reason":SNIPER_SELECT_REASON_KILLED})
	//MakeButtonEnabled("#KardelButton")
	//MakeButtonEnabled("#RiggsButton")
	//MakeButtonEnabled("#FloraxButton")
	//MakeButtonEnabled("#JebbyButton")	
})();