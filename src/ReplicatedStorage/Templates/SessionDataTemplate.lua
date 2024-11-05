local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Templates = ReplicatedStorage.Templates

local Enums = require(Templates.Enums)

local multipliers = {
	ParaCoins = 0,
	Spawnrate = 0,
	Credits = 0,
	Cash = 0,
	Exp = 0,
}

local data = {
	Attributes = {
		Cash = 0,
	},
	
	Settings = {
		ShowVisualizer = false,
		RainbowUI = false,
		FOVShake = false,
		MusicVolume = 1,
		TowerVolume = 1,
	},

	Multipliers = {
		Location = table.clone(multipliers),
		Global = table.clone(multipliers),
		Other = table.clone(multipliers),
	},

	Character = nil,
	SessionTime = 0,
	
	ActiveBuffs = {},
	Party = {},
	
	OnDeath = {},
	Passives = {},
	Abilities = {},
}

return function()
	local clonnedData = table.clone(data)
	
	clonnedData.Multipliers = table.clone(clonnedData.Multipliers)
	clonnedData.Attributes = table.clone(clonnedData.Attributes)
	clonnedData.Settings = table.clone(clonnedData.Settings)
	
	clonnedData.ActiveBuffs = {}
	clonnedData.Party = {}
	
	clonnedData.OnDeath = {}
	clonnedData.Passives = {}
	clonnedData.Abilities = {}
	
	return clonnedData
end
