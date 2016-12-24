"use strict";

/* HVH */
function UpdateLogo()
{ 
	var logoDay = $("#HVH_Logo_Day");
	var logoNight = $("#HVH_Logo_Night");
	var hourglassDay = $("#HVH_Hourglass_Day");
	var hourglassNight = $("#HVH_Hourglass_Night");

	var isDaytime = CustomNetTables.GetTableValue("cycle", "IsDaytime")["value"]

	if (isDaytime)
	{
		hourglassDay.RemoveClass("Rotate");
		hourglassDay.AddClass("MakeVisible");
		hourglassNight.AddClass("Rotate");
		hourglassNight.RemoveClass("MakeVisible");

		logoDay.AddClass("MakeVisible");
		logoNight.RemoveClass("MakeVisible");
	}
	else
	{
		hourglassDay.AddClass("Rotate");
		hourglassDay.RemoveClass("MakeVisible");
		hourglassNight.RemoveClass("Rotate");
		hourglassNight.AddClass("MakeVisible");

		logoDay.RemoveClass("MakeVisible");
		logoNight.AddClass("MakeVisible");
	}

	$.Schedule( 1.0, UpdateLogo );
}

function PopBonusTime(args)
{
	var isDaytime = CustomNetTables.GetTableValue("cycle", "IsDaytime")["value"]
	var bonus = args["time"]
	var color = "";
	var pre = "";

	if (isDaytime)
	{
	    color = "#FCAF3D";
		pre = "+"
	}
	else
	{
		color = "#99CCFF";
		pre = "-"
	}	

	var bonusTimeParent = $("#HVH_BonusTimeSpawner")
	var bonusTime = $.CreatePanel( "Label", bonusTimeParent, "" );
	bonusTime.AddClass("HVH_BonusTime")
	bonusTime.AddClass("PopBonusTime");
	bonusTime.style["color"] = color;
	bonusTime.text = pre + bonus + " sec";
	$.Schedule(1.0, function(){
	      bonusTime.deleted = true;
	      bonusTime.DeleteAsync(0);
	});
}


(function()
{

})();


//------------------------------------------------------------------------------

var COLOUR_NORMAL = "#FFFFFF";
var COLOUR_WARNING = "#DF161F";
var TIMER_INTERVAL = 0.05;

var startTime = -1;
var timerDuration = 0;
var timerMode = 0; // Countdown = 0, Countup = 1
var timerMessage = "Remaining";
var timerEnd = false; // When true, hide on timer end
var timerPosition = 0; 
var timerPaused = false;
var timerSound = false;
var timer = null;
var timerWarning = -1; // Second to start warning at from end (-1 Disabled)
var timerLast = 0;

var timer = $( "#TimerBox" );

function UpdateTimer() {
	// Adjust the message based on time of day
	var day = CustomNetTables.GetTableValue("cycle", "IsDaytime")["value"];
	var imageSun = $("#HVH_Cycle_Sun");
	var imageMoon = $("#HVH_Cycle_Moon");

	var timerMessage;
	if (day) {
		imageSun.AddClass("MakeVisible");
		imageMoon.RemoveClass("MakeVisible");
		timerMessage = $.Localize("#custom_timer_daylight");
	}
	else {
		imageSun.RemoveClass("MakeVisible");
		imageMoon.AddClass("MakeVisible");
		timerMessage = $.Localize("#custom_timer_moonlight");
	}
	
	var timerTextMsg = $( "#TimerMsg" );
	timerTextMsg.text = $.Localize(timerMessage);

	if (timerPaused)
		startTime += 0.05;

	var timerTextRemain = $( "#TimerRemaining" );
	var time = Game.GetGameTime() - startTime;
	var remaining = CustomNetTables.GetTableValue("cycle", "TimeRemaining")["value"];
	
	if (remaining <= timerWarning && timerWarning != -1) {
		if (remaining != timerLast && timerSound) {
			timerLast = remaining;
			Game.EmitSound("ui.crafting_confirm_socket");
		}
		timerTextRemain.style['color'] = COLOUR_WARNING;
	}
	else
		timerTextRemain.style['color'] = COLOUR_NORMAL;
	if (remaining >= 0) {
		if (timerMode == 0)
			timerTextRemain.text = FormatTime(remaining);
		else
			timerTextRemain.text = FormatTime(time);
	}

	$.Schedule( TIMER_INTERVAL, UpdateTimer );
}

function DisplayTimer( table ) {
	timerMessage = table.msg || "Remaining";
	timerDuration = table.duration;
	timerMode = table.mode;
	timerEnd = table.endfade;
	timerPosition = table.position;
	timerWarning = table.warning;
	timerPaused = table.paused;
	timerSound = table.sound;
	startTime = Game.GetGameTime();
	var timerTextMsg = $( "#TimerMsg" );
	timerTextMsg.text = $.Localize(timerMessage);
	UpdateTimer();
}

function PauseTimer( bool ) {
	timerPaused = bool.pause;
}

function FormatTime( seconds ) {
	var minutes = Math.floor(seconds / 60);
	var seconds = Math.floor(seconds % 60);
	var s = "";
	if (seconds < 10)
		s = "0";
	return minutes + ":" + s + seconds;
}

/*function FormatTime( seconds ) {
	var hours = Math.floor(seconds / 3600);
	var remainder = seconds % 3600;
	var minutes = Math.floor(remainder / 60);
	var seconds = Math.floor(remainder % 60);
	var s = "";
	var m = "";
	var h = "";
	if (seconds < 10)
		s = "0";
	if (minutes < 10)
		m = "0";
	if (hours < 10)
		h = "0";
	return h + hours + ":" + m + minutes + ":" + s + seconds;
}*/

(function () {
	GameEvents.Subscribe( "display_timer", DisplayTimer );
	GameEvents.Subscribe( "pause_timer", PauseTimer );

	GameEvents.Subscribe("pop_bonus_time", PopBonusTime );
	UpdateLogo();
})();