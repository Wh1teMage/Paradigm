local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local ReplicatedComponents = ReplicatedStorage.Components

local EnemiesInfo = require(ReplicatedStorage.Info.EnemiesInfo)
local PlayerEffects = require(script.PlayerEffects)

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local ReplicaController = require(ReplicatedStorage.ReplicaController)

local ActionComponent = require(script.ActionComponent)
local TowersComponent = require(script.TowersComponent)

local Cache = {}

local Component: IPlayerComponent = nil

local PlayerComponent = {}
PlayerComponent.__index = setmetatable(PlayerComponent, {
	__index = function(t, i)
		return TowersComponent[i]
	end,
}) 

type IPlayerComponent = typeof(PlayerComponent)

function PlayerComponent:ReplicatePlayerEffect(args) --!! rewrite later
	local effectName = args[1]
	
	if (not PlayerEffects[effectName]) then return end
	PlayerEffects[effectName](self, args)
end

local PlayerComponentFabric = {}

local IsLoaded = false

function PlayerComponent.constructor(): IPlayerComponent
	local self = setmetatable({

		Instance = Players.LocalPlayer,
		Replica = {},
		Data = {},

	}, {
		__index = function(t, i)
			return PlayerComponent[i]
		end
	})

	ReplicaController.ReplicaOfClassCreated('PlayerData', function(replica)
		self.Replica = replica
		IsLoaded = true
		print("-- PlayerData replica received! --")
	end)

	ReplicaController.RequestData()
	
	while (not IsLoaded) do task.wait(.1) end

	Component = self
	
	self.Data.Controls = {
		{ name = 'PressAction1', code = Enum.KeyCode.One, state = Enum.UserInputState.Begin },
		{ name = 'PressAction2', code = Enum.KeyCode.Two, state = Enum.UserInputState.Begin },
		{ name = 'PressAction3', code = Enum.KeyCode.Three, state = Enum.UserInputState.Begin },
		{ name = 'PressAction4', code = Enum.KeyCode.Four, state = Enum.UserInputState.Begin },
		{ name = 'PressAction5', code = Enum.KeyCode.Five, state = Enum.UserInputState.Begin },
		
		{ name = 'StopPlacing', code = Enum.KeyCode.Q, state = Enum.UserInputState.Begin },
		{ name = 'UpgradeTower', code = Enum.KeyCode.F, state = Enum.UserInputState.Begin },
		{ name = 'SellTower', code = Enum.KeyCode.X, state = Enum.UserInputState.Begin },
		
		{ name = 'SelectAction', code = Enum.UserInputType.MouseButton1, state = Enum.UserInputState.Begin },

		{ name = 'Test1', code = Enum.KeyCode.V, state = Enum.UserInputState.Begin },
		{ name = 'Test2', code = Enum.KeyCode.V, state = Enum.UserInputState.End },
	}
	
	ActionComponent.UpdateControls(self.Data.Controls)

	return self
end

function PlayerComponentFabric:CreatePlayer()
	if (Component and IsLoaded) then return Component end

	return PlayerComponent.constructor()
end

function PlayerComponentFabric:GetPlayer()
	while (not IsLoaded) or (not Component) do task.wait(.1); print(Component, 'Loading') end
	return Component
end

return PlayerComponentFabric
