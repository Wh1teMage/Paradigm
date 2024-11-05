local TweenService = game:GetService('TweenService')
local StarterGui = game:GetService('StarterGui')

local lastComboUsed = 0
local currentCombo = 0

return {
	['Combo'] = function(component, ui: typeof(StarterGui.MainUI))
		local comboUI = ui.PlayerAttacks.Combo
		local frame = comboUI.CanvasGroup.Frame
		frame.Size = UDim2.fromScale(1,1)
		frame.BackgroundTransparency = 0
		comboUI.Visible = true
		
		lastComboUsed = os.clock()
		currentCombo += 1
		comboUI.Value.Text = 'COMBO x'..tostring(currentCombo)

		TweenService:Create(frame, TweenInfo.new(1.5), 
			{ Size = UDim2.fromScale(0, 1), BackgroundTransparency = .7 }):Play()
		
		task.delay(1.5, function()
			if (os.clock() - lastComboUsed) < 1.5 then return end
			currentCombo = 0
			comboUI.Visible = false
		end)
	end,
}
