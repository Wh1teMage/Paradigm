local RunService = game:GetService('RunService')

local DataTransfer = require(script.Parent.DataTransfer)

local DELAY_TIME = 1/20
local DELTA_TIME = 1/3

local Package = {}
local Deltas = {}

local firstAdded = 0
local disabled = false

local PackageComponent = {}

function PackageComponent:AddToPackage(scope: string, data, player: Player?)
    if (disabled) then return end
    if (not Deltas[scope]) then Deltas[scope] = 0 end

    local delta = os.clock() - Deltas[scope]
    if (Deltas[scope] < 1) then Deltas[scope] = os.clock() end

    if (delta > DELTA_TIME) then
        local newPackage = {}

        if (RunService:IsClient()) then newPackage[scope] = { data }
        else newPackage[player] = { [scope] = { data } } end

        self:Finish(newPackage)
        return
    end

    if (firstAdded < 0) then

        firstAdded = os.clock()

        task.delay(DELAY_TIME, function()
            self:Finish(Package, scope)
            self:Clear(scope)
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