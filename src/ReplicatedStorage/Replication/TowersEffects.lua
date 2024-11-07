local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Templates = ReplicatedStorage.Templates
local Info = ReplicatedStorage.Info

local Upgrades = Info.Upgrades

local TowerInfo = require(Info.TowerInfo)

type ITowerInfo = typeof(require(Templates.TowerTemplate)())

local ReplicatedTowers = {}

local Cache = {}

local function FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then warn(part.Name..' Failed to find '..name); return end

    return value
end

local function GetTowerInfo(towerName: string, towerLevel: number)
    if (not Cache[towerName]) then
        if (not Upgrades:FindFirstChild(towerName)) then warn(towerName..' Upgrades dont exist') ;return end
        Cache[towerName] = require(Upgrades:FindFirstChild(towerName))
    end

    local selectedInfo: ITowerInfo? = TowerInfo[towerName]()
    if (towerLevel > 1) then selectedInfo = Cache[towerName][towerLevel]() end

    if (not selectedInfo) then warn(towerName..' Info doesnt exist'); return end
    if (not selectedInfo.Model) then warn(towerName..' Model doesnt exist'); return end

    return selectedInfo
end

local function createModel(self, selectedInfo, part)
    self.Model = selectedInfo.Model:Clone() :: Model
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

    local loadedAnimation: AnimationTrack = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
    loadedAnimation.Looped = true

    loadedAnimation:Play()
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

    ['GetTowerByName'] = function(name: string)
        for _, tower in pairs(ReplicatedTowers) do
            if (tower.Instance.Name == name) then return tower end
        end
    end,

    ['Spawn'] = function(part: BasePart)
        local self = {
            Instance = part,
            LevelChange = nil,
            Model = nil,
            Info = nil,
            Cache = nil
        }

        local towerLevel = FindAttribute(part, 'Level')
        local towerName = FindAttribute(part, 'Name')

        local selectedInfo = GetTowerInfo(towerName, towerLevel)
        self.Info = selectedInfo

        createModel(self, selectedInfo, part)

        self.LevelChange = part:GetAttributeChangedSignal('Level'):Connect(function()
            towerLevel = FindAttribute(part, 'Level')
            selectedInfo = GetTowerInfo(towerName, towerLevel)
            self.Info = selectedInfo

            self.Model:Destroy()

            createModel(self, selectedInfo, part)
        end)

        ReplicatedTowers[part] = self
    end,

    ['Remove'] = function(part: BasePart)
        local self = ReplicatedTowers[part]
        if (not self) then return end

        --if (self.Cache) then self.Cache:Destroy() end
        if (self.LevelChange) then self.LevelChange:Disconnect() end
        if (self.Model and self.Model.Parent) then self.Model:Destroy() end
        table.clear(self)
        self = nil

        ReplicatedTowers[part] = nil
    end

}
