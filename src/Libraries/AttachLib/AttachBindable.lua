local Animate2 = script.Parent.Parent.Parent
local EMOTE_NAMES = require(Animate2.EMOTE_NAMES)

local function AttachBindable(self, bindable)
	coroutine.wrap(function()
		assert(
			typeof(bindable) == "Instance" and bindable:IsA("BindableFunction"),
			"A BindableFunction has to be provided to this method!"
		)

		self:WaitForAttached("Machines")

		function bindable.OnInvoke(anim)
			local type_anim = typeof(anim)
			if
				self.Machines.Main.Current.AllowEmotes
				and (type_anim == "string" and EMOTE_NAMES[anim] ~= nil or type_anim == "Instance")
			then
				self.Machines.Main:ChangeState("Emote", anim)
				return true
			end
		end
	end)()
end

return AttachBindable
