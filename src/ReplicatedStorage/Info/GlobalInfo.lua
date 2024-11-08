local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Enums = require(ReplicatedStorage.Templates.Enums)

return {
	Health = 100,
	MaxHealth = 100,

	CurrentWave = 0,
	PathPoints = {},
	
	GlobalTowerAmplifiers = {
		[Enums.TowerAmplifiers.Cash] = 1,
		[Enums.TowerAmplifiers.Speed] = 1,
		[Enums.TowerAmplifiers.Range] = 1,
		[Enums.TowerAmplifiers.Damage] = 1,
	}
}
