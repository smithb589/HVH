function GetTeamColorHex(team)
	if team == DOTA_TEAM_GOODGUYS then
		return SNIPERS_COLOR_HEX
	elseif team == DOTA_TEAM_BADGUYS then
		return NS_COLOR_HEX
	end
end