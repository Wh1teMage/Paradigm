local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)
local QuadPath = require(ReplicatedStorage.Utilities.QuadPath)

local WaveComponent = require(script.WaveComponent)
local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)

local GameComponent = setmetatable({}, {__index = WaveComponent})

function GameComponent:ChangeHealth(value: number)
	GlobalInfo.Health = value
end

function GameComponent:ChangeWave(value: number)
	GlobalInfo.CurrentWave = value
end

function GameComponent:Start()
	self:CreatePath()
	self:LoadWaves('TestLobby')
	
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
	
	local points = {}
	local newPoints = {}

	for _, part in pairs(workspace.Path:GetChildren()) do
		table.insert(points, part.Position)
		table.insert(newPoints, part.CFrame)
	end
	
	local path = QuadPath.new(workspace.Path:GetChildren())
	path:SetupPoints()
	
	GlobalInfo.PathPoints = path.Points
end

function GameComponent.new()
	local self = setmetatable({}, {__index = GameComponent})
	
	return self
end

return GameComponent
