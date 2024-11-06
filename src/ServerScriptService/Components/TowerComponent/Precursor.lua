local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local tower = require(script.Parent)

return function(position: Vector3)
	local self = tower.new(position, 'Precursor')
	
	function self:OnAttack()
		if (not getmetatable(self.SelectedTarget)) then return end -- extra check

		for i = 1, self.BurstCount do
			self:GetTarget()

			repeat task.wait(.1); self:GetTarget() until self.SelectedTarget
			if (not getmetatable(self.SelectedTarget)) then return end
			
			self.SelectedTarget:DealDamage(self.Damage)
			if (not getmetatable(self.SelectedTarget)) then return end

			local selectedCFrame = CFrame.new(self.Hitbox.Position, self.SelectedTarget.Hitbox.Position * Vector3.new(1, 0, 1) + self.Hitbox.Position * Vector3.new(0, 1, 0))
			self.Hitbox.CFrame = selectedCFrame

			SignalComponent:GetSignal('ManageEffects'):FireAllClients(
				PathConfig.Scope.ReplicateEffect, 
				PathConfig.Effects.PrecursorTestEffect, 
				self.SelectedTarget.Hitbox.Position,
				self.Hitbox.Name
			)

			task.wait(self.BurstCD)
		end

		--[[
		self.SelectedTarget:DealDamage(self.Damage)
		--print(self.SelectedTarget)
		local selectedCFrame = CFrame.new(self.Hitbox.Position, self.SelectedTarget.Hitbox.Position * Vector3.new(1, 0, 1) + self.Hitbox.Position * Vector3.new(0, 1, 0))
		self.Hitbox.CFrame = selectedCFrame
		]]



	end
	
	return self
end
