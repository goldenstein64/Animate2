local function fnWrapper(conn)
	return function()
		conn:Disconnect()
	end
end

local function AttachTool(self, character)
	coroutine.wrap(function()
		
		self:WaitForAttached("Machines")
		
		if self.Connections.ToolAdded then
			self.Connections.ToolAdded()
		end
		self.Connections.ToolAdded = fnWrapper(character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				self.Machines.Tool:ChangeState("None", child)
			end
		end))
		
		if self.Connections.ToolRemoved then
			self.Connections.ToolRemoved()
		end
		self.Connections.ToolRemoved = fnWrapper(character.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") then
				self.Machines.Tool:ChangeState("Null")
			end
		end))
	end)()
end

return AttachTool
