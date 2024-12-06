local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Enums = require(ReplicatedStorage.Templates.Enums)
local EnemyComponent = require(ServerScriptService.Components.EnemyComponent)

local TargetModes = {
	[Enums.TargetType.First] = function(self, position: Vector3?, range: number?)
		local enemies = self:GetTargetsInRange(position, range)
		
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

function TargetComponent:GetTargetsInRange(position: Vector3?, range: number?)
	if (not position) then position = self.Hitbox.Position end
	if (not range) then range = self:GetValue('Range') end

	return EnemyComponent:GetEnemiesInRadius(position, range)
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

function TargetComponent:GetTarget(mode: typeof(Enums.TargetType)?, ...)
	if (not mode) then mode = self.TargetType end
	if (not TargetModes[mode]) then return end
	
	TargetModes[mode](self, ...)
end

function TargetComponent:WaitForTarget(delay: number?)
	if (not delay) then delay = 5 end

	local start = os.clock()

	if (self.SelectedTarget and getmetatable(self.SelectedTarget)) then return end
	repeat task.wait(.1); self:GetTarget() until self.SelectedTarget or (not getmetatable(self)) or (os.clock() - start > delay)
end

function TargetComponent:FaceEnemy()
	if not getmetatable(self.SelectedTarget) then return end
	local selectedCFrame = CFrame.new(self.Hitbox.Position, 
		self.SelectedTarget.CFrame.Position * Vector3.new(1, 0, 1) + 
		self.Hitbox.Position * Vector3.new(0, 1, 0))

	task.spawn(function() -- not sure about this one tho
		for i = 1, 3 do
			if ((not getmetatable(self.SelectedTarget)) or (not getmetatable(self))) then continue end
			self.Hitbox.CFrame = self.Hitbox.CFrame:Lerp(selectedCFrame, i/3)
			task.wait(1/20)
		end
	end)
end


return TargetComponent
