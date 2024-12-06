return {

    ['EncodeEnemyMovement'] = function(pathPoint: number, path: number, enemyId: number)
        
        local pathPointBits = 0b0000_1111_1111_1111
        local pathBits = 0b1111_0000_0000_0000

        local result = 0
        result += bit32.band(pathPoint, pathPointBits)
        result += bit32.band(bit32.lshift(path, 12), pathBits)

        local buff = buffer.create(4*10)

        local offset = 0

        for i = 1, 10 do
            buffer.writeu16(buff, offset, result)
            buffer.writeu16(buff, offset+2, enemyId)
            offset += 4
        end

        return buff
    end,

    ['DecodeEnemyMovement'] = function(buff: buffer)
        --[[
        local id = buffer.readu16(buff, 2)
        local data = buffer.readu16(buff, 0)
        
        local pathPoint = bit32.extract(data, 0, 12)
        local path = bit32.extract(data, 12, 4)

        return pathPoint, path, id
        ]]
    end,

}