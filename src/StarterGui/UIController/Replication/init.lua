local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local StarterGui = game:GetService('StarterGui')

local Components = StarterGui.Components
local Events = ReplicatedStorage.Events
local Templates = ReplicatedStorage.Templates
local Info = ReplicatedStorage.Info

local ButtonComponent = require(Components.UIButtonComponent)
local PlayerComponent = require(ReplicatedStorage.Components.PlayerComponent) 
local SignalComponent = require(ReplicatedStorage.Components.SignalComponent) 

local PathConfig = require(ReplicatedStorage.Templates.PathConfig) 

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

function manageBaseHealth(value: number)
	local bar: ImageLabel = mainUI.WaveBar.Stats.Health.Bar
	bar.HealthValue.Text = tostring( value )..' HP'

	local defaultValue = 250
	local percentage = math.clamp(value/defaultValue, 0, 1)*0.71

	TweenService:Create(bar, TweenInfo.new(.1, Enum.EasingStyle.Linear), { ['Size'] = UDim2.fromScale(percentage, 1) }):Play()

	mainUI.PlacingText.Visible = false
end

function manageWaveText(value: string)
	local text: TextLabel = mainUI.WaveBar.TextLabel
	text.MaxVisibleGraphemes = 0
	text.Text = value

	for i = 1, string.len(value) do
		text.MaxVisibleGraphemes = i
		task.wait(1/20)
	end
end

function managePlayerCash(value: number)
	mainUI.WaveBar.Stats.PlayerStats.Cash.TextLabel.Text = '$ '..tostring(value)
end

function managePlayerExp(value: number)
	mainUI.WaveBar.Stats.PlayerStats.Exp.TextLabel.Text = 'XP '..tostring(value)
end

local towerLimit = 60
local towerAmount = 0

function managePlayerLimit(current: number, max: number)
	if (max) then towerLimit = max end
	if (current) then towerAmount = current end

	local limit: TextLabel = mainUI.WaveBar.Stats.PlayerStats.Limit.TextLabel
	limit.Text = tostring(towerAmount)..' / '..tostring(towerLimit)
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
			if (scope == 'StartPlacingUI') then startPlacingUI(...) end
			if (scope == 'StopPlacingUI') then stopPlacingUI() end
		end
	)
	
	SignalComponent:GetSignal('ManageTowersUIFromServer'):Connect(
		function(scope, ...)
			if (scope == tostring( PathConfig.Scope.WaveMessage )) then manageWaveText(...) end
			if (scope == tostring( PathConfig.Scope.ChangeBaseHealth )) then manageBaseHealth(...) end
			if (scope == tostring( PathConfig.Scope.ChangeTowerLimit )) then managePlayerLimit(nil, ...) end
		end
	)
end
