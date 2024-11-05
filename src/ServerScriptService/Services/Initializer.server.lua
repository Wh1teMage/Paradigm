local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local HttpService = game:GetService('HttpService')

local Components = ServerScriptService.Components
local ReplicatedComponents = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local DataTransfer = require(ReplicatedComponents.SignalComponent.DataTransfer)

require(Components.GameComponent).new():Start()

SignalComponent:GetSignal('ManageTowers')

SignalComponent:GetSignal('Test'):Connect(function(scope, ...)
	print(scope, ...)
end)

--SignalComponent:GetSignal('Test'):Wait('Test1')