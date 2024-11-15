local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Components = ServerScriptService.Components

local PlayerComponent = require(Components.PlayerComponent)
local EnemyComponent = require(Components.EnemyComponent)
local EnemyComponentFolder = ServerScriptService.Enemies

local EnemiesCache = {}

--{"AwardCash", 1000},--awardcash type, amount of cash
--{"Spawn", "Normal", 6, 1.2},--zombie, amount, timebetween
--{"Dialogue", "Get ready for a new enemy!", 3},--dialogue type, text, duration
--{"DialogueLink", "SirZeltron"} --name of required module
--{"Wait", 3},
--{"Music", 15914222986, 1, true}, --id, volume, loop
--{"WaitForClear"}, --wait for every zombie killed
--{"StopMusic"},

local parseFunctions = {
	['Music'] = function(component, id: number, volume: number, loop: boolean)

	end,

	['DialogueLink'] = function(component, name: string)

	end,

	['Wait'] = function(component, value: number)
		task.wait(value)
	end,

	['WaitForClear'] = function()

	end,

	['AwardCash'] = function(component, value: number)
		for _, player in pairs(Players:GetChildren()) do
			local component = PlayerComponent:GetPlayer(player)
			if (not component) then continue end
			component:AddAttribute('Cash', value)
		end
	end,
	
	['Dialogue'] = function(component, text: string, duration: number)
		print(text)
		task.wait(duration)
	end,

	['Spawn'] = function(component, name: string, amount: number, between: number)

		print(name, amount, between, component)

		for i = 1, amount do
			if (not EnemyComponentFolder:FindFirstChild(name)) then return end

			if (not EnemiesCache[name]) then 
				EnemiesCache[name] = require(EnemyComponentFolder:FindFirstChild(name))
			end

			local enemy = EnemiesCache[name]()
			enemy:SetCurrentGame(component)
			enemy:StartMoving(math.random(1, #component.Map.Path:GetChildren()))
			
			task.wait(between)
		end
	end,
}

local WaveComponent = {}

function WaveComponent:ParseWave(waveData)
	
	local finished = false

	task.spawn(function()
		for i, v in pairs(waveData) do
			if (self.Info.Health < 0) then continue end
			
			local func = parseFunctions[v[1]]
			if (not func) then continue end
			
			func(self, table.unpack(v, 2))
		end

		finished = true
	end)

	while (not finished) and (not self.Skipped) do task.wait(.1) end

	self.Skipped = false
end

function WaveComponent:Skip()
	self.Skipped = true
end

function WaveComponent:LoadWaves(name: string)
	local selectedWave = self.Waves
	
	self.Skipped = false

	-- add for i = startwave, endwave

	for index, wave in pairs(selectedWave) do
		self:ChangeWave(index)
		if (self.Info.Health < 0) then return end
		self:ParseWave(wave)
	end
	
	if (self.Info.Health < 0) then return end
end

return WaveComponent
