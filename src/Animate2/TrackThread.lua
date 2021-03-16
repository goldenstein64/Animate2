--[[
	Author: goldenstein64
	Has the unique property of only having one animation track per instanced object
--]]

local R = Random.new()

local TrackThread = {}
TrackThread.__index = TrackThread

local function roll(trackList)
	if #trackList.Tracks > 1 then
		local pick = R:NextInteger(1, trackList.TotalWeight)
		
		local index = 1
		while pick > trackList.Tracks[index].Weight do
			pick -= trackList.Tracks[index].Weight
			index += 1
		end
		
		return trackList.Tracks[index].Track
	else
		return trackList.Tracks[1].Track
	end
	
end

function TrackThread.new(machine, trackLists)
	local self = {
		Machine = machine,
		TrackLists = trackLists,
		
		Current = nil,
		LoopHandler = nil,
	}
	
	return setmetatable(self, TrackThread)
end

function TrackThread:ConnectLooped()
	if self.LoopHandler then
		self.LoopHandler:Disconnect()
	end
	
	local track = self.Current
	local trackList = self.TrackLists[track.Name]
	if track and trackList then
		if track.Looped then
			self.LoopHandler = track.DidLoop:Connect(function()
				local newTrack = roll(trackList)
				if newTrack ~= track then
					local speed = track.Speed
					self:PlayTrack(newTrack, 0.1, true)
					self:AdjustSpeed(speed)
				end
			end)
		else
			self.LoopHandler = track.Stopped:Connect(function()
				local newTrack = roll(trackList)
				local speed = track.Speed
				self:PlayTrack(newTrack, 0.1, true)
				self:AdjustSpeed(speed)
			end)
		end
	end
end

function TrackThread:OnStoppedState(stateName)
	if self.LoopHandler then
		self.LoopHandler:Disconnect()
	end
	
	self.LoopHandler = self.Current.Stopped:Connect(function()
		self.Machine:ChangeState(stateName)
	end)
end

function TrackThread:Play(animName, fadeTime, connectLooped)
	local trackList = assert(self.TrackLists[animName], ("This anim name (%s) is not valid!"):format(animName))
	local track = roll(trackList)
	self:PlayTrack(track, fadeTime, connectLooped)
end

function TrackThread:PlayTrack(track, fadeTime, connectLooped)
	self:Stop(fadeTime)
	
	self.Current = track
	track:Play(fadeTime)
	
	local trackList = self.TrackLists[track.Name]
	if connectLooped and trackList then
		self:ConnectLooped()
	end
end

function TrackThread:Stop(fadeTime)
	if self.LoopHandler then
		self.LoopHandler:Disconnect()
		self.LoopHandler = nil
	end
	
	if self.Current then
		if self.Current.IsPlaying then
			self.Current:Stop(fadeTime)
		end
		self.Current = nil
	end
end

function TrackThread:AdjustSpeed(speed)
	self.Current:AdjustSpeed(speed)
end

function TrackThread:AdjustWeight(weight)
	self.Current:AdjustWeight(weight)
end

return TrackThread