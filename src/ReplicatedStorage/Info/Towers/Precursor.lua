local ReplicatedStorage = game:GetService('ReplicatedStorage')

local TowerSamples = ReplicatedStorage.Samples.TowerModels

local Template = require(ReplicatedStorage.Templates.TowerTemplate)
local Enums = require(ReplicatedStorage.Templates.Enums)

local Towers: {[number]: () -> typeof(Template())} = {}

Towers[1] = function()
	local tower = Template()

	tower.ModelsFolder = TowerSamples.Precursor
	tower.Price = 460
	tower.Range = 18
	tower.Damage = 1
	tower.Firerate = 2.05

	tower.ShootType = Enums.ShootType.Burst
	tower.BurstCount = 6
	tower.BurstCD = .11

	tower.Level = 1

	local idleAnim = Instance.new('Animation')
	idleAnim.AnimationId = 'rbxassetid://14253606347'

	local attackAnim = Instance.new('Animation')
	attackAnim.AnimationId = 'rbxassetid://14535901409'

	local attackSound = Instance.new('Sound')
	attackSound.SoundId = 'rbxassetid://7131411690'
	attackSound.PlaybackSpeed = 1.3
	attackSound.Volume = 0.35

	tower.Animations = {
		Idle = idleAnim,
		Attack = attackAnim
	}

	tower.Sounds = {
		AttackSound = attackSound
	}

	tower.Passives = {
		{Name = 'TestPassive2', Level = 1, Requirements = {}}
	}

	return tower
end

Towers[2] = function()
	local tower = Towers[1]()

	tower.Damage = 13
	tower.Level = 2

	return tower
end

Towers[3] = function()
	local tower = Towers[2]()

	tower.Damage = 26
	tower.Level = 3

	tower.Passives = {
		{Name = 'TestPassive', Level = 1, Requirements = {}}
	}

	return tower
end

return Towers