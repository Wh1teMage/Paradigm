local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Patterns = {}

Patterns['Burst'] = function(component, callback: () -> nil)

	for i = 1, component.BurstCount do
		task.wait(component.BurstCD/component:GetAmplifier('Firerate'))
		if (not getmetatable(component)) then break end

		component:WaitForTarget()
		if ((not getmetatable(component.SelectedTarget)) or (not getmetatable(component))) then continue end

		component:FaceEnemy()
		callback()

		if (not getmetatable(component)) then break end
	end

end



return Patterns