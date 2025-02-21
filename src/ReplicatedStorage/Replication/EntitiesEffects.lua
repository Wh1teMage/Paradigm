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
local ReplicatedEntities = {}
--local EnemyAttributes = {}
local SpawnQueue = {}

local Models = {}
local ModelDeltas = {}

local function FindAttribute(part: Part, name: string)
    local value = part:GetAttribute(name)
    if (not value) then warn(part.Name..' Failed to find '..name); return end

    return value
end

local entityCount = 0
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

    --if (#ReplicatedEntities < defaultClusterCount) then clusterCount = #ReplicatedEntities 
    --else clusterCount = defaultClusterCount end

    --clusterCount = (entityCount//200)+defaultClusterCount

    if (packageCount < defaultClusterCount) then clusterCount = 1 
    else clusterCount = defaultClusterCount end --(entityCount//500)+

    local clusterSize = packageCount/clusterCount

    moving = true

    local count = 0

    local lerpCFrames = {}
    local parts = {}

--[[
    for id = (clusterSize*step)+1, clusterSize*(step+1) do
        local enemy = ReplicatedEntities[id]
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

    --print(lowerPoint, upperPoint, clusterCount, entityCount)

    for id, package in pairs(ReplicatedPackages) do

        count += 1

        if (not package.Part) then continue end
        if (count < lowerPoint) then continue end
        if (count > upperPoint+1) then continue end

--[[
        local passed = 0

        for _, closeEnemy in pairs(ReplicatedEntities) do
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

        if (entityCount > maxSpawnCount) then continue end

        for id, enemy in pairs(SpawnQueue) do
            Functions.Spawn(enemy.PackageId, id, enemy.Name, enemy.Model, true)
            if (entityCount > maxSpawnCount) then break end
            task.wait()
        end

    end
    
end)

local clearTime = 1

task.spawn(function()
    while task.wait(3) do

        for name, values in pairs(Models) do
            if ((os.clock() - ModelDeltas[name]) < clearTime) then continue end
            -- add models gc here
            table.clear(values)
        end
        
    end
end)


Functions = {
--[[
    ['SetAttribute'] = function(id: number, name: string, value: any)
        if (not EnemyAttributes[id]) then EnemyAttributes[id] = {} end
        EnemyAttributes[id][name] = value
    end,

    ['GetAttribute'] = function(id: number, name: string)
        if (not EnemyAttributes[id]) then EnemyAttributes[id] = {} end
        return EnemyAttributes[id][name]
    end,
]]

    ['DespawnPackage'] = function(packageId: number)
        local package = ReplicatedPackages[tostring(packageId)]
        if (not package) then return end

        package.Part:Destroy()

        ReplicatedPackages[tostring(packageId)] = nil
        packageCount -= 1

        table.clear(package)
    end,

    ['SpawnPackage'] = function(packageId: number,  point: number?)
        --if (ReplicatedPackages[tostring(packageId)]) then return end
        --local start = os.clock()
        --while (ReplicatedPackages[packageId] and (os.clock() - start) < 5) do task.wait(.1) end

        --print('spawned package', packageId)

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
            Part = part,
            --ZOffset = Vector3.new(math.random(-20, 20)/20, 0, math.random(-20, 20)/20),
        }

        if (GlobalInfo.Paths[1]) then
            self.GoalCFrame = GlobalInfo.Paths[1][self.PathPoint]
            self.PreviousCFrame = GlobalInfo.Paths[1][self.PathPoint] + Vector3.new(0, .01, 0)    
        end

        packageCount += 1

        part.Parent = game.Workspace.Packages

        ReplicatedPackages[tostring(packageId)] = self

        --print(ReplicatedPackages)
    end,

    ['Spawn'] = function(packageId: number, id: string, name: string, model: Model, callback: (model: Model) -> nil, fromQueue: boolean?)
        --if (SpawnQueue[id] or ReplicatedEntities[id]) then return end

        --[[
        local previousCFrame = CFrame.new(0,0,0) + Vector3.new(0,0.01,0)
        local goalCFrame = CFrame.new(0,0,0)

        if (GlobalInfo.Paths[1]) then
            previousCFrame = GlobalInfo.Paths[1][1] + Vector3.new(0,0.01,0)
            goalCFrame = GlobalInfo.Paths[1][1]
        end
        ]]

        local self;
        self = {
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

        if (not lastSpawned[name]) then lastSpawned[name] = 0 end
        entityFilter[name] = math.floor( .1/(os.clock() - lastSpawned[name]) ) + 1
        lastSpawned[name] = os.clock()
        
        if (entityFilter[name] > 15) then entityFilter[name] = 15 end

        --if (not entityFilter[name]) then entityFilter[name] = 1 end
        if ((queueCount + entityCount)%entityFilter[name] == 0) then fromQueue = true end
        
        --print('spawning', fromQueue)

        if (not fromQueue) then
            queueCount += 1
            self.Model = model:Clone()
            SpawnQueue[id] = self
            return self
        end

        if (SpawnQueue[id]) then
            queueCount -= 1
            SpawnQueue[id] = nil
        end

        --print(entityCount, queueCount)

        --print(entityFilter[name])

        entityCount += 1

        if (ReplicatedEntities[id]) then return end

        local package = ReplicatedPackages[tostring(packageId)]

        --print(tostring(packageId), package)

        if (not package) then return end
        if (not package.Part) then return end
        --if (fromQueue and package.PathPoint < 3) then return end
        --if (fromQueue and package.PathPoint > 4093) then return end

        --print(package.PathPoint)

        --[[
        local enemyName = name
        if (not EnemiesInfo[enemyName]) then return end

        local selectedInfo = EnemiesInfo[enemyName]()
        --prob include speed, check stats in the original game

        if (not selectedInfo.Model) then return end
        ]]

        -- to store models in cache (for further reuse)
        if (Models[name] and #Models[name] > 0) then -- less readable for optimization
            self.Model = table.remove(Models[name])
            ModelDeltas[self.Name] = os.clock()
        else
            self.Model = model:Clone()
        end

        --print(self.Model)

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

        callback(self.Model)
        callback = nil
        self.Callback = nil

        ReplicatedEntities[id] = self

        return self

        --if (callback) then callback(self) end

        --[[
        local idle = selectedInfo.Animations.Idle
        if (not idle) then return end

        pcall(function() -- Cannot load the AnimationClipProvider Service. error on very fast enemy kill ( fix later )
            local loadedAnimation: AnimationTrack = self.Model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
            loadedAnimation.Looped = true
    
            loadedAnimation:Play()
        end)
        ]]

        --lastUpdated[id] = os.clock()
        --delta = .1
    end,

    ['GetReplicatedEntities'] = function()
        return ReplicatedEntities
    end,

    ['Remove'] = function(id: string)
        local fromQueue = false

        local self = ReplicatedEntities[id]
        if (not self) then self = SpawnQueue[id]; fromQueue = true end
        if (not self) then return end

        if (self.Model and self.Model.Parent) then
            self.Model.Parent = nil
            if (not Models[self.Name]) then Models[self.Name] = {} end
            table.insert(Models[self.Name], self.Model:Clone())
            ModelDeltas[self.Name] = os.clock()
        end

        table.clear(self)
        self = nil
        
        if (fromQueue) then
            SpawnQueue[id] = nil
            queueCount -= 1
            return
        end

        ReplicatedEntities[id] = nil
        entityCount -= 1
    end,

    ['Move'] = function(data)

        for _, decoded in pairs(data) do --{pathPoint, path, id}
            local track = GlobalInfo.Paths[decoded[2]]
            if (not track) then continue end
    
            --print(decoded[1])

            --local t = decoded[1]/2^12
            local cframe = track[decoded[1]+1]
            local id = tostring(decoded[3])
            local direction = decoded[4]

            local self = ReplicatedPackages[id]
            if (not self) then continue end

            --if (direction < .5) then direction = -1 end

            self.PathPoint = decoded[1]
            self.PreviousCFrame = self.GoalCFrame
            self.GoalCFrame = cframe * CFrame.Angles(0, math.rad(180)*direction, 0)
            --+ self.Model:GetExtentsSize().Y/2 * Vector3.new(0, 1, 0) 
        end

        delta = ((os.clock() - lastUpdated) + delta)/2
        lastUpdated = os.clock()
    end

}

return Functions