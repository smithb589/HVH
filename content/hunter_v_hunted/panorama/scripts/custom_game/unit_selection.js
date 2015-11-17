"use strict";

function AddToSelection ( args ) {
	var entIndex = args.ent_index

	//$.Msg("Add "+entIndex+" to Selection")

	GameUI.SelectUnit(entIndex, true)
	//OnUpdateSelectedUnit( args )
}

(function () {
	GameEvents.Subscribe( "add_to_selection", AddToSelection );
})();