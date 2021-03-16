--[[
	Author: goldenstein64
	A module meant to simulate a Roblox event's semantics.
--]]

local RunService = game:GetService("RunService")

local Connection = {}
Connection.__index = Connection

function Connection.new(listeners, key)
	local self = {
		Connected = true,
		Listeners = listeners,
		Key = key,
	}

	return setmetatable(self, Connection)
end

function Connection:Disconnect()
	self.Connected = false
	self.Listeners[self.Key] = nil
end

local Event = {}
Event.__index = Event

function Event.new()
	local self = {
		Listeners = {},
		Waiting = {},
	}

	return setmetatable(self, Event)
end

function Event:Fire(...)
	for _, fn in pairs(self.Listeners) do
		coroutine.wrap(fn)(...)
	end

	for _, thread in pairs(self.Waiting) do
		coroutine.resume(thread, ...)
	end
	self.Waiting = {}
end

function Event:Connect(fn)
	local key = newproxy()
	self.Listeners[key] = fn
	return Connection.new(self.Listeners, key)
end

function Event:Wait(timeout)
	local key = newproxy()
	local thread = coroutine.running()
	self.Waiting[key] = thread

	if timeout then
		coroutine.wrap(function()
			local i = 0
			while i < timeout do
				i = i + RunService.Heartbeat:Wait()
			end
			self.Waiting[key] = nil
			coroutine.resume(thread, error, i)
		end)()
	end

	return coroutine.yield()
end

return Event
