local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Templates = ReplicatedStorage.Templates

local Enums = require(Templates.Enums)
local EntityTemplate = require(Templates.EntityTemplate)

local data = EntityTemplate()

data.Name = 'Precursor'
data.ModelsFolder = nil
data.Skin = 'Default'

data.Price = 325
data.SellPrice = 250

data.Firerate = 1
data.Damage = 1
data.Range = 5

data.Limit = 8

data.PlacementType = Enums.PlacementType.Ground
data.TargetType = Enums.TargetType.First
data.ShootType = Enums.ShootType.Single

data.PackageType = Enums.PackageType.Tower

data.EnemiesInRange = {}

--	Hidden = true,
--	UpgradePrice = nil,

return function()
	local temp = table.clone(data)

	temp.Attributes = {}
	temp.Passives = {}
	temp.Abilities = {}

	temp.Session = table.clone(temp.Session)
	temp.Amplifiers = table.clone(temp.Amplifiers)

	temp.Animations = {}
	temp.Sounds = {}
	temp.Descriptions = {}

	temp.Session.Abilities = {}
	temp.Session.Passives = {}
	temp.Session.Buffs = {}

	temp.EnemiesInRange = {}

	return temp
end