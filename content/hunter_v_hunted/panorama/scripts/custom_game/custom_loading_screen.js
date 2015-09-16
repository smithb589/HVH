// choose random hint
function Choose_Hint(){
	var count = Count_Localized_Strings();
	var r = Math.floor(Math.random() * count);
	var r_str = ("0"+r).slice(-2); // 00, 05, 13, etc.

	var tipHeader = $.Localize("game_info_tips_header");
	var tipText	  = $.Localize("game_info_tips_" + r_str);
	var tip = Root.FindChildTraverse("BelowTeamPanel").FindChildTraverse("TipLabel");
	tip.text = tipHeader + " #" + r_str +  ": "+ tipText;
	// (example output) Tip #14: Always bring a towel.
}

// an infinite loop that stops once an unlocalised string is found
// function assumes that game_info_tips_00 EXISTS
function Count_Localized_Strings(){
	var strBase = "game_info_tips_"
	for(i=0; i == i; i++){
		var num = i + 1;
		var num_str = ("0" + num).slice(-2);

		var textLocalized = $.Localize("game_info_tips_"+(num_str));
		
		// if the localized string is identical to the localized value,
		// then the end of the tips has been reached, so break the loop
		if(textLocalized == "game_info_tips_"+(num_str)){
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