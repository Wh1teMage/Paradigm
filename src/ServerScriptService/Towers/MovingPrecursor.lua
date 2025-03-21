local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local AttackPatterns = require(ServerScriptService.Components.Static.TowerAttackPatterns)

local tower = require(ServerScriptService.Components.TowerComponent)
local PlayerComponent = require(ServerScriptService.Components.PlayerComponent)

local MovablePackageComponent = require(ServerScriptService.Components.MovablePackageComponent)

return function(position: Vector3, callback)
	local self = tower.new(position, 'MovingPrecursor')
	if (not self) then return end 

	local test = function()

		return AttackPatterns.Burst(self, function()
			
			SignalComponent:GetSignal('ManageEffects'):FireAllClients(
				PathConfig.Scope.ReplicateEffect, 
				PathConfig.Effects.PrecursorTestEffect,
				self.SelectedTarget.CFrame.Position,
				self.Hitbox.Name
			)
			
			local damageAmount = self:GetValue('Damage')
			local moneyGain = math.min(self.SelectedTarget.Health, damageAmount)
	
			self.SelectedTarget:TakeDamage(damageAmount)

			local owner = PlayerComponent:GetPlayer(self.OwnerInstance)
			if (not owner) then return end

			owner:AddExp(moneyGain)
			owner:AddAttribute('Cash', moneyGain)

		end)
		
	end

	function self:OnAttack()
		if (not getmetatable(self.SelectedTarget)) then return end -- extra check

		local package = MovablePackageComponent:GetPackage(self.PackageId)
		if (not package) then return end

		package:AppendBuff('PackageSlowness', 10, {package, 10^6})
		test()
		package:RemoveBuff('PackageSlowness')

	end
	
	return self
end
