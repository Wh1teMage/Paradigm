local RunService = game:GetService('RunService')

local DataTransfer = require(script.Parent.DataTransfer)

local DELAY_TIME = 1/10
local DELTA_TIME = 1/30

local Packages = {}
local Deltas = {}

local FirstAdded = {}
local disabled = {}

local PackageComponent = {}

PackageComponent.FinishConnections = {}

function PackageComponent:AddToPackage(eventName: string, scope: string, data, player: Player?)
    if (disabled[eventName]) then return end
    if (not Deltas[scope]) then Deltas[scope] = 0 end
    if (not Packages[eventName]) then Packages[eventName] = {}; FirstAdded[eventName] = 0 end

    local delta = os.clock() - Deltas[scope]
    if (Deltas[scope] < 1) then Deltas[scope] = os.clock() end

    if (delta < DELTA_TIME) then
        local newPackage = {}

        if (RunService:IsClient()) then newPackage[eventName] = { [scope] = { data } }
        else newPackage[eventName] = { [player] = { [scope] = { data } } } end

        self.FinishConnections[eventName](newPackage[eventName])
        return
    end

    if (FirstAdded[eventName] <= 0) then

        FirstAdded[eventName] = os.clock()

        task.delay(DELAY_TIME, function()
            self.FinishConnections[eventName](Packages[eventName])
            self:Clear(eventName)
        end)
    end

    if (RunService:IsClient()) then
        if (not Packages[eventName][scope]) then Packages[eventName][scope] = {} end
        table.insert(Packages[eventName][scope], data)
    end

    if (RunService:IsServer()) then
        if (not Packages[eventName][player]) then Packages[eventName][player] = {} end
        if (not Packages[eventName][player][scope]) then Packages[eventName][player][scope] = {} end
        table.insert(Packages[eventName][player][scope], data)
    end
end

function PackageComponent:Encode(package)
    local redactedPackage = {}

    for scope, vals in pairs(package) do

        local sizesOffset = 0
        local overallSize = 0
        local sizesBuffer = buffer.create(4 * #vals)

        for i, val in pairs(vals) do

            local size = buffer.len(val[1]) + 2
            overallSize += size

            if ((sizesOffset == 0) and (buffer.readi16(sizesBuffer, 0) == 0)) then
                buffer.writei16(sizesBuffer, 0, size)
                buffer.writei16(sizesBuffer, 2, 1)
                continue
            end

            if (buffer.readi16(sizesBuffer, sizesOffset) == size) then 
                buffer.writei16(sizesBuffer, sizesOffset+2, buffer.readi16(sizesBuffer, sizesOffset+2)+1); continue
            else 
                sizesOffset += 4
                buffer.writei16(sizesBuffer, sizesOffset, size)
                buffer.writei16(sizesBuffer, sizesOffset+2, buffer.readi16(sizesBuffer, sizesOffset-2)+1)
            end
        end

        local buff = buffer.create(overallSize)

        local offset = 0
        sizesOffset = 0

        for i, val in pairs(vals) do
            if (i > buffer.readi16(sizesBuffer, sizesOffset+2)) then
                sizesOffset += 4
            end

            buffer.copy(buff, offset, val[1])
            offset += buffer.readi16(sizesBuffer, sizesOffset)-2
            buffer.writeu8(buff, offset, val[2])
            offset += 2
        end

        redactedPackage[scope] = { buff, sizesBuffer }
    end
    
    return redactedPackage
end

function PackageComponent:Decode(data, callback: () -> nil)
    for scope, vals in pairs(data) do

        local buff = vals[1]
        local sizesBuffer = vals[2]

        local offset = 0
        local sizesOffset = 0
        local i = 0

        while offset < buffer.len(buff) do
            i += 1;
            if (i > buffer.readi16(sizesBuffer, sizesOffset+2)) then
                sizesOffset += 4
            end

            local elementSize = buffer.readi16(sizesBuffer, sizesOffset)
            local strLen = buffer.readu8(buff, offset+elementSize-2)

            local newBuff = buffer.create(elementSize)
            buffer.copy(newBuff, 0, buff, offset, elementSize)

            offset += elementSize

            local value = DataTransfer:Decode(newBuff, strLen)

            callback(scope, value)
        end

    end
end

function PackageComponent:Clear(eventName: string)
    disabled[eventName] = true
    table.clear(Packages[eventName])
    Packages[eventName] = {}
    FirstAdded[eventName] = 0
    disabled[eventName] = false
end

return PackageComponent