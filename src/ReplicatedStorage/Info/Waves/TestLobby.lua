local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Templates = ReplicatedStorage.Templates
local Template = require(Templates.WaveTemplate)

local Waves: {typeof(Template())} = {
	[1] = {
		{"Dialogue", "Get ready for a new enemy!", 3},
		{"AwardCash", 1000},
		{"Spawn", "Part", 6, 1.2}
	}
}

return Waves
