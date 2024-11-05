local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ReplicatedComponent = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponent.SignalComponent)

local Contexts = {}

Contexts['PressAction1'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('StartPlacing', 1)
end

Contexts['PressAction2'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('StartPlacing', 2)
end

Contexts['PressAction3'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('StartPlacing', 3)
end

Contexts['PressAction4'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('StartPlacing', 4)
end

Contexts['PressAction5'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('StartPlacing', 5)
end

Contexts['StopPlacing'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('StopPlacing')
end

Contexts['SelectAction'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('SelectTower')
end

Contexts['UpgradeTower'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('UpgradeTower')
end

Contexts['SellTower'] = function()
	SignalComponent:GetSignal('ManageTowersBindable', true):Fire('SellTower')
end

return Contexts
