local ReplicatedStorage = game:GetService('ReplicatedStorage')

--local EnemySamples = ReplicatedStorage.Samples.Enemies

local Template = require(script.Parent.Parent.Templates.EnemyTemplate)

local Enemies: {[string]: () -> typeof(Template())} = {}

Enemies['Part'] = function(level: number)
	local enemy = Template()
	
	if (level) then enemy.Level = level end
	
	enemy.MaxHealth = enemy.MaxHealth + 10*(enemy.Level-1)
	enemy.Health = enemy.MaxHealth
	
	enemy.Speed = 10
	
	enemy.Name = 'Part'
	--enemy.Model = EnemySamples["Spike Fox"]
	return enemy
end

return Enemies
