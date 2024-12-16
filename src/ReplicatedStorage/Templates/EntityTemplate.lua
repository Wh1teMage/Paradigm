local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Templates = ReplicatedStorage.Templates

local Enums = require(Templates.Enums)

local data = {
	Name = 'Test',
	CFrame = nil,

    PackageType = Enums.PackageType.Enemy,
	PackageId = 0,
	Level = 1,

    MaxHealth = 100,
	Health = 100,
    Speed = 1,

    CanAttack = false,

	Attributes = {},
	Passives = {},
	Abilities = {},

	Animations = {},
	Sounds = {},
	Descriptions = {},

	Amplifiers = {
		[Enums.TowerAmplifiers.Cash] = 1,
		[Enums.EnemyAmplifiers.Speed] = 1,
		[Enums.EnemyAmplifiers.Range] = 1,
		[Enums.EnemyAmplifiers.Damage] = 1,
		[Enums.EnemyAmplifiers.Health] = 1,
		[Enums.EnemyAmplifiers.Firerate] = 1,
	},

	Session = {
		Passives = {},
		Buffs = {},
		Abilities = {},
	},
}

return function()
	local temp = table.clone(data)
	
	temp.Attributes = {}
	temp.Passives = {}
	temp.Abilities = {}

	temp.Session = table.clone(temp.Session)
	temp.Amplifiers = table.clone(temp.Amplifiers)
	
	temp.Session.Abilities = {}
	temp.Session.Passives = {}
	temp.Session.Buffs = {}

	temp.Animations = {}
	temp.Sounds = {}
	temp.Descriptions = {}
	
	return temp
end