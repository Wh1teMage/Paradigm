local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local SignalFunctions = require(ReplicatedStorage.Components.SignalComponent.CustomFunctions)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)
local PackageTemplate = require(ReplicatedStorage.Templates.PackageTemplate)

local Queue = {}
local ExistingPackages = {}
local CFrames = {}

local PackageComponent = {}
local PackageComponentFabric = {}

local MoveEnemyEvent = ReplicatedStorage.Events.MoveEnemy :: RemoteEvent

local packageCount = 0

function PackageComponent:GetSpeed() -- add self amplifiers
    return self.Speed * self.Game.Info.EnemyAmplifiers.Speed
end

function PackageComponent:Destroy()
	SignalComponent:GetSignal('ManagePackages'):FireAllClients(PathConfig.Scope.DestroyPackage, self.Id)

	ExistingPackages[tostring(self.Id)] = nil
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
    local packageType;

    local count = info.count
    info.count = nil

    for _, obj in pairs(info) do 
        currentGame = obj.Game 
        packageType = obj.PackageType

        --print(obj.Firerate, obj.PackageType, 'created info')

        break
    end

    local track = currentGame.Info.Paths[selectedTrack]

    local self = setmetatable(PackageTemplate(), { __index = PackageComponent })

    self.TrackId = selectedTrack
    self.Track = track
    self.Direction = direction

    self.Speed = speed
    self.CurrentStep = startingPoint

    self.EntityCount = count
    self.Game = currentGame

    self.Entities = info
    self.PackageType = packageType

	local id = 1

	for i = 1, 2^14 do
		if (not ExistingPackages[tostring(i)]) then id = i; break end
	end

    self.Id = id

    task.spawn(function()

        SignalComponent:GetSignal('ManagePackages'):FireAllClients(PathConfig.Scope.ReplicatePackage, self.Id)
        
        task.delay(.1, function()
            for _, entity in pairs(info) do
                if (not getmetatable(entity)) then continue end

                entity.PackageId = id
                entity:ReplicateCreation()
                entity:AppendPassive('PackagePassive', 1, {}, { self })
                --SignalComponent:GetSignal('ManageEnemies'):FireAllClients(PathConfig.Scope.ReplicateEnemy, self.Id, enemy.Id, enemy.Name)
            end
        end)

    end)

    --[[
    for _, enemy in pairs(info) do
        enemy.PackageId = id
    end
    ]]

    packageCount += 1

    ExistingPackages[tostring(id)] = self
end

function PackageComponentFabric:AddToQueue(info)

    local selectedTrack = info[1]
    local direction = info[2]
    local entity = info[3]

    --print(selectedTrack, direction, entity:GetValue('Speed'), entity.CurrentStep)

    local index = selectedTrack..'_'..direction..'_'..entity:GetValue('Speed')..'_'..entity.CurrentStep

    if (not Queue[index]) then Queue[index] = {['count'] = 0} end
    Queue[index][entity.Id] = entity
    Queue[index]['count'] += 1
end

function PackageComponentFabric:FinishQueue()
    
    for data, package in pairs(Queue) do
        PackageComponent.new(string.split(data, '_'), package)
    end

    table.clear(Queue)

end

function PackageComponentFabric:GetPackage(id: number)
    return ExistingPackages[tostring(id)]
end

function PackageComponentFabric:GetPackages()
    return ExistingPackages
end

function PackageComponentFabric:GetPackageCount()
    return packageCount
end


function PackageComponentFabric:GetPackagesInRadius(position: Vector3, radius: number)
	
	local packages = table.create(packageCount)
	
	debug.profilebegin('gettingEnemies')

	for id, package in pairs(ExistingPackages) do
		
		local cframe = package.CFrame
		if (not cframe) then continue end

		local distance = (position - cframe.Position).Magnitude
		if (distance > radius) then continue end

		table.insert(packages, package)
	end

	debug.profileend()
	
	return packages
	
end

return PackageComponentFabric