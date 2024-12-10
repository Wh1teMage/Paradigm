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

local sessionData = {}
local profileData = {}

local mainUI: typeof(StarterGui.MainUI);

function startPlacingUI(name: string)
	mainUI.PlacingText.Text = 'Placing '..name
	mainUI.PlacingText.Visible = true
end

function stopPlacingUI()
	mainUI.PlacingText.Visible = false
end

function openUpgradeUI() -- make this one into frame component
	FrameComponent.new(mainUI.Upgrade):Open()
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
	ButtonComponent.new(mainUI.Upgrade.UpgInfo.Upgrade)
	ButtonComponent.new(mainUI.Upgrade.Targetting)
	ButtonComponent.new(mainUI.Upgrade.Sell)

	ButtonComponent.new(mainUI.Upgrade.Sell)
	ButtonComponent.new(mainUI.Upgrade.Sell)

	ButtonComponent.new(mainUI.Upgrade.UpgradeName.arrowLeft)
	ButtonComponent.new(mainUI.Upgrade.UpgradeName.arrowRight)
end

return function(UI: typeof(StarterGui.MainUI))
	local component = PlayerComponent:GetPlayer()
	local replica = component.Replica
	
	print(replica, component.Replica, component)
	
	mainUI = UI

	--[[
	replica:ListenToChange('Session.Attributes.Health', function()
		setBarValue(values.Health, sessionData.Attributes.Health, sessionData.Attributes.MaxHealth)
	end)
	]]

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
			if (scope == 'OpenUpgradeUI') then openUpgradeUI() end
			if (scope == 'CloseUpgradeUI') then closeUpgradeUI() end

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
end
