local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Patterns = {}

Patterns['Burst'] = function(component, callback: () -> nil)

	--print(component.SelectedTarget)

	for i = 1, component.BurstCount do
		task.wait(component.BurstCD/component:GetAmplifier('Firerate'))
		if (not getmetatable(component)) then break end

		component:WaitForTarget()
		if ((not getmetatable(component.SelectedTarget)) or (not getmetatable(component))) then continue end

		component:FaceEnemy()
		callback()

		if (i%10 == 0) then component.SelectedTarget = nil end
		--component.SelectedTarget = nil

		if (not getmetatable(component)) then break end
	end


end

Patterns['Single'] = function(component, callback: () -> nil)

	--print(component.SelectedTarget)

	if (not getmetatable(component)) then return end

	component:WaitForTarget()
	if ((not getmetatable(component.SelectedTarget)) or (not getmetatable(component))) then return end

	component:FaceEnemy()
	callback()

	component.SelectedTarget = nil

	if (not getmetatable(component)) then return end

end



return Patterns