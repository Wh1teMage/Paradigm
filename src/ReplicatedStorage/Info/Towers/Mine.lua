local ReplicatedStorage = game:GetService('ReplicatedStorage')

local TowerSamples = ReplicatedStorage.Samples.TowerModels

local Template = require(ReplicatedStorage.Templates.TowerTemplate)
local Enums = require(ReplicatedStorage.Templates.Enums)

local Towers: {[number]: () -> typeof(Template())} = {}

Towers[1] = function()
	local tower = Template()

    tower.Name = 'Mine'

	tower.ModelsFolder = TowerSamples.Mine
	tower.Price = 2
	tower.Range = 5
	tower.Damage = 100
	tower.Firerate = .1

	tower.ShootType = Enums.ShootType.Single

	tower.Level = 1
	tower.SellPrice = tower.Price * .8

	--local idleAnim = Instance.new('Animation')
	--idleAnim.AnimationId = 'rbxassetid://14253606347'

	--local attackAnim = Instance.new('Animation')
	--attackAnim.AnimationId = 'rbxassetid://14535901409'

	local attackSound = Instance.new('Sound')
	attackSound.SoundId = 'rbxassetid://7131411690'
	attackSound.PlaybackSpeed = 1.3
	attackSound.Volume = 0.35

	tower.Animations = {
		--Idle = idleAnim,
		--Attack = attackAnim
	}

	tower.Sounds = {
		AttackSound = attackSound
	}

	tower.Descriptions = {
		{'Damage 18 → 13'}, -- somebody make an semi automatic parser for this, im too lazy
		{'Test Passive1', 'Does some stuff'},
	}

	return tower
end

return Towers