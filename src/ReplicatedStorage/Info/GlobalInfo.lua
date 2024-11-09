local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Enums = require(ReplicatedStorage.Templates.Enums)

return {
	Health = 100,
	MaxHealth = 100,

	CurrentWave = 0,
	PathPoints = {},
	
	TowerAmplifiers = {
		[Enums.TowerAmplifiers.Cash] = 1,
		[Enums.TowerAmplifiers.Range] = 1,
		[Enums.TowerAmplifiers.Damage] = 1,
		[Enums.TowerAmplifiers.Firerate] = 1,
	},

	EnemyAmplifiers = {
		[Enums.EnemyAmplifiers.Speed] = 1,
		[Enums.EnemyAmplifiers.Range] = 1,
		[Enums.EnemyAmplifiers.Damage] = 1,
		[Enums.EnemyAmplifiers.Health] = 1,
		[Enums.EnemyAmplifiers.Firerate] = 1,
	},
}
