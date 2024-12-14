local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local SignalFunctions = require(ReplicatedStorage.Components.SignalComponent.CustomFunctions)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local UPDATE_RATE = 1/10
local PACK_TIME = 1/10

local Queue = {}
local ExistingPackages = {}
local CFrames = {}

local PackageComponent = {}
local PackageComponentFabric = {}

local MoveEnemyEvent = ReplicatedStorage.Events.MoveEnemy :: RemoteEvent

local packageCount = 0

task.spawn(function()
    
    while task.wait(UPDATE_RATE) do

        local package = {}

        while task.wait(UPDATE_RATE) do
    
            table.clear(package)
    
            --SignalComponent:GetSignal('ManageTowersUIFromServer'):FireAllClients(PathConfig.Scope.ReplicateEnemyAmount, enemyCount)
    
            for id, data in pairs(ExistingPackages) do
    
                local length = data.Track:GetPathLength()
    
                data.CurrentStep += (data:GetSpeed()*UPDATE_RATE)/length * data.Direction
                data.CFrame = data.Track:CalculateUniformCFrame(data.CurrentStep)
                data.Distance = data.CurrentStep * length
    
                table.insert(package, {pathPoint = data.CurrentStep*2^12, path = data.TrackId, enemyId = data.Id})
                
                for enemyId, enemy in pairs(data.Enemies) do
                    if ((not enemy.Health) or (enemy.Health <= 0)) then 
                        --table.clear(data.Enemies[enemyId])
                        data.Enemies[enemyId] = nil
                        --data.EnemyCount -= 1
                        continue 
                    end

                    if (data.CurrentStep >= 1) then enemy:CompletedPath(); continue end
                    if (enemy.CanAttack) then enemy:Attack() end

                    enemy.CFrame = data.CFrame
                end
    
                if (data.EnemyCount < 1) then data:Destroy() end
            end
    
            MoveEnemyEvent:FireAllClients(SignalFunctions.EncodeEnemyMovement(package))
            
        end
    end

end)

task.spawn(function()
    
    while task.wait(PACK_TIME) do
        PackageComponentFabric:FinishQueue()
    end

end)

function PackageComponent:GetSpeed() -- add self amplifiers
    return self.Speed * self.Game.Info.EnemyAmplifiers.Speed
end

function PackageComponent:Destroy()
	SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.DestroyPackage, self.Id)

	ExistingPackages[self.Id] = nil
	table.clear(self)
	setmetatable(self, nil)

	packageCount -= 1
end

function PackageComponent.new(data, info)
    
    local selectedTrack = tonumber(data[1])
    local direction = tonumber(data[2])

    local speed = tonumber(data[3])
    local startingPoint = tonumber(data[4])

    local currentGame; --= info[1].Game --! store only enemies ids later on

    local count = info.count
    info.count = nil

    for _, obj in pairs(info) do currentGame = obj.Game; break end
    local track = currentGame.Info.Paths[selectedTrack]

    local self = setmetatable({
        TrackId = selectedTrack,
        Track = track,
        Direction = direction,

        Speed = speed,
        CurrentStep = startingPoint,

        CFrame = CFrame.new(10000, 10000, 10000),
        Distance = 0,
        EnemyCount = count,

        Game = currentGame,
        Enemies = info
    }, { __index = PackageComponent })

	local id = 1

	for i = 1, 2^16 do
		if (not ExistingPackages[i]) then id = i; break end
	end

    self.Id = id

    task.spawn(function()

        SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.ReplicatePackage, self.Id)
        
        for _, enemy in pairs(info) do
            SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.ReplicateEnemy, self.Id, enemy.Id, enemy.Name)
        end

    end)

    for _, enemy in pairs(info) do
        enemy.PackageId = self.Id
    end

    packageCount += 1

    ExistingPackages[id] = self
end

function PackageComponentFabric:AddToQueue(info)

    local selectedTrack = info[1]
    local direction = info[2]
    local enemy = info[3]

    local index = selectedTrack..'_'..direction..'_'..enemy:GetValue('Speed')..'_'..enemy.CurrentStep

    if (not Queue[index]) then Queue[index] = {['count'] = 0} end
    Queue[index][enemy.Id] = enemy
    Queue[index]['count'] += 1
end

function PackageComponentFabric:FinishQueue()
    
    for data, package in pairs(Queue) do
        PackageComponent.new(string.split(data, '_'), package)
    end

    table.clear(Queue)

end

function PackageComponentFabric:GetPackage(id: number)
    return ExistingPackages[id]
end

function PackageComponentFabric:GetPackages()
    return ExistingPackages
end

function PackageComponentFabric:GetPackageCount()
    return packageCount
end

return PackageComponentFabric