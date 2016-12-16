--------------------------------------------------------------------------------------------------------
-- Tower AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	-- preview pane is now spawning creatures in it, as of ~7.00
	if not IsServer() then return end

	Timers:CreateTimer(150.0, function()
		if AICore:IsTargetValid(thisEntity) then
			thisEntity:ForceKill(false)
			--print("Destroying tower for inactivity")
		end
	end)
end

-- TODO: tower death
-- TODO: tower sprays random explosions in a circular area