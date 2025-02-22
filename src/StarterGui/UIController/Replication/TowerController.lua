local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')

local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local Components = script:FindFirstAncestorWhichIsA('Player').PlayerGui.Components

local FrameComponent = require(Components.UIFrameComponent) 
local ButtonComponent = require(Components.UIButtonComponent)
local InstanceUtilities = require(ReplicatedStorage.Utilities.InstanceUtilities)

local mainUI;

local currentlySelectedTower = nil
local selectedTowerInfo = nil

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
	if (not selectedTowerInfo) then return end
	
	local messages = selectedTowerInfo['Description']
	if (not messages) then messages = nil else messages = string.split( messages, '/' ) end

	local passives = {}

	for i = 1, 10 do
		local passive = selectedTowerInfo['Passive'..i]
		if (not passive) then continue end
		table.insert(passives, string.split( passive, '/' ) )
	end

	for _, obj: Instance in pairs(mainUI.Upgrade.UpgInfo.Details:GetChildren()) do
		if (obj:IsA('Frame') or obj:IsA('TextLabel')) then obj:Destroy() end
	end

	--if (#passives < 1) then passives = nil end

	addFrameToUpgradeInfo(messages)
	for i = 1, #passives do
		addFrameToUpgradeInfo(passives[i], true)
	end

	local sellPrice = selectedTowerInfo['SellPrice']
	if (not sellPrice) then return end
	mainUI.Upgrade.Sell.SellPrice.Text = '$'..sellPrice

	local upgradePrice = selectedTowerInfo['UpgradePrice']
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

function setupTowerButtons()
	ButtonComponent.new(mainUI.Upgrade.UpgInfo.Upgrade):BindToClick(function()
		if (not currentlySelectedTower) then return end
		SignalComponent:GetSignal('ManageTowersBindable', true):Fire('UpgradeTower')
	end)

	ButtonComponent.new(mainUI.Upgrade.Targetting)

	ButtonComponent.new(mainUI.Upgrade.Sell):BindToClick(function()
		if (not currentlySelectedTower) then return end
		SignalComponent:GetSignal('ManageTowersBindable', true):Fire('SellTower')
		currentlySelectedTower = nil
		selectedTowerInfo = nil
	end)

	--ButtonComponent.new(mainUI.Upgrade.Sell)
	--ButtonComponent.new(mainUI.Upgrade.Sell)

	ButtonComponent.new(mainUI.Upgrade.UpgradeName.arrowLeft)
	ButtonComponent.new(mainUI.Upgrade.UpgradeName.arrowRight)
end


return function(UI, component)
	local replica = component.Replica

    mainUI = UI

    setupTowerButtons()

	SignalComponent:GetSignal('ManageTowersUI', true):Connect(
		function(scope, ...)

			if (scope == 'StartPlacingUI') then startPlacingUI(...) end
			if (scope == 'StopPlacingUI') then stopPlacingUI() end
			if (scope == 'CloseUpgradeUI') then closeUpgradeUI() end
			if (scope == 'UpdateUpgradeUI') then updateUpgradeUI() end

			if (scope == 'OpenUpgradeUI') then 
				currentlySelectedTower, selectedTowerInfo = ...
				openUpgradeUI()
			end

		end
	)

end