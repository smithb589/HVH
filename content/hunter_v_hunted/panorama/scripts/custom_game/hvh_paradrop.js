"use strict";

function ParadropCam_Start() {
	//$.Msg("ParadropCam start");

	GameUI.SetCameraPitchMin(90.0);
	GameUI.SetCameraPitchMax(90.0);
}

function ParadropCam_OnPhysicsFrame( args ) {
	var height = args.height;
	//$.Msg(height);

	GameUI.SetCameraDistance(height + 600);
}

function ParadropCam_End() {
	//$.Msg("ParadropCam end");
	GameUI.SetCameraPitchMin(25.0);
	GameUI.SetCameraPitchMax(65.0);
	GameUI.SetCameraDistance(1134.0);
}

(function () {
	GameEvents.Subscribe( "paradropCam_start", ParadropCam_Start );
	GameEvents.Subscribe( "paradropCam_onPhysicsFrame", ParadropCam_OnPhysicsFrame );
	GameEvents.Subscribe( "paradropCam_end", ParadropCam_End );
	
})();