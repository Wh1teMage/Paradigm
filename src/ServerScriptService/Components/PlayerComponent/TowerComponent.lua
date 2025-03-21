local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local ReplicatedComponents = ReplicatedStorage.Components
local Components = ServerScriptService.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local TowerFabric = require(Components.TowerComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local Cache = {}

local TowerComponent = {}

function TowerComponent:PlaceTower(position: Vector3, name: string)
	
	local result = workspace:Raycast(position, Vector3.new(0, -1, 0) * 1000)
	if (result) then position = result.Position end
	
	if (not Cache[name]) then
		local info = ServerScriptService.Towers:FindFirstChild(name)
		if (not info) then return end

		Cache[name] = require(info)
	end

	local tower = Cache[name](position)

	local toBeDestroyed = false

	if (self:GetAttribute('Cash') < tower.Price) then toBeDestroyed = true end -- add cash warning
	if (self:GetAttribute('TowerAmount') >= self.Game.Info.TowerLimit) then toBeDestroyed = true end -- add warning

	if (toBeDestroyed) then
		tower:Destroy()
		tower = nil
		toBeDestroyed = nil
		return
	end

	--if (not tower) then return end

	--tower:ReplicateField('Skin', 'Default')
	tower:SetOwner(self)
	--tower:StartMoving(1, 1, -1)
	tower:ReplicateCreation()

	--[[
	local blockingParts = workspace:GetPartBoundsInBox(CFrame.new(position), tower.Hitbox.Size) 
	local canBePlaced = true
	
	for _, part in ipairs(blockingParts) do
		if (part:IsAncestorOf(workspace.Towers)) then canBePlaced = false; break end
	end
	]]
	--if (not canBePlaced) then tower:Destroy() return end
	
	-- money check

	self:AddAttribute('Cash', -tower.Price)

	--print(self.Game)
	
	self:AddAttribute('TowerAmount', 1)

	SignalComponent:GetSignal('ManageTowers'):Fire(PathConfig.Scope.TowerUpdated, self.Instance)
end

function TowerComponent:SellTower(partName: string)
	local tower = TowerFabric:GetTower(partName)
	if (not tower) then return end
	
	self:AddAttribute('Cash', tower.SellPrice)

	tower:Destroy()
	self:AddAttribute('TowerAmount', -1)
end

function TowerComponent:UpgradeTower(partName: string)
	local tower = TowerFabric:GetTower(tostring(partName))
	if (not tower) then return end

	if (self:GetAttribute('Cash') < tower.UpgradePrice) then return end -- add cash warning	
	self:AddAttribute('Cash', -tower.UpgradePrice)

	tower:Upgrade()
	SignalComponent:GetSignal('ManageTowers'):Fire(PathConfig.Scope.TowerUpdated, self.Instance)
end

return TowerComponent
