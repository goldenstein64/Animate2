local Animate2 = script.Parent.Parent.Parent
	local TrackThread = require(Animate2.TrackThread)
	local EMOTE_NAMES = require(Animate2.EMOTE_NAMES)

local Main = {
	AnimScope = {
		"idle", "walk", "run", "jump", "fall", "climb", "sit", "swim", "swimidle",
		"wave", "point", "dance1", "dance2", "dance3", "laugh", "cheer"
	}
}


local EMOTE_NOT_LOOPED = {}
for name, value in pairs(EMOTE_NAMES) do
	EMOTE_NOT_LOOPED[name] = value == false or nil
end

local function getMoveSpeed(self, speed)
	local humanoid = self.Controller.Humanoid
	
	local rigType = humanoid.RigType
	local rigScale = rigType == Enum.HumanoidRigType.R15 and 16
		or rigType == Enum.HumanoidRigType.R6 and 14.5
	
	if rigType == Enum.HumanoidRigType.R15 then
		local baseHipHeight = 2
		local dampener = self.Controller.ScaleDampeningPercent
		
		local heightScale = self:GetHeightScale()
		--[[
		if humanoid.AutomaticScalingEnabled then
			local actualHipHeight = humanoid.HipHeight
			
			if dampener then
				heightScale = 1 + (actualHipHeight - baseHipHeight) 
					* dampener.Value / baseHipHeight
			else
				heightScale = actualHipHeight / baseHipHeight
			end
		end
		heightScale = 1.25 / heightScale
		--]]	
		
		speed = speed * heightScale
	end
	
	speed = speed / rigScale
	
	return speed,
		math.clamp(2 - 3*speed, 1e-4, 1), -- weightWalk
		math.clamp(3*speed - 1, 1e-4, 1) -- weightRun
end

function Main.new(trackLists)
	local self = {
		CachedSpeed = 0,
		JumpDuration = 0
	}
	self.Thread = TrackThread.new(self, trackLists)
	self.RunThread = TrackThread.new(self, trackLists)
	
	return setmetatable(self, Main)
end

function Main:GetHeightScale()
	local humanoid = self.Controller.Humanoid
	
	local baseHipHeight = 2
	local dampener = self.Controller.ScaleDampeningPercent
	
	if humanoid.AutomaticScalingEnabled then
		local actualHipHeight = humanoid.HipHeight
		
		if dampener then
			return 1.25 / (1 + (actualHipHeight - baseHipHeight) 
				* dampener.Value / baseHipHeight)
		else
			return 1.25 * baseHipHeight / actualHipHeight
		end
	else
		return 1.25
	end	
end

local States = {}
Main.States = States

States.Standing = {
	AllowEmotes = true,
	
	onBind = function(self, checkSpeed)
		local speed = checkSpeed and self.CachedSpeed
		if speed and speed > 0.75 then
			self:ChangeState("Walking")
		else
			self.Thread:Play("idle", 0.2, true)
		end
	end,
	
	onSpeedChanged = function(self, speed)
		if speed > 0.75 then
			self:ChangeState("Walking")
		end
	end
}

States.Walking = {
	onBind = function(self)
		local rawSpeed = self.CachedSpeed
		local speed, weightWalk, weightRun = getMoveSpeed(self, rawSpeed)
		self.Thread:Play("walk", 0.2, true)
		self.Thread:AdjustWeight(weightWalk)
		self.Thread:AdjustSpeed(speed)
		
		self.RunThread:Play("run", 0.2, true)
		self.RunThread:AdjustWeight(weightRun)
		self.RunThread:AdjustSpeed(speed)
	end,
	
	onSpeedChanged = function(self, rawSpeed)
		if rawSpeed > 0.75 then
			local speed, weightWalk, weightRun = getMoveSpeed(self, rawSpeed)
			self.Thread:AdjustWeight(weightWalk)
			self.Thread:AdjustSpeed(speed)
			
			self.RunThread:AdjustWeight(weightRun)
			self.RunThread:AdjustSpeed(speed)
		else
			self:ChangeState("Standing")
		end
	end,
	
	onUnbind = function(self)
		self.RunThread:Stop(0.2)
	end
}

States.Jumping = {
	onBind = function(self)
		self.Thread:Play("jump", 0.1, true)
		self.JumpDuration = 0.31
		-- play the jump animation and set the timer thing
	end,
	
	onUpdate = function(self, dt)
		self.JumpDuration = self.JumpDuration - dt
		if self.JumpDuration <= 0 then
			self:ChangeState("Freefall")
		end
	end,
	
	onUnbind = function(self)
		self.JumpDuration = 0
	end
}

States.Freefall = {
	onBind = function(self)
		self.Thread:Play("fall", 0.2, true)
	end
}

States.Seated = {
	onBind = function(self)
		self.Thread:Play("sit", 0.5, true)
	end
}

States.Climbing = {
	onBind = function(self)
		local speed = self.CachedSpeed
		local rigType = self.Controller.Humanoid.RigType
		
		local scale
		if rigType == Enum.HumanoidRigType.R15 then
			scale = 5.0
		elseif rigType == Enum.HumanoidRigType.R6 then
			scale = 12.0
		end
		
		self.Thread:Play("climb", 0.1, true)
		self.Thread:AdjustSpeed(speed / scale)
	end,
	
	onSpeedChanged = function(self, speed)
		local rigType = self.Controller.Humanoid.RigType
		
		local scale
		if rigType == Enum.HumanoidRigType.R15 then
			scale = 5.0
		elseif rigType == Enum.HumanoidRigType.R6 then
			scale = 12.0
		end
		
		self.Thread:AdjustSpeed(speed / scale)
	end,
}

States.Swimming = {
	onBind = function(self)
		local speed = self.CachedSpeed
		if speed > 1.00 then
			self.Thread:Play("swim", 0.4)
			if self.Controller.Humanoid.RigType == Enum.HumanoidRigType.R15 then
				local scale = 10.0
				self.Thread:AdjustSpeed(speed / scale)
			end
		else
			self.Thread:Play("swimidle", 0.4)
		end
	end,
	
	onSpeedChanged = function(self, speed)
		if speed > 1.00 then
			if self.Thread.Current.Name ~= "swim" then
				self.Thread:Play("swim", 0.4)
			end
			if self.Controller.Humanoid.RigType == Enum.HumanoidRigType.R15 then
				local scale = 10.0
				self.Thread:AdjustSpeed(speed / scale)
			end
		elseif self.Thread.Current.Name ~= "swimidle" then
			self.Thread:Play("swimidle", 0.4)
		end
	end
}

States.Emote = {
	AllowEmotes = true,
	
	onBind = function(self, anim)
		local type_anim = typeof(anim)
		if type_anim == "string" then
			self.Thread:Play(anim, 0.1)
			if EMOTE_NOT_LOOPED[anim] then
				self:OnStoppedState("Standing")
			end
		elseif type_anim == "Instance" and anim:IsA("Animation") then
			local track = self.Controller.Humanoid:LoadAnimation(anim)
			self.Thread:PlayTrack(track, 0.1)
			self.Thread:OnStoppedState("Standing")
		else
			error(("This type (%s) of emote is not supported!"):format(type_anim))
		end
	end,
	
	onSpeedChanged = function(self, speed)
		if speed > 0.75 then
			self:ChangeState("Walking")
		end
	end
}

local statesDict = {
	[Enum.HumanoidStateType.Climbing] = "Climbing",
	[Enum.HumanoidStateType.Swimming] = "Swimming",
	[Enum.HumanoidStateType.Seated] = "Seated",
	[Enum.HumanoidStateType.Jumping] = "Jumping",
	[Enum.HumanoidStateType.Freefall] = "Freefall",
	
	[Enum.HumanoidStateType.Running] = "Running",
	[Enum.HumanoidStateType.RunningNoPhysics] = "Running",
	[Enum.HumanoidStateType.StrafingNoPhysics] = "Running",
	[Enum.HumanoidStateType.GettingUp] = "Running",
	[Enum.HumanoidStateType.Landed] = "Running",
	
	[Enum.HumanoidStateType.Ragdoll] = "Null",
	[Enum.HumanoidStateType.PlatformStanding] = "Null",
	[Enum.HumanoidStateType.Flying] = "Null",
	[Enum.HumanoidStateType.FallingDown] = "Null",
	[Enum.HumanoidStateType.None] = "Null",
	[Enum.HumanoidStateType.Physics] = "Null",
	[Enum.HumanoidStateType.Dead] = "Null"
}
local function humanoidStateChanged(self, rawOld, rawState)
	local old = assert(statesDict[rawOld], ("State (%s) has not been registered!"):format(rawOld.Name))
	local state = assert(statesDict[rawState], ("State (%s) has not been registered!"):format(rawState.Name))
	if old ~= state then
		if state == "Running" then
			if self.CachedSpeed and self.CachedSpeed > 0.75 then
				self:ChangeState("Walking")
			elseif self.Current ~= Main.States.Emote then
				self:ChangeState("Standing")
			end
		elseif state == "Freefall" then
			if self.JumpDuration <= 0 then
				self:ChangeState("Freefall")
			end
		else
			self:ChangeState(state)
		end
	end
end

local function onSpeedChanged(self, speed)
	self.CachedSpeed = speed
	if self.Current.onSpeedChanged then
		self.Current.onSpeedChanged(self, speed)
	end
end

Main.Triggers = {
	default = function(self)
		local humanoid = self.Controller:WaitForAttached("Humanoid")
		
		local conns = {}
		
		conns.StateChanged = humanoid.StateChanged:Connect(function(rawOld, rawState)
			humanoidStateChanged(self, rawOld, rawState)
		end)
		
		for _, name in ipairs{"Running", "Climbing", "Swimming"} do
			conns[name] = humanoid[name]:Connect(function(speed)
				onSpeedChanged(self, speed)
			end)
		end
		
		return function()
			for _, conn in pairs(conns) do
				conn:Disconnect()
			end
		end
	end
}

return Main
