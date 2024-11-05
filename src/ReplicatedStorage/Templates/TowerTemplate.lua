local Enums = require(script.Parent.Enums)

local data = {
	Name = 'Precursor',
	Model = nil,
	Hitbox = nil,

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

	Attributes = {},
	Passives = {},
	
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

	temp.Session.Passives = {}
	temp.Session.Buffs = {}

	return temp
end