local ReplicatedStorage = game:GetService('ReplicatedStorage')

return {}

--[[
local Effects = ReplicatedStorage.Samples.Effects

return {
	['TakeDamage'] = function(component, args)
		
		local character = component.Instance.Character
		if (not character) then return end
		
		local primary = character.PrimaryPart
		if (not primary) then return end
		
		local effect = Effects.HitEffect:Clone()
		effect.CFrame = CFrame.new(primary.Position)
		effect.Parent = primary

		for i, v in pairs(effect:GetDescendants()) do
			if (not v:IsA('ParticleEmitter')) then continue end
			v:Emit(v:GetAttribute('EmitCount') or 5)
		end

		task.wait(1)

		effect:Destroy()
		
	end,
}
]]
