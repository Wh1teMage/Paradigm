local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Components = ServerScriptService.Components

local TowerComponent = require(Components.TowerComponent)
local MovablePackageComponent = require(Components.MovablePackageComponent)

local Enums = require(ReplicatedStorage.Templates.Enums)

local ATTACK_TICK = 1/20
local PASSIVE_TICK = 1

local PACKAGE_SIZE = 30
local UPDATE_RATE = 1/3

task.spawn(function() -- seems nested, refactor later
	while task.wait(ATTACK_TICK) do
		for part, tower in pairs(TowerComponent:GetTowers()) do
			task.spawn(tower.Attack, tower)
		end

		--EnemyComponent:TestFunc()
		--TestFunc
	end
end)

task.spawn(function()
	while task.wait(PASSIVE_TICK) do
		for part, tower in pairs(TowerComponent:GetTowers()) do
			for _, passive in pairs(tower.Session.Passives) do
				passive.OnTick()
			end
		end
	end
end)

task.spawn(function()
	
	while task.wait() do

		local movable = MovablePackageComponent:GetPackages()
		local count = 0

		local start = os.clock()

		--[[
		table.sort(enemies, function(a, b)
			return (a.CurrentStep > b.CurrentStep)
		end)
		]]

		for _, tower in pairs(TowerComponent:GetTowers()) do
			count += 1

			if (count % PACKAGE_SIZE == 0) then
				task.wait() --UPDATE_RATE / (towerCount / PACKAGE_SIZE)
			end

			if (tower.EnemiesInRange) then table.clear(tower.EnemiesInRange) end
			if (not tower.EnemiesInRange) then continue end

			local position = tower.CFrame.Position
			local radius = tower:GetValue('Range')

			local packages = table.create(MovablePackageComponent:GetPackageCount())

			for _, package in pairs(movable) do
                if (package.PackageType ~= Enums.PackageType.Enemy) then continue end

				local cframe = package.CFrame
				if (not cframe) then continue end

				local distance = (position - cframe.Position).Magnitude
				if (distance > radius) then continue end

				table.insert(packages, package) --{ CurrentStep = package.CurrentStep, Id = package.Id }
			end

			tower.EnemiesInRange = packages

			--table.insert(answer, {tower.Name, packages})
		end

		local elapsed = os.clock() - start

		task.wait(UPDATE_RATE - elapsed)

	end

end)