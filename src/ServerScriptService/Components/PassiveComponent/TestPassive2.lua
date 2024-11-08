local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local TowersComponent = require(Components.TowerComponent)
local passive = require(script.Parent)

return function()
	local self = passive.new()
	
	local component;

	local buffedTowers = {}

	local function ClearBuffs()
		for _, tower in pairs(buffedTowers) do
			tower.Amplifiers.Range -= .5
		end

		table.clear(buffedTowers)
	end

	local function ApplyBuffs()
		ClearBuffs()

		for _, tower in pairs(TowersComponent:GetTowers()) do
			if (tower.Hitbox == component.Hitbox) then continue end
			if (tower.Name ~= component.Name) then continue end
			tower.Amplifiers.Range += .5
			table.insert(buffedTowers, tower)
		end
	end

	function self.OnTick()
		ApplyBuffs()
	end

	function self.Start()
		ApplyBuffs()
	end

	function self.Stop()
		ClearBuffs()
	end
	
	function self.TransferData(args: {any})
		component = args[1]
	end
	
	return self
end
