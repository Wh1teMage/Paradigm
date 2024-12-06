local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local EnemiesInfo = require(ReplicatedStorage.Info.EnemiesInfo)

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local SignalFunctions = require(ReplicatedStorage.Components.SignalComponent.CustomFunctions)

local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local LoadedComponents = {}

local MoveEnemyEvent = ReplicatedStorage.Events.MoveEnemy :: UnreliableRemoteEvent

local UPDATE_RATE = 1/10

for _, component in ipairs(script:GetChildren()) do
	LoadedComponents[component.Name] = require(component)
end

local Enemies = {}

local EnemyComponent = setmetatable({}, {
	__index = function(t, i)
		for _, module in pairs(LoadedComponents) do
			if (module[i]) then return module[i] end
		end
	end,
})

function EnemyComponent:StartMoving(selectedTrack: number?, startingCFrame: CFrame?, currentStep: number?, direction: number?)

	if (not selectedTrack) then selectedTrack = 1 end

	if (#self.Game.Info.PathPoints < 1) then return end
	if (not self.Game.Info.PathPoints[selectedTrack]) then return end
	
	if (not startingCFrame) then startingCFrame = self.Game.Info.PathPoints[selectedTrack][1] end
	if (not currentStep) then currentStep = 0 end
	if (not direction) then direction = 1 end
	
	task.spawn(function()
		self.CurrentStep = currentStep
		self.CFrame = startingCFrame + Vector3.new(0, .01, 0) -- prevent CFrame bug
		
		local changablePosition = startingCFrame.Position
		
		local start = 1
		local stop = #self.Game.Info.PathPoints[selectedTrack]
		
		if (direction < 0) then start = #self.Game.Info.PathPoints[selectedTrack]; stop = 1 end
		
		for i = start, stop, direction do
			if ((not self.Health) or (self.Health <= 0)) then break end

			local uniformCframe = self.Game.Info.PathPoints[selectedTrack][i]
			self.CurrentStep = i

			--self.CFrame.Position = uniformCframe.Position
			local stepCFrame = self.CFrame
			local overallDistance = (self.CFrame.Position - uniformCframe.Position).Magnitude

			repeat
				
				local distance = (self.CFrame.Position - uniformCframe.Position).Magnitude

				--self.Hitbox.AlignPosition.MaxVelocity = self:GetValue('Speed')
				self.Distance += (self.CFrame.Position - changablePosition).Magnitude
				changablePosition = self.CFrame.Position

				self.CFrame = stepCFrame:Lerp(uniformCframe, 1-(distance-self:GetValue('Speed')*UPDATE_RATE)/overallDistance) --(distance+self:GetValue('Speed')*UPDATE_RATE)/overallDistance
				--self.Hitbox.CFrame = self.CFrame

				--print(overallDistance, distance, self:GetValue('Speed')*UPDATE_RATE, 1-(distance-self:GetValue('Speed')*UPDATE_RATE)/overallDistance)

				task.spawn(self.Attack, self)

				MoveEnemyEvent:FireAllClients(SignalFunctions.EncodeEnemyMovement(.2, 1, 65))
				
				--[[
				SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.ReplicateEnemyMovement, 
					Vector2.new(self.CFrame.X, self.CFrame.Z), Vector2.new(self.CFrame.LookVector.X, self.CFrame.LookVector.Z)
				)
				]]
				

				--SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.DestroyEnemy, self.Id, 
				--	Vector2.new(self.CFrame.X, self.CFrame.Z), Vector2.new(self.CFrame.LookVector.X, self.CFrame.LookVector.Z))

				task.wait(UPDATE_RATE) -- 1/self:GetValue('Speed')

				--task.wait(1/(10*self.Speed))
				
				if ((not self.Health) or (self.Health <= 0)) then break end
				
			until (distance < .5)
			
		end
		
		if ((not self.Health) or (self.Health <= 0)) then return end
		
		local healthDelta = self.Game.Info.Health - self.Health
		
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
	while (#self.Session.Passives > 0) do
		local passive = table.remove(self.Session.Passives)
		passive.Stop()
		self:RemovePassive(passive.Name, passive.Level)
	end

	SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.DestroyEnemy, self.Id, self.Name)

	Enemies[self.Id] = nil
	--self.Hitbox:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

function EnemyComponent:CheckRequirements(requirements) -- use later
	return true
end

function EnemyComponent:ReplicateField(fieldName: string, value: number)
	if (not self.CFrame) then return end
	--local hitbox: Part? = self.Hitbox
	--hitbox:SetAttribute(fieldName, value)
end

function EnemyComponent:CheckCD()
	if (not self.CanAttack) then return end
	if (self.Shooting) then return end
	if (self:GetAttribute('Stunned') > 0) then return end
	if (os.clock() - self.LastShoot) < self:GetValue('Firerate') then return end
	return true
end

function EnemyComponent:OnAttack()
	
end

function EnemyComponent:Attack()
	if (not self:CheckCD()) then return end
	self.Shooting = true

	for _, passive in pairs(self.Session.Passives) do
		passive.OnAttack()
	end
	
	self:OnAttack()
		
	self.LastShoot = os.clock()
	self.Shooting = false
end

function EnemyComponent:SetCurrentGame(match)
	self.Game = match
end

local EnemyComponentFabric = {}

function EnemyComponentFabric.new(name: string): typeof(EnemyComponent)
	if (not EnemiesInfo[name]) then warn(name..' enemy doesnt exist') return end

	local clockId = tostring(math.round(math.fmod(os.clock(), 1)*1000))
	local postfix = string.rep('0', (4-string.len(clockId)))

	local id = clockId..postfix..tostring(math.random(1000, 9999))

	--local part = ReplicatedStorage.Samples.EnemyPart:Clone()
	--part.Name = 
	--part.Parent = workspace.Enemies

	local data = EnemiesInfo[name]()

	data.Id = id
	--data.Hitbox = part
	data.Shooting = false
	data.LastShoot = 0
	
	local self = setmetatable(data, {__index = EnemyComponent})

	for _, passive in pairs(data.Abilities) do
		self:AppendAbility(passive.Name, { self.Id, self })
	end

	for _, passive in pairs(data.Passives) do
		self:AppendPassive(passive.Name, passive.Level, passive.Requirements, { self })
	end
	
	SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.ReplicateEnemy, id, name)
	--SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.DestroyEnemy, self.Id, self.Name)

	--self:ReplicateField('Name', name)

	data.Passives = nil
	data.Abilities = nil

	Enemies[id] = self
	
	return self
end

function EnemyComponentFabric:GetAll()
	return Enemies
end

function EnemyComponentFabric:GetEnemiesInRadius(position: Vector3, radius: number)
	local enemies = {}
	
	for _, enemy in pairs(self:GetAll()) do
		local cframe = enemy.CFrame
		if (not cframe) then continue end

		local distance = (position - cframe.Position).Magnitude
		if (distance <= radius) then
			table.insert(enemies, enemy)
		end
	end
	
	return enemies
end

return EnemyComponentFabric
