local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')

local ReplicatedComponents = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local PlayerComponent = require(ReplicatedComponents.PlayerComponent)
local ReplicationComponent = require(ReplicatedComponents.ReplicationComponent)

local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)
local BezierPath = require(ReplicatedStorage.Utilities.BezierPath)

ReplicationComponent:Setup()

--[[
if (#GlobalInfo.Paths > 0) then return end
local map = game.Workspace.Map:FindFirstChildWhichIsA('Model')

task.wait(6)

for _, pathFolder: Instance in pairs(map.Path:GetChildren()) do
    if (not pathFolder:IsA('Folder')) then continue end

    local sorted = pathFolder:GetChildren()
    table.sort(sorted, function(a, b) return tonumber(a.Name) > tonumber(b.Name) end)

    local waypoints = {}

    for _, part: Part in pairs(sorted) do
        if (not part:IsA('Part')) then continue end
        table.insert(waypoints, part.Position)
    end

    local path = BezierPath.new(waypoints, 3)

    table.insert(GlobalInfo.Paths, path)
end
]]
