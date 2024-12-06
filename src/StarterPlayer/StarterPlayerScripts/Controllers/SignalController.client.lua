local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ReplicatedComponents = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local PlayerComponent = require(ReplicatedComponents.PlayerComponent)
local ReplicationComponent = require(ReplicatedComponents.ReplicationComponent)

local PathConfig = require(ReplicatedStorage.Templates.PathConfig)	

local SignalFunctions = require(ReplicatedComponents.SignalComponent.CustomFunctions)

local BezierPath = require(ReplicatedStorage.Utilities.BezierPath)
local GlobalInfo = require(ReplicatedStorage.Info.GlobalInfo)
local EnemiesEffects = require(ReplicatedStorage.Replication.EnemiesEffects)

local MoveEnemyEvent = ReplicatedStorage:WaitForChild('Events'):WaitForChild('MoveEnemy') :: UnreliableRemoteEvent

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

		--print(scope, ...)

		if (tonumber( scope ) == tonumber( PathConfig.Scope.ReplicateEffect )) then
			ReplicationComponent:TriggerEffect(...)
		end

	end
)

SignalComponent:GetSignal('ManageEnemies'):Connect(
	function(scope: string, ...)

		--print(scope, ...)

		if (scope == tostring( PathConfig.Scope.ReplicateEnemy )) then EnemiesEffects.Spawn(...) end
		if (scope == tostring( PathConfig.Scope.DestroyEnemy )) then EnemiesEffects.Remove(...) end

		--print(scope, ...)
	end
)

SignalComponent:GetSignal('ManageGame'):Connect(
	function(scope: string, ...)
		
		--[[
		if (scope == PathConfig.Scope.GameStarted) then -- make this one into some kind of module
			
			if (#GlobalInfo.Paths > 0) then return end
			local map = game.Workspace.Map:FindFirstChildWhichIsA('Model')
		
			for _, pathFolder: Instance in pairs(map.Path:GetChildren()) do
				if (not pathFolder:IsA('Folder')) then continue end
		
				local waypoints = {}
		
				for _, part: Part in pathFolder:GetChildren() do
					if (not part:IsA('Part')) then continue end
					table.insert(waypoints, part.Position)
				end
		
				local path = BezierPath.new(waypoints, 3)
		
				table.insert(GlobalInfo.Paths, path)
			end
			

		end
		]]

	end
)

MoveEnemyEvent.OnClientEvent:Connect(function(data: buffer, amount: number)
	--print(buffer.len(data))
	local result = SignalFunctions.DecodeEnemyMovement(data, amount)

	for _, decoded in pairs(result) do --{pathPoint, path, id}
		local track = GlobalInfo.Paths[decoded[2]]
		if (not track) then continue end

		local t = decoded[1]/2^12
		local cframe = track:CalculateUniformCFrame(t)

		EnemiesEffects.Move(decoded[3], cframe, t, os.clock())
	end

end)