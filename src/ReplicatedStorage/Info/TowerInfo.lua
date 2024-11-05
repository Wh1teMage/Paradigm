local ReplicatedStorage = game:GetService('ReplicatedStorage')

local TowerSamples: Folder = ReplicatedStorage.Samples.TowerModels

local Template = require(ReplicatedStorage.Templates.TowerTemplate)

local Towers: {[string]: () -> typeof(Template())} = {}

Towers['Precursor'] = function()
	local tower = Template()
	
	tower.Model = TowerSamples:FindFirstChild('TestModel') :: Model
	tower.Damage = 10
	tower.Firerate = 1/30
	tower.Range = 100
	
	tower.Passives = {
		{Name = 'TestPassive', Level = 1, Requirements = {}}
	}
	
	return tower
end

return Towers
