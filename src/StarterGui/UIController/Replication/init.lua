local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local StarterGui = game:GetService('StarterGui')

local Components = script.Parent.Parent.Components
local Events = ReplicatedStorage.Events
local Templates = ReplicatedStorage.Templates
local Info = ReplicatedStorage.Info

local ButtonComponent = require(Components.UIButtonComponent)
local PlayerComponent = require(ReplicatedStorage.Components.PlayerComponent) 
local SignalComponent = require(ReplicatedStorage.Components.SignalComponent) 

local PathConfig = require(ReplicatedStorage.Templates.PathConfig) 

local FrameComponent = require(Components.UIFrameComponent) 
local InstanceUtilities = require(ReplicatedStorage.Utilities.InstanceUtilities)
local HotbarController = require(script.HotbarController)
local TowerController = require(script.TowerController)
--[[
local sessionData = {}
local profileData = {}

local currentlySelectedTower = nil
local currentlySelectedPart = nil

local mainUI: typeof(StarterGui.MainUI);

function addFrameToUpgradeInfo(text: {string}, passive: boolean?)
	if (not text) then return end

	local details = mainUI.Upgrade.UpgInfo.Details
	local templates = details.Templates

	if (passive) then
		local frame = templates.Passive:Clone() :: Frame

		frame.TextButton.Text = text[1]

		for i = 2, #text do
			local message = text[i]
			local detail = templates.PassiveDetail:Clone()
			detail.Text = ' • '..message
			detail.Parent = frame
			detail.Visible = true
		end

		frame.Parent = details
		frame.Visible = true

		FrameComponent.new(frame):BindToOpen(function(self)
			self.Size = UDim2.fromScale(0.975, 0.07)
			TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ['Size'] = UDim2.fromScale(0.975, 0.5) }):Play()
		end)

		FrameComponent.new(frame):BindToClose(function(self)
			self.Size = UDim2.fromScale(0.975, 0.5)
			TweenService:Create(self, TweenInfo.new(.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ['Size'] = UDim2.fromScale(0.975, 0.07) }):Play()
		end)

		ButtonComponent.new(frame.TextButton):BindToClick(function()
			FrameComponent.new(frame):Change()
		end)

		return
	end

	for _, message in pairs(text) do
		local detail = templates.Detail:Clone()
		detail.Text = ' '..message
		detail.Parent = details
		detail.Visible = true
	end

end

function startPlacingUI(name: string)
	mainUI.PlacingText.Text = 'Placing '..name
	mainUI.PlacingText.Visible = true
end

function stopPlacingUI()
	mainUI.PlacingText.Visible = false
end

function updateUpgradeUI()
	if (not currentlySelectedPart) then return end
	
	local messages = InstanceUtilities:FindAttribute(currentlySelectedPart, 'Description')
	if (not messages) then messages = nil else messages = string.split( messages, '/' ) end

	local passives = {}

	for i = 1, 10 do
		local passive = InstanceUtilities:FindAttribute(currentlySelectedPart, 'Passive'..i)
		if (not passive) then continue end
		table.insert(passives, string.split( passive, '/' ) )
	end

	for _, obj: Instance in pairs(mainUI.Upgrade.UpgInfo.Details:GetChildren()) do
		if (obj:IsA('Frame') or obj:IsA('TextLabel')) then obj:Destroy() end
	end

	if (#passives < 1) then passives = nil end

	addFrameToUpgradeInfo(messages)
	for i = 1, #passives do
		addFrameToUpgradeInfo(passives[i], true)
	end

	local upgradePrice = InstanceUtilities:FindAttribute(currentlySelectedPart, 'UpgradePrice')
	if (not upgradePrice) then return end
	mainUI.Upgrade.UpgInfo.Upgrade.Price.Text = '$'..upgradePrice
end

function openUpgradeUI()
	FrameComponent.new(mainUI.Upgrade):Open()
	updateUpgradeUI()
end

function closeUpgradeUI()
	FrameComponent.new(mainUI.Upgrade):Close()
end

function manageBaseHealth(value: number)
	local bar: Frame = mainUI.Container.Health.Health
	bar.HP.Text = tostring( value )..' HP'

	local defaultValue = 250
	local percentage = math.clamp(value/defaultValue, 0, 1)

	TweenService:Create(bar.Green, TweenInfo.new(.1, Enum.EasingStyle.Linear), { ['Size'] = UDim2.fromScale(percentage, 1) }):Play()
end

function manageWaveText(value: string)
	local text: TextLabel = mainUI.Container.WaveText
	text.MaxVisibleGraphemes = 0
	text.Text = value

	for i = 1, string.len(value) do
		text.MaxVisibleGraphemes = i
		task.wait(1/20)
	end
end

function managePlayerCash(value: number)
	mainUI.Container.Cash.Cash.Text = '$'..tostring(value)
end

function manageEnemyCount(value: number)
	mainUI.Container.Extras.ZombiesRemaining.Remaining.Text = tostring(value)
end

function managePlayerExp(value: number)
	mainUI.Container.Extras.EXPGain.Text = 'EXP Gained: '..tostring(value)
end

local towerLimit = 60
local towerAmount = 0

function managePlayerLimit(current: number, max: number)
	if (max) then towerLimit = max end
	if (current) then towerAmount = current end

	local limit: TextLabel = mainUI.Towersbg.TextLabel
	limit.Text = tostring(towerAmount)..' / '..tostring(towerLimit)
end

function setupButtons()
	ButtonComponent.new(mainUI.Upgrade.UpgInfo.Upgrade):BindToClick(function()
		if (not currentlySelectedTower) then return end
		SignalComponent:GetSignal('ManageTowersBindable', true):Fire('UpgradeTower')
	end)

	ButtonComponent.new(mainUI.Upgrade.Targetting)

	ButtonComponent.new(mainUI.Upgrade.Sell):BindToClick(function()
		if (not currentlySelectedTower) then return end
		SignalComponent:GetSignal('ManageTowersBindable', true):Fire('SellTower')
		currentlySelectedTower = nil
		currentlySelectedPart = nil
	end)

	--ButtonComponent.new(mainUI.Upgrade.Sell)
	--ButtonComponent.new(mainUI.Upgrade.Sell)

	ButtonComponent.new(mainUI.Upgrade.UpgradeName.arrowLeft)
	ButtonComponent.new(mainUI.Upgrade.UpgradeName.arrowRight)
end
]]
return function(UI: typeof(StarterGui.MainUI))
	local component = PlayerComponent:GetPlayer()
	local replica = component.Replica

	HotbarController(UI, component)
	TowerController(UI, component)
	--[[
	print(replica, component.Replica, component)
	
	mainUI = UI

	
	replica:ListenToChange('Session.Attributes.Health', function()
		setBarValue(values.Health, sessionData.Attributes.Health, sessionData.Attributes.MaxHealth)
	end)
	

	replica:ListenToChange('Session.Attributes.Cash', function(newValue: number)
		managePlayerCash(newValue)
	end)

	replica:ListenToChange('Session.Attributes.TowerAmount', function(newValue: number)
		managePlayerLimit(newValue)
	end)

	replica:ListenToChange('Profile.Values.ExpValue', function(newValue: number)
		managePlayerExp(newValue)
	end)

	managePlayerCash(replica.Data.Session.Attributes.Cash)
	managePlayerExp(replica.Data.Profile.Values.ExpValue)

	SignalComponent:GetSignal('ManageTowersUI', true):Connect(
		function(scope, ...)

			print(scope, ...)

			if (scope == 'StartPlacingUI') then startPlacingUI(...) end
			if (scope == 'StopPlacingUI') then stopPlacingUI() end
			if (scope == 'CloseUpgradeUI') then closeUpgradeUI() end
			if (scope == 'UpdateUpgradeUI') then updateUpgradeUI() end

			if (scope == 'OpenUpgradeUI') then 
				currentlySelectedTower, currentlySelectedPart = ...
				openUpgradeUI()
			end

		end
	)
	
	SignalComponent:GetSignal('ManageTowersUIFromServer'):Connect(
		function(scope, ...)
			if (scope == tostring( PathConfig.Scope.WaveMessage )) then manageWaveText(...) end
			if (scope == tostring( PathConfig.Scope.ChangeBaseHealth )) then manageBaseHealth(...) end
			if (scope == tostring( PathConfig.Scope.ChangeTowerLimit )) then managePlayerLimit(nil, ...) end
			if (scope == tostring( PathConfig.Scope.ReplicateEnemyAmount )) then manageEnemyCount(...) end
		end
	)

	setupButtons()
	]]
end
