local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local GetAnimsLib = {
	Name = "GetAnimsLib",
}

function GetAnimsLib:GetAvatarAnimations(player)
	assert(
		typeof(player) == "Instance" and player:IsA("Player") or typeof(player) == "nil",
		"Only a Player can be provided to this method!"
	)

	player = player or localPlayer
	local parent = Instance.new("Folder")

	if self.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		local s, model
		for _ = 1, 3 do
			s, model = pcall(Players.GetCharacterAppearanceAsync, Players, player.UserId)
			if s then
				break
			end
		end

		if s and model then
			for _, child in ipairs(model:GetChildren()) do
				if child.Name == "R15Anim" then
					for _, anim in ipairs(child:GetChildren()) do
						local newAnim = anim:Clone()
						newAnim.Parent = parent
					end
				end
			end
		else
			if not s then
				warn("GetAvatarAnimations could not find an appearance to extract:", model)
			elseif not model then
				warn("No model was returned by :GetCharacterAppearanceAsync!")
			end
			return nil
		end
	else
		warn("GetAvatarAnimations should only be called for humanoids of rig type 'R15'!")
		return nil
	end

	return parent
end

return GetAnimsLib
