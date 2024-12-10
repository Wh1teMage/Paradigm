local Players = game:GetService('Players')
local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerStorage = game:GetService('ServerStorage')


local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)
local GamesInfo = ReplicatedStorage.Info.Games

local QuadPath = require(ReplicatedStorage.Utilities.QuadPath)
local BezierPath = require(ReplicatedStorage.Utilities.BezierPath)
local DataModifiers = require(ReplicatedStorage.Utilities.DataModifiers)

local PathConfig = require(ReplicatedStorage.Templates.PathConfig)
local WaveComponent = require(script.WaveComponent)
local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)

local GameComponent = setmetatable({}, {__index = WaveComponent})

function GameComponent:ChangeHealth(value: number)
	self.Info.Health = value
	SignalComponent:GetSignal('ManageTowersUIFromServer'):FireAllClients(PathConfig.Scope.ChangeBaseHealth, value)
end

function GameComponent:ChangeWave(value: number)
	self.Info.CurrentWave = value
	SignalComponent:GetSignal('ManageTowersUIFromServer'):FireAllClients(PathConfig.Scope.WaveMessage, 'Wave: '..value)
	print(self.Info.CurrentWave..' Current Wave')
end

function GameComponent:CalculateTowerLimit()
	self.Info.TowerLimit = self.Info.DefaultTowerLimit / #Players:GetPlayers()
	SignalComponent:GetSignal('ManageTowersUIFromServer'):FireAllClients(PathConfig.Scope.ChangeTowerLimit, self.Info.TowerLimit)
end

function GameComponent:Start(startWave: number?)
	self:CreatePath()
	task.spawn(self.LoadWaves, self, self.SelectedLobby, startWave)

	SignalComponent:GetSignal('ManageGameBindable', true):Connect(
		function(scope, ...)
			
			if (scope == 'ChangeHealth') then
				self:ChangeHealth(...)
			end
			
			print(self.Info.Health)
		end
	)

	--SignalComponent:GetSignal('ManageGame'):FireAllClients(PathConfig.Scope.GameStarted)
end

function GameComponent:SetupMap(name: string, cframe: CFrame)
	local map = ServerStorage.Maps:FindFirstChild(name)
	if (not map) then return end

	local clonnedMap = map:Clone()
	clonnedMap.Parent = game.Workspace.Map
	clonnedMap:PivotTo(cframe)

	self.Map = clonnedMap
end

function GameComponent:CreatePath()
	if (#self.Info.Paths > 0) then return end

	for _, pathFolder: Instance in pairs(self.Map.Path:GetChildren()) do
		if (not pathFolder:IsA('Folder')) then continue end

		local sorted = pathFolder:GetChildren()
		table.sort(sorted, function(a, b) return tonumber(a.Name) > tonumber(b.Name) end)

		local waypoints = {}

		for _, part: Part in pairs(sorted) do
			if (not part:IsA('Part')) then continue end
			table.insert(waypoints, part.Position)
		end

		local path = BezierPath.new(waypoints, 3)

		table.insert(self.Info.Paths, path)
	end
end

function GameComponent.new(name: string)
	if (not GamesInfo:FindFirstChild(name)) then warn(name..' Lobby doesnt exist') end

	print(GamesInfo:FindFirstChild(name), name)

	local gameInfo = require(GamesInfo:FindFirstChild(name))

	local self = setmetatable({}, {__index = GameComponent})
	self.SelectedLobby = name
	self.Info = DataModifiers:DeepTableClone(GlobalInfo)
	self.Waves = DataModifiers:DeepTableClone(gameInfo.Waves)

	DataModifiers:UpdateTable(self.Info, gameInfo.Settings)
	self.Info.Loaded = true

	return self
end

return GameComponent
