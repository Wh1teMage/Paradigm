local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)

local avaliableScopes = { 'Range', 'Damage', 'Firerate', 'Health', 'Speed' }

local ValuesComponent = {}

function ValuesComponent:GetValue(scope: string)
    if (not table.find(avaliableScopes, scope)) then return end
    local value = self[scope] * self:GetAmplifier(scope)
    self:ReplicateField(scope, value)
    return value
end

function ValuesComponent:GetAmplifier(scope: string)
    if (not table.find(avaliableScopes, scope)) then return end  
    return self.Amplifiers[scope] * ( GlobalInfo.EnemyAmplifiers[scope] )
end

function ValuesComponent:GetAttribute(key)
	local sessionData = self.Session
	if (not sessionData.Attributes[key]) then sessionData.Attributes[key] = 0 end
	return sessionData.Attributes[key]
end

function ValuesComponent:AddAttribute(key, value: any)
	self.Session.Attributes[key] = self:GetAttribute(key) + value
end

function ValuesComponent:SetAttribute(key, value: any)
	self.Session.Attributes[key] = value
end

return ValuesComponent