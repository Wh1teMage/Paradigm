local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Templates = ReplicatedStorage.Templates
local Template = require(Templates.GameTemplate)

--[[
	{"Wait", 3},
	{"Walker", 6, 1},
	{"Wait", 10},--wait type, time
	{"AwardCash", 255},
]]

local Game = Template()

Game.Settings.Health = 1000
Game.Settings.MaxHealth = 1000

Game.Waves = {
	[1] = {
		{"Spawn", "Part", 100, 0},
		{"Wait", 50},
	},
	[2] = {
		{"Spawn", "Part", 15, .1},
		{"Wait", 5},
	},
	[3] = {
		{"Spawn", "Part", 15, .1},
		{"Wait", 5},
	},
	[4] = {
		{"Spawn", "Part", 15, .1},
		{"Wait", 5},
	}
}


	--[[
	[1] = {
		{"Wait", 3},
		{"Spawn", "Walker", 6, 1},
		{"Wait", 10},
		{"AwardCash", 255},
	},
	[2] = {
		{"Spawn", "Walker", 8, 0.9},
		{"Wait", 5},
		{"AwardCash", 310},
	},
	]]

return Game
