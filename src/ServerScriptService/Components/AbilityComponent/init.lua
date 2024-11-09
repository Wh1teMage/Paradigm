local AbilitiesComponent = {}
AbilitiesComponent.__index = AbilitiesComponent

local GlobalCD = {} -- not sure about global cd

function AbilitiesComponent:CheckCD()
	if (os.clock() - GlobalCD[self.OwnerId].LastUsed) < self.CD then return end
	if (os.clock() - self.LastUsed) < self.CD then return end
	
	if (GlobalCD[self.OwnerId].Using) then return end
	if (self.Using) then return end
	
	return true
end

function AbilitiesComponent:Start()
	if (not self:CheckCD()) then return end
	
	self.Using = true
	GlobalCD[self.OwnerId].Using = true

	task.spawn(function()
		self.OnStart()
		self:Stop()
	end)
end

function AbilitiesComponent:Stop()
	self.OnStop()
	
	self.LastUsed = os.clock()
	self.Using = false
	
	GlobalCD[self.OwnerId].LastUsed = self.LastUsed
	GlobalCD[self.OwnerId].Using = false
end

function AbilitiesComponent.OnStart()

end

function AbilitiesComponent.OnStop()

end

function AbilitiesComponent:Setup(args: {any})
	local id = args[1]
	self.OwnerId = id
	
	GlobalCD[id] = {LastUsed = 0, Using = false}
	
	self.TransferData(args)
end

function AbilitiesComponent.TransferData(args: {any})

end

function AbilitiesComponent.new()
	local self = setmetatable({
		CD = 5,
		LastUsed = 0,
		Using = false,
		Level = 1,
		OwnerId = 1,
	}, AbilitiesComponent)

	return self
end

return AbilitiesComponent
