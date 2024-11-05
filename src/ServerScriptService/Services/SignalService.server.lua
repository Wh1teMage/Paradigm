local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local ReplicatedComponents = ReplicatedStorage.Components
local Components = ServerScriptService.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local PlayerComponent = require(Components.PlayerComponent)

SignalComponent:GetSignal('ManageTowers'):Connect(
	function(scope, ...)
		local args = {...}
		local component = PlayerComponent:GetPlayer(args[1])
		
		if (not component) then return end
		
		if (scope == 'PlaceTower') then component:PlaceTower(args[2], args[3]) return end
		if (scope == 'UpgradeTower') then component:UpgradeTower(args[2]) return end
		if (scope == 'SellTower') then component:SellTower(args[2]) return end
	end
)