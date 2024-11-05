local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Templates = ReplicatedStorage.Templates
local Info = ReplicatedStorage.Info

local Upgrades = Info.Upgrades

local TowerInfo = require(Info.TowerInfo)

type ITowerInfo = typeof(require(Templates.TowerTemplate)())

local ReplicatedTowers = {}

local Cache = {}

local function FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then warn(part..' Failed to find '..value); return end

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

return {

    ['Spawn'] = function(part: BasePart)
        local self = {
            Instance = part,
            LevelChange = nil,
            Model = nil
        }

        local towerLevel = FindAttribute(part, 'Level')
        local towerName = FindAttribute(part, 'Name')

        local selectedInfo = GetTowerInfo(towerName, towerLevel)

        self.Model = selectedInfo.Model:Clone()
        self.Model.Parent = part
        self.Model:PivotTo(part.CFrame) -- add size

        self.LevelChange = part:GetAttributeChangedSignal('Level'):Connect(function()
            towerLevel = FindAttribute(part, 'Level')
            selectedInfo = GetTowerInfo(towerName, towerLevel)

            self.Model:Destroy()

            self.Model = selectedInfo.Model:Clone() -- make into func
            self.Model.Parent = part
            self.Model:PivotTo(part.CFrame) -- add size    
        end)

        ReplicatedTowers[part] = self
    end,

    ['Remove'] = function(part: BasePart)
        local self = ReplicatedTowers[part]
        if (not self) then return end

        if (self.LevelChange) then self.LevelChange:Disconnect() end
        if (self.Model and self.Model.Parent) then self.Model:Destroy() end
        table.clear(self)
        self = nil
    end

}
