local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local AttackPatterns = require(ServerScriptService.Components.Static.TowerAttackPatterns)

local tower = require(ServerScriptService.Components.TowerComponent)

return function(position: Vector3)
	local self = tower.new(position, 'Precursor')

	local test = function()

		return AttackPatterns.Burst(self, function()

			SignalComponent:GetSignal('ManageEffects'):FireAllClients(
				PathConfig.Scope.ReplicateEffect, 
				PathConfig.Effects.PrecursorTestEffect,
				self.SelectedTarget.CFrame.Position,
				self.Hitbox.Name
			)
	
			self.SelectedTarget:DealDamage(self:GetValue('Damage'))
		end)

	end

	function self:OnAttack()
		if (not getmetatable(self.SelectedTarget)) then return end -- extra check

		test()
	end
	
	return self
end
