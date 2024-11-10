local AbilitiesComponent = {}
AbilitiesComponent.__index = AbilitiesComponent


function AbilitiesComponent:CheckCD()
	if (os.clock() - self.LastUsed) < self.CD then return end
	if (self.Using) then return end
	
	return true
end

function AbilitiesComponent:Start()
	if (not self:CheckCD()) then return end
	
	self.Using = true

	task.spawn(function()
		self.OnStart()
		self:Stop()
	end)
end

function AbilitiesComponent:Stop()
	self.OnStop()
	
	self.LastUsed = os.clock()
	self.Using = false
end

function AbilitiesComponent.OnStart()

end

function AbilitiesComponent.OnStop()

end

function AbilitiesComponent:Setup(args: {any})
	local id = args[1]
	self.OwnerId = id
	
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
