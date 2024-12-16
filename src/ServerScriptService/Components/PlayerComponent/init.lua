local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local LoadedComponents = {}

for _, component in ipairs(script:GetChildren()) do
	LoadedComponents[component.Name] = require(component)
end

local Components: {IPlayerComponent} = {}

local PlayerComponentMethods = {}

function PlayerComponentMethods:SetCurrentGame(match)
	self.Game = match

	if (self.Game.Info.UseCustomLoadout) then self.Session.EquippedTowers = table.clone(self.Game.Info.EquippedTowers) end
	self.Replica:SetValue('Session.EquippedTowers', self.Session.EquippedTowers)
end

function PlayerComponentMethods:OnLeft()
	local player = self.Instance :: Player
	Components[player.UserId] = nil
	self.Profile:Release()
	self.Replica:Destroy()
end

function PlayerComponentMethods:OnStart()
	local player = self.Instance :: Player
	self.Profile = self:LoadProfile()
	self.Session = self:LoadSession()
	self.Replica = self:LoadReplica()
	
	self:SetupCharacter()	
	self:AddPlayerToParty(self)
	
	task.spawn(function()
		while task.wait(.1) do
			for _, passive in pairs(self.Session.Passives) do
				passive.OnTick()
			end
		end
	end)
	
	for i, v in pairs(script.Parent.PassiveComponent.DefaultPassives:GetChildren()) do
		self:AppendPassive(v.Name, 1, {}, {self})
	end
	
	self.Session.EquippedTowers = table.clone(self.Profile.Data.EquippedTowers)
	self.Replica:SetValue('Session.EquippedTowers', self.Session.EquippedTowers)

	--! Party System Testing
	
	for _, comp in pairs(Components) do
		comp:AddPlayerToParty(self)
	end
	
end

local PlayerComponent = {}
PlayerComponent.__index = setmetatable(PlayerComponentMethods, {
	__index = function(t, i)
		for _, component in pairs(LoadedComponents) do
			if (component[i]) then return component[i] end
		end
	end
})

type IPlayerComponent = typeof(PlayerComponentMethods)

function PlayerComponent.constructor(player: Player): IPlayerComponent
	local self = setmetatable({
		
		Instance = player,
		Profile = {},
		Session = {},
		Replica = {},
		
	}, PlayerComponent)

	self:OnStart()
	
	Components[player.UserId] = self
	
	return self
end

local PlayerComponentFabric = {}

function PlayerComponentFabric:CreatePlayer(player: Player): IPlayerComponent
	local component = PlayerComponentFabric:GetPlayer(player)
	if (component) then return component end
	
	return PlayerComponent.constructor(player)
end

function PlayerComponentFabric:GetPlayer(player: Player): IPlayerComponent
	if (not player) then return end
	return Components[player.UserId]
end

return PlayerComponentFabric
