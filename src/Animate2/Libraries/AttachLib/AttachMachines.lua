local Animate2 = script.Parent.Parent.Parent
local TrackThread = require(Animate2.TrackThread)
local Event = require(Animate2.Event)

local function AttachMachines(self)
	coroutine.wrap(function()
		if not self.TrackLists then
			self:UpdateConfig()
		end

		local machineDict = {}

		for name, machine in pairs(self.MachineClasses) do
			local trackLists = {}
			for _, animName in ipairs(machine.AnimScope) do
				trackLists[animName] = self.TrackLists[animName]
			end
			local newMachine = machine.new(trackLists)
			newMachine.Controller = newMachine.Controller or self
			newMachine.Thread = newMachine.Thread or TrackThread.new(newMachine, trackLists)
			newMachine.StateChanged = newMachine.StateChanged or Event.new()

			machineDict[name] = newMachine
		end

		local lastConns = self.Connections.Machines
		if lastConns then
			for _, dict in pairs(lastConns) do
				for _, conn in pairs(dict) do
					conn()
				end
			end
		end

		local conns = {}
		for name, machine in pairs(machineDict) do
			if machine.Triggers then
				local machineConns = {}
				conns[name] = machineConns
				for k, fn in pairs(machine.Triggers) do
					machineConns[k] = fn(machine)
				end

			end
		end

		self.Connections.Machines = conns

		self.Machines = machineDict
		self:GetAttachedSignal("Machines"):Fire(machineDict)
	end)()
end

return AttachMachines
