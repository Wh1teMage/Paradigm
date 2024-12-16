local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ReplicatedComponents = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local PlayerComponent = require(ReplicatedComponents.PlayerComponent)
local GameComponent = require(ReplicatedComponents.PlayerComponent.GameComponent)

local ReplicationComponent = require(ReplicatedComponents.ReplicationComponent)

local PathConfig = require(ReplicatedStorage.Templates.PathConfig)	

local SignalFunctions = require(ReplicatedComponents.SignalComponent.CustomFunctions)

local BezierPath = require(ReplicatedStorage.Utilities.BezierPath)
local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)

local TowersEffects = require(ReplicatedStorage.Replication.TowersEffects)
local EnemiesEffects = require(ReplicatedStorage.Replication.EnemiesEffects)
local EntitiesEffects = require(ReplicatedStorage.Replication.EntitiesEffects)


local MoveEnemyEvent = ReplicatedStorage:WaitForChild('Events'):WaitForChild('MoveEnemy') :: RemoteEvent

local Component = PlayerComponent:GetPlayer()

SignalComponent:GetSignal('ManageTowersBindable', true):Connect(
	function(scope: string, ...)
		if (scope == 'StartPlacing') then Component:StartPlacing(...) end
		if (scope == 'SelectTower') then Component:SelectTower() end
		if (scope == 'StopPlacing') then Component:StopPlacing() end
		if (scope == 'UpgradeTower') then Component:UpgradeTower() end
		if (scope == 'SellTower') then Component:SellTower() end
	end
)

SignalComponent:GetSignal('ManageEffects'):Connect(
	function(scope: number, ...)

		if (tonumber( scope ) == tonumber( PathConfig.Scope.ReplicateEffect )) then
			ReplicationComponent:TriggerEffect(...)
		end

	end
)

SignalComponent:GetSignal('ManageEnemies'):Connect(
	function(scope: string, ...)

		--if (scope == tostring( PathConfig.Scope.DestroyPackage )) then EnemiesEffects.DespawnPackage(...) end
		--if (scope == tostring( PathConfig.Scope.ReplicatePackage )) then EnemiesEffects.SpawnPackage(...) end
		if (scope == tostring( PathConfig.Scope.ReplicateEnemy )) then EnemiesEffects.Spawn(...) end
		if (scope == tostring( PathConfig.Scope.DestroyEnemy )) then EnemiesEffects.Remove(...) end
		if (scope == tostring( PathConfig.Scope.ReplicateAttributes )) then EnemiesEffects.SetAttribute(...) end

		--print(scope, ...)
	end
)

SignalComponent:GetSignal('ManageTowers'):Connect(
	function(scope: string, ...)

		scope = tostring( scope )

		--if (scope == tostring( PathConfig.Scope.DestroyPackage )) then EnemiesEffects.DespawnPackage(...) end
		--if (scope == tostring( PathConfig.Scope.ReplicatePackage )) then EnemiesEffects.SpawnPackage(...) end
		if (scope == tostring( PathConfig.Scope.PlaceTower )) then TowersEffects.Spawn(...) end
		if (scope == tostring( PathConfig.Scope.SellTower )) then TowersEffects.Remove(...) end
		if (scope == tostring( PathConfig.Scope.ReplicateAttributes )) then TowersEffects.SetAttribute(...) end

		--print(scope, ...)
	end
)


SignalComponent:GetSignal('ManagePackages'):Connect(
	function(scope: string, ...)

		--print(scope, ...)

		if (scope == tostring( PathConfig.Scope.DestroyPackage )) then EntitiesEffects.DespawnPackage(...) end
		if (scope == tostring( PathConfig.Scope.ReplicatePackage )) then EntitiesEffects.SpawnPackage(...) end
		--if (scope == tostring( PathConfig.Scope.ReplicateEnemy )) then EnemiesEffects.Spawn(...) end
		--if (scope == tostring( PathConfig.Scope.DestroyEnemy )) then EnemiesEffects.Remove(...) end
		--if (scope == tostring( PathConfig.Scope.ReplicateAttributes )) then EnemiesEffects.SetAttribute(...) end

		--print(scope, ...)
	end
)

SignalComponent:GetSignal('ManageGame'):Connect(
	function(scope: string, ...)
		
		print('Starting game on client')

		if (scope == tostring( PathConfig.Scope.GameStarted )) then
			GameComponent:SetupPath()
			SignalComponent:GetSignal('ManageGame'):Fire(PathConfig.Scope.GameStarted)
		end

	end
)

MoveEnemyEvent.OnClientEvent:Connect(function(data: buffer, amount: number)
	--print(buffer.len(data))
	
    if (#GlobalInfo.Paths < 1) then return end
	local result = SignalFunctions.DecodeEnemyMovement(data, amount)

	EntitiesEffects.Move(result)
	--ReplicationComponent:TriggerEffect('Move', result)

end)