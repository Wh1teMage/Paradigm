local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local tower = require(script.Parent)

return function(position: Vector3)
	local self = tower.new(position, 'Precursor')
	
	function self:OnAttack()
		if (not getmetatable(self.SelectedTarget)) then return end -- extra check

		self.SelectedTarget:DealDamage(self.Damage)
		--print(self.SelectedTarget)
		local selectedCFrame = CFrame.new(self.Hitbox.Position, self.SelectedTarget.Hitbox.Position)
		self.Hitbox.CFrame = selectedCFrame

		--[[
		SignalComponent:GetSignal('ManageEffects'):FireAllClients(
			PathConfig.Scope.ReplicateEffect, 
			PathConfig.Effects.PrecursorTestEffect, 
			selectedCFrame,
			self.Hitbox.Name
		)
		]]

	end
	
	return self
end
