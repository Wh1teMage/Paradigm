local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local AttackPatterns = require(ServerScriptService.Components.Static.TowerAttackPatterns)

local tower = require(ServerScriptService.Components.TowerComponent)
local PlayerComponent = require(ServerScriptService.Components.PlayerComponent)

return function(position: Vector3, callback)
	local self = tower.new(position, 'Mine', callback)
	if (not self) then return end 

	local test = function()

		return AttackPatterns.Single(self, function()
			
			local damageAmount = self:GetValue('Damage')
			local moneyGain = math.min(self.SelectedTarget.Health, damageAmount)
	
			self.SelectedTarget:TakeDamage(damageAmount)

            self:Destroy()

			local owner = PlayerComponent:GetPlayer(self.OwnerInstance)
			if (not owner) then return end

			owner:AddExp(moneyGain)
			owner:AddAttribute('Cash', moneyGain)
            owner:AddAttribute('TowerAmount', -1)
		end)
		
	end

	function self:OnAttack()
		if (not getmetatable(self.SelectedTarget)) then return end -- extra check

		test()
	end
	
	return self
end
