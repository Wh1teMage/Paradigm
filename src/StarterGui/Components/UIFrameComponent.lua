local FrameComponent = {}
FrameComponent.__index = FrameComponent

local Components: {typeof(FrameComponent)} = {}

function FrameComponent:Open()
	if (self.locked) then return end
	self.locked = true
	for _, callback in pairs(self.OnOpen) do callback(self.Instance) end
	self.open = true
	self.locked = false
end

function FrameComponent:Close()
	if (self.locked) then return end
	self.locked = true
	for _, callback in pairs(self.OnClose) do callback(self.Instance) end
	self.open = false
	self.locked = false
end

function FrameComponent:Change()
	if (self.locked) then return end
	
	if (self.open) then self:Close()
	else self:Open() end
end

function FrameComponent:CloseOthers()
	for inst, component in pairs(Components) do
		if (inst == self.Instance) then continue end
		if (component.open) then component:Close() end
	end
end

function FrameComponent:BindToOpen(callback: () -> {})
	table.insert(self.OnOpen, callback)
end

function FrameComponent:BindToClose(callback: () -> {})
	table.insert(self.OnClose, callback)
end

function FrameComponent.new(frame: Frame): typeof(FrameComponent)
	if (Components[frame]) then return Components[frame] end
	
	local self = setmetatable({
		Instance = frame,
		
		OnOpen = {},
		OnClose = {},
		
		locked = false,
		open = false,
	}, FrameComponent)
	
	Components[frame] = self
	
	return self
end

return FrameComponent
