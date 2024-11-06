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

	tower.Animations = {
		Idle = 'rbxassetid://14253606347',
		Attack = 'rbxassetid://14535901409'
	}

	tower.Sounds = {
		AttackSound = {
			SoundId = 'rbxassetid://7131411690',
			PlaybackSpeed = 1.3,
			Volume = 0.35,
		}
	}
	
	tower.Passives = {
		{Name = 'TestPassive', Level = 1, Requirements = {}}
	}
	
	return tower
end

return Towers
