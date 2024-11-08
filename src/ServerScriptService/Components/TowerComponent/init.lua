local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local TargetComponent = require(script.TargetComponent)
local PassiveComponent = require(script.PassiveComponent)

local TowersInfo = ReplicatedStorage.Info.Towers
local DataModifiers = require(ReplicatedStorage.Utilities.DataModifiers)

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

	local upgradeInfo = TowersCache[self.Name]

	self.Level += 1
	
	if (not upgradeInfo[self.Level]) then return end

	self:ReplicateField('Level', self.Level)
	DataModifiers:UpdateTable(self.Info, upgradeInfo[self.Level]())
end

function TowerComponent:CheckRequirements(requirements) -- use later
	return true
end

function TowerComponent:ReplicateField(fieldName: string, value: number)
	if (not self.Hitbox) then return end
	local hitbox: Part? = self.Hitbox
	hitbox:SetAttribute(fieldName, value)
end

local TowerComponentFabric = {}

function TowerComponentFabric:GetTower(partName: string): typeof(TowerComponent)
	for part, tower in pairs(Towers) do
		if (part.Name == partName) then return tower end
	end
end

function TowerComponentFabric.new(position: Vector3, name: string)
	if (not TowersInfo:FindFirstChild(name)) then warn(name..' tower doesnt exist') return end

	local clockId = tostring(math.round(math.fmod(os.clock(), 1)*1000))
	local postfix = string.rep('0', (4-string.len(clockId)))

	local part = ReplicatedStorage.Samples.TowerPart:Clone()
	part.Name = clockId..postfix..tostring(math.random(-9999, 9999))
	part.CFrame = CFrame.new(position)
	part.Parent = workspace.Towers

	if (not TowersCache[name]) then
		local info = TowersInfo:FindFirstChild(name)
		if (not info) then return end
		
		TowersCache[name] = require(info)
	end
	
	local data = {}
	
	data.Info = TowersCache[name][1]()
	data.Hitbox = part
	data.SelectedTarget = nil
	data.LastShoot = 0
	data.Shooting = false

	local self = setmetatable(data, {
		__index = function(t, i)
			return TowerComponent[i] or data.Info[i]
		end 
	})

	for _, passive in pairs(data.Passives) do
		self:AppendPassive(passive.Name, passive.Level, passive.Requirements, { self })
	end

	self:ReplicateField('Level', self.Level)
	self:ReplicateField('Name', name)

	Towers[part] = self

	return self
end

return TowerComponentFabric
