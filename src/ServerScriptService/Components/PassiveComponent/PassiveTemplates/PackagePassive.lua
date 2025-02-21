local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local passive = require(ServerScriptService.Components.PassiveComponent)

return function()
	local self = passive.new()
	
    local package;
	
	function self.OnDeath() -- prob make this one into stop

		package.EntityCount -= 1
		--print(package.EntityCount, 'destroying enemy')
		if (package.EntityCount < 1) then package:Destroy() end

	end
	
	function self.TransferData(args: {any})
        package = args[1]
	end
	
	return self
end