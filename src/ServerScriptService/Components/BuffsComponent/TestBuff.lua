local buff = require(script.Parent)

return function()
	local self = buff.new()

	local component;

	local buffTime = 5

	function self.Start()
		print('Started Buffing')

		task.delay(buffTime, function()
			self.Stop()
		end)
	end
	
	function self.Stop()
		print('Stopped Buffing')
	end

	function self.TransferData(args: {any})
		component = args[1]
	end

	return self
end
