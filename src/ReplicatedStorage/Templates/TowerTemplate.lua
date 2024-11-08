local Enums = require(script.Parent.Enums)

local data = {
	Name = 'Precursor',
	Hitbox = nil,
	ModelsFolder = nil,

	Level = 1,

	Price = 325,
	SellPrice = 250,
	
	Firerate = 1,
	Damage = 1,
	Range = 5,
	
	Limit = 8,
	Hidden = true,
	
	PlacementType = Enums.PlacementType.Ground,
	TargetType = Enums.TargetType.First,
	ShootType = Enums.ShootType.Single,

	Attributes = {},
	Passives = {},

	Animations = {},
	Sounds = {},
	Descriptions = {},
	
	Amplifiers = {
		[Enums.TowerAmplifiers.Cash] = 1,
		[Enums.TowerAmplifiers.Speed] = 1,
		[Enums.TowerAmplifiers.Range] = 1,
		[Enums.TowerAmplifiers.Damage] = 1,
	},

	Session = {
		Passives = {},
		Buffs = {},
	},
}

return function()
	local temp = table.clone(data)

	temp.Attributes = {}
	temp.Passives = {}
	temp.Session = table.clone(temp.Session)
	temp.Amplifiers = table.clone(temp.Amplifiers)

	temp.Animations = {}
	temp.Sounds = {}
	temp.Descriptions = {}

	temp.Session.Passives = {}
	temp.Session.Buffs = {}

	return temp
end