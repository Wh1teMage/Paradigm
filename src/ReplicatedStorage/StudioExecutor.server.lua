local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local toolbar = plugin:CreateToolbar("Custom Script Tools")

local newScriptButton = toolbar:CreateButton("Execute Script", "Execute In Studio", "rbxassetid://14978048121")

newScriptButton.ClickableWhenViewportHidden = true

local function onNewScriptButtonClicked()
	local storage = game:GetService("ServerStorage")
	local executionFile = storage:FindFirstChild('Executive')

	if (not executionFile) then
		local newScript = Instance.new('ModuleScript')
		newScript.Source = ''
		newScript.Name = 'Executive'
		newScript.Parent = storage
	else
		require(executionFile)()
	end
end

newScriptButton.Click:Connect(onNewScriptButtonClicked)