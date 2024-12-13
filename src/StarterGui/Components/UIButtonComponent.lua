local TweenService = game:GetService('TweenService')

local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

local Components: {typeof(ButtonComponent)} = {}

function ButtonComponent:BindToClick(callback: () -> {})
	table.insert(self.OnClick, callback)
end

function ButtonComponent:BindToEnter(callback: () -> {})
	table.insert(self.OnEnter, callback)
end

function ButtonComponent:BindToLeave(callback: () -> {})
	table.insert(self.OnLeave, callback)
end

function ButtonComponent:BindToDown(callback: () -> {})
	table.insert(self.OnDown, callback)
end

function ButtonComponent:BindToUp(callback: () -> {})
	table.insert(self.OnUp, callback)
end

function ButtonComponent.new(guiButton: GuiButton): typeof(ButtonComponent)
	if (Components[guiButton]) then return Components[guiButton] end
	if (not guiButton:IsA('GuiButton')) then return end
	
	local self = setmetatable({
		
		Instance = guiButton,
		
		OnClick = {},
		OnEnter = {},
		OnLeave = {},

		OnDown = {},
		OnUp = {},
		
	}, ButtonComponent)
	
	local defaultSelectorColor = Color3.fromRGB(255, 255, 255)
	local defaultOnEnterColor = Color3.fromRGB(255, 255, 255)

	local defaultSelectorTransparency = 0
	local defaultSize = 1
	local defaultMulti = .05
	
	local stroke = guiButton:FindFirstChildWhichIsA('UIStroke')
	local size = guiButton:FindFirstChildWhichIsA('UIScale')


	
	if stroke then
		defaultSelectorColor = stroke.Color
		defaultSelectorTransparency = stroke.Transparency

		local onEnterColor = stroke:FindFirstChildWhichIsA('Color3Value')
		if (onEnterColor) then defaultOnEnterColor = onEnterColor.Value end
	end
	
	if size then
		defaultSize = size.Scale
		local sizeMulti = size:FindFirstChildWhichIsA('NumberValue')
		if (sizeMulti) then defaultMulti = sizeMulti.Value end
	end
	
	local TInfo = TweenInfo.new(.15)
	
	self:BindToEnter(function()
		
		if (size) then 
			TweenService:Create(size, TInfo, { Scale = defaultSize * (1+defaultMulti) }):Play()
		end
		
		if (stroke) then
			
			if (stroke.Name == 'Selector') then
				stroke.Transparency = 1
				stroke.Enabled = true
				TweenService:Create(stroke, TInfo, { Transparency = defaultSelectorTransparency }):Play()
				return
			end
			
			TweenService:Create(stroke, TInfo, { Color = defaultOnEnterColor }):Play()
		end
	end)
	
	self:BindToLeave(function()

		if (size) then 
			TweenService:Create(size, TInfo, { Scale = defaultSize }):Play()
		end
		
		if (stroke) then
			
			if (stroke.Name == 'Selector') then
				TweenService:Create(stroke, TInfo, { Transparency = 1 }):Play()
				task.delay(TInfo.Time, function() stroke.Enabled = false end)
				return
			end
			
			TweenService:Create(stroke, TweenInfo.new(.2), { Color = defaultSelectorColor }):Play()
		end
	end)

	self:BindToDown(function()
		if (size) then 
			TweenService:Create(size, TInfo, { Scale = defaultSize * (1-defaultMulti) }):Play()
		end
	end)
	
	self:BindToUp(function()
		if (size) then 
			TweenService:Create(size, TInfo, { Scale = defaultSize * (1+defaultMulti) }):Play()
		end
	end)

	local clickConnection;
	clickConnection = guiButton.MouseButton1Click:Connect(function()
		for _, callback in pairs(self.OnClick) do callback() end
	end)
	
	local enterConnection;
	enterConnection = guiButton.MouseEnter:Connect(function()
		for _, callback in pairs(self.OnEnter) do callback() end
	end)
	
	local leaveConnection;
	leaveConnection = guiButton.MouseLeave:Connect(function()
		for _, callback in pairs(self.OnLeave) do callback() end
	end)

	local mouseDownConnection;
	mouseDownConnection = guiButton.MouseButton1Down:Connect(function()
		for _, callback in pairs(self.OnDown) do callback() end
	end)

	local mouseUpConnection;
	mouseUpConnection = guiButton.MouseButton1Up:Connect(function()
		for _, callback in pairs(self.OnUp) do callback() end
	end)
	
	
	local destsoyConnection;
	destsoyConnection = guiButton.Destroying:Connect(function()
		clickConnection:Disconnect()
		enterConnection:Disconnect()
		leaveConnection:Disconnect()

		mouseDownConnection:Disconnect()
		mouseUpConnection:Disconnect()
		
		self.OnClick = nil
		self.OnEnter = nil
		self.OnLeave = nil
		self.OnDown = nil
		self.OnUp = nil

		setmetatable(self, nil)
		self = nil
		Components[guiButton] = nil
		
		clickConnection = nil
		enterConnection = nil
		leaveConnection = nil
		mouseDownConnection = nil
		mouseUpConnection = nil
		
		destsoyConnection:Disconnect()
	end)
	
	Components[guiButton] = self
	
	return self
end

return ButtonComponent
