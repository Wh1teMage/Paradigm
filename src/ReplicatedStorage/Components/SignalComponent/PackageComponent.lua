local RunService = game:GetService('RunService')

local DataTransfer = require(script.Parent.DataTransfer)

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

function PackageComponent:Encode(package)
    local redactedPackage = {}

    for scope, vals in pairs(package) do

        local elementSize = (buffer.len(vals[1][1]) + 2)
        local buff = buffer.create(#vals * elementSize)

        local offset = 0

        for i, val in pairs(vals) do
            buffer.copy(buff, offset, val[1])
            offset += elementSize-2
            buffer.writeu8(buff, offset, val[2])
            offset += 2
        end

        redactedPackage[scope] = { buff, elementSize }
    end
    
    return redactedPackage
end

function PackageComponent:Decode(data, callback: () -> nil)
    for scope, vals in pairs(data) do

        local buff = vals[1]
        local elementSize = vals[2]

        local strLen = buffer.readu8(buff, elementSize-2)

        for i = 0, buffer.len(buff)-1, elementSize do
            local newBuff = buffer.create(elementSize)
            buffer.copy(newBuff, 0, buff, i, elementSize)

            local value = DataTransfer:Decode(newBuff, strLen)

            callback(scope, value)
        end
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