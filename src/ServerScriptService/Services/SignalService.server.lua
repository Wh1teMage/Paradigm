local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local ReplicatedComponents = ReplicatedStorage.Components
local Components = ServerScriptService.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local PlayerComponent = require(Components.PlayerComponent)

local PathConfig = require(ReplicatedStorage.Templates.PathConfig)	

SignalComponent:GetSignal('ManageTowers'):Connect(
	function(scope, ...)
		local args = {...}
		local component = PlayerComponent:GetPlayer(args[1])

		scope = tonumber(scope)

		if (not component) then return end
		
		if (scope == PathConfig.Scope.PlaceTower) then component:PlaceTower(args[2], args[3]) return end
		if (scope == PathConfig.Scope.UpgradeTower) then component:UpgradeTower(args[2]) return end
		if (scope == PathConfig.Scope.SellTower) then component:SellTower(args[2]) return end
	end
)

SignalComponent:GetSignal('ManageGame'):Connect(
	function(scope, ...)
		local args = {...}
		local component = PlayerComponent:GetPlayer(args[1])

		if (scope == tostring( PathConfig.Scope.GameStarted )) then 
			component.Session.LoadedClient = true 
		end
	end
)