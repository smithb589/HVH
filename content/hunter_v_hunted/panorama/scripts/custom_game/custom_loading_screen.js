// choose random hint
function Choose_Hint(){
	var count = Count_Localized_Strings();
	var r = Math.floor(Math.random() * count);
	var strR = ("0"+r).slice(-2);

	// accepted random localized string
	var strLocalized = $.Localize("game_info_tips_" + strR);
	
	var tipLabel = Root.FindChildTraverse("BelowTeamPanel").FindChildTraverse("TipLabel");
	tipLabel.text = "Hint #" + strR +  ": "+ strLocalized;
}

// an infinite loop that stops once an unlocalised string is found
// function assume that atleast a hint game_info_tips__00 EXISTS
function Count_Localized_Strings(){
	var strBase = "game_info_tips_"
	for(i=0; i == i; i++){
		var num = i + 1;
		var strNum = ("0" + num).slice(-2);

		// store localized string based on i Index
		var strLocalized = $.Localize("game_info_tips_"+(strNum));
		
		// check if the localized string is identical to the localize value, if true that means there's no localisation for this, we assume at least.
		if(strLocalized == "game_info_tips_"+(strNum)){
			//$.Msg("BREAKING OUT OF COUNT, COUNT="+i)
			return i;
			break;
		}
	}
}

function Check_Loading(){
	var GameState = Game.GetState();
	var BelowTeamPanel = Root.FindChildTraverse("BelowTeamPanel");

	if(GameState == DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP){
		BelowTeamPanel.visible = true;
		//Root.SetHasClass("Done_Loading", true)
	}	
	else{
		BelowTeamPanel.visible = false;
		$.Schedule(0.1, Check_Loading);
	}
}
// root panel
var Root = $.GetContextPanel();

(function () {
	Choose_Hint();
	Check_Loading();
})();