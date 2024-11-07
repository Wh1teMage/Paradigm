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

--[[
RunService.Stepped:Connect(function()
    
    for _, enemy in pairs(ReplicatedEnemies) do
        if (not enemy.Model) then continue end
        --local finalCFrame = enemy.Instance.CFrame + Vector3.new(0, enemy.Model:GetExtentsSize().Y/2, 0)
        --enemy.Model:PivotTo(enemy.Model:GetPivot():Lerp(finalCFrame, .2))
    end

end)
]]

return {

    ['Spawn'] = function(part: BasePart)
        local self = {
            Instance = part,
            Model = nil
        }

        local enemyName = FindAttribute(part, 'Name')
        if (not EnemiesInfo[enemyName]) then return end

        local selectedInfo = EnemiesInfo[enemyName]()
        --prob include speed, check stats in the original game

        if (not selectedInfo.Model) then return end

        self.Model = selectedInfo.Model:Clone()
        self.Model.Parent = part
        self.Model:PivotTo(part.CFrame + Vector3.new(0, self.Model:GetExtentsSize().Y/2, 0))

        if (not self.Model.PrimaryPart) then warn('PrimaryPart '..self.Model.Name..' doesnt exist'); return end

        local weld = Instance.new('WeldConstraint')
        weld.Part1 = part
        weld.Part0 = self.Model.PrimaryPart
        weld.Parent = part
    
        self.Model.PrimaryPart.Anchored = false    

        local idle = selectedInfo.Animations.Idle
        if (not idle) then return end

        pcall(function() -- Cannot load the AnimationClipProvider Service. error on very fast enemy kill ( fix later )
            local loadedAnimation: AnimationTrack = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
            loadedAnimation.Looped = true
    
            loadedAnimation:Play()
        end)

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
