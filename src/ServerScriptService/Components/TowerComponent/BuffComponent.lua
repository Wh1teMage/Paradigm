local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local BuffComponent = {}

local Cache = {}

function BuffComponent:AppendBuff(name: string, level: number, args: {any})
	local sessionData = self.Session
	local amount = 1

    if (sessionData.Buffs[name]) then
		if (sessionData.Buffs[name][level]) then 
			sessionData.Buffs[name][level].Amount += 1
			return
		end

		local lastLevel = -1
		for level, _ in pairs(sessionData.Buffs[name]) do lastLevel = level end

		if (lastLevel > -1) then sessionData.Buffs[name][lastLevel].Stop() end
    end

	if (not Cache[name]) then
		local module = Components.BuffsComponent:FindFirstChild(name, true)
		if (not module) then return end

		Cache[name] = require(module)
	end

	local buff = Cache[name]()

	buff.Name = name
	buff.Level = level
	buff.Amount = amount

	buff.TransferData(args)
	buff.Start()

	if (not sessionData.Buffs[name]) then sessionData.Buffs[name] = {} end
	sessionData.Buffs[name][level] = buff
end

function BuffComponent:RemoveBuff(name: string, level: number, args: {any}?)
    local sessionData = self.Session
    if (not sessionData.Buffs[name]) then return end
	if (not sessionData.Buffs[name][level]) then return end
	sessionData.Buffs[name][level].Amount -= 1

	if (sessionData.Buffs[name][level].Amount > 0) then return end

    sessionData.Buffs[name][level].Stop()
    sessionData.Buffs[name][level] = nil

	local lastLevel = -1
	for level, _ in pairs(sessionData.Buffs[name]) do lastLevel = level end

	print(sessionData.Buffs, name, lastLevel)

	if (lastLevel > -1) then
		sessionData.Buffs[name][lastLevel].TransferData(args)
		sessionData.Buffs[name][lastLevel].Start()
	end
end

return BuffComponent