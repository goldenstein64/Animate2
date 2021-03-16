local Players = game:GetService("Players")

local Animate2 = script.Parent.Parent.Parent
local EMOTE_NAMES = require(Animate2.EMOTE_NAMES)

local localPlayer = Players.LocalPlayer

local R = Random.new()

local function fnWrapper(conn)
	return function()
		conn:Disconnect()
	end
end

local function onPlayerChatted(self, msg)
	local emote
	if msg:sub(1, 3) == "/e " then
		emote = msg:sub(4)
	elseif msg:sub(1, 7) == "/emote " then
		emote = msg:sub(8)
	end

	if emote and EMOTE_NAMES[emote] ~= nil and self.Machines.Main.Current.AllowEmotes then
		if emote == "dance" then
			emote = string.format("dance%d", R:NextInteger(1, 3))
		end
		self.Machines.Main:ChangeState("Emote", emote)
	end
end

local function AttachChatted(self, player)
	coroutine.wrap(function()
		player = player or localPlayer

		self:WaitForAttached("Machines")

		if self.Connections.Chatted then
			self.Connections.Chatted()
		end
		self.Connections.Chatted = fnWrapper(player.Chatted:Connect(function(msg)
			onPlayerChatted(self, msg)
		end))
	end)()
end

return AttachChatted
