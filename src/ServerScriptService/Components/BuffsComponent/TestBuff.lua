local buff = require(script.Parent)

return function()
	local self = buff.new()

	function self.Start()
		print('Started Buffing')
	end
	
	function self.Stop()
		print('Stopped Buffing')
	end

	return self
end
