local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local HttpService = game:GetService('HttpService')

local Components = ServerScriptService.Components
local ReplicatedComponents = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local DataTransfer = require(ReplicatedComponents.SignalComponent.DataTransfer)

SignalComponent:GetSignal('ManageTowers')
SignalComponent:GetSignal('ManageEffects')

--require(Components.GameComponent).new('TestLobby'):Start()

print('-- Setup Completed --')

task.wait(3)

--SignalComponent:Test()

--SignalComponent:GetSignal('Test'):Wait('Test1')