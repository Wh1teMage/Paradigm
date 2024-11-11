local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Templates = ReplicatedStorage.Templates

local Template = require(Templates.ProfileStoreTemplate) 

type IProfileTemplate = typeof(require(Templates.ProfileStoreTemplate))

local ValuesComponent = {}

function ValuesComponent:GetAttribute(key)
	local sessionData = self.Session
	if (not sessionData.Attributes[key]) then sessionData.Attributes[key] = 0 end
	return sessionData.Attributes[key]
end

function ValuesComponent:AddAttribute(key, value: any)
	self.Session.Attributes[key] = self:GetAttribute(key) + value
end

function ValuesComponent:ApplyReward(reward)
	local profileData: IProfileTemplate = self.Profile.Data
	local sessionData = self.Session
	
	profileData.Values.ParaCoinsValue += math.round(reward.Values.ParaCoins)
	profileData.Values.CreditsValue += math.round(reward.Values.Credits)
	profileData.Values.ExpValue += math.round(reward.Values.Exp)

	self:LevelUp()
	
	self.Replica:SetValue('Profile.Values.ParaCoinsValue', profileData.Values.ParaCoinsValue)
	self.Replica:SetValue('Profile.Values.CreditsValue', profileData.Values.CreditsValue)
	self.Replica:SetValue('Profile.Values.ExpValue', profileData.Values.ExpValue)
end

function ValuesComponent:CheckRequirements(requirements)
	local profileData = self.Profile.Data
	local sessionData = self.Session
	
	return true
end

function ValuesComponent:LevelUp()
	local profileData = self.Profile.Data
	local sessionData = self.Session
	local values = profileData.Values

	local requiredExp = values.LevelValue*100*(1.01^values.LevelValue) + 100
	
	while (values.ExpValue > requiredExp) do
		values.ExpValue -= math.round(requiredExp)
		values.LevelValue += 1
		requiredExp = values.LevelValue*100*(1.01^values.LevelValue) + 100
	end
	
	self.Replica:SetValue('Profile.Values.LevelValue', profileData.Values.LevelValue)
	self.Replica:SetValue('Profile.Values.ExpValue', profileData.Values.ExpValue)
end

return ValuesComponent
