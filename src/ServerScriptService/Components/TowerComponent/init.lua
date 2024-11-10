local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local TowersInfo = ReplicatedStorage.Info.Towers
local DataModifiers = require(ReplicatedStorage.Utilities.DataModifiers)

local LoadedComponents = {}

for _, component in ipairs(script:GetChildren()) do
	LoadedComponents[component.Name] = require(component)
end

local TowersCache = {}

local Towers = {}
local TowerComponentFabric = {}

local TowerComponent = setmetatable({}, {
	__index = function(t, i)
		for _, module in pairs(LoadedComponents) do
			if (module[i]) then return module[i] end
		end
	end,
})

local DEFAULT_TOWER_PASSIVES = { 'TowerReplication' }

local ATTACK_TICK = 1/20
local PASSIVE_TICK = 1

task.spawn(function() -- seems nested, refactor later
	while task.wait(ATTACK_TICK) do
		for part, tower in pairs(Towers) do
			task.spawn(tower.Attack, tower)
		end
	end
end)

task.spawn(function()
	while task.wait(PASSIVE_TICK) do
		for part, tower in pairs(Towers) do
			for _, passive in pairs(tower.Session.Passives) do
				passive.OnTick()
			end
		end
	end
end)

function TowerComponent:CheckCD()
	if (self.Shooting) then return end
	if (self:GetAttribute('Stunned') > 0) then return end
	if (os.clock() - self.LastShoot) < self:GetValue('Firerate') then return end
	return true
end

function TowerComponent:OnAttack() -- virtual
	
end

function TowerComponent:Attack()
	if (not self:CheckCD()) then return end
	self.Shooting = true

	self:GetTarget()
	if (not self.SelectedTarget) then self.Shooting = false; return end
	
	for _, passive in pairs(self.Session.Passives) do
		passive.OnAttack()
	end
	
	self:OnAttack()
	
	self.SelectedTarget = nil
	
	self.LastShoot = os.clock()
	self.Shooting = false
end

function TowerComponent:DealDamage(damage: number)
	self.Health -= damage
	if (self.Health > 0) then return end
	self:Destroy()
end

function TowerComponent:Destroy()
	while (#self.Session.Passives > 0) do
		local passive = table.remove(self.Session.Passives)
		passive.Stop()
		self:RemovePassive(passive.Name, passive.Level)
	end

	for _, tower in pairs(TowerComponentFabric:GetTowers()) do
		if (tower.Hitbox == self.Hitbox) then continue end
		for _, passive in pairs(tower.Session.Passives) do
			passive.OnTowerRemoved(self)
		end
	end

	Towers[self.Hitbox] = nil
	self.Hitbox:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

function TowerComponent:Upgrade()

	local upgradeInfo = TowersCache[self.Name]

	self.Level += 1
	
	if (not upgradeInfo[self.Level]) then return end

	self:ReplicateField('Level', self.Level)
	DataModifiers:UpdateTable(self, upgradeInfo[self.Level]())

	for _, passive in pairs(self.Passives) do
		self:AppendPassive(passive.Name, passive.Level, passive.Requirements, { self })
	end

	self.Passives = nil

	for _, passive in pairs(self.Session.Passives) do
		passive.OnUpgrade()
	end
end

function TowerComponent:CheckRequirements(requirements) -- use later
	return true
end

function TowerComponent:ReplicateField(fieldName: string, value: number)
	if (not self.Hitbox) then return end
	local hitbox: Part? = self.Hitbox
	hitbox:SetAttribute(fieldName, value)
end

function TowerComponent:SetOwner(owner)
	for _, passive in pairs(owner.Session.Passives) do
		passive.OnTowerAdded(self)
	end
	
	self.OwnerInstance = owner.Instance
end

function TowerComponentFabric:GetTower(partName: string): typeof(TowerComponent)
	for part, tower in pairs(Towers) do
		if (part.Name == partName) then return tower end
	end
end

function TowerComponentFabric:GetTowers(): typeof({TowerComponent})
	return Towers
end

function TowerComponentFabric.new(position: Vector3, name: string)
	if (not TowersInfo:FindFirstChild(name)) then warn(name..' tower doesnt exist') return end

	local clockId = tostring(math.round(math.fmod(os.clock(), 1)*1000))
	local postfix = string.rep('0', (4-string.len(clockId)))

	local part = ReplicatedStorage.Samples.TowerPart:Clone()
	part.Name = clockId..postfix..tostring(math.random(-9999, 9999))
	part.CFrame = CFrame.new(position)

	if (not TowersCache[name]) then
		local info = TowersInfo:FindFirstChild(name)
		if (not info) then return end
		
		TowersCache[name] = require(info)
	end
	
	local data = TowersCache[name][1]()
	
	data.Id = part.Name
	data.Hitbox = part
	data.SelectedTarget = nil
	data.LastShoot = 0
	data.Shooting = false
	data.OwnerInstance = nil

	local self = setmetatable(data, {
		__index = function(t, i)
			return TowerComponent[i]
		end 
	})

	for _, passiveName in pairs(DEFAULT_TOWER_PASSIVES) do
		self:AppendPassive(passiveName, 1, {}, { self })
	end

	for _, ability in pairs(data.Abilities) do
		self:AppendAbility(ability.Name, { self.Id, self })
	end

	for _, passive in pairs(data.Passives) do
		self:AppendPassive(passive.Name, passive.Level, passive.Requirements, { self })
	end

	for _, tower in pairs(TowerComponentFabric:GetTowers()) do
		if (tower.Hitbox == part) then continue end
		for _, passive in pairs(tower.Session.Passives) do
			passive.OnTowerAdded(self)
		end
	end

	data.Passives = nil
	data.Abilities = nil

	self:ReplicateField('Range', self.Range)
	self:ReplicateField('Level', self.Level)
	self:ReplicateField('Name', name)

	part.Parent = workspace.Towers

	Towers[part] = self

	return self
end

return TowerComponentFabric
