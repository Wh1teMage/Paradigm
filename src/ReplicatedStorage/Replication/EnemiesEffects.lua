local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Templates = ReplicatedStorage.Templates
local Info = ReplicatedStorage.Info

local EnemiesInfo = require(Info.EnemiesInfo)
local GlobalInfo = require(Info.GlobalInfo)
local InstanceUtilities = require(ReplicatedStorage.Utilities.InstanceUtilities)

type ITowerInfo = typeof(require(Templates.EnemyTemplate)())

--[[

]]
local Functions = {}

local ReplicatedPackages = {}
local ReplicatedEnemies = {}
local EnemyAttributes = {}
local SpawnQueue = {}

local Models = {}
local ModelDeltas = {}

local function FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then warn(part.Name..' Failed to find '..name); return end

    return value
end

local enemyCount = 0
local queueCount = 0
local packageCount = 0

local step = 0
local defaultClusterCount = 2

local maxSpawnCount = 200

local clusterCount = defaultClusterCount --defaultClusterCount
local moving = false

local recieveTime = os.clock()

local lastUpdated = os.clock()
local delta = 1/10

RunService.Heartbeat:Connect(function(dt)

    if (moving) then return end
    if (step >= clusterCount) then step = 0 end

    --if (#ReplicatedEnemies < defaultClusterCount) then clusterCount = #ReplicatedEnemies 
    --else clusterCount = defaultClusterCount end

    --clusterCount = (enemyCount//200)+defaultClusterCount

    if (packageCount < defaultClusterCount) then clusterCount = 1 
    else clusterCount = defaultClusterCount end --(enemyCount//500)+

    local clusterSize = packageCount/clusterCount

    moving = true

    local count = 0

    local lerpCFrames = {}
    local parts = {}

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

    local tetha = (os.clock() - lastUpdated)/delta

    local lowerPoint = (clusterSize*step)+1
    local upperPoint = clusterSize*(step+1)

    --print(lowerPoint, upperPoint, clusterCount, enemyCount)

    for id, package in pairs(ReplicatedPackages) do

        count += 1

        if (not package.Part) then continue end
        if (count < lowerPoint) then continue end
        if (count > upperPoint+1) then continue end

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

        --print(enemy.GoalCFrame)

        -- maybe do the same thing with lerps as was done with bezierPath
        local lerp = package.PreviousCFrame:Lerp(package.GoalCFrame, tetha) -- calc step later
        table.insert(lerpCFrames, lerp)
        table.insert(parts, package.Part)
    end

    workspace:BulkMoveTo(parts, lerpCFrames, Enum.BulkMoveMode.FireCFrameChanged)

    table.clear(parts)
    table.clear(lerpCFrames)

    step += 1

    --maxSpawnCount = math.floor( 1/dt ) * 10
    if (1/dt < 30) then task.wait() end

    moving = false

end)

local lastSpawned = {}

local retryTime = 1/5
local entityFilter = {} --15

task.spawn(function()
    
    while task.wait(retryTime) do
        
        --print(SpawnQueue)

        if (enemyCount > maxSpawnCount) then continue end

        for id, enemy in pairs(SpawnQueue) do
            Functions.Spawn(enemy.PackageId, id, enemy.Name, true)
            if (enemyCount > maxSpawnCount) then break end
            task.wait()
        end

    end
    
end)

local clearTime = 1

task.spawn(function()
    while task.wait(3) do

        for name, values in pairs(Models) do
            if ((os.clock() - ModelDeltas[name]) < clearTime) then continue end

            table.clear(values)
        end
        
    end
end)


Functions = {

    ['SetAttribute'] = function(id: number, name: string, value: any)
        if (not EnemyAttributes[id]) then EnemyAttributes[id] = {} end
        EnemyAttributes[id][name] = value
    end,

    ['GetAttribute'] = function(id: number, name: string)
        if (not EnemyAttributes[id]) then EnemyAttributes[id] = {} end
        return EnemyAttributes[id][name]
    end,

    ['DespawnPackage'] = function(packageId: number)
        local package = ReplicatedPackages[packageId]
        if (not package) then return end

        package.Part:Destroy()

        ReplicatedPackages[packageId] = nil
        packageCount -= 1

        table.clear(package)
    end,

    ['SpawnPackage'] = function(packageId: number,  point: number?)
        if (ReplicatedPackages[packageId]) then return end
        --local start = os.clock()
        --while (ReplicatedPackages[packageId] and (os.clock() - start) < 5) do task.wait(.1) end

        local previousCFrame = CFrame.new(0,0,0) + Vector3.new(0,0.01,0)
        local goalCFrame = CFrame.new(0,0,0)

        local part = Instance.new('Part')
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.new(1,1,1)

        local self = {
            PreviousCFrame = previousCFrame,
            GoalCFrame = goalCFrame,
            PathPoint = point or 1,
            Part = part
            --ZOffset = Vector3.new(math.random(-20, 20)/20, 0, math.random(-20, 20)/20),
        }

        if (GlobalInfo.Paths[1]) then
            self.GoalCFrame = GlobalInfo.Paths[1][self.PathPoint]
            self.PreviousCFrame = GlobalInfo.Paths[1][self.PathPoint] + Vector3.new(0, .01, 0)    
        end

        packageCount += 1

        part.Parent = game.Workspace.Enemies

        ReplicatedPackages[packageId] = self
    end,

    ['Spawn'] = function(packageId: number, id: number, name: string, fromQueue: boolean?)
        --if (SpawnQueue[id] or ReplicatedEnemies[id]) then return end

        --[[
        local previousCFrame = CFrame.new(0,0,0) + Vector3.new(0,0.01,0)
        local goalCFrame = CFrame.new(0,0,0)

        if (GlobalInfo.Paths[1]) then
            previousCFrame = GlobalInfo.Paths[1][1] + Vector3.new(0,0.01,0)
            goalCFrame = GlobalInfo.Paths[1][1]
        end
        ]]

        local self = {
            --PreviousCFrame = previousCFrame,
            --GoalCFrame = goalCFrame,
            --PathPoint = point or 1,
            --ZOffset = Vector3.new(math.random(-20, 20)/20, 0, math.random(-20, 20)/20),
            PackageId = packageId,
            Name = name,
            Model = nil
        }

        --if (not lastSpawned[name]) then lastSpawned[name] = os.clock() end
        --entityFilter[name] = math.floor( .1/(os.clock() - lastSpawned[name]) ) + 1

        if (not lastSpawned[name]) then lastSpawned[name] = os.clock() end
        entityFilter[name] = math.floor( .1/(os.clock() - lastSpawned[name]) ) + 1
        lastSpawned[name] = os.clock()
        
        if (entityFilter[name] > 15) then entityFilter[name] = 15 end

        --if (not entityFilter[name]) then entityFilter[name] = 1 end
        if ((queueCount + enemyCount)%entityFilter[name] == 0) then fromQueue = true end
        
        if (not fromQueue) then
            queueCount += 1
            SpawnQueue[id] = self
            return
        end

        if (SpawnQueue[id]) then
            queueCount -= 1
            SpawnQueue[id] = nil
        end

        --print(enemyCount, queueCount)

        --print(entityFilter[name])

        enemyCount += 1

        if (ReplicatedEnemies[id]) then return end

        local package = ReplicatedPackages[packageId]
        if (not package) then return end
        if (not package.Part) then return end
        --if (package.PathPoint > 4093) then Functions.Remove(id); return end

        local enemyName = name
        if (not EnemiesInfo[enemyName]) then return end

        local selectedInfo = EnemiesInfo[enemyName]()
        --prob include speed, check stats in the original game

        if (not selectedInfo.Model) then return end

        if (Models[enemyName] and #Models[enemyName] > 0) then -- less readable for optimization
            self.Model = table.remove(Models[enemyName])
            ModelDeltas[self.Name] = os.clock()
        else
            self.Model = selectedInfo.Model:Clone()
        end

        self.Model.Parent = package.Part

        self.Offset = Vector3.new(0, self.Model:GetExtentsSize().Y/2, 0)

        --[[
        if (GlobalInfo.Paths[1]) then
            self.GoalCFrame = GlobalInfo.Paths[1][self.PathPoint] + self.Offset
            self.PreviousCFrame = GlobalInfo.Paths[1][self.PathPoint] + self.Offset + Vector3.new(0, .01, 0)    
        end
        ]]

        self.Model:PivotTo(package.Part.CFrame + self.Offset)

        if (not self.Model.PrimaryPart) then warn('PrimaryPart '..self.Model.Name..' doesnt exist'); return end
        
        self.Model.PrimaryPart.Anchored = false
        InstanceUtilities:Weld(self.Model.PrimaryPart, package.Part)

        local idle = selectedInfo.Animations.Idle
        if (not idle) then return end

        pcall(function() -- Cannot load the AnimationClipProvider Service. error on very fast enemy kill ( fix later )
            local loadedAnimation: AnimationTrack = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
            loadedAnimation.Looped = true
    
            loadedAnimation:Play()
        end)

        --lastUpdated[id] = os.clock()
        --delta = .1

        ReplicatedEnemies[id] = self
    end,

    ['Remove'] = function(id: number)
        local fromQueue = false

        local self = ReplicatedEnemies[id]
        if (not self) then self = SpawnQueue[id]; fromQueue = true end
        if (not self) then return end

        if (self.Model and self.Model.Parent) then
            self.Model.Parent = nil
            if (not Models[self.Name]) then Models[self.Name] = {} end
            table.insert(Models[self.Name], self.Model)
            ModelDeltas[self.Name] = os.clock()
        end

        table.clear(self)
        self = nil
        
        if (fromQueue) then
            SpawnQueue[id] = nil
            queueCount -= 1
            return
        end

        ReplicatedEnemies[id] = nil
        enemyCount -= 1
    end,

    ['Move'] = function(data)

        for _, decoded in pairs(data) do --{pathPoint, path, id}
            local track = GlobalInfo.Paths[decoded[2]]
            if (not track) then continue end
    
            --local t = decoded[1]/2^12
            local cframe = track[decoded[1]]
            local id = decoded[3]

            local self = ReplicatedPackages[id]
            if (not self) then continue end

            self.PathPoint = decoded[1]
            self.PreviousCFrame = self.GoalCFrame
            self.GoalCFrame = cframe --+ self.Model:GetExtentsSize().Y/2 * Vector3.new(0, 1, 0)
        end

        delta = ((os.clock() - lastUpdated) + delta)/2
        lastUpdated = os.clock()
    end

}

return Functions