local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Enums = require(ReplicatedStorage.Templates.Enums)
local EnemyComponent = require(ServerScriptService.Components.EnemyComponent)

local TargetModes = {
	[Enums.TargetType.First] = function(self)
		local enemies = self:GetTargetsInRange()
		
		local selectedEnemy;
		local selectedValue = 0
		
		for _, target in pairs(enemies) do
			if (target.Distance < selectedValue) then continue end
			selectedValue = target.Distance
			selectedEnemy = target
		end
		
		if selectedEnemy then self.SelectedTarget = selectedEnemy end
		
		table.clear(enemies)
		enemies = nil
	end,
}

local TargetComponent = {}

function TargetComponent:GetTargetsInRange()
	return EnemyComponent:GetEnemiesInRadius(self.Hitbox.Position, self.Range)
	--[[
	for _, enemy in pairs(EnemyComponent:GetAll()) do
		local hitbox = enemy.Hitbox
		if (not hitbox) then continue end
		
		local distance = (self.Hitbox.Position - hitbox.Position).Magnitude
		if (distance <= self.Range) then
			table.insert(targets, enemy)
		end
	end
	
	return targets
	]]
end

function TargetComponent:GetTarget()
	local mode = self.TargetType
	if (not TargetModes[mode]) then return end
	
	TargetModes[mode](self)
end

return TargetComponent
