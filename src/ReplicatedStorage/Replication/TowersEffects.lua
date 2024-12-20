local ReplicatedStorage = game:GetService('ReplicatedStorage')
local EntitiesEffects = require(ReplicatedStorage.Replication.EntitiesEffects)
local RunService = game:GetService('RunService')

local Templates = ReplicatedStorage.Templates
local Enums = require(Templates.Enums)
local TowersInfo = ReplicatedStorage.Info.Towers

type ITowerInfo = typeof(require(Templates.TowerTemplate)())

local ReplicatedTowers = {}

local TowersCache = {}

local function FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then return end --warn(part.Name..' Failed to find '..name);

    return value
end

local function GetTowerInfo(towerName: string, towerLevel: number)
    if (not TowersCache[towerName]) then
        if (not TowersInfo:FindFirstChild(towerName)) then warn(towerName..' Upgrades dont exist') ;return end
        TowersCache[towerName] = require(TowersInfo:FindFirstChild(towerName))
    end

    if (not TowersCache[towerName][towerLevel]) then warn(towerLevel..' for '..towerName..' doesnt exist') return end

    local selectedInfo: ITowerInfo? = TowersCache[towerName][towerLevel]()

    if (not selectedInfo) then warn(towerName..' Info doesnt exist'); return end
    if (not selectedInfo.ModelsFolder) then warn(towerName..' Model doesnt exist'); return end

    return selectedInfo
end

local function createModel(self, selectedInfo, skin)
    if (not skin) then skin = 'Default' end

    if ((not selectedInfo.ModelsFolder:FindFirstChild(skin))) then warn(skin..' skin doesnt exist') end

    self.Model = selectedInfo.ModelsFolder[skin][selectedInfo.Level] :: Model --:Clone()
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

    ['SetAttribute'] = function(id: number, scope: string, value: any)
        local tower = ReplicatedTowers[tostring(id)]
        if (not tower) then return end

        tower[scope] = value
        --[[
        for _, tower in pairs(ReplicatedTowers) do
            if (tower.Instance.Name == name) then return tower end
        end
        ]]
    end,


    ['GetTowerById'] = function(id: number)
        return ReplicatedTowers[tostring(id)]
        --[[
        for _, tower in pairs(ReplicatedTowers) do
            if (tower.Instance.Name == name) then return tower end
        end
        ]]
    end,

    ['Spawn'] = function(packageId: number, id: number, name: string, position: Vector3, skin: string)

        print(packageId, name)

        local self = {
            LevelChange = nil,
            Model = nil,
            Info = nil,
            Cache = nil,
            FXCache = {},
            Attributes = {},
        }

        --local towerLevel = FindAttribute(part, 'Level')
        --local towerName = FindAttribute(part, 'Name')

        local selectedInfo = GetTowerInfo(name, 1)
        self.Info = selectedInfo

        createModel(self, selectedInfo, skin)
        local newId = tostring(Enums.PackageType.Tower)..'-'..tostring(id)

        if (packageId == 0) then
            self.Model = self.Model:Clone()

            self.Model:PivotTo(CFrame.new( position + Vector3.new(0, self.Model:GetExtentsSize().Y/2, 0) ))
            self.Model.PrimaryPart.Anchored = true
            self.Model.Parent = game.Workspace.Towers
        else
            local newInfo = EntitiesEffects.Spawn(packageId, newId, name, self.Model)
            self.Model = newInfo.Model
        end

        pcall(function()
            self.FXCache['AttackAnimation'] = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(self.Info.Animations.Attack)
        end)

        --if (self.Info.Animations.Attack) then end

        local sound = self.Info.Sounds.AttackSound:Clone()
        sound.Parent = self.Model

        self.FXCache['AttackSound'] = sound

        local idle = selectedInfo.Animations.Idle
        if (not idle) then return end
    
        pcall(function()
            local loadedAnimation: AnimationTrack = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
            loadedAnimation.Looped = true
        
            loadedAnimation:Play()
        end)
        
        --[[
        self.LevelChange = part:GetAttributeChangedSignal('Level'):Connect(function()
            towerLevel = FindAttribute(part, 'Level')
            selectedInfo = GetTowerInfo(towerName, towerLevel)
            self.Info = selectedInfo

            self.Model:Destroy()

            createModel(self, selectedInfo, part)
        end)
        ]]

        ReplicatedTowers[tostring(id)] = self
    end,

    ['Remove'] = function(id: number)
        local self = ReplicatedTowers[tostring(id)]
        if (not self) then return end

        if (self.Cache) then self.Cache:Destroy() end
        if (self.LevelChange) then self.LevelChange:Disconnect() end
        --if (self.Model and self.Model.Parent) then self.Model:Destroy() end
        table.clear(self)
        self = nil

        ReplicatedTowers[tostring(id)] = nil
    end

}
