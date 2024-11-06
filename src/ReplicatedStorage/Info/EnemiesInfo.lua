local ReplicatedStorage = game:GetService('ReplicatedStorage')

--local EnemySamples = ReplicatedStorage.Samples.Enemies

local Template = require(script.Parent.Parent.Templates.EnemyTemplate)

local Enemies: {[string]: () -> typeof(Template())} = {}

Enemies['Part'] = function(level: number)
	local enemy = Template()
	
	if (level) then enemy.Level = level end
	
	enemy.MaxHealth = enemy.MaxHealth * 10000 + 10*(enemy.Level-1) -- change later
	enemy.Health = enemy.MaxHealth
	
	enemy.Speed = 1
	
	enemy.Name = 'Part'
	--enemy.Model = EnemySamples["Spike Fox"]
	return enemy
end

Enemies['Walker'] = function(level: number)
	local enemy = Template()
	
	if (level) then enemy.Level = level end
	
	enemy.MaxHealth = 100
	enemy.Health = enemy.MaxHealth
	
	enemy.Speed = 1
	
	enemy.Name = 'Part'
	--enemy.Model = EnemySamples["Spike Fox"]
	return enemy
end


return Enemies
