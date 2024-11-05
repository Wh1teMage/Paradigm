return {
	Values = {
		CreditsValue = 0,
		ParaCoinsValue = 0,
		ExpValue = 0,
		LevelValue = 0,
	},
	
	Multipliers = {
		CreditsMultiplier = 0,
		ParaCoinsMultiplier = 0,
		ExpMultiplier = 0,
		SpawnrateMultiplier = 0,
	},
	
	Config = {
		FirstJoin = os.time(),
		LastJoined = os.time(),

		DayAmount = 0,
		IngameTime = 0,
		RobuxSpent = 0,
		
		Luck = 1,
		Losses = 0,
		Wins = 0,
	},

	Codes = {},
	Products = {},
	Quests = {},
	
	OwnedTowers = {
		{ Name = 'Precursor', Skin = '' }
	},
	Skins = {},
	
	EquippedTowers = {
		TowerSlot1 = 'Precursor',
		TowerSlot2 = nil,
		TowerSlot3 = nil,
		TowerSlot4 = nil,
		TowerSlot5 = nil,
	},
	
	Constants = {
		VERSION = .1	
	},
}