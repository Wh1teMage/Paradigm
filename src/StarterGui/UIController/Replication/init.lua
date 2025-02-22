local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

local PlayerComponent = require(ReplicatedStorage.Components.PlayerComponent) 
local HotbarController = require(script.HotbarController)
local TowerController = require(script.TowerController)

return function(UI: typeof(StarterGui.MainUI))
	local component = PlayerComponent:GetPlayer()

	HotbarController(UI, component)
	TowerController(UI, component)
end
