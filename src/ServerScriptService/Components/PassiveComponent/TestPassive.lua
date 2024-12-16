local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local TowersComponent = require(Components.TowerComponent)
local PlayerComponent = require(Components.PlayerComponent)
local passive = require(script.Parent)

local EnemyComponentFolder = ServerScriptService.Enemies

return function()
	local self = passive.new()
	
	local component;
	local owner;
	
	function self.OnAttack()
		--print('Attack', component.Damage)
		--component.Damage += 1
	end

	function self.Start()

		for _, tower in pairs(TowersComponent:GetTowers()) do
			if (tower.Hitbox == component.Hitbox) then continue end
			if (tower.Name ~= component.Name) then continue end
			if (tower.OwnerInstance ~= owner.Instance) then continue end

			component.Damage += 10
			component.Firerate /= 1.5
			component.BurstCD /= 1.5
			component.BurstCount *= 1.5

			tower:Destroy()
			--owner:AddAttribute('TowerAmount', -1)
			--task.wait()
		end
		

		task.spawn(function()
			while not component.Game do task.wait(.1) end
			
			for i = 1, 150 do

				task.spawn(function()
					local enemy = require(EnemyComponentFolder:FindFirstChild('TowerWalker'))()
					enemy.IsTower = true
					enemy:SetCurrentGame(component.Game)
					enemy:StartMoving(1, 1, -1)
		
					local tower = require(ServerScriptService.Towers:FindFirstChild('Precursor'))(enemy.CFrame.Position, function() return true end)
					tower:SetCurrentGame(component.Game)

					local tower2 = require(ServerScriptService.Towers:FindFirstChild('Mine'))(enemy.CFrame.Position, function() return true end)
					tower2:SetCurrentGame(component.Game)
		
					while tower.Id and enemy.Id and tower2.Id do
						tower.Hitbox.CFrame = enemy.CFrame
						tower2.Hitbox.CFrame = enemy.CFrame
						task.wait()
					end
		
					if (enemy.Id) then enemy:Destroy() end
					if (tower.Id) then tower:Destroy() end
					if (tower2.Id) then tower2:Destroy() end
				end)

				task.wait()

			end


		end)

		--print('Placed')
	end
	
	function self.TransferData(args: {any})
		component = args[1]
		owner = PlayerComponent:GetPlayer( component.OwnerInstance )
	end
	
	return self
end
