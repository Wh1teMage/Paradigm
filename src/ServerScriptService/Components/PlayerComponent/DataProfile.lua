local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ProfileService = require(ServerScriptService.ProfileService)
local ReplicaService = require(ServerScriptService.ReplicaService)

local ProfileTemplate = require(ReplicatedStorage.Templates.ProfileStoreTemplate) 
local SessionTemplate = require(ReplicatedStorage.Templates.SessionDataTemplate) 

local DataModifiers = require(ReplicatedStorage.Utilities.DataModifiers)

local DataProfile = {}

local ProfileStore = ProfileService.GetProfileStore('Main', ProfileTemplate)
local TOKEN = ReplicaService.NewClassToken('PlayerData')

function DataProfile:LoadProfile()

	local player = self.Instance
	local profile = ProfileStore:LoadProfileAsync(tostring(player.UserId))
	
	profile.Data = DataModifiers:ConstuctData(profile.Data, ProfileTemplate)
	profile:AddUserId(player.UserId)
	
	profile:ListenToRelease(function()
		profile:Release()
		player:Kick('Profile was released')
	end)

	return profile
end

function DataProfile:LoadReplica()
	local replica = ReplicaService.NewReplica({
		ClassToken = TOKEN,
		Data = {Profile = self.Profile.Data, Session = self.Session},
		Replication = self.Instance,
	})
	
	return replica
end

function DataProfile:LoadSession()
	return SessionTemplate()
end

return DataProfile
