local buff = require(script.Parent)

return function()
	local self = buff.new()

	local enemyComponent;

	function self.Start()
		print('AppliedStun')
		
		enemyComponent:AddAttribute('Slowness', self.Data.Value)
		--enemyComponent:AddAttribute('Stunned', 1)
		
		task.delay(self.Data.Time, function()
			self:Stop()
		end)
	end

	function self.Stop() -- add garbage collector
		if (not getmetatable(enemyComponent)) then return end
		enemyComponent:AddAttribute('Slowness', -self.Data.Value)
		--enemyComponent:AddAttribute('Stunned', -1)
	end
	
	function self.TransferData(args: {any})
		enemyComponent = args[1]
	end

	return self
end
