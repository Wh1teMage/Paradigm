local ReplicatedStorage = game:GetService('ReplicatedStorage')

local BezierPath = require(ReplicatedStorage.Utilities.BezierPath)

local EnemiesInfo = require(ReplicatedStorage.Info.EnemiesInfo)
local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)

local PassiveComponent = require(script.PassiveComponent)

local Enemies = {}

local EnemyComponent = setmetatable({}, {
	__index = function(t, i)
		return PassiveComponent[i]
	end,
})

function EnemyComponent:StartMoving(startingCFrame: CFrame?, currentStep: number?, direction: number?)
	if (#GlobalInfo.PathPoints < 1) then return end
	
	if (not startingCFrame) then startingCFrame = GlobalInfo.PathPoints[1] end
	if (not currentStep) then currentStep = 0 end
	if (not direction) then direction = 1 end
	
	task.spawn(function()
		self.CurrentStep = currentStep
		self.Hitbox.CFrame = startingCFrame + Vector3.new(0, .01, 0) -- prevent CFrame bug
		
		local changablePosition = startingCFrame.Position
		
		local start = 1
		local stop = #GlobalInfo.PathPoints
		
		if (direction < 0) then start = #GlobalInfo.PathPoints; stop = 1 end
		
		for i = start, stop, direction do
			local uniformCframe = GlobalInfo.PathPoints[i]
			self.CurrentStep = i
			
			if ((not self.Health) or (self.Health <= 0)) then break end

			self.Hitbox.AlignPosition.Position = uniformCframe.Position
			self.Hitbox.AlignOrientation.CFrame = uniformCframe.Rotation

			repeat 
				
				self.Hitbox.AlignPosition.MaxVelocity = self.Speed
				self.Distance += (self.Hitbox.Position - changablePosition).Magnitude
				changablePosition = self.Hitbox.Position
				
				task.wait(1/(10*self.Speed))
				
				if ((not self.Health) or (self.Health <= 0)) then break end
				
			until ((self.Hitbox.Position - self.Hitbox.AlignPosition.Position).Magnitude < .1)
		end
		
		if ((not self.Health) or (self.Health <= 0)) then return end
		
		local healthDelta = GlobalInfo.Health - self.Health
		
		self:Destroy()
		
		print('Finished TestPath')
		
		--[[
		
		]]
		
		--onReachingEnd
		
		SignalComponent:GetSignal('ManageGameBindable', true):Fire('ChangeHealth', healthDelta)
	end)
	
end

function EnemyComponent:DealDamage(damage: number)
	self.Health -= damage
	if (self.Health > 0) then return end
	self:Destroy()
end

function EnemyComponent:Destroy()
	Enemies[self.Hitbox] = nil
	self.Hitbox:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

function EnemyComponent:CheckRequirements(requirements) -- use later
	return true
end

local EnemyComponentFabric = {}

function EnemyComponentFabric.new(name: string): typeof(EnemyComponent)
	if (not EnemiesInfo[name]) then warn(name..' enemy doesnt exist') return end

	local clockId = tostring(math.round(math.fmod(os.clock(), 1)*1000))
	local postfix = string.rep('a', (4-string.len(clockId)))

	local part = ReplicatedStorage.Samples.EnemyPart:Clone()
	part.Name = name..clockId..postfix..tostring(math.random(1000, 9999))
	part.Parent = workspace.Enemies

	local data = EnemiesInfo[name]()
	data.Hitbox = part
	
	local self = setmetatable(data, {__index = EnemyComponent})
	
	for _, passive in pairs(data.Passives) do
		self:AppendPassive(passive.Name, passive.Level, passive.Requirements, { self })
	end
	
	Enemies[part] = self
	
	return self
end

function EnemyComponentFabric:GetAll()
	return Enemies
end

function EnemyComponentFabric:GetEnemiesInRadius(position: Vector3, radius: number)
	local enemies = {}
	
	for _, enemy in pairs(self:GetAll()) do
		local hitbox = enemy.Hitbox
		if (not hitbox) then continue end

		local distance = (position - hitbox.Position).Magnitude
		if (distance <= radius) then
			table.insert(enemies, enemy)
		end
	end
	
	return enemies
end

return EnemyComponentFabric
