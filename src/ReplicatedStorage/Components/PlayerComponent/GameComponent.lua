local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)
local BezierPath = require(ReplicatedStorage.Utilities.BezierPath)

local GameComponent = {}

function GameComponent:SetupPath()
    
    if (#GlobalInfo.Paths > 0) then return end
    local map = game.Workspace.Map:FindFirstChildWhichIsA('Model') :: Model
        
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

        local points = {}

        for i = 1, 2^12 do
            points[i] = path:CalculateUniformCFrame(i/2^12)
        end
    
        table.insert(GlobalInfo.Paths, points)
    end
    
end

return GameComponent