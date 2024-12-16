local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Templates = ReplicatedStorage.Templates

local Enums = require(Templates.Enums)
local EntityTemplate = require(Templates.EntityTemplate)

--[[
	Firerate = 5,
	Damage = 1,
	Range = 5,
]]

local data = EntityTemplate()

data.Name = 'Default'
data.Model = nil

data.Defense = {
	[Enums.DamageType.Bullet] = 1,
	[Enums.DamageType.Energy] = 1,
	[Enums.DamageType.Splash] = 1,
}

return function()
	local temp = table.clone(data)
	
	temp.Attributes = {}
	temp.Passives = {}
	temp.Abilities = {}

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