local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ServerScriptService = game:GetService('ServerScriptService')

local TowersInfo = ReplicatedStorage.Info.Towers
local DataModifiers = require(ReplicatedStorage.Utilities.DataModifiers)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)
local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)

local EnemyComponent = require(ServerScriptService.Components.EnemyComponent)
--local PackageComponent = require(ServerScriptService.Components.EnemyComponent.PackageComponent)

local LoadedComponents = {}

for _, component in ipairs(script:GetChildren()) do
	if (not component:IsA('ModuleScript')) then continue end
	LoadedComponents[component.Name] = require(component)
end

local towerCount = 0

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

function TowerComponent:Destroy()
	for _, passive in pairs(self.Session.Passives) do
		passive.OnDeath()
	end

	while (#self.Session.Passives > 0) do
		local passive = table.remove(self.Session.Passives)
		passive.Stop()
		self:RemovePassive(passive.Name, passive.Level)
	end

	for _, tower in pairs(TowerComponentFabric:GetTowers()) do
		if (tower.Id == self.Id) then continue end
		for _, passive in pairs(tower.Session.Passives) do
			passive.OnTowerRemoved(self)
		end
	end

	SignalComponent:GetSignal('ManageTowers'):FireAllClients(PathConfig.Scope.SellTower, self.Id)

	--print(self.Session.Passives)

	towerCount -= 1

	Towers[tostring(self.Id)] = nil
	table.clear(self)
	setmetatable(self, nil)
end

function TowerComponent:Upgrade()

	local upgradeInfo = TowersCache[self.Name]

	self.Level += 1
	
	if (not upgradeInfo[self.Level]) then return end

	if (#self.Descriptions > 0) then
		for i = 2, #self.Descriptions do
			self:ReplicateField('Passive'..(i-1), '')
		end
	end

	self:ReplicateField('Level', self.Level)
	DataModifiers:UpdateTable(self, upgradeInfo[self.Level]())

	for _, passive in pairs(self.Passives) do
		self:AppendPassive(passive.Name, passive.Level, passive.Requirements, { self })
	end

	self.Passives = nil

	for _, passive in pairs(self.Session.Passives) do
		passive.OnUpgrade()
	end
	
	self:ReplicateDescriptions()
end

function TowerComponent:ReplicateDescriptions()
	if (#self.Descriptions > 0) then
		self:ReplicateField('Description', table.concat(self.Descriptions[1], '/'))

		for i = 2, #self.Descriptions do
			self:ReplicateField('Passive'..(i-1), table.concat(self.Descriptions[i], '/'))
		end
	end

	self:ReplicateField('SellPrice', self.SellPrice)

	local upgradeInfo = TowersCache[self.Name]
	if (not upgradeInfo[self.Level+1]) then return end

	if (upgradeInfo[self.Level+1]) then
		local nextInfo = upgradeInfo[self.Level+1]()
		self.UpgradePrice = nextInfo.Price
		self:ReplicateField('UpgradePrice', self.UpgradePrice)
		table.clear(nextInfo)
	end
end

function TowerComponent:ReplicateField(fieldName: string, value: any)
	if (not self.CFrame) then return end
	SignalComponent:GetSignal('ManageTowers'):FireAllClients(PathConfig.Scope.ReplicateAttributes, self.Id, fieldName, value)
end

function TowerComponent:ReplicateCreation()
	--print('sent')
	SignalComponent:GetSignal('ManageTowers'):FireAllClients(PathConfig.Scope.PlaceTower, self.PackageId, self.Id, 
		self.Name, self.CFrame.Position, self.Skin)
end

function TowerComponent:SetCurrentGame(match)
	self.Game = match
end

function TowerComponent:SetOwner(owner)
	for _, passive in pairs(owner.Session.Passives) do
		passive.OnTowerAdded(self)
	end

	self:SetCurrentGame(owner.Game)
	self.OwnerInstance = owner.Instance
end

function TowerComponentFabric:GetTower(partName: string): typeof(TowerComponent)
	--[[
	for part, tower in pairs(Towers) do
		if (part.Name == partName) then return tower end
	end
	]]

	return Towers[partName] -- check later
end

function TowerComponentFabric:GetTowers(): typeof({TowerComponent})
	return Towers
end

function TowerComponentFabric.new(position: Vector3, name: string) --, checkCallback: () -> boolean
	if (not TowersInfo:FindFirstChild(name)) then warn(name..' tower doesnt exist'); return end

	if (not TowersCache[name]) then
		local info = TowersInfo:FindFirstChild(name)
		if (not info) then return end
		
		TowersCache[name] = require(info)
	end
	
	local data = TowersCache[name][1]()
	
	data.CFrame = CFrame.new(position)
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

	--if (checkCallback and (not checkCallback(data))) then table.clear(data); return end

	local id = 1

	for i = 1, 2^12 do
		if (not Towers[tostring(i)]) then id = i; break end
	end

	data.Id = id

	for _, ability in pairs(data.Abilities) do
		self:AppendAbility(ability.Name, { self.Id, self })
	end

	for _, passive in pairs(data.Passives) do
		self:AppendPassive(passive.Name, passive.Level, passive.Requirements, { self })
	end

	for _, tower in pairs(TowerComponentFabric:GetTowers()) do
		if (tower.Id == data.Id) then continue end
		for _, passive in pairs(tower.Session.Passives) do
			passive.OnTowerAdded(self)
		end
	end

	data.Passives = nil
	data.Abilities = nil

	self:ReplicateField('Range', self.Range)
	self:ReplicateField('Level', self.Level)
	self:ReplicateField('Name', name)

	self:ReplicateDescriptions()

	Towers[tostring(data.Id)] = self

	towerCount += 1

	return self
end

return TowerComponentFabric
