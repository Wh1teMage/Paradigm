local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Templates = ReplicatedStorage.Templates
local Template = require(Templates.WaveTemplate)

--[[
	{"Wait", 3},
	{"Walker", 6, 1},
	{"Wait", 10},--wait type, time
	{"AwardCash", 255},
]]

local Waves: {typeof(Template())} = {
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
}

return Waves
