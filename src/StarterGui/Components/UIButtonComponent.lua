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

function ButtonComponent.new(guiButton: GuiButton): typeof(ButtonComponent)
	if (Components[guiButton]) then return Components[guiButton] end
	if (not guiButton:IsA('GuiButton')) then return end
	
	local self = setmetatable({
		
		Instance = guiButton,
		
		OnClick = {},
		OnEnter = {},
		OnLeave = {},
		
	}, ButtonComponent)
	
	local defaultSelectorColor = Color3.fromRGB(255, 255, 255)
	local defaultSelectorTransparency = 0
	local defaultSize = 1
	
	local stroke = guiButton:FindFirstChildWhichIsA('UIStroke')
	local size = guiButton:FindFirstChildWhichIsA('UIScale')
	
	if stroke then
		defaultSelectorColor = stroke.Color
		defaultSelectorTransparency = stroke.Transparency
	end
	
	if size then
		defaultSize = size.Scale
	end
	
	local TInfo = TweenInfo.new(.2)
	
	self:BindToEnter(function()
		
		if (size) then 
			TweenService:Create(size, TInfo, { Scale = defaultSize * 1.1 }):Play()
		end
		
		if (stroke) then
			
			if (stroke.Name == 'Selector') then
				stroke.Transparency = 1
				stroke.Enabled = true
				TweenService:Create(stroke, TInfo, { Transparency = defaultSelectorTransparency }):Play()
				return
			end
			
			TweenService:Create(stroke, TInfo, { Color = Color3.fromRGB(255, 255, 255) }):Play()
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
	
	local destsoyConnection;
	destsoyConnection = guiButton.Destroying:Connect(function()
		clickConnection:Disconnect()
		enterConnection:Disconnect()
		leaveConnection:Disconnect()
		
		self.OnClick = nil
		self.OnEnter = nil
		self.OnLeave = nil
		
		setmetatable(self, nil)
		self = nil
		Components[guiButton] = nil
		
		clickConnection = nil
		enterConnection = nil
		leaveConnection = nil
		
		destsoyConnection:Disconnect()
	end)
	
	Components[guiButton] = self
	
	return self
end

return ButtonComponent
