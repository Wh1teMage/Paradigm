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

local currentlyPlaying: {Sound} = {}

local parseFunctions = {
	['StopMusic'] = function()
		while #currentlyPlaying > 0 do
			local sound = table.remove(currentlyPlaying)
			sound:Stop()
			sound:Destroy()
		end
	end,

	['Music'] = function(component, id: number, volume: number, loop: boolean)

		local sound = Instance.new('Sound')
		sound.SoundId = id
		sound.Volume = volume
		sound.Looped = loop

		sound:Play()

		table.insert(currentlyPlaying, sound)
	end,

	['DialogueLink'] = function(component, name: string)

	end,

	['Wait'] = function(component, value: number)
		task.wait(value)
	end,

	['WaitForClear'] = function()
		while #EnemyComponentFolder:GetChildren() > 0 do
			task.wait(.1)
		end
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

		--print(name, amount, between, component)

		local packageAmount = math.floor( (1/30) / math.max(between, 1/120) ) + 1
		local iter = 1

		while iter <= amount do

			local randomPath = math.random(1, #component.Map.Path:GetChildren())

			for i = 1, packageAmount do
				if (not EnemyComponentFolder:FindFirstChild(name)) then return end

				if (not EnemiesCache[name]) then 
					EnemiesCache[name] = require(EnemyComponentFolder:FindFirstChild(name))
				end
	
				local enemy = EnemiesCache[name]()
				enemy:SetCurrentGame(component)
				enemy:StartMoving(randomPath)

				iter += 1
				if iter > amount then break end
			end

			task.wait(between)
		end

		--[[
		local spawnAmount = math.floor( 1/20 / math.max(between, 1/120) ) + 1
		local packageAmount = amount/spawnAmount

		for j = 1, spawnAmount do

			coroutine.wrap(function()
				
				for i = packageAmount*(j-1)+1, packageAmount*j do
					if (not EnemyComponentFolder:FindFirstChild(name)) then return end
		
					if (not EnemiesCache[name]) then 
						EnemiesCache[name] = require(EnemyComponentFolder:FindFirstChild(name))
					end
		
					local enemy = EnemiesCache[name]()
					enemy:SetCurrentGame(component)
					enemy:StartMoving(math.random(1, #component.Map.Path:GetChildren()))
					
					task.wait(between)
				end

			end)()

		end
		]]

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

function WaveComponent:LoadWaves(name: string, startWave: number?)
	local selectedWave = self.Waves

	if (not startWave) then startWave = 1 end
	
	self.Skipped = false

	for index = startWave, #selectedWave do
		local wave = selectedWave[index]

		self:ChangeWave(index)
		if (self.Info.Health < 0) then return end
		self:ParseWave(wave)
	end

	--[[
	for index, wave in pairs(selectedWave) do
		self:ChangeWave(index)
		if (self.Info.Health < 0) then return end
		self:ParseWave(wave)
	end
	]]
	
	if (self.Info.Health < 0) then return end
end

return WaveComponent
