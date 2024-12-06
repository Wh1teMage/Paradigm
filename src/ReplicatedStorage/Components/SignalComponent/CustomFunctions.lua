return {

    ['EncodeEnemyMovement'] = function(info: {{pathPoint: number, path: number, enemyId: number}})
        
        local pathPointBits = 0b0000_1111_1111_1111
        local pathBits = 0b1111_0000_0000_0000

        local buff = buffer.create(4*#info)
        local offset = 0

        for i = 1, #info do
            local currentInfo = info[i]

            local result = 0
            result += bit32.band(currentInfo.pathPoint, pathPointBits)
            result += bit32.band(bit32.lshift(currentInfo.path, 12), pathBits)

            buffer.writeu16(buff, offset, result)
            buffer.writeu16(buff, offset+2, currentInfo.enemyId)
            offset += 4
        end

        return buff, #info
    end,

    ['DecodeEnemyMovement'] = function(buff: buffer, amount: number)

        local result = {}
        local offset = 0

        for i = 1, amount do
            local id = buffer.readu16(buff, offset+2)
            local data = buffer.readu16(buff, offset)
            
            local pathPoint = bit32.extract(data, 0, 12)
            local path = bit32.extract(data, 12, 4)

            offset += 4

            table.insert(result, {pathPoint, path, id})
        end

        return result
    end,

}