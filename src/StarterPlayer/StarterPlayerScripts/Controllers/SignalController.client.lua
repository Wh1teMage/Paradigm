local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ReplicatedComponents = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local PlayerComponent = require(ReplicatedComponents.PlayerComponent)
local ReplicationComponent = require(ReplicatedComponents.ReplicationComponent)

local PathConfig = require(ReplicatedStorage.Templates.PathConfig)	

local Component = PlayerComponent:GetPlayer()

SignalComponent:GetSignal('ManageTowersBindable', true):Connect(
	function(scope: string, ...)
		if (scope == 'StartPlacing') then Component:StartPlacing(...) end
		if (scope == 'SelectTower') then Component:SelectTower() end
		if (scope == 'StopPlacing') then Component:StopPlacing() end
		if (scope == 'UpgradeTower') then Component:UpgradeTower() end
		if (scope == 'SellTower') then Component:SellTower() end
	end
)

SignalComponent:GetSignal('ManageEffects'):Connect(
	function(scope: number, ...)

		if (tonumber( scope ) == tonumber( PathConfig.Scope.ReplicateEffect )) then
			ReplicationComponent:TriggerEffect(...) 
		end

	end
)