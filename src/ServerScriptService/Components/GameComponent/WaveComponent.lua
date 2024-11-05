local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)
local WavesInfo = ReplicatedStorage.Info.Waves
local Components = ServerScriptService.Components

local PlayerComponent = require(Components.PlayerComponent)
local EnemyComponent = Components.EnemyComponent

local EnemiesCache = {}

local parseFunctions = {
	['AwardCash'] = function(value: number)
		for _, player in pairs(Players:GetChildren()) do
			PlayerComponent:GetPlayer(player) -- add money method
		end
	end,
	
	['Dialogue'] = function(text: string, duration: number)
		print(text)
		task.wait(duration)
	end,

	['Spawn'] = function(name: string, amount: number, between: number)
		for i = 1, amount do
			if (not EnemyComponent:FindFirstChild(name)) then return end

			if (not EnemiesCache[name]) then 
				EnemiesCache[name] = require(EnemyComponent:FindFirstChild(name))
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
