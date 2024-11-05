local TweenService = game:GetService('TweenService')
local StarterGui = game:GetService('StarterGui')

local Components = script.Parent.Components
local ButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local FrameComponent = require(Components:WaitForChild('UIFrameComponent'))

local mainUI = script.Parent:WaitForChild('MainUI')
local sampleUI = StarterGui:WaitForChild('MainUI')

repeat task.wait(.1) until #mainUI:GetDescendants() >= #sampleUI:GetDescendants()

require(script.Replication)(mainUI)

local hotbar = mainUI.Hotbar
local hotbarRButtons = hotbar.RightButtons
local hotbarLButtons = hotbar.LeftButtons

local inventory =  mainUI.Inventory
local stats =  mainUI.Stats

local statsButton = hotbarRButtons.Buttons.StatsButton
local inventoryButton = hotbarRButtons.Buttons.InventoryButton

local charButtons =  stats.Screens.Character.SideButtons

local statsScreen =  stats.Screens.Character.Stats
local upgradesScreen =  stats.Screens.Character.Upgrades

for _, v in pairs(hotbarRButtons.ActiveButtons:GetChildren()) do
	ButtonComponent.new(v)
end

for _, v in pairs(hotbarLButtons.Buttons:GetChildren()) do
	ButtonComponent.new(v)
end

ButtonComponent.new(stats.Buttons.Close):BindToClick(function()
	FrameComponent.new(stats):Close()
end)

ButtonComponent.new(inventory.Buttons.Close):BindToClick(function()
	FrameComponent.new(inventory):Close()
end)

local function transferColor(button: GuiButton)
	for _, obj in pairs(charButtons:GetChildren()) do
		if (not obj:IsA('TextButton')) then continue end
		if (button == obj) then continue end
		
		TweenService:Create(obj, TweenInfo.new(.2), 
			{ BackgroundColor3 = Color3.fromRGB(0,0,0) }):Play()
		TweenService:Create(obj, TweenInfo.new(.2), 
			{ TextColor3 = Color3.fromRGB(255,255,255) }):Play()
		
		TweenService:Create(obj.UIStroke, TweenInfo.new(.2), { Transparency = 1 }):Play()
		task.delay(.2, function() obj.UIStroke.Enabled = false end)
	end
	
	TweenService:Create(button, TweenInfo.new(.2), 
		{ BackgroundColor3 = Color3.fromRGB(255,255,255) }):Play()
	TweenService:Create(button, TweenInfo.new(.2), 
		{ TextColor3 = Color3.fromRGB(0,0,0) }):Play()

	button.UIStroke.Enabled = true
	TweenService:Create(button.UIStroke, TweenInfo.new(.2), { Transparency = 0 }):Play()
end

ButtonComponent.new(charButtons.Points):BindToClick(function()
	transferColor(charButtons.Points)
	FrameComponent.new(statsScreen):Close()
	task.wait(.2)
	statsScreen.Visible = false
	FrameComponent.new(upgradesScreen):Open()
end)

ButtonComponent.new(charButtons.Attributes):BindToClick(function()
	transferColor(charButtons.Attributes)
	FrameComponent.new(upgradesScreen):Close()
	task.wait(.2)
	upgradesScreen.Visible = false
	FrameComponent.new(statsScreen):Open()
end)

FrameComponent.new(statsScreen):BindToOpen(function()
	for _, v in pairs(statsScreen:GetChildren()) do
		if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
		v.Size = UDim2.fromScale(0, v.Size.Y.Scale)
	end
	
	statsScreen.Visible = true
	
	task.spawn(function()
		for _, v in pairs(statsScreen:GetChildren()) do
			if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
			TweenService:Create(v, TweenInfo.new(.2), 
				{ Size = UDim2.fromScale(1, v.Size.Y.Scale) }):Play()
			task.wait(.05)
		end
	end)

end)

FrameComponent.new(statsScreen):BindToClose(function()
	for _, v in pairs(statsScreen:GetChildren()) do
		if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
		TweenService:Create(v, TweenInfo.new(.2), 
			{ Size = UDim2.fromScale(0, v.Size.Y.Scale) }):Play()
		--task.wait(.05)
	end

	--[[
	task.delay(.2, function()
		statsScreen.Visible = false
	end)
	]]
end)

FrameComponent.new(upgradesScreen):BindToClose(function()
	for _, v in pairs(upgradesScreen:GetChildren()) do
		if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
		TweenService:Create(v, TweenInfo.new(.2), 
			{ Size = UDim2.fromScale(0, v.Size.Y.Scale) }):Play()
		--task.wait(.05)
	end
	
	--[[
	task.delay(.2, function()
		upgradesScreen.Visible = false
	end)
	]]
end)

FrameComponent.new(upgradesScreen):BindToOpen(function()
	for _, v in pairs(upgradesScreen:GetChildren()) do
		if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
		v.Size = UDim2.fromScale(0, v.Size.Y.Scale)
	end

	upgradesScreen.Visible = true

	task.spawn(function()
		for _, v in pairs(upgradesScreen:GetChildren()) do
			if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
			TweenService:Create(v, TweenInfo.new(.2), 
				{ Size = UDim2.fromScale(1, v.Size.Y.Scale) }):Play()
			task.wait(.05)
		end
	end)

end)

ButtonComponent.new(statsButton):BindToClick(function()
	FrameComponent.new(stats):Change()
end)

FrameComponent.new(stats):BindToOpen(function()
	local pattern = stats.Pattern
	local ILButton = stats.Buttons

	local characterScreen = stats.Screens.Character
	local grid = characterScreen.SideButtons.UIGridLayout

	pattern.ImageTransparency = 1
	pattern.BackgroundTransparency = 1
	ILButton.Position = UDim2.fromScale(0.02, 1)
	grid.CellSize = UDim2.fromScale(0, .12)
	
	--[[
	for _, v in pairs(characterScreen.Stats:GetChildren()) do
		if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
		v.Size = UDim2.fromScale(0, v.Size.Y.Scale)
	end
	]]

	FrameComponent.new(stats):CloseOthers()

	stats.Visible = true

	TweenService:Create(pattern, TweenInfo.new(.2), { ImageTransparency = .9 }):Play()
	TweenService:Create(pattern, TweenInfo.new(.2), { BackgroundTransparency = .45 }):Play()

	TweenService:Create(ILButton, TweenInfo.new(.2), 
		{ Position = UDim2.fromScale(0.02, .887) }):Play()

	TweenService:Create(grid, TweenInfo.new(.2), 
		{ CellSize = UDim2.fromScale(1, .12) }):Play()

	for _, obj in pairs(stats.Screens.Character:GetChildren()) do
		if (obj.Name == 'SideButtons') then continue end
		if (not obj.Visible) then continue end
		FrameComponent.new(obj):Open()
	end

	--[[
	for _, v in pairs(characterScreen.Stats:GetChildren()) do
		if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
		TweenService:Create(v, TweenInfo.new(.2), 
			{ Size = UDim2.fromScale(1, v.Size.Y.Scale) }):Play()
		task.wait(.05)
	end
	]]

	task.wait(.2)
end)

FrameComponent.new(stats):BindToClose(function()
	local pattern = stats.Pattern
	local ILButton = stats.Buttons

	local characterScreen = stats.Screens.Character
	local grid = characterScreen.SideButtons.UIGridLayout

	--[[
	for _, v in pairs(characterScreen.Stats:GetChildren()) do
		if (not (v:IsA('Frame') or v:IsA('CanvasGroup'))) then continue end
		TweenService:Create(v, TweenInfo.new(.2), 
			{ Size = UDim2.fromScale(0, v.Size.Y.Scale) }):Play()
		--task.wait(.05)
	end
	]]
	
	for _, obj in pairs(stats.Screens.Character:GetChildren()) do
		if (obj.Name == 'SideButtons') then continue end
		FrameComponent.new(obj):Close()
	end
	
	--FrameComponent.new(statsScreen):Close()

	TweenService:Create(pattern, TweenInfo.new(.2), { ImageTransparency = 1 }):Play()
	TweenService:Create(pattern, TweenInfo.new(.2), { BackgroundTransparency = 1 }):Play()

	TweenService:Create(ILButton, TweenInfo.new(.2), 
		{ Position = UDim2.fromScale(0.02, 1) }):Play()
	
	TweenService:Create(grid, TweenInfo.new(.2), 
		{ CellSize = UDim2.fromScale(0, .12) }):Play()
	
	task.wait(.2)
	stats.Visible = false
end)

for i, v in pairs(inventory.Items:GetChildren()) do
	FrameComponent.new(v):BindToOpen(function()
		local active = v

		active.Visible = false

		for _, obj: GuiButton in pairs(active.ScrollingFrame:GetChildren()) do
			if (not obj:IsA('GuiButton')) then continue end
			local scale = obj:FindFirstChildWhichIsA('UIScale')
			if (not scale) then continue end

			scale.Scale = 0
		end

		active.Visible = true
		
		task.spawn(function()
			for _, obj: GuiButton in pairs(active.ScrollingFrame:GetChildren()) do
				if (not obj:IsA('GuiButton')) then continue end
				local scale = obj:FindFirstChildWhichIsA('UIScale')
				if (not scale) then continue end

				TweenService:Create(scale, TweenInfo.new(.2), { Scale = 1 }):Play()

				task.wait()
			end
		end)

	end)

	FrameComponent.new(v):BindToClose(function()
		local active = v

		for _, obj: GuiButton in pairs(active.ScrollingFrame:GetChildren()) do
			if (not obj:IsA('GuiButton')) then continue end
			local scale = obj:FindFirstChildWhichIsA('UIScale')
			if (not scale) then continue end

			TweenService:Create(scale, TweenInfo.new(.2), { Scale = 0 }):Play()
		end

		--task.delay(.2, function() active.Visible = false end)
	end)
end

local function changeButton(currentButton)

	for _, button in pairs(inventory.Buttons:GetChildren()) do
		if (not button:IsA('GuiButton')) then continue end
		if (button.Name == 'Close') then continue end
		if (button == currentButton) then continue end

		TweenService:Create(button.TextStroke, TweenInfo.new(.2), { Transparency = 1 }):Play()
		task.delay(.2, function() button.TextStroke.Enabled = false end)
	end

	currentButton.TextStroke.Transparency = 1
	currentButton.TextStroke.Enabled = true 

	TweenService:Create(currentButton.TextStroke, TweenInfo.new(.2), { Transparency = .7 }):Play()

end

ButtonComponent.new(inventory.Buttons.Actives):BindToClick(function()
	changeButton(inventory.Buttons.Actives)
	FrameComponent.new(inventory.Items.Passive):Close()
	task.wait(.2)
	inventory.Items.Passive.Visible = false
	FrameComponent.new(inventory.Items.Active):Open()
end)

ButtonComponent.new(inventory.Buttons.Passives):BindToClick(function()
	changeButton(inventory.Buttons.Passives)
	FrameComponent.new(inventory.Items.Active):Close()
	task.wait(.2)
	inventory.Items.Active.Visible = false
	FrameComponent.new(inventory.Items.Passive):Open()
end)


ButtonComponent.new(inventoryButton):BindToClick(function()
	FrameComponent.new(inventory):Change()
end)

FrameComponent.new(inventory):BindToOpen(function()
	local pattern = inventory.Pattern
	local ILButton = inventory.Buttons
	local info = inventory.Info
	
	pattern.ImageTransparency = 1
	pattern.BackgroundTransparency = 1
	ILButton.Position = UDim2.fromScale(0.02, 1)
	info.Position = UDim2.fromScale(1, 0.06)
	
	--[[
	for _, cluster: Frame in pairs(inventory.Items:GetChildren()) do
		if (not cluster.Visible) then continue end
		
		for _, obj: GuiButton in pairs(cluster.ScrollingFrame:GetChildren()) do
			if (not obj:IsA('GuiButton')) then continue end
			local scale = obj:FindFirstChildWhichIsA('UIScale')
			if (not scale) then continue end
			
			scale.Scale = 0
		end
	end
	]]
	
	FrameComponent.new(inventory):CloseOthers()
	
	inventory.Visible = true
	
	TweenService:Create(pattern, TweenInfo.new(.2), { ImageTransparency = .9 }):Play()
	TweenService:Create(pattern, TweenInfo.new(.2), { BackgroundTransparency = .45 }):Play()
	
	TweenService:Create(ILButton, TweenInfo.new(.2), 
		{ Position = UDim2.fromScale(0.02, .887) }):Play()
	TweenService:Create(info, TweenInfo.new(.2), 
		{ Position = UDim2.fromScale(.776, 0.06) }):Play()
	
	for _, cluster: Frame in pairs(inventory.Items:GetChildren()) do
		if (not cluster.Visible) then continue end
		
		FrameComponent.new(cluster):Open()
	end
	
	--[[
	for _, cluster: Frame in pairs(inventory.Items:GetChildren()) do
		if (not cluster.Visible) then continue end

		for _, obj: GuiButton in pairs(cluster.ScrollingFrame:GetChildren()) do
			if (not obj:IsA('GuiButton')) then continue end
			local scale = obj:FindFirstChildWhichIsA('UIScale')
			if (not scale) then continue end

			TweenService:Create(scale, TweenInfo.new(.2), { Scale = 1 }):Play()
			
			task.wait()
		end
		
	end
	]]
	
	task.wait(.2)
end)

FrameComponent.new(inventory):BindToClose(function()
	local pattern = inventory.Pattern
	local ILButton = inventory.Buttons
	local info = inventory.Info
	
	for _, cluster: Frame in pairs(inventory.Items:GetChildren()) do
		--if (not cluster.Visible) then continue end

		FrameComponent.new(cluster):Close()

		--[[

		for _, obj: GuiButton in pairs(cluster.ScrollingFrame:GetChildren()) do
			if (not obj:IsA('GuiButton')) then continue end
			local scale = obj:FindFirstChildWhichIsA('UIScale')
			if (not scale) then continue end

			TweenService:Create(scale, TweenInfo.new(.2), { Scale = 0 }):Play()
		end
		
		]]

	end
	
	TweenService:Create(pattern, TweenInfo.new(.2), { ImageTransparency = 1 }):Play()
	TweenService:Create(pattern, TweenInfo.new(.2), { BackgroundTransparency = 1 }):Play()
	
	TweenService:Create(ILButton, TweenInfo.new(.2), 
		{ Position = UDim2.fromScale(0.02, 1) }):Play()
	TweenService:Create(info, TweenInfo.new(.2), 
		{ Position = UDim2.fromScale(1, 0.06) }):Play()
	
	task.wait(.2)
	inventory.Visible = false
end)