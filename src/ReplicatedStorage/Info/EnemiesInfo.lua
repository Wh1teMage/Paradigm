local ReplicatedStorage = game:GetService('ReplicatedStorage')

local EnemySamples = ReplicatedStorage.Samples.EnemyModels

local Template = require(script.Parent.Parent.Templates.EnemyTemplate)

local Enemies: {[string]: () -> typeof(Template())} = {}

Enemies['Part'] = function(level: number)
	local enemy = Template()
	
	if (level) then enemy.Level = level end
	
	enemy.Name = 'Part'

	enemy.MaxHealth = 18 -- change later
	enemy.Health = enemy.MaxHealth
	enemy.Model = EnemySamples.Walker
	
	enemy.Speed = 3
	enemy.Firerate = .1

	local idleAnim = Instance.new('Animation')
	idleAnim.AnimationId = 'rbxassetid://15289102971'

	enemy.Animations = {
		Idle = idleAnim,
	}

	enemy.Abilities = {
		{Name = 'Fireball'}
	}
	
	enemy.CanAttack = false
	--enemy.Model = EnemySamples["Spike Fox"]
	return enemy
end

Enemies['Walker'] = function(level: number)
	local enemy = Enemies['Part'](level)
	--[[
	if (level) then enemy.Level = level end
	
	enemy.MaxHealth = 6 * 100
	enemy.Health = enemy.MaxHealth
	enemy.Model = EnemySamples.Walker
	
	enemy.Speed = 3

	enemy.Animations = {
		Idle = 'rbxassetid://15289102971',
	}
	]]
	--enemy.Health = 2
	enemy.Speed = 5
	enemy.Model = EnemySamples.BigWalker
	enemy.Name = 'Walker'
	return enemy
end


return Enemies
