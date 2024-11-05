local ServerScriptService = game:GetService('ServerScriptService')

local Components = ServerScriptService.Components

local PassiveComponent = require(Components.PassiveComponent)

type IPassiveComponent = typeof(PassiveComponent.new())

local Cache = {}

local PassiveComponent = {}

function PassiveComponent:AppendPassive(name: string, level: number, requirements: {any}, args: {any})
	local sessionData = self.Session

	if (not self:CheckRequirements(requirements)) then return end

	if (not Cache[name]) then
		local module = Components.PassiveComponent:FindFirstChild(name, true)
		if (not module) then return end

		Cache[name] = require(module)
	end

	local passive: IPassiveComponent = Cache[name]()

	passive.Name = name
	passive.Level = level

	passive.TransferData(args)
	passive.Start()

	table.insert(sessionData.Passives, passive)
end

function PassiveComponent:RemovePassive(name: string, level: number)
	local sessionData = self.Session

	for i, passive in pairs(sessionData.Passives) do
		if (passive.Name == name) and (passive.Level == level) then
			passive.Stop()
			table.remove(sessionData.Passives, i)
			break
		end
	end

end

return PassiveComponent
