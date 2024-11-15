local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local TowersComponent = require(Components.TowerComponent)
local passive = require(script.Parent)

return function()
	local self = passive.new()
	
	local component;
	
	function self.OnAttack()
		--print('Attack', component.Damage)
		--component.Damage += 1
	end

	function self.Start()

		for _, tower in pairs(TowersComponent:GetTowers()) do
			if (tower.Hitbox == component.Hitbox) then continue end
			if (tower.Name == component.Name) then
				component.Damage += 10
				component.Firerate /= 1.5
				component.BurstCD /= 1.5
				component.BurstCount *= 1.5
				tower:Destroy()
			end
		end
		
		--print('Placed')
	end
	
	function self.TransferData(args: {any})
		component = args[1]
	end
	
	return self
end
