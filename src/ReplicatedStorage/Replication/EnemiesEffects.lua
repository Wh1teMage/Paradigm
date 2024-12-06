local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Templates = ReplicatedStorage.Templates
local Info = ReplicatedStorage.Info

local EnemiesInfo = require(Info.EnemiesInfo)

type ITowerInfo = typeof(require(Templates.EnemyTemplate)())

--[[

]]
local Functions = {}

local ReplicatedEnemies = {}
local SpawnQueue = {}

local function FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then warn(part.Name..' Failed to find '..name); return end

    return value
end

local step = 0
local defaultClusterCount = 4

local clusterCount = defaultClusterCount
local moving = false

local recieveTime = os.clock()

local lastUpdated = {}
local deltas = {}

RunService.Heartbeat:Connect(function(dt)

    if (moving) then return end
    if (step >= clusterCount) then step = 0 end

    if (#ReplicatedEnemies < defaultClusterCount) then clusterCount = #ReplicatedEnemies 
    else clusterCount = defaultClusterCount end

    --defaultClusterCount = (#ReplicatedEnemies//200)+1

    local clusterSize = #ReplicatedEnemies/clusterCount

    moving = true

    local count = 0

    local lerpCFrames = {}
    local parts = {}

    --print(#ReplicatedEnemies)
--[[
    for id = (clusterSize*step)+1, clusterSize*(step+1) do
        local enemy = ReplicatedEnemies[id]
        if (not enemy) then continue end
        if (not enemy.Model) then continue end

        local lerp = enemy.PreviousCFrame:Lerp(enemy.GoalCFrame, tetha) -- calc step later
        table.insert(lerpCFrames, lerp)
        table.insert(parts, enemy.Model.PrimaryPart)
    end
]]

    for id, enemy in pairs(ReplicatedEnemies) do

        count += 1
        if (not enemy.Model) then continue end
        if (count < (clusterSize*step)+1) or (count > clusterSize*(step+1)) then continue end

--[[
        local passed = 0

        for _, closeEnemy in pairs(ReplicatedEnemies) do
            if math.abs(enemy.PathPoint - closeEnemy.PathPoint) < .01 then passed += 1 end
            if passed > 20 then
                Functions.Remove(id)
                break
            end
        end

        if passed > 20 then continue end
]]
        local tetha = (os.clock() - lastUpdated[id])/deltas[id]

        local lerp = enemy.PreviousCFrame:Lerp(enemy.GoalCFrame, tetha) -- calc step later
        table.insert(lerpCFrames, lerp)
        table.insert(parts, enemy.Model.PrimaryPart)
    end
    

    workspace:BulkMoveTo(parts, lerpCFrames, Enum.BulkMoveMode.FireCFrameChanged)

    step += 1

    if (1/dt < 30) then task.wait() end

    moving = false

end)
--[[
local retryTime = 1/20

task.spawn(function()
    
    while task.wait(retryTime) do

        --print(#SpawnQueue)
        
        for id, enemy in pairs(SpawnQueue) do
            local passed = 0

            for _, closeEnemy in pairs(ReplicatedEnemies) do
                if math.abs(enemy.PathPoint - closeEnemy.PathPoint) < .01 then passed += 1 end
                if passed > 10 then break end
            end
    
            if passed > 10 then continue end

            Functions.Spawn(id, enemy.Name, true)

            task.wait()
        end

    end

end)
]]

Functions = {

    ['Spawn'] = function(id: number, name: string, fromQueue: boolean)

        local self = {
            PreviousCFrame = CFrame.new(0,0,0),
            GoalCFrame = CFrame.new(0,0,0),
            PathPoint = 0,
            ZOffset = Vector3.new(math.random(-20, 20)/20, 0, math.random(-20, 20)/20),
            Name = name,
            Model = nil
        }
--[[
        if (not fromQueue) then
            SpawnQueue[id] = self
            return
        end

        SpawnQueue[id] = nil
]]
        local enemyName = name
        if (not EnemiesInfo[enemyName]) then return end

        local selectedInfo = EnemiesInfo[enemyName]()
        --prob include speed, check stats in the original game

        if (not selectedInfo.Model) then return end
        self.Model = selectedInfo.Model:Clone()

        self.Offset = Vector3.new(0, self.Model:GetExtentsSize().Y/2, 0)

        self.Model.Parent = game.Workspace.Enemies
        self.Model:PivotTo(self.GoalCFrame + self.Offset)

        if (not self.Model.PrimaryPart) then warn('PrimaryPart '..self.Model.Name..' doesnt exist'); return end
        
        self.Model.PrimaryPart.Anchored = true    

        local idle = selectedInfo.Animations.Idle
        if (not idle) then return end

        pcall(function() -- Cannot load the AnimationClipProvider Service. error on very fast enemy kill ( fix later )
            local loadedAnimation: AnimationTrack = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
            loadedAnimation.Looped = true
    
            loadedAnimation:Play()
        end)

        lastUpdated[id] = os.clock()
        deltas[id] = .1

        ReplicatedEnemies[id] = self
    end,

    ['Remove'] = function(id: number)
        local self = ReplicatedEnemies[id]
        if (not self) then return end

        if (self.Model and self.Model.Parent) then self.Model:Destroy() end
        table.clear(self)
        self = nil

        ReplicatedEnemies[id] = nil
    end,

    ['Move'] = function(id: number, cframe: CFrame, pathPoint: number, recieveTime: number)
        local self = ReplicatedEnemies[id]
        if (not self) then return end

        self.PreviousCFrame = self.GoalCFrame
        self.GoalCFrame = cframe + self.Offset + cframe.RightVector * self.ZOffset
        self.PathPoint = pathPoint

        deltas[id] = (os.clock() - lastUpdated[id])
        lastUpdated[id] = os.clock()
    end

}

return Functions