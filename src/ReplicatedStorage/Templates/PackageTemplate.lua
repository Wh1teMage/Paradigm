local Enums = require(script.Parent.Enums)

local data = {

    TrackId = 1,
    Track = nil,
    Direction = 1,

    Attributes = {
        Speed = 1,
    },

    Amplifiers = {
		[Enums.TowerAmplifiers.Cash] = 1,
		[Enums.EnemyAmplifiers.Speed] = 1,
		[Enums.EnemyAmplifiers.Range] = 1,
		[Enums.EnemyAmplifiers.Damage] = 1,
		[Enums.EnemyAmplifiers.Health] = 1,
		[Enums.EnemyAmplifiers.Firerate] = 1,
	},

    CurrentStep = 0,

    CFrame = CFrame.new(10000, 10000, 10000),
    Distance = 0,
    EntityCount = 0,

    Game = nil,
    Entities = {},
    PackageType = Enums.PackageType.Enemy,

    Id = 1,

    Session = {
		Passives = {},
		Buffs = {},
		Abilities = {},
	},

}

return function()
	local temp = table.clone(data)

    temp.Attributes = table.clone(temp.Attributes)
    temp.Amplifiers = table.clone(temp.Amplifiers)

    temp.Entities = {}

    temp.Session = table.clone(temp.Session)
	
	temp.Session.Abilities = {}
	temp.Session.Passives = {}
	temp.Session.Buffs = {}

	return temp
end