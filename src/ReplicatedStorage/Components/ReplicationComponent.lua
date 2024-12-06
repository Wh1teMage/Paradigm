local ReplicatedStorage = game:GetService('ReplicatedStorage')

local GlobalEffects = ReplicatedStorage.Replication.Effects

local EnemiesEffects = require(ReplicatedStorage.Replication.EnemiesEffects)
local TowersEffects = require(ReplicatedStorage.Replication.TowersEffects)

local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local EnemiesFolder: Folder = workspace.Enemies
local TowersFolder: Folder = workspace.Towers

local LoadedModules = { EnemiesEffects, TowersEffects }

for index, value in GlobalEffects:GetChildren() do
    table.insert(LoadedModules, require(value))
end

local ReplicationComponent = {}

TowersFolder.ChildAdded:Connect(function(child) -- refactor later
    if (not child:IsA('BasePart')) then return end
    TowersEffects.Spawn(child)
end)

TowersFolder.ChildRemoved:Connect(function(child)
    if (not child:IsA('BasePart')) then return end
    TowersEffects.Remove(child)
end)

--[[
EnemiesFolder.ChildAdded:Connect(function(child)
    if (not child:IsA('BasePart')) then return end
    EnemiesEffects.Spawn(child)
end)

EnemiesFolder.ChildRemoved:Connect(function(child)
    if (not child:IsA('BasePart')) then return end
    EnemiesEffects.Remove(child)
end)
]]

function ReplicationComponent:BindTowers()
	for index, value: Instance in pairs(TowersFolder:GetChildren()) do
        if (not value:IsA('BasePart')) then continue end
        TowersEffects.Spawn(value)
    end
end

function ReplicationComponent:BindEnemies()
	for index, value in pairs(EnemiesFolder:GetChildren()) do
        if (not value:IsA('BasePart')) then continue end
        EnemiesEffects.Spawn(value)
    end
end

function ReplicationComponent:Setup()
    self:BindEnemies()
    self:BindTowers()
end

function ReplicationComponent:TriggerEffect(path: number, ...)
    
    for _, module in pairs(LoadedModules) do
        if (module[path]) then module[path](...) end
    end

    -- if (not EffectsCache[scope]) then
    --     local scopeInstance = GlobalEffects:FindFirstChild(scope)

    --     if (not scopeInstance) then warn(scope..' doesnt exist'); return end
    --     EffectsCache[scope] = require(scopeInstance)
    -- end

    -- if (not EffectsCache[scope][name]) then warn(scope..' '..name..' doesnt exist'); return end

    -- EffectsCache[scope][name](...)

end

return ReplicationComponent
