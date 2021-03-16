--[[
	Animate2
	Author: goldenstein64
--]]

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Private Functions
local function step(self, dt)
	local blacklist = {}
	for _, machineName in ipairs(self.MachinePriority) do
		local machine = assert(self.Machines[machineName], 
			("There is no machine (%s) for this priority!"):format(machineName))

		if not blacklist[machine.Name] and machine.Current.onUpdate then
			local newBlacklist = machine.Current.onUpdate(machine, dt)
			if newBlacklist then
				for _, v in ipairs(newBlacklist) do
					blacklist[v] = true
				end
			end
		end
	end
end

-- Module
local Animate2 = {
	CopyStateMachines = false
}
Animate2.__index = Animate2

local onNew = {}

-- Libraries
for _, mod in ipairs(script.Libraries:GetChildren()) do
	local lib = require(mod)
	for k, v in pairs(lib) do
		if k == "new" then
			onNew[lib.Name] = v
		elseif k ~= "Name" then
			assert(Animate2[k] == nil, 
				("This method (%s) has already been defined in Animate2!"):format(tostring(k)))
			Animate2[k] = v
		end
	end
end

-- .new
function Animate2.new(humanoid)
	local self = {
		Enabled = true
	}
	
	setmetatable(self, Animate2)
	
	for _, modifier in pairs(onNew) do
		modifier(self)
	end
	
	if humanoid then
		self:AttachHumanoid(humanoid)
	end
	
	return self
end

-- :init
function Animate2:init(config)
	-- connect events
	if self.Humanoid then
		self:AttachMachines()
		self:AttachTriggers()
		self:AttachTool(self.Humanoid.Parent)
		
		if self.Machines.Main and self.Machines.Main.States.Freefall then
			self.Machines.Main:ChangeState("Freefall")
		end
	end
	
	-- configure machines and emote bindable if provided config
	if config then
		local bindable = Instance.new("BindableFunction")
		bindable.Name = "PlayEmote"
		bindable.Parent = config
		
		self:AttachConfig(config)
	end
	
	self:AttachChatted()
	
	return self:update(0.1)
end

function Animate2:update(waitTime)
	self:WaitForAttached("Machines")
	
	local updateThread = self.Connections.UpdateThread
	if not updateThread then
		updateThread = coroutine.create(function(threadWait)
			while true do
				local dt = 0
				while dt < threadWait do
					dt = dt + RunService.RenderStepped:Wait()
				end
				if self.Enabled then
					step(self, dt)
				else
					threadWait = coroutine.yield()
				end
			end
		end)
		self.Connections.UpdateThread = updateThread
	end
	coroutine.resume(updateThread, waitTime)
	
	return updateThread
end

return Animate2
