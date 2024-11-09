local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local BuffComponent = {}

local Cache = {}

function BuffComponent:AppendBuff(name: string, level: number, args: {any})
	local sessionData = self.Session
    if (sessionData.Buffs[name] and sessionData.Buffs[name].Level <= level) then
        self:RemoveBuff(name)
    end

	if (not Cache[name]) then
		local module = Components.BuffsComponent:FindFirstChild(name, true)
		if (not module) then return end

		Cache[name] = require(module)
	end

	local buff = Cache[name]()

	buff.Name = name
	buff.Level = level

	buff.TransferData(args)
	buff.Start()

	sessionData.Buffs[name] = buff
end

function BuffComponent:RemoveBuff(name: string)
    local sessionData = self.Session
    if (not sessionData.Buffs[name]) then return end

    sessionData.Buffs[name].Stop()
    sessionData.Buffs[name] = nil
end

return BuffComponent