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
	$.Schedule(1.5, function(){
	      bonusTime.deleted = true;
	      bonusTime.DeleteAsync(0);
	});
}


(function()
{
	GameEvents.Subscribe("pop_bonus_time", PopBonusTime );	
	UpdateLogo();
})();
