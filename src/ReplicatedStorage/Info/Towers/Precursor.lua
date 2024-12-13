local ReplicatedStorage = game:GetService('ReplicatedStorage')

local TowerSamples = ReplicatedStorage.Samples.TowerModels

local Template = require(ReplicatedStorage.Templates.TowerTemplate)
local Enums = require(ReplicatedStorage.Templates.Enums)

local Towers: {[number]: () -> typeof(Template())} = {}

Towers[1] = function()
	local tower = Template()

	tower.ModelsFolder = TowerSamples.Precursor
	tower.Price = 20
	tower.Range = 18
	tower.Damage = 18
	tower.Firerate = 2.05

	tower.ShootType = Enums.ShootType.Burst
	tower.BurstCount = 600
	tower.BurstCD = .1

	tower.Level = 1
	tower.SellPrice = tower.Price * .8

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

	tower.Descriptions = {
		{'Damage 18 → 13'}, -- somebody make an semi automatic parser for this, im too lazy
		{'Test Passive1', 'Does some stuff'},
	}

	return tower
end

Towers[2] = function()
	local tower = Towers[1]()

	tower.Damage = 13
	tower.Level = 2
	tower.Price = 40
	tower.SellPrice += tower.Price * .8

	tower.Descriptions = {
		{'Damage 18 → 26'},
		{'Test Passive2', 'Does more stuff'},
	}

	return tower
end

Towers[3] = function()
	local tower = Towers[2]()

	tower.Damage = 26
	tower.Level = 3
	tower.Price = 60
	tower.SellPrice += tower.Price * .8

	tower.Passives = {
		{Name = 'TestPassive', Level = 1, Requirements = {}}
	}

	tower.Descriptions = {}

	return tower
end

return Towers