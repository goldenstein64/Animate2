local function fnWrapper(conn)
	return function()
		conn:Disconnect()
	end
end

local function onAnimConfigChildModified(self, child)
	self.TrackLists[child.Name] = self:UpdateConfigSet(child)
end

local function onConfigModified(self, child)
	if child.Name == "ScaleDampeningPercent" then
		self.ScaleDampeningPercent = child
	elseif child.Name == "PlayEmote" then
		self:AttachBindable(child)
	else
		local childConns
		childConns = {
			children = {},

			Changed = fnWrapper(child.Changed:Connect(function()
				onAnimConfigChildModified(self, child)
			end)),
			DescendantAdded = fnWrapper(child.DescendantAdded:Connect(function(desc)
				childConns.children[desc] = fnWrapper(desc.Changed:Connect(function()
					onAnimConfigChildModified(self, child)
				end))
				onAnimConfigChildModified(self, child)
			end)),
			DescendantRemoving = fnWrapper(child.DescendantRemoving:Connect(function(desc)
				childConns.children[desc] = nil
				onAnimConfigChildModified(self, child)
			end)),
		}
		for _, desc in ipairs(child:GetDescendants()) do
			childConns.children[desc] = fnWrapper(desc.Changed:Connect(function()
				onAnimConfigChildModified(self, child)
			end))
		end

		self.Connections.Config.children[child] = childConns
	end
end

local function AttachConfig(self, config)
	assert(typeof(config) == "Instance", "An Instance has to be provided to this method!")

	self:UpdateConfig(config)

	local lastConns = self.Connections.Config
	if lastConns then
		lastConns.ChildAdded()
		lastConns.ChildRemoved()
		for _, childConns in pairs(lastConns.children) do
			childConns.Changed()
			childConns.DescendantAdded()
			childConns.DescendantRemoving()
			for _, conn in pairs(childConns.children) do
				conn()
			end
		end
	end

	local conns
	conns = {
		children = {},

		ChildAdded = fnWrapper(config.ChildAdded:Connect(function(child)
			onConfigModified(self, child)
		end)),
		ChildRemoved = fnWrapper(config.ChildRemoved:Connect(function(child)
			conns.children[child] = nil
			if child.Name == "ScaleDampeningPercent" then
				self.ScaleDampeningPercent = nil
			elseif child.Name ~= "PlayEmote" then
				self.TrackLists[child.Name] = self:UpdateConfigSet(self.AnimData[child.Name])
			end
		end)),
	}
	self.Connections.Config = conns

	for _, child in ipairs(config:GetChildren()) do
		onConfigModified(self, child)
	end

	self.Config = config

	self:GetAttachedSignal("Config"):Fire(config, conns)
end

return AttachConfig
