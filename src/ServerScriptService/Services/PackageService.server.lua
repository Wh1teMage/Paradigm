local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local MovablePackageComponent = require(Components.MovablePackageComponent)
local SignalFunctions = require(ReplicatedStorage.Components.SignalComponent.CustomFunctions)

local MoveEnemyEvent = ReplicatedStorage.Events.MoveEnemy :: RemoteEvent

local UPDATE_RATE = 1/10
local PACK_TIME = 1/10

task.spawn(function()
    
    while task.wait(PACK_TIME) do
        MovablePackageComponent:FinishQueue()
    end

end)

task.spawn(function()
    local package = {}

    while task.wait(UPDATE_RATE) do

        table.clear(package)

        --SignalComponent:GetSignal('ManageTowersUIFromServer'):FireAllClients(PathConfig.Scope.ReplicateEnemyAmount, enemyCount)

        for id, data in pairs(MovablePackageComponent:GetPackages()) do
            if (not data.EntityCount) then continue end

            local length = data.Track:GetPathLength()

            data.CurrentStep += (data:GetSpeed()*UPDATE_RATE)/length * data.Direction
            data.CFrame = data.Track:CalculateUniformCFrame(data.CurrentStep)
            data.Distance = data.CurrentStep * length

            table.insert(package, {pathPoint = data.CurrentStep*2^12, path = data.TrackId, packageId = data.Id, packageDirection = data.Direction})
            
            for enemyId, entity in pairs(data.Entities) do

                if (not entity.PackageId) then continue end

                entity.CFrame = data.CFrame

                if (data.Direction < 0 and data.CurrentStep <= 0) then entity:Destroy(); continue end
                if (data.Direction > 0 and data.CurrentStep >= 1) then entity:CompletedPath(); continue end
                if (entity.CanAttack) then entity:Attack() end

            end

            if (not data.EntityCount) then continue end
            if (data.EntityCount < 1) then data:Destroy() end
        end

        MoveEnemyEvent:FireAllClients(SignalFunctions.EncodeEnemyMovement(package))
        
    end

end)