local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local ReplicatedComponents = ReplicatedStorage.Components

local SignalComponent = require(ReplicatedComponents.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local Templates = ReplicatedStorage.Templates

type IProfileStore = typeof(require(Templates.ProfileStoreTemplate))

local TowersComponent = {}

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include -- or exclude
raycastParams.FilterDescendantsInstances = { workspace.Map }

local selectParams = RaycastParams.new()
selectParams.FilterType = Enum.RaycastFilterType.Include
selectParams.FilterDescendantsInstances = { workspace.Towers }

local camera = workspace.CurrentCamera
local mouse = Players.LocalPlayer:GetMouse()

local createRaycast = function(params: RaycastParams): RaycastResult
	local endPosition = camera:ScreenPointToRay(mouse.X, mouse.Y)

	local ray = workspace:Raycast(endPosition.Origin, endPosition.Direction * 1000, params)

	if (not ray) then return end
	return ray
end

local currentlyPlacing: Part;
local currentlySelected: string;
local currentlySelectedPart: Part;

RunService:BindToRenderStep('TowerPlacement', 10, function()
	if (not currentlyPlacing) then return end
	
	local raycast = createRaycast(raycastParams)
	if (not raycast) then return end
	
	currentlyPlacing.Position = currentlyPlacing.Position:Lerp(raycast.Position, .3)
end)

function TowersComponent:StartPlacing(slot: number)
	if (currentlyPlacing) then self:StopPlacing() end
	
	local profileData: IProfileStore = self.Replica.Data.Profile
	local selectedTower = profileData.EquippedTowers['TowerSlot'..tostring(slot)]

	if (not selectedTower) then return end
	
	currentlySelected = selectedTower
	currentlyPlacing = workspace.Part:Clone()
	currentlyPlacing.Parent = workspace['_ignore']
end

function TowersComponent:StopPlacing()
	if (not currentlyPlacing) then return end

	--print('Stopped Placing')
	currentlyPlacing:Destroy()
	currentlySelected = nil
	currentlyPlacing = nil
end

function TowersComponent:PlaceTower()
	if (not currentlyPlacing) then return end
	
	local raycast = createRaycast(raycastParams)
	if (not raycast) then return end

	SignalComponent:GetSignal('ManageTowers'):Fire(PathConfig.Scope.PlaceTower, raycast.Position, currentlySelected)

	self:StopPlacing()
	
	--SignalComponent:GetSignal('ManageTowers'):Wait('Selected') --!! remove comments for auto selection after placement
	--self:SelectTower()
end

function TowersComponent:SelectTower()
	if (currentlyPlacing) then self:PlaceTower() return end
	
	local raycast = createRaycast(selectParams)
	if (not raycast) then currentlySelected = nil return end
	
	currentlySelected = raycast.Instance.Name
	--print('Selected')
end

function TowersComponent:UpgradeTower()
	if (not currentlySelected) then return end
	
	SignalComponent:GetSignal('ManageTowers'):Fire(PathConfig.Scope.UpgradeTower, currentlySelected)
end

function TowersComponent:SellTower()
	if (not currentlySelected) then return end

	SignalComponent:GetSignal('ManageTowers'):Fire(PathConfig.Scope.SellTower, currentlySelected)
end

return TowersComponent
