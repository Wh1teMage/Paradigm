local buff = require(script.Parent)

return function()
	local self = buff.new()

	local component;

	local testVal = 0

	function self.Start()
		component:AddAmplifier('Range', testVal)
	end
	
	function self.Stop()
		component:AddAmplifier('Range', -testVal)
	end

	function self.TransferData(args: {any})
		component = args[1]
		testVal = args[2]
	end

	return self
end
