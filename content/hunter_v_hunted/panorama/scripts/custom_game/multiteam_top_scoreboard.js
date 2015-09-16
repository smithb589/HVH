"use strict";

var g_ScoreboardHandle = null;

/* HVH */
function UpdateLogo()
{ 
	var logoLabel = $.GetContextPanel().FindChild("HVH_Logo_Label");

	// TODO: day/night listener, possible using another custom net table to listen to Lua events
	var day = true;
	if (day)
	{
		logoLabel.SetHasClass( "Logo_Day", true );
		logoLabel.SetHasClass( "Logo_Night", false );
	}
	else
	{
		logoLabel.SetHasClass( "Logo_Day", false );
		logoLabel.SetHasClass( "Logo_Night", true );
	}
}

function UpdateScoreboard()
{
	ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );
	UpdateLogo() /* HVH */

	$.Schedule( 0.2, UpdateScoreboard );
}

(function()
{
	var shouldSort = true;

	if ( GameUI.CustomUIConfig().multiteam_top_scoreboard )
	{
		var cfg = GameUI.CustomUIConfig().multiteam_top_scoreboard;
		if ( cfg.LeftInjectXMLFile )
		{
			$( "#LeftInjectXMLFile" ).BLoadLayout( cfg.LeftInjectXMLFile, false, false );
		}
		if ( cfg.RightInjectXMLFile )
		{
			$( "#RightInjectXMLFile" ).BLoadLayout( cfg.RightInjectXMLFile, false, false );
		}

		if ( typeof(cfg.shouldSort) !== 'undefined')
		{
			shouldSort = cfg.shouldSort;
		}
	}
	
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_top_scoreboard_player.xml",
		"shouldSort" : shouldSort
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#MultiteamScoreboard" ) );

	UpdateScoreboard();
})();

