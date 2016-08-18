if HVHErrorUtils == nil then
	HVHErrorUtils = class({})
end

function HVHErrorUtils:SendErrorToScreenTop(player, message)
	local payload = {}
	payload.style = { color = "red" }
	payload.text = message

	Notifications:ClearTop(player)
	Notifications:Top(player, payload)
	EmitSoundOnClient("General.InvalidTarget_Shop", player)
end