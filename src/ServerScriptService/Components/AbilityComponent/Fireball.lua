local ability = require(script.Parent)

return function()
	local self = ability.new()

	local component;

	function self.OnStart()
		print('Started Ability')
		task.wait(1)
	end

	function self.OnStop()
		print('Stopped Ability')
	end
	
	function self.TransferData(args: {any})
		component = args[2]
	end

	return self
end
