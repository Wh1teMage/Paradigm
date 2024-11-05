local ReplicatedStorage = game:GetService('ReplicatedStorage')

--local EnemySamples = ReplicatedStorage.Samples.Enemies

local Template = require(ReplicatedStorage.Templates.TowerTemplate)

local Towers: {[string]: () -> typeof(Template())} = {}

Towers['Precursor'] = function()
	local tower = Template()
	
	tower.Damage = 10
	tower.Firerate = .1
	
	tower.Passives = {
		{Name = 'TestPassive', Level = 1, Requirements = {}}
	}
	
	return tower
end

return Towers
