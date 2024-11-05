local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local UpgradesInfo = ReplicatedStorage.Info.Upgrades

local TargetComponent = require(script.TargetComponent)
local PassiveComponent = require(script.PassiveComponent)

local TowersInfo = require(ReplicatedStorage.Info.TowerInfo)
local DataModifiers = require(ReplicatedStorage.Utilities.DataModifiers)

local UpgradesCache = {}
local TowersCache = {}

local Towers = {}

local TowerComponent = setmetatable({}, {
	__index = function(t, i)
		return TargetComponent[i] or PassiveComponent[i]
	end,
})

local TICK = 1/20

task.spawn(function() -- seems nested, refactor later
	while task.wait(TICK) do
		for part, tower in pairs(Towers) do
			task.spawn(function()
				
				for _, passive in pairs(tower.Session.Passives) do
					passive.OnTick()
				end
				
				tower:Attack()
			end)
		end
	end
end)

function TowerComponent:CheckCD()
	if (self.Shooting) then return end
	if (os.clock() - self.LastShoot) < self.Firerate then return end
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

function TowerComponent:Destroy()
	Towers[self.Hitbox] = nil
	self.Hitbox:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

function TowerComponent:Upgrade()

	if (not UpgradesCache[self.Name]) then
		local info = UpgradesInfo:FindFirstChild(self.Name)
		if (not info) then return end
		
		UpgradesCache[self.Name] = require(info)
	end
	
	local upgradeInfo = UpgradesCache[self.Name]
	self.Level += 1
	
	if (not upgradeInfo[self.Level]) then return end
	
	self = DataModifiers:ConstuctData(upgradeInfo[self.Level](), self)
	
	print('Upgraded', self)
end

function TowerComponent:CheckRequirements(requirements) -- use later
	return true
end

local TowerComponentFabric = {}

function TowerComponentFabric:GetTower(partName: string): typeof(TowerComponent)
	for part, tower in pairs(Towers) do
		if (part.Name == partName) then return tower end
	end
end

function TowerComponentFabric.new(position: Vector3, name: string)
	if (not TowersInfo[name]) then warn(name..' tower doesnt exist') return end

	local part = Instance.new('Part')
	part.Name = name..tostring(os.clock())..tostring(math.random(-1000, 1000))
	part.Anchored = true
	part.Transparency = .5
	part.CanCollide = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	part.Parent = workspace.Towers

	local data = TowersInfo[name]()
	
	data.Hitbox = part
	data.SelectedTarget = nil
	data.LastShoot = 0
	data.Shooting = false

	local self = setmetatable(data, {__index = TowerComponent})

	for _, passive in pairs(data.Passives) do
		self:AppendPassive(passive.Name, passive.Level, passive.Requirements, { self })
	end

	Towers[part] = self

	return self
end

return TowerComponentFabric
