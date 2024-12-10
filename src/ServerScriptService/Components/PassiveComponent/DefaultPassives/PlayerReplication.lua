local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local TowersComponent = require(Components.TowerComponent)
local passive = require(ServerScriptService.Components.PassiveComponent)

return function()
	local self = passive.new()
	
	local component;
	
	function self.OnTick()
        local profileData = component.Profile.Data
        local sessionData = component.Session

        if (not component.Replica:IsActive()) then return end

        component.Replica:SetValue('Profile.Values.ExpValue', profileData.Values.ExpValue)
	    component.Replica:SetValue('Session.Attributes.Cash', sessionData.Attributes['Cash'])
	    component.Replica:SetValue('Session.Attributes.TowerAmount', sessionData.Attributes['TowerAmount'])
	end
	
	function self.TransferData(args: {any})
		component = args[1]
	end
	
	return self
end