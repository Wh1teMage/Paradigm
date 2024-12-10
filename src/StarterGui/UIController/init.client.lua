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

FrameComponent.new(mainUI.Upgrade):BindToOpen(function()
	mainUI.Upgrade.Position = UDim2.fromScale(1.3, 0)
	mainUI.Upgrade.Visible = true
	TweenService:Create(mainUI.Upgrade, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Position'] = UDim2.fromScale(.775, 0) }):Play()

	FrameComponent.new(mainUI.Upgrade.Sell):Open()
	FrameComponent.new(mainUI.Upgrade.AbilityContainer):Open()
	FrameComponent.new(mainUI.Upgrade.UpgInfo.Details):Open()
	FrameComponent.new(mainUI.Upgrade.UpgInfo.Upgrade):Open()
	FrameComponent.new(mainUI.Upgrade.TowerName.TextLabel):Open()
	FrameComponent.new(mainUI.Upgrade.UpgradeName.TextLabel):Open()

	--task.delay(.1, function() FrameComponent.new(mainUI.Upgrade.Targetting):Open() end)
end)

FrameComponent.new(mainUI.Upgrade):BindToClose(function()
	mainUI.Upgrade.Position = UDim2.fromScale(.775, 0)
	local tween = TweenService:Create(mainUI.Upgrade, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Position'] = UDim2.fromScale(1.3, 0) })
	tween:Play()

	FrameComponent.new(mainUI.Upgrade.Sell):Close()
	--FrameComponent.new(mainUI.Upgrade.Targetting):Close()
	FrameComponent.new(mainUI.Upgrade.AbilityContainer):Close()
	FrameComponent.new(mainUI.Upgrade.UpgInfo.Details):Close()
	FrameComponent.new(mainUI.Upgrade.UpgInfo.Upgrade):Close()
	FrameComponent.new(mainUI.Upgrade.TowerName.TextLabel):Close()
	FrameComponent.new(mainUI.Upgrade.UpgradeName.TextLabel):Close()

	tween.Completed:Wait()
	mainUI.Upgrade.Visible = false
end)

FrameComponent.new(mainUI.Upgrade.Sell):BindToOpen(function(self) --{1, 0},{0.4, 0}
	self.Position = UDim2.fromScale(1, .5)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Position'] = UDim2.fromScale(1, .838) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.Sell):BindToClose(function(self)
	self.Position = UDim2.fromScale(1, .838)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Position'] = UDim2.fromScale(1, .5) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.Targetting):BindToOpen(function(self)
	self.Size = UDim2.fromScale(.9, .7)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Size'] = UDim2.fromScale(.9, 1) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.Targetting):BindToClose(function(self)
	self.Size = UDim2.fromScale(.9, 1)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Size'] = UDim2.fromScale(.9, .7) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.AbilityContainer):BindToOpen(function(self)
	self.Position = UDim2.fromScale(0, 0.35)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Position'] = UDim2.fromScale(-0.955, 0.35) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.AbilityContainer):BindToClose(function(self)
	self.Position = UDim2.fromScale(-0.955, 0.35)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Position'] = UDim2.fromScale(0, 0.35) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.UpgInfo.Details):BindToOpen(function(self)
	self.Position = UDim2.fromScale(0, -0.5)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Position'] = UDim2.fromScale(0, 0) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.UpgInfo.Details):BindToClose(function(self)
	self.Position = UDim2.fromScale(0, 0)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Position'] = UDim2.fromScale(0, -0.5) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.UpgInfo.Upgrade):BindToOpen(function(self)
	self.Size = UDim2.fromScale(0.9, 0)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Size'] = UDim2.fromScale(0.9, 0.2) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.UpgInfo.Upgrade):BindToClose(function(self)
	self.Size = UDim2.fromScale(0.9, 0.2)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Size'] = UDim2.fromScale(0.9, 0) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.TowerName.TextLabel):BindToOpen(function(self)
	self.Size = UDim2.fromScale(0, 1)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Size'] = UDim2.fromScale(1, 1) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.TowerName.TextLabel):BindToClose(function(self)
	self.Size = UDim2.fromScale(1, 1)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Size'] = UDim2.fromScale(0, 1) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.UpgradeName.TextLabel):BindToOpen(function(self)
	self.Size = UDim2.fromScale(0, 1)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Size'] = UDim2.fromScale(1, 1) }):Play()
end)

FrameComponent.new(mainUI.Upgrade.UpgradeName.TextLabel):BindToClose(function(self)
	self.Size = UDim2.fromScale(1, 1)
	TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Size'] = UDim2.fromScale(0, 1) }):Play()
end)
