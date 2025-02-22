local ReplicatedStorage = game:GetService('ReplicatedStorage')
local SignalComponent = require(ReplicatedStorage.Components.SignalComponent)
local PathConfig = require(ReplicatedStorage.Templates.PathConfig)
local TweenService = game:GetService('TweenService')

local mainUI;

function manageWaveText(value: string)
	local text: TextLabel = mainUI.Container.WaveText
	text.MaxVisibleGraphemes = 0
	text.Text = value

	for i = 1, string.len(value) do
		text.MaxVisibleGraphemes = i
		task.wait(1/20)
	end
end

function manageBaseHealth(value: number)
	local bar: Frame = mainUI.Container.Health.Health
	local barHP: TextLabel = bar:FindFirstChild('HP') :: TextLabel
	local greenBar: Frame = bar:FindFirstChild('Green') :: Frame


	barHP.Text = tostring( value )..' HP'

	local defaultValue = 250
	local percentage = math.clamp(value/defaultValue, 0, 1)

	TweenService:Create(greenBar, TweenInfo.new(.1, Enum.EasingStyle.Linear), { ['Size'] = UDim2.fromScale(percentage, 1) }):Play()
end

local towerLimit = 60
local towerAmount = 0

function managePlayerLimit(current: number?, max: number?)
	if (max) then towerLimit = max end
	if (current) then towerAmount = current end

	local limit: TextLabel = mainUI.Towersbg.TextLabel
	limit.Text = tostring(towerAmount)..' / '..tostring(towerLimit)
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

return function(UI, component)
	local replica = component.Replica
	mainUI = UI

	replica:ListenToChange('Session.Attributes.Cash', function(newValue: number)
		managePlayerCash(newValue)
	end)

	replica:ListenToChange('Session.Attributes.TowerAmount', function(newValue: number)
		managePlayerLimit(newValue, nil)
	end)

	replica:ListenToChange('Profile.Values.ExpValue', function(newValue: number)
		managePlayerExp(newValue)
	end)

	managePlayerCash(replica.Data.Session.Attributes.Cash)
	managePlayerExp(replica.Data.Profile.Values.ExpValue)

	SignalComponent:GetSignal('ManageTowersUIFromServer'):Connect(
		function(scope, ...)
			if (scope == tostring( PathConfig.Scope.WaveMessage )) then manageWaveText(...) end
			if (scope == tostring( PathConfig.Scope.ChangeBaseHealth )) then manageBaseHealth(...) end
			if (scope == tostring( PathConfig.Scope.ChangeTowerLimit )) then managePlayerLimit(nil, ...) end
			if (scope == tostring( PathConfig.Scope.ReplicateEnemyAmount )) then manageEnemyCount(...) end
		end
	)
end