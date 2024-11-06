local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Templates = ReplicatedStorage.Templates
local Info = ReplicatedStorage.Info

local EnemiesInfo = require(Info.EnemiesInfo)

type ITowerInfo = typeof(require(Templates.EnemyTemplate)())

--[[

]]
local ReplicatedEnemies = {}

local function FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then warn(part.Name..' Failed to find '..name); return end

    return value
end


RunService.Stepped:Connect(function()
    
    for _, enemy in pairs(ReplicatedEnemies) do
        if (not enemy.Model) then continue end
        enemy.Model:PivotTo(enemy.Instance.CFrame)
    end

end)

return {

    ['Spawn'] = function(part: BasePart)
        local self = {
            Instance = part,
            Model = nil
        }

        local enemyName = FindAttribute(part, 'Name')
        --prob include speed, check stats in the original game

        if (not EnemiesInfo[enemyName]) then return end
        if (not EnemiesInfo[enemyName].Model) then return end

        self.Model = EnemiesInfo[enemyName].Model:Clone()
        self.Model.Parent = part
        self.Model:PivotTo(part.CFrame)

        ReplicatedEnemies[part] = self
    end,

    ['Remove'] = function(part: BasePart)
        local self = ReplicatedEnemies[part]
        if (not self) then return end

        if (self.Model and self.Model.Parent) then self.Model:Destroy() end
        table.clear(self)
        self = nil

        ReplicatedEnemies[part] = nil
    end

}
