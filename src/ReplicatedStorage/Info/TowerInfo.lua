local ReplicatedStorage = game:GetService('ReplicatedStorage')

local TowerSamples: Folder = ReplicatedStorage.Samples.TowerModels

local Enums = require(ReplicatedStorage.Templates.Enums)
local Template = require(ReplicatedStorage.Templates.TowerTemplate)

local Towers: {[string]: () -> typeof(Template())} = {}

Towers['Precursor'] = function()
	local tower = Template()
	
	tower.Model = TowerSamples:FindFirstChild('TestModel') :: Model
	tower.Price = 460
	tower.Range = 18 * 100
	tower.Damage = 1
	tower.Firerate = 2.05

	tower.ShootType = Enums.ShootType.Burst
	tower.BurstCount = 6
	tower.BurstCD = .11

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
		{Name = 'TestPassive', Level = 1, Requirements = {}}
	}
	
	return tower
end

return Towers
