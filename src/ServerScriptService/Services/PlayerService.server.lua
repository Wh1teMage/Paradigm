local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Components = ServerScriptService.Components
local ReplicatedComponents = ReplicatedStorage.Components

local LobbyComponent = require(Components.LobbyComponent)
local PlayerComponent = require(Components.PlayerComponent)
local SignalComponent = require(ReplicatedComponents.SignalComponent)

local PathConfig = require(ReplicatedStorage.Templates.PathConfig)
local EnemyComponent = require(Components.EnemyComponent)

local testGame = LobbyComponent:Survival('TestGame', 'TestModel')

Players.PlayerAdded:Connect(function(player)
	print(player, 123)

	--repeat task.wait(.1); print('Player loading') until GlobalInfo.Loaded

	local component = PlayerComponent:CreatePlayer(player)
	component:SetCurrentGame(testGame)
	testGame:CalculateTowerLimit()

	SignalComponent:GetSignal('ManageGame'):FireAllClients(PathConfig.Scope.GameStarted)

	local start = os.clock()
	local delta = 5

	repeat task.wait(.1) until (component.Session.LoadedClient or (os.clock() - start) > delta)

	print('--  Client Fully Loaded  --')

	EnemyComponent:ReplicateAliveEnemiesForPlayer(player)
	SignalComponent:GetSignal('ManageTowersUIFromServer'):Fire(PathConfig.Scope.ChangeBaseHealth, player, testGame.Info.Health)
	SignalComponent:GetSignal('ManageTowersUIFromServer'):Fire(PathConfig.Scope.WaveMessage, player, 
		'Wave: '..tostring(testGame.Info.CurrentWave) )

	

	-- connect player to the session
	
	--component:AddAttribute('CritChance', 30)
	
	--[[
	for i=1, 100 do
		local item = component:AppendPassiveItem('Default')
		component:EquipItem(item.Id, 10)
	end
	]]
	--[[
	for i=1, 5 do
		local item = component:AppendPassiveItem('Default')
		--component:EquipItem(item.Id, 10)
		task.wait(2)
	end
	]]
	
	--component:AppendPassiveItem('MagicStone')
	--component:AppendPassiveItem('Torch')
	--component:AppendPassiveItem('StaffOfDestiny')
	--component:AppendPassiveItem('IceStaff')
	--component:AppendPassiveItem('GeniusStick')
	
	--for i=1, 5 do
		--component:AppendActiveItem('Default')
		--component:AppendPassiveItem('AmuletOfCorruption')
		--component:EquipItem(item.Id, 10)
	--end
	
	print(component)
end)

Players.PlayerRemoving:Connect(function(player)
	local component = PlayerComponent:GetPlayer(player)
	if (not component) then return end
	component:OnLeft()
end)