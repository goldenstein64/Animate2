local AnimNames = {
	[Enum.HumanoidRigType.R15] = {
		idle = {
			{ Id = "rbxassetid://507766666", Weight = 1 },
			{ Id = "rbxassetid://507766951", Weight = 1 },
			{ Id = "rbxassetid://507766388", Weight = 9 },
		},
		walk = { { Id = "rbxassetid://507777826", Weight = 10 } },

		run = { { Id = "rbxassetid://507767714", Weight = 10 } },

		swim = { { Id = "rbxassetid://507784897", Weight = 10 } },

		swimidle = { { Id = "rbxassetid://507785072", Weight = 10 } },

		jump = { { Id = "rbxassetid://507765000", Weight = 10 } },

		fall = { { Id = "rbxassetid://507767968", Weight = 10 } },

		climb = { { Id = "rbxassetid://507765644", Weight = 10 } },

		sit = { { Id = "rbxassetid://2506281703", Weight = 10 } },

		toolnone = { { Id = "rbxassetid://507768375", Weight = 10 } },

		toolslash = { { Id = "rbxassetid://522635514", Weight = 10 } },

		toollunge = { { Id = "rbxassetid://522638767", Weight = 10 } },

		wave = { { Id = "rbxassetid://507770239", Weight = 10 } },

		point = { { Id = "rbxassetid://507770453", Weight = 10 } },

		dance1 = {
			{ Id = "rbxassetid://507771019", Weight = 10 },
			{ Id = "rbxassetid://507771955", Weight = 10 },
			{ Id = "rbxassetid://507772104", Weight = 10 } 
		},
		dance2 = {
			{ Id = "rbxassetid://507776043", Weight = 10 },
			{ Id = "rbxassetid://507776720", Weight = 10 },
			{ Id = "rbxassetid://507776879", Weight = 10 } 
		},
		dance3 = {
			{ Id = "rbxassetid://507777268", Weight = 10 },
			{ Id = "rbxassetid://507777451", Weight = 10 },
			{ Id = "rbxassetid://507777623", Weight = 10 } 
		},
		laugh = { { Id = "rbxassetid://507770818", Weight = 10 } },

		cheer = { { Id = "rbxassetid://507770677", Weight = 10 } },
	},

	[Enum.HumanoidRigType.R6] = {
		idle = {
			{ Id = "rbxassetid://180435571", Weight = 9 },
			{ Id = "rbxassetid://180435792", Weight = 1 },
		},
		walk = { { Id = "rbxassetid://180426354", Weight = 10 } },

		run = { { Id = "rbxassetid://180426354", Weight = 10 } },

		jump = { { Id = "rbxassetid://125750702", Weight = 10 } },

		fall = { { Id = "rbxassetid://180436148", Weight = 10 } },

		climb = { { Id = "rbxassetid://180436334", Weight = 10 } },

		sit = { { Id = "rbxassetid://178130996", Weight = 10 } },

		toolnone = { { Id = "rbxassetid://182393478", Weight = 10 } },

		toolslash = { { Id = "rbxassetid://129967390", Weight = 10 } },

		toollunge = { { Id = "rbxassetid://129967478", Weight = 10 } },

		wave = { { Id = "rbxassetid://128777973", Weight = 10 } },

		point = { { Id = "rbxassetid://128853357", Weight = 10 } },

		swim = { { Id = "rbxassetid://180426354", Weight = 10 } },

		swimidle = { { Id = "rbxassetid://180426354", Weight = 10 } },

		--[
		dance1 = {
			{ Id = "rbxassetid://182435998", Weight = 10 },
			{ Id = "rbxassetid://182491037", Weight = 10 },
			{ Id = "rbxassetid://182491065", Weight = 10 } 
		},
		dance2 = {
			{ Id = "rbxassetid://182436842", Weight = 10 },
			{ Id = "rbxassetid://182491248", Weight = 10 },
			{ Id = "rbxassetid://182491277", Weight = 10 } 
		},
		dance3 = {
			{ Id = "rbxassetid://182436935", Weight = 10 },
			{ Id = "rbxassetid://182491368", Weight = 10 },
			{ Id = "rbxassetid://182491423", Weight = 10 } 
		},
		--]]
		laugh = { { Id = "rbxassetid://129423131", Weight = 10 } },

		cheer = { { Id = "rbxassetid://129423030", Weight = 10 } },
	},
}
local fileListMt = {
	__newindex = function(self, k, v)
		local type_k = type(k)

		if type_k == "number" then
			assert(k <= #self + 1, ("This key (%d) has to be larger than the length plus one!"):format(k))
			assert(type(v) == "table", ("This value (%s) is not of type 'table'!"):format(tostring(v)))

			assert(v.Id, ("The animation id for this item (%d) does not exist!"):format(k))
			v.Weight = type(v.Weight) == "number" and v.Weight or 1
		elseif k ~= "Name" then
			error(("This key (%s) is not of type 'number' and is not \"Name\"!"):format(tostring(k)))
		end

		rawset(self, k, v)
	end,
}
local fileListsMt = {
	__newindex = function(self, k, v)
		assert(type(k) == "string", ("This key (%s) is not of type 'string'!"):format(tostring(k)))
		assert(type(v) == "table", ("This value (%s) is not of type 'table'!"):format(tostring(v)))

		v.Name = v.Name or k
		for i, dict in ipairs(v) do
			assert(dict.Id, ("The animation id for this item (%d) does not exist!"):format(i))
			dict.Weight = type(dict.Weight) == "number" and v.Weight or 1
		end
		setmetatable(v, fileListMt)

		rawset(self, k, v)
	end,
}
for _, fileLists in pairs(AnimNames) do
	setmetatable(fileLists, fileListsMt)
	for name, fileList in pairs(fileLists) do
		fileList.Name = name
		setmetatable(fileList, fileListMt)
	end
end

return {
	Name = "AnimNames",
	AnimNames = AnimNames,
}
