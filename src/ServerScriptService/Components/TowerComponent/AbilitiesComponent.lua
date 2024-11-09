local ServerScriptService = game:GetService('ServerScriptService')
local Components = ServerScriptService.Components

local Cache = {}

local AbilitiesComponent = {}

function AbilitiesComponent:UseAbility(name: string)
    local sessionData = self.Session
    if (not sessionData.Abilities[name]) then return end   

    sessionData.Abilities[name]:Start()
end

function AbilitiesComponent:AppendAbility(name: string, args: {any})
    local sessionData = self.Session
    if (sessionData.Abilities[name]) then return end

	if (not Cache[name]) then
		local module = Components.AbilityComponent:FindFirstChild(name, true)
		if (not module) then return end

		Cache[name] = require(module)
	end

	local ability = Cache[name]()

	ability.Name = name
	ability.Setup(args)

	sessionData.Abilities[name] = ability
end

function AbilitiesComponent:RemoveAbility(name: string)
    local sessionData = self.Session
    if (not sessionData.Abilities[name]) then return end

    sessionData.Abilities[name]:Stop()
    sessionData.Abilities[name] = nil
end

return AbilitiesComponent