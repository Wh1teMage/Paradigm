local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)
local LobbiesInfo = ReplicatedStorage.Info.Lobbies

local QuadPath = require(ReplicatedStorage.Utilities.QuadPath)
local DataModifiers = require(ReplicatedStorage.Utilities.DataModifiers)

local WaveComponent = require(script.WaveComponent)
local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)

local Loaded = false

local GameComponent = setmetatable({}, {__index = WaveComponent})

function GameComponent:ChangeHealth(value: number)
	GlobalInfo.Health = value
end

function GameComponent:ChangeWave(value: number)
	GlobalInfo.CurrentWave = value
	print(GlobalInfo.CurrentWave..' Current Wave')
end

function GameComponent:Start()
	self:CreatePath()
	task.spawn(self.LoadWaves, self, self.SelectedLobby)

	SignalComponent:GetSignal('ManageGameBindable', true):Connect(
		function(scope, ...)
			
			if (scope == 'ChangeHealth') then
				self:ChangeHealth(...)
			end
			
			print(GlobalInfo.Health)
		end
	)
end

function GameComponent:CreatePath()
	if (#GlobalInfo.PathPoints > 0) then return end

	for _, pathFolder: Instance in pairs(workspace.Path:GetChildren()) do
		if (not pathFolder:IsA('Folder')) then continue end
		local path = QuadPath.new(pathFolder:GetChildren())
		path:SetupPoints()

		table.insert(GlobalInfo.PathPoints, path.Points)
	end
end

function GameComponent.new(name: string)
	if (Loaded) then warn('Game was already loaded') return end
	if (not LobbiesInfo:FindFirstChild(name)) then warn(name..' Lobby doesnt exist') end

	Loaded = true

	local self = setmetatable({}, {__index = GameComponent})
	self.SelectedLobby = name

	DataModifiers:UpdateTable(GlobalInfo, require(LobbiesInfo:FindFirstChild(name)).Settings)
	GlobalInfo.Loaded = true

	return self
end

return GameComponent
