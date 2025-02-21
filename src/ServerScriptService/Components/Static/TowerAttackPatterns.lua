local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local EnemyComponentFolder = ServerScriptService.Enemies

local Patterns = {}

Patterns['Burst'] = function(component, callback: () -> nil)

	--print(component.SelectedTarget)

	for i = 1, component.BurstCount do
		if (not getmetatable(component)) then break end

		task.wait(component.BurstCD/component:GetAmplifier('Firerate'))
		if (not getmetatable(component)) then break end

		component:WaitForTarget()
		if ((not getmetatable(component.SelectedTarget)) or (not getmetatable(component))) then 
			component.SelectedTarget = nil
			continue 
		end

		component:FaceEnemy()
		callback()

		if (i%10 == 0) then component.SelectedTarget = nil end
		--component.SelectedTarget = nil

		if (not getmetatable(component)) then break end
	end


end

Patterns['Single'] = function(component, callback: () -> nil)

	--print(component.SelectedTarget)

	if (not getmetatable(component)) then return end

	component:WaitForTarget()
	if ((not getmetatable(component.SelectedTarget)) or (not getmetatable(component))) then return end

	component:FaceEnemy()
	callback()

	component.SelectedTarget = nil

	if (not getmetatable(component)) then return end

end

Patterns['Spawn'] = function(component, enemyName, towerName)

	task.spawn(function()
		while not component.Game do task.wait(.1) end

		local enemy = require(EnemyComponentFolder:FindFirstChild(enemyName))() -- not sure if we need cache here
		--enemy.IsTower = true
		enemy:SetCurrentGame(component.Game)
		enemy:StartMoving(1, 1, -1)
	
		local tower = require(ServerScriptService.Towers:FindFirstChild(towerName))(enemy.CFrame.Position, function() return true end)
		tower:SetCurrentGame(component.Game)

		tower.LinkedEnemy = enemy
	
		while tower.Id and enemy.Id do
			tower.Hitbox.CFrame = enemy.CFrame
			task.wait(.1)
		end
	
		if (enemy.Id) then enemy:Destroy() end
		if (tower.Id) then tower:Destroy() end

	end)

end



return Patterns