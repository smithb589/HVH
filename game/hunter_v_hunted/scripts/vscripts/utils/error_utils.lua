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

function HVHErrorUtils:SendNoteToScreenBottom(player, message)
	local payload = {}
	payload.style = { color = "orange" }
	payload.text = message

	Notifications:ClearBottom(player)
	Notifications:Bottom(player, payload)
	EmitSoundOnClient("Conquest.capture_point_timer", player)
end