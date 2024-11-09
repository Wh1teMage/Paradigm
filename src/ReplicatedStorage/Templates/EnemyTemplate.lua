local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Templates = ReplicatedStorage.Templates

local Enums = require(Templates.Enums)

local data = {
	Name = 'Default',
	Model = nil,
	Hitbox = nil,
	
	Level = 1,
	
	MaxHealth = 100,
	Health = 100,
	Speed = 1,
	
	Firerate = 5,
	Damage = 1,
	Range = 5,

	CanAttack = false,
	Distance = 0,

	Defense = {
		[Enums.DamageType.Bullet] = 1,
		[Enums.DamageType.Energy] = 1,
		[Enums.DamageType.Splash] = 1,
	},
	
	Amplifiers = {
		[Enums.EnemyAmplifiers.Speed] = 1,
		[Enums.EnemyAmplifiers.Range] = 1,
		[Enums.EnemyAmplifiers.Damage] = 1,
		[Enums.EnemyAmplifiers.Health] = 1,
		[Enums.EnemyAmplifiers.Firerate] = 1,
	},

	Attributes = {},
	Passives = {},
	Abilities = {},

	Animations = {},
	Sounds = {},
	Descriptions = {},
	
	Session = {
		Abilities = {},
		Passives = {},
		Buffs = {},
	},
}

return function()
	local temp = table.clone(data)
	
	temp.Attributes = {}
	temp.Passives = {}
	temp.Session = table.clone(temp.Session)

	temp.Defense = table.clone(temp.Defense)
	temp.Amplifiers = table.clone(temp.Amplifiers)
	
	temp.Session.Abilities = {}
	temp.Session.Passives = {}
	temp.Session.Buffs = {}

	temp.Animations = {}
	temp.Sounds = {}
	temp.Descriptions = {}
	
	return temp
end

--[[ --!!
Make all global server cycles into actors, this includes
OnTick for enemies, towers
Movement for enemies
Attack for tower, enemies
]]