local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)

local avaliableScopes = { 'Range', 'Damage', 'Firerate' }

local ValuesComponent = {}

function ValuesComponent:GetValue(scope: string)
    if (not table.find(avaliableScopes, scope)) then return end
    local value = self[scope] * self:GetAmplifier(scope)
    self:ReplicateField(scope, value)
    return value
end

function ValuesComponent:GetAmplifier(scope: string)
    if (not table.find(avaliableScopes, scope)) then return end  
    return self.Amplifiers[scope] * ( GlobalInfo.TowerAmplifiers[scope] )
end

function ValuesComponent:AddAmplifier(scope: string, value: number)
    if (not table.find(avaliableScopes, scope)) then return end  
    self.Amplifiers[scope] += value
end

function ValuesComponent:GetAttribute(key)
	if (not self.Attributes[key]) then self.Attributes[key] = 0 end
	return self.Attributes[key]
end

function ValuesComponent:AddAttribute(key, value: any)
	self.Attributes[key] = self:GetAttribute(key) + value
end

function ValuesComponent:SetAttribute(key, value: any)
	self.Attributes[key] = value
end

return ValuesComponent