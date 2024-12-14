local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Enums = require(ReplicatedStorage.Templates.Enums)
local EnemyComponent = require(ServerScriptService.Components.EnemyComponent)

local TargetModes = {
	[Enums.TargetType.First] = function(self, position: Vector3?, range: number?)
		
		local enemies = self.EnemiesInRange

		local selectedPackage;
		local selectedValue = 0

		self.SelectedTarget = nil

		for _, target in pairs(enemies) do -- iter from start to end
			if (not target.EnemyCount) then continue end
			if (target.EnemyCount < 1) then continue end
			if (target.Distance < selectedValue) then continue end
			selectedValue = target.Distance
			selectedPackage = EnemyComponent:GetPackage(target.Id)
			break
		end
		
		--print(self.Id, selectedPackage)
		--print(#self.EnemiesInRange)
		--if (selectedPackage) then
			--print(selectedPackage.Id)
		--end
		
		if selectedPackage then 
			for _, enemy in pairs(selectedPackage.Enemies) do 
				if (not enemy.Id) then continue end
				--enemy.CFrame = selectedPackage.CFrame
				self.SelectedTarget = enemy
				break 
			end
		end

		--[[
		if (self.SelectedTarget) then
			local distance = (self.Hitbox.Position - self.SelectedTarget.CFrame.Position).Magnitude
			if (distance > self:GetValue('Range')) then  end
		end
		]]

		--if (self.SelectedTarget) then print(self.SelectedTarget.Id) end

		--print(self.SelectedTarget.Id)

		--print(self.SelectedTarget.Id, self.Id)

		--print(self.SelectedTarget.Id, self.Id, selectedPackage.Id)
		
		enemies = nil
		
	end,
}

local TargetComponent = {}

function TargetComponent:GetTargetsInRange(position: Vector3?, range: number?)
	if (not position) then position = self.Hitbox.Position end
	if (not range) then range = self:GetValue('Range') end

	return EnemyComponent:GetPackagesInRadius(position, range)
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
--[[
function TargetComponent:DealTargetDamage(damage: number)
	local hasDied = self.SelectedTarget:TakeDamage(damage)
	if (not hasDied) then return end
	local owner = PlayerComponent:GetPlayer(self.OwnerInstance)
	if (not owner) then return end

	owner:AddAttribute('Cash', 1)
	owner = nil
end
]]
function TargetComponent:WaitForTarget(delay: number?)
	if (not delay) then delay = 1 end

	local start = os.clock()

	if (self.SelectedTarget and getmetatable(self.SelectedTarget)) then return end

	self:GetTarget()

	while (not self.SelectedTarget) and (os.clock() - start < delay) do
		task.wait(.1)
		self:GetTarget()
	end
	--repeat task.wait(.1); self:GetTarget(); until self.SelectedTarget or (not getmetatable(self)) 
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
