local ReplicatedStorage = game:GetService('ReplicatedStorage')

--local EnemySamples = ReplicatedStorage.Samples.Enemies

local Template = require(ReplicatedStorage.Info.TowerInfo)['Precursor']

local Towers: {[number]: () -> typeof(Template())} = {}

Towers[2] = function()
	local tower = Template()
	
	tower.Damage = 100
	
	return tower
end

return Towers
