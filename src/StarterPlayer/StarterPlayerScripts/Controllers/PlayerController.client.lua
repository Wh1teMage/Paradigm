local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Player = Players.LocalPlayer

local Components = ReplicatedStorage.Components
local PlayerComponent = require(Components.PlayerComponent)

local Component = PlayerComponent:CreatePlayer()

--for i, v in pairs(workspace.Arenas:GetChildren()) do
	--ReplicatedStorage.Events.ManageFight:FireServer('Trigger', v.Name)
--end

print(Component)