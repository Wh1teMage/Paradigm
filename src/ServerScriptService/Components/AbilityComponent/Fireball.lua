local ability = require(script.Parent)

return function()
	local self = ability.new()

	local playerComponent;

	function self.OnStart()
		print('Started Ability')
		print(playerComponent.Session)
		task.wait(1)
	end

	function self.OnStop()
		print('Stopped Ability')
	end
	
	function self.TransferData(args: {any})
		playerComponent = args[2]
	end

	return self
end
