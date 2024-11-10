local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Templates = ReplicatedStorage.Templates
local Template = require(Templates.LobbyTemplate)

--[[
	{"Wait", 3},
	{"Walker", 6, 1},
	{"Wait", 10},--wait type, time
	{"AwardCash", 255},
]]

local Lobby = Template()

Lobby.Settings.Health = 1000
Lobby.Settings.MaxHealth = 1000

Lobby.Waves = {
	[1] = {
		{"Spawn", "Part", 15, .1},
		{"Wait", 5},
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

return Lobby
