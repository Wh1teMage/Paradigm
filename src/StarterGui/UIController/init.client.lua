local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local StarterGui = game:GetService('StarterGui')

local Components = script.Parent.Components
local ButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local FrameComponent = require(Components:WaitForChild('UIFrameComponent'))

local mainUI = script.Parent:WaitForChild('MainUI')
local sampleUI = StarterGui:WaitForChild('MainUI')

local SignalComponent = require(ReplicatedStorage:WaitForChild('Components'):WaitForChild('SignalComponent')) 

repeat task.wait(.1) until #mainUI:GetDescendants() >= #sampleUI:GetDescendants()

print('working')

require(script.Replication)(mainUI)

for _, slot in pairs(mainUI.Towers:GetChildren()) do
	if (not slot:IsA('GuiButton')) then continue end
	ButtonComponent.new(slot):BindToClick(function()
		SignalComponent:GetSignal('ManageTowersBindable', true):Fire('StartPlacing', slot.LayoutOrder)
	end)
end
