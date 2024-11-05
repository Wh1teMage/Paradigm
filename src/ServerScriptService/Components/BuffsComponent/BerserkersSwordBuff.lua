local buff = require(script.Parent)

return function()
	local self = buff.new()
	
	local playerComponent;

	function self.Start()
		self.Session.Multipliers.Other.Damage += .2
	end

	function self.Stop()
		self.Session.Multipliers.Other.Damage -= .2
	end

	function self.TransferData(args: {any})
		playerComponent = args[1]
	end

	return self
end
