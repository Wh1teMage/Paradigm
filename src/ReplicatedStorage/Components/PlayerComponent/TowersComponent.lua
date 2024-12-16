local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local ReplicatedComponents = ReplicatedStorage.Components

local InstanceUtilities = require(ReplicatedStorage.Utilities.InstanceUtilities)
local SignalComponent = require(ReplicatedComponents.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)

local Templates = ReplicatedStorage.Templates
local TowerSamples = ReplicatedStorage.Samples.TowerModels
local TowersInfo = ReplicatedStorage.Info.Towers

--!! make this module into effects folder (the effects part)

local TowersCache = {}

type IProfileStore = typeof(require(Templates.ProfileStoreTemplate))

local function GetTowerInfo(towerName: string, towerLevel: number)
    if (not TowersCache[towerName]) then
        if (not TowersInfo:FindFirstChild(towerName)) then warn(towerName..' Upgrades dont exist') ;return end
        TowersCache[towerName] = require(TowersInfo:FindFirstChild(towerName))
    end

    if (not TowersCache[towerName][towerLevel]) then warn(towerLevel..' for '..towerName..' doesnt exist') return end

    local selectedInfo = TowersCache[towerName][towerLevel]()

    if (not selectedInfo) then warn(towerName..' Info doesnt exist'); return end
    if (not selectedInfo.ModelsFolder) then warn(towerName..' Model doesnt exist'); return end

    return selectedInfo
end

local function CreateRange(part: Part, radius: number)
	local range = ReplicatedStorage.Samples.Range:Clone() :: Part
	range.Position = part.Position
	range.Transparency = .2
	range.Name = 'Range'
	range.Parent = part

	TweenService:Create(range, TweenInfo.new(.3), { Size = Vector3.new(.1, radius*2, radius*2), Transparency = .6 }):Play()

	return range
end

local function DestroyRange(part: Part)
	local range = part.Range
	range.Parent = workspace['_ignore']
	range.Anchored = true
	TweenService:Create(range, TweenInfo.new(.3), { Size = Vector3.new(.1, .1, .1), Transparency = 1 }):Play()

	task.delay(.3, function()
		if (not range.Parent) then return end
		range:Destroy()
	end)
end

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
local modelOffset: Vector3

RunService:BindToRenderStep('TowerPlacement', 10, function()
	if (not currentlyPlacing) then return end
	
	local raycast = createRaycast(raycastParams)
	if (not raycast) then return end
	
	local unit = (currentlyPlacing.Position - raycast.Position).Unit * math.min( (currentlyPlacing.Position - raycast.Position).Magnitude, 1/5 )
	local model = currentlyPlacing.Model

	currentlyPlacing.CFrame = currentlyPlacing.CFrame:Lerp(CFrame.new( raycast.Position ), .3)
	model.PrimaryPart.CFrame = (currentlyPlacing.CFrame + modelOffset) * CFrame.Angles(unit.Z, 0, -unit.X)
end)

function TowersComponent:StartPlacing(slot: number)
	if (currentlyPlacing) then self:StopPlacing() end
	
	local profileData: IProfileStore = self.Replica.Data.Profile
	local sessionData: IProfileStore = self.Replica.Data.Session 

	local selectedTower = sessionData.EquippedTowers['TowerSlot'..tostring(slot)]

	if (not selectedTower) then return end

	local selectedSkin = ''

	for _, info in pairs(profileData.OwnedTowers) do
		if (info.Name == selectedTower) then selectedSkin = info.Skin; break end
	end

	if (selectedSkin == '') then selectedSkin = 'Default' end
	if (not TowerSamples:FindFirstChild(selectedTower)) then return end
	if (not TowerSamples:FindFirstChild(selectedTower):FindFirstChild(selectedSkin)) then return end
	
	currentlyPlacing = ReplicatedStorage.Samples.TowerPart:Clone()

	local model = TowerSamples[selectedTower][selectedSkin][1]:Clone() :: Model
	model.Name = 'Model'
	model.Parent = currentlyPlacing

	modelOffset = Vector3.new(0, model:GetExtentsSize().Y/2, 0)
    model:PivotTo(currentlyPlacing.CFrame + modelOffset)

    if (not model.PrimaryPart) then warn('PrimaryPart '..model.Name..' doesnt exist'); return end

    model.PrimaryPart.Anchored = true

	local selectedInfo = GetTowerInfo(selectedTower, 1)
	local range = CreateRange(currentlyPlacing, selectedInfo.Range)

	InstanceUtilities:Weld(currentlyPlacing, range)
	range.Anchored = false

	currentlySelected = selectedTower
	currentlyPlacing.Parent = workspace['_ignore']

	local raycast = createRaycast(raycastParams)
	if (not raycast) then return end
	
	currentlyPlacing.CFrame = CFrame.new(raycast.Position)
	model.PrimaryPart.CFrame = currentlyPlacing.CFrame

	SignalComponent:GetSignal('ManageTowersUI', true):Fire('StartPlacingUI', selectedTower)

	local idle = selectedInfo.Animations.Idle
    if (not idle) then return end

    local loadedAnimation: AnimationTrack = model.AnimationController:FindFirstChildWhichIsA('Animator'):LoadAnimation(idle)
    loadedAnimation.Looped = true

    loadedAnimation:Play()

	selectedInfo = nil
end

function TowersComponent:StopPlacing()
	if (not currentlyPlacing) then return end

	SignalComponent:GetSignal('ManageTowersUI', true):Fire('StopPlacingUI')
	DestroyRange(currentlyPlacing)
	--print('Stopped Placing')
	currentlyPlacing:Destroy()
	currentlySelected = nil
	currentlyPlacing = nil
end

function TowersComponent:PlaceTower()
	if (not currentlyPlacing) then return end
	
	local raycast = createRaycast(raycastParams)
	if (not raycast) then return end

	for i = 1, 35 do
		SignalComponent:GetSignal('ManageTowers'):Fire(PathConfig.Scope.PlaceTower, raycast.Position 
		 + Vector3.new(math.random(-100, 100)/100*2, 0, math.random(-100, 100)/100*2), currentlySelected)
	end

	self:StopPlacing()
	
	--SignalComponent:GetSignal('ManageTowers'):Wait('Selected') --!! remove comments for auto selection after placement
	--self:SelectTower()
end

function TowersComponent:SelectTower()
	if (currentlyPlacing) then self:PlaceTower() return end
	
	local raycast = createRaycast(selectParams)
	
	if (currentlySelectedPart) then
		DestroyRange(currentlySelectedPart)
		currentlySelectedPart = nil
		SignalComponent:GetSignal('ManageTowersUI', true):Fire('CloseUpgradeUI')
	end
	
	if (not raycast) then 
		currentlySelected = nil 
		SignalComponent:GetSignal('ManageTowersUI', true):Fire('CloseUpgradeUI')
		return 
	end

	currentlySelectedPart = raycast.Instance:FindFirstAncestorWhichIsA('Part')
	currentlySelected = currentlySelectedPart.Name

	SignalComponent:GetSignal('ManageTowersUI', true):Fire('OpenUpgradeUI', currentlySelected, currentlySelectedPart)

	CreateRange(currentlySelectedPart, InstanceUtilities:FindAttribute(currentlySelectedPart, 'Range'))
end

function TowersComponent:UpgradeTower()
	if (not currentlySelected) then return end
	
	SignalComponent:GetSignal('ManageTowers'):Fire(PathConfig.Scope.UpgradeTower, currentlySelected) -- use promise there
	print('sent promise')
	local promise;

	promise = SignalComponent:GetSignal('ManageTowers'):Connect(function(scope)
		if (scope ~= tostring( PathConfig.Scope.TowerUpdated )) then return end
		print('recieved promise')
		SignalComponent:GetSignal('ManageTowersUI', true):Fire('UpdateUpgradeUI')
		promise:Disconnect()
	end)

	task.delay(5, function() if (getmetatable(promise)) then promise:Disconnect() end end)
end

function TowersComponent:SellTower()
	if (not currentlySelected) then return end

	SignalComponent:GetSignal('ManageTowers'):Fire(PathConfig.Scope.SellTower, currentlySelected)
	SignalComponent:GetSignal('ManageTowersUI', true):Fire('CloseUpgradeUI')

	currentlySelected = nil 
	currentlySelectedPart = nil
end

return TowersComponent
