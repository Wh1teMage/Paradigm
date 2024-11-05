local HttpService = game:GetService('HttpService')

local SPECIAL_SYMBOL = 'é'

local function deepTableFunction(map: {[any]: any}, callback: () -> ())

	for index, val in pairs(map) do
		callback(val, index, map)
		if type(val) == "table" then
			map[index] = table.clone(val)
			deepTableFunction(map[index], callback)
		end
	end
	
end

local writeFunctions;
writeFunctions = {
	['Vector3'] = function(val: Vector3, array)
		table.insert(array, {val.X, 4, 'f'})
		table.insert(array, {val.Y, 4, 'f'})
		table.insert(array, {val.Z, 4, 'f'})
		
		return SPECIAL_SYMBOL..'v'
	end,
	
	['number'] = function(val: number, array)
		local selected = 2
		local symbol = 'n'
		
		if (val > 32768) then selected = 4; symbol = 'i' end
		if (math.fmod(val, 1) > 0.01) then selected = 4; symbol = 'f' end
		
		table.insert(array, {val, selected, symbol})
		
		return SPECIAL_SYMBOL..symbol
	end,
	
	['CFrame'] = function(val: CFrame, array)
		local x, y, z = val.X, val.Y, val.Z

		local axis, angle = val:ToAxisAngle()
		local rx, ry, rz = axis.X, axis.Y, axis.Z

		table.insert(array, {x, 4, 'f'})
		table.insert(array, {y, 4, 'f'})
		table.insert(array, {z, 4, 'f'})
		
		table.insert(array, {rx, 4, 'f'})
		table.insert(array, {ry, 4, 'f'})
		table.insert(array, {rz, 4, 'f'})
		
		table.insert(array, {angle, 4, 'f'})
		
		return SPECIAL_SYMBOL..'c'
	end,
}

local readFunctions;
readFunctions = {
	[SPECIAL_SYMBOL..'v'] = function(offsetm: {number}, buff: buffer)
		local vector = Vector3.new(
			buffer.readf32(buff, offsetm[1]),
			buffer.readf32(buff, offsetm[1]+4),
			buffer.readf32(buff, offsetm[1]+8)
		)
		
		offsetm[1] += 12

		return vector
	end,
	
	[SPECIAL_SYMBOL..'c'] = function(offsetm: {number}, buff: buffer)
		local x = buffer.readf32(buff, offsetm[1])
		local y = buffer.readf32(buff, offsetm[1] + 4)
		local z = buffer.readf32(buff, offsetm[1] + 8)
		local rx = buffer.readf32(buff, offsetm[1] + 12)
		local ry = buffer.readf32(buff, offsetm[1] + 16)
		local rz = buffer.readf32(buff, offsetm[1] + 20)
		local angle = buffer.readf32(buff, offsetm[1] + 24)

		local axis = Vector3.new(rx, ry, rz)

		offsetm[1] += 28

		return CFrame.fromAxisAngle(axis, angle) + Vector3.new(x, y, z)
	end,

	[SPECIAL_SYMBOL..'n'] = function(offsetm: {number}, buff: buffer)
		local val = buffer.readi16(buff, offsetm[1])
		offsetm[1] += 2
		return val
	end,
	
	[SPECIAL_SYMBOL..'i'] = function(offsetm: {number}, buff: buffer)
		local val = buffer.readi32(buff, offsetm[1])
		offsetm[1] += 4
		return val
	end,
	
	[SPECIAL_SYMBOL..'f'] = function(offsetm: {number}, buff: buffer)
		local val = buffer.readf32(buff, offsetm[1])
		offsetm[1] += 4
		return val
	end,

}

local DataTransfer = {}

function DataTransfer:Encode(val: {[any]: any})
	local nums = {}
	local clonned = table.clone(val)
	
	deepTableFunction(clonned, 
		function(v, i, t)
			if (not writeFunctions[typeof(v)]) then return end
			t[i] = writeFunctions[typeof(v)](v, nums)
		end
	)
	
	local redactedString = HttpService:JSONEncode(clonned)
	local additional = 0
	
	for i = 1, #nums do
		additional += nums[i][2]
	end
	
	local offset = string.len(redactedString)
	local buff = buffer.create(offset+additional)
	buffer.writestring(buff, 0, redactedString)
	
	for i = 1, #nums do
		
		local val = nums[i][1]
		local add = nums[i][2]
		local btype = nums[i][3]
		
		if (btype == 'n') then buffer.writei16(buff, offset, val)
		elseif (btype == 'i') then buffer.writei32(buff, offset, val)
		else buffer.writef32(buff, offset, val) end
		
		offset += add
	end
	
	clonned = nil
	
	return buff, string.len(redactedString)
end

function DataTransfer:Decode(buff: buffer, strLen: number)
	local offsetm = {strLen}
	local str = buffer.readstring(buff, 0, strLen)
	
	local map = HttpService:JSONDecode(str)
	
	deepTableFunction(map, function(val, index, nmap)
		if (typeof(val) ~= 'string') then return end
		if (not readFunctions[val]) then return end
		nmap[index] = readFunctions[val](offsetm, buff)
	end)
	
	return map
end

return DataTransfer
