local buff = require(script.Parent)

return function()
	local self = buff.new()

    local multiplier = self.Level;
    local startTime = os.clock();

    local duration = 2;
    local stopped  = false;

	local packageComponent;
    local thread: thread;

	function self.Start()

        packageComponent.Attributes.SlownessStart = os.clock()
        packageComponent.Amplifiers.Speed /= multiplier

		thread = task.delay(duration, function()
            if (os.clock() - startTime) < duration then return end
			self:Stop()
		end)
	end

	function self.Stop() -- add garbage collector
        if (stopped) then return end
		if (not getmetatable(packageComponent)) then return end
        packageComponent.Amplifiers.Speed *= multiplier
        packageComponent.Attributes.SlownessStart = nil
        
        stopped = true
        task.cancel(thread)
	end
	
	function self.TransferData(args: {any})
		packageComponent = args[1]
        duration = args[2]
	end

	return self
end
