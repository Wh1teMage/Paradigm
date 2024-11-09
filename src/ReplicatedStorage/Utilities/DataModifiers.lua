
local compareIgnoreList = {
	'limit',
	'model',
	'equipped',
	'locked',
	'id',
}

local mergeIgnoreList = {
	'Amplifiers',
	'Session',
}

local Functions = {}

function Functions:TableClone(transfer, template)
	local proxy = table.clone(template)
	for index, value in template do
		if typeof(value) == 'table' then

			if typeof(transfer[index]) == 'table' and transfer[index][1] then -- used to check arrays (maybe rewrite later)
				proxy[index] = transfer[index]
				continue
			end

			proxy[index] = Functions:TableClone(transfer, value)
		elseif transfer[index] then
			proxy[index] = transfer[index]
		end
	end
	--print(transfer, proxy)
	return proxy
end

function Functions:TransferTable(target, transfer)
	for index, value in target do
		if typeof(value) == 'table' then

			if value[1] then -- used to check arrays (maybe rewrite later)
				transfer[index] = value
				continue
			end

			Functions:TransferTable(value, transfer)
			--transferValues[index] = TransferTable(value)
		else
			transfer[index] = value
		end
	end

	return transfer
end

function Functions:CompareTables(t1, t2, useIgnore)
	local checks = true
	for index, value in t1 do

		if useIgnore and table.find(compareIgnoreList, index) ~= nil and t2[index] ~= nil then continue end

		if typeof(value) == 'table' and typeof(t2[index]) == 'table' then
			checks = checks and Functions:CompareTables(t1[index], t2[index], useIgnore)
		else
			checks = checks and (value == t2[index])
		end

	end

	return checks
end

function Functions:UpdateTable(origin, template) -- rewrite later
	for i, value in pairs(template) do
		if (table.find(mergeIgnoreList, i)) then continue end
		origin[i] = value
	end
end

function Functions:ConstuctData(target, template)
	return self:TableClone(self:TransferTable(target, {}), template)
end

function Functions:RandomWeight(chances: {{weight: number}}, luck: number)

	local maxweight = 0
	if (not luck) then luck = 1 end
	
	for _, info in pairs(chances) do
		maxweight += info.weight
	end
	
	table.sort(chances, function(n1, n2)
		return n1.weight > n2.weight
	end)

	local chance = math.random(0, maxweight*100)/100/luck
	local currentWeight = maxweight

	for i = 1, #chances do
		currentWeight -= chances[i].weight
		if (chance >= currentWeight) then return chances[i] end
	end

	return chances[0]
end

local NumberSystem = '1234567890qwertyuiop[]asdfghjkl;zxcvbnm,./'

function Functions:GenerateId(length: number)
	local id = ''

	for i = 1, length do
		local index = math.random(1, #NumberSystem)
		id = id..NumberSystem:sub(index, index)
	end

	id = id..tostring(os.time())

	return id
end

return Functions
