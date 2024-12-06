local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local HttpService = game:GetService('HttpService')

local Components = ServerScriptService.Components
local ReplicatedComponents = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local DataTransfer = require(ReplicatedComponents.SignalComponent.DataTransfer)

local LobbyComponent = require(Components.LobbyComponent)

SignalComponent:GetSignal('ManageTowers')
SignalComponent:GetSignal('ManageEnemies')
SignalComponent:GetSignal('ManageEffects')


--LobbyComponent:Survival('TestGame', 'TestModel')

--require(Components.GameComponent).new('TestLobby'):Start()

print('-- Setup Completed --')

task.wait(3)

--SignalComponent:Test()

--SignalComponent:GetSignal('Test'):Wait('Test1')