local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local TowersComponent = require(Components.TowerComponent)
local passive = require(ServerScriptService.Components.PassiveComponent)

return function()
	local self = passive.new()
	
	local component;
	
	function self.OnTick()
        component:ReplicateField('Range', component.Range * component.Amplifiers.Range)
	end
	
	function self.TransferData(args: {any})
		component = args[1]
	end
	
	return self
end
