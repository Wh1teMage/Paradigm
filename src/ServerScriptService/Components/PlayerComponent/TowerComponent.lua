local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ReplicatedComponents = ReplicatedStorage.Components
local Components = ServerScriptService.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local TowerFabric = require(Components.TowerComponent)

local Cache = {}

local TowerComponent = {}

function TowerComponent:PlaceTower(position: Vector3, name: string)
	
	local result = workspace:Raycast(position, Vector3.new(0, -1, 0) * 1000)
	if (result) then position = result.Position end
	
	if (not Cache[name]) then
		local info = Components.TowerComponent:FindFirstChild(name)
		if (not info) then return end

		Cache[name] = require(info)
	end
	
	local tower = Cache[name](position)
	-- set owner
	local blockingParts = workspace:GetPartBoundsInBox(CFrame.new(position), tower.Hitbox.Size) 
	
	local canBePlaced = true
	
	for _, part in ipairs(blockingParts) do
		if (part:IsAncestorOf(workspace.Towers)) then canBePlaced = false; break end
	end
	
	if (not canBePlaced) then tower:Destroy() return end
	
	-- money check
	
	SignalComponent:GetSignal('ManageTowers'):Fire('Selected', self.Instance)
end

function TowerComponent:SellTower(partName: string)
	local tower = TowerFabric:GetTower(partName)
	if (not tower) then return end
	
	tower:Destroy()
end

function TowerComponent:UpgradeTower(partName: string)
	local tower = TowerFabric:GetTower(partName)
	if (not tower) then return end

	tower:Upgrade()
	
	print(tower)
end

return TowerComponent
