local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Enums = require(ReplicatedStorage.Templates.Enums)

return {
	Health = 100,
	MaxHealth = 100,

	CurrentWave = 0,
	PathPoints = {},

	Loaded = false,

	UseCustomLoadout = false,
	EquippedTowers = {
		TowerSlot1 = nil,
		TowerSlot2 = nil,
		TowerSlot3 = nil,
		TowerSlot4 = nil,
		TowerSlot5 = nil,
	},
	
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
