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
local MovingEnemies = {}

task.spawn(function()

	local package = {}

	while task.wait(UPDATE_RATE) do

		table.clear(package)

		--print(#MovingEnemies)

		for _, data in pairs(MovingEnemies) do
	
			local trackId = data[1]
			local direction = data[2]
			local enemy = data[3]

			local track = enemy.Game.Info.Paths[trackId]
			local length = track:GetPathLength()

			enemy.CurrentStep += (enemy:GetValue('Speed')*UPDATE_RATE)/length * direction
			enemy.CFrame = track:CalculateUniformCFrame(enemy.CurrentStep)
			enemy.Distance = enemy.CurrentStep * length

			table.insert(package, {pathPoint = enemy.CurrentStep*2^12, path = trackId, enemyId = enemy.Id})

			if (enemy.CurrentStep >= 1) then enemy:CompletedPath(); continue end
			if ((not enemy.Health) or (enemy.Health <= 0)) then enemy:Destroy() end

		end

		MoveEnemyEvent:FireAllClients(SignalFunctions.EncodeEnemyMovement(package))

	end

end)

local EnemyComponent = setmetatable({}, {
	__index = function(t, i)
		for _, module in pairs(LoadedComponents) do
			if (module[i]) then return module[i] end
		end
	end,
})

function EnemyComponent:StartMoving(selectedTrack: number?, startingPoint: number?, direction: number?)
	if (not selectedTrack) then selectedTrack = 1 end

	if (#self.Game.Info.Paths < 1) then return end
	if (not self.Game.Info.Paths[selectedTrack]) then return end
	
	if (not startingPoint) then startingPoint = 0 end
	if (not direction) then direction = 1 end

	self.CurrentStep = startingPoint

	MovingEnemies[self.Id] = { selectedTrack, direction, self }
end

function EnemyComponent:TakeDamage(damage: number)
	self.Health -= damage
	if (self.Health > 0) then return end
	self:Destroy()

	return true
end

function EnemyComponent:CompletedPath()
	if ((not self.Health) or (self.Health <= 0)) then return end
	local healthDelta = self.Game.Info.Health - self.Health

	self:Destroy()
	SignalComponent:GetSignal('ManageGameBindable', true):Fire('ChangeHealth', healthDelta)
end

function EnemyComponent:Destroy()
	while (#self.Session.Passives > 0) do
		local passive = table.remove(self.Session.Passives)
		passive.Stop()
		self:RemovePassive(passive.Name, passive.Level)
	end

	SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.DestroyEnemy, self.Id)

	--print('enemy killed')

	Enemies[self.Id] = nil
	MovingEnemies[self.Id] = nil
	--self.Hitbox:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

function EnemyComponent:CheckRequirements(requirements) -- use later
	return true
end

function EnemyComponent:ReplicateField(fieldName: string, value: number)
	if (not self.CFrame) then return end
	SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.ReplicateAttributes, self.Id, fieldName, value)
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

	--local clockId = tostring(math.round(math.fmod(os.clock(), 1)*1000))
	--local postfix = string.rep('0', (4-string.len(clockId)))

	local id = 1

	for i = 1, 2^16 do
		if (not Enemies[i]) then id = i; break end
	end

	--local part = ReplicatedStorage.Samples.EnemyPart:Clone()
	--part.Name = 
	--part.Parent = workspace.Enemies

	local data = EnemiesInfo[name]()

	data.Id = id
	--data.Hitbox = part
	data.CFrame = CFrame.new(10000, 10000, 10000)
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

	self:ReplicateField('Name', name)

	data.Passives = nil
	data.Abilities = nil

	Enemies[id] = self
	
	return self
end

function EnemyComponentFabric:GetAll()
	return Enemies
end

function EnemyComponentFabric:ReplicateAliveEnemiesForPlayer(player: Player)
	for id, enemy in pairs(EnemyComponentFabric:GetAll()) do
		SignalComponent:GetSignal('ManageEnemies'):Fire(PathConfig.Scope.ReplicateEnemy, player, id, enemy.Name)
	end
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
