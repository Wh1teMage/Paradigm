local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Templates = ReplicatedStorage.Templates

local Enums = require(Templates.Enums)

local data = {
	Name = 'Default',
	Model = nil,
	Hitbox = nil,
	
	Level = 1,
	
	MaxHealth = 10000,
	Health = 10000,
	Speed = 1,
	
	Distance = 0,

	Defense = {
		[Enums.DamageType.Bullet] = 0,
		[Enums.DamageType.Energy] = 0,
		[Enums.DamageType.Splash] = 0,
	},
	
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