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
		{"Wait", 3},
		{"Spawn", "Part", 3000, 0}, --1/30
		--{"Spawn", "Walker", 100, 1/30},
		{"WaitForClear"},
		{"AwardCash", 2550},
		{"Wait", 50},
	},
	[2] = {
		{"Spawn", "Part", 2000, 0},
		{"WaitForClear"},
		{"Wait", 5},
	},
	[3] = {
		{"Spawn", "Part", 3000, 0},
		{"WaitForClear"},
		{"Wait", 5},
		--{"Spawn", "Walker", 15, .1},
		--{"Wait", 5},
	},
	[4] = {
		{"Spawn", "Part", 4000, 0},
		{"WaitForClear"},
		--{"Spawn", "Part", 15, .1},
		{"Wait", 5},
	},
	[5] = {
		{"Spawn", "Part", 5000, 0},
		{"WaitForClear"},
		--{"Spawn", "Part", 15, .1},
		{"Wait", 5},
	},
	[6] = {
		{"Spawn", "Part", 6000, 0},
		{"WaitForClear"},
		--{"Spawn", "Part", 15, .1},
		{"Wait", 5},
	},
	[7] = {
		{"Spawn", "Part", 7000, 0},
		{"WaitForClear"},
		--{"Spawn", "Part", 15, .1},
		{"Wait", 5},
	},
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
