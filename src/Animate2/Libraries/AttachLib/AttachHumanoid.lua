local Animate2 = script.Parent.Parent.Parent
	local copyTable = require(Animate2.DeepCopyTable)

local function AttachHumanoid(self, humanoid)
	assert(typeof(humanoid) == "Instance" and humanoid:IsA("Humanoid"), 
		"A Humanoid has to be given to this method!")
	
	self.Humanoid = humanoid
	
	if self.DeepCopyAnimData then
		self.AnimData = {}
		for name, fileList in pairs(self.AnimNames[humanoid.RigType]) do
			self.AnimData[name] = copyTable(self.AnimNames[humanoid.RigType])
		end
	else
		self.AnimData = self.AnimNames[humanoid.RigType]
	end
	local trackLists = {}
	for name in pairs(self.AnimData) do
		trackLists[name] = {
			Tracks = {},
			TotalWeight = 0
		}
	end
	self.TrackLists = trackLists
	
	self:GetAttachedSignal("Humanoid"):Fire(humanoid)
end

return AttachHumanoid
