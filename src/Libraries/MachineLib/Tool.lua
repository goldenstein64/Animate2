local RunService = game:GetService("RunService")

local Tool = {
	AnimScope = { "toolnone", "toolslash", "toollunge" },
}

local function revertNone(self)
	local newId = newproxy()
	self.Id = newId
	coroutine.wrap(function()
		local i = 0
		while i < 0.3 do
			i = i + RunService.RenderStepped:Wait()
		end

		if newId == self.Id then
			self:ChangeState("None")
		end
	end)()
end

local States = {}
Tool.States = States

States.None = {
	onBind = function(self, tool)
		if tool then
			self.CurrentTool = tool
			self.ToolConn = tool.ChildAdded:Connect(function(child)
				if child.Name == "toolanim" and child:IsA("ValueBase") then
					self:ChangeState(child.Value)
					RunService.RenderStepped:Wait()
					child:Destroy()
				end
			end)
		end
		self.Thread:Play("toolnone", 0.1, true)
	end,
}

States.Slash = {
	onBind = function(self)
		self.Thread:Play("toolslash", 0)
		revertNone(self)
	end,
}

States.Lunge = {
	onBind = function(self)
		local Main = self.Controller.Machines.Main
		if Main.Current ~= Main.States.Seated then
			self.Thread:Play("toollunge", 0.1)
			revertNone(self)
		end
	end,
}

States.Null = {
	onBind = function(self)
		if self.ToolConn then
			self.ToolConn:Disconnect()
			self.ToolConn = nil
		end
		self.CurrentTool = nil
		self.Id = nil
		self.Thread:Stop()
	end,
}

return Tool
