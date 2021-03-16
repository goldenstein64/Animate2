local MachineLib = {
	Name = "MachineLib",
}

MachineLib.MachinePriority = {
	[1] = "Main",
}

local stateNull = {
	Name = "Null",

	onBind = function(self)
		self.Thread:Stop()
	end,
}

local stateChangingQueue = {}
local prototype = {}
prototype.__index = prototype

prototype.Current = stateNull
function prototype:BindState(stateName, ...)
	if not self.Current then
		local state = assert(self.States[stateName], ("This state (%s) does not exist!"):format(stateName))

		local results
		if state.onBind then
			results = table.pack(state.onBind(self, ...))
		else
			results = { n = 0 }
		end

		self.Current = state

		return table.unpack(results, 1, results.n)
	end
end

function prototype:UnbindState(nextStateName)
	local state = self.Current
	if state then
		if not nextStateName then
			nextStateName = "Null"
			self:BindState("Null")
		end

		local results = table.pack(state.onUnbind(nextStateName))

		return table.unpack(results, 1, results.n)
	end
end

function queuelessChangeState(self, stateName, ...)
	local old = self.Current
	local new = assert(self.States[stateName], ("This state (%s) does not exist!"):format(stateName))

	if old == new and new.onRebind then
		return new.onRebind(self, ...)
	else
		if old.onUnbind then
			old.onUnbind(self, stateName)
		end

		local results
		if new.onBind then
			results = table.pack(new.onBind(self, ...))
		else
			results = { n = 0 }
		end
		self.Current = new

		self.StateChanged:Fire(old.Name, stateName)

		return table.unpack(results, 1, results.n)
	end
end

function prototype:ChangeState(stateName, ...)
	local queue = stateChangingQueue[self]
	if not queue then
		queue = {}
		stateChangingQueue[self] = queue
		local old = self.Current
		local new = assert(self.States[stateName], ("This state (%s) does not exist!"):format(stateName))

		if old == new and new.onRebind then
			return new.onRebind(self, ...)
		else
			if old.onUnbind then
				old.onUnbind(self, stateName)
			end

			local results
			if new.onBind then
				results = table.pack(new.onBind(self, ...))
			else
				results = { n = 0 }
			end
			self.Current = new

			self.StateChanged:Fire(old.Name, stateName)

			local i = 1
			while i <= #queue do
				local array = queue[i]
				queuelessChangeState(self, table.unpack(array, 1, array.n))
				i = i + 1
			end
			stateChangingQueue[self] = nil

			return results
		end
	else
		queue[#queue + 1] = table.pack(stateName, ...)
	end
end

function prototype:AttachTriggers()
	local connsDict = {}
	for k, trigger in pairs(self.Triggers) do
		connsDict[k] = trigger(self)
	end
	return connsDict
end

local protoStates = { Null = stateNull }
protoStates.__index = protoStates
function protoStates:__newindex(k, v)
	assert(type(k) == "string", "This value is not of type 'string'!")
	assert(type(v) == "table", "This value is not of type 'table'!")
	v.Name = v.Name or k

	rawset(self, k, v)
end

local machineClasses = {}

local function handleMachine(class, classAltName)
	class.Name = class.Name or classAltName
	assert(class.States, ("This state machine (%s) does not have a `States` table!"):format(class.Name))
	for name, state in pairs(class.States) do
		state.Name = state.Name or name
	end
	class.__index = class.__index or class
	class.new = class.new or function()
		return setmetatable({}, class)
	end

	machineClasses[class.Name] = class
	setmetatable(class.States, protoStates)
	setmetatable(class, prototype)
end

local function handleChild(module)
	assert(module:IsA("ModuleScript"), ("This child (%s) must be a container!"):format(module.Name))
	local class = require(module)
	handleMachine(class, module.Name)
end

for _, module in ipairs(script:GetChildren()) do
	handleChild(module)
end
script.ChildAdded:Connect(handleChild)

local classesMt = {}
function classesMt:__newindex(name, class)
	assert(type(name) == "string", ("This key (%s) is not of type 'string'!"):format(tostring(name)))
	assert(type(class) == "table", ("This value (%s) is not of type 'table'!"):format(tostring(class)))

	handleMachine(class, name)
end

setmetatable(machineClasses, classesMt)

MachineLib.MachineClasses = machineClasses

return MachineLib
