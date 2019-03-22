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

function HVHErrorUtils:SendNoteToScreenBottomAll(message)
	local payload = {}
	payload.style = { color = "orange" }
	payload.text = message

	Notifications:ClearBottomFromAll()
	Notifications:BottomToAll(payload)
end