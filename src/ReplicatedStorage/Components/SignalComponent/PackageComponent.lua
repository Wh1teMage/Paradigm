local RunService = game:GetService('RunService')

local DELAY_TIME = 1/20

local Package = {}

local firstAdded = 0
local disabled = false

local PackageComponent = {}

function PackageComponent:AddToPackage(scope: string, data, player: Player?)
    if (disabled) then return end

    if (firstAdded < 1) then
        firstAdded = os.clock()
        task.delay(DELAY_TIME, function()
            --print(Package)

            self:Finish(Package)
            self:Clear()
        end)
    end

    if (RunService:IsClient()) then
        if (not Package[scope]) then Package[scope] = {} end
        table.insert(Package[scope], data)
    end

    if (RunService:IsServer()) then
        if (not Package[player]) then Package[player] = {} end
        if (not Package[player][scope]) then Package[player][scope] = {} end
        table.insert(Package[player][scope], data)
    end
end

function PackageComponent:Finish()
    
end

function PackageComponent:Clear()
    disabled = true
    table.clear(Package)
    Package = {}
    firstAdded = 0
    disabled = false
end

return PackageComponent