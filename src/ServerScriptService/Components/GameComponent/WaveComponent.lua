local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)
local WavesInfo = ReplicatedStorage.Info.Waves
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
	['Music'] = function(id: number, volume: number, loop: boolean)

	end,

	['DialogueLink'] = function(name: string)

	end,

	['Wait'] = function(value: number)
		task.wait(value)
	end,

	['WaitForClear'] = function()

	end,

	['AwardCash'] = function(value: number)
		for _, player in pairs(Players:GetChildren()) do
			local component = PlayerComponent:GetPlayer(player)
			if (not component) then continue end
			component:AddAttribute('Cash', value)
		end
	end,
	
	['Dialogue'] = function(text: string, duration: number)
		print(text)
		task.wait(duration)
	end,

	['Spawn'] = function(name: string, amount: number, between: number)
		for i = 1, amount do
			if (not EnemyComponentFolder:FindFirstChild(name)) then return end

			if (not EnemiesCache[name]) then 
				EnemiesCache[name] = require(EnemyComponentFolder:FindFirstChild(name))
			end

			EnemiesCache[name]()
			
			task.wait(between)
		end
	end,
}

local WaveComponent = {}

function WaveComponent:ParseWave(waveData)
	
	for i, v in pairs(waveData) do
		if (GlobalInfo.Health < 0) then return end
		
		local func = parseFunctions[v[1]]
		if (not func) then return end
		
		func(table.unpack(v, 2))
	end
	
end

function WaveComponent:LoadWaves(name: string)
	if (not WavesInfo:FindFirstChild(name)) then return end
	local selectedWave = require(WavesInfo:FindFirstChild(name))
	
	for index, wave in pairs(selectedWave) do
		self:ChangeWave(index)
		if (GlobalInfo.Health < 0) then return end
		self:ParseWave(wave)
	end
	
	if (GlobalInfo.Health < 0) then return end
	
	
end

return WaveComponent
