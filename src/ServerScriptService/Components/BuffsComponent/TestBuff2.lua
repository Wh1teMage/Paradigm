local buff = require(script.Parent)

return function()
	local self = buff.new()

	local component;

	function self.Start()
		print('Started Buffing')
		component:AddAmplifier('Range', .5*self.Level)
	end
	
	function self.Stop()
		print('Stopped Buffing', component.Level)
		component:AddAmplifier('Range', -.5*self.Level)
	end

	function self.TransferData(args: {any})
		component = args[1]
	end

	return self
end
