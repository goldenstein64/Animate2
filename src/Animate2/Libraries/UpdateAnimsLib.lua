local UpdateAnimsLib = {}

local Animate2 = script.Parent.Parent
	local EMOTE_NAMES = require(Animate2.EMOTE_NAMES)

local function resetTrackList(self, name)
	assert(name ~= nil, "'name' has to be non-nil!")
	
	local trackList = self.TrackLists[name]
	
	if trackList then
		for i = 1, #trackList.Tracks do
			trackList.Tracks[i].Track:Destroy()
			trackList.Tracks[i] = nil
		end
	else
		trackList = {
			Tracks = {},
			TotalWeight = 0
		}
		self.TrackLists[name] = trackList
	end
	
	return trackList
end

local function updateConfigSetInstance(self, fileList)
	local trackList = resetTrackList(self, fileList.Name)
	
	local index = 1
	for _, anim in ipairs(fileList:GetChildren()) do
		if anim:IsA("Animation") then
			
			local track = self.Humanoid:LoadAnimation(anim)
			track.Name = fileList.Name
			
			local emoteLooped = EMOTE_NAMES[fileList.Name]
			if emoteLooped ~= nil then
				track.Looped = emoteLooped
			end
			
			local weightValue = anim:FindFirstChild("Weight")
			local weight = weightValue and weightValue.Value > 0 and weightValue.Value or 1
			
			trackList.Tracks[index] = {
					Track = track,
					Weight = weight
			}
			trackList.TotalWeight = trackList.TotalWeight + weight
			index = index + 1
		end
	end
	
	return trackList
end

local function updateConfigSetTable(self, fileList)
	local trackList = resetTrackList(self, fileList.Name)
	
	for i, dict in ipairs(fileList) do
		local anim = Instance.new("Animation")
		anim.AnimationId = dict.Id
		
		local track = self.Humanoid:LoadAnimation(anim)
		track.Name = fileList.Name
		
		local emoteLooped = EMOTE_NAMES[fileList.Name]
		if emoteLooped ~= nil then
			track.Looped = emoteLooped
		end
		
		trackList.Tracks[i] = {
			Track = track,
			Weight = dict.Weight or 1
		}
		trackList.TotalWeight = trackList.TotalWeight + (dict.Weight or 1)
	end
	
	return trackList
end

function UpdateAnimsLib:UpdateConfigSet(fileList)
	local type_fileList = typeof(fileList)
	
	local trackList
	if type_fileList == "Instance" then
		trackList = updateConfigSetInstance(self, fileList)
	elseif type_fileList == "table" then
		trackList = updateConfigSetTable(self, fileList)
	else
		error("An Instance or table has to be provided to this method!")
	end
	
	assert(trackList.TotalWeight >= 1, 
		"track lists need to have a total weight that is 1 or greater!")
	
	return trackList
end


function UpdateAnimsLib:UpdateConfig(config)
	coroutine.wrap(function()
		assert(typeof(config) == "Instance" or type(config) == "nil", 
			"Only an Instance can be provided to this method!")
		
		self:WaitForAttached("Humanoid")
		
		if config then
			self.Config = config
		elseif self.Config then
			config = self.Config
		end
		
		if config then
			for name, fileList in pairs(self.AnimData) do
				local fileInstance = config:FindFirstChild(name)
				if fileInstance and #fileInstance:GetChildren() > 0 then
					self:UpdateConfigSet(fileInstance)
				else
					self:UpdateConfigSet(fileList)
				end
					
			end
		else
			for name, fileList in pairs(self.AnimData) do
				self:UpdateConfigSet(fileList)
			end
		end
	end)()
end

return UpdateAnimsLib
