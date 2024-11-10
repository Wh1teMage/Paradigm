local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Components = ServerScriptService.Components

local TowersComponent = require(Components.TowerComponent)
local passive = require(script.Parent)

return function()
	local self = passive.new()
	
	local component;

	local buffedTowers = {}

	local testVal = 0

	local function ClearBuffs()
		for _, tower in pairs(buffedTowers) do
			if (not getmetatable(tower)) then continue end
			tower:RemoveBuff('TestBuff2')
		end

		table.clear(buffedTowers)
	end

	local function ApplyBuffs()
		ClearBuffs()
		
		for _, tower in pairs(TowersComponent:GetTowers()) do
			if (tower.Hitbox == component.Hitbox) then continue end
			if (tower.Name ~= component.Name) then continue end
			tower:AppendBuff('TestBuff2', component.Level, { tower, testVal })
			table.insert(buffedTowers, tower)
		end
	end

	local function ApplyForTower(tower)
		if (tower.Name ~= component.Name) then return end
		tower:AppendBuff('TestBuff2', component.Level, { tower, testVal })
		table.insert(buffedTowers, tower)
	end

	function self.OnUpgrade()
		testVal = .5*component.Level
		ApplyBuffs()
	end

	function self.OnTowerAdded(tower)
		ApplyForTower(tower)
	end

	function self.OnTowerRemoved(tower)
		if (#tower.Session.Passives < 1) then return end 
		-- add check if the tower has the same passive (to update less towers)
		ApplyBuffs()
	end

	function self.Start()
		component:UseAbility('Fireball')
		ApplyBuffs()
	end

	function self.Stop()
		ClearBuffs()
	end
	
	function self.TransferData(args: {any})
		component = args[1]
		testVal = .5
	end
	
	return self
end
