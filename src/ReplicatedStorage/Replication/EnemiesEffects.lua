local ReplicatedStorage = game:GetService('ReplicatedStorage')
local EntitiesEffects = require(ReplicatedStorage.Replication.EntitiesEffects)
local RunService = game:GetService('RunService')

local Templates = ReplicatedStorage.Templates
local Enums = require(Templates.Enums)
local EnemiesInfo = require(ReplicatedStorage.Info.EnemiesInfo)
local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)

type IEnemyInfo = typeof(require(Templates.EnemyTemplate)())

local ReplicatedEnemies = {}

local function FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then return end --warn(part.Name..' Failed to find '..name);

    return value
end

local function GetEnemyInfo(enemyName: string)
    if (not EnemiesInfo[enemyName]) then warn(enemyName..' doesnt exist') return end

    local selectedInfo: IEnemyInfo? = EnemiesInfo[enemyName]()

    if (not selectedInfo) then warn(enemyName..' Info doesnt exist'); return end
    if (not selectedInfo.Model) then warn(enemyName..' Model doesnt exist'); return end

    return selectedInfo
end

local function createModel(self, selectedInfo)
    --if (not skin) then skin = 'Default' end

    --if ((not selectedInfo.ModelsFolder:FindFirstChild(skin))) then warn(skin..' skin doesnt exist') end

    self.Model = selectedInfo.Model --ModelsFolder[skin][selectedInfo.Level] :: Model --:Clone()
    --self.Model:PivotTo(part.CFrame + Vector3.new(0, self.Model:GetExtentsSize().Y/2, 0))

    if (not self.Model.PrimaryPart) then warn('PrimaryPart '..self.Model.Name..' doesnt exist'); return end

    --self.Model.PrimaryPart.Anchored = false

    --[[
    local idle = selectedInfo.Animations.Idle
    if (not idle) then return end

    local loadedAnimation: AnimationTrack = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
    loadedAnimation.Looped = true

    loadedAnimation:Play()
    ]]
end

--[[
RunService.Stepped:Connect(function()
    
    for _, tower in pairs(ReplicatedTowers) do
        if (not tower.Model) then continue end
        --local finalCFrame = tower.Instance.CFrame + Vector3.new(0, tower.Model:GetExtentsSize().Y/2, 0)
        --tower.Model:PivotTo(tower.Model:GetPivot():Lerp(finalCFrame, .2))
    end

end)
]]

return {

    ['GetEnemyById'] = function(id: number)
        return ReplicatedEnemies[tostring(id)]
        --[[
        for _, tower in pairs(ReplicatedTowers) do
            if (tower.Instance.Name == name) then return tower end
        end
        ]]
    end,

    ['Spawn'] = function(packageId: number, id: number, name: string)
        local self = {
            LevelChange = nil,
            Model = nil,
            Info = nil,
            Cache = nil,
            Clonned = false,
        }

        --local towerLevel = FindAttribute(part, 'Level')
        --local towerName = FindAttribute(part, 'Name')

        local selectedInfo = GetEnemyInfo(name, 1)
        self.Info = selectedInfo

        createModel(self, selectedInfo)

        local newId = tostring(Enums.PackageType.Enemy)..'-'..tostring(id)

        local onModelAdded = function(model: Model)
            self.Model = model
            self.Clonned = true

            --print(self.Model, self.Clonned)

            local idle = selectedInfo.Animations.Idle
            if (not idle) then return end
    
            local loadedAnimation: AnimationTrack = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
            loadedAnimation.Looped = true
        
            loadedAnimation:Play()       
    
        end

        EntitiesEffects.Spawn(packageId, newId, name, self.Model, onModelAdded)

        --[[
        self.LevelChange = part:GetAttributeChangedSignal('Level'):Connect(function()
            towerLevel = FindAttribute(part, 'Level')
            selectedInfo = GetTowerInfo(towerName, towerLevel)
            self.Info = selectedInfo

            self.Model:Destroy()

            createModel(self, selectedInfo, part)
        end)
        ]]

        ReplicatedEnemies[tostring(id)] = self
    end,

    ['Remove'] = function(id: number)
        local self = ReplicatedEnemies[tostring(id)]
        if (not self) then return end

        EntitiesEffects.Remove(tostring(Enums.PackageType.Enemy)..'-'..tostring(id))

        if (self.Cache) then self.Cache:Destroy() end
        if (self.LevelChange) then self.LevelChange:Disconnect() end
        --if (self.Model and self.Model.Parent) then self.Model:Destroy() end
        table.clear(self)
        self = nil

        ReplicatedEnemies[tostring(id)] = nil
    end

}
