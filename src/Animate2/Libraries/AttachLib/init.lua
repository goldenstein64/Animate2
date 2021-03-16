local Animate2 = script.Parent.Parent
local Event = require(Animate2.Event)

local AttachLib = {
	Name = "AttachLib",
}

local attachedDict = {}

function AttachLib.new(self)
	attachedDict[self] = {
		Humanoid = Event.new(),
		Config = Event.new(),
		Machines = Event.new(),
	}
	self.Connections = {}
	self.DontWarnAttached = false
	self.DeepCopyAnimData = false
end

function AttachLib:GetAttachedSignal(name)
	assert(type(name) == "string", "A string has to be provided to this method!")

	local event = attachedDict[self][name]
	if not event then
		event = Event.new()
		attachedDict[self][name] = event
	end
	return event
end

function AttachLib:WaitForAttached(name)
	assert(type(name) == "string", "A string has to be provided to this method!")

	local attached = self[name]
	if attached then
		return attached
	else
		if not self.DontWarnAttached then
			delay(3, function()
				if not self[name] then
					warn(("{AttachLib} - Waiting for '%s'..."):format(name))
				end
			end)
		end
		return self:GetAttachedSignal(name):Wait()
	end
end

for _, module in ipairs(script:GetChildren()) do
	local fn = require(module)
	AttachLib[module.Name] = fn
end

return AttachLib
